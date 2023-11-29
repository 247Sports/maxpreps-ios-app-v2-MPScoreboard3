//
//  PBPWebViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/26/23.
//

import UIKit
import WebKit
import GoogleMobileAds
//import MoPubAdapter
import DTBiOSSDK
import AdSupport
import AppTrackingTransparency

class PBPWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate //,WKScriptMessageHandler
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var testButton: UIButton!
    
    var allowRotation = false
    var urlString = ""
    var titleString = ""
    var navColor = UIColor.mpWhiteColor()
    var titleColor = UIColor.mpBlackColor()
    var showScrollIndicators = false
    var showLoadingOverlay = false
    var tabBarVisible = false
    var enableAdobeQueryParameter = false
    var trackingContextData = kEmptyTrackingContextData
    var trackingKey = ""
    
    private var trackingGuid = ""
            
    private var browserView: WKWebView!
    private var progressIndicator: UIProgressView = UIProgressView()
    private var webRefreshControl = UIRefreshControl()
    
    private var browserInitialHeight = 0
    
    private var videoPlayerVC: VideoPlayerViewController!
    
    /*
    // MARK: - WebKit Message Handler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
    {
        // Not used
        print("Script Received")
        //NSDictionary *sentData = (NSDictionary*)message.body;
        //long aCount = [sentData[@"count"] integerValue];
        //aCount++;
        //[wkBrowserView evaluateJavaScript:[NSString stringWithFormat:@"storeAndShow(%ld)", aCount] completionHandler:nil];
    }
    */
    // MARK: - Show Video Player
    
    private func showVideoPlayer(videoId:String)
    {
        videoPlayerVC = VideoPlayerViewController(nibName: "VideoPlayerViewController", bundle: nil)
        videoPlayerVC.videoIdString = videoId
        videoPlayerVC.trackingContextData = self.trackingContextData
        videoPlayerVC.trackingKey = self.trackingKey
        videoPlayerVC.ftag = ""
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
                self.showVideoPlayer(videoId: videoId)
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
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!)
    {
        print("Redirect")
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        completionHandler(.performDefaultHandling, nil)
    }
    
    // MARK: - Button Methods
    
    @IBAction func refreshButtonTouched()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            self.browserView.reload()
        }
    }
    
    @IBAction func testButtonTouched()
    {
        let tabBarController = self.tabBarController as! TabBarController
        tabBarController.hidePlayByPlay()
    }
    
    // MARK: - Pull to Refresh
    
    @objc private func pullToRefresh()
    {
        if (webRefreshControl.isRefreshing == true)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            {
                self.browserView.reload()
                self.webRefreshControl.endRefreshing()
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
            refreshButton.tintColor = UIColor.mpBlackColor()
        }
        else
        {
            refreshButton.tintColor = UIColor.mpWhiteColor()
        }
        
        fakeStatusBar.backgroundColor = navColor
        navView.backgroundColor = navColor
        testButton.setTitleColor(navColor, for: .normal)
                
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
        
        if (self.showLoadingOverlay)
        {
            progressIndicator.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: 6)
            progressIndicator.trackTintColor = .clear
            //progressIndicator.progressTintColor = navColor.darker(by: 10)
            progressIndicator.progressTintColor = UIColor.mpGrayColor()
            self.view.addSubview(progressIndicator)
            
            // Use blue for white nav bars
            if (self.navColor == UIColor.mpWhiteColor())
            {
                progressIndicator.progressTintColor = UIColor.mpBlueColor()
            }
            
            browserView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        }
        
        print(urlString)

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

    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
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
}
