//
//  OldClaimAthleteLandingViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/23/22.
//

import UIKit

class OldClaimAthleteLandingViewController: UIViewController, OnboardingAlertViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var claimProfileButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var alertTestButton: UIButton!
    @IBOutlet weak var claimTestButton: UIButton!
    
    var userIsAthlete = false
    
    private var claimAthleteSearchVC: ClaimAthleteSearchViewController!
    private var onboardingAlertView: OnboardingAlertView!
    
    private var claimAthleteSuccessVC: ClaimAthleteSuccessViewController!
    
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
    }
    
    func closeOnboardingAlertAfterCancelButtonTouched()
    {
        onboardingAlertView.removeFromSuperview()
        onboardingAlertView = nil
    }
    
    // MARK: - Button Methods
    
    @IBAction func skipButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func claimProfileButtonTouched(_ sender: UIButton)
    {
        if (claimAthleteSearchVC != nil)
        {
            claimAthleteSearchVC = nil
        }
        
        claimAthleteSearchVC = ClaimAthleteSearchViewController(nibName: "ClaimAthleteSearchViewController", bundle: nil)
        claimAthleteSearchVC.userIsAthlete = self.userIsAthlete
        self.navigationController?.pushViewController(claimAthleteSearchVC, animated: true)
    }
    
    @IBAction func alertTestButtonTouched(_ sender: UIButton)
    {
        if (onboardingAlertView != nil)
        {
            onboardingAlertView.removeFromSuperview()
            onboardingAlertView = nil
        }
        
        onboardingAlertView = OnboardingAlertView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight), color: UIColor.mpRedColor(), title: "You Have Already Claimed Your Profile", message: "The quick brown fox jumped over the lazy dog. The quick brown fox jumped over the lazy dog.", topButtonTitle: "OKAY", bottomButtonTitle: "")
        onboardingAlertView.delegate = self
        
        self.view.addSubview(onboardingAlertView)
    }
    
    @IBAction func claimTestButtonTouched(_ sender: UIButton)
    {
        // Set a test user with one favorite
        kUserDefaults.setValue("c3b23e5b-13ce-4d98-949c-ca41eaa31ab5", forKey: kUserIdKey)
        kUserDefaults.setValue("Dave", forKey: kUserFirstNameKey)
        kUserDefaults.setValue("Smith", forKey: kUserLastNameKey)
        kUserDefaults.setValue(kDefaultSchoolLocation, forKey: kCurrentLocationKey)
        kUserDefaults.setValue("95762", forKey: kUserZipKey)
        
        // Set the token buster
        let now = NSDate()
        let timeInterval = Int(now.timeIntervalSinceReferenceDate)
        kUserDefaults.setValue(String(timeInterval), forKey: kTokenBusterKey)
        
        // Set the app id cookie
        MiscHelper.setAppIdCookie()
        
        let notifications = [] as Array
        
        let schoolId = "74c1621c-e0cf-4821-b5e1-3c8170c8125a"
        let allSeasonId = "22e2b335-334e-4d4d-9f67-a0f716bb1ccd"
        let mascotUrl = "https://dw3jhbqsbya58.cloudfront.net/fit-in/1024x1024/school-mascot/7/4/c/74c1621c-e0cf-4821-b5e1-3c8170c8125a.gif?version=637752723600000000"
        let schoolColor = "022C66"
        
        let newFavorite1 = [kNewGenderKey:"Boys", kNewSportKey:"Football", kNewLevelKey:"Varsity", kNewSeasonKey:"Fall", kNewSchoolIdKey:schoolId, kNewSchoolNameKey:"Oak Ridge", kNewSchoolFormattedNameKey:"Oak Ridge (El Dorado Hills, CA", kNewSchoolStateKey:"CA", kNewSchoolCityKey:"El Dorado Hills", kNewSchoolMascotUrlKey:mascotUrl, kNewSchoolColor1Key: schoolColor, kNewUserfavoriteTeamIdKey:0, kNewAllSeasonIdKey:allSeasonId, kNewNotificationSettingsKey:notifications] as [String : Any]
        
        let newFavorite2 = [kNewGenderKey:"Boys", kNewSportKey:"Basketball", kNewLevelKey:"Varsity", kNewSeasonKey:"Fall", kNewSchoolIdKey:schoolId, kNewSchoolNameKey:"Oak Ridge", kNewSchoolFormattedNameKey:"Oak Ridge (El Dorado Hills, CA", kNewSchoolStateKey:"CA", kNewSchoolCityKey:"El Dorado Hills", kNewSchoolMascotUrlKey:mascotUrl,kNewSchoolColor1Key: schoolColor, kNewUserfavoriteTeamIdKey:0, kNewAllSeasonIdKey:allSeasonId, kNewNotificationSettingsKey:notifications] as [String : Any]
        
        let favorites = [newFavorite1, newFavorite2]
        kUserDefaults.setValue(favorites, forKey: kNewUserFavoriteTeamsArrayKey)
        
        if (claimAthleteSuccessVC != nil)
        {
            claimAthleteSuccessVC = nil
        }
        
        claimAthleteSuccessVC = ClaimAthleteSuccessViewController(nibName: "ClaimAthleteSuccessViewController", bundle: nil)
        claimAthleteSuccessVC.userIsAthlete = self.userIsAthlete
        claimAthleteSuccessVC.athleteFirstName = "Joe"
        claimAthleteSuccessVC.athleteLastName = "Blow"
        claimAthleteSuccessVC.schoolColor = ColorHelper.color(fromHexString: schoolColor, colorCorrection: true)
        //claimAthleteSuccessVC.searchVC = self
        
        self.navigationController?.pushViewController(claimAthleteSuccessVC, animated: true)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, etc.
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        claimProfileButton.frame = CGRect(x: 32, y: kDeviceHeight - 84 - CGFloat(SharedData.bottomSafeAreaHeight), width: kDeviceWidth - 64, height: 42)
        titleLabel.frame = CGRect(x: 32, y: navView.frame.origin.y + navView.frame.size.height + 28, width: kDeviceWidth - 64, height: 31)
        subtitleLabel.frame = CGRect(x: 32, y: navView.frame.origin.y + navView.frame.size.height + 63, width: kDeviceWidth - 64, height: 90)
        
        claimProfileButton.layer.cornerRadius = claimProfileButton.frame.size.height / 2.0
        claimProfileButton.clipsToBounds = true
        
        if (self.userIsAthlete == true)
        {
            titleLabel.text = "Claim My Profile"
            subtitleLabel.text = "Build out your athlete profile, keep track of your progress, and showcase your accomplishments."
            claimProfileButton.setTitle("CLAIM MY PROFILE", for: .normal)
        }
        else
        {
            titleLabel.text = "Get linked to your athlete"
            subtitleLabel.text = "Link your profile to your athlete to receive their latest updates and help build out their career profile."
            claimProfileButton.setTitle("LINK MY PROFILE", for: .normal)
        }
        
        alertTestButton.isHidden = true
        claimTestButton.isHidden = true
        
        /*
        #if DEBUG
        alertTestButton.isHidden = false
        claimTestButton.isHidden = false
        #endif
        */
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if (claimAthleteSuccessVC != nil)
        {
            // Clear out the user's prefs
            MiscHelper.logoutUser()
        }
    }

    override func viewDidAppear(_ animated: Bool)
    {
        if (claimAthleteSearchVC != nil)
        {
            claimAthleteSearchVC = nil
        }

        if (claimAthleteSuccessVC != nil)
        {
            claimAthleteSuccessVC = nil
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
