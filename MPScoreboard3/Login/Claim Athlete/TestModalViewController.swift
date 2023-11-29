//
//  TestModalViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/30/22.
//

import UIKit

class TestModalViewController: UIViewController, OnboardingAlertViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    
    private var onboardingAlertView: OnboardingAlertView!
    
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
    }
    
    func closeOnboardingAlertAfterCancelButtonTouched()
    {
        onboardingAlertView.removeFromSuperview()
        onboardingAlertView = nil
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
     //Parent
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
     */
    
    @IBAction func button1Touched(_ sender: UIButton)
    {
        let title = "You Have Already Claimed This Profile"
        let message = String(format: "You have already claimed %@ %@'s profile. Once in the app, you can access or edit your children in your profile.", "John", "Doe")
        let bottomButtonTitle = ""
        
        self.showOnboardingMessage(title: title, message: message, topButtonTitle: "OKAY", bottomButtonTitle: bottomButtonTitle)
    }
    
    @IBAction func button2Touched(_ sender: UIButton)
    {
        let title = "Unable to Claim Profile"
        let message = "Parents cannot claim more than 10 athlete profiles."
        let bottomButtonTitle = "GET HELP"
        
        self.showOnboardingMessage(title: title, message: message, topButtonTitle: "OKAY", bottomButtonTitle: bottomButtonTitle)
    }
    
    @IBAction func button3Touched(_ sender: UIButton)
    {
        let title = "Unable to Claim Profile"
        let message = String(format: "%@ %@'s profile has the maximum number of parents linked to it.", "John", "Doe")
        let bottomButtonTitle = "GET HELP"
        
        self.showOnboardingMessage(title: title, message: message, topButtonTitle: "OKAY", bottomButtonTitle: bottomButtonTitle)
    }
    
    /*
     // Athlete
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
     */
    
    @IBAction func button4Touched(_ sender: UIButton)
    {
        let title = "You Can't Claim Yourself Twice!"
        let message = String(format: "You have already claimed %@ %@'s profile. Once in the app, you can edit your information in your profile.", "John", "Doe")
        let bottomButtonTitle = ""
        
        self.showOnboardingMessage(title: title, message: message, topButtonTitle: "OKAY", bottomButtonTitle: bottomButtonTitle)
    }
    
    @IBAction func button5Touched(_ sender: UIButton)
    {
        let title = "You Have Already Claimed a Different Athlete"
        let message = String(format: "Your profile is already linked to %@ %@.", "John", "Doe")
        let bottomButtonTitle = "GET HELP"
        
        self.showOnboardingMessage(title: title, message: message, topButtonTitle: "OKAY", bottomButtonTitle: bottomButtonTitle)
    }
    
    @IBAction func button6Touched(_ sender: UIButton)
    {
        let title = "Athlete Already Claimed"
        let message = String(format: "%@ %@'s profile has already been claimed by another athlete.", "John", "Doe")
        let bottomButtonTitle = "GET HELP"
        
        self.showOnboardingMessage(title: title, message: message, topButtonTitle: "OKAY", bottomButtonTitle: bottomButtonTitle)
    }
    
    @IBAction func button7Touched(_ sender: UIButton)
    {
        let title = "Unable to Claim Profile"
        let message = "Your name does not match this athlete."
        let bottomButtonTitle = "GET HELP"
        
        self.showOnboardingMessage(title: title, message: message, topButtonTitle: "OKAY", bottomButtonTitle: bottomButtonTitle)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, etc.
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
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
