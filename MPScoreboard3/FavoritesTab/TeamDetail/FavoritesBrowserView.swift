//
//  FavoritesBrowserView.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/13/21.
//

import UIKit
import WebKit

protocol FavoritesBrowserViewDelegate: AnyObject
{
    func favoritesBrowserVideoButtonTouched(videoId: String)
    func favoritesBrowserViewDidScroll(_ yScroll : Int)
}

class FavoritesBrowserView: UIView, WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate
{
    weak var delegate: FavoritesBrowserViewDelegate?
    
    private var browserView: WKWebView = WKWebView()
    private var progressIndicator: UIProgressView = UIProgressView()
    private var navContainerView : UIView!
    private var backButton: UIButton!
    private var forwardButton: UIButton!
    
    private let kIndicatorHeight = 20
    
    // MARK: - Load URL Method
    
    func loadUrl(_ urlString: String, progressColor: UIColor)
    {
        progressIndicator.progressTintColor = progressColor
        
        let url = URL(string: urlString)!
        browserView.load(URLRequest(url: url))
    }
    
    // MARK: - Browser UI Delegate
    
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
            //print("Decide Policy for URL: " + urlString);
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
                self.delegate!.favoritesBrowserVideoButtonTouched(videoId: videoId)
                return
            }
        }
        
        //print("Allowed")
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!)
    {
        print("Did Commit")
                
        // Deadman timer for the progressIndicator
        DispatchQueue.main.asyncAfter(deadline: .now() + 3)
        { [self] in
            self.progressIndicator.setProgress(0.0, animated: false)
            
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        print("Did Finish")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
        { [self] in
            self.progressIndicator.setProgress(0.0, animated: false)
            
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
        { [self] in
            self.progressIndicator.setProgress(0.0, animated: false)

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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
        { [self] in
            self.progressIndicator.setProgress(0.0, animated: false)

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

    // MARK: - Nav Button Methods
    
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
    
    // MARK: - Progress Indicator Observer
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if (keyPath == "estimatedProgress")
        {
            progressIndicator.setProgress(Float(browserView.estimatedProgress), animated: true)
            print(browserView.estimatedProgress)
        }
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        self.delegate?.favoritesBrowserViewDidScroll(Int(scrollView.contentOffset.y))
    }
    
    // MARK: - Update Frame Method
    
    func updateFrame(_ frame: CGRect)
    {
        self.frame = frame
        browserView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        navContainerView.frame = CGRect(x: 20, y: frame.size.height - 48, width: 80, height: 32)
    }
    
    // MARK: - Init Method
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        // UIViews don't clip to bounds automatically
        self.clipsToBounds = true
        
        browserView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        browserView.navigationDelegate = self
        browserView.uiDelegate = self
        browserView.scrollView.bounces = false
        browserView.scrollView.delegate = self
        self.addSubview(browserView)
        
        progressIndicator.frame = CGRect(x: 0, y: 0, width: kDeviceWidth, height: 6)
        progressIndicator.trackTintColor = .clear
        self.addSubview(progressIndicator)
            
        browserView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)

        
        navContainerView = UIView(frame: CGRect(x: 20, y: frame.size.height - 48, width: 80, height: 32))
        navContainerView.layer.cornerRadius = 16
        navContainerView.layer.borderWidth = 1
        navContainerView.layer.borderColor = UIColor.init(white: 0.67, alpha: 0.9).cgColor
        navContainerView.clipsToBounds = true
        navContainerView.backgroundColor = UIColor.init(white: 0.96, alpha: 0.9)
        self.addSubview(navContainerView)
        
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
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
