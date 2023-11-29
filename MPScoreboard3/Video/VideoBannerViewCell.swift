//
//  VideoBannerViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 9/14/23.
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

protocol VideoBannerViewCellDelegate: AnyObject
{
    func videoBannerViewCellDidClose()
    func videoBannerViewPlayerDidMinimize()
}

class VideoBannerViewCell: UITableViewCell, UVPNPlayerViewControllerDelegate, UVPNIMAResourceProviderViewDelegate
{
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var inlinePlayerContainerView: UIView!
    
    weak var delegate: VideoBannerViewCellDelegate?
    var parentVC: UIViewController!
    var trackingKey = ""
    var trackingContextData = kEmptyTrackingContextData
    
    private var playlistManager : UVPNPlaylistManager?
    private var playerVC : UVPNPlayerViewController?
    private var embeddedVC : UVPNPlayerViewController?
    private var trackingManager : UVPNVideoTrackingManager?
    private var existingAudioCategory = AVAudioSession.sharedInstance().category
    private var existingAudioMode = AVAudioSession.sharedInstance().mode
    private var existingAudioOptions = AVAudioSession.sharedInstance().categoryOptions
    
    private var activeVideoIndex = 0
    private var activeVideo: Dictionary<String,Any> = [:]
    private var allVideos: Array<Dictionary<String,Any>> = []
    private var trackingGuid = ""
    private var isMaximized = false
    private var isMuted = true
    
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

    // MARK: - Load Data
    
    func loadData(_ data: Array<Dictionary<String,Any>>)
    {
        allVideos = data
        
        // Set a random starting index
        activeVideoIndex = Int.random(in: 0..<allVideos.count)
        
        closeButton.isHidden = true
        
        self.decodeVideos()
    }
    
    // MARK: - Decode Videos
    
    private func decodeVideos()
    {
        // Build a videoInfo dictionary for the FMS helper
        var videoInfo: Dictionary<String,String> = [:]
        activeVideo = allVideos[activeVideoIndex]
        
        let videoId = activeVideo["videoId"] as? String ?? ""
        videoInfo.updateValue(videoId, forKey: "videoId")

        let title = activeVideo["title"] as? String ?? ""
        videoInfo.updateValue(title, forKey: "title")

        let duration = activeVideo["duration"] as? Int ?? 0
        videoInfo.updateValue(String(duration), forKey: "duration")
        
        // If the partner is not NULL (NULL for MPX Videos), set it from the videoInfo object
        let externalPartner = activeVideo["externalPartner"] as? String ?? "MPX"
        videoInfo.updateValue(externalPartner, forKey: "externalPartner")
        
        // Can be null
        let mpxId = activeVideo["mpxId"] as? String ?? ""
        videoInfo.updateValue(mpxId, forKey: "mpxId")
        
        
        // Use the externalVideoURL instead of renditions if it is available, then exit
        if let externalVideoURL = activeVideo["externalVideoURL"] as? String
        // let externalVideoURL = "https://canhls.cbsaavideo.com/vr/maxpreps/2022/12/28/2155979843697/e3d9c103-db0e-d0ae-5a95-396fc0ad652f_2022-12-27_1579598_phone.m3u8"
        {
            if (externalVideoURL.count > 0)
            {
                videoInfo.updateValue(externalVideoURL, forKey: "streamingUrl")
                self.buildPlayer(videoInfo: videoInfo)
                return
            }
        }
        
        // Look for the best video to use
        let renditions = activeVideo["renditions"] as! Array<Any>
        
        if (renditions.count == 0)
        {
            /*
            MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "This video can not be played due to a playback error.", lastItemCancelType: false) { tag in
            }
            */
            self.playNext()
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
                        videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                        videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                        videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
                        break
                    }
                }
                
                // Fallback case
                if (rendition["assetType"] as! String == "3G")
                {
                    // Break if the preferred case is found
                    if (rendition["streamingUrl"] != nil)
                    {
                        videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                        videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                        videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
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
                        videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                        videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                        videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
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
                        videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                        videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                        videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
                        break
                    }
                }
                
