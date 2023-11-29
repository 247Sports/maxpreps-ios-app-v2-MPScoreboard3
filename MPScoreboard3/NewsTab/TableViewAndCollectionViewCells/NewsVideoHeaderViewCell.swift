//
//  NewsVideoHeaderViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 11/29/21.
//

import UIKit
import AviaUI
import Avia
import AviaIMAPlugin
import AdSupport
import AppTrackingTransparency
import AviaTrackingCore
import AviaTrackingComscore
import AviaTrackingNielsen

protocol NewsHeaderViewCellDelegate: AnyObject
{
    func newsHeaderViewCellDidSelectVideo(index: Int)
}

class NewsVideoHeaderViewCell: UITableViewCell, UVPNPlayerViewControllerDelegate, UVPNIMAResourceProviderViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource
{
    weak var delegate: NewsHeaderViewCellDelegate?
    
    @IBOutlet weak var thumbnailBackgroundView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var fadeBackgroundImageView: UIImageView!
    @IBOutlet weak var playIconBackgroundView: UIView!
    @IBOutlet weak var playIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var videoPlayButton: UIButton!
    @IBOutlet weak var inlinePlayerContainerView: UIView!
    @IBOutlet weak var newsVideoCollectionView : UICollectionView!
    
    private var playlistManager : UVPNPlaylistManager?
    private var playerVC : UVPNPlayerViewController?
    private var embeddedVC : UVPNPlayerViewController?
    private var trackingManager : UVPNVideoTrackingManager?
    private var existingAudioCategory = AVAudioSession.sharedInstance().category
    private var existingAudioMode = AVAudioSession.sharedInstance().mode
    private var existingAudioOptions = AVAudioSession.sharedInstance().categoryOptions
    private var videoInfo = [:] as Dictionary<String,String>
    private var videoIdString = ""
    private var trackingGuid = ""
    private var isMaximized = false
    
    private var videosArray = [] as! Array<Dictionary<String,Any>>
    
    var trackingContextData = [:] as Dictionary<String,Any>
    var trackingKey = ""
    var parentVC: UIViewController!
    var playerIsMaximized = false
    
    // MARK: - IMA Delegates
    
    func adViewForIMAResourceProvider(_ imaResourceProvider: UVPNIMAResourceProvider) -> UIView
    {
        return self.playerVC!.avplayerLayerView!
    }
    
    func viewControllerForIMAResourceProvider(_ imaResourceProvider: UVPNIMAResourceProvider) -> UIViewController
    {
        return self.playerVC!
    }
    
    func viewsForOMIDViewabilityExclusionForIMAResourceProvider(_ imaResourceProvider: UVPNIMAResourceProvider) -> [UIView]?
    {
        return playerVC?.viewsToExcludeForOMID()
    }
    
    // MARK: - Get Video Info
    
