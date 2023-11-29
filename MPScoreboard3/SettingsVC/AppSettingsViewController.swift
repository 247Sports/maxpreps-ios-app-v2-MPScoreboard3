//
//  AppSettingsViewViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/12/23.
//

import UIKit
import AirshipCore

class AppSettingsViewController: UIViewController
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tokenTextView: UITextView!
    
    var logoutTouched = false
    
    private var videoSettingsVC: VideoSettingsViewController!
    private var legalVC: LegalViewController!
    private var updateSchoolsVC: UpdateSchoolsViewController!
    
    private var trackingGuid = ""
    
    // MARK: - Clear User Preferences and Pop
    
    private func clearUserPrefsAndPop()
    {
        // Clear out the user's prefs
        //MiscHelper.logoutUser()
        
        // Set the logoutTouched variable so the profileVC can pop to the root
        self.logoutTouched = true
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Button Methods
    
    @IBAction func backButtontouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
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
  
    @IBAction func updateSchoolsButtontouched(_ sender: UIButton)
    {
        updateSchoolsVC = UpdateSchoolsViewController(nibName: "UpdateSchoolsViewController", bundle: nil)
        self.navigationController?.pushViewController(updateSchoolsVC, animated: true)
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
        self.tabBarController?.tabBar.isHidden = true
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mpBlackColor(), .font: UIFont.mpSemiBoldFontWith(size: kNavBarFontSize)]
        
        setNeedsStatusBarAppearanceUpdate()
        
        if (legalVC != nil)
        {
            if (legalVC.accountDeleted == true)
            {
                // Logout the user
                self.clearUserPrefsAndPop()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
 
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
