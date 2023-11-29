//
//  VerticalVideoAdPlayerView.swift
//  MPScoreboard3
//
//  Created by David Smith on 11/6/23.
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

protocol VerticalVideoAdPlayerViewDelegate: AnyObject
{
    func videoAdFinished()
    func scrollBlockTimerExpired()
}

class VerticalVideoAdPlayerView: UIView, UVPNPlayerViewControllerDelegate, UVPNIMAResourceProviderViewDelegate
{
    weak var delegate: VerticalVideoAdPlayerViewDelegate?
    
    var parentVC: UIViewController!
    
    private var inlinePlayerContainerView: UIView!
    private var adFinishedOnce = false
    
    private var adTimerLabel: UILabel!
    private var adTimerCount = 0
    private var adDuration = 0
    private var tickTimer: Timer!
    private var tickTimerPause = false
    
    private var videoInfo = [:] as Dictionary<String,String>
    private var trackingGuid = ""
    
    private var playlistManager : UVPNPlaylistManager?
    private var playerVC : UVPNPlayerViewController?
    private var embeddedVC : UVPNPlayerViewController?
    private var trackingManager : UVPNVideoTrackingManager?
    private var existingAudioCategory = AVAudioSession.sharedInstance().category
    private var existingAudioMode = AVAudioSession.sharedInstance().mode
    private var existingAudioOptions = AVAudioSession.sharedInstance().categoryOptions
    
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
    
    // MARK: - Avia Player Methods
    
    private func playVideoWithAds()
    {
        //self.removePlayer()
        
        // Add a timer
        //tickTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerExpired), userInfo: nil, repeats: true)
        
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
        
        let streamingUrl = videoInfo["streamingUrl"]
        
        let resourceConfig = UVPNIMAResourceConfiguration()
        resourceConfig.assetURLString = streamingUrl
        
        let freeWheelUrl = MiscHelper.buildFreeWheelURL(pidMode: false, videoInfo: videoInfo)
        
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
            provider.adClickThroController = self.parentVC
            
            playerVC?.showMaximize = false
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
             playerVC?.topRightOrderedControls = [.mute, .airplay, .custom]
             */
            playerVC?.topRightOrderedControls = [.mute]
            
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(adFinished) , name: Notification.Name(kUVPNDidEndPlayingAdSlot), object: playlistManager)
        
        NotificationCenter.default.addObserver(self, selector: #selector(adLoaded(_:)) , name: Notification.Name(kUVPNDidLoadAd), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userPaused) , name: Notification.Name(kUVPNUserPause), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userPlay) , name: Notification.Name(kUVPNUserPlay), object: nil)
        
        // Tracking
        let title = videoInfo["title"] ?? ""
        let duration = videoInfo["duration"] ?? "0"
        let videoIdString = videoInfo["videoId"] ?? ""
        
        let context = TrackingManager.buildVideoContextData(featureName: "shorts", videoId: videoIdString, videoTitle: title, videoDuration: Int(duration)!, isMuted: true, isAutoPlay: MiscHelper.videoAutoplayIsOk(), cData: kEmptyTrackingContextData, trackingGuid: self.trackingGuid, ftag: "")
        
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
        self.playlistManager?.muted = false // Start the video with sound
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
        if let layer = playerVC?.avplayerLayer {
            trackingManager?.playerLayer = layer
        }
    }
    
    @objc func playlistDone()
    {
        self.cleanupVideoPlayer()
        
        self.inlinePlayerContainerView.isHidden = true
        
        self.delegate?.scrollBlockTimerExpired()
    }
    
    @objc func playbackFailed()
    {
        self.cleanupVideoPlayer()
        
        self.inlinePlayerContainerView.isHidden = true
        
        MiscHelper.showAlert(in: self.parentVC, withActionNames: ["OK"], title: "Playback Error", message: "The was a problem playing this video.", lastItemCancelType: false) { tag in
            
        }
        
        self.delegate?.scrollBlockTimerExpired()
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
    
    @objc func userPaused()
    {
        print("Paused")
        tickTimerPause = true
    }
    
    @objc func userPlay()
    {
        print("Play")
        tickTimerPause = false
    }
    
    func pauseAdVideoPlayer()
    {
        self.playlistManager?.pause()
    }
    
    @objc func adFinished()
    {
        if (adFinishedOnce == false)
        {
            adFinishedOnce = true // this prevents multiple calls
            //self.cleanupVideoPlayer()
            self.inlinePlayerContainerView.isHidden = true
            
            self.playlistManager?.resourceCleanupWithCompletion({
                
                self.embeddedVC?.view.removeFromSuperview()
                self.embeddedVC?.removeFromParent()
                self.embeddedVC = nil

                // Reset the audio
                try? AVAudioSession.sharedInstance().setActive(false)

                self.delegate?.videoAdFinished()
            })
        }
    }
    
    @objc func adLoaded(_ note: Notification)
    {
        let snapshot = note.userInfo![kUVPNEventSnapshotKey] as! UVPNSnapshot
        adDuration = Int(snapshot.adModel!.adDuration)
        adTimerLabel.text = String(format: "Ad: (0:%d)", adDuration)
        adTimerCount = adDuration
        
        // Add a timer
        tickTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerExpired), userInfo: nil, repeats: true)
        
