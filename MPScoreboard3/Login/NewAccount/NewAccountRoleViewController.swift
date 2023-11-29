//
//  NewAccountRoleViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/22/22.
//

import UIKit
import BranchSDK

class NewAccountRoleViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var roleTextField: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var policyTextView: UITextView!
    @IBOutlet weak var optInButton1: UIButton!
    @IBOutlet weak var optInButton2: UIButton!
        
    var isPendingMember = false
    var userEmail = ""
    var userPassword = ""
    var userFirstName = ""
    var userLastName = ""
    var userBirthdate = ""
    var userGenderAlias = ""
    var userZipcode = ""
    
    private var tickTimer: Timer!
    private var optInEnable1 = true
    private var optInEnable2 = true
    
    private var kRoleValues = ["Select Role", "Athlete", "Parent", "Fan", "High School Coach", "Athletic Director", "College Coach", "Statistician", "Media", "School Administrator"]
    private var currentPickerIndex = 0
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Create Account
    
    private func createAccount()
    {
        // Show the busy indicator
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.createUserAccount(email: self.userEmail, password: self.userPassword, firstName: self.userFirstName, lastName: self.userLastName, birthdate: self.userBirthdate, genderAlias: self.userGenderAlias, zipcode: self.userZipcode, role: roleTextField.text!, allowMessaging: optInEnable1, allowPartner: optInEnable2) { result, error in
            
            if (error == nil)
            {
                print("Create Account Success")
                
                // Call the login user API
                self.loginUser(email: self.userEmail, password: self.userPassword)
                
                // Call Branch event tracking
                let userId = result!["userId"] as? String ?? "Unknown"
                let userType = result!["type"] as? String ?? "Unknown"
                
                let event = BranchEvent.standardEvent(.completeRegistration)
                event.alias = "COMPLETE REGISTRATION"
                event.transactionID = userId
                event.eventDescription = "COMPLETE_REGISTRATION"
                event.customData["userId"] = userId
                event.customData["userRole"] = userType
                event.logEvent()
            }
            else
            {
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
                
                print("Create Account Failed")
                //let errorMessage = error?.localizedDescription

                OverlayView.showPopdownOverlay(withMessage: "An error occurred when creating the account.", title: "We're Sorry", overlayColor: UIColor.mpPinkMessageColor()) {
                }
            }
        }
    }
    
    // MARK: - Login User
        
    private func loginUser(email: String, password: String)
    {
        NewFeeds.loginUser(email: email, password: password) { result, error in
            
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
                }
                
                // Save to prefs
                kUserDefaults.setValue(roleDictionary, forKey: kUserAdminRolesDictionaryKey)
                */
                
                // Notify the loginLandingVC that the account creation was successful
                NotificationCenter.default.post(name: Notification.Name("CreateAccountFinished"), object: nil)
                
                // Pop all the way back to the loginLandingVC
                self.navigationController?.popToRootViewController(animated: true)
            }
            else
            {
                print("Login Failed")
                //let errorMessage = error?.localizedDescription

                OverlayView.showPopdownOverlay(withMessage: "An error occurred when logging into the new account.", title: "We're Sorry", overlayColor: UIColor.mpPinkMessageColor()) {
                }
            }
        }
    }
    
    // MARK: - TextField Delegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        return false
    }
    
    // MARK: - Picker View Delegates
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
        return 36
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return kRoleValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return kRoleValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if (row == 0)
        {
            roleTextField.text = ""
            return
        }
        
        currentPickerIndex = row
        roleTextField.text = kRoleValues[row]
    }
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        if (roleTextField.text!.count > 0)
        {
            continueButton.backgroundColor = UIColor.mpNegativeRedColor()
            continueButton.isEnabled = true
        }
        else
        {
            continueButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
            continueButton.isEnabled = false
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func continueButtonTouched(_ sender: UIButton)
    {        
        self.createAccount()
        
        /*
        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Coming Soon", message: "This creates the account and returns to the login landing page for the next steps.", lastItemCancelType: false) { tag in
            
        }
        */
    }
    
    @IBAction func optInButton1Touched(_ sender: UIButton)
    {
        optInEnable1 = !optInEnable1
        
        if (optInEnable1 == true)
        {
            optInButton1.setImage(UIImage(named: "CheckBoxBlue"), for: .normal)
        }
        else
        {
            optInButton1.setImage(UIImage(named: "CheckBoxOff"), for: .normal)
        }
    }
    
    @IBAction func optInButton2Touched(_ sender: UIButton)
    {
        optInEnable2 = !optInEnable2
        
        if (optInEnable2 == true)
        {
            optInButton2.setImage(UIImage(named: "CheckBoxBlue"), for: .normal)
        }
        else
        {
            optInButton2.setImage(UIImage(named: "CheckBoxOff"), for: .normal)
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and innerContainer
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        //pickerContainerView.frame = CGRect(x: 0, y: kDeviceHeight - CGFloat(SharedData.bottomSafeAreaHeight) - 227, width: kDeviceWidth, height: CGFloat(SharedData.bottomSafeAreaHeight) + 227)
        pickerContainerView.frame = CGRect(x: 0, y: kDeviceHeight - CGFloat(SharedData.bottomSafeAreaHeight) - 216, width: kDeviceWidth, height: CGFloat(SharedData.bottomSafeAreaHeight) + 216)
        
        // Set the inner container height
        //let innerContainerHeight = kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight) - 240.0
        let innerContainerHeight = kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight) - 216.0
        
        innerContainerView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: innerContainerHeight)
                
        continueButton.layer.cornerRadius = continueButton.frame.size.height / 2.0
        continueButton.clipsToBounds = true
        continueButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
        continueButton.isEnabled = false
        
        // Add hyperlinks to the textView
        let policyString = "By creating an account, using or visiting this website at www.maxpreps.com, you are agreeing to the Terms of Use and the Privacy Policy."
        
        let attributedString = NSMutableAttributedString(string: policyString, attributes: [NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 13), NSAttributedString.Key.foregroundColor: UIColor.mpGrayColor()])
        
        //let attributedString = NSMutableAttributedString(string: policyString)
        
        let range1 = policyString.range(of: "Terms of Use")
        let convertedRange1 = NSRange(range1!, in: policyString)
        let termsUrl = URL(string: kCBSTermsOfUseUrl)!
        
        let range2 = policyString.range(of: "Privacy Policy")
        let convertedRange2 = NSRange(range2!, in: policyString)
        let privacyUrl = URL(string: kCBSPolicyUrl)!
        
        // Set the links
        attributedString.setAttributes([.link: termsUrl], range: convertedRange1)
        attributedString.setAttributes([.link: privacyUrl], range: convertedRange2)
        
        policyTextView.attributedText = attributedString

        // Set how links should appear: blue and underlined
        //policyTextView.linkTextAttributes = [.foregroundColor: UIColor.mpBlueColor(), .underlineStyle: NSUnderlineStyle.single.rawValue]
        policyTextView.linkTextAttributes = [.foregroundColor: UIColor.mpBlueColor()]
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
        
        // Tracking
        let trackingGuid = NSUUID().uuidString
        TrackingManager.trackState(featureName: "role", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
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
