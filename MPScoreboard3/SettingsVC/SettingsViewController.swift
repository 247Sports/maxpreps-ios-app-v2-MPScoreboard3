//
//  SettingsViewViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/13/22.
//

import UIKit
import AirshipCore

class SettingsViewController: UIViewController
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var footerLabel: UILabel!
    
    @IBOutlet weak var tokenTextView: UITextView!
    
    var logoutTouched = false
    var showSignOutButton = true
    
    private var webVC: WebViewController!
    private var videoSettingsVC: VideoSettingsViewController!
    private var legalVC: LegalViewController!
    private var updateSchoolsVC: UpdateSchoolsViewController!
    
    private var trackingGuid = ""
    
    // MARK: - Clear User Preferences and Pop
    
    private func clearUserPrefsAndDismiss()
    {
        // Clear out the user's prefs
        MiscHelper.logoutUser()
        
        // Set the logoutTouched variable so the profileVC can pop to the root
        self.logoutTouched = true
        
        self.presentingViewController?.dismiss(animated: true, completion:
        {
            
        })
    }

    // MARK: - Button Methods
    
    @IBAction func closeButtontouched(_ sender: UIButton)
    {
        self.presentingViewController?.dismiss(animated: true, completion:
        {
            
        })
    }
    
    @IBAction func videoSettingsButtontouched(_ sender: UIButton)
    {
        videoSettingsVC = VideoSettingsViewController(nibName: "VideoSettingsViewController", bundle: nil)
        self.navigationController?.pushViewController(videoSettingsVC, animated: true)
    }
    
    @IBAction func legalButtontouched(_ sender: UIButton)
    {
        legalVC = LegalViewController(nibName: "LegalViewController", bundle: nil)
        self.navigationController?.pushViewController(legalVC, animated: true)
    }
    
    @IBAction func supportButtontouched(_ sender: UIButton)
    {
        webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC?.titleString = "Support"
        webVC?.urlString = kTechSupportUrl
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
    
    @IBAction func updateSchoolsButtontouched(_ sender: UIButton)
    {
        updateSchoolsVC = UpdateSchoolsViewController(nibName: "UpdateSchoolsViewController", bundle: nil)
        self.navigationController?.pushViewController(updateSchoolsVC, animated: true)
    }
    
    @IBAction func logoutButtontouched(_ sender: UIButton)
    {
        // Just Logout if a test drive user
        if (kUserDefaults .string(forKey: kUserIdKey) == kTestDriveUserId)
        {
            self.clearUserPrefsAndDismiss()
            
            // Click Tracking
            let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"sign-out-button-click", kClickTrackingModuleNameKey: "sign-out", kClickTrackingModuleLocationKey:"settings home", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:""]
            
            TrackingManager.trackEvent(featureName: "sign-out", cData: cData)
            
            return
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Sign Out", style: .destructive, handler: { [self] action in
            
            alert.dismiss(animated: true) { [self] in
                
                self.clearUserPrefsAndDismiss()
                
                // Click Tracking
                let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"sign-out-button-click", kClickTrackingModuleNameKey: "sign-out", kClickTrackingModuleLocationKey:"settings home", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:""]
                
                TrackingManager.trackEvent(featureName: "sign-out", cData: cData)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { action in
            
        })
        
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        
        alert.modalPresentationStyle = .fullScreen
        present(alert, animated: true)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        trackingGuid = NSUUID().uuidString
                
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        containerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height)
        
        var buttonText = "Sign Out"
        if (kUserDefaults.string(forKey: kUserIdKey) == kTestDriveUserId)
        {
            buttonText = "Sign In or Join Now"
        }
        
        //let attributedString = NSMutableAttributedString(string: buttonText, attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 17), NSAttributedString.Key.foregroundColor: UIColor.mpBlackColor()])
        let attributedString = NSMutableAttributedString(string: buttonText, attributes: [NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 17), NSAttributedString.Key.foregroundColor: UIColor.mpBlackColor()])
        
        logoutButton.setAttributedTitle(attributedString, for: .normal)
        
        if (self.showSignOutButton == false)
        {
            logoutButton.isHidden = true
        }
        
        // Load the titleLabel
        if (kUserDefaults.object(forKey: kServerModeKey) as! String == kServerModeBranch)
        {
            let branchValue = kUserDefaults.object(forKey: kBranchValue) as! String
            titleLabel.text = "Branch-" + branchValue + " Server"
        }
        else if (kUserDefaults.object(forKey: kServerModeKey) as! String == kServerModeDev)
        {
            titleLabel.text = "Dev Server"
        }
        else if (kUserDefaults.object(forKey: kServerModeKey) as! String == kServerModeStaging)
        {
            titleLabel.text = "Staging Server"
        }
        else
        {
            titleLabel.text = ""
        }
        
        //Copyright 2015-2022, CBS Interactive Inc.\nAll Rights Reserved.
        // Add some app information
        let shortVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let version = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let currentYear = dateFormatter.string(from: Date())
        
        let iosVersion = ProcessInfo().operatingSystemVersion
        
        footerLabel.text = String(format: "App Version: %@ (build %@)\niOS version: %@.%@.%@\n\nCopyright 2015-%@, CBS Interactive Inc.\nAll Rights Reserved.", shortVersion, version, String(iosVersion.majorVersion), String(iosVersion.minorVersion), String(iosVersion.patchVersion), currentYear)
        
        if (kUserDefaults.bool(forKey: kDebugDialogsKey) == true)
        {
            let identifier = Airship.channel.identifier!
            let text = String(format: "%@, %@", identifier, SharedData.deviceToken)
            
            tokenTextView.text = text
        }
        else
        {
            tokenTextView.text = ""
        }
        
        // Tracking
        TrackingManager.trackState(featureName: "app-settings", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
        
        if (legalVC != nil)
        {
            if (legalVC.accountDeleted == true)
            {
                // Logout the user
                self.clearUserPrefsAndDismiss()
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
        
        if (videoSettingsVC != nil)
        {
            videoSettingsVC = nil
        }
        
        if (legalVC != nil)
        {
            legalVC = nil
        }
        
        if (updateSchoolsVC != nil)
        {
            updateSchoolsVC = nil
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
