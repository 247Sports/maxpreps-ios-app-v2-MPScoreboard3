//
//  ClaimAthleteSearchViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/24/22.
//

import UIKit

class ClaimAthleteSearchViewController: UIViewController, ClaimAthleteSearchViewDelegate, ClaimProfileAlertViewDelegate, OnboardingAlertViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dontSeeYourselfButton: UIButton!
    
    var userIsAthlete = false
    
    private var selectedAthleteCareerId = ""
    private var selectedAthleteFirstName = ""
    private var selectedAthleteLastName = ""
    
    private var athleteSearchView: ClaimAthleteSearchView!
    private var webVC: WebViewController!
    private var claimProfileAlertView: ClaimProfileAlertView!
    private var onboardingAlertView: OnboardingAlertView!
    
    private var claimAthleteSuccessVC: ClaimAthleteSuccessViewController!
    private var progressOverlay: ProgressHUD!
    private var trackingGuid = ""
    
    // MARK: - Show ClaimAthleteSuccess View Controller
    
    private func showClaimAthleteSuccessViewController(schoolColor: UIColor)
    {
        if (claimAthleteSuccessVC != nil)
        {
            claimAthleteSuccessVC = nil
        }
        
        claimAthleteSuccessVC = ClaimAthleteSuccessViewController(nibName: "ClaimAthleteSuccessViewController", bundle: nil)
        claimAthleteSuccessVC.userIsAthlete = self.userIsAthlete
        claimAthleteSuccessVC.athleteFirstName = selectedAthleteFirstName
        claimAthleteSuccessVC.athleteLastName = selectedAthleteLastName
        claimAthleteSuccessVC.schoolColor = schoolColor
        //claimAthleteSuccessVC.searchVC = self
        
        self.navigationController?.pushViewController(claimAthleteSuccessVC, animated: true)
    }
    
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
    
    // MARK: - Get User Favorite Teams
    
    private func getUserFavoriteTeams()
    {
        // Show the busy indicator
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.getUserFavoriteTeams { error in
            
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
                // Use the color from the first school in the favorites list
                let userFavoriteTeams = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
                if (userFavoriteTeams!.count > 0)
                {
                    let firstFavoriteTeam = userFavoriteTeams!.first as! Dictionary<String,Any>
                    let schoolColor1String = firstFavoriteTeam[kNewSchoolColor1Key] as? String ?? "808080"
                    let schoolColor1 = ColorHelper.color(fromHexString: schoolColor1String, colorCorrection: true)
                    
                    // Show the claimAthleteSuccessVC
                    self.showClaimAthleteSuccessViewController(schoolColor: schoolColor1!)
                }
            }
            else
            {
                self.showOnboardingMessage(title: "We're Sorry", message: "Something went wrong when trying to retrieve your favorite teams.", topButtonTitle: "OKAY", bottomButtonTitle: "")
            }
        }
    }
    
    // MARK: - Show Onboarding Message
    
    private func showOnboardingMessage(title: String, message: String, topButtonTitle: String, bottomButtonTitle: String)
    {
        if (onboardingAlertView != nil)
        {
            onboardingAlertView.removeFromSuperview()
            onboardingAlertView = nil
        }
        
        onboardingAlertView = OnboardingAlertView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight), color: UIColor.mpRedColor(), title: title, message: message, topButtonTitle: topButtonTitle, bottomButtonTitle: bottomButtonTitle)
        onboardingAlertView.delegate = self
        
        self.view.addSubview(onboardingAlertView)
    }
    
    // MARK: - OnboardingAlertView Delegate
    
    func closeOnboardingAlertAfterTopButtonTouched()
    {
        onboardingAlertView.removeFromSuperview()
        onboardingAlertView = nil
    }
    
    func closeOnboardingAlertAfterBottomButtonTouched()
    {
        onboardingAlertView.removeFromSuperview()
        onboardingAlertView = nil
        
        self.showWebViewController(title: "Support", urlString: kTechSupportUrl)
    }
    
    func closeOnboardingAlertAfterCancelButtonTouched()
    {
        onboardingAlertView.removeFromSuperview()
        onboardingAlertView = nil
    }
    
    // MARK: - ClaimProfileAlertView Delegate
    
    func closeClaimProfileAlertAfterAthleteSelectButtonTouched()
    {
        claimProfileAlertView.removeFromSuperview()
        claimProfileAlertView = nil
        
        // Click Tracking
        let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"claim-athlete", kClickTrackingModuleNameKey: "user preferences", kClickTrackingModuleLocationKey:"claim athlete prompt", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:"Yes this is me"]
        
        TrackingManager.trackEvent(featureName: "claim-pop-up", cData: cData)

        NewFeeds.getAthleteClaimEligibility(careerId: self.selectedAthleteCareerId) { (result, error) in
            
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
                    
                    NewFeeds.claimCareerProfile(careerId: self.selectedAthleteCareerId, relationship: "Athlete") { error in
                        
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
                                
                                // Get user favorite teams
                                self.getUserFavoriteTeams()
                            }
                        }
                        else
                        {
                            print("Claim career profile failed.")
                             
                            self.showOnboardingMessage(title: "We're Sorry", message: "Something went wrong when trying to claim this athlete.", topButtonTitle: "OKAY", bottomButtonTitle: "")
                            
                            // Click Tracking
                            let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"claim-athlete", kClickTrackingModuleNameKey: "user preferences", kClickTrackingModuleLocationKey:"claim athlete error", kClickTrackingModuleActionKey: "impression", kClickTrackingClickTextKey:"athlete claim error"]
                            
                            TrackingManager.trackEvent(featureName: "claim-pop-up-error", cData: cData)
                        }
                    }
                }
                else
                {
                    //let reason = result!["ineligibleForAthleteClaimReason"] as! String
                    let reasonType = result!["athleteClaimIneligibilityType"] as? Int ?? -1 // Newer version of the feed
                    
                    var title = ""
                    var message = ""
                    let topButtonTitle = "OKAY"
                    var bottomButtonTitle = ""
    
                    /*
                     public enum AthleteClaimIneligibilityType
                         {
                             None = 0,

                             // Athlete is already claimed as athlete by the user.
                             UserAlreadyBoundToCareer,

                             // User is already bound to another athlete.
                             UserAlreadyBoundToAnotherCareer,

                             // Athlete is already bound to another user.
                             CareerAlreadyBoundToAnotherUser,

                             // User type is [athlete, fan, statistician, parent, etc.].
                             IneligibleUserMemberType,

                             // User's last name is different from athlete's.
                             NonMatchingLastName
                         }
                    */
                    
                    switch reasonType
                    {
                    case 1: // Athlete is already claimed as athlete by the user.
                        title = "You Can't Claim Yourself Twice!"
                        message = String(format: "You have already claimed %@ %@'s profile. Once in the app, you can edit your information in your profile.", self.selectedAthleteFirstName, self.selectedAthleteLastName)
                        
                    case 2: // User is already bound to another athlete.
                        title = "You Have Already Claimed a Different Athlete"
                        message = String(format: "Your profile is already linked to %@ %@.", self.selectedAthleteFirstName, self.selectedAthleteLastName)
                        bottomButtonTitle = "GET HELP"
                        
                    case 3: // Athlete is already bound to another user.
                        title = "Athlete Already Claimed"
                        message = String(format: "%@ %@'s profile has already been claimed by another athlete.", self.selectedAthleteFirstName, self.selectedAthleteLastName)
                        bottomButtonTitle = "GET HELP"
                        
                    case 4: // User type is [athlete, fan, statistician, parent, etc.].
                        // This case should never occur when onboarding
                        title = "Wrong User Type"
                        message = "You must be an athlete to claim yourself."
                        bottomButtonTitle = "GET HELP"
                        
                    case 5: // User's last name is different from athlete's.
                        title = "Unable to Claim Profile"
                        message = "Your name does not match this athlete."
                        bottomButtonTitle = "GET HELP"
                        
                    default: // Something went wrong
                        title = "We're Sorry"
                        message = "Something went wrong when checking eligibility."
                    }
                    
                    self.showOnboardingMessage(title: title, message: message, topButtonTitle: topButtonTitle, bottomButtonTitle: bottomButtonTitle)
                }
            }
            else
            {
                print("Get athlete claim eligibility failed.")
                
                self.showOnboardingMessage(title: "We're Sorry", message: "Something went wrong while determining if this athlete could be claimed.", topButtonTitle: "OKAY", bottomButtonTitle: "")
                
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
        
        NewFeeds.getAthleteClaimEligibility(careerId: self.selectedAthleteCareerId) { (result, error) in
            
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
                    
                    NewFeeds.claimCareerProfile(careerId: self.selectedAthleteCareerId, relationship: "Parent") { error in
                        
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
                                    
                                // Get user favorite teams
                                self.getUserFavoriteTeams()
                            }
                        }
                        else
                        {
                            print("Claim career profile failed.")
 
                            self.showOnboardingMessage(title: "We're Sorry", message: "Something went wrong when trying to claim this athlete.", topButtonTitle: "OKAY", bottomButtonTitle: "")
                            
                            // Click Tracking
                            let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"claim-athlete", kClickTrackingModuleNameKey: "user preferences", kClickTrackingModuleLocationKey:"claim athlete error", kClickTrackingModuleActionKey: "impression", kClickTrackingClickTextKey:"parent claim error"]
                            
                            TrackingManager.trackEvent(featureName: "claim-pop-up-error", cData: cData)
                        }
                    }
                }
                else
                {
                    //let reason = result!["ineligibleForParentClaimReason"] as! String
                    let reasonType = result!["parentClaimIneligibilityType"] as? Int ?? -1 // Newer version of the feed
                    
                    var title = ""
                    var message = ""
                    let topButtonTitle = "OKAY"
                    var bottomButtonTitle = ""
                    
                    /*
                     public enum ParentClaimIneligibilityType
                         {
                             None = 0,

                             // Athlete is already claimed as child by the user.
                             UserAlreadyBoundToCareer,

                             // User cannot be bound as parent to [number] or more athletes.
                             UserMaxParentClaimsReached,

                             // User type is [athlete, fan, statistician, parent, etc.].
                             IneligibleUserMemberType,

                             // Athlete can only have up to [number] parents claimed to it.
                             CareerMaxParentClaimsReached
                         }
                    */
                    
                    switch reasonType
                    {
                    case 1: // Athlete is already claimed as child by the user.
                        title = "You Have Already Claimed This Profile"
                        message = String(format: "You have already claimed %@ %@'s profile. Once in the app, you can access or edit your children in your profile.", self.selectedAthleteFirstName, self.selectedAthleteLastName)
                        
                    case 2: // User cannot be bound as parent to [number] or more athletes.
                        title = "Unable to Claim Profile"
                        message = "Parents cannot claim more than 10 athlete profiles."
                        bottomButtonTitle = "GET HELP"
                        
                    case 3: // User type is [athlete, fan, statistician, parent, etc.].
                        // This case should never occur when onboarding
                        title = "Wrong User Type"
                        message = "You must not be an athlete to claim a child."
                        bottomButtonTitle = "GET HELP"
                        
                    case 4: // Athlete can only have up to [number] parents claimed to it.
                        title = "Unable to Claim Profile"
                        message = String(format: "%@ %@'s profile has the maximum number of parents linked to it.", self.selectedAthleteFirstName, self.selectedAthleteLastName)
                        bottomButtonTitle = "GET HELP"
                        
                    default: // Something went wrong
                        title = "We're Sorry"
                        message = "Something went wrong when checking eligibility."
                    }
                    
                    self.showOnboardingMessage(title: title, message: message, topButtonTitle: topButtonTitle, bottomButtonTitle: bottomButtonTitle)
                }
            }
            else
            {
                print("Get athlete claim eligibility failed.")

                self.showOnboardingMessage(title: "We're Sorry", message: "Something went wrong while determining if this athlete could be claimed.", topButtonTitle: "OKAY", bottomButtonTitle: "")
            }
        }
    }
    
    func closeClaimProfileAlertAfterCancelButtonTouched()
    {
        claimProfileAlertView.removeFromSuperview()
        claimProfileAlertView = nil
    }
    
    // MARK: - ClaimAthleteSearchView Delegate
    
    func claimAthleteSearchDidSelectAthlete(selectedAthlete: Athlete, showSaveFavoriteButton: Bool, showRemoveFavoriteButton: Bool)
    {
        if (claimProfileAlertView != nil)
        {
            claimProfileAlertView.removeFromSuperview()
            claimProfileAlertView = nil
        }
        
        selectedAthleteCareerId = selectedAthlete.careerId
        selectedAthleteFirstName = selectedAthlete.firstName
        selectedAthleteLastName = selectedAthlete.lastName
                
        claimProfileAlertView = ClaimProfileAlertView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight), color: UIColor.mpRedColor(), name: String(format: "%@ %@", selectedAthleteFirstName, selectedAthleteLastName), isParent: !self.userIsAthlete)
        claimProfileAlertView.delegate = self
        
        self.view.addSubview(claimProfileAlertView)
        
        // Click Tracking
        let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"claim-athlete", kClickTrackingModuleNameKey: "user preferences", kClickTrackingModuleLocationKey:"claim athlete prompt", kClickTrackingModuleActionKey: "impression", kClickTrackingClickTextKey:""]
        
        TrackingManager.trackEvent(featureName: "claim-pop-up", cData: cData)
    }
    
    // MARK: - Clear Search View Fields
    
    private func clearSearchViewFields()
    {
        athleteSearchView.clearAllFields()
    }
    
    // MARK: - Button Methods
    
    @IBAction func skipButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func dontSeeYourselfButtonTouched(_ sender: UIButton)
    {
        self.showWebViewController(title: "Support", urlString: kTechSupportUrl)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        trackingGuid = NSUUID().uuidString

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and titleLabel
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        
        // Shift the button up on devices with a home button
        var shift = 0.0
        if (SharedData.bottomSafeAreaHeight == 0)
        {
            shift = 20.0
        }
        dontSeeYourselfButton.frame = CGRect(x: (kDeviceWidth - dontSeeYourselfButton.frame.size.width) / 2.0, y: kDeviceHeight - CGFloat(SharedData.bottomSafeAreaHeight) - dontSeeYourselfButton.frame.size.height - shift, width: dontSeeYourselfButton.frame.size.width, height: dontSeeYourselfButton.frame.size.height)
        
        athleteSearchView = ClaimAthleteSearchView(frame: CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: CGFloat(kDeviceWidth), height: CGFloat(kDeviceHeight) - navView.frame.size.height - fakeStatusBar.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight) - dontSeeYourselfButton.frame.size.height - 20 - shift))
        athleteSearchView.delegate = self
        athleteSearchView.backgroundColor = UIColor.mpWhiteColor()
        self.view.addSubview(athleteSearchView)
        
        // This is needed so the view can present other VCs or alerts
        athleteSearchView.setParentViewController(self)
        
        var buttonText = ""
        if (self.userIsAthlete == true)
        {
            titleLabel.text = "Claim My Profile"
            buttonText = "Don't see yourself?"
        }
        else
        {
            titleLabel.text = "Link Your Profile"
            buttonText = "Don't see your child?"
        }
        
        let attributedString = NSMutableAttributedString(string: buttonText, attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 14), NSAttributedString.Key.foregroundColor: UIColor.mpBlueColor()])
        
        dontSeeYourselfButton.setAttributedTitle(attributedString, for: .normal)
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if (claimAthleteSuccessVC != nil)
        {
            // Reset the fields for non-athlete users
            if (self.userIsAthlete == false)
            {
                self.clearSearchViewFields()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if (claimAthleteSuccessVC != nil)
        {
            claimAthleteSuccessVC = nil
        }
        
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
