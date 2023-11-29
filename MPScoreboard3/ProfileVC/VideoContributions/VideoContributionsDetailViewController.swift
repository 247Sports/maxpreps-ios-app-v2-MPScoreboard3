//
//  VideoContributionsDetailViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 1/3/23.
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

class VideoContributionsDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UVPNPlayerViewControllerDelegate, UVPNIMAResourceProviderViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var inlinePlayerContainerView: UIView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var playIconBackgroundView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var videoPlayButton: UIButton!
    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var titleContainerTitleLabel: UILabel!
    @IBOutlet weak var titleContainerDescriptionLabel: UILabel!
    @IBOutlet weak var titleContainerDateLabel: UILabel!
    @IBOutlet weak var titleContainerViewCountLabel: UILabel!
    @IBOutlet weak var taggedAthletesTableView: UITableView!
    
    var selectedVideoObj = [:] as! Dictionary<String,Any>
    
    private var progressOverlay: ProgressHUD!
    private var taggedAthletesArray = [] as Array
    //private var isTeamVideo = false
    private var videoEditorVC: VideoContributionsEditorViewController!
    
    private var playlistManager : UVPNPlaylistManager?
    private var playerVC : UVPNPlayerViewController?
    private var embeddedVC : UVPNPlayerViewController?
    private var trackingManager : UVPNVideoTrackingManager?
    private var existingAudioCategory = AVAudioSession.sharedInstance().category
    private var existingAudioMode = AVAudioSession.sharedInstance().mode
    private var videoInfo = [:] as Dictionary<String,String>
    private var videoIdString = ""
    private var isMuted = true
    //private var trackingGuid = ""
    private var isMaximized = false
    
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
        print("Get Video Info: " + videoIdString)
        
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

                        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This video is not available for your device.", lastItemCancelType: false) { tag in
                            
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

                            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This video can not be played on an iOS device.", lastItemCancelType: false) { tag in
                                
                            }
                        }
                        else
                        {
                            self.playVideoWithAds(pidMode: false)
                        }
                    }
                    else
                    {
                        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This video is not available for your device.", lastItemCancelType: false) { tag in
                            
                        }
                    }
                //}
            }
            else
            {
                print("Get Video Info Failed")

                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This video can not be found.", lastItemCancelType: false) { tag in
                    
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
        
        /*
        // Increment the video view count
        let videoId = videoInfo["videoId"]
        NewFeeds.incrementVideoViewCount(videoId: videoId!) { error in
            
            if (error == nil)
            {
                print("Video Count Incremented")
            }
        }
        */
        
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

        /*
        let freeWheelUrl = MiscHelper.buildFreeWheelURL(pidMode: pidMode, videoInfo: videoInfo)
        
        resourceConfig.enableFreeWheelMode = true
        resourceConfig.overridenAdCallURLString = freeWheelUrl
        resourceConfig.usePerAdLoader = true
        //resourceConfig.showAdAttribution = true
        */
        playerVC = UVPNPlayerViewController.defaultPlayerViewController()
        
        if let provider = UVPNIMAResourceProvider(resourceConfiguration: resourceConfig)
        {
            provider.skipAds = true
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
        isMaximized = false
        
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
        
        // Tracking is disabled for this instance
        /*
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
        */

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
        isMaximized = false
    }
    
    func playerViewControllerUserDidMaximize(pvc _: UVPNPlayerViewController)
    {
        NSLog("Max Max Max")
        isMaximized = true
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
    
    @objc func playlistDone()
    {
        // Retain the muted state
        isMuted = (self.playlistManager?.muted)!
        
        self.stopVideo()
        
        /*
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
        */
    }
    
    @objc func playbackFailed()
    {
        self.cleanupVideoPlayer()
        
        self.inlinePlayerContainerView.isHidden = true
        
        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Playback Error", message: "The was a problem playing this video.", lastItemCancelType: false) { tag in
            
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
        if (isMaximized == true)
        {
            self.dismiss(animated: true) {
                
                self.cleanupVideoPlayer()
                self.inlinePlayerContainerView.isHidden = true
            }
        }
        else
        {
            self.cleanupVideoPlayer()
            self.inlinePlayerContainerView.isHidden = true
        }
    }
    
    // MARK: - Cleanup Video Player
    
    func cleanupVideoPlayer()
    {
        self.playlistManager?.resourceCleanupWithCompletion(nil)

        if (isMaximized == true)
        {
            self.dismiss(animated: true) {
                self.embeddedVC?.view.removeFromSuperview()
                self.embeddedVC?.removeFromParent()
                self.embeddedVC = nil
            }
        }
        else
        {
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
    
    // MARK: - Get Tagged Athletes
    
    private func getTaggedAthletes(videoId: String)
    {
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.getVideoTaggedCareers(videoId: videoId) { items, error in
            
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                //MBProgressHUD.hide(for: self.view, animated: true)
                if (self.progressOverlay != nil)
                {
                    self.progressOverlay.hide(animated: false)
                    self.progressOverlay = nil
                }
            }
            
            if (error == nil)
            {
                
                self.taggedAthletesArray = items!["careers"] as! Array<Dictionary<String,Any>>
                print("Get Tagged Athletes Success")
                
                if (self.taggedAthletesArray.count == 0)
                {
                    // Disable scrolling
                    self.taggedAthletesTableView?.isScrollEnabled = false
                }
                else
                {
                    self.taggedAthletesTableView?.isScrollEnabled = true
                }
            }
            
            self.taggedAthletesTableView?.reloadData()
        }
    }
    
    // MARK: - Untag Athlete
    
    private func untagAthlete(careerId: String)
    {
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        let videoId = selectedVideoObj["videoId"] as! String
            
        NewFeeds.untagAthleteFomVideo(videoId: videoId, careerId: careerId) { error in
            
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                //MBProgressHUD.hide(for: self.view, animated: true)
                if (self.progressOverlay != nil)
                {
                    self.progressOverlay.hide(animated: false)
                    self.progressOverlay = nil
                }
            }
            
            if (error == nil)
            {
                OverlayView.showPopupOverlay(withMessage: "Athlete Untagged")
                {
                    self.getTaggedAthletes(videoId: videoId)
                }
            }
            else
            {
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "An error occured while trying to untag this athlete.", lastItemCancelType: false) { tag in
                    
                }
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
        return taggedAthletesArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 32.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 24.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (self.taggedAthletesArray.count > 0)
        {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 32.0))
            headerView.backgroundColor = UIColor.mpBlackColor()
            
            let headerLabel = UILabel(frame: CGRect(x: 16.0, y: 8, width: kDeviceWidth - 32.0, height: 24.0))
            headerLabel.textColor = UIColor.mpLighterGrayColor()
            headerLabel.font = UIFont.mpRegularFontWith(size: 13)
            headerLabel.text = "Tagged"
            headerView.addSubview(headerLabel)
            
            return headerView
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "TeamVideoDarkCareerTableViewCell") as? TeamVideoDarkCareerTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("TeamVideoDarkCareerTableViewCell", owner: self, options: nil)
            cell = nib![0] as? TeamVideoDarkCareerTableViewCell
        }
        
        cell?.selectionStyle = .none
        cell?.deleteButton.isHidden = false
        
        let taggedAthlete = taggedAthletesArray[indexPath.row] as! Dictionary<String, Any>
        
        let firstName = taggedAthlete["firstName"] as! String
        let lastName = taggedAthlete["lastName"] as! String
        let athletePhotoUrlString = taggedAthlete["photoUrl"] as! String
        let schoolName = taggedAthlete["schoolName"] as! String
        let schoolCity = taggedAthlete["schoolCity"] as! String
        let schoolState = taggedAthlete["schoolState"] as! String
        
        cell?.titleLabel.text = firstName + " " + lastName
        
        if (schoolName == schoolCity)
        {
            cell?.subtitleLabel.text = String(format: "%@ (%@)", schoolName, schoolState)
        }
        else
        {
            cell?.subtitleLabel.text = String(format: "%@ (%@, %@)", schoolName, schoolCity, schoolState)
        }

        cell?.athletePhotoImageView.image = UIImage(named: "Avatar")
        
        if (athletePhotoUrlString.count > 0)
        {
            let url = URL(string: athletePhotoUrlString)
            
            SDWebImageManager.shared().downloadImage(with: url!, progress: { receivedSize, expectedSize in
                
            }, completed: { image, error, cacheType, finished, imageUrl in
                
                if (image != nil)
                {
                    cell?.athletePhotoImageView.image = image
                }
            })
        }
        
        // Hide the deleteButton if this is a team video
        //cell?.deleteButton.isHidden = isTeamVideo
        cell?.deleteButton.tag = 100 + indexPath.row
        cell?.deleteButton.addTarget(self, action: #selector(deleteButtonTouched(_:)), for: .touchUpInside)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Button Methods
    
    @IBAction func closeButtonTouched()
    {
        self.stopVideo()
        self.dismiss(animated: true)
    }
    
    @IBAction func editButtonTouched()
    {
        videoEditorVC = VideoContributionsEditorViewController(nibName: "VideoContributionsEditorViewController", bundle: nil)
        videoEditorVC.selectedVideoObj = self.selectedVideoObj
        self.navigationController?.pushViewController(videoEditorVC, animated: true)
    }
    
    @IBAction func shareButtonTouched()
    {
        let videoUrlString = selectedVideoObj["canonicalUrl"] as! String
        
        if (videoUrlString.count > 0)
        {
            // Call the Bitly feed to compress the URL
            NewFeeds.getBitlyUrl(videoUrlString) { (dictionary, error) in
      
                var dataToShare = [kShareMessageText + videoUrlString]
                
                if (error == nil)
                {
                    print("Done")
                    if let shortUrl = dictionary!["data"] as? String
                    {
                        if (shortUrl.count > 0)
                        {
                            dataToShare = [kShareMessageText + shortUrl]
                        }
                    }
                }
                
                self.playlistManager?.pause()
                
                let activityVC = UIActivityViewController(activityItems: dataToShare, applicationActivities: nil)
                activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
                activityVC.modalPresentationStyle = .fullScreen
                //activityVC.overrideUserInterfaceStyle = .dark
                self.present(activityVC, animated: true)
            }
        }
        else
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This video can not be shared.", lastItemCancelType: false) { tag in
                
            }
        }
    }
    
    @IBAction func videoPlayButtonTouched()
    {
        videoIdString = selectedVideoObj["videoId"] as! String
        self.getVideoInfo()
    }
    
    @objc private func deleteButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        MiscHelper.showAlert(in: self, withActionNames: ["Cancel", "Untag"], title: "Untag Athlete?", message: "Do you want to untag this athlete from the video?", lastItemCancelType: true) { tag in
            
            if (tag == 1)
            {
                let taggedAthlete = self.taggedAthletesArray[index] as! Dictionary<String, Any>
                let careerId = taggedAthlete["careerId"] as! String
                
                self.untagAthlete(careerId: careerId)
            }
        }
    }
    
    // MARK: - Load Title Container
    
    private func loadTitleContainer()
    {
        // Look for the teamReferences Array to determine if this is a team video
        //let teamReferences = selectedVideoObj["teamReferences"] as? Array ?? []
        
        //if (teamReferences.count > 0)
        //{
            //isTeamVideo = true
        //}
        
        let title = selectedVideoObj["title"] as! String
        titleContainerTitleLabel!.text = title
        
        let publishDate = selectedVideoObj["formattedPublishedOn"] as? String ?? ""
        titleContainerDateLabel!.text = publishDate
        
        let durationString = selectedVideoObj["durationString"] as! String
        timeLabel.text = durationString
        
        let viewCount = selectedVideoObj["viewCount"] as? Int ?? 0
        
        if (viewCount >= 1000000)
        {
            let viewCountFloat = Float(viewCount) / 1000000.0
            titleContainerViewCountLabel!.text = String(format: "%1.1fm", viewCountFloat)
        }
        else
        {
            if (viewCount >= 1000)
            {
                let viewCountFloat = Float(viewCount) / 1000.0
                titleContainerViewCountLabel!.text = String(format: "%1.1fk", viewCountFloat)
            }
            else
            {
                titleContainerViewCountLabel!.text = String(format: "%d", viewCount)
            }
        }
        
        let description = selectedVideoObj["description"] as! String
        //print("Description: " + description)
        titleContainerDescriptionLabel.text = description
        
        // Calculate the descriptionTextHeight
        let descriptionTextHeight = description.height(withConstrainedWidth: kDeviceWidth - 32, font: UIFont.mpRegularFontWith(size: 13))
        //print(String(Int(descriptionTextHeight)))
        
        titleContainerView.frame = CGRect(x: 0, y: thumbnailImageView.frame.origin.y + thumbnailImageView.frame.size.height, width: kDeviceWidth, height: descriptionTextHeight + 50 + 64 + 28)
                
        taggedAthletesTableView.frame = CGRect(x: 0, y: titleContainerView.frame.origin.y + titleContainerView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - titleContainerView.frame.origin.y - titleContainerView.frame.size.height)
        
        // Load the thumbnail
        let thumbnailUrl = selectedVideoObj["thumbnailUrl"] as? String ?? ""
            
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
        
        // Get the tagged athletes
        let videoId = selectedVideoObj["videoId"] as! String
        self.getTaggedAthletes(videoId: videoId)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Size the fakeStatusBar, navBar, and scrollView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        
        // The height is variable
        let videoHeight = ((kDeviceWidth * 9) / 16)
        inlinePlayerContainerView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: videoHeight)
        thumbnailImageView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: videoHeight)
        timeLabel.frame = CGRect(x: 8, y: navView.frame.origin.y + navView.frame.size.height + videoHeight - 28, width: timeLabel.frame.size.width, height: timeLabel.frame.size.height)
        playIconBackgroundView.center = thumbnailImageView.center
        videoPlayButton.center = thumbnailImageView.center
        
        self.thumbnailImageView.image = nil
        
        timeLabel.layer.cornerRadius = 6
        timeLabel.clipsToBounds = true
        
        playIconBackgroundView.layer.cornerRadius = playIconBackgroundView.frame.size.width / 2.0
        playIconBackgroundView.clipsToBounds = true
        
        // The titleContainerView and tableView will be resized when the data is loaded
        titleContainerView.frame = CGRect(x: 0, y: thumbnailImageView.frame.origin.y + thumbnailImageView.frame.size.height, width: kDeviceWidth, height: titleContainerView.frame.size.height)
        
        taggedAthletesTableView.frame = CGRect(x: 0, y: titleContainerView.frame.origin.y + titleContainerView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - titleContainerView.frame.origin.y - titleContainerView.frame.size.height)
        
        self.loadTitleContainer()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mpBlackColor(), .font: UIFont.mpSemiBoldFontWith(size: kNavBarFontSize)]
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (videoEditorVC != nil)
        {
            if (videoEditorVC.videoDetailsUpdated == true)
            {
                videoEditorVC = nil
                self.dismiss(animated: true)
            }
            else
            {
                videoEditorVC = nil
            }
        }
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
    }
}
