//
//  WebViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/8/21.
//

import UIKit
import WebKit
import GoogleMobileAds
//import MoPubAdapter
import DTBiOSSDK
import AdSupport
import AppTrackingTransparency

class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, DTBAdCallback, GADBannerViewDelegate, VideoBannerViewCellDelegate //,WKScriptMessageHandler
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var navBackButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    var allowRotation = false
    var urlString = ""
    var titleString = ""
    var navColor = UIColor.mpWhiteColor()
    var titleColor = UIColor.mpBlackColor()
    var showShareButton = false
    var showScrollIndicators = false
    var showLoadingOverlay = false
    var showBannerAd = false
    var tabBarVisible = false
    var enableAdobeQueryParameter = false
    var enableMaxPrepsQueryParameters = true
    var trackingContextData = kEmptyTrackingContextData
    var trackingKey = ""
    var adId = ""
    var ftag = "" // Added for deep link attribution that is forwarded to the video player
    var contestId = "" // Added for the videoBanner ad
    var autoPopAfterVideoPlayerCloses = false // Added to pop this class after the video player closes
    
    private var trackingGuid = ""
    private var tickTimer: Timer!
            
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
    private var showVideoBanner = false
    
    private var browserInitialHeight = 0
    
    private var videoPlayerVC: VideoPlayerViewController!
    
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
        
        if (showBannerAd == true)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                self.loadBannerViews()
            }
        }
    }
    
    func videoBannerViewPlayerDidMinimize()
    {
        if (tabBarVisible == true)
        {
            self.tabBarController?.tabBar.isHidden = false
        }
        else
        {
            self.tabBarController?.tabBar.isHidden = true
        }
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
        videoPlayerVC.trackingContextData = self.trackingContextData
        videoPlayerVC.trackingKey = self.trackingKey
        videoPlayerVC.ftag = self.ftag
        //videoPlayerVC.autoCloseAfterVideoDone = !self.autoPopAfterVideoPlayerCloses
        videoPlayerVC.modalPresentationStyle = .fullScreen
        self.present(videoPlayerVC, animated: true)
    }
    
    // MARK: - UI Delegates
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView?
    {
        if (navigationAction.targetFrame == nil)
        {
            webView.load(navigationAction.request)
            return nil
        }
        else
        {
            let newBrowserView = WKWebView(frame: CGRect(x: 0, y: fakeStatusBar.frame.self.height + navView.frame.size.height, width: kDeviceWidth, height: CGFloat(browserInitialHeight)), configuration: configuration)
            newBrowserView.navigationDelegate = self
            newBrowserView.uiDelegate = self
            return newBrowserView
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void)
    {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))

        present(alertController, animated: true, completion: nil)
    }


    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void)
    {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler(true)
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))

        present(alertController, animated: true, completion: nil)
    }


    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void)
    {
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .actionSheet)

        alertController.addTextField { (textField) in
            textField.text = defaultText
        }

        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(nil)
        }))

        present(alertController, animated: true, completion: nil)
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
            
            // Look for a photo purchase by searching for "&app=1" in the URL. Ask the user if Safari is OK to open
            if (urlString.contains("&app=1"))
            {
                if (UIApplication.shared.canOpenURL(URL(string: urlString)!) == true)
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["Cancel", "Continue"], title: "Open Safari", message: "The application needs to open the Safari web browser to purchase photos.", lastItemCancelType: false) { tag in
                        if (tag == 1)
                        {
                            UIApplication.shared.open(URL(string: urlString)!, options: [:]) { result in
                                
                            }
                        }
                    }
                }
                
                decisionHandler(.cancel)
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
            //self.animateLoadingContainer(show: true)
            
            // Deadman timer for the overlay view
            DispatchQueue.main.asyncAfter(deadline: .now() + 3)
            { [self] in
                self.progressIndicator.setProgress(0.0, animated: false)
                /*
                UIView.animate(withDuration: 0.2)
                { [self] in
                    self.animateLoadingContainer(show: false)
                    
                }
                */
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
                
                /*
                UIView.animate(withDuration: 0.2)
                { [self] in
                    self.animateLoadingContainer(show: false)
                }
                */
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
                
                /*
                UIView.animate(withDuration: 0.2)
                { [self] in
                    self.animateLoadingContainer(show: false)
                }
                */
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
                
                /*
                UIView.animate(withDuration: 0.2)
                { [self] in
                    self.animateLoadingContainer(show: false)
                }
                */
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
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!)
    {
        print("Redirect")
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        completionHandler(.performDefaultHandling, nil)
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched()
    {
        if (videoBannerViewCell != nil)
        {
            videoBannerViewCell.stopVideo()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func shareButtonTouched()
    {
        // Get the current URL from the browser
        var currentUrlString = browserView.url?.absoluteString
        
        if (currentUrlString == nil)
        {
            // Fallback URL
            currentUrlString = urlString
        }
        
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
    
    @objc func browserBackButtonTouched()
    {
        if (browserView.canGoBack == true)
        {
            browserView.goBack()
        }
    }
    
    @objc func browserForwardButtonTouched()
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
            
            self.navContainerView.frame = CGRect(x: 20, y: Int(self.fakeStatusBar.frame.size.height) + Int(self.navView.frame.size.height) + self.browserInitialHeight - Int(self.bannerBackgroundView.frame.size.height) - 48, width: 80, height: 32)
            
            // Animate the ad up
            UIView.animate(withDuration: 0.25, animations: {self.bannerBackgroundView.transform = CGAffineTransform(translationX: 0, y: 0)})
            { (finished) in
                
                // Resize the browser view to be a little shorter
                // Disabled to find the background crash
                if ((self.browserView != nil) && (self.bannerBackgroundView != nil))
                {
                    self.browserView.frame = CGRect(x: 0, y: self.browserView.frame.origin.y, width: self.browserView.frame.size.width, height: CGFloat(self.browserInitialHeight) - self.bannerBackgroundView.frame.size.height)
                }
                
                // Shift the nav container up
                if ((self.navContainerView != nil) && (self.bannerBackgroundView != nil))
                {
                    self.navContainerView.frame = CGRect(x: 20.0, y: self.fakeStatusBar.frame.size.height + self.navView.frame.size.height + CGFloat(self.browserInitialHeight) - self.bannerBackgroundView.frame.size.height - 48.0, width: self.navContainerView.frame.size.width, height: self.navContainerView.frame.size.height)
                }
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
            self.clearBannerAd()
            self.clearVideoBannerViewCell()
            
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
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        trackingGuid = NSUUID().uuidString
        
        titleLabel.text = titleString
        titleLabel.textColor = titleColor
        
        if (titleColor == UIColor.mpBlackColor())
        {
            navBackButton.setImage(UIImage(named: "BackArrowBlack"), for: .normal)
        }
        else
        {
            navBackButton.setImage(UIImage(named: "BackArrowWhite"), for: .normal)
        }
        
        shareButton.isHidden = !showShareButton
        
        fakeStatusBar.backgroundColor = navColor
        navView.backgroundColor = navColor
                
        var bottomTabBarPad = 0
        if (tabBarVisible == true)
        {
            bottomTabBarPad = kTabBarHeight
        }
        
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: Int(fakeStatusBar.frame.size.height), width: Int(kDeviceWidth), height: kNavBarHeight)
        
        // We need to explicitly calculate the browser's height without ads for use elsewhere
        browserInitialHeight = Int(kDeviceHeight) - Int(fakeStatusBar.frame.size.height) - Int(navView.frame.size.height) - SharedData.bottomSafeAreaHeight - bottomTabBarPad
        
        let configuration = WKWebViewConfiguration()
        //let contentController = WKUserContentController()
        //contentController.add(self, name: "interOp")
        //configuration.userContentController = contentController
        configuration.applicationNameForUserAgent = "MaxPrepsApp" // "MaxPrepsTeamsApp"
        configuration.mediaTypesRequiringUserActionForPlayback = .all
        configuration.allowsInlineMediaPlayback = false
        
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        preferences.isFraudulentWebsiteWarningEnabled = true
        configuration.preferences = preferences
        
        /*
        let webPagePreferences = WKWebpagePreferences()
        webPagePreferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = webPagePreferences
        */
        
        browserView = WKWebView(frame: CGRect(x: 0, y: fakeStatusBar.frame.self.height + navView.frame.size.height, width: kDeviceWidth, height: CGFloat(browserInitialHeight)), configuration: configuration)
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
        
        navContainerView = UIView(frame: CGRect(x: 20, y: Int(fakeStatusBar.frame.size.height) + Int(navView.frame.size.height) + browserInitialHeight - 48, width: 80, height: 32))
        navContainerView.layer.cornerRadius = 16
        navContainerView.layer.borderWidth = 1
        navContainerView.layer.borderColor = UIColor.init(white: 0.67, alpha: 0.9).cgColor
        navContainerView.clipsToBounds = true
        navContainerView.backgroundColor = UIColor.init(white: 0.96, alpha: 0.9)
        self.view.addSubview(navContainerView)
        
        backButton = UIButton(type: .custom)
        backButton.frame = CGRect(x: 0, y: 0, width: 40, height: 32)
        backButton.setImage(UIImage(named: "AccessoryLeftRed"), for: .normal)
        backButton.addTarget(self, action: #selector(browserBackButtonTouched), for: .touchUpInside)
        navContainerView.addSubview(backButton)
        
        //let leftImage = UIImage(named: "ArrowLeftGray")?.withRenderingMode(.alwaysTemplate)
        //backButton.setImage(leftImage, for: .normal)
        //backButton.tintColor = UIColor.mpBlueColor()
        
        forwardButton = UIButton(type: .custom)
        forwardButton.frame = CGRect(x: 40, y: 0, width: 40, height: 32)
        forwardButton.setImage(UIImage(named: "AccessoryRightRed"), for: .normal)
        forwardButton.addTarget(self, action: #selector(browserForwardButtonTouched), for: .touchUpInside)
        navContainerView.addSubview(forwardButton)
        
        //let rightImage = UIImage(named: "ArrowRightGray")?.withRenderingMode(.alwaysTemplate)
        //forwardButton.setImage(rightImage, for: .normal)
        //forwardButton.tintColor = UIColor.mpBlueColor()
    
        navContainerView.isHidden = true
        backButton.alpha = 0.5
        forwardButton.alpha = 0.5
        
        if (self.showLoadingOverlay)
        {
            progressIndicator.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: 6)
            progressIndicator.trackTintColor = .clear
            //progressIndicator.progressTintColor = navColor.darker(by: 10)
            progressIndicator.progressTintColor = navColor
            self.view.addSubview(progressIndicator)
            
            // Use blue for white nav bars
            if (self.navColor == UIColor.mpWhiteColor())
            {
                progressIndicator.progressTintColor = UIColor.mpBlueColor()
            }
            
            browserView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        }
        
        // Add an observer for the app going into the background
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        /*
        // Test code
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = CGRect(x: 0, y: browserView.frame.size.height + browserView.frame.origin.y - 60, width: browserView.frame.size.width, height: 60)
        self.view.addSubview(blurredEffectView)
        */
        
        print(urlString)
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
        if (enableMaxPrepsQueryParameters == true)
        {
            if (urlString.contains("?"))
            {
                urlString = urlString + "&" + kAppIdentifierQueryParam
            }
            else
            {
                urlString = urlString + "?" + kAppIdentifierQueryParam
            }
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
        }
        
        /*
        // Get the response headers
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse
            {
                //print(httpResponse.allHeaderFields)
                let allHeaderFields = httpResponse.allHeaderFields
                let allKeys = allHeaderFields.keys
                
                for key in allKeys
                {
                    print(key)
                }
            }
        }
        .resume()
         
        */

        
        // Initialize the videoBannerView or the regular banner ads based upon the titleString
        if ((titleString == "Box Score") || (titleString == "Preview") || (titleString == "Contest Update"))
        {
            showVideoBanner = true
        }
        
        // Call the contest videos API
        if (showVideoBanner == true)
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
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (videoPlayerVC != nil)
        {
            videoPlayerVC = nil
            
            if (self.autoPopAfterVideoPlayerCloses == true)
            {
                self.navigationController?.popViewController(animated: true)
            }
        }
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
        if (titleColor == UIColor.mpWhiteColor())
        {
            return UIStatusBarStyle.lightContent
        }
        else
        {
            return UIStatusBarStyle.default
        }
    }

    override var shouldAutorotate: Bool
    {
        return self.allowRotation
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation
    {
        return UIInterfaceOrientation.portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        if (self.allowRotation)
        {
            return UIInterfaceOrientationMask.allButUpsideDown
        }
        else
        {
            return .portrait
        }
    }
    
    deinit
    {
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

}
