//
//  OldLoginViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/18/21.
//

import UIKit

class OldLoginViewController: UIViewController, UITextFieldDelegate
{
    var loginFinished = false
    
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var daveButton1: UIButton!
    @IBOutlet weak var daveButton2: UIButton!
    @IBOutlet weak var daveButton3: UIButton!
        
    // MARK: - Text Field Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
    
    // MARK: - Login Feed
    
    private func loginUser(email: String, password: String)
    {
        // Show the busy indicator
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        NewFeeds.loginUser(email: email, password: password) { result, error in
            
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                MBProgressHUD.hide(for: self.view, animated: true)
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
                
                self.loginFinished = true
                self.navigationController?.popViewController(animated: true)
            }
            else
            {
                print("Login Failed")
                //if (kUserDefaults.bool(forKey: kDebugDialogsKey) == true)
                //{
                    let errorMessage = error?.localizedDescription

                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Login Error", message: errorMessage, lastItemCancelType: false) { (tag) in
                    
                    }
                //}
            }
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginButtonTouched(_ sender: UIButton)
    {
        if (emailTextField.text?.count == 0) || (passwordTextField.text?.count == 0)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Error", message: "Please enter your email and password", lastItemCancelType: false) { (tag) in
                
            }
            
            return
        }
        
        // Call the login feed
        self.loginUser(email: emailTextField.text!, password: passwordTextField.text!)
    }
    
    @IBAction func loginDaveButtonTouched(_ sender: UIButton)
    {
        self.loginUser(email: kDaveEmail, password: kDavePassword)
    }
    
    @IBAction func loginDave120ButtonTouched(_ sender: UIButton)
    {
        self.loginUser(email: kDave120Email, password: kDave120Password)
    }
    
    @IBAction func loginDave122ButtonTouched(_ sender: UIButton)
    {
        self.loginUser(email: kDave122Email, password: kDave122Password)
    }
    
    @IBAction func loginTestDriveUserNoFavsNoState(_ sender: UIButton)
    {
        kUserDefaults.setValue(kTestDriveUserId, forKey: kUserIdKey)
        kUserDefaults.setValue(kDefaultSchoolLocation, forKey: kCurrentLocationKey)
        kUserDefaults.setValue("99999", forKey: kUserZipKey)
        kUserDefaults.setValue("Guest", forKey: kUserTypeKey)
        
        // Set the token buster
        let now = NSDate()
        let timeInterval = Int(now.timeIntervalSinceReferenceDate)
        kUserDefaults.setValue(String(timeInterval), forKey: kTokenBusterKey)
        
        // Set the app id cookie
        MiscHelper.setAppIdCookie()
        
        self.loginFinished = true
        self.navigationController?.popViewController(animated: true)
        
        // Post a notification that the favorite teams have been updated
        NotificationCenter.default.post(name: Notification.Name("FavoriteTeamsUpdated"), object: nil)
    }
    
    @IBAction func loginTestDriveUserWithOneFavorite(_ sender: UIButton)
    {
        kUserDefaults.setValue(kTestDriveUserId, forKey: kUserIdKey)
        kUserDefaults.setValue(kDefaultSchoolLocation, forKey: kCurrentLocationKey)
        kUserDefaults.setValue("95762", forKey: kUserZipKey)
        kUserDefaults.setValue("Guest", forKey: kUserTypeKey)
        
        // Set the token buster
        let now = NSDate()
        let timeInterval = Int(now.timeIntervalSinceReferenceDate)
        kUserDefaults.setValue(String(timeInterval), forKey: kTokenBusterKey)
        
        // Set the app id cookie
        MiscHelper.setAppIdCookie()
        
        let notifications = [] as Array
        
        let schoolId = "74c1621c-e0cf-4821-b5e1-3c8170c8125a"
        let allSeasonId = "22e2b335-334e-4d4d-9f67-a0f716bb1ccd"
        
        let newFavorite = [kNewGenderKey:"Boys", kNewSportKey:"Football", kNewLevelKey:"Varsity", kNewSeasonKey:"Fall", kNewSchoolIdKey:schoolId, kNewSchoolNameKey:"Oak Ridge", kNewSchoolFormattedNameKey:"Oak Ridge (El Dorado Hills, CA", kNewSchoolStateKey:"CA", kNewSchoolCityKey:"El Dorado Hills", kNewSchoolMascotUrlKey:"", kNewUserfavoriteTeamIdKey:0, kNewAllSeasonIdKey:allSeasonId, kNewNotificationSettingsKey:notifications] as [String : Any]
        
        let favorites = [newFavorite]
        kUserDefaults.setValue(favorites, forKey: kNewUserFavoriteTeamsArrayKey)
        
        // Add a favorite athlete
        let newAthlete = [kCareerProfileFirstNameKey:"Montana", kCareerProfileLastNameKey:"Fouts", kCareerProfileSchoolNameKey:"East Carter", kCareerProfileSchoolIdKey:"106c199e-50fa-4fb8-98bc-4c72ed9ad4a0", kCareerProfileSchoolColor1Key:"FF0000", kCareerProfileSchoolMascotUrlKey:"https://dw3jhbqsbya58.cloudfront.net/fit-in/1024x1024/school-mascot/1/0/6/106c199e-50fa-4fb8-98bc-4c72ed9ad4a0.gif?version=636387379800000000", kCareerProfileSchoolCityKey:"Grayson", kCareerProfileSchoolStateKey:"KY", kCareerProfileIdKey:"8017c3f8-9bd0-e311-b4d2-002655e6c45a", kCareerProfilePhotoUrlKey:"https://dw3jhbqsbya58.cloudfront.net/careers/8/0/1/8017c3f8-9bd0-e311-b4d2-002655e6c45a/thumbnail.jpg?version=0"]
        
        
        let favoriteAthletes = [newAthlete]
        kUserDefaults.setValue(favoriteAthletes, forKey: kUserFavoriteAthletesArrayKey)
        
        /*
             let kCareerProfileFirstNameKey = "careerProfileFirstName"        // String
             let kCareerProfileLastNameKey = "careerProfileLastName"          // String
             let kCareerProfileSchoolNameKey = "schoolName"                   // String
             let kCareerProfileSchoolIdKey = "schoolId"                       // String
             let kCareerProfileSchoolColor1Key = "schoolColor1"               // String
             let kCareerProfileSchoolMascotUrlKey = "schoolMascotUrl"         // String
             let kCareerProfileSchoolCityKey = "schoolCity"                   // String
             let kCareerProfileSchoolStateKey = "schoolState"                 // String
             let kCareerProfileIdKey = "careerProfileId"                      // String
             let kCareerProfilePhotoUrlKey = "photoUrl"                       // String
        */
        
        // Post a notification that the favorite teams have been updated
        NotificationCenter.default.post(name: Notification.Name("FavoriteTeamsUpdated"), object: nil)
        
        self.loginFinished = true
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, videoContainer, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        
        loginButton.layer.cornerRadius = 5
        loginButton.clipsToBounds = true
        
        daveButton1.isEnabled = false
        daveButton2.isEnabled = false
        daveButton3.isEnabled = false

        #if DEBUG
        daveButton1.isEnabled = true
        daveButton2.isEnabled = true
        daveButton3.isEnabled = true
        #endif
        
        // This shows the email suggestions
        emailTextField.textContentType = .emailAddress

    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.lightContent
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
