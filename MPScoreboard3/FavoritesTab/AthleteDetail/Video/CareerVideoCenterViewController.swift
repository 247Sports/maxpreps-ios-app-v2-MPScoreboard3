//
//  CareerVideoCenterViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 9/28/22.
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
import PhotosUI

class CareerVideoCenterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UVPNPlayerViewControllerDelegate, UVPNIMAResourceProviderViewDelegate, CareerVideoDarkCareerListViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, TeamVideoExtrasSelectorViewDelegate, CareerVideoToolTipDelegate
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
    @IBOutlet weak var titleContainerDateLabel: UILabel!
    @IBOutlet weak var titleContainerDescriptionLabel: UILabel!
    @IBOutlet weak var videoTableView: UITableView!
    @IBOutlet weak var uploadVideoButton: UIButton!
    @IBOutlet weak var noVideoOverlayView: UIView!
    @IBOutlet weak var noVideoImageView: UIImageView!
    @IBOutlet weak var noVideoTitleLabel: UILabel!
    @IBOutlet weak var noVideoMessageLabel: UILabel!
    @IBOutlet weak var noVideoPostButton: UIButton!
    
    private var videosArray = [] as! Array<Dictionary<String,Any>>
    private var selectedIndex = 0
    private var progressOverlay: ProgressHUD!
  
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
    
    private var videoPicker : UIImagePickerController?
    private var kMaxVideoUploadSize = 100000000 // 1000MB
    
    private var headerView: TeamVideoCenterHeaderViewCell!
    private var currentSortOrder = 0
    
    var trackingContextData = [:] as Dictionary<String,Any>
    var trackingKey = ""
    var selectedAthlete : Athlete?
    var profileIsMineToEdit = false
    var autoOpenUpload = false
    
    private var careerVideoDarkCareerListView: CareerVideoDarkCareerListView!
    private var extrasSelectorView: TeamVideoExtrasSelectorView!
    private var miniAthleteDetailVC: MiniAthleteDetailViewController!
    private var careerVideoUploadVC: CareerVideoUploadViewController!
    private var careerVideoToolTipVC: CareerVideoToolTipViewController!
    private var reportVideoVC: ReportVideoViewController!
    private var webVC: WebViewController!

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
        print("Get Video Info")
        
        NewFeeds.getVideoInfo(videoId: videoIdString) { videoObj, error in
                        
            // Show the upload button after a bit of delay so the video player can start up
            let userId = kUserDefaults.string(forKey: kUserIdKey)
            if (userId != kTestDriveUserId)
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
                {
                    let userIsAdmin = MiscHelper.isUserAnAdmin(schoolId: kEmptyGuid, allSeasonId: kEmptyGuid)
                    if ((self.profileIsMineToEdit == true) || (userIsAdmin == true))
                    {
                        self.uploadVideoButton.isHidden = false
                        
                        // Auto open the upload if enabled
                        if (self.autoOpenUpload == true)
                        {
                            self.stopVideo()
                            self.getPhotoLibraryPermission()
                        }
                        
                        // Show the tool tip if it hasn't been shown before
                        if (kUserDefaults.bool(forKey: kCareerVideoToolTipShownKey) == false)
                        {
                            self.showVideoToolTip()
                        }
                    }
                }
            }
            
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
                        if let streamingUrl = rendition["streamingUrl"] as? String
                        {
                            if (streamingUrl.contains("_0.m3u8") == true)
                            {
                                continue
                            }
                        }
                        
                        // Look for the HLS or HLS_VARIANT_PHONE versions
                        if ((rendition["assetType"] as! String == "HLS_VARIANT_PHONE") || (rendition["assetType"] as! String == "HLS"))
                        {
                            // Break if the preferred case is found
                            //if (rendition["pid"] != nil)
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
                            //if (rendition["pid"] != nil)
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
                */
                //else
                //{
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
        /// Enable audio on muted device
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
        if let selectedCell = videoTableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as? TeamVideoCenterTableViewCell
        {
            selectedCell.loadNowPlaying("Paused")
        }
        
    }
    
    func playerViewControllerUserDidResume(pvc: UVPNPlayerViewController)
    {
        // Find the active cell
        if let selectedCell = videoTableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as? TeamVideoCenterTableViewCell
        {
            selectedCell.loadNowPlaying("Now Playing")
        }
    }
    
    @objc func playlistDone()
    {
        // Retain the muted state
        isMuted = (self.playlistManager?.muted)!
        
        // Find the active cell
        if let selectedCell = videoTableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as? TeamVideoCenterTableViewCell
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
        
        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Playback Error", message: "The was a problem playing this video.", lastItemCancelType: false) { tag in
            
        }
        
        // Find the active cell
        if let selectedCell = videoTableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as? TeamVideoCenterTableViewCell
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
        if let selectedCell = videoTableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as? TeamVideoCenterTableViewCell
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
            self.isMaximized = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05)
            {
                self.playerVC?.minMaxEmbeddedPlayer()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05)
                {
                    self.playlistManager?.resume()
                }
            }
        }
    }
    
    func minimizeVideoPlayer()
    {
        if (isMaximized == true)
        {
            self.playlistManager?.pause()
            self.isMaximized = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05)
            {
                self.playerVC?.minMaxEmbeddedPlayer()
            
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05)
                {
                    self.playlistManager?.resume()
                }
            }
        }
    }
    
    // MARK: - Get Career Videos
    
    private func getCareerVideos(sortOrder: Int)
    {
        noVideoTitleLabel.isHidden = true
        noVideoMessageLabel.isHidden = true
        noVideoPostButton.isHidden = true
        noVideoOverlayView.isHidden = false
        
        var sortModeQueryParameter = ""
        switch sortOrder
        {
        case 0:
            sortModeQueryParameter = "MostRecent"
        case 1:
            sortModeQueryParameter = "MostPopular"
        default:
            sortModeQueryParameter = "Oldest"
        }
        
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        let careerId = self.selectedAthlete!.careerId
        
        CareerFeeds.getCareerVideos(careerId, pageNumber: 1, maxItems: 60, sort:sortModeQueryParameter) { [self] (result, error) in
            
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                //MBProgressHUD.hide(for: self, animated: true)
                if (self.progressOverlay != nil)
                {
                    self.progressOverlay.hide(animated: false)
                    self.progressOverlay = nil
                }
            }
            
            if (error == nil)
            {
                print("Get Career Videos Success")
                
                self.videoTableView.isHidden = false
                
                let resultArray = result!["videos"] as! Array<Dictionary<String,Any>>
                
                if (resultArray.count > 0)
                {
                    self.videosArray = resultArray
                    self.loadHeader()
                    self.noVideoOverlayView.isHidden = true
                }
                else
                {
                    self.noVideoTitleLabel.isHidden = false
                    self.noVideoMessageLabel.isHidden = false
                    self.noVideoPostButton.isHidden = false
                    
                    // Show the video button and show the black overlay
                    let userIsAdmin = MiscHelper.isUserAnAdmin(schoolId: kEmptyGuid, allSeasonId: kEmptyGuid)
                    if ((self.profileIsMineToEdit == true) || (userIsAdmin == true))
                    {
                        self.uploadVideoButton.isHidden = false
                        
                        // Auto open the upload if enabled
                        if (self.autoOpenUpload == true)
                        {
                            self.stopVideo()
                            self.getPhotoLibraryPermission()
                        }
                        
                        // Show the tool tip if it hasn't been shown before
                        if (kUserDefaults.bool(forKey: kCareerVideoToolTipShownKey) == false)
                        {
                            self.showVideoToolTip()
                        }
                    }
                    
                    let userId = kUserDefaults.string(forKey: kUserIdKey)
                    if (userId == kTestDriveUserId)
                    {
                        self.noVideoPostButton.isHidden = true
                    }
                }
                
                /*
                for video in self.videosArray
                {
                    let videoId = video["videoId"] as! String
                    print(videoId)
                    
                    let renditions = video["renditions"] as! Array<Any>
                    
                    if (renditions.count == 0)
                    {
                        print("No rendition")
                    }
                }
                */
                self.videoTableView.reloadData()
            }
            else
            {
                print("Get Career Videos Failed")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "There was a problem getting the videos from the server.", lastItemCancelType: false) { (tag) in
                    
                }
            }
        }
    }
    
    // MARK: - Show Web View Controller
    
    private func showWebViewController()
    {
        webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC.titleString = "Support"
        webVC.urlString = "https://support.maxpreps.com/hc/en-us/requests/new?ticket_form_id=360003897614"
        webVC.titleColor = UIColor.mpBlackColor()
        webVC.navColor = UIColor.mpWhiteColor()
        webVC.allowRotation = false
        webVC.showShareButton = false
        webVC.showScrollIndicators = true
        webVC.showLoadingOverlay = true
        webVC.showBannerAd = false
        webVC.adId = ""
        webVC.tabBarVisible = true
        webVC.enableAdobeQueryParameter = false
        webVC.trackingContextData = kEmptyTrackingContextData
        webVC.trackingKey = ""
        
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    // MARK: - Image Picker Methods
    
    private func getPhotoLibraryPermission()
    {
        if (UIImagePickerController.isSourceTypeAvailable(.photoLibrary))
        {
            let authStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            
            if (authStatus == .authorized)
            {
                self.showVideoPicker()
            }
            else if (authStatus == .notDetermined)
            {
                // Requst access
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { [unowned self] (status) in
                    
                    if (status == .authorized)
                    {
                        DispatchQueue.main.async
                        {
                            self.showVideoPicker()
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async
                        {
                            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This app does not have access to the video library.\nYou can enable access in the device's Privacy Settings.", lastItemCancelType: false) { (tag) in
                                
                            }
                        }
                    }
                }
            }
            else if (authStatus == .restricted)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "You've been restricted from opening the video library on this device. Please contact the device owner so they can give you access.", lastItemCancelType: false) { (tag) in
                    
                }
            }
            else
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This app does not have access to the video library.\nYou can enable access in the device's Privacy Settings.", lastItemCancelType: false) { (tag) in
                    
                }
            }
        }
        else
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "The video library is not available on this device.", lastItemCancelType: false) { (tag) in
                
            }
        }
    }
    
    private func showVideoPicker()
    {
        videoPicker = UIImagePickerController()
        videoPicker?.delegate = self
        videoPicker?.allowsEditing = true
        videoPicker?.sourceType = .photoLibrary
        videoPicker?.mediaTypes = ["public.movie"]
        videoPicker?.modalPresentationStyle = .fullScreen
        self.present(videoPicker!, animated: true)
        {
            
        }
    }
    
    // MARK: - Image Picker Delegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL
        let imageData = NSData(contentsOf: videoUrl!)
        print(imageData!.length)
        
        if (imageData!.length > kMaxVideoUploadSize)
        {
            self.dismiss(animated: true, completion:{
                
                self.videoPicker = nil
                
                let videoSize = imageData!.length / 1000000 as Int
                let maxSize = self.kMaxVideoUploadSize / 1000000 as Int
                let message = String(format: "This video is %d MB. The size cannot exceed %d MB.", videoSize, maxSize)
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: message, lastItemCancelType: false) { tag in
                    
                }
            })
        }
        else
        {
            self.dismiss(animated: true, completion:{
                
                self.videoPicker = nil
                
                self.careerVideoUploadVC = CareerVideoUploadViewController(nibName: "CareerVideoUploadViewController", bundle: nil)
                self.careerVideoUploadVC.videoUrl = videoUrl
                self.careerVideoUploadVC.selectedAthlete = self.selectedAthlete
                
                let careerUploadNav = TopNavigationController()
                careerUploadNav.viewControllers = [self.careerVideoUploadVC]
                careerUploadNav.modalPresentationStyle = .fullScreen
                
                self.present(careerUploadNav, animated: true)
                
                // Tracking
                let firstName = self.selectedAthlete!.firstName
                let lastName = self.selectedAthlete!.lastName
                let fullName = firstName + " " + lastName
                let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:self.selectedAthlete!.careerId]
                            
                TrackingManager.trackState(featureName: "career-video-details", trackingGuid: self.trackingGuid, cData: cData as Dictionary<String, Any>)
            })
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion:{
 
            self.videoPicker = nil
        })
    }
    
    // MARK: - Career Video Career List View Delegates

    func closeCareerVideoDarkCareerListView()
    {
        careerVideoDarkCareerListView.removeFromSuperview()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func careerVideoDarkCareerListViewAthleteSelected(taggedAthlete: AthleteWithProfile)
    {
        //let message = String(format: "Sports: %@\nGrade: %@\nBio: %@\nFacebook: %@\nTwitter: %@", taggedAthlete.sportsPlayedString, taggedAthlete.gradeClass, taggedAthlete.bio, taggedAthlete.facebookProfile, taggedAthlete.twitterHandle)
        
        //MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Player Info", message: message, lastItemCancelType: false) { tag in
            
        //}
        
        miniAthleteDetailVC = MiniAthleteDetailViewController(nibName: "MiniAthleteDetailViewController", bundle: nil)
        miniAthleteDetailVC.taggedAthlete = taggedAthlete
        
        // Check to see if the athlete is already a favorite
        let isFavorite = MiscHelper.isAthleteMyFavoriteAthlete(careerId: taggedAthlete.careerId)
        
        var showSaveFavoriteButton = false
        var showRemoveFavoriteButton = false
        
        if (isFavorite == true)
        {
            showSaveFavoriteButton = false
            showRemoveFavoriteButton = true
        }
        else
        {
            showSaveFavoriteButton = true
            showRemoveFavoriteButton = false
        }
        
        miniAthleteDetailVC.showSaveFavoriteButton = showSaveFavoriteButton
        miniAthleteDetailVC.showRemoveFavoriteButton = showRemoveFavoriteButton
        
        let navController = TopNavigationController(rootViewController: miniAthleteDetailVC)
        navController.modalPresentationStyle = .overCurrentContext
        self.present(navController, animated: true)
        
    }
    
    func careerVideoDarkCareerListViewAthleteUntagged()
    {
        careerVideoDarkCareerListView.removeFromSuperview()
        self.tabBarController?.tabBar.isHidden = false
        
        self.stopVideo()
        
        selectedIndex = 0
        self.scrollToSelectedIndex()
        
        // Get the video list again
        self.getCareerVideos(sortOrder: 0)
    }
    
    // MARK: - TeamVideoExtrasSelectorViewDelegate
    
    func teamVideoExtrasSelectorViewDidSelectItem(index: Int)
    {
        extrasSelectorView.removeFromSuperview()
        extrasSelectorView = nil
        
        //self.stopVideo()
        self.playlistManager?.pause()
        
        switch index
        {
        case 0:
            let video = videosArray[selectedIndex]
            let videoUrlString = video["canonicalUrl"] as? String ?? ""
            
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
        case 1:
            
            let video = videosArray[selectedIndex]
            let isUserUploaded = video["isUserUploaded"] as! Bool
            
            // Show a dialog if the video can't be reporteed through the app
            if (isUserUploaded == true)
            {
                let videoId = video["videoId"] as! String
                
                reportVideoVC = ReportVideoViewController(nibName: "ReportVideoViewController", bundle: nil)
                reportVideoVC.videoId = videoId
                reportVideoVC.modalPresentationStyle = .overFullScreen
                self.present(reportVideoVC, animated: true)
            }
            else
            {
                MiscHelper.showAlert(in: self, withActionNames: ["Support", "Cancel"], title: "Report Video", message: "Contact MaxPreps support to report this video.", lastItemCancelType: false) { tag in
                    
                    if (tag == 0)
                    {
                        self.showWebViewController()
                    }
                }
            }

        default:
            return
        }
    }
    
    func teamVideoExtrasSelectorViewDidCancel()
    {
        extrasSelectorView.removeFromSuperview()
        extrasSelectorView = nil
    }
    
    // MARK: - CareerVideoToolTip Delegate
    
    func careerVideoToolTipDidCancel()
    {
        if (careerVideoToolTipVC != nil)
        {
            careerVideoToolTipVC.view .removeFromSuperview()
            careerVideoToolTipVC = nil
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
        return 102
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return headerView.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let view = UIView()
        view.addSubview(headerView)
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "TeamVideoCenterTableViewCell") as?TeamVideoCenterTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("TeamVideoCenterTableViewCell", owner: self, options: nil)
            cell = nib![0] as? TeamVideoCenterTableViewCell
        }
        cell?.selectionStyle = .none
        //cell?.horizLine.isHidden = false
        
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
        
        //if ((indexPath.row) == (videosArray.count - 1))
        //{
            //cell?.horizLine.isHidden = true
        //}
        
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
        let description = video["description"] as! String
        let time = video["durationString"] as! String
        let publishDate = video["formattedPublishedOn"] as! String
        let viewCount = video["viewCount"] as? Int ?? 0
        
        titleContainerTitleLabel.text = title
        titleContainerDescriptionLabel.text = description
        timeLabel.text = time
        
        if (viewCount > 0)
        {
            if (viewCount >= 1000000)
            {
                let viewCountFloat = Float(viewCount) / 1000000.0
                titleContainerDateLabel.text = String(format: "%@ • %1.1fm views", publishDate, viewCountFloat)
            }
            else
            {
                if (viewCount >= 1000)
                {
                    let viewCountFloat = Float(viewCount) / 1000.0
                    titleContainerDateLabel.text = String(format: "%@ • %1.1fk views", publishDate, viewCountFloat)
                }
                else
                {
                    titleContainerDateLabel.text = String(format: "%@ • %d views", publishDate, viewCount)
                }
            }
        }
        else
        {
            titleContainerDateLabel.text = publishDate
        }
        
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
        
        // Start up the video player if it's allowed.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25)
        {
            if (MiscHelper.videoAutoplayIsOk() == true)
            {
                self.getVideoInfo()
            }
            else
            {
                let userIsAdmin = MiscHelper.isUserAnAdmin(schoolId: kEmptyGuid, allSeasonId: kEmptyGuid)
                if ((self.profileIsMineToEdit == true) || (userIsAdmin == true))
                {
                    self.uploadVideoButton.isHidden = false
                    
                    // Auto open the upload if enabled
                    if (self.autoOpenUpload == true)
                    {
                        self.stopVideo()
                        self.getPhotoLibraryPermission()
                    }
                    
                    // Show the tool tip if it hasn't been shown before
                    if (kUserDefaults.bool(forKey: kCareerVideoToolTipShownKey) == false)
                    {
                        self.showVideoToolTip()
                    }
                }
            }
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
        if let selectedCell = videoTableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as? TeamVideoCenterTableViewCell
        {
            selectedCell.loadNowPlaying("Now Playing")
        }
    }
    
    @IBAction func extrasButtonTouched()
    {
        let buttonFrame = CGRect(x: kDeviceWidth - 50.0, y: titleContainerView.frame.origin.y + 96.0, width: 38.0, height: 28.0)
        
        extrasSelectorView = TeamVideoExtrasSelectorView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight), buttonFrame: buttonFrame)
        extrasSelectorView.delegate = self
        
        self.view.addSubview(extrasSelectorView)
    }
    
    @IBAction func moreButtonTouched()
    {
        let video = videosArray[selectedIndex]
        let careerIdReferences = video["careerIdReferences"] as! Array<String>
        
        for careerId in careerIdReferences
        {
            print("CareerId: " + careerId)
        }
        
        //headerView.stopVideo()
        
        self.tabBarController?.tabBar.isHidden = true
        
        careerVideoDarkCareerListView = CareerVideoDarkCareerListView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight))
        careerVideoDarkCareerListView.delegate = self
        careerVideoDarkCareerListView.loadData(videoObj: video)
        self.view.addSubview(careerVideoDarkCareerListView)
    }
    
    @IBAction func uploadVideoButtonTouched()
    {
        self.stopVideo()
        
        self.getPhotoLibraryPermission()
    }
    
    // MARK: - Sort Menu Methods
    
    private var menuItems: [UIAction]
    {
        /*
        return [
            UIAction(title: "Oldest", image: UIImage(systemName: "trash"), handler: { (_) in
            }),
            UIAction(title: "Most Popular", image: UIImage(systemName: "moon"), handler: { (_) in
            }),
            UIAction(title: "Most Recent", image: UIImage(systemName: "sun.max"), handler: { (_) in
            })
        ]
        */
        return [
            UIAction(title: "Oldest", image: nil, handler: { (_) in
                print("Oldest Touched")
                
                if (self.currentSortOrder != 2)
                {
                    self.currentSortOrder = 2
                    self.headerView.sortLabel.text = "Sort by Oldest"
                    self.getCareerVideos(sortOrder: 2)
                }
            }),
            UIAction(title: "Most Popular", image: nil, handler: { (_) in
                print("Most Popular Touched")
                
                if (self.currentSortOrder != 1)
                {
                    self.currentSortOrder = 1
                    self.headerView.sortLabel.text = "Sort by Most Popular"
                    self.getCareerVideos(sortOrder: 1)
                }
            }),
            UIAction(title: "Most Recent", image: nil, handler: { (_) in
                print("Most Recent Touched")
                
                if (self.currentSortOrder != 0)
                {
                    self.currentSortOrder = 0
                    self.headerView.sortLabel.text = "Sort by Most Recent"
                    self.getCareerVideos(sortOrder: 0)
                }
            })
        ]
    }

    private var sortMenu: UIMenu
    {
        return UIMenu(title: "Sort Videos By", image: nil, identifier: nil, options: [], children: menuItems)
    }
    
    // MARK: - Video ToolTip Method
    
    private func showVideoToolTip()
    {
        // Adding this VC as a subview
        careerVideoToolTipVC = CareerVideoToolTipViewController(nibName: "CareerVideoToolTipViewController", bundle: nil)
        careerVideoToolTipVC.view.frame = CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight)
        careerVideoToolTipVC.delegate = self
        self.view.addSubview(careerVideoToolTipVC.view)
        //careerVideoToolTipVC.modalPresentationStyle = .overFullScreen
        //self.present(careerVideoToolTipVC, animated: false)
    }
    
    // MARK: - Tab Bar Changed Notification
    
    @objc private func tabBarChanged()
    {
        self.stopVideo()
    }
    
    // MARK: - Orientation Changed Method
    
    @objc private func orientationChanged()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
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
        timeLabel.frame = CGRect(x: 8, y: navView.frame.origin.y + navView.frame.size.height + videoHeight - 28, width: timeLabel.frame.size.width, height: timeLabel.frame.size.height)
        playIconBackgroundView.center = thumbnailImageView.center
        videoPlayButton.center = thumbnailImageView.center
        
        timeLabel.layer.cornerRadius = 6
        timeLabel.clipsToBounds = true
        
        titleContainerView.frame = CGRect(x: 0, y: inlinePlayerContainerView.frame.origin.y + inlinePlayerContainerView.frame.size.height, width: kDeviceWidth, height: titleContainerView.frame.size.height)
        
        videoTableView.frame = CGRect(x: 0, y: titleContainerView.frame.origin.y + titleContainerView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - titleContainerView.frame.origin.y - titleContainerView.frame.size.height - CGFloat(kTabBarHeight) - CGFloat(SharedData.bottomSafeAreaHeight))
        
        noVideoOverlayView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height - CGFloat(kTabBarHeight) - CGFloat(SharedData.bottomSafeAreaHeight))
        noVideoOverlayView.isHidden = true
        
        playIconBackgroundView.layer.cornerRadius = playIconBackgroundView.frame.size.width / 2.0
        playIconBackgroundView.clipsToBounds = true
        
        // Instantiate the header view
        let headerNib = Bundle.main.loadNibNamed("TeamVideoCenterHeaderViewCell", owner: self, options: nil)
        headerView = headerNib![0] as? TeamVideoCenterHeaderViewCell
        headerView.frame = CGRect(x: 0, y: 0, width: kDeviceWidth, height: 76)
        headerView.sortButton.menu = sortMenu
        headerView.sortButton.showsMenuAsPrimaryAction = true
        headerView.sortLabel.text = "Sort by Most Recent"
        
        let hexColorString = self.selectedAthlete?.schoolColor
        let currentTeamColor = ColorHelper.color(fromHexString: hexColorString, colorCorrection: true)!
        navView.backgroundColor = currentTeamColor
        fakeStatusBar.backgroundColor = currentTeamColor
        
        thumbnailImageView.image = nil
        
        if (SharedData.deviceAspectRatio as! AspectRatio == AspectRatio.high)
        {
            noVideoImageView.image = UIImage(named: "EmptyCareerVideoHigh")
        }
        else
        {
            noVideoImageView.image = UIImage(named: "EmptyCareerVideoMedium")
        }
        
        noVideoMessageLabel.text = String(format: "There aren't any videos yet for %@ %@.", selectedAthlete!.firstName, selectedAthlete!.lastName)
        
        noVideoPostButton.layer.cornerRadius = 8
        noVideoPostButton.layer.borderWidth = 1
        noVideoPostButton.layer.borderColor = UIColor.mpOffWhiteNavColor().cgColor
        noVideoPostButton.clipsToBounds = true
        
        self.getCareerVideos(sortOrder: 0)
        
        // Scroll to the active index
        self.scrollToSelectedIndex()
        
        // Add a notification handler that the tab bar changed
        NotificationCenter.default.addObserver(self, selector: #selector(tabBarChanged), name: Notification.Name("TabBarChanged"), object: nil)
        
        // Hide the upload button until the careerVideos have been downloaded
        uploadVideoButton.isHidden = true
        
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
        kAppKeyWindow.rootViewController!.view.backgroundColor = UIColor.mpBlackColor()
        
        setNeedsStatusBarAppearanceUpdate()
        
        // Load the tab bar icons and text color
        let tabBarItem0 = self.tabBarController!.tabBar.items![0]
        let tabBarItem1 = self.tabBarController!.tabBar.items![1]
        let tabBarItem2 = self.tabBarController!.tabBar.items![2]
        
        let unselectedImage0 = UIImage(named: "LatestIconWhite")
        let selectedImage0 = UIImage(named: "LatestIconSelectedWhite")
        let unselectedImage1 = UIImage(named: "FollowingIconWhite")
        let selectedImage1 = UIImage(named: "FollowingIconSelectedWhite")
        let unselectedImage2 = UIImage(named: "ScoresIconWhite")
        let selectedImage2 = UIImage(named: "ScoresIconSelectedWhite")
        
        tabBarItem0.image = unselectedImage0!.withRenderingMode(.alwaysOriginal)
        tabBarItem0.selectedImage = selectedImage0!.withRenderingMode(.alwaysOriginal)
        
        tabBarItem1.image = unselectedImage1!.withRenderingMode(.alwaysOriginal)
        tabBarItem1.selectedImage = selectedImage1!.withRenderingMode(.alwaysOriginal)
        
        tabBarItem2.image = unselectedImage2!.withRenderingMode(.alwaysOriginal)
        tabBarItem2.selectedImage = selectedImage2!.withRenderingMode(.alwaysOriginal)
        
        // Change the tab bar to a black background
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.mpBlackColor()
        
        let selectedAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.mpBoldFontWith(size: 12), NSAttributedString.Key.foregroundColor: UIColor.mpWhiteColor(), NSAttributedString.Key.paragraphStyle: NSParagraphStyle.default]
        
        let normalAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 12), NSAttributedString.Key.foregroundColor: UIColor.mpLighterGrayColor(), NSAttributedString.Key.paragraphStyle: NSParagraphStyle.default]
        
        appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        
        appearance.inlineLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
                
        self.tabBarController?.tabBar.standardAppearance = appearance
        
        if #available(iOS 15.0, *)
        {
            self.tabBarController?.tabBar.scrollEdgeAppearance = appearance
        }
        
        /*
        if (athleteDetailVC != nil)
        {
            // This is added to enable the tabbar buttons when returning from the VCs
            let tabBarControllerItems = self.tabBarController?.tabBar.items

            if let tabArray = tabBarControllerItems
            {
                let tabBarItem1 = tabArray[0]
                let tabBarItem2 = tabArray[1]
                let tabBarItem3 = tabArray[2]

                tabBarItem1.isEnabled = true
                tabBarItem2.isEnabled = true
                tabBarItem3.isEnabled = true
            }
        }
        */
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (miniAthleteDetailVC != nil)
        {
            miniAthleteDetailVC = nil
        }
        
        if (careerVideoUploadVC != nil)
        {
            careerVideoUploadVC = nil
        }
        
        /*
        if (careerVideoToolTipVC != nil)
        {
            careerVideoToolTipVC = nil
        }
        */
        if (reportVideoVC != nil)
        {
            reportVideoVC = nil
        }
        
        if (webVC != nil)
        {
            webVC = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        // Load the tab bar icons and text color
        let tabBarItem0 = self.tabBarController!.tabBar.items![0]
        let tabBarItem1 = self.tabBarController!.tabBar.items![1]
        let tabBarItem2 = self.tabBarController!.tabBar.items![2]
        
        let unselectedImage0 = UIImage(named: "LatestIcon")
        let selectedImage0 = UIImage(named: "LatestIconSelected")
        let unselectedImage1 = UIImage(named: "FollowingIcon")
        let selectedImage1 = UIImage(named: "FollowingIconSelected")
        let unselectedImage2 = UIImage(named: "ScoresIcon")
        let selectedImage2 = UIImage(named: "ScoresIconSelected")
        
        tabBarItem0.image = unselectedImage0!.withRenderingMode(.alwaysOriginal)
        tabBarItem0.selectedImage = selectedImage0!.withRenderingMode(.alwaysOriginal)
        
        tabBarItem1.image = unselectedImage1!.withRenderingMode(.alwaysOriginal)
        tabBarItem1.selectedImage = selectedImage1!.withRenderingMode(.alwaysOriginal)
        
        tabBarItem2.image = unselectedImage2!.withRenderingMode(.alwaysOriginal)
        tabBarItem2.selectedImage = selectedImage2!.withRenderingMode(.alwaysOriginal)
        
        // Change the tab bar to a off white background
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.mpOffWhiteNavColor()
        
        let selectedAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.mpBoldFontWith(size: 12), NSAttributedString.Key.foregroundColor: UIColor.mpBlackColor(), NSAttributedString.Key.paragraphStyle: NSParagraphStyle.default]
        
        let normalAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 12), NSAttributedString.Key.foregroundColor: UIColor.mpDarkGrayColor(), NSAttributedString.Key.paragraphStyle: NSParagraphStyle.default]
        
        appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        
        appearance.inlineLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
                
        self.tabBarController?.tabBar.standardAppearance = appearance
        
        if #available(iOS 15.0, *)
        {
            self.tabBarController?.tabBar.scrollEdgeAppearance = appearance
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
        
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("TabBarChanged"), object: nil)
    }
}
