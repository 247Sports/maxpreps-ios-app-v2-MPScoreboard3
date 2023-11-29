//
//  NewAthleteSearchViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/15/23.
//

import UIKit

class NewAthleteSearchViewController: UIViewController, AthleteSearchViewDelegate, ClaimProfileAlertViewDelegate, ClaimProfileSuccessAlertViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    
    var athleteClaimed = false
    var existingClaimedCareers: Array<String> = []
    var userProfileType: String = ""
    
    private var selectedCareerId = ""
    private var athleteSearchView: AthleteSearchView!
    private var claimProfileAlertView: ClaimProfileAlertView!
    private var claimProfileSuccessAlertView: ClaimProfileSuccessAlertView!
    private var webVC: WebViewController!
    private var progressOverlay: ProgressHUD!
    
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
        webVC.showShareButton = false
        webVC.showScrollIndicators = false
        webVC.showLoadingOverlay = true
        webVC.showBannerAd = false
        webVC.tabBarVisible = false
        webVC.enableAdobeQueryParameter = true

        self.navigationController?.pushViewController(webVC, animated: true)
        //self.hidesBottomBarWhenPushed = false
    }
    
    // MARK: - ClaimProfileAlertView Delegate
    
    func closeClaimProfileAlertAfterAthleteSelectButtonTouched()
    {
        claimProfileAlertView.removeFromSuperview()
        claimProfileAlertView = nil
        
        // Click Tracking
        let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"claim-athlete", kClickTrackingModuleNameKey: "user preferences", kClickTrackingModuleLocationKey:"claim athlete prompt", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:"This is me"]
        
        TrackingManager.trackEvent(featureName: "claim-pop-up", cData: cData)
        
        NewFeeds.getAthleteClaimEligibility(careerId: self.selectedCareerId) { (result, error) in
            
            if error == nil
            {
                print("Get athlete claim eligibility success.")
                let athleteIsEligible = result!["isEligibleForAthleteClaim"] as! Bool
                
                if (athleteIsEligible == true)
                {
                    // Show the busy indicator
                    //MBProgressHUD.showAdded(to: self.view, animated: true)
                    if (self.progressOverlay == nil)
                    {
                        self.progressOverlay = ProgressHUD()
                        self.progressOverlay.show(animated: false)
                    }
                    
                    NewFeeds.claimCareerProfile(careerId: self.selectedCareerId, relationship: "Athlete") { error in
                        
                        // Hide the busy indicator
                        DispatchQueue.main.async
                        {
                            //MBProgressHUD.hide(for: self.view, animated: true)
                            if (self.progressOverlay != nil)
                            {
                                self.progressOverlay.hide(animated: false)
                                self.progressOverlay = nil
                            }
                        }
                        
                        if (error == nil)
                        {
                            print("Claim career profile success.")
                            
                            // Add some delay so the ClaimProfileAlertView can dismiss
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                            { [self] in
         
                                // Show the new success popup
                                self.athleteClaimed = true
                                
                                self.showClaimProfileSuccessView()

                            }
                        }
                        else
                        {
                            print("Claim career profile failed.")
                                                        
                            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to claim this athlete.", lastItemCancelType: false) { tag in
                                
                            }
                            
                            // Click Tracking
                            let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"claim-athlete", kClickTrackingModuleNameKey: "user preferences", kClickTrackingModuleLocationKey:"claim athlete error", kClickTrackingModuleActionKey: "impression", kClickTrackingClickTextKey:"athlete claim error"]
                            
                            TrackingManager.trackEvent(featureName: "claim-pop-up-error", cData: cData)
                        }
                    }
                }
                else
                {
                    let reason = result!["ineligibleForAthleteClaimReason"] as! String
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: reason, lastItemCancelType: false) { (tag) in
                    }
                }
            }
            else
            {
                print("Get athlete claim eligibility failed.")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong while determining if this athlete could be claimed.", lastItemCancelType: false) { (tag) in
                }
            }
        }
    }
    
    func closeClaimProfileAlertAfterParentSelectButtonTouched()
    {
        claimProfileAlertView.removeFromSuperview()
        claimProfileAlertView = nil
        
        // Click Tracking
        let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"claim-athlete", kClickTrackingModuleNameKey: "user preferences", kClickTrackingModuleLocationKey:"claim athlete prompt", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:"This is my child"]
        
        TrackingManager.trackEvent(featureName: "claim-pop-up", cData: cData)
        
        NewFeeds.getAthleteClaimEligibility(careerId: self.selectedCareerId) { (result, error) in
            
            if error == nil
            {
                print("Get athlete claim eligibility success.")
                let athleteIsEligible = result!["isEligibleForParentClaim"] as! Bool
                
                if (athleteIsEligible == true)
                {
                    // Show the busy indicator
                    //MBProgressHUD.showAdded(to: self.view, animated: true)
                    if (self.progressOverlay == nil)
                    {
                        self.progressOverlay = ProgressHUD()
                        self.progressOverlay.show(animated: false)
                    }
                    
                    NewFeeds.claimCareerProfile(careerId: self.selectedCareerId, relationship: "Parent") { error in
                        
                        // Hide the busy indicator
                        DispatchQueue.main.async
                        {
                            //MBProgressHUD.hide(for: self.view, animated: true)
                            if (self.progressOverlay != nil)
                            {
                                self.progressOverlay.hide(animated: false)
                                self.progressOverlay = nil
                            }
                        }
                        
                        if (error == nil)
                        {
                            print("Claim career profile success.")
                            
                            // Add some delay so the ClaimProfileAlertView can dismiss
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                            { [self] in
         
                                // Show the new success popup
                                self.athleteClaimed = true
                                
                                self.showClaimProfileSuccessView()

                            }
                        }
                        else
                        {
                            print("Claim career profile failed.")
                                                        
                            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to claim this athlete.", lastItemCancelType: false) { tag in
                                
                            }
                            
                            // Click Tracking
                            let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"claim-athlete", kClickTrackingModuleNameKey: "user preferences", kClickTrackingModuleLocationKey:"claim athlete error", kClickTrackingModuleActionKey: "impression", kClickTrackingClickTextKey:"parent claim error"]
                            
                            TrackingManager.trackEvent(featureName: "claim-pop-up-error", cData: cData)
                        }
                    }
                }
                else
                {
                    let reason = result!["ineligibleForParentClaimReason"] as! String
                    let reasonType = result!["parentClaimIneligibilityType"] as? Int ?? -1 // Newer version of the feed
                    if (reasonType != -1)
                    {
                        if (reasonType == 3)
                        {
                            // Point the user to the app settings to change his role to parent
                            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Update Your Role", message: "Go to your Account Info to select the correct role for yourself", lastItemCancelType: false) { (tag) in
                            }
                        }
                        else
                        {
                            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: reason, lastItemCancelType: false) { (tag) in
                            }
                        }
                    }
                    else
                    {
                        if (reason == "User type is athlete.")
                        {
                            // Point the user to the app settings to change his role to parent
                            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Update Your Role", message: "Go to your Account Info to select the correct role for yourself", lastItemCancelType: false) { (tag) in
                            }
                        }
                        else
                        {
                            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: reason, lastItemCancelType: false) { (tag) in
                            }
                        }
                    }
                }
            }
            else
            {
                print("Get athlete claim eligibility failed.")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong while determining if this athlete could be claimed.", lastItemCancelType: false) { (tag) in
                }
            }
        }
    }
    
    func closeClaimProfileAlertAfterCancelButtonTouched()
    {
        claimProfileAlertView.removeFromSuperview()
        claimProfileAlertView = nil
    }
    
    // MARK: - ClaimProfileSuccessAlertView Methods
    
    private func showClaimProfileSuccessView()
    {
        if (claimProfileSuccessAlertView != nil)
        {
            claimProfileSuccessAlertView.removeFromSuperview()
            claimProfileSuccessAlertView = nil
        }
                
        var message = ""
        
        if (userProfileType == "Athlete") || (userProfileType == "Fan")
        {
            message = "We need to refresh your app in order to view your newly claimed profile."
        }
        claimProfileSuccessAlertView = ClaimProfileSuccessAlertView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight), message: message)
        claimProfileSuccessAlertView.delegate = self

        kAppKeyWindow.rootViewController!.view.addSubview(claimProfileSuccessAlertView)
    }
    
    func closeClaimProfileSuccessAlertAfterDoneButtonTouched()
    {
        claimProfileSuccessAlertView.removeFromSuperview()
        claimProfileSuccessAlertView = nil
        
        // Return to the Claimed Profile Page
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - AthleteSearchView Delegate
    
    func athleteSearchDidSelectAthlete(selectedAthlete: Athlete, showSaveFavoriteButton: Bool, showRemoveFavoriteButton: Bool)
    {
        selectedCareerId = selectedAthlete.careerId
        
        // Check if the user is picking himself
        //if (self.userCareerId == selectedCareerId)
        if (self.existingClaimedCareers.contains(selectedCareerId))
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Duplicate Claim", message: "You can not claim an athlete more than once.", lastItemCancelType: false) { tag in
                
            }
            return
        }
        
        // Show a confirmation alert
        if (claimProfileAlertView != nil)
        {
            claimProfileAlertView.removeFromSuperview()
            claimProfileAlertView = nil
        }
        
        let name = selectedAthlete.firstName + " " + selectedAthlete.lastName
        
        var showParentOnly = false
        
        if ((self.userProfileType == "Athlete") || (self.userProfileType == "Parent") || (self.userProfileType == "AD"))
        {
            showParentOnly = true
        }
        
        claimProfileAlertView = ClaimProfileAlertView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight), color: UIColor.mpRedColor(), name: name, parentOnly: showParentOnly)
        claimProfileAlertView.delegate = self

        kAppKeyWindow.rootViewController!.view.addSubview(claimProfileAlertView)
        
        // Click Tracking
        let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"claim-athlete", kClickTrackingModuleNameKey: "user preferences", kClickTrackingModuleLocationKey:"claim athlete prompt", kClickTrackingModuleActionKey: "impression", kClickTrackingClickTextKey:""]
        
        TrackingManager.trackEvent(featureName: "claim-pop-up", cData: cData)
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.athleteClaimed = false
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func helpButtonTouched()
    {
        self.showWebViewController(urlString: kTechSupportUrl, title: "Support")
    }
    
    @IBAction func testButtonTouched(_ sender: UIButton)
    {
        self.showClaimProfileSuccessView()
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Size the fakeStatusBar, navBar, and searchView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        
        // Shift the button up on devices with a home button
        var shift = 0.0
        if (SharedData.bottomSafeAreaHeight == 0)
        {
            shift = 20.0
        }
        
        let helpButton = UIButton(type: .system)
        helpButton.frame = CGRect(x: (kDeviceWidth - 151.0) / 2.0, y: kDeviceHeight - CGFloat(SharedData.bottomSafeAreaHeight) - 30.0 - shift, width: 151.0, height: 30.0)
        helpButton.titleLabel?.font = UIFont.mpRegularFontWith(size: 14)
        helpButton.addTarget(self, action: #selector(helpButtonTouched), for: .touchUpInside)
        helpButton.setTitleColor(UIColor.mpBlueColor(), for: .normal)
        
        self.view.addSubview(helpButton)
   
        athleteSearchView = AthleteSearchView(frame: CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: CGFloat(kDeviceWidth), height: CGFloat(kDeviceHeight) - navView.frame.size.height - fakeStatusBar.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight) - helpButton.frame.size.height - 20 - shift))
        athleteSearchView.delegate = self
        athleteSearchView.backgroundColor = UIColor.mpWhiteColor()
        self.view.addSubview(athleteSearchView)
        
        //let buttonText = "Don't see your child?"
        let buttonText = "Can't find an athlete?"
        let attributedString = NSMutableAttributedString(string: buttonText, attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 14), NSAttributedString.Key.foregroundColor: UIColor.mpBlueColor()])
        
        helpButton.setAttributedTitle(attributedString, for: .normal)
        
        let trackingGuid = NSUUID().uuidString
        TrackingManager.trackState(featureName: "search-athletes", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
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