        print("Ad Loaded")
    }
    
    // MARK: - Cleanup Video Player
    
    func cleanupVideoPlayer()
    {
        self.playlistManager?.resourceCleanupWithCompletion({
            
            self.embeddedVC?.view.removeFromSuperview()
            self.embeddedVC?.removeFromParent()
            self.embeddedVC = nil

            // Reset the audio
            try? AVAudioSession.sharedInstance().setActive(false)
            
        })
    }
    
    // MARK: - Get Video Info
    
    private func getVideoInfo(videoId: String)
    {
        NewFeeds.getVideoInfo(videoId: videoId) { videoObj, error in
            
            if (error == nil)
            {
                print("Get Video Info Successful")
                
                let videoId = videoObj!["videoId"] as! String
                self.videoInfo.updateValue(videoId, forKey: "videoId")
                
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
                        self.playVideoWithAds()
                        return
                    }
                }
                    
                // Look for the best video to use
                let renditions = videoObj!["renditions"] as! Array<Any>
                
                if (renditions.count == 0)
                {
                    MiscHelper.showAlert(in: self.parentVC, withActionNames: ["OK"], title: "We're Sorry", message: "This video can not be played due to a playback error.", lastItemCancelType: false) { tag in
                        
                    }
                    return
                }
                
                
                for item in renditions
                {
                    let rendition = item as! Dictionary<String,Any>
                    if (externalPartner.lowercased() == "hudl")
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
                                self.videoInfo.updateValue(rendition["assetType"]! as! String, forKey: "assetType")
                                self.videoInfo.updateValue(rendition["deviceType"]! as! String, forKey: "deviceType")
                                break
                            }
                        }
                    }
                }
                
                // This is for all of the other cases tha use streamingUrl
                let streamingUrl = self.videoInfo["streamingUrl"] ?? ""
                if (streamingUrl.count > 0)
                {
                    // Check to make sure it's not a Flash file
                    let url = URL(string: streamingUrl)
                    let fileExtension = url?.pathExtension
                    
                    if (fileExtension?.lowercased() == "flv")
                    {
                        MiscHelper.showAlert(in: self.parentVC, withActionNames: ["OK"], title: "We're Sorry", message: "This video can not be played on an iOS device.", lastItemCancelType: false) { tag in
                            
                        }
                    }
                    else
                    {
                        self.playVideoWithAds()
                    }
                }
                else
                {
                    MiscHelper.showAlert(in: self.parentVC, withActionNames: ["OK"], title: "We're Sorry", message: "This video is not available for your device.", lastItemCancelType: false) { tag in
                        
                    }
                }
            }
            else
            {
                print("Get Video Info Failed")
                
                MiscHelper.showAlert(in: self.parentVC, withActionNames: ["OK"], title: "We're Sorry", message: "This video can not be found.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - Timer Method
    
    @objc private func timerExpired()
    {
        if (tickTimerPause == true)
        {
            return
        }
        
        adTimerCount -= 1
        
        if (adTimerCount == adDuration - 5)
        {
            tickTimer.invalidate()
            tickTimer = nil
            adTimerLabel.text = "Swipe to next video"
            self.delegate?.scrollBlockTimerExpired()
        }
        else
        {
            adTimerLabel.text = String(format: "Ad: (0:%d)", adTimerCount)
        }
    }
    
    // MARK: - App Entered Background Notification
    
    @objc private func applicationDidEnterBackground()
    {
        self.cleanupVideoPlayer()
    }
    
    // MARK: - Init Method
    
    init(frame: CGRect, videoId: String, titleText: String)
    {
        super.init(frame: frame)
        
        trackingGuid = NSUUID().uuidString
        
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.9)
        
        let upNextLabel = UILabel(frame: CGRect(x: 16.0, y: frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight) - 94.0, width: 60.0, height: 24.0))
        upNextLabel.backgroundColor = UIColor.mpRedColor()
        upNextLabel.layer.cornerRadius = 6
        upNextLabel.clipsToBounds = true
        upNextLabel.font = UIFont.mpBoldFontWith(size: 12)
        upNextLabel.textColor = .white
        upNextLabel.textAlignment = .center
        upNextLabel.text = "Up Next"
        self.addSubview(upNextLabel)
        
        adTimerLabel = UILabel(frame: CGRect(x: frame.size.width - 224.0, y: frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight) - 94.0, width: 200.0, height: 24.0))
        adTimerLabel.textColor = .white
        adTimerLabel.font = UIFont.mpBoldFontWith(size: 14)
        adTimerLabel.textAlignment = .right
        //adTimerLabel.text = String(format: "Ad: (0:0%d)", adTimerCount)
        self.addSubview(adTimerLabel)
        
        let titleLabel = UILabel(frame: CGRect(x: 16.0, y: frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight) - 60.0, width: frame.size.width - 32.0, height: 40.0))
        titleLabel.textColor = .white
        titleLabel.font = UIFont.mpBoldFontWith(size: 16)
        titleLabel.numberOfLines = 2
        //titleLabel.text = titleText
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.8
        titleLabel.attributedText = NSMutableAttributedString(string: titleText, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        self.addSubview(titleLabel)
        
        let videoHeight = ((frame.size.width * 9) / 16)
        inlinePlayerContainerView = UIView(frame: CGRect(x: 0, y: (frame.size.height / 2.0) - (videoHeight / 2.0), width: frame.size.width, height: videoHeight))
        inlinePlayerContainerView.backgroundColor = .black
        self.addSubview(inlinePlayerContainerView)
        
        // Add an observer for the app going into the background
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        self.getVideoInfo(videoId: videoId)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    deinit
    {
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kUVPNDidFinishPlaylistPlayback), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kUVPNPlaybackFailed), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kUVPNPlaylistMuted), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kUVPNPlaylistUnmuted), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kUVPNDidEndPlayingAdSlot), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kUVPNDidStartPlayingContent), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kUVPNUserPause), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(kUVPNUserPlay), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
}

