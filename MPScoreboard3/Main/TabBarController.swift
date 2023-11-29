//
//  TabBarController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/1/21.
//

import UIKit
import AppTrackingTransparency
import BranchSDK
import OTPublishersHeadlessSDK

class TabBarController: UITabBarController, UITabBarControllerDelegate, LoginLandingViewControllerDelegate
{
    private var loginLandingVC: LoginLandingViewController!
    private var loginLandingNav: TopNavigationController!
    
    private let kDefaultTabIndex = 0
    
    // MARK: - Original Web Login
    
    private func originalWebLogin()
    {
        /*
        // Test code for Pranata
        let fakeFavorite = [kNewSchoolIdKey:kDefaultSchoolId, kNewAllSeasonIdKey: kEmptyGuid, kNewSeasonKey: "Spring"]

        NewFeeds.loadCookie(fakeFavorite) { error in
            
            if (error == nil)
            {
                print("success")
                
                let cookieJar = HTTPCookieStorage.shared

                for cookie in cookieJar.cookies!
                {
                   if cookie.name == "CookieTest"
                   {
                      let cookieValue = cookie.value

                      print("COOKIE VALUE = \(cookieValue)")
                   }
                }
            }
        }
        */
        
        LegacyFeeds.webLogin(completionHandler:{ post, error in
            if error == nil
            {
                print("Web login successful")
                
                // Get the user favorites if a real user
                if ((kUserDefaults.string(forKey: kUserIdKey) != kEmptyGuid) && (kUserDefaults.string(forKey: kUserIdKey) != kTestDriveUserId))
                {
                    //self.getUserInfo()
                    //self.getUserFavoriteAthletes()
                    //self.getUserFavoriteTeams()
                }
            }
            else
            {
                print("Web login error")
            }
        })
    }
    
    // MARK: - Get User Info
    
