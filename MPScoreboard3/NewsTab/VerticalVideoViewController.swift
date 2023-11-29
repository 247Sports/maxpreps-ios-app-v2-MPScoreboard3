//
//  VerticalVideoViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/31/23.
//

import UIKit
import AVKit
import AVFoundation
import AppTrackingTransparency
//import Avia
//import AviaTrackingCore
//import AviaTrackingComscore
//import AviaTrackingNielsen

class VerticalVideoViewController: UIViewController, UIScrollViewDelegate, VerticalVideoTitleOverlayViewDelegate, VerticalVideoAdPlayerViewDelegate
{
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var containerScrollView: UIScrollView!
    
    var initialVideoIndex = 0
    var videoShortsArray: Array<Dictionary<String,Any>> = []
    
    private var currentVideoIndex = 0
    private var deceleratingContentOffset = 0.0
    
    private var titleOverlayView: VerticalVideoTitleOverlayView!
    private var kTitleOverlayTransformHeight = 130.0 // 230.0
    
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    private var timeObserver: Any!
    private var progressIndicatorView: UIProgressView!
    private var playImageView: UIImageView!
    private let kPortraitVideoPlayMaxCount = 3
    private var bumpScreenCount = 0
    private var bumpScreenShownAlready = false
    
    private var videoAdView: VerticalVideoAdPlayerView!
    private var videoAdVisible = false
    private var getVideoInfoBusy = false
    private var blockPlayerStarts = false
    
    //private var playlistManager : UVPNPlaylistManager?
    //private var trackingManager : UVPNVideoTrackingManager?
    //private var playerVC : UVPNPlayerViewController?
    private var trackingGuid = ""
    
    /*
    private func trackVideo()
    {
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
        
        self.playlistManager?.resourceCleanupWithCompletion(nil)
        
        let playlistManager = UVPNPlaylistManager()
        
        // Tracking
        let videoShort = videoShortsArray[currentVideoIndex]
        let title = videoShort["title"] as? String ?? ""
        let duration = videoShort["duration"] as? String ?? "0"
        let videoIdString = videoShort["videoId"] as? String ?? ""
        
        let context = TrackingManager.buildVideoContextData(featureName: "shorts", videoId: videoIdString, videoTitle: title, videoDuration: Int(duration)!, isMuted: false, isAutoPlay: true, cData: kEmptyTrackingContextData, trackingGuid: trackingGuid, ftag: "")
        
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
            playerVC.playResourceProvider(, with: playlistManager)
        }
        self.playlistManager = playlistManager
    }
    */
    
    // MARK: - Portrait Video Player Methods
    
    private func playPortraitVideo(videoUrlString: String)
    {
        if (blockPlayerStarts == true)
        {
            return
        }
        
        self.removePortraitPlayer()
        self.removeVideoAdPlayer()
        
        let videoURL = URL(string: videoUrlString)
        if (videoURL == nil)
        {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
        {
            //let videoURL = URL(string: "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_5MB.mp4")
            
            self.player = AVPlayer(url: videoURL!)
            
            // Add various notifications
            NotificationCenter.default.addObserver(self, selector: #selector(self.portraitPlayerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
            
            // Add a player layer
            self.playerLayer = AVPlayerLayer(player: self.player)
            self.playerLayer.backgroundColor = UIColor.clear.cgColor
            
            let activeFrame = CGRect(x: 0, y: (CGFloat(self.currentVideoIndex) * kDeviceHeight) + kDeviceHeight, width: kDeviceWidth, height: kDeviceHeight)
            self.playerLayer.frame = activeFrame
            self.playerLayer.videoGravity = .resizeAspectFill
            self.containerScrollView.layer.addSublayer(self.playerLayer)
            
            self.progressIndicatorView.progress = 0.0
            self.progressIndicatorView.isHidden = false
            
            // Add the playImageView
            self.playImageView = UIImageView(frame: CGRect(x: (kDeviceWidth / 2.0) - 36.0, y: (CGFloat(self.currentVideoIndex) * kDeviceHeight) + kDeviceHeight + (kDeviceHeight / 2.0) - 36.0, width: 72.0, height: 72.0))
            self.playImageView.image = UIImage(named: "VideoPlayIconShorts")
            self.containerScrollView.addSubview(self.playImageView)
            self.playImageView.isHidden = true
            
            // Add the progress indicator observer
            self.timeObserver = self.player.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 30), queue: .main, using: { time in
                if let playerDuration = self.player.currentItem?.duration
                {
                    let duration = CMTimeGetSeconds(playerDuration), time = CMTimeGetSeconds(time)
                    let progress = (time/duration)
                    //print(progress)
                    
                    if (duration > 0) // This handles the divide by zero problem
                    {
                        self.progressIndicatorView.progress = Float(progress)
                    }
                }
            })
            
            self.player.play()
        }
        
    }
    
