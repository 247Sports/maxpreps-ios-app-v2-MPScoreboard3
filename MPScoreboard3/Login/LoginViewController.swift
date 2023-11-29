//
//  LoginViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/15/22.
//

import UIKit
import NVActivityIndicatorView

class LoginViewController: UIViewController, UITextFieldDelegate
{
    var loginFinished = false
    
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var navLogo: UIImageView!
    @IBOutlet weak var xManLogo: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var signinButton: UIButton!
    
    private var tickTimer: Timer!
    private var showPassword = false
    private var screenShiftDone = false
    
    private var resetPaswordVC: ResetPasswordViewController!
    //private var progressOverlay: ProgressHUD!
    private var activityIndicatorView: NVActivityIndicatorView!
    
    // MARK: - Login Feed
    
    private func loginUser(email: String, password: String)
    {
        // Show the busy indicator
        if (activityIndicatorView == nil)
        {
            signinButton.setTitle("", for: .normal)
            signinButton.isEnabled = false
            activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: (signinButton.frame.size.width / 2.0) - 18, y: 3, width: 36, height: 36), type: .ballPulse, color: UIColor.mpWhiteColor(), padding: 0)
            signinButton.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
        }
        
        NewFeeds.loginUser(email: email, password: password) { result, error in
            
            // Hide the busy indicator
            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            {
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.removeFromSuperview()
                self.activityIndicatorView = nil
                
                if (error != nil)
                {
                    self.signinButton.setTitle("SIGN IN", for: .normal)
                    self.signinButton.isEnabled = true
                }
            }
            
            if (error == nil)
            {
                print("Login Success")
                let email = result!["email"] as! String
                let firstName = result!["firstName"] as! String
                let lastName = result!["lastName"] as! String
                let userId = result!["userId"] as! String
                let zip = result!["zip"] as! String
                let photoUrl = result!["photoUrl"] as! String
                let careerPhotoUrl = result!["careerPhotoUrl"] as? String ?? ""
                let type = result!["type"] as! String
                let birthdate = result!["bornOn"] as? String ?? ""
                let gender = result!["gender"] as? String ?? ""
                let adminRoles = result!["roles"] as! Array<Dictionary<String,Any>>
                
                MiscHelper.saveUserInfo(userId: userId, email: email, firstName: firstName, lastName: lastName, zip: zip, photoUrl: photoUrl, careerPhotoUrl: careerPhotoUrl, type: type, birthdate: birthdate, gender: gender, adminRoles: adminRoles)
                /*
                kUserDefaults.setValue(userId, forKey: kUserIdKey)
                kUserDefaults.setValue(email, forKey: kUserEmailKey)
                kUserDefaults.setValue(firstName, forKey: kUserFirstNameKey)
                kUserDefaults.setValue(lastName, forKey: kUserLastNameKey)
                kUserDefaults.setValue(zip, forKey: kUserZipKey)
                kUserDefaults.setValue(photoUrl, forKey: kUserPhotoUrlKey)
                kUserDefaults.setValue(careerPhotoUrl, forKey: kUserCareerPhotoUrlKey)
                kUserDefaults.setValue(type, forKey: kUserTypeKey)
                
                let location = ZipCodeHelper.location(forZipCode: zip)
                kUserDefaults.setValue(location, forKey: kCurrentLocationKey)
                
                // Set the app id cookie
                MiscHelper.setAppIdCookie()
                
                // Set the token buster
                let now = NSDate()
                let timeInterval = Int(now.timeIntervalSinceReferenceDate)
                kUserDefaults.setValue(String(timeInterval), forKey: kTokenBusterKey)
                
                //print(kUserDefaults.value(forKey: kTokenBusterKey) as! String)
                
                // Fill the admin roles array
                var roleDictionary = [:] as! Dictionary<String,Dictionary<String,Any>>
                
                // Added to handle parents of multiple children
                // The dictionary is used for most of the app as it's faster than iterating through an array to get privileges
                var rolesArray = [] as! Array<Dictionary<String,Any>>
                
                for role in adminRoles
                {
                    let roleName = role["roleName"] as! String
                    let adminRoleTitle = role["adminRoleTitle"] as? String ?? ""
                    let schoolId = role["schoolId"] as! String
                    let allSeasonId = role["allSeasonId"] as! String
                    let ssid = role["sportSeasonId"] as? String ?? ""
                    let schoolName = role["schoolName"] as! String
                    let sport = role["sport"] as! String
                    let gender = role["gender"] as! String
                    let teamLevel = role["teamLevel"] as! String
                    let accessId1 = role["accessId1"] as? String ?? ""
                    let permissions = role["permissions"] as? Array<Dictionary<String,String>> ?? []
                    
                    let refactoredRole = [kRoleNameKey:roleName, kRoleTitleKey:adminRoleTitle, kRoleSchoolIdKey:schoolId, kRoleSSIDKey:ssid, kRollAllSeasonIdKey: allSeasonId, kRoleSchoolNameKey: schoolName, kRoleSportKey:sport, kRoleGenderKey:gender, kRoleTeamLevelKey:teamLevel, kRoleCareerIdKey:accessId1, kRolePermissionsKey:permissions] as [String : Any]
                    
                    // Create a unique key for each role using schoolId and allSeasonId
                    // The schoolId and allSeasonId are zero for the various admin roles. I need to differentiate these users from the coach and AD roles.
                    var roleKey = schoolId + "_" + allSeasonId
                    
                    if (roleName == "Standard Admin User")
                    {
                        roleKey = kStandardAdminUserId
                    }
                    else if (roleName == "Affiliate Administrator")
                    {
                        roleKey = kAffiliateAdminUserId
                    }
                    else if (roleName == "State Association Administrator")
                    {
                        roleKey = kStateAssociationAdminUserId
                    }
                    else if (roleName == "Photographer")
                    {
                        roleKey = kPhotographerUserId
                    }
                    else if (roleName == "Writer")
                    {
                        roleKey = kWriterUserId
                    }
                    else if (roleName == "Stat Supplier")
                    {
                        roleKey = kStatSupplierUserId
                    }
                    else if (roleName == "Tournament Director")
                    {
                        roleKey = kTournamentDirectorUserId
                    }
                    else if (roleName == "Meet Manager")
                    {
                        roleKey = kMeetManagerUserId
                    }
                    
                    if (roleName == "Career Admin")
                    {
                        if (adminRoleTitle == "Parent")
                        {
                            roleKey = kCareerAdminParentUserId
                        }
                        else if (adminRoleTitle == "Athlete")
                        {
                            roleKey = kCareerAdminAthleteUserId
                        }
                    }
                    
                    roleDictionary.updateValue(refactoredRole, forKey: roleKey)
                    rolesArray.append(refactoredRole)
                }
                
                // Save to prefs
                kUserDefaults.setValue(roleDictionary, forKey: kUserAdminRolesDictionaryKey)
                kUserDefaults.setValue(rolesArray, forKey: kUserAdminRolesArrayKey)
                */
                
                self.loginFinished = true
                self.navigationController?.popViewController(animated: true)
            }
            else
            {
                print("Login Failed")
                
                let errorMessage = error?.localizedDescription

                OverlayView.showPopdownOverlay(withMessage: errorMessage, title: "Oops!", overlayColor: UIColor.mpPinkMessageColor()) {
                }
            }
        }
    }
    
    // MARK: - Text Field Delegates
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        // Shift the inner container up 70 pixels
        // Shift the titleLabel up 50, scale by 80%
        // Shift the subtitleLabel up 60, scale by 80%
        // Shift the signinButton up by the signinButtonShift value
        
        if (screenShiftDone == false)
        {
            let signinButtonShift = kDeviceHeight - 80 - CGFloat(SharedData.bottomSafeAreaHeight) - 335
            
            UIView.animate(withDuration: 0.25, animations: {
                
                self.xManLogo.alpha = 0
                self.navLogo.alpha = 1
                self.innerContainerView.transform = CGAffineTransform(translationX: 0, y: -70)
                self.titleLabel.transform = CGAffineTransform(translationX: -16, y: -50).concatenating(CGAffineTransform(scaleX: 0.8, y: 0.8))
                self.subtitleLabel.transform = CGAffineTransform(translationX: -23, y: -60).concatenating(CGAffineTransform(scaleX: 0.8, y: 0.8))
                self.signinButton.transform = CGAffineTransform(translationX: 0, y: -signinButtonShift)
            })
            { (finished) in
                
            }
            screenShiftDone = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        /*
        UIView.animate(withDuration: 0.25, animations: {
            
            self.xManLogo.alpha = 1
            self.navLogo.alpha = 0
            self.innerContainerView.transform = CGAffineTransform(translationX: 0, y: 0)
            self.titleLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            self.subtitleLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            self.signinButton.transform = CGAffineTransform(translationX: 0, y: 0)
        })
        { (finished) in
            
        }
        */
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if (textField == emailTextField)
        {
            passwordTextField.becomeFirstResponder()
        }
        else
        {
            emailTextField.resignFirstResponder()
            passwordTextField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        if ((emailTextField.text!.count > 0) && (passwordTextField.text!.count > 0))
        {
            signinButton.backgroundColor = UIColor.mpRedColor()
            signinButton.isEnabled = true
        }
        else
        {
            signinButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
            signinButton.isEnabled = false
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showPasswordButtonTouched(_ sender: UIButton)
    {
        showPassword = !showPassword
        
        if (showPassword == true)
        {
            let attributedString = NSMutableAttributedString(string: "HIDE", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 13), NSAttributedString.Key.foregroundColor: UIColor.mpLightGrayColor()])
            
            showPasswordButton.setAttributedTitle(attributedString, for: .normal)
            passwordTextField.isSecureTextEntry = false
        }
        else
        {
            let attributedString = NSMutableAttributedString(string: "SHOW", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 13), NSAttributedString.Key.foregroundColor: UIColor.mpLightGrayColor()])
            
            showPasswordButton.setAttributedTitle(attributedString, for: .normal)
            passwordTextField.isSecureTextEntry = true
        }
    }
    
    @IBAction func forgotPasswordButtonTouched(_ sender: UIButton)
    {
        if (resetPaswordVC != nil)
        {
            resetPaswordVC = nil
        }
        
        resetPaswordVC = ResetPasswordViewController(nibName: "ResetPasswordViewController", bundle: nil)
        self.navigationController?.pushViewController(resetPaswordVC, animated: true)
    }
    
    @IBAction func signinButtonTouched(_ sender: UIButton)
    {
        self.loginUser(email: emailTextField.text!, password: passwordTextField.text!)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and innerContainer
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        signinButton.frame = CGRect(x: 28, y: kDeviceHeight - 80 - CGFloat(SharedData.bottomSafeAreaHeight), width: kDeviceWidth - 56, height: 42)
        xManLogo.frame = CGRect(x: 28, y: navView.frame.origin.y + navView.frame.size.height + 16, width: 24, height: 40)
        titleLabel.frame = CGRect(x: 28, y: navView.frame.origin.y + navView.frame.size.height + 72, width: 130, height: 35)
        subtitleLabel.frame = CGRect(x: 28, y: navView.frame.origin.y + navView.frame.size.height + 107, width: 180, height: 30)
        //innerContainerView.frame = CGRect(x: 0, y: innerContainerView.frame.origin.y, width: kDeviceWidth, height: innerContainerView.frame.size.height)
        innerContainerView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height + 161, width: kDeviceWidth, height: 128)
        
        signinButton.layer.cornerRadius = signinButton.frame.size.height / 2.0
        signinButton.clipsToBounds = true
        signinButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
        signinButton.isEnabled = false
        
        navLogo.alpha = 0.0
        
        let attributedString = NSMutableAttributedString(string: "SHOW", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 13), NSAttributedString.Key.foregroundColor: UIColor.mpLightGrayColor()])
        
        showPasswordButton.setAttributedTitle(attributedString, for: .normal)

        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
        
        // Tracking
        let trackingGuid = NSUUID().uuidString
        TrackingManager.trackState(featureName: "membership-sign-in", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if (resetPaswordVC != nil)
        {
            resetPaswordVC = nil
        }
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
    
    deinit
    {
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
    }
}
