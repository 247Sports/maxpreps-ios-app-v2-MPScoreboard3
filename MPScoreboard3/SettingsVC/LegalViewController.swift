//
//  LegalViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/14/22.
//

import UIKit
import OTPublishersHeadlessSDK

class LegalViewController: UIViewController
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var privacyContainerView: UIView!
    @IBOutlet weak var californiaContainerView: UIView!
    @IBOutlet weak var deleteAccountContainerView: UIView!
    
    var accountDeleted = false
    
    private var webVC: WebViewController!
    private var deleteAccountVC: DeleteAccountViewController!
    
    //private let kDoNotSellPolicyUrl = "https://www.viacomcbsprivacy.com/donotsell"
    
    // MARK: - Show Web View Controller
    
    private func showWebViewController(title: String, urlString: String)
    {
        webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC?.titleString = title
        webVC?.urlString = urlString
        webVC?.titleColor = UIColor.mpBlackColor()
        webVC?.navColor = UIColor.mpWhiteColor()
        webVC?.allowRotation = false
        webVC?.showShareButton = false
        webVC?.showScrollIndicators = true
        webVC?.showLoadingOverlay = true
        webVC?.showBannerAd = false
        webVC?.tabBarVisible = false
        webVC?.enableAdobeQueryParameter = true

        self.navigationController?.pushViewController(webVC!, animated: true)
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func privacyButtonTouched(_ sender: UIButton)
    {
        self.showWebViewController(title: "", urlString: kCBSPolicyUrl)
    }
    
    @IBAction func termsButtonTouched(_ sender: UIButton)
    {
        self.showWebViewController(title: "", urlString: kCBSTermsOfUseUrl)
    }
    
    @IBAction func doNotSellButtonTouched(_ sender: UIButton)
    {
        //self.showWebViewController(title: "", urlString: kDoNotSellPolicyUrl)
        OTPublishersHeadlessSDK.shared.showPreferenceCenterUI()
        //OTPublishersHeadlessSDK.shared.showConsentUI(for: .idfa, from: self)
        print("Done")
    }
    
    @IBAction func californiaButtonTouched(_ sender: UIButton)
    {
        self.showWebViewController(title: "", urlString: kCaliforniaNoticeUrl)
    }
    
    @IBAction func deleteAccountButtonTouched(_ sender: UIButton)
    {
        deleteAccountVC = DeleteAccountViewController(nibName: "DeleteAccountViewController", bundle: nil)
        self.navigationController?.pushViewController(deleteAccountVC, animated: true)
        
        // Tracking
        let trackingGuid = NSUUID().uuidString
        TrackingManager.trackState(featureName: "delete-my-account", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        containerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height)
        
        // Added in V6.3.1
        if (MiscHelper.isUserMinorAged() == true)
        {
            // Hide the privacy container and shift the Ca and delete account containers up
            privacyContainerView.isHidden = true
            californiaContainerView.frame.origin = CGPoint(x: 0, y: californiaContainerView.frame.origin.y - 48.0)
            deleteAccountContainerView.frame.origin = CGPoint(x: 0, y: deleteAccountContainerView.frame.origin.y - 48.0)
        }
        
        // Hide te delete account if the user is a guest
        if (kUserDefaults.string(forKey: kUserIdKey) == kTestDriveUserId)
        {
            deleteAccountContainerView.isHidden = true
        }
        
        // Initialize the OneTrust UI
        //OTPublishersHeadlessSDK.shared.setupUI(self, UIType: .banner)
        OTPublishersHeadlessSDK.shared.setupUI(self, UIType: .preferenceCenter)
        print("Done")
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
        
        if (deleteAccountVC != nil)
        {
            self.accountDeleted = deleteAccountVC.accountDeleted
            
            if (self.accountDeleted == true)
            {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (webVC != nil)
        {
            webVC = nil
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.default
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
}
