//
//  NewGuestProfileViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 7/20/23.
//

import UIKit
import AVFoundation

class NewGuestProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
        
    private var webVC: WebViewController!
    private var appSettingsVC: AppSettingsViewController!
    
    private var settingsHeaderView: ProfilesAndTeamsHeaderViewCell?
    private var helpHeaderView: ProfilesAndTeamsHeaderViewCell?
    
    private var profileData = [:] as Dictionary<String,Any>
    private var trackingGuid = ""
    
    // MARK: - Show Settings View Controller
    
    private func showSettingsViewController()
    {
        appSettingsVC = AppSettingsViewController(nibName: "AppSettingsViewController", bundle: nil)
        self.navigationController?.pushViewController(appSettingsVC, animated: true)
    }
    
    // MARK: - Show Web View Controller
    
    private func showWebViewController(urlString: String, title: String)
    {
        self.hidesBottomBarWhenPushed = true
        
        webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC.titleString = title
        webVC.urlString = urlString
        webVC.titleColor = UIColor.mpBlackColor()
        webVC.navColor = UIColor.mpWhiteColor()
        webVC.allowRotation = false
        webVC.showShareButton = true
        webVC.showScrollIndicators = false
        webVC.showLoadingOverlay = true
        webVC.showBannerAd = false
        webVC.tabBarVisible = false
        webVC.enableAdobeQueryParameter = true

        self.navigationController?.pushViewController(webVC, animated: true)
        //self.hidesBottomBarWhenPushed = false
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if ((section == 0) || (section == 1) || (section == 3))
        {
            return 1
        }
        else
        {
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if ((indexPath.section == 0) || (indexPath.section == 1) || (indexPath.section == 2))
        {
            return 48.0
        }
        else
        {
            return 120.0 // This shortens the cell to hide the sign out button
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if ((section == 1) || (section == 2))
        {
            return 50.0
        }
        else
        {
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (section == 3)
        {
            return  120.0
        }
        else
        {
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (section == 1)
        {
            let view = UIView()
            view.addSubview(settingsHeaderView!)
            return view
        }
        else if (section == 2)
        {
            let view = UIView()
            view.addSubview(helpHeaderView!)
            return view
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        if (section == 3)
        {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 120))
            view.backgroundColor = UIColor.mpHeaderBackgroundColor()
            
            let footerLabel = UILabel(frame: CGRect(x: 16, y: 10, width: kDeviceWidth - 32, height: 90))
            footerLabel.font = UIFont.mpRegularFontWith(size: 13)
            footerLabel.textColor = UIColor.mpDarkGrayColor()
            footerLabel.textAlignment = .center
            footerLabel.numberOfLines = 5
            view.addSubview(footerLabel)
            
            // Add some app information
            let shortVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            let version = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            let currentYear = dateFormatter.string(from: Date())
            
            let iosVersion = ProcessInfo().operatingSystemVersion
            
            footerLabel.text = String(format: "App Version: %@ (build %@)\niOS version: %@.%@.%@\n\nCopyright 2015-%@, CBS Interactive Inc.\nAll Rights Reserved.", shortVersion, version, String(iosVersion.majorVersion), String(iosVersion.minorVersion), String(iosVersion.patchVersion), currentYear)
            
            return view
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (indexPath.section == 0)
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "NewProfileSignInTableViewCell") as? NewProfileSignInTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("NewProfileSignInTableViewCell", owner: self, options: nil)
                cell = nib![0] as? NewProfileSignInTableViewCell
            }
            
            cell?.selectionStyle = .none
            
            return cell!
        }
        
        else if (indexPath.section == 1)
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "NewProfileShortTableViewCell") as? NewProfileShortTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("NewProfileShortTableViewCell", owner: self, options: nil)
                cell = nib![0] as? NewProfileShortTableViewCell
            }
            
            cell?.selectionStyle = .none
            cell?.titleLabel.text = "App Settings"
            cell?.iconImageView.image = UIImage(named: "NewAppSettingsIcon")
            
            return cell!

        }
        else if (indexPath.section == 2)
        {
            if (indexPath.row == 0)
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "NewProfileShortTableViewCell") as? NewProfileShortTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("NewProfileShortTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? NewProfileShortTableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.titleLabel.text = "Support"
                cell?.iconImageView.image = UIImage(named: "NewSupportIcon")
                
                return cell!
            }
            else if (indexPath.row == 1)
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "NewProfileShortTableViewCell") as? NewProfileShortTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("NewProfileShortTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? NewProfileShortTableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.titleLabel.text = "Send Feedback"
                cell?.iconImageView.image = UIImage(named: "NewFeedbackIcon")
                
                return cell!
            }
            else
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "NewProfileSpecialTableViewCell") as? NewProfileSpecialTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("NewProfileSpecialTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? NewProfileSpecialTableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.titleLabel.text = "Special Offers"
                cell?.iconImageView.image = UIImage(named: "NewSpecialOffersIcon")
                
                return cell!
            }
        }
        else
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "NewProfileSocialTableViewCell") as? NewProfileSocialTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("NewProfileSocialTableViewCell", owner: self, options: nil)
                cell = nib![0] as? NewProfileSocialTableViewCell
            }
            
            cell?.selectionStyle = .none
            
            cell?.twitterButton.addTarget(self, action: #selector(twitterButtonTouched), for: .touchUpInside)
            cell?.facebookButton.addTarget(self, action: #selector(facebookButtonTouched), for: .touchUpInside)
            cell?.youTubeButton.addTarget(self, action: #selector(youTubeButtonTouched), for: .touchUpInside)
            cell?.tikTokButton.addTarget(self, action: #selector(tikTokButtonTouched), for: .touchUpInside)
            cell?.instagramButton.addTarget(self, action: #selector(instagramButtonTouched), for: .touchUpInside)
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
            
        if (indexPath.section == 0) // Sign out
        {
            self.signoutButtonTouched()
        }
        else if (indexPath.section == 1) // Settings section
        {
            self.showSettingsViewController()
        }
        else if (indexPath.section == 2) // Help section
        {
            if (indexPath.row == 0)
            {
                self.showWebViewController(urlString: kTechSupportUrl, title: "Support")
            }
            else
            {
                self.showWebViewController(urlString: "https://support.maxpreps.com/hc/en-us/requests/new?ticket_form_id=14520918612635", title: "Send Feedback")
            }
        }
    }
    
    // MARK: - Clear User Prefs and Dismiss
    
    private func clearUserPrefsAndDismiss()
    {
        // Clear out the user's prefs
        MiscHelper.logoutUser()
 
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
        {
            NotificationCenter.default.post(name: Notification.Name("Logout"), object: self, userInfo: nil)
        }
        
        self.dismiss(animated: true)
    }
    
    // MARK: - Button Methods
   
    @IBAction func closeButtontouched(_ sender: UIButton)
    {
        self.dismiss(animated: true)
    }
    
    @objc private func signoutButtonTouched()
    {
        self.clearUserPrefsAndDismiss()
        
        // Click Tracking
        let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"sign-out-button-click", kClickTrackingModuleNameKey: "sign-out", kClickTrackingModuleLocationKey:"settings home", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:""]
        
        TrackingManager.trackEvent(featureName: "sign-out", cData: cData)
    }
    
    @objc private func twitterButtonTouched()
    {
        self.showWebViewController(urlString: kMaxPrepsTwitterUrl, title: "X")
    }
    
    @objc private func facebookButtonTouched()
    {
        self.showWebViewController(urlString: kMaxPrepsFacebookUrl, title: "Facebook")
    }
    
    @objc private func youTubeButtonTouched()
    {
        self.showWebViewController(urlString: kMaxPrepsYouTubeUrl, title: "YouTube")
    }
    
    @objc private func tikTokButtonTouched()
    {
        self.showWebViewController(urlString: kMaxPrepsTikTokUrl, title: "TikTok")
    }
    
    @objc private func instagramButtonTouched()
    {
        self.showWebViewController(urlString: kMaxPrepsInstagramUrl, title: "Instagram")
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        trackingGuid = NSUUID().uuidString

        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        profileTableView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height)
        profileTableView.contentInsetAdjustmentBehavior = .never
        profileTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -20.0, right: 0)
        
        let settingsNib = Bundle.main.loadNibNamed("ProfilesAndTeamsHeaderViewCell", owner: self, options: nil)
        settingsHeaderView = settingsNib![0] as? ProfilesAndTeamsHeaderViewCell
        settingsHeaderView?.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 50)
        settingsHeaderView?.titleLabel.text = "Settings"
        
        let helpNib = Bundle.main.loadNibNamed("ProfilesAndTeamsHeaderViewCell", owner: self, options: nil)
        helpHeaderView = helpNib![0] as? ProfilesAndTeamsHeaderViewCell
        helpHeaderView?.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 50)
        helpHeaderView?.titleLabel.text = "Help"
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
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
        
        // This is added to reset the background when returning from the VCs
        kAppKeyWindow.rootViewController!.view.backgroundColor = UIColor.mpWhiteColor()
        
        self.tabBarController?.tabBar.isHidden = true
    
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (webVC != nil)
        {
            webVC = nil
        }
        
        // Pop the nav to the root if the user logged out
        if (appSettingsVC != nil)
        {
            let logout = appSettingsVC?.logoutTouched
            if (logout == true)
            {
                //self.navigationController?.popToRootViewController(animated: false)
                self.clearUserPrefsAndDismiss()
            }
        }
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