    @objc func getUserInfo()
    {
        NewFeeds.validateUser() { result, error in
            
            if (error == nil)
            {
                print("Validate User Success")
                
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
                
                // Set the token buster
                let now = NSDate()
                let timeInterval = Int(now.timeIntervalSinceReferenceDate)
                kUserDefaults.setValue(String(timeInterval), forKey: kTokenBusterKey)
                
                //print(kUserDefaults.value(forKey: kTokenBusterKey) as! String)
                
                // Fill the admin roles array
                var roleDictionary = [:] as! Dictionary<String,Dictionary<String,Any>>
                
                // Added this array to handle parents of multiple children
                // The dictionary is used for most of the app as it's faster than iterating through an array to get privileges.
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
                    
                    // Create a unique key for each role using schoolId, allSeasonId, and roleName
                    // The schoolId and allSeasonId are zero for the various admin roles. I need to differentiate these users from the coach and AD roles.
                    var roleKey = String(format: "%@_%@", schoolId, allSeasonId)
                    
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
                // Clear out existing roles
                kUserDefaults.removeObject(forKey: kUserAdminRolesDictionaryKey)
                kUserDefaults.removeObject(forKey: kUserAdminRolesArrayKey)
                
                // Save to prefs
                kUserDefaults.setValue(roleDictionary, forKey: kUserAdminRolesDictionaryKey)
                kUserDefaults.setValue(rolesArray, forKey: kUserAdminRolesArrayKey)
                */
                
                // Notify the rest of the app that the userInfo has been updated
                NotificationCenter.default.post(name: Notification.Name("GetUserInfoFinished"), object: nil)
                
                // Added to temporarily fix the bad web pages
                //self.originalWebLogin()
                
            }
            else
            {
                print("Validate User Failed")
               
                if (kUserDefaults.bool(forKey: kDebugDialogsKey) == true)
                {
                    let errorMessage = error?.localizedDescription
                
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Validate User Error", message: errorMessage, lastItemCancelType: false) { (tag) in
                    
                    }
                }
            }
        }
    }
    
    // MARK: - Get User Favorite Athletes
    
    private func getUserFavoriteAthletes()
    {
        NewFeeds.getUserFavoriteAthletes { (error) in
            
            if (error == nil)
            {
                // Check if the favorites have been written
                if let favs = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
                {
                    print ("Saved favorites count: " + String(favs.count))
                    
                    if (favs.count > 0)
                    {
                        print("Favorite Athlete Count: " + String(favs.count))
                    }
                }
                else
                {
                    print ("No Favorite Athletes")
                }
            }
            else
            {
                print("User Favorite Athletes Failed")
            }
        }
    }

    // MARK: - Get User Favorite Teams
    
    private func getUserFavoriteTeams()
    {
        NewFeeds.getUserFavoriteTeams { (error) in
            
            if (error == nil)
            {
                // Check if the favorites have been written
                if let favs = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
                {
                    print ("Saved favorite teams count: " + String(favs.count))
                    
                    if (favs.count > 0)
                    {
                        // Get the school info for each favorite to save into prefs
                        self.getNewSchoolInfo(favs)
                    }
                    
                    // Post a notification that the favorite teams have been updated
                    NotificationCenter.default.post(name: Notification.Name("FavoriteTeamsUpdated"), object: nil)
                }
                else
                {
                    print ("No Favorites Team")
                }
            }
            else
            {
                print("User Favorite Teams Failed")
            }
        }
    }

    // MARK: - Get School Info

    private func getNewSchoolInfo(_ teams : Array<Any>)
    {
        // Build an array of schoolIds
        var schoolIds = [] as Array<String>
        
        for team in teams
        {
            let item = team  as! Dictionary<String, Any>
            let schoolId  = item[kNewSchoolIdKey] as! String
            
            schoolIds.append(schoolId)
        }

        NewFeeds.getSchoolInfoForSchoolIds(schoolIds) { error in
            if error == nil
            {
                print("Download school info success")
            }
            else
            {
                print("Download school info error")
            }
        }
    }

    // MARK: - Tab Bar Delegate Methods
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)
    {
        // Notify the rest of the app that the tab bar changed
        NotificationCenter.default.post(name: Notification.Name("TabBarChanged"), object: nil)
        
        if (self.selectedIndex == 0)
        {
            // Call Tracking
            TrackingManager.trackState(featureName: "latest-home", trackingGuid: SharedData.newsTabBaseGuid, cData: kEmptyTrackingContextData)
        }
        else if (self.selectedIndex == 1)
        {
            // Call Tracking
            TrackingManager.trackState(featureName: "following-home", trackingGuid: SharedData.followingTabBaseGuid, cData: kEmptyTrackingContextData)
        }
        if (self.selectedIndex == 2)
        {
            // Call Tracking
            TrackingManager.trackState(featureName: "score-home", trackingGuid: SharedData.scoresTabBaseGuid, cData: kEmptyTrackingContextData)
        }
    }

    // MARK: - Login Landing VC Delegate
    
    func loginLandingFinished()
    {
        let firstVC = self.viewControllers?[0]
        firstVC?.dismiss(animated: true, completion: {
            
            // Notify the rest of the app that login is finished
            NotificationCenter.default.post(name: Notification.Name("LoginFinished"), object: nil)
            
            // Show the tracking dialog from the newsVC
            //NotificationCenter.default.post(name: Notification.Name("ShowTrackingDialog"), object: nil)
            
            // Deferred Deep Linking
            let latestParameters = Branch.getInstance().getLatestReferringParamsSynchronous()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.showDeepLink(parameters: latestParameters!)
            
            // Check if there is a canonicalURL in the parameters to decide whether to show the tool tips right away or next launch
            let canonicalUrl = latestParameters!["$canonical_url"] as? String ?? ""
            
            if (canonicalUrl.count == 0)
            {
                // Set the launch count to 1 so the tooltips show
                kUserDefaults.setValue(NSNumber.init(integerLiteral: 1), forKey: kAppLaunchCountKey)
                
                // Notify the app to show the tool tips
                NotificationCenter.default.post(name: Notification.Name("AppActiveNotification"), object: nil)
            }
            else
            {
                kUserDefaults.setValue(NSNumber.init(integerLiteral: 0), forKey: kAppLaunchCountKey)
            }
        })
    }
    
    // MARK: - Show Login Home VC
    
    func showLoginHomeVC()
    {
        // Set the selected tab to the default
        self.selectedIndex = kDefaultTabIndex
        
        // Show the login page on top of the first VC
        loginLandingVC = LoginLandingViewController(nibName: "LoginLandingViewController", bundle: nil)
        loginLandingVC.delegate = self
        loginLandingNav = TopNavigationController()
        loginLandingNav.viewControllers = [loginLandingVC]
        loginLandingNav.modalPresentationStyle = .fullScreen
        
        let firstVC = self.viewControllers?[0]
        firstVC?.present(loginLandingNav, animated: false)
        {
            
        }
    }
    
    // MARK: - Show OneTrust Preference Center
    
    private func showOneTrustPreferenceCenter()
    {
        let oneTrustShown = kUserDefaults.bool(forKey: kOneTrustShownKey)
        
        if (oneTrustShown == false)
        {
            // Initialize and show the OneTrust Preference Center
            OTPublishersHeadlessSDK.shared.setupUI(self, UIType: .preferenceCenter)
            OTPublishersHeadlessSDK.shared.showPreferenceCenterUI()
                
            kUserDefaults.setValue(true, forKey: kOneTrustShownKey)
        }
    }
    
    // MARK: - Deep Link Tab Switch
    
    @objc private func switchToLatestTab(notification: Notification)
    {
        self.selectedIndex = 0
        
        let type = notification.userInfo?["type"] as? String
        
        switch type
        {
        case "web":
            
            // Add a little delay so the screen can settle down
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                NotificationCenter.default.post(name: Notification.Name("OpenLatestWebBrowser"), object: self, userInfo: notification.userInfo)
            }
        case "career":
            
            // Add a little delay so the screen can settle down
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                NotificationCenter.default.post(name: Notification.Name("OpenLatestCareerDeepLink"), object: self, userInfo: notification.userInfo)
            }
        case "team":
            
            // Add a little delay so the screen can settle down
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                NotificationCenter.default.post(name: Notification.Name("OpenLatestTeamDeepLink"), object: self, userInfo: notification.userInfo)
            }
        case "user":
            
            // Add a little delay so the screen can settle down
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                NotificationCenter.default.post(name: Notification.Name("OpenLatestUserDeepLink"), object: self, userInfo: notification.userInfo)
            }
        case "arena":
            
            // Add a little delay so the screen can settle down
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                NotificationCenter.default.post(name: Notification.Name("OpenLatestArenaDeepLink"), object: self, userInfo: notification.userInfo)
            }
        default:
            return
        }
    }
    
    @objc private func switchToFollowingTab(notification: Notification)
    {
        self.selectedIndex = 1
        
        let type = notification.userInfo?["type"] as? String
        
        switch type
        {
        case "web":
            
            // Add a little delay so the screen can settle down
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                NotificationCenter.default.post(name: Notification.Name("OpenFollowingWebBrowser"), object: self, userInfo: notification.userInfo)
            }
        case "career":
            
            // Add a little delay so the screen can settle down
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                NotificationCenter.default.post(name: Notification.Name("OpenFollowingCareerDeepLink"), object: self, userInfo: notification.userInfo)
            }
        case "team":
            
            // Add a little delay so the screen can settle down
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                NotificationCenter.default.post(name: Notification.Name("OpenFollowingTeamDeepLink"), object: self, userInfo: notification.userInfo)
            }
        default:
            return
        }
    }
    
    @objc private func switchToScoresTab(notification: Notification)
    {
        self.selectedIndex = 2
        
        let type = notification.userInfo?["type"] as? String
        
        switch type
        {
        case "web": // Most common case
            
            // Add a little delay so the screen can settle down
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                NotificationCenter.default.post(name: Notification.Name("OpenScoresWebBrowser"), object: self, userInfo: notification.userInfo)
            }
        case "career": // Probably won't get used
            
            // Add a little delay so the screen can settle down
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                NotificationCenter.default.post(name: Notification.Name("OpenScoresCareerDeepLink"), object: self, userInfo: notification.userInfo)
            }
        case "team": // Probably won't get used
            
            // Add a little delay so the screen can settle down
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                NotificationCenter.default.post(name: Notification.Name("OpenScoresTeamDeepLink"), object: self, userInfo: notification.userInfo)
            }
        default:
            return
        }
    }
    
    // MARK: - Logout Notification
    
    @objc private func logoutNotification(notification: Notification)
    {
        // Show the Login Home VC
        self.showLoginHomeVC()
        
        // Clear out the notifications channels
        NotificationManager.clearAirshipNotifications()
    }
    
    // MARK: - Add/Remove PBP Tab Item
    
    func showPlayByPlay()
    {
        LegacyFeeds.getPlayByPlayStatus { result, error in
            
            if (error == nil)
            {
                print("PBP Status Success")
                
                if (result!["game"] is NSNull)
                {
                    print("Null Game")
                    
                    self.addPlayByPlayTab(urlString: "https://www.maxpreps.com/games/5-10-2023/jv-football-23/maxpreps-vs-maxpreps-b.htm?c=ZXsbzbY4mkyKuyOiqsV4zA")
                }
                else
                {
                    print("Game Data Present")
                    
                    let game = result!["game"] as! Dictionary<String,Any>
                    let scorers = game["Scorers"] as! Array<Dictionary<String,Any>>
                    var scoringUrl = "https://www.maxpreps.com"
                    for scorer in scorers
                    {
                        let membershipId = scorer["MembershipId"] as! String
                        let userId = kUserDefaults.string(forKey: kUserIdKey)
                        
                        if (userId == membershipId)
                        {
                            scoringUrl = scorer["ScoringUrl"] as! String
                        }
                    }
                    
                    self.addPlayByPlayTab(urlString: scoringUrl)
                }
                
                /*
                 some : 4 elements
                   ▿ 0 : 2 elements
                     - key : "took"
                     - value : 4
                   ▿ 1 : 2 elements
                     - key : "total"
                     - value : 1
                   ▿ 2 : 2 elements
                     - key : "game"
                     ▿ value : 9 elements
                       ▿ 0 : 2 elements
                         - key : MinsRemainingInGame
                         - value : 179.80677225
                       ▿ 1 : 2 elements
                         - key : Duration
                         - value : 180
                       ▿ 2 : 2 elements
                         - key : Id
                         - value : 03cbb051-0ceb-4025-a5e8-c66ab85d3f2a
                       ▿ 3 : 2 elements
                         - key : UpdateStamp
                         - value : 2023-04-27T17:38:58Z
                       ▿ 4 : 2 elements
                         - key : Date
                         - value : 2023-04-27T17:40:00Z
                       ▿ 5 : 2 elements
                         - key : HasScorer
                         - value : 1
                       ▿ 6 : 2 elements
                         - key : MinsUntilGameTime
                         - value : 0.19322775
                       ▿ 7 : 2 elements
                         - key : ContestState
                         - value : 2
                       ▿ 8 : 2 elements
                         - key : Scorers
                         ▿ value : 1 element
                           ▿ 0 : 2 elements
                             ▿ 0 : 2 elements
                               - key : MembershipId
                               - value : 06922024-f762-496e-a5b9-42ae1d411856
                             ▿ 1 : 2 elements
                               - key : ScoringUrl
                               - value : https://t.maxpreps.com/447hXSA
                   ▿ 3 : 2 elements
                     - key : "timedOut"
                     - value : 0
                 */
            }
            else
            {
                print("PBP Status Failed")
            }
        }
    }
    
    func hidePlayByPlay()
    {
        if (self.viewControllers?.count == 4)
        {
            self.viewControllers?.remove(at: 3)
        }
    }
    
    private func addPlayByPlayTab(urlString: String)
    {
        let pbpVC = PBPWebViewController(nibName: "PBPWebViewController", bundle: nil)
        pbpVC.titleString = "Live Scoring"
        pbpVC.urlString = urlString
        pbpVC.titleColor = UIColor.mpWhiteColor()
        pbpVC.navColor = UIColor.mpBlueColor()
        pbpVC.allowRotation = false
        pbpVC.showScrollIndicators = false
        pbpVC.showLoadingOverlay = true
        pbpVC.tabBarVisible = true
        pbpVC.enableAdobeQueryParameter = false
        pbpVC.trackingContextData = kEmptyTrackingContextData
        pbpVC.trackingKey = "scores-home"
        
        self.viewControllers?.append(pbpVC)
        
        // Load the tab bar icons and text color
        let tabBarItem3 = self.tabBar.items![3]
        
        let unselectedImage3 = UIImage(named: "PBPIcon")
        let selectedImage3 = UIImage(named: "PBPIconSelected")
        
        tabBarItem3.image = unselectedImage3!.withRenderingMode(.alwaysOriginal)
        tabBarItem3.selectedImage = selectedImage3!.withRenderingMode(.alwaysOriginal)
        
        tabBarItem3.title = "Scoring"
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.delegate = self
        
        // Set the selected tab to the default
        self.selectedIndex = kDefaultTabIndex
        
        /*
        // Calculate the top and bottom safe areas for use elsewhere in the app
        let window = UIApplication.shared.windows[0]
        
        if (window.safeAreaInsets.top > 0)
        {
            SharedData.topNotchHeight = Int(window.safeAreaInsets.top) - kStatusBarHeight;
        }
        else
        {
            SharedData.topNotchHeight = 0;
        }
        
        SharedData.bottomSafeAreaHeight = Int(window.safeAreaInsets.bottom)
        
        print("Top Pad: " + String(SharedData.topNotchHeight) + ", Bottom Pad: " + String( SharedData.bottomSafeAreaHeight))
        
        // Set the overall window background color so navigation looks better
        window.backgroundColor = UIColor.mpWhiteColor()
        */
        // Show a copy of the splash screen momentarily
        // This prevents the screen from flashing while the loginVC loads
        let splashView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight))
        splashView.backgroundColor = UIColor.mpWhiteColor()
        self.view.addSubview(splashView)
        
        let splashImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 210.0, height: 54.0))
        splashImage.center = CGPoint(x: kDeviceWidth / 2.0, y: kDeviceHeight - 443)
        splashImage.contentMode = .scaleAspectFit
        splashImage.isOpaque = true
        splashImage.image = UIImage(named: "LaunchScreenIcon.png")
        splashView.addSubview(splashImage)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            splashView.removeFromSuperview()
        }

        // Load the tab bar icons and text color
        let tabBarItem0 = self.tabBar.items![0]
        let tabBarItem1 = self.tabBar.items![1]
        let tabBarItem2 = self.tabBar.items![2]
        
        let unselectedImage0 = UIImage(named: "LatestIcon")
        let selectedImage0 = UIImage(named: "LatestIconSelected")
        let unselectedImage1 = UIImage(named: "FollowingIcon")
        let selectedImage1 = UIImage(named: "FollowingIconSelected")
        let unselectedImage2 = UIImage(named: "ScoresIcon")
        let selectedImage2 = UIImage(named: "ScoresIconSelected")
        
        tabBarItem0.image = unselectedImage0!.withRenderingMode(.alwaysOriginal)
        tabBarItem0.selectedImage = selectedImage0!.withRenderingMode(.alwaysOriginal)
        
        tabBarItem1.image = unselectedImage1!.withRenderingMode(.alwaysOriginal)
        tabBarItem1.selectedImage = selectedImage1!.withRenderingMode(.alwaysOriginal)
        
        tabBarItem2.image = unselectedImage2!.withRenderingMode(.alwaysOriginal)
        tabBarItem2.selectedImage = selectedImage2!.withRenderingMode(.alwaysOriginal)
        
        // Added for iOS 15
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.mpOffWhiteNavColor()
        
        let selectedAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.mpBoldFontWith(size: 12), NSAttributedString.Key.foregroundColor: UIColor.mpBlackColor(), NSAttributedString.Key.paragraphStyle: NSParagraphStyle.default]
        
        let normalAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 12), NSAttributedString.Key.foregroundColor: UIColor.mpDarkGrayColor(), NSAttributedString.Key.paragraphStyle: NSParagraphStyle.default]
        
        appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        
        appearance.inlineLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = selectedAttributes
        
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes
                
        self.tabBar.standardAppearance = appearance
        
        if #available(iOS 15.0, *)
        {
            self.tabBar.scrollEdgeAppearance = self.tabBar.standardAppearance
        }

        // Add a handler to update the user info
        NotificationCenter.default.addObserver(self, selector: #selector(getUserInfo), name: Notification.Name("GetUserInfo"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(switchToLatestTab), name: Notification.Name("LatestDeepLink"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(switchToFollowingTab), name: Notification.Name("FollowingDeepLink"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(switchToScoresTab), name: Notification.Name("ScoresDeepLink"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(logoutNotification), name: Notification.Name("Logout"), object: nil)
        
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        

    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // This prevents modals on other tabs from triggering the startup sequence
        if (self.selectedIndex != kDefaultTabIndex)
        {
            return
        }
        
        // Show the ATT dialog from the newsVC (this is now done in this class)
        //NotificationCenter.default.post(name: Notification.Name("ShowTrackingDialog"), object: nil)
        
        // Show the tracking dialog if it has not been set
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5)
        {
            let status = ATTrackingManager.trackingAuthorizationStatus
            
            if (status == .notDetermined)
            {
                // Call tracking authorization
                ATTrackingManager.requestTrackingAuthorization { status in
                    
                }
            }
        }
        
        if (kUserDefaults.string(forKey: kUserIdKey) == kEmptyGuid)
        {
            // Show the Login Home VC
            self.showLoginHomeVC()
            
            // Clear out the notifications channels
            NotificationManager.clearAirshipNotifications()
        }
        else if (kUserDefaults.string(forKey: kUserIdKey) == kTestDriveUserId)
        {
            // Just get the School Info
            if let favs = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
            {
                print ("Test Drive user favorites count: " + String(favs.count))
                
                if (favs.count > 0)
                {
                    // Get the school info for each favorite to save into prefs
                    self.getNewSchoolInfo(favs)
                }
            }
            
            // Clear out the notifications channels
            NotificationManager.clearAirshipNotifications()
        }
        else
        {
            // Get the user favorites if a real user
            self.getUserInfo()
            self.getUserFavoriteAthletes()
            self.getUserFavoriteTeams()
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.registerForNotifications()
            
            // Show OneTrust
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5)
            {
                self.showOneTrustPreferenceCenter()
            }
        }
    }
    
    override var shouldAutorotate: Bool
    {
        return ((self.selectedViewController?.shouldAutorotate) != nil)
        //return false
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation
    {
        return self.selectedViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
        //return .portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        return self.selectedViewController?.supportedInterfaceOrientations ?? .portrait
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