    func getVideoInfo(hideError: Bool)
    {
        NewFeeds.getVideoInfo(videoId: videoIdString) { videoObj, error in
                        
            if (error == nil)
            {
                print("Get Video Info Successful")
                
                let videoId = videoObj!["videoId"] as! String
                self.videoInfo.updateValue(videoId, forKey: "videoId")
                
                //let videoObj = result!["video"] as! Dictionary<String, Any>
                
                if (videoObj!["title"] != nil)
                {
                    let title = videoObj!["title"] as! String
                    self.titleLabel.text = title
                    self.videoInfo.updateValue(title, forKey: "title")
                }
                
                if (videoObj!["duration"] != nil)
                {
                    let duration = videoObj!["duration"] as! Int
                    self.videoInfo.updateValue(String(duration), forKey: "duration")
                }
                
                // If the partner is not NULL (NULL for MPX Videos), set it from the videoInfo object
                var externalPartner = "MPX"
                
                // Can be null
                if let partner = videoObj!["externalPartner"] as? String
                {
                    externalPartner = partner
                }
                
                self.videoInfo.updateValue(externalPartner, forKey: "externalPartner")
                
                // Can be null
                let mpxId = videoObj!["mpxId"] as? String ?? ""
                self.videoInfo.updateValue(mpxId, forKey: "mpxId")
                
                
                // Use the externalVideoURL instead of renditions if it is available
                if let externalVideoURL = videoObj!["externalVideoURL"] as? String
                {
                    if (externalVideoURL.count > 0)
                    {
                        self.videoInfo.updateValue(externalVideoURL, forKey: "streamingUrl")
                        self.playVideoWithAds(pidMode: false)
                        return
                    }
                }
                
                // Look for the best video to use
                let renditions = videoObj!["renditions"] as! Array<Any>
                
                if (renditions.count == 0)
                {
                    if (hideError == false)
                    {
                        MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "This video can not be played due to a playback error.", lastItemCancelType: false) { tag in
                            
                        }
                    }
                    return
                }
                
                /*
                 {
                 assetType = 3G;
                 deviceType = Mobile;
                 pid = "HUDL_VIDEO";
                 streamingUrl = "https://content.fantag.io/storage/us/maxpreps/4db562a3-d035-4a74-bdd4-0fb3c46ad1fe/source.mp4";
                 videoId = "a0f76e8c-36fa-4e6e-817f-3d72c8f5e560";
                 }
                 */
                
                for item in renditions
                {
                    let rendition = item as! Dictionary<String,Any>
                    if (externalPartner.lowercased() == "hudl")
                    {
                        if (rendition["assetType"] as! String == "WIFI") //&& (rendition["deviceType"] == "PC")
                        {
                            // Break if the preferred case is found
                            if (rendition["streamingUrl"] != nil)
                            {
                                self.videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                                self.videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                                self.videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
                                break
                            }
                        }
                        
                        // Fallback case
                        if (rendition["assetType"] as! String == "3G")
                        {
                            // Break if the preferred case is found
                            if (rendition["streamingUrl"] != nil)
                            {
                                self.videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                                self.videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                                self.videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
                                break
                            }
                        }
                    }
                    else if (externalPartner.lowercased() == "maxpreps legacy video")
                    {
                        if (rendition["assetType"] as! String == "WIFI")
                        {
                            // Break if the preferred case is found
                            if (rendition["streamingUrl"] != nil)
                            {
                                self.videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                                self.videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                                self.videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
                                break
                            }
                        }
                    }
                    else if (externalPartner.lowercased() == "fantag")
                    {
                        if (rendition["assetType"] as! String == "WIFI")
                        {
                            // Break if the preferred case is found
                            if (rendition["streamingUrl"] != nil)
                            {
                                self.videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                                self.videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                                self.videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
                                break
                            }
                        }
                        
                        // Fallback case
                        if (rendition["assetType"] as! String == "3G")
                        {
                            // Break if the preferred case is found
                            if (rendition["streamingUrl"] != nil)
                            {
                                self.videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                                self.videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                                self.videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
                                break
                            }
                        }
                    }
                    else if (externalPartner.lowercased() == "vrv")
                    {
                        if (rendition["assetType"] as! String == "WIFI")
                        {
                            // Break if the preferred case is found
                            if (rendition["streamingUrl"] != nil)
                            {
                                self.videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                                self.videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                                self.videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
                                break
                            }
                        }
                        
                        // Fallback case
                        if (rendition["assetType"] as! String == "3G")
                        {
                            // Break if the preferred case is found
                            if (rendition["streamingUrl"] != nil)
                            {
                                self.videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                                self.videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                                self.videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
                                break
                            }
                        }
                    }
                    else if (externalPartner.lowercased() == "matrix")
                    {
                        if (rendition["assetType"] as! String == "WIFI") //&& (rendition["deviceType"] == "PC")
                        {
                            // Break if the preferred case is found
                            if (rendition["streamingUrl"] != nil)
                            {
                                self.videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                                self.videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                                self.videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
                                break
                            }
                        }
                        
                        // Fallback case
                        if (rendition["assetType"] as! String == "3G")
                        {
                            // Break if the preferred case is found
                            if (rendition["streamingUrl"] != nil)
                            {
                                self.videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                                self.videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                                self.videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
                                break
                            }
                        }
                    }
                    else // MPX Case
                    {
                        // Toss the rendition if the streamingUrl is audio only
                        if let stremaingUrl = rendition["streamingUrl"] as? String
                        {
                            if (stremaingUrl.contains("_0.m3u8") == true)
                            {
                                continue
                            }
                        }
                        
                        // Look for the HLS or HLS_VARIANT_PHONE versions
                        if ((rendition["assetType"] as! String == "HLS_VARIANT_PHONE") || (rendition["assetType"] as! String == "HLS"))
                        {
                            // Break if the preferred case is found
                            if (rendition["streamingUrl"] != nil)
                            {
                                self.videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                                //self.videoInfo.updateValue(rendition["pid"]! as! String, forKey: "pid")
                                self.videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                                self.videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
                                break
                            }
                        }
                        
                        // Fallback case
                        if (rendition["assetType"] as! String == "WIFI")
                        {
                            // Break if the preferred case is found
                            if (rendition["streamingUrl"] != nil)
                            {
                                self.videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                                //self.videoInfo.updateValue(rendition["pid"]! as! String, forKey: "pid")
                                self.videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                                self.videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
                                break
                            }
                        }
                    }
                }
                
                /*
                // Check that the pid or streaming url is valid, then start the player
                if (externalPartner == "MPX")
                {
                    let pid = self.videoInfo["pid"] ?? ""
                    if (pid.count > 0)
                    {
                        self.playVideoWithAds(pidMode: true)
                    }
                    else
                    {
                        MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "This video is not available for your device.", lastItemCancelType: false) { tag in
                            
                        }
                    }
                }
                else
                {
                */
                    // This is for all of the other cases tha use streamingUrl
                    let streamingUrl = self.videoInfo["streamingUrl"] ?? ""
                    if (streamingUrl.count > 0)
                    {
                        // Check to make sure it's not a Flash file
                        let url = URL(string: streamingUrl)
                        let fileExtension = url?.pathExtension
                        
                        if (fileExtension?.lowercased() == "flv")
                        {
                            MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "This video can not be played on an iOS device.", lastItemCancelType: false) { tag in
                                
                            }
                        }
                        else
                        {
                            self.playVideoWithAds(pidMode: false)
                        }
                    }
                    else
                    {
                        MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "This video is not available for your device.", lastItemCancelType: false) { tag in
                            
                        }
                    }
                //}
            }
            else
            {
                print("Get Video Info Failed")
                
                if (hideError == false)
                {
                    MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "This video can not be found.", lastItemCancelType: false) { tag in
                        
                    }
                }
            }
        }
    }
    
    // MARK: - Video Player Methods
    
    private func playVideoWithAds(pidMode: Bool)
    {
        // Enable audio on muted device
        let audioMixEnabled = kUserDefaults.bool(forKey: kAudioMixEnableKey)
        
        if (audioMixEnabled == true)
        {
            // Start with mix mode since the player starts muted
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: .mixWithOthers)
        }
        else
        {
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        }
        
        // Increment the video view count
        let videoId = videoInfo["videoId"]
        NewFeeds.incrementVideoViewCount(videoId: videoId!) { error in
            
            if (error == nil)
            {
                print("Video Count Incremented")
            }
        }
        
        let resourceConfig = UVPNIMAResourceConfiguration()
        
        // Either load the pid or the URL
        if (pidMode == true)
        {
            let pid = videoInfo["pid"]
            resourceConfig.pid = pid
            //resourceConfig.pid = "JVTKJ7We32oa"
        }
        else
        {
            let streamingUrl = videoInfo["streamingUrl"]
            resourceConfig.assetURLString = streamingUrl
        }

        let freeWheelUrl = MiscHelper.buildFreeWheelURL(pidMode: pidMode, videoInfo: videoInfo)
        
        resourceConfig.enableFreeWheelMode = true
        resourceConfig.overridenAdCallURLString = freeWheelUrl
        resourceConfig.usePerAdLoader = true
        //resourceConfig.showAdAttribution = true
        
        playerVC = UVPNPlayerViewController.defaultPlayerViewController()
        
        if let provider = UVPNIMAResourceProvider(resourceConfiguration: resourceConfig)
        {
            //provider.skipAds = true
            //playerVC = UVPNPlayerViewController.defaultPlayerViewController()
            provider.viewDelegate = self
            provider.adClickThroController = self.parentVC //playerVC
            playerVC?.showContentMetadataDuringAds = true
            playerVC?.showProgressForAds = true
            playerVC?.showTimeLabelsForAds = true
            playerVC?.showTopRightWidgetsDuringAds = true
            
            // Additions
            playerVC?.allowAssetOverridesInAppBundle = true
            playerVC?.playerLayerBackgroundColor = .black
            playerVC?.view.backgroundColor = .black
            playerVC?.titleText = ""
            playerVC?.subTitleText = ""
            /*
            // Hide the maximize button if on an iPhone
            if (SharedData.deviceType as! DeviceType == DeviceType.iphone)
            {
                playerVC?.showMaximize = false
            }
             */
            //playerVC?.enableDebugHUD = true
            
            // Add a stop button to the top-right widgets
            let stopButton = UIButton(type: .custom)
            stopButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            stopButton.setImage(UIImage(named: "CloseButtonWhite"), for: .normal)
            //stopButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
            //stopButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
            //stopButton.tintColor = .white
            stopButton.addTarget(self, action: #selector(stopButtonTouched(_:)), for: .primaryActionTriggered)
            playerVC?.topRightCustomControls = [stopButton]
            playerVC?.topRightOrderedControls = [.mute, .airplay, .custom]
            
            /*
            let pipEnabled = kUserDefaults.bool(forKey: kVideoPipEnableKey)
            
            if (pipEnabled == true)
            {
                playerVC?.bottomRightOrderedControls = [.pip]
            }
            */
            playerVC?.showTimeProgressOnLeft = true
            playerVC?.progressBarHeight = 2
            playerVC?.progressBarMinColor = UIColor.mpRedColor()
            playerVC?.progressBarThumbImage = UIImage(named: "CircletRed.png")
            playerVC?.timeLabelsFont = UIFont.systemFont(ofSize: 13, weight: .semibold)
            playerVC?.nowPlayingInfoImage = UIImage(named: "AirplayBackground")
            playerVC?.airplayPosterImage = UIImage(named: "AirplayBackground")
    
            playRP(provider)
        }
    }
    
    // MARK: - Video Player Playlist Init Method
    
    func playRP(_ rp : UVPNResourceProvider)
    {
        if (embeddedVC != nil)
        {
            embeddedVC?.view.removeFromSuperview()
            embeddedVC?.removeFromParent()
        }
        
        self.playlistManager?.resourceCleanupWithCompletion(nil)
        
        let playlistManager = UVPNPlaylistManager()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playlistDone) , name: Notification.Name(kUVPNDidFinishPlaylistPlayback), object: playlistManager)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playbackFailed), name: Notification.Name(kUVPNPlaybackFailed), object: playlistManager)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playlistMuted) , name: Notification.Name(kUVPNPlaylistMuted), object: playlistManager)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playlistUnmuted) , name: Notification.Name(kUVPNPlaylistUnmuted), object: playlistManager)
        
        // Tracking
        let title = videoInfo["title"] ?? ""
        let duration = videoInfo["duration"] ?? "0"
        
        let context = TrackingManager.buildVideoContextData(featureName: "latest-home", videoId: videoIdString, videoTitle: title, videoDuration: Int(duration)!, isMuted: true, isAutoPlay: MiscHelper.videoAutoplayIsOk(), cData: kEmptyTrackingContextData, trackingGuid: self.trackingGuid, ftag: "")
        
        // Changed in V6.3.1
        if (MiscHelper.privacyStatusForUser(consentCategory: "4") == 0)
        {
            trackingManager = UVPNVideoTrackingManager(playlistManager: playlistManager, context: context, debugLogging: true, trackingClasses: [
                UVPNVideoTrackerName.Adobe.rawValue : UVPNAdobeHeartbeatRESTVideoTracker.self,
                UVPNVideoTrackerName.Comscore.rawValue : UVPNComscoreVideoTracker.self
            ])
        }
        else
        {
            trackingManager = UVPNVideoTrackingManager(playlistManager: playlistManager, context: context, debugLogging: true, trackingClasses: [
                UVPNVideoTrackerName.Adobe.rawValue : UVPNAdobeHeartbeatRESTVideoTracker.self,
                UVPNVideoTrackerName.Comscore.rawValue : UVPNComscoreVideoTracker.self,
                UVPNVideoTrackerName.Nielsen.rawValue : UVPNNielsenVideoTracker.self
            ])
        }

        if let playerVC = self.playerVC
        {
            playerVC.delegate = self
            
            embeddedVC = playerVC
            playerVC.view.frame = self.inlinePlayerContainerView.bounds
            self.parentVC.addChild(playerVC)
            self.inlinePlayerContainerView.addSubview(playerVC.view)
            self.inlinePlayerContainerView.isHidden = false
            playerVC.playResourceProvider(rp, with: playlistManager)
        }
        
        self.playlistManager = playlistManager
        self.playlistManager?.muted = true
    }
    
    // MARK: - Player Delegate Method
    
    func playerViewControllerUserDidClose(pvc _: UVPNPlayerViewController)
    {
        NSLog("Closed Closed Closed")
        trackingManager?.cleanup()
    }
    
    func playerViewControllerUserDidMinimize(pvc _: UVPNPlayerViewController)
    {
        NSLog("Min Min Min")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
        {
            self.playerIsMaximized = false
        }
        
    }
    
    func playerViewControllerUserDidMaximize(pvc _: UVPNPlayerViewController)
    {
        NSLog("Max Max Max")
        self.playerIsMaximized = true
    }
    
    //Example for adding custom widgets with custom positioning
    func playerViewControllerViewDidLoad(pvc _: UVPNPlayerViewController)
    {
        NSLog("PlayerDidLoad")
        if let layer = playerVC?.avplayerLayer {
            trackingManager?.playerLayer = layer
        }
    }
    
    @objc func playlistDone()
    {
        self.cleanupVideoPlayer()
        
        self.inlinePlayerContainerView.isHidden = true
    }
    
    @objc func playbackFailed()
    {
        self.cleanupVideoPlayer()
        
        self.inlinePlayerContainerView.isHidden = true
        
        let window = UIApplication.shared.windows[0]
        MiscHelper.showAlert(in: window.rootViewController, withActionNames: ["OK"], title: "Playback Error", message: "The was a problem playing this video.", lastItemCancelType: false) { tag in
            
        }
    }
    
    @objc func playlistMuted()
    {
        NSLog("Muted")
        
        // Enable audio on muted device
        let audioMixEnabled = kUserDefaults.bool(forKey: kAudioMixEnableKey)
        
        if (audioMixEnabled == true)
        {
            // Mix mode
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: .mixWithOthers)
        }
    }
    
    @objc func playlistUnmuted()
    {
        NSLog("Unmuted")
        
        // Enable audio on muted device
        let audioMixEnabled = kUserDefaults.bool(forKey: kAudioMixEnableKey)
        
        if (audioMixEnabled == true)
        {
            // Duck mode
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: .duckOthers)
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func videoPlayButtonTouched()
    {
        self.getVideoInfo(hideError: false)
    }
    
    @objc func stopButtonTouched(_ sender : UIButton)
    {
        NSLog("Stop button")
        
        // This is included in case the user is on the full screen view
        self.parentVC.dismiss(animated: true) {
            
            self.cleanupVideoPlayer()
            self.inlinePlayerContainerView.isHidden = true
        }
    }
    
    // MARK: - Cleanup Video Player
    
    func cleanupVideoPlayer()
    {
        self.playlistManager?.resourceCleanupWithCompletion(nil)

        self.parentVC.dismiss(animated: true) {
            self.embeddedVC?.view.removeFromSuperview()
            self.embeddedVC?.removeFromParent()
            self.embeddedVC = nil
        }

        // Reset the audio
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    // MARK: - Stop Video
    
    func stopVideo()
    {
        self.cleanupVideoPlayer()
        self.inlinePlayerContainerView.isHidden = true
    }
    
    // MARK: - Video Player Maximize/Minimize Methods
    
    func maximizeVideoPlayer()
    {
        if (isMaximized == false)
        {
            self.playlistManager?.pause()
            self.playerVC?.minMaxEmbeddedPlayer()
            isMaximized = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
            {
                self.playlistManager?.resume()
            }
        }
    }
    
    func minimizeVideoPlayer()
    {
        if (isMaximized == true)
        {
            self.playlistManager?.pause()
            self.playerVC?.minMaxEmbeddedPlayer()
            isMaximized = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
            {
                self.playlistManager?.resume()
            }
        }
    }
    
    // MARK: - CollectionView Delegates
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        // Only display the first 10 items
        if (videosArray.count > 10)
        {
            let range = 10...videosArray.count - 1
            videosArray.removeSubrange(range)
            
            return videosArray.count
        }
        else
        {
            return videosArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsVideoCollectionViewCell", for: indexPath) as! NewsVideoCollectionViewCell
        
        let video = videosArray[indexPath.row]
        cell.loadData(data: video)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        self.delegate?.newsHeaderViewCellDidSelectVideo(index: indexPath.row)
    }
    
    // MARK: - Load Data
    
    func loadData(_ data: Array<Dictionary<String,Any>>, autoPlay: Bool)
    {
        self.playerIsMaximized = false
        
        // The data count is guaranteed to be greater than zero when this is called from the parentVC
        
        // Strip out the first video
        if (data.count > 1)
        {
            videosArray = data
            videosArray.remove(at: 0)
            newsVideoCollectionView.reloadData()
        }
        
        // Load the top video cell
        let firstVideo = data.first!
        let time = firstVideo["durationString"] as! String
        let title = firstVideo["title"] as! String
        let publishDateString = firstVideo["publishedOn"] as! String
        let thumbnailUrl = firstVideo["thumbnailUrl"] as? String ?? ""
        
        //let thumbnailUrl =  "https://vg.hudl.com/p-highlights/Team/6545/5d9bcfa7f55f7c00b0d057aa/7d956c2a_720.jpg?v=FE3ABAE3814BD708"
        //let title = "Bronny is now in eSports"
        //let subtitle = "OCT 21, 2021 • JORDAN DIVENS"
        //let time = "2:15"
        
        titleLabel.text = title
        timeLabel.text = time
        
        let dateFormatter = DateFormatter()
        dateFormatter.isLenient = true
        dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
        let publishDate = dateFormatter.date(from: publishDateString)
        
        if (publishDate != nil)
        {
            dateFormatter.dateFormat = "MMM d, yyyy"
            let subtitle = dateFormatter.string(from: publishDate!)
            subtitleLabel.text = subtitle
        }
        else
        {
            subtitleLabel.text = ""
        }
        
        //thumbnailImageView.image = UIImage(named: "TestVideo")
        if (thumbnailUrl.count > 0)
        {
            // Get the data and make an image
            let url = URL(string: thumbnailUrl)
            
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        self.thumbnailImageView.image = image
                    }
                    else
                    {
                        self.thumbnailImageView.image = UIImage(named: "EmptyVideoScores")
                    }
                }
            }
        }
        else
        {
            thumbnailImageView.image = UIImage(named: "EmptyVideoScores")
        }
        
        videoIdString = firstVideo["videoId"] as! String
        
        // Load the video player if autoplay is ok
        if ((MiscHelper.videoAutoplayIsOk() == true) && (autoPlay == true))
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
            {
                self.getVideoInfo(hideError: true)
            }
        }
    }
    
    // MARK: - Load Video Size
    
    func loadVideoSize(_ size: CGSize)
    {
        thumbnailBackgroundView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        thumbnailImageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        inlinePlayerContainerView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        fadeBackgroundImageView.frame = CGRect(x: 0, y: size.height / 2.0, width: size.width, height: size.height / 2.0)
        playIconBackgroundView.center = CGPoint(x: size.width / 2.0, y: (size.height / 2.0) - 15)
        videoPlayButton.center = CGPoint(x: size.width / 2.0, y: (size.height / 2.0) - 15)
        
        titleLabel.text = ""
        subtitleLabel.text = ""
        timeLabel.text = ""
    }
    
    // MARK: - App Entered Background Notification
    
    @objc private func applicationDidEnterBackground()
    {
        //self.stopVideo()
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        trackingGuid = NSUUID().uuidString

        playIconBackgroundView.layer.cornerRadius = playIconBackgroundView.frame.self.width / 2
        playIconBackgroundView.clipsToBounds = true
          
        //contentView.layer.cornerRadius = 12
        //contentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        //contentView.clipsToBounds = true
        
        // Register the NewsVideoCollectionView Cell
        newsVideoCollectionView.register(UINib.init(nibName: "NewsVideoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewsVideoCollectionViewCell")
        
        // Add an observer for the app going into the background
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kUVPNDidFinishPlaylistPlayback), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kUVPNPlaybackFailed), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kUVPNPlaylistMuted), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kUVPNPlaylistUnmuted), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
}