                // Fallback case
                if (rendition["assetType"] as! String == "3G")
                {
                    // Break if the preferred case is found
                    if (rendition["streamingUrl"] != nil)
                    {
                        videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                        videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                        videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
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
                        videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                        videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                        videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
                        break
                    }
                }
                
                // Fallback case
                if (rendition["assetType"] as! String == "3G")
                {
                    // Break if the preferred case is found
                    if (rendition["streamingUrl"] != nil)
                    {
                        videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                        videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                        videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
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
                        videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                        videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                        videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
                        break
                    }
                }
                
                // Fallback case
                if (rendition["assetType"] as! String == "3G")
                {
                    // Break if the preferred case is found
                    if (rendition["streamingUrl"] != nil)
                    {
                        videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                        videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                        videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
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
                        videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                        //self.videoInfo.updateValue(rendition["pid"]! as! String, forKey: "pid")
                        videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                        videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
                        break
                    }
                }
                
                // Fallback case
                if (rendition["assetType"] as! String == "WIFI")
                {
                    // Break if the preferred case is found
                    if (rendition["streamingUrl"] != nil)
                    {
                        videoInfo.updateValue(rendition["streamingUrl"]! as! String, forKey: "streamingUrl")
                        //self.videoInfo.updateValue(rendition["pid"]! as! String, forKey: "pid")
                        videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                        videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
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
        let streamingUrl = videoInfo["streamingUrl"] ?? ""
        if (streamingUrl.count > 0)
        {
            // Check to make sure it's not a Flash file
            let url = URL(string: streamingUrl)
            let fileExtension = url?.pathExtension
            
            if (fileExtension?.lowercased() == "flv")
            {
                /*
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "This video can not be played on an iOS device.", lastItemCancelType: false) { tag in
                }
                */
                self.playNext()
            }
            else
            {
                self.buildPlayer(videoInfo: videoInfo)
            }
        }
        else
        {
            /*
            MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "This video is not available for your device.", lastItemCancelType: false) { tag in
            }
            */
            self.playNext()
        }
    }
    
    // MARK: - Build Player
    
    private func buildPlayer(videoInfo: Dictionary<String,String>)
    {
        inlinePlayerContainerView.isHidden = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 6)
        {
            self.closeButton.isHidden = false
        }
        
        // Enable audio on muted device
        let audioMixEnabled = kUserDefaults.bool(forKey: kAudioMixEnableKey)
        
        if (audioMixEnabled == true)
        {
            // Start with mix mode since the player starts muted
            if (isMuted == true)
            {
                try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: .mixWithOthers)
            }
            else
            {
                // Duck mode
                try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: .duckOthers)
            }
        }
        else
        {
            if (isMuted == true)
            {
                try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            }
            else
            {
                // Mix mode
                try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: .mixWithOthers)
            }
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
        let streamingUrl = videoInfo["streamingUrl"]
        resourceConfig.assetURLString = streamingUrl

        // Build the FMS URL
        let freeWheelUrl = MiscHelper.buildFreeWheelURL(pidMode: false, videoInfo: videoInfo)
        //let freeWheelUrl = "https://7f077.v.fwmrm.net/ad/g/1?asnw=520311&prof=520311%3AGoogleDAICSAI_v01_COPPA&ssnw=520311&vprn=8752772203008914&resp=vmap1%2Bvast4&nw=520311&metr=1023&pvrn=2866541293287341&flag=%2Bamcb%2Bemcr%2Bsltp%2Bslcb%2Bdtrd%2Bvicb%2Bfbad%2Bsync%2Bnucr%2Baeti&csid=vcbs_maxpreps_mobile_iosphone_vod&caid=E6472494-D95D-40FA-8C14-2EE6B40AF277;&givn=[GOOGLE_INSTREAM_VIDEO_NONCE]&sz=640x480&_fw_us_privacy=1YNN&_fw_vcid2=91981b5eb3154fd9e769f7252028181ce65c891d5214521634e22abd9b7132f6&_fw_nielson_app_id=P0C0C37AD-20C4-4EF7-AF25-BEBCB16DF85E&_fw_continuous_play=0&fms_vcid2type=emailhash"
        resourceConfig.enableFreeWheelMode = true
        resourceConfig.overridenAdCallURLString = freeWheelUrl
        resourceConfig.usePerAdLoader = true
        //resourceConfig.showAdAttribution = true
        
        playerVC = UVPNPlayerViewController.defaultPlayerViewController()
        
        if let provider = UVPNIMAResourceProvider(resourceConfiguration: resourceConfig)
        {
            //provider.skipAds = false
            //playerVC = UVPNPlayerViewController.defaultPlayerViewController()
            provider.viewDelegate = self
            provider.adClickThroController = playerVC
            playerVC?.showContentMetadataDuringAds = true // This shows the title instead
            playerVC?.showProgressForAds = true
            playerVC?.showTimeLabelsForAds = false
            playerVC?.showTopRightWidgetsDuringAds = true
            playerVC?.showRewind = false
            playerVC?.showForward = false
            
            // Additions
            playerVC?.allowAssetOverridesInAppBundle = true
            playerVC?.playerLayerBackgroundColor = .black
            playerVC?.view.backgroundColor = .black
            playerVC?.titleText = ""
            playerVC?.subTitleText = ""
            //playerVC?.playbackButtonsSizeInMinimal = 32.0
            /*
            // Hide the maximize button if on an iPhone
            if (SharedData.deviceType as! DeviceType == DeviceType.iphone)
            {
                playerVC?.showMaximize = false
            }
             */
            playerVC?.enableDebugHUD = true
            
            /*
            // Add a stop button to the top-right widgets
            let stopButton = UIButton(type: .custom)
            stopButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            stopButton.setImage(UIImage(named: "CloseButtonWhite"), for: .normal)
            //stopButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
            //stopButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
            //stopButton.tintColor = .white
            stopButton.addTarget(self, action: #selector(stopButtonTouched(_:)), for: .primaryActionTriggered)
            playerVC?.topRightCustomControls = [stopButton]
            */
            playerVC?.topRightOrderedControls = [.mute] //[.mute, .custom]
            //playerVC?.bottomRightOrderedControls = [.mute]
            
            /*
            let pipEnabled = kUserDefaults.bool(forKey: kVideoPipEnableKey)
            
            if (pipEnabled == true)
            {
                playerVC?.bottomRightOrderedControls = [.pip]
            }
            */
            
            
            playerVC?.showTimeProgressOnLeft = false
            playerVC?.progressBarHeight = 2
            playerVC?.bottomProgressBottomSpacing = 10
            playerVC?.progressBarMinColor = UIColor.mpRedColor()
            playerVC?.progressBarThumbImage = UIImage(named: "CircletRed.png")
            playerVC?.timeLabelsFont = UIFont.systemFont(ofSize: 13, weight: .semibold)
            playerVC?.nowPlayingInfoImage = UIImage(named: "AirplayBackground")
            playerVC?.airplayPosterImage = UIImage(named: "AirplayBackground")
            
            playRP(provider)
        }
    }
    
    // MARK: - Video Player Playlist Init Method
    
    private func playRP(_ rp : UVPNResourceProvider)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(adError) , name: Notification.Name(kUVPNAdError), object: playlistManager)
        
        
        // Tracking
        let title = activeVideo["title"] as? String ?? ""
        let durationInt = activeVideo["duration"] as? Int ?? 0
        let videoId = activeVideo["videoId"] as? String ?? ""
        
        let context = TrackingManager.buildVideoContextData(featureName: self.trackingKey, videoId: videoId, videoTitle: title, videoDuration: durationInt, isMuted: true, isAutoPlay: MiscHelper.videoAutoplayIsOk(), cData: self.trackingContextData, trackingGuid: self.trackingGuid, ftag: "")
        
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
            //let width = playerVC.view.bounds.size.width
            //let height = playerVC.view.bounds.size.height
            //print(String(format: "W: %1.0f, H: %1.0f", width, height))
            playerVC.view.frame = inlinePlayerContainerView.bounds
            self.parentVC.addChild(playerVC)
            inlinePlayerContainerView.addSubview(playerVC.view)
            inlinePlayerContainerView.isHidden = false
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
        
        // This callback is used to show or hide the parent's tabBar
        self.delegate?.videoBannerViewPlayerDidMinimize()
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
        if let layer = playerVC?.avplayerLayer {
            trackingManager?.playerLayer = layer
        }
    }
    
    private func playNext()
    {
        self.cleanupVideoPlayer()
        inlinePlayerContainerView.isHidden = true
        closeButton.isHidden = true
        
        activeVideoIndex += 1
        if (activeVideoIndex == allVideos.count)
        {
            // Start over
            activeVideoIndex = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            self.decodeVideos()
        }
    }
    
    @objc func playlistDone()
    {
        self.playNext()
    }
    
    @objc func playbackFailed()
    {
        self.playNext()
    }
    
    @objc func playlistMuted()
    {
        NSLog("Muted")
        isMuted = true
        
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
        isMuted = false
        
        // Enable audio on muted device
        let audioMixEnabled = kUserDefaults.bool(forKey: kAudioMixEnableKey)
        
        if (audioMixEnabled == true)
        {
            // Duck mode
            try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: .duckOthers)
        }
    }
    
    @objc func adError(notification: Notification)
    {
        NSLog("Ad Error")
        let userInfo = notification.userInfo
        let error = userInfo![kUVPNAdErrorKey] as! NSError
        print(error.localizedDescription)
        
        /*
         Error Domain=com.avia.AVIA_AD_ERROR Code=5301 "UVPNErrorEvent(rawValue: 5301) - Avia Ad Error" UserInfo={provider=<AviaIMAPlugin.UVPNIMAResourceProvider: 0x15c01eb00>, NSLocalizedDescription=UVPNErrorEvent(rawValue: 5301) - Avia Ad Error, NSUnderlyingError=0x2827b7d20 {Error Domain=com.avia.IMA_ADS_LOADER_FAILED Code=5514 "UVPNErrorEvent(rawValue: 5514) - IMA AdsLoader failed with - IMAErrorCode(rawValue: 1005) : Optional("Ads cannot be requested because the ad container is not attached to the view hierarchy.")" UserInfo={shortCode=IMA_ADS_LOADER_FAILED, NSLocalizedDescription=UVPNErrorEvent(rawValue: 5514) - IMA AdsLoader failed with - IMAErrorCode(rawValue: 1005) : Optional("Ads cannot be requested because the ad container is not attached to the view hierarchy."), NSUnderlyingError=0x2827b76c0 {Error Domain=com.avia Code=1005 "IMA Ad Error : IMAErrorCode(rawValue: 1005) - Ads cannot be requested because the ad container is not attached to the view hierarchy.)" UserInfo={NSLocalizedDescription=IMA Ad Error : IMAErrorCode(rawValue: 1005) - Ads cannot be requested because the ad container is not attached to the view hierarchy.), IMAErrorType=__C.IMAErrorType(rawValue: 1)}}, provider=<AviaIMAPlugin.UVPNIMAResourceProvider: 0x15c01eb00>}}, shortCode=AVIA_AD_ERROR}
         */
    }

    // MARK: - Button Methods
    
    @IBAction func videoPlayButtonTouched()
    {
        //self.getVideoInfo(hideError: false)
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
        if (isMaximized == true)
        {
            self.playerVC?.minMaxEmbeddedPlayer()
            isMaximized = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            self.playlistManager?.resourceCleanupWithCompletion(nil)
            self.embeddedVC?.view.removeFromSuperview()
            self.embeddedVC?.removeFromParent()
            self.embeddedVC = nil
        }

        /*
        self.parentVC.dismiss(animated: true) {
            self.embeddedVC?.view.removeFromSuperview()
            self.embeddedVC?.removeFromParent()
            self.embeddedVC = nil
        }
        */

        // Reset the audio
        try? AVAudioSession.sharedInstance().setActive(false)
    }
    
    // MARK: - Stop Video
    
    func stopVideo()
    {
        self.cleanupVideoPlayer()
        self.inlinePlayerContainerView.isHidden = true
        self.closeButton.isHidden = true
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
    
    // MARK: - Button Methods
    
    @IBAction func closeButtonTouched()
    {
        self.stopVideo()
        self.delegate?.videoBannerViewCellDidClose()
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        trackingGuid = NSUUID().uuidString
        closeButton.isHidden = true
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
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kUVPNAdError), object: nil)
    }
    
}
