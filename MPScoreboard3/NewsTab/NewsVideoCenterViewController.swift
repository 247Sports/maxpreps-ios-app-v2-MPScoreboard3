//
//  NewsVideoCenterViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 12/2/21.
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

class NewsVideoCenterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UVPNPlayerViewControllerDelegate, UVPNIMAResourceProviderViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var inlinePlayerContainerView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var playIconBackgroundView: UIView!
    @IBOutlet weak var videoFadeBackgroundImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var videoPlayButton: UIButton!
    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var titleContainerTitleLabel: UILabel!
    @IBOutlet weak var titleContainerSubtitleLabel: UILabel!
    @IBOutlet weak var videoTableView: UITableView!
    
    var videosArray = [] as! Array<Dictionary<String,Any>>
    var selectedIndex = 0
    
    private var playlistManager : UVPNPlaylistManager?
    private var playerVC : UVPNPlayerViewController?
    private var embeddedVC : UVPNPlayerViewController?
    private var trackingManager : UVPNVideoTrackingManager?
    private var existingAudioCategory = AVAudioSession.sharedInstance().category
    private var existingAudioMode = AVAudioSession.sharedInstance().mode
    private var videoInfo = [:] as Dictionary<String,String>
    private var videoIdString = ""
    private var isMuted = true
    private var trackingGuid = ""
    private var isMaximized = false
    
    var trackingContextData = [:] as Dictionary<String,Any>
    var trackingKey = ""
    
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
    
    private func getVideoInfo()
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
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This video can not be played due to a playback error.", lastItemCancelType: false) { tag in
                        
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
                        //let window = UIApplication.shared.windows[0]

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
                            //let window = UIApplication.shared.windows[0]

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

                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "This video can not be found.", lastItemCancelType: false) { tag in
                    
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
            provider.adClickThroController = playerVC
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
        
        let context = TrackingManager.buildVideoContextData(featureName: self.trackingKey, videoId: videoIdString, videoTitle: title, videoDuration: Int(duration)!, isMuted: true, isAutoPlay: true, cData: self.trackingContextData, trackingGuid: self.trackingGuid, ftag: "")
        
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
            self.addChild(playerVC)
            self.inlinePlayerContainerView.addSubview(playerVC.view)
            self.inlinePlayerContainerView.isHidden = false
            playerVC.playResourceProvider(rp, with: playlistManager)
        }
        
        self.playlistManager = playlistManager
        self.playlistManager?.muted = isMuted
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
    }
    
    func playerViewControllerUserDidMaximize(pvc _: UVPNPlayerViewController)
    {
        NSLog("Max Max Max")
    }
    
    //Example for adding custom widgets with custom positioning
    func playerViewControllerViewDidLoad(pvc _: UVPNPlayerViewController)
    {
        NSLog("PlayerDidLoad")
        if let layer = playerVC?.avplayerLayer
        {
            trackingManager?.playerLayer = layer
        }
    }
    
    func playerViewControllerUserDidPause(pvc: UVPNPlayerViewController)
    {
        // Find the active cell
        if let selectedCell = videoTableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as? NewsVideoCenterTableViewCell
        {
            selectedCell.loadNowPlaying("Paused")
        }
        
    }
    
    func playerViewControllerUserDidResume(pvc: UVPNPlayerViewController)
    {
        // Find the active cell
        if let selectedCell = videoTableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as? NewsVideoCenterTableViewCell
        {
            selectedCell.loadNowPlaying("Now Playing")
        }
    }
    
    @objc func playlistDone()
    {
        // Retain the muted state
        isMuted = (self.playlistManager?.muted)!
        
        // Find the active cell
        if let selectedCell = videoTableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as? NewsVideoCenterTableViewCell
        {
            selectedCell.loadNowPlaying("Stopped")
        }
        
        self.stopVideo()
        
        // Autoplay the next video
        if (selectedIndex < (videosArray.count - 1))
        {
            selectedIndex += 1
        }
        else
        {
            selectedIndex = 0
        }
        
        videoTableView.reloadData()
        
        self.scrollToSelectedIndex()
                
        //self.loadHeader()
        
        // Start the player again
        let video = videosArray[selectedIndex]
        videoIdString = video["videoId"] as! String
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
        {
            //self.getVideoInfo()
            self.loadHeader()
        }
    }
    
    @objc func playbackFailed()
    {
        self.cleanupVideoPlayer()
        
        self.inlinePlayerContainerView.isHidden = true
        
        MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "Playback Error", message: "The was a problem playing this video.", lastItemCancelType: false) { tag in
            
        }
        
        // Find the active cell
        if let selectedCell = videoTableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as? NewsVideoCenterTableViewCell
        {
            selectedCell.loadNowPlaying("Playback Error")
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
    
    // MARK: - Video Player Button Methods
    
    @objc func stopButtonTouched(_ sender : UIButton)
    {
        NSLog("Stop button")
        
        // This is included in case the user is on the full screen view
        self.dismiss(animated: true) {
            
            self.cleanupVideoPlayer()
            self.inlinePlayerContainerView.isHidden = true
        }
        
        // Find the active cell
        if let selectedCell = videoTableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as? NewsVideoCenterTableViewCell
        {
            selectedCell.loadNowPlaying("Stopped")
        }
    }
    
    // MARK: - Cleanup Video Player
    
    func cleanupVideoPlayer()
    {
        self.playlistManager?.resourceCleanupWithCompletion(nil)

        self.dismiss(animated: true) {
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
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        print("Videos: " + String(videosArray.count))
        return videosArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 122
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "NewsVideoCenterTableViewCell") as? NewsVideoCenterTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("NewsVideoCenterTableViewCell", owner: self, options: nil)
            cell = nib![0] as? NewsVideoCenterTableViewCell
        }
        cell?.selectionStyle = .none
        cell?.horizLine.isHidden = false
        
        let video = videosArray[indexPath.row]
        
        // Highlight the active cell
        if (indexPath.row == selectedIndex)
        {
            cell?.loadData(data:video, isHighlighted: true)
        }
        else
        {
            cell?.loadData(data:video, isHighlighted: false)
        }
        
        if ((indexPath.row) == (videosArray.count - 1))
        {
            cell?.horizLine.isHidden = true
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.row == selectedIndex)
        {
            return
        }
        
        selectedIndex = indexPath.row
        
        videoTableView.reloadData()
        
        self.stopVideo()
        
        //self.loadHeader()
        
        // Start the player again
        let video = videosArray[selectedIndex]
        videoIdString = video["videoId"] as! String
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            //self.getVideoInfo()
            self.loadHeader()
        }
    }
    
    // MARK: - Scroll to SelectedIndex
    
    private func scrollToSelectedIndex()
    {
        if (videosArray.count > selectedIndex)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                self.videoTableView.scrollToRow(at: IndexPath(row: self.selectedIndex, section: 0), at: .top, animated: true)
            }
        }
    }
    
    // MARK: - Load Header
    
    private func loadHeader()
    {
        let video = videosArray[selectedIndex]
        
        let title = video["title"] as! String
        let time = video["durationString"] as! String
        let publishDateString = video["publishedOn"] as! String
        
        let dateFormatter = DateFormatter()
        dateFormatter.isLenient = true
        dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
        let publishDate = dateFormatter.date(from: publishDateString)
        
        if (publishDate != nil)
        {
            dateFormatter.dateFormat = "MMM d, yyyy"
            let subtitle = dateFormatter.string(from: publishDate!)
            titleContainerSubtitleLabel.text = subtitle
        }
        else
        {
            titleContainerSubtitleLabel.text = ""
        }
        
        titleContainerTitleLabel.text = title
        timeLabel.text = time
        
        let thumbnailUrl = video["thumbnailUrl"] as? String ?? ""
            
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
        
        videoIdString = video["videoId"] as! String
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            self.getVideoInfo()
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.stopVideo()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func videoPlayButtonTouched()
    {
        let video = videosArray[selectedIndex]
        videoIdString = video["videoId"] as! String
        self.getVideoInfo()
        
        // Find the active cell
        if let selectedCell = videoTableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as? NewsVideoCenterTableViewCell
        {
            selectedCell.loadNowPlaying("Now Playing")
        }
    }
    
    // MARK: - Orientation Changed Method
    
    @objc private func orientationChanged()
    {
        if UIDevice.current.orientation.isLandscape
        {
            print("Landscape")
            self.maximizeVideoPlayer()
        }
        else
        {
            print("Portrait")
            self.minimizeVideoPlayer()
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        trackingGuid = NSUUID().uuidString

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, videoContainer, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        
        // The height is variable
        let videoHeight = ((kDeviceWidth * 9) / 16)
        inlinePlayerContainerView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: videoHeight)
        thumbnailImageView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: videoHeight)
        videoFadeBackgroundImageView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height + videoHeight - videoFadeBackgroundImageView.frame.size.height, width: kDeviceWidth, height: videoFadeBackgroundImageView.frame.size.height)
        timeLabel.frame = CGRect(x: kDeviceWidth - timeLabel.frame.size.width - 16, y: navView.frame.origin.y + navView.frame.size.height + videoHeight - 28, width: timeLabel.frame.size.width, height: timeLabel.frame.size.height)
        playIconBackgroundView.center = thumbnailImageView.center
        videoPlayButton.center = thumbnailImageView.center
        
        titleContainerView.frame = CGRect(x: 0, y: inlinePlayerContainerView.frame.origin.y + inlinePlayerContainerView.frame.size.height, width: kDeviceWidth, height: titleContainerView.frame.size.height)
        
        videoTableView.frame = CGRect(x: 0, y: titleContainerView.frame.origin.y + titleContainerView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - titleContainerView.frame.origin.y - titleContainerView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight))
        
        playIconBackgroundView.layer.cornerRadius = playIconBackgroundView.frame.size.width / 2.0
        playIconBackgroundView.clipsToBounds = true
        
        thumbnailImageView.image = nil
        
        self.loadHeader()
        
        // Scroll to the active index
        self.scrollToSelectedIndex()
        /*
        // Add a device orientation handler if on an iPhone
        if (SharedData.deviceType as! DeviceType == DeviceType.iphone)
        {
            NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        }
         */
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.lightContent
    }
    
    override open var shouldAutorotate: Bool
    {
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation
    {
        return UIInterfaceOrientation.portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        return .portrait
    }

    deinit
    {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kUVPNDidFinishPlaylistPlayback), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kUVPNPlaybackFailed), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kUVPNPlaylistMuted), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kUVPNPlaylistUnmuted), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
}
