//
//  NewModalWebViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 9/12/23.
//

import UIKit
import WebKit
import GoogleMobileAds
//import MoPubAdapter
import DTBiOSSDK
import AdSupport
import AppTrackingTransparency

protocol NewModalWebViewControllerDelegate: AnyObject
{
    func modalWebViewControllerCancelButtonTouched()
}

class NewModalWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, DTBAdCallback, GADBannerViewDelegate, ContestNotificationsSelectorViewDelegate, VideoBannerViewCellDelegate
{
    weak var delegate: NewModalWebViewControllerDelegate?
    
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!
    
    var urlString = ""
    var titleString = ""
    var showScrollIndicators = false
    var showLoadingOverlay = false
    var showBannerAd = false
    var showVideoBanner = false
    var showShareButton = true
    var enableAdobeQueryParameter = false
    var trackingContextData = kEmptyTrackingContextData
    var trackingKey = ""
    var adId = ""
    var ftag = "" // Added for deep link attribution that is forwarded to the video player
    var contestId = "" // Added for contest notifications and the videoBanner ad
    var sport = "" // Added for contest notifications
    var contestDate = Date()
    var duplicateNotification = false
    
    private var trackingGuid = ""
    private var tickTimer: Timer!
    private var systemNotificationsEnabled = false
    
    private var browserView: WKWebView!
    private var progressIndicator: UIProgressView = UIProgressView()
    private var webRefreshControl = UIRefreshControl()
    
    private var navContainerView : UIView!
    private var backButton: UIButton!
    private var forwardButton: UIButton!
    
    private var googleBannerAdView: GAMBannerView!
    private var bannerBackgroundView: UIVisualEffectView! //UIImageView!
    
    private var videoBannerViewCell: VideoBannerViewCell!
    private var bannerVideoSize = CGSize(width: 224.0, height: 126.0 + 16.0)
    
    private var browserInitialHeight = 0
    private var notificationOn = false
    
    private var videoPlayerVC: VideoPlayerViewController!
    private var notificationSelectorView: ContestNotificationsSelectorView!
    
    // MARK: - Nimbus Variables
    
    let apsLoader: DTBAdLoader = {
        let loader = DTBAdLoader()
        loader.setAdSizes([
            DTBAdSize(bannerAdSizeWithWidth: 320, height: 50, andSlotUUID: kAmazonBannerAdSlotUUID) as Any
        ])
        return loader
    }()
    
    lazy var bidders: [Bidder] = [
        // Position identifies this placement in our dashboard, it is freeform so I matched the Google ad unit name
        NimbusBidder(request: .forBannerAd(position: "web")),
        APSBidder(adLoader: apsLoader)
    ]
    
    lazy var dynamicPriceManager = DynamicPriceManager(bidders: bidders, refreshInterval: TimeInterval(kNimbusAdTimerValue))
    
    // MARK: - Get Contest Videos
    