    private func removePortraitPlayer()
    {
        if (player != nil)
        {
            player.pause()
            player.removeTimeObserver(self.timeObserver as Any)
            player = nil
            
            // Remove the notifications
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        }
        
        if (playerLayer != nil)
        {
            playerLayer.removeFromSuperlayer()
            playerLayer = nil
        }
        
        if (playImageView != nil)
        {
            playImageView.removeFromSuperview()
        }
    }
    
    @objc private func portraitPlayerDidFinishPlaying()
    {
        progressIndicatorView.progress = 0.0
        progressIndicatorView.isHidden = true
        
        if (playImageView != nil)
        {
            playImageView.isHidden = true
        }
        
        // Play the portrait video again
        let videoShort = videoShortsArray[currentVideoIndex]
        let videolId = videoShort["videoId"] as? String ?? ""
        
        if (videolId.count > 0)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            {
                self.getVideoInfo(videoId: videolId, allowAds: false)
            }
        }
    }
    
    // MARK: - VideoAdPlayerMethods
    
    private func showVideoAdPlayer()
    {
        self.removePortraitPlayer()
        
        if (videoAdView != nil)
        {
            videoAdView = nil
        }
        
        let videoShort = videoShortsArray[currentVideoIndex]
        let videoId = videoShort["videoId"] as? String ?? ""
        let title = videoShort["title"] as? String ?? ""
        //let title = "White returns a 98 yard punt return to send them into the playoffs"
        
        videoAdView = VerticalVideoAdPlayerView(frame: CGRect(x: 0, y: (CGFloat(currentVideoIndex) * kDeviceHeight) + kDeviceHeight, width: kDeviceWidth, height: kDeviceHeight), videoId: videoId, titleText: title)
        videoAdView.delegate = self
        videoAdView.parentVC = self
        containerScrollView.addSubview(videoAdView)
        //self.view.insertSubview(videoAdView, aboveSubview: containerScrollView)
        
        progressIndicatorView.isHidden = true
        titleOverlayView.isHidden = true
        shareButton.isHidden = true
        
        // Disable scrolling until the scrollBlockTimer callback is received
        containerScrollView.isScrollEnabled = false
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + kVideoAdScrollBlockingTime)
        {
            self.containerScrollView.isScrollEnabled = true
        }
        */
    }
    
    private func removeVideoAdPlayer()
    {
        if (videoAdView != nil)
        {
            videoAdView.pauseAdVideoPlayer()
            videoAdView.cleanupVideoPlayer()
            videoAdView.removeFromSuperview()
            progressIndicatorView.isHidden = false
            titleOverlayView.isHidden = false
            shareButton.isHidden = false
            
            self.containerScrollView.isScrollEnabled = true
        }
    }
    
    func videoAdFinished()
    {
        self.removeVideoAdPlayer()
        
        if (blockPlayerStarts == true)
        {
            return
        }
        
        // This blocks the ad completion from firing off the video player if in the background
        if (UIApplication.shared.applicationState == .active)
        {
            // Play the video
            let videoShort = videoShortsArray[currentVideoIndex]
            let videoId = videoShort["videoId"] as? String ?? ""
            
            if (videoId.count > 0)
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
                {
                    self.getVideoInfo(videoId: videoId, allowAds: true)
                }
            }
            else
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This video can not be found.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    func scrollBlockTimerExpired() 
    {
        self.containerScrollView.isScrollEnabled = true
    }
    
    // MARK: - bump Screen Method
    
    private func bumpScreen()
    {
        // Reset the overlay to its starting position
        titleOverlayView.resetOverlay()
        titleOverlayView.enableBumpText(true)
        
        // Translate the screen up and down
        let yShiftValue = self.kTitleOverlayTransformHeight - 70.0
        
        UIView.animate(withDuration: 0.3, animations: {self.titleOverlayView.transform = CGAffineTransform(translationX: 0.0, y: yShiftValue); self.progressIndicatorView.transform = CGAffineTransform(translationX: 0.0, y: -70.0)}) { done in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                UIView.animate(withDuration: 0.3, animations: {self.titleOverlayView.transform = CGAffineTransform(translationX: 0.0, y: self.kTitleOverlayTransformHeight);self.progressIndicatorView.transform = CGAffineTransformIdentity}) { done in
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
                    {
                        UIView.animate(withDuration: 0.3, animations: {self.titleOverlayView.transform = CGAffineTransform(translationX: 0.0, y: yShiftValue); self.progressIndicatorView.transform = CGAffineTransform(translationX: 0.0, y: -70.0)}) { done in
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                            {
                                UIView.animate(withDuration: 0.3, animations: {self.titleOverlayView.transform = CGAffineTransform(translationX: 0.0, y: self.kTitleOverlayTransformHeight); self.progressIndicatorView.transform = CGAffineTransformIdentity}) { done in
                                    
                                    self.titleOverlayView.enableBumpText(false)
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    // MARK: - Steering Logic
    
    private func playVideoOrAd(videoUrlString: String, allowAds: Bool)
    {
        if (allowAds == false)
        {
            self.playPortraitVideo(videoUrlString: videoUrlString)
            
            if (bumpScreenShownAlready == false)
            {
                if (bumpScreenCount < 1)
                {
                    bumpScreenCount += 1
                }
                else
                {
                    bumpScreenCount = 0
                    bumpScreenShownAlready = true
                    self.bumpScreen()
                }
            }
        }
        else
        {
            bumpScreenCount = 0
            bumpScreenShownAlready = false
            
            if (SharedData.verticalVideoPlayCount < kPortraitVideoPlayMaxCount)
            {
                self.removeVideoAdPlayer()
                self.playPortraitVideo(videoUrlString: videoUrlString)
                SharedData.verticalVideoPlayCount += 1
            }
            else
            {
                self.removePortraitPlayer()
                self.showVideoAdPlayer()
                SharedData.verticalVideoPlayCount = 0
            }
        }
    }
    
    // MARK: - Get Video Info
    
    private func getVideoInfo(videoId: String, allowAds: Bool)
    {
        // This prevents a second trigger when scrolling past and ad
        if (getVideoInfoBusy == true)
        {
            return
        }
        
        getVideoInfoBusy = true
        
        NewFeeds.getVideoInfo(videoId: videoId) { videoObj, error in
                        
            if (error == nil)
            {
                print("Get Video Info Successful")
                
                // Use the externalVideoURL instead of renditions if it is available
                if let externalVideoURL = videoObj!["externalVideoURL"] as? String
                {
                    if (externalVideoURL.count > 0)
                    {
                        self.playVideoOrAd(videoUrlString: externalVideoURL, allowAds: allowAds)
                        self.getVideoInfoBusy = false
                        return
                    }
                }
                
                // If the partner is not NULL (NULL for MPX Videos), set it from the videoInfo object
                var externalPartner = "MPX"
                
                // Can be null
                if let partner = videoObj!["externalPartner"] as? String
                {
                    externalPartner = partner
                }
                
                // Look for the best video to use
                let renditions = videoObj!["renditions"] as! Array<Any>
                
                if (renditions.count == 0)
                {
                    
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This video can not be played due to a playback error.", lastItemCancelType: false) { tag in
                            
                    }
                    return
                }

                
                var videoUrlString = ""
                var mpxDictionary: Dictionary<String,String> = [:]
                
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
                                videoUrlString = rendition["streamingUrl"]! as! String
                                break
                            }
                        }
                        
                        // Fallback case
                        if (rendition["assetType"] as! String == "3G")
                        {
                            // Break if the preferred case is found
                            if (rendition["streamingUrl"] != nil)
                            {
                                videoUrlString = rendition["streamingUrl"]! as! String
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
                                videoUrlString = rendition["streamingUrl"]! as! String
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
                                videoUrlString = rendition["streamingUrl"]! as! String
                                break
                            }
                        }
                        
                        // Fallback case
                        if (rendition["assetType"] as! String == "3G")
                        {
                            // Break if the preferred case is found
                            if (rendition["streamingUrl"] != nil)
                            {
                                videoUrlString = rendition["streamingUrl"]! as! String
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
                                videoUrlString = rendition["streamingUrl"]! as! String
                                break
                            }
                        }
                        
                        // Fallback case
                        if (rendition["assetType"] as! String == "3G")
                        {
                            // Break if the preferred case is found
                            if (rendition["streamingUrl"] != nil)
                            {
                                videoUrlString = rendition["streamingUrl"]! as! String
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
                                videoUrlString = rendition["streamingUrl"]! as! String
                                break
                            }
                        }
                        
                        // Fallback case
                        if (rendition["assetType"] as! String == "3G")
                        {
                            // Break if the preferred case is found
                            if (rendition["streamingUrl"] != nil)
                            {
                                videoUrlString = rendition["streamingUrl"]! as! String
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
                        
                        if (rendition["assetType"] as! String == "HLS_VARIANT_TABLET")
                        {
                            // Break if the preferred case is found
                            if (rendition["streamingUrl"] != nil)
                            {
                                //videoUrlString = rendition["streamingUrl"]! as! String
                                //break
                                mpxDictionary["HLS_VARIANT_TABLET"] = (rendition["streamingUrl"]! as! String)
                            }
                        }
                        else if (rendition["assetType"] as! String == "HLS_VARIANT_PHONE")
                        {
                            // Break if the preferred case is found
                            if (rendition["streamingUrl"] != nil)
                            {
                                //videoUrlString = rendition["streamingUrl"]! as! String
                                //break
                                mpxDictionary["HLS_VARIANT_PHONE"] = (rendition["streamingUrl"]! as! String)
                            }
                        }
                        
                        else if (rendition["assetType"] as! String == "HLS")
                        {
                            // Break if the preferred case is found
                            if (rendition["streamingUrl"] != nil)
                            {
                                //videoUrlString = rendition["streamingUrl"]! as! String
                                //break
                                mpxDictionary["HLS"] = (rendition["streamingUrl"]! as! String)
                            }
                        }
                        else if (rendition["assetType"] as! String == "WIFI")
                        {
                            // Break if the preferred case is found
                            if (rendition["streamingUrl"] != nil)
                            {
                                //videoUrlString = rendition["streamingUrl"]! as! String
                                //break
                                mpxDictionary["WIFI"] = (rendition["streamingUrl"]! as! String)
                            }
                        }
                    }
                }
                
                // Pick the best rendition from the mpxDictionary
                if (externalPartner == "MPX")
                {
                    if (mpxDictionary["HLS_VARIANT_TABLET"] != nil)
                    {
                        videoUrlString = mpxDictionary["HLS_VARIANT_TABLET"]!
                    }
                    else
                    {
                        if (mpxDictionary["HLS_VARIANT_PHONE"] != nil)
                        {
                            videoUrlString = mpxDictionary["HLS_VARIANT_PHONE"]!
                        }
                        else
                        {
                            if (mpxDictionary["HLS"] != nil)
                            {
                                videoUrlString = mpxDictionary["HLS"]!
                            }
                            else
                            {
                                if (mpxDictionary["WIFI"] != nil)
                                {
                                    videoUrlString = mpxDictionary["WIFI"]!
                                }
                            }
                        }
                    }
                }
                
                // This is for all of the other cases tha use streamingUrl
                if (videoUrlString.count > 0)
                {
                    // Check to make sure it's not a Flash file
                    let url = URL(string: videoUrlString)
                    let fileExtension = url?.pathExtension
                    
                    if (fileExtension?.lowercased() == "flv")
                    {
                        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This video can not be played on an iOS device.", lastItemCancelType: false) { tag in
                            
                        }
                        self.getVideoInfoBusy = false
                    }
                    else
                    {
                        self.playVideoOrAd(videoUrlString: videoUrlString, allowAds: allowAds)
                        self.getVideoInfoBusy = false
                    }
                }
                else
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This video is not available for your device.", lastItemCancelType: false) { tag in
                        
                    }
                    self.getVideoInfoBusy = false
                }
                //}
            }
            else
            {
                print("Get Video Info Failed")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This video can not be found.", lastItemCancelType: false) { tag in
                    
                }
                self.getVideoInfoBusy = false
            }
        }
    }
    
    // MARK: - ScrollView Delegates
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) 
    {
        let previousVideoIndex = currentVideoIndex
        
        // Compare the content offset while decelerating to the end to detemine the scroll direction
        if (deceleratingContentOffset < scrollView.contentOffset.y)
        {
            // Going down
            self.showNavTitleLabel(false)
        }
        else
        {
            // Going up
            self.showNavTitleLabel(true)
        }
        
        if (scrollView.contentOffset.y == 0)
        {
            scrollView.scrollRectToVisible(CGRect(x: 0, y: scrollView.contentSize.height - kDeviceHeight - kDeviceHeight, width: kDeviceWidth, height: kDeviceHeight), animated: false)
            
            currentVideoIndex = videoShortsArray.count - 1
        }
        else if (scrollView.contentOffset.y == (scrollView.contentSize.height - kDeviceHeight))
        {
            scrollView.scrollRectToVisible(CGRect(x: 0, y: kDeviceHeight, width: kDeviceWidth, height: kDeviceHeight), animated: false)
            
            currentVideoIndex = 0
        }
        else
        {
            currentVideoIndex = Int(scrollView.contentOffset.y - kDeviceHeight) / Int(kDeviceHeight)
        }
        
        // Don't continue if nothing changed
        if (previousVideoIndex == currentVideoIndex)
        {
            return
        }

        print(String(format: "Current Video Index: %d", currentVideoIndex))
        
        // Reset the overlay to its starting position
        titleOverlayView.resetOverlay()
        
        // Load the titleOverlay text
        self.loadTitleOverlayView()
        
        // Hide the progress indicator
        progressIndicatorView.progress = 0.0
        progressIndicatorView.isHidden = true
        
        if (playImageView != nil)
        {
            playImageView.isHidden = true
        }
        
        // Play the video
        let videoShort = videoShortsArray[currentVideoIndex]
        let videolId = videoShort["videoId"] as? String ?? ""
        
        if (videolId.count > 0)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
            {
                self.getVideoInfo(videoId: videolId, allowAds: true)
            }
        }
        else
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This video can not be found.", lastItemCancelType: false) { tag in
                
            }
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) 
    {
        deceleratingContentOffset = scrollView.contentOffset.y
    }

    // MARK: - Build Thumbnails
    
    private func buildThumbnails()
    {
        var containerScrollViewTotalHeight = 0.0
        var index = 1
        
        for videoShort in videoShortsArray
        {
            //print("Video Short")
   
            let thumbnailImageView = UIImageView(frame: CGRect(x: 0, y: (kDeviceHeight * CGFloat(index)), width: kDeviceWidth, height: kDeviceHeight))
            thumbnailImageView.contentMode = .scaleAspectFill
            containerScrollView.addSubview(thumbnailImageView)
            
            /*
            // Add a label in the middle to keep track of the screens
            let label = UILabel(frame: CGRect(x: 0, y: (kDeviceHeight / 2.0) - 20.0, width: kDeviceWidth, height: 40.0))
            label.textAlignment = .center
            label.textColor = .yellow
            label.font = UIFont.mpBoldFontWith(size: 36)
            label.text = String(index - 1)
            thumbnailImageView.addSubview(label)
            */
            let thumbnailUrl = videoShort["thumbnailUrl"] as? String ?? ""
            if (thumbnailUrl.count > 0)
            {
                let url = URL(string: thumbnailUrl)
                
                // Get the data and make an image
                MiscHelper.getData(from: url!) { data, response, error in
                    guard let data = data, error == nil else { return }

                    DispatchQueue.main.async()
                    {
                        let image = UIImage(data: data)
                        
                        if (image != nil)
                        {
                            thumbnailImageView.image = image
                        }
                        else
                        {
                            if (SharedData.deviceAspectRatio as! AspectRatio == .high)
                            {
                                let image = UIImage.init(named: "EmptyVerticalVideoTall")
                                thumbnailImageView.image = image
                            }
                            else
                            {
                                let image = UIImage.init(named: "EmptyVerticalVideoShort")
                                thumbnailImageView.image = image
                            }
                        }
                    }
                }
            }
            else
            {
                if (SharedData.deviceAspectRatio as! AspectRatio == .high)
                {
                    let image = UIImage.init(named: "EmptyVerticalVideoTall")
                    thumbnailImageView.image = image
                }
                else
                {
                    let image = UIImage.init(named: "EmptyVerticalVideoShort")
                    thumbnailImageView.image = image
                }
            }
            index += 1
            containerScrollViewTotalHeight = containerScrollViewTotalHeight + kDeviceHeight
            
        }
        
        // Add the extra imageViews to the top and bottom
        let thumbnailImageViewTop = UIImageView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight))
        thumbnailImageViewTop.contentMode = .scaleAspectFill
        containerScrollView.addSubview(thumbnailImageViewTop)
        
        /*
        // Add a label to keep track of the screens
        let labelT = UILabel(frame: CGRect(x: 0, y: (kDeviceHeight / 2.0) - 20.0, width: kDeviceWidth, height: 40.0))
        labelT.textAlignment = .center
        labelT.textColor = .yellow
        labelT.font = UIFont.mpBoldFontWith(size: 36)
        labelT.text = String(videoShortsArray.count - 1)
        thumbnailImageViewTop.addSubview(labelT)
        */
        let videoShortTop = videoShortsArray.last
        let thumbnailUrlTop = videoShortTop!["thumbnailUrl"] as? String ?? ""
        if (thumbnailUrlTop.count > 0)
        {
            let url = URL(string: thumbnailUrlTop)
            
            // Get the data and make an image
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        thumbnailImageViewTop.image = image
                    }
                    else
                    {
                        let image = UIImage.init(named: "EmptyProfilePhoto")
                        thumbnailImageViewTop.image = image
                    }
                }
            }
        }
        else
        {
            let image = UIImage.init(named: "EmptyProfilePhoto")
            thumbnailImageViewTop.image = image
        }
        
        // Increment the height
        containerScrollViewTotalHeight = containerScrollViewTotalHeight + kDeviceHeight
  
        let thumbnailImageViewBottom = UIImageView(frame: CGRect(x: 0, y: containerScrollViewTotalHeight, width: kDeviceWidth, height: kDeviceHeight))
        thumbnailImageViewBottom.contentMode = .scaleAspectFill
        containerScrollView.addSubview(thumbnailImageViewBottom)
        /*
        // Add a label to keep track of the screens
        let labelB = UILabel(frame: CGRect(x: 0, y: (kDeviceHeight / 2.0) - 20.0, width: kDeviceWidth, height: 40.0))
        labelB.textAlignment = .center
        labelB.textColor = .yellow
        labelB.font = UIFont.mpBoldFontWith(size: 36)
        labelB.text = "0"
        thumbnailImageViewBottom.addSubview(labelB)
        */
        let videoShortBottom = videoShortsArray.first
        let thumbnailUrlBottom = videoShortBottom!["thumbnailUrl"] as? String ?? ""
        if (thumbnailUrlBottom.count > 0)
        {
            let url = URL(string: thumbnailUrlBottom)
            
            // Get the data and make an image
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        thumbnailImageViewBottom.image = image
                    }
                    else
                    {
                        let image = UIImage.init(named: "EmptyProfilePhoto")
                        thumbnailImageViewBottom.image = image
                    }
                }
            }
        }
        else
        {
            let image = UIImage.init(named: "EmptyProfilePhoto")
            thumbnailImageViewBottom.image = image
        }
        
        // Increment the height
        containerScrollViewTotalHeight = containerScrollViewTotalHeight + kDeviceHeight
        
        // Update the scrollView's contentSize
        containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: containerScrollViewTotalHeight)
        
        // Set the contentOffset to the initial index + kDeviceHeight
        containerScrollView.scrollRectToVisible(CGRect(x: 0, y: (CGFloat(initialVideoIndex) * kDeviceHeight) + kDeviceHeight, width: kDeviceWidth, height: kDeviceHeight), animated: false)
        
        // Play the video
        let videoShort = videoShortsArray[currentVideoIndex]
        let videoId = videoShort["videoId"] as? String ?? ""
        
        if (videoId.count > 0)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                self.getVideoInfo(videoId: videoId, allowAds: true)
            }
        }
        else
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This video can not be found.", lastItemCancelType: false) { tag in
                
            }
        }
        
    }
    
    // MARK: - Show-Hide Nav Title Label
    
    private func showNavTitleLabel(_ show: Bool)
    {
        if (show == true)
        {
            UIView.animate(withDuration: 0.2)
            { [self] in
                self.navTitleLabel.alpha = 1
            }
        }
        else
        {
            UIView.animate(withDuration: 0.2)
            { [self] in
                self.navTitleLabel.alpha = 0
            }
        }
    }
    
    // MARK: - Title Overlay Delegate
    
    func overlayViewExpanded(_ expanded: Bool)
    {
        if (expanded == true)
        {
            UIView.animate(withDuration: 0.3)
            { [self] in
                self.titleOverlayView.transform = CGAffineTransform.identity
            }
        }
        else
        {
            UIView.animate(withDuration: 0.3)
            { [self] in
                self.titleOverlayView.transform = CGAffineTransform(translationX: 0.0, y: self.kTitleOverlayTransformHeight)
            }
        }
    }
    
    // MARK: - Load Title Overlay View
    
    private func loadTitleOverlayView()
    {
        /*
        // title shown is 64 characters
        let title = "White returns a 98 yard punt return to send them into the playoffs"
        
        // description shown is 64 * 6 = 384
        let description = "Experience the game changing moment when this player finishes. Experience the game changing moment when this player finishes. Experience the game changing moment when this player finishes. Experience the game changing moment when this player finishes. Experience the game changing moment when this player finishes. Experience the game changing moment when this player finishes."
        */
        let videoShort = videoShortsArray[currentVideoIndex]
        let title = videoShort["title"] as? String ?? ""
        let description = videoShort["description"] as? String ?? ""
        
        titleOverlayView.loadTitleOverlayData(title: title, description: description)
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        blockPlayerStarts = true
        self.removePortraitPlayer()
        self.removeVideoAdPlayer()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareButtonTouched(_ sender: UIButton)
    {
        // Get the canonicalUrl
        let videoShort = videoShortsArray[currentVideoIndex]
        let canonicalUrl = videoShort["canonicalUrl"] as? String ?? ""
        
        // Call the Bitly feed to compress the URL
        NewFeeds.getBitlyUrl(canonicalUrl) { (dictionary, error) in
  
            var dataToShare = [kShareMessageText + canonicalUrl]
            
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
            self.present(activityVC, animated: true)
        }
    }
    
    @IBAction func testButtonTouched(_ sender: UIButton)
    {
        self.bumpScreen()
        
        /*
        videoAdVisible = !videoAdVisible
        
        if (videoAdVisible == true)
        {
            self.removePortraitPlayer()
            self.showVideoAdPlayer()
        }
        else
        {
            self.removeVideoAdPlayer()
            
            // Play the portrait video
            let videoShort = videoShortsArray[currentVideoIndex]
            let videoId = videoShort["videoId"] as? String ?? ""
            
            if (videoId.count > 0)
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2)
                {
                    self.getVideoInfo(videoId: videoId, allowAds: false)
                }
            }
            else
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This video can not be found.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
        */
    }
    
    // MARK: - Gesture Methods
    
    @objc func handleTap(sender: UITapGestureRecognizer)
    {
        print("Tap Detected")
        if (player != nil)
        {
            if (player.timeControlStatus == AVPlayer.TimeControlStatus.playing )
            {
                player.pause()
                playImageView.isHidden = false
            }
            else
            {
                player.play()
                playImageView.isHidden = true
            }
        }
    }
    
    // MARK: - App Entered Background Notification
    
    @objc private func applicationDidEnterBackground()
    {
        if (player != nil)
        {
            //if (player.timeControlStatus == AVPlayer.TimeControlStatus.playing)
            //{
                player.pause()
                playImageView.isHidden = false
            //}
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        currentVideoIndex = initialVideoIndex
        trackingGuid = NSUUID().uuidString
        
        // Size the navBar, and containerScrollView
        navView.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight + 94)
        containerScrollView.frame = CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight)
        
        containerScrollView.contentInsetAdjustmentBehavior = .never
        containerScrollView.decelerationRate = .fast
        
        // Add a tap gesture recognizer to the blackBackgroundView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.cancelsTouchesInView = true
        containerScrollView.addGestureRecognizer(tapGesture)
        
        // Add a gradient layer to the navBar
        let topColor = UIColor(white: 0, alpha: 0.5)
        let bottomColor = UIColor(white: 0, alpha: 0)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: kDeviceWidth, height: navView.frame.size.height)
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.3)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        navView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Add the titleOverlayView and shift it down
        titleOverlayView = VerticalVideoTitleOverlayView(frame: CGRect(x: 0, y: kDeviceHeight - CGFloat(SharedData.bottomSafeAreaHeight) - 96.0 - kTitleOverlayTransformHeight, width: kDeviceWidth, height: CGFloat(SharedData.bottomSafeAreaHeight) + 96.0 + kTitleOverlayTransformHeight), transformHeight: kTitleOverlayTransformHeight)
        titleOverlayView.delegate = self
        titleOverlayView.transform = CGAffineTransform(translationX: 0.0, y: kTitleOverlayTransformHeight)
        self.view.addSubview(titleOverlayView)
        
        progressIndicatorView = UIProgressView(frame: CGRect(x: 0, y: kDeviceHeight - CGFloat(SharedData.bottomSafeAreaHeight) - 12.0, width: kDeviceWidth, height: 3.0))
        progressIndicatorView.progress = 0.0
        progressIndicatorView.trackTintColor = UIColor.mpHeaderBackgroundColor()
        progressIndicatorView.progressTintColor = UIColor.mpRedColor()
        self.view.addSubview(progressIndicatorView)
        progressIndicatorView.isHidden = true
        
        // Add an observer for the app going into the background
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        self.buildThumbnails()
        self.loadTitleOverlayView()
        
        // Show the bump on the first three launches
        let bumpCount = kUserDefaults.value(forKey: kVerticalVideoBumpCountKey) as! Int
        if (bumpCount < 3)
        {
            kUserDefaults.setValue(NSNumber(integerLiteral: bumpCount + 1), forKey: kVerticalVideoBumpCountKey)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            {
                self.bumpScreen()
            }
        }
        
        // Tracking
        TrackingManager.trackState(featureName: "shorts", trackingGuid: self.trackingGuid, cData: kEmptyTrackingContextData)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

    }
    
    override func viewWillDisappear(_ animated: Bool) 
    {
        super.viewWillDisappear(animated)
        
        self.removePortraitPlayer()
        self.removeVideoAdPlayer()
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
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
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
}