    private func getContestVideos()
    {
        NewFeeds.getContestVideos(contestId: self.contestId, count: 10) { videos, error in
            
            if (error == nil)
            {
                print("Get Contest Videos Success")
                
                if (self.videoBannerViewCell == nil)
                {
                    //self.clearVideoBannerViewCell()
                    if (videos!.count > 0)
                    {
                        let videoBannerNib = Bundle.main.loadNibNamed("VideoBannerViewCell", owner: self, options: nil)
                        self.videoBannerViewCell = videoBannerNib![0] as? VideoBannerViewCell
                        self.videoBannerViewCell.parentVC = self
                        self.videoBannerViewCell.delegate = self
                        self.videoBannerViewCell.trackingKey = self.trackingKey
                        self.videoBannerViewCell.trackingContextData = self.trackingContextData
                        self.videoBannerViewCell.frame = CGRect(x: 0, y: self.browserView.frame.origin.y + CGFloat(self.browserInitialHeight) - self.bannerVideoSize.height, width: kDeviceWidth, height: self.bannerVideoSize.height)
                        self.view.addSubview(self.videoBannerViewCell)
                        
                        // This delay was required so the VideoBannerCell was added to the view heirarchy before building the video player
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            self.videoBannerViewCell.loadData(videos!)
                        }
                        
                        // Resize the browser and shift the navContainerup
                        self.browserView.frame.size = CGSize(width: kDeviceWidth, height: CGFloat(self.browserInitialHeight) - self.bannerVideoSize.height)
                        self.navContainerView.frame.origin = CGPoint(x: 20.0, y: self.fakeStatusBar.frame.size.height + self.navView.frame.size.height + CGFloat(self.browserInitialHeight) - self.bannerVideoSize.height - 60.0)
                    }
                    else
                    {
                        if (self.showBannerAd == true)
                        {
                            self.loadBannerViews()
                        }
                    }
                }
                else
                {
                    if (videos!.count > 0)
                    {
                        self.videoBannerViewCell.isHidden = false
                        self.videoBannerViewCell.loadData(videos!)
                        
                        // Resize the browser and shift the navContainerup
                        self.browserView.frame.size = CGSize(width: kDeviceWidth, height: CGFloat(self.browserInitialHeight) - self.bannerVideoSize.height)
                        self.navContainerView.frame.origin = CGPoint(x: 20.0, y: self.fakeStatusBar.frame.size.height + self.navView.frame.size.height + CGFloat(self.browserInitialHeight) - self.bannerVideoSize.height - 60.0)
                    }
                    else
                    {
                        if (self.showBannerAd == true)
                        {
                            self.loadBannerViews()
                        }
                    }
                }
            }
            else
            {
                print("Get Contest Videos Failed")
                if (self.showBannerAd == true)
                {
                    self.loadBannerViews()
                }
            }
        }
    }
    
    // MARK: - VideoBannerViewCell Delegate
    
    func videoBannerViewCellDidClose()
    {
        self.clearVideoBannerViewCell()
        
        if (self.showBannerAd == true)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                self.loadBannerViews()
            }
        }
    }
    
    func videoBannerViewPlayerDidMinimize()
    {
        let tabBarController = kAppKeyWindow.rootViewController as? UITabBarController
        tabBarController?.tabBar.isHidden = true
    }
    
    private func clearVideoBannerViewCell()
    {
        if (videoBannerViewCell != nil)
        {
            videoBannerViewCell.isHidden = true
            //videoBannerViewCell.removeFromSuperview()
            //videoBannerViewCell = nil
        }
        
        browserView.frame.size = CGSize(width: kDeviceWidth, height: CGFloat(browserInitialHeight))
        navContainerView.frame.origin = CGPoint(x: 20.0, y: fakeStatusBar.frame.size.height + navView.frame.size.height + CGFloat(browserInitialHeight) - 60.0)
    }
    
    // MARK: - Show Full Screen Video Player
    
    private func showFullScreenVideoPlayer(videoId:String)
    {
        // Stop the videoBannerViewCell and hide it
        if (videoBannerViewCell != nil)
        {
            videoBannerViewCell.stopVideo()
            clearVideoBannerViewCell()
        }
        
        videoPlayerVC = VideoPlayerViewController(nibName: "VideoPlayerViewController", bundle: nil)
        videoPlayerVC.videoIdString = videoId
        videoPlayerVC.trackingKey = self.trackingKey
        videoPlayerVC.trackingContextData = self.trackingContextData
        videoPlayerVC.ftag = self.ftag
        videoPlayerVC.modalPresentationStyle = .fullScreen
        self.present(videoPlayerVC, animated: true)
    }
    
    // MARK: - UI Delegate
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView?
    {
        if (navigationAction.targetFrame == nil)
        {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    // MARK: - Navigaton Delegates
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        if let urlString = navigationAction.request.url?.absoluteString
        {
            print("Decide Policy for URL: " + urlString);
            if urlString.contains("about:blank")
            {
               // print("Rejected URL, about:blank")
                decisionHandler(.cancel)
                return
            }
            // Extract the videoid from the url if the type is video
            let videoId = MiscHelper.extractVideoIdFromString(urlString)
            
            if (videoId.count > 0)
            {
                decisionHandler(.cancel)
                self.showFullScreenVideoPlayer(videoId: videoId)
                return
            }
        }
        
        //print("Allowed")
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!)
    {
        print("Did Commit")
        
        if (self.showLoadingOverlay)
        {
            // Deadman timer for the overlay view
            DispatchQueue.main.asyncAfter(deadline: .now() + 3)
            { [self] in
                self.progressIndicator.setProgress(0.0, animated: false)
            }
        }
        
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        print("Did Finish")
        
        if (self.showLoadingOverlay)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            { [self] in
                self.progressIndicator.setProgress(0.0, animated: false)
            }
        }
        
        if (browserView.canGoBack == true) || (browserView.canGoForward == true)
        {
            navContainerView.isHidden = false
        }
        else
        {
            navContainerView.isHidden = true
        }
        
        if (browserView.canGoBack == true)
        {
            backButton.isEnabled = true
            backButton.alpha = 1
        }
        else
        {
            backButton.isEnabled = false
            backButton.alpha = 0.5
        }
        
        if (browserView.canGoForward == true)
        {
            forwardButton.isEnabled = true
            forwardButton.alpha = 1
        }
        else
        {
            forwardButton.isEnabled = false
            forwardButton.alpha = 0.5
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation: WKNavigation!, withError: Error)
    {
        print("Did Fail")
        
        if (self.showLoadingOverlay)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            { [self] in
                self.progressIndicator.setProgress(0.0, animated: false)
            }
        }
        
        if (browserView.canGoBack == true) || (browserView.canGoForward == true)
        {
            navContainerView.isHidden = false
        }
        else
        {
            navContainerView.isHidden = true
        }
        
        if (browserView.canGoBack == true)
        {
            backButton.isEnabled = true
        }
        else
        {
            backButton.isEnabled = false
        }
        
        if (browserView.canGoForward == true)
        {
            forwardButton.isEnabled = true
        }
        else
        {
            forwardButton.isEnabled = false
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error)
    {
        print("Did Fail")
        
        if (self.showLoadingOverlay)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            { [self] in
                self.progressIndicator.setProgress(0.0, animated: false)
            }
        }
        
        if (browserView.canGoBack == true) || (browserView.canGoForward == true)
        {
            navContainerView.isHidden = false
        }
        else
        {
            navContainerView.isHidden = true
        }
        
        if (browserView.canGoBack == true)
        {
            backButton.isEnabled = true
        }
        else
        {
            backButton.isEnabled = false
        }
        
        if (browserView.canGoForward == true)
        {
            forwardButton.isEnabled = true
        }
        else
        {
            forwardButton.isEnabled = false
        }
    }
    
    // MARK: - ContestNotificationSelectorView Delegate Method

    func contestNotificationsSelectorViewDidCancel()
    {
        notificationSelectorView.removeFromSuperview()
        notificationSelectorView = nil
        
        // Update the bell by parsing the contestNotifications for this contest
        let existingContestNotifications = kUserDefaults.dictionary(forKey: kContestNotificationsDictionaryKey)
        
        // Use the defaults if this contest didn't exist in prefs
        if (existingContestNotifications![self.contestId] != nil)
        {
            let existingContestNotification = existingContestNotifications![self.contestId] as! Dictionary<String,Any>
            let notificationsArray = existingContestNotification[kContestNotificationSettingsKey] as! Array<Any>
            
            var notificationFound = false
            
            for item in notificationsArray
            {
                let notification = item as! Dictionary<String,Any>
                let isEnabled = notification[kNewNotificationIsEnabledForAppKey] as! Bool
                
                if (isEnabled == true)
                {
                    notificationFound = true
                    break
                }
            }
            
            if (notificationFound == true)
            {
                notificationButton.setImage(UIImage(named: "ContestNotificationOn"), for: .normal)
            }
            else
            {
                notificationButton.setImage(UIImage(named: "ContestNotificationOff"), for: .normal)
            }
        }
        
        // Update Airship
        NotificationManager.loadAirshipNotifications()
    }

    // MARK: - Button Methods
    
    @IBAction func cancelButtonTouched(_ sender: UIButton)
    {
        if (videoBannerViewCell != nil)
        {
            videoBannerViewCell.stopVideo()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            self.delegate?.modalWebViewControllerCancelButtonTouched()
        }
    }
    
    @IBAction func shareButtonTouched(_ sender: UIButton)
    {
        // Get the current URL from the browser
        let currentUrlString = browserView.url?.absoluteString
        //let currentUrlString = "https://secure.maxpreps.com/m/team/articles.aspx?schoolid=c510b298-3a73-4bcf-8855-96c998d8e26e&ssid=97e3f828-856d-419e-b94f-7f41319fe3d3"
        
        // Call the Bitly feed to compress the URL
        NewFeeds.getBitlyUrl(currentUrlString!) { (dictionary, error) in
  
            var dataToShare = [kShareMessageText + self.urlString]
            
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
    
    @IBAction func notificationButtonTouched(_ sender: UIButton)
    {
        if (duplicateNotification == true)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Duplicate Notification", message: "You already have notifications enabled for one of the teams in this contest.", lastItemCancelType: false) { tag in
                
            }
            return
        }
        
        // Check if notifications are allowed
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings(completionHandler: { settings in
          
            if (settings.authorizationStatus == .authorized)
            {
                self.systemNotificationsEnabled = true
            }
            else
            {
                self.systemNotificationsEnabled = false
                
                DispatchQueue.main.async
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["Cancel", "Settings"], title: "Notifications Disabled", message: "Enable notifications for MaxPreps in your device settings to receive notifications for this contest.", lastItemCancelType: false) { (tag) in
                        
                        if (tag == 1)
                        {
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else
                            {
                                return
                            }
                            
                            if UIApplication.shared.canOpenURL(settingsUrl)
                            {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                    
                                })
                            }
                        }
                    }
                }
            }
        })
        
        if (systemNotificationsEnabled == true)
        {
            //let buttonFrame = CGRect(x: kDeviceWidth - 83.0, y: navView.frame.origin.y + 10.0, width: 30.0, height: 40.0)
            let buttonFrame = CGRect(x: sender.frame.origin.x, y: navView.frame.origin.y + sender.frame.origin.y, width: sender.frame.size.width, height: sender.frame.size.height)
            
            notificationSelectorView = ContestNotificationsSelectorView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight), buttonFrame: buttonFrame, contestId: self.contestId, sport: self.sport, contestDate: self.contestDate)
            notificationSelectorView.delegate = self
            
            self.view.addSubview(notificationSelectorView)
        }
    }
    
    @objc func backButtonTouched()
    {
        if (browserView.canGoBack == true)
        {
            browserView.goBack()
        }
    }
    
    @objc func forwardButtonTouched()
    {
        if (browserView.canGoForward == true)
        {
            browserView.goForward()
        }
    }
    
    // MARK: - Amazon Banner Ad Methods
    
    private func requestAmazonBannerAd()
    {
        let adSize = DTBAdSize(bannerAdSizeWithWidth: 320, height: 50, andSlotUUID: kAmazonBannerAdSlotUUID)
        let adLoader = DTBAdLoader()
        adLoader.setAdSizes([adSize!])
        adLoader.loadAd(self)
    }
    
    func onSuccess(_ adResponse: DTBAdResponse!)
    {
        var adResponseDictionary = adResponse.customTargeting()
        
        adResponseDictionary!.updateValue(trackingGuid, forKey: "vguid")
        
        let ccpaString = kUserDefaults.string(forKey: "IABUSPrivacy_String") ?? ""
        adResponseDictionary!.updateValue(ccpaString, forKey: "us_privacy")
        
        // To be added in V6.2.8
        if (MiscHelper.isUserMinorAged() == true)
        {
            adResponseDictionary!.updateValue("1", forKey: "tfcd")
        }
        
        print("Received Amazon Banner Ad")
        
        let request = GAMRequest()
        request.customTargeting = adResponseDictionary
        /*
        // Add a location
        let location = ZipCodeHelper.locationForAd() as! Dictionary<String, String>
        let latitudeValue = Float(location[kLatitudeKey]!)
        let longitudeValue = Float(location[kLongitudeKey]!)
        
        if ((latitudeValue != 0) && (longitudeValue != 0))
        {
            request.setLocationWithLatitude(CGFloat(latitudeValue!), longitude: CGFloat(longitudeValue!), accuracy: 30)
        }
        */
        if (googleBannerAdView != nil)
        {
            googleBannerAdView.load(request)
        }
    }
    
    func onFailure(_ error: DTBAdError)
    {
        print("Amazon Banner Ad Failed")
        
        let request = GAMRequest()
        
        var customTargetDictionary = [:] as Dictionary<String, String>
        let idfaString = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        customTargetDictionary.updateValue(trackingGuid, forKey: "vguid")
        customTargetDictionary.updateValue(idfaString, forKey: "idtype")
        
        // Get the ATT type string to add to the custonTargetDictionary
        let trackingString = MiscHelper.trackingStatusForAds()
        customTargetDictionary.updateValue(trackingString, forKey: "attmas")
        
        let ccpaString = kUserDefaults.string(forKey: "IABUSPrivacy_String") ?? ""
        customTargetDictionary.updateValue(ccpaString, forKey: "us_privacy")
        
        // To be added in V6.2.8
        if (MiscHelper.isUserMinorAged() == true)
        {
            customTargetDictionary.updateValue("1", forKey: "tfcd")
        }
        
        request.customTargeting = customTargetDictionary
        /*
        // Add a location
        let location = ZipCodeHelper.locationForAd() as! Dictionary<String, String>
        let latitudeValue = Float(location[kLatitudeKey]!)
        let longitudeValue = Float(location[kLongitudeKey]!)
        
        if ((latitudeValue != 0) && (longitudeValue != 0))
        {
            request.setLocationWithLatitude(CGFloat(latitudeValue!), longitude: CGFloat(longitudeValue!), accuracy: 30)
        }
        */
        /*
        // Add MoPub
        let extras = GADMoPubNetworkExtras()
        extras.privacyIconSize = 20
        request.register(extras)
        */
        
        if (googleBannerAdView != nil)
        {
            googleBannerAdView.load(request)
        }
        
    }
    
    // MARK: - Google Ad Methods
    
    private func loadBannerViews()
    {
        // Removed for Nimbus
        /*
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
        */
        
        if (googleBannerAdView != nil)
        {
            googleBannerAdView.removeFromSuperview()
            googleBannerAdView = nil
            
            if (bannerBackgroundView != nil)
            {
                bannerBackgroundView.removeFromSuperview()
                bannerBackgroundView = nil
            }
            
            // Reset the browser view's height
            browserView.frame = CGRect(x: 0, y: browserView.frame.origin.y, width: browserView.frame.size.width, height: CGFloat(browserInitialHeight))
            
            // Reset the nav container's y-location
            navContainerView.frame = CGRect(x: 20, y: fakeStatusBar.frame.size.height + navView.frame.size.height + CGFloat(browserInitialHeight) - 48, width: 80, height: 32)
        }
        
        // Removed for Nimbus
        // Add a timer to request a new ad after 15 seconds
        //tickTimer = Timer.scheduledTimer(timeInterval: TimeInterval(kGoogleAdTimerValue), target: self, selector: #selector(adTimerExpired), userInfo: nil, repeats: true)
        
        //GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["ab075279b6aba4510e894e3563b029dc"]
        
        print("AdId: ", adId)
        
        googleBannerAdView = GAMBannerView(adSize: GADAdSizeBanner, origin: CGPoint(x: (kDeviceWidth - GADAdSizeBanner.size.width) / 2.0, y: 6.0))
        googleBannerAdView.delegate = self
        googleBannerAdView.adUnitID = adId
        googleBannerAdView.rootViewController = self
        
        // Removed for Nimbus
        //self.requestAmazonBannerAd()
        
        // Added for Nimbus
        // Starts a task to refresh every 30 seconds with proper foreground/background notifications
        //dynamicPriceManager.autoRefresh { [weak self] request in
        dynamicPriceManager.autoRefresh { request in
            
            request.customTargeting?.updateValue(self.trackingGuid, forKey: "vguid")
            
            // Get the ATT type string to add to the customTargetDictionary
            let trackingString = MiscHelper.trackingStatusForAds()
            request.customTargeting?.updateValue(trackingString, forKey: "attmas")
            
            let ccpaString = kUserDefaults.string(forKey: "IABUSPrivacy_String") ?? ""
            request.customTargeting?.updateValue(ccpaString, forKey: "us_privacy")
            
            let idfaString = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            request.customTargeting?.updateValue(idfaString, forKey: "idtype")
            
            let abTestString = MiscHelper.userABTestValue()
            if (abTestString != "")
            {
                request.customTargeting?.updateValue(abTestString, forKey: "test")
            }
            
            // To be added in V6.2.8
            if (MiscHelper.isUserMinorAged() == true)
            {
                request.customTargeting?.updateValue("1", forKey: "tfcd")
            }
            
            if (self.googleBannerAdView != nil)
            {
                self.googleBannerAdView.load(request)
            }
        }
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView)
    {
        print("Received Google Banner Ad")
        
        /* // MoPub is disabled
        if (bannerView.responseInfo?.adNetworkClassName != "GADMAdapterGoogleAdMobAds")
        {
            print("MoPub Ad Served")
         if (kUserDefaults.bool(forKey: kDebugDialogsKey) == true)
            {
                tickTimer.invalidate()
                tickTimer = nil
                
                MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "MoPub Ad", message: "", lastItemCancelType: false) { tag in
                    
                }
            }
        }
        */
        
        // Added for Nimbus
        if (bannerBackgroundView != nil)
        {
            bannerBackgroundView.removeFromSuperview()
            bannerBackgroundView = nil
        }
        
        // Delay added for Nimbus
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
        {
            
            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            self.bannerBackgroundView = UIVisualEffectView(effect: blurEffect)
            self.bannerBackgroundView.frame =  CGRect(x: 0, y: Int(self.fakeStatusBar.frame.size.height) + Int(self.navView.frame.size.height) + self.browserInitialHeight - Int(GADAdSizeBanner.size.height) - 12, width: Int(kDeviceWidth), height: Int(GADAdSizeBanner.size.height) + 12)
            
            // Add the background to the view and the banner ad to the background
            self.view.addSubview(self.bannerBackgroundView)
            self.bannerBackgroundView.contentView.addSubview(bannerView)
            
            // Move it down so it is hidden
            self.bannerBackgroundView.transform = CGAffineTransform(translationX: 0, y: self.bannerBackgroundView.frame.size.height + 5)
            
            // Shift the nav container up
            self.navContainerView.frame = CGRect(x: 20, y: Int(self.fakeStatusBar.frame.size.height) + Int(self.navView.frame.size.height) + self.browserInitialHeight - Int(self.bannerBackgroundView.frame.size.height) - 48, width: 80, height: 32)
            
            // Animate the ad up
            UIView.animate(withDuration: 0.25, animations: {self.bannerBackgroundView.transform = CGAffineTransform(translationX: 0, y: 0)})
            { (finished) in
                
                // Resize the browser view to be a little shorter
                // Disabled to find the background crash
                //self.browserView.frame = CGRect(x: 0, y: self.browserView.frame.origin.y, width: self.browserView.frame.size.width, height: CGFloat(self.browserInitialHeight) - 16)
                
                // Shift the nav container up
                //self.navContainerView.frame = CGRect(x: 20, y: Int(self.fakeStatusBar.frame.size.height) + Int(self.navView.frame.size.height) + self.browserInitialHeight - Int(self.bannerBackgroundView.frame.size.height) - 48, width: 80, height: 32)
            }
        }
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error)
    {
        print("Google Banner Ad Failed")
        
        // Added for Nimbus
        if (bannerBackgroundView != nil)
        {
            bannerBackgroundView.removeFromSuperview()
            bannerBackgroundView = nil
        }
        
        // Reset the browser view's height
        browserView.frame = CGRect(x: 0, y: self.browserView.frame.origin.y, width: self.browserView.frame.size.width, height: CGFloat(self.browserInitialHeight))
        
        // Reset the nav container's y-location
        navContainerView.frame = CGRect(x: 20, y: fakeStatusBar.frame.size.height + navView.frame.size.height + CGFloat(browserInitialHeight) - 48, width: 80, height: 32)
    }
    
    private func clearBannerAd()
    {
        // Added for Nimbus
        dynamicPriceManager.cancelRefresh()
        
        if (googleBannerAdView != nil)
        {
            googleBannerAdView.removeFromSuperview()
            googleBannerAdView = nil
            
            if (bannerBackgroundView != nil)
            {
                bannerBackgroundView.removeFromSuperview()
                bannerBackgroundView = nil
            }
        }
    }
    
    // MARK: - Ad Timer
    
    @objc private func adTimerExpired()
    {
        self.loadBannerViews()
    }
    
    // MARK: - Pull to Refresh
    
    @objc private func pullToRefresh()
    {
        if (webRefreshControl.isRefreshing == true)
        {
            clearBannerAd()
            clearVideoBannerViewCell()
   
            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            {
                self.browserView.reload()
                self.webRefreshControl.endRefreshing()
                
                // Call the contest videos API
                if (self.showVideoBanner == true)
                {
                    self.getContestVideos()
                }
                else
                {
                    if (self.showBannerAd == true)
                    {
                        self.loadBannerViews()
                    }
                }
            }
        }
    }
    
    // MARK: - Progress Indicator Observer
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if (keyPath == "estimatedProgress")
        {
            progressIndicator.setProgress(Float(browserView.estimatedProgress), animated: true)
            print(browserView.estimatedProgress)
        }
    }
    
    // MARK: - Return from Background Notification
    
    @objc private func returningFromBackground()
    {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings(completionHandler: { settings in
          
            if (settings.authorizationStatus == .authorized)
            {
                self.systemNotificationsEnabled = true
            }
            else
            {
                self.systemNotificationsEnabled = false
            }
            
            // Update the bell by parsing the contestNotifications for this contest
            let existingContestNotifications = kUserDefaults.dictionary(forKey: kContestNotificationsDictionaryKey)
            
            var notificationFound = false
            
            // Use the defaults if this contest didn't exist in prefs
            if (existingContestNotifications![self.contestId] != nil)
            {
                let existingContestNotification = existingContestNotifications![self.contestId] as! Dictionary<String,Any>
                let notificationsArray = existingContestNotification[kContestNotificationSettingsKey] as! Array<Any>

                for item in notificationsArray
                {
                    let notification = item as! Dictionary<String,Any>
                    let isEnabled = notification[kNewNotificationIsEnabledForAppKey] as! Bool
                    
                    if (isEnabled == true)
                    {
                        notificationFound = true
                        break
                    }
                }
            }
            
            DispatchQueue.main.async
            {
                if (self.systemNotificationsEnabled == true)
                {
                    if (notificationFound == true)
                    {
                        self.notificationButton.setImage(UIImage(named: "ContestNotificationOn"), for: .normal)
                    }
                    else
                    {
                        self.notificationButton.setImage(UIImage(named: "ContestNotificationOff"), for: .normal)
                    }
                }
                else
                {
                    if (notificationFound == true)
                    {
                        self.notificationButton.setImage(UIImage(named: "ContestNotificationOnDisabled"), for: .normal)
                    }
                    else
                    {
                        self.notificationButton.setImage(UIImage(named: "ContestNotificationOff"), for: .normal)
                    }
                }
            }
        })
    }
    
    // MARK: - App Entered Background Notification
    
    @objc private func applicationDidEnterBackground()
    {
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
        
        self.clearBannerAd()
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let guid = NSUUID()
        trackingGuid = guid.uuidString
        
        // Size the fakeStatusBar and navBar
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + 12 + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        
        let configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = "MaxPrepsApp";
        configuration.mediaTypesRequiringUserActionForPlayback = .all
        configuration.allowsInlineMediaPlayback = false
        /*
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        preferences.isFraudulentWebsiteWarningEnabled = true
        configuration.preferences = preferences
        */
        
        browserInitialHeight = Int(kDeviceHeight) - Int(navView.frame.origin.y) - Int(navView.frame.size.height) - SharedData.bottomSafeAreaHeight// - 90
        
        browserView = WKWebView(frame: CGRect(x: 0, y: Int(navView.frame.origin.y) + Int(navView.frame.size.height), width: Int(kDeviceWidth), height: browserInitialHeight), configuration: configuration)
        browserView.navigationDelegate = self
        browserView.uiDelegate = self
        browserView.scrollView.showsVerticalScrollIndicator = showScrollIndicators
        browserView.scrollView.showsHorizontalScrollIndicator = showScrollIndicators
        //browserView.allowsBackForwardNavigationGestures = true
        self.view.addSubview(browserView)
        
        // Add refresh control to the browser
        webRefreshControl.tintColor = UIColor.mpLightGrayColor()
        //let attributedString = NSMutableAttributedString(string: "Reloading", attributes: [NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 14), NSAttributedString.Key.foregroundColor: UIColor.mpLightGrayColor()])
        //webRefreshControl.attributedTitle = attributedString
        webRefreshControl.addTarget(self, action: #selector(pullToRefresh), for: UIControl.Event.valueChanged)
        browserView.scrollView.addSubview(webRefreshControl)

        navView.layer.cornerRadius = 12
        navView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        navView.clipsToBounds = true
        
        fakeStatusBar.backgroundColor = .clear
        
        titleLabel.text = self.titleString
        
        navContainerView = UIView(frame: CGRect(x: 20, y:Int(navView.frame.origin.y) + Int(navView.frame.size.height) + browserInitialHeight - 60, width: 80, height: 32))
        navContainerView.layer.cornerRadius = 16
        navContainerView.layer.borderWidth = 1
        navContainerView.layer.borderColor = UIColor.init(white: 0.67, alpha: 0.9).cgColor
        navContainerView.clipsToBounds = true
        navContainerView.backgroundColor = UIColor.init(white: 0.96, alpha: 0.9)
        self.view.addSubview(navContainerView)
        
        backButton = UIButton(type: .custom)
        backButton.frame = CGRect(x: 0, y: 0, width: 40, height: 32)
        backButton.setImage(UIImage(named: "AccessoryLeftRed"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTouched), for: .touchUpInside)
        navContainerView.addSubview(backButton)
        
        //let leftImage = UIImage(named: "ArrowLeftGray")?.withRenderingMode(.alwaysTemplate)
        //backButton.setImage(leftImage, for: .normal)
        //backButton.tintColor = UIColor.mpBlueColor()
        
        forwardButton = UIButton(type: .custom)
        forwardButton.frame = CGRect(x: 40, y: 0, width: 40, height: 32)
        forwardButton.setImage(UIImage(named: "AccessoryRightRed"), for: .normal)
        forwardButton.addTarget(self, action: #selector(forwardButtonTouched), for: .touchUpInside)
        navContainerView.addSubview(forwardButton)
        
        //let rightImage = UIImage(named: "ArrowRightGray")?.withRenderingMode(.alwaysTemplate)
        //forwardButton.setImage(rightImage, for: .normal)
        //forwardButton.tintColor = UIColor.mpBlueColor()
    
        navContainerView.isHidden = true
        backButton.alpha = 0.5
        forwardButton.alpha = 0.5
        
        if (self.showLoadingOverlay)
        {
            progressIndicator.frame = CGRect(x: 0, y: 0, width: kDeviceWidth, height: 6)
            progressIndicator.trackTintColor = .clear
            progressIndicator.progressTintColor = UIColor.mpBlueColor()
            browserView.addSubview(progressIndicator)
            
            browserView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        }
        
        // Add an observer for the app going into the background
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(returningFromBackground), name: Notification.Name(UIApplication.willEnterForegroundNotification.rawValue), object: nil)
        
        
        if (self.showShareButton == false)
        {
            shareButton.isHidden = true
        }
        
        // Show the notification button if the sport and contestId are set
        if (self.sport == "") || (self.contestId == "")
        {
            notificationButton.isHidden = true
        }
        
        // Update the bell icon
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings(completionHandler: { settings in
          
            if (settings.authorizationStatus == .authorized)
            {
                self.systemNotificationsEnabled = true
            }
            else
            {
                self.systemNotificationsEnabled = false
            }
            
            // Update the bell by parsing the contestNotifications for this contest
            let existingContestNotifications = kUserDefaults.dictionary(forKey: kContestNotificationsDictionaryKey)
            
            var notificationFound = false
            
            // Use the defaults if this contest didn't exist in prefs
            if (existingContestNotifications![self.contestId] != nil)
            {
                let existingContestNotification = existingContestNotifications![self.contestId] as! Dictionary<String,Any>
                let notificationsArray = existingContestNotification[kContestNotificationSettingsKey] as! Array<Any>

                for item in notificationsArray
                {
                    let notification = item as! Dictionary<String,Any>
                    let isEnabled = notification[kNewNotificationIsEnabledForAppKey] as! Bool
                    
                    if (isEnabled == true)
                    {
                        notificationFound = true
                        break
                    }
                }
            }
            
            DispatchQueue.main.async
            {
                if (self.systemNotificationsEnabled == true)
                {
                    if (notificationFound == true)
                    {
                        self.notificationButton.setImage(UIImage(named: "ContestNotificationOn"), for: .normal)
                    }
                    else
                    {
                        self.notificationButton.setImage(UIImage(named: "ContestNotificationOff"), for: .normal)
                    }
                }
                else
                {
                    if (notificationFound == true)
                    {
                        self.notificationButton.setImage(UIImage(named: "ContestNotificationOnDisabled"), for: .normal)
                    }
                    else
                    {
                        self.notificationButton.setImage(UIImage(named: "ContestNotificationOff"), for: .normal)
                    }
                }
            }
        })
        
        /*
        // Get rid of some unwanted characters
        // apostrophe
        urlString = urlString.replacingOccurrences(of: "\u{0027}", with: "")

        // left single quote
        urlString = urlString.replacingOccurrences(of: "\u{2018}", with: "")

        // right single quote
        urlString = urlString.replacingOccurrences(of: "\u{2019}", with: "")
        */
        // Add the Omniture tracking query parameter
        if (enableAdobeQueryParameter == true)
        {
            //print(urlString)

            if let testUrl = ADBMobile.visitorAppend(to: URL(string: urlString))
            {
                urlString = testUrl.absoluteString
            }
        }
        
        // Append the app identifier to the URL
        if (urlString.contains("?"))
        {
            urlString = urlString + "&" + kAppIdentifierQueryParam
        }
        else
        {
            urlString = urlString + "?" + kAppIdentifierQueryParam
        }
        
        // Load the browser
        print(urlString)
        if let url = URL(string: urlString)
        {
            let request = URLRequest(url: url)
            browserView.load(request)
        }
        else
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "The url for this item is invalid.", lastItemCancelType: false) { tag in
                
            }
            
            // Added in V6.3.1
            shareButton.isHidden = true
            return
        }
        
        // Call the contest videos API
        if (self.showVideoBanner == true)
        {
            self.getContestVideos()
        }
        else
        {
            if (self.showBannerAd == true)
            {
                self.loadBannerViews()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
                
        setNeedsStatusBarAppearanceUpdate()
        
        // Add some delay so the view is partially showing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
        {
            UIView.animate(withDuration: 0.3)
            { [self] in
                fakeStatusBar.backgroundColor = UIColor(white: 0, alpha: 0.6)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
        
        self.clearBannerAd()
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
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name(UIApplication.willEnterForegroundNotification.rawValue), object: nil)
    }
}
