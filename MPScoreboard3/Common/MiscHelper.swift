//
//  MiscHelper.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/9/21.
//

import UIKit
import SystemConfiguration
import SystemConfiguration.CaptiveNetwork
import AppTrackingTransparency
import WebKit
import BranchSDK
import OTPublishersHeadlessSDK

class MiscHelper: NSObject
{
    // MARK: - Is TestFlight Install
    
    class func isTestFlightInstallation() -> Bool
    {
        return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }
    
    // MARK: - Validate Password
    
    class func isValidPassword(_ passwordString: String) -> Bool
    {
        //let password = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[$@$#!%*?&])(?=.*[A-Z]).{6,}$")
        
        // Uppercase, lowercase, and number
        let password = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[0-9])(?=.*[A-Z]).{8,}$")
        
        return password.evaluate(with: passwordString)
    }
    
    // MARK: - Validate Email
    
    class func isValidEmailAddress(_ emailAddressString: String) -> Bool
    {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        
        do
        {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
            
        }
        catch let error as NSError
        {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        
        return  returnValue
    }
    
    // MARK: - Logout User
    
    class func logoutUser()
    {
        // Clear out the user's prefs
        kUserDefaults.setValue(kEmptyGuid, forKey: kUserIdKey)
        
        let emptyTeamFavs = [] as Array<Any>
        let emptyAthleteFavs = [] as Array<Any>
        kUserDefaults.setValue(emptyTeamFavs, forKey: kNewUserFavoriteTeamsArrayKey)
        kUserDefaults.setValue(emptyAthleteFavs, forKey: kUserFavoriteAthletesArrayKey)
        
        //let emptyDict = [:] as Dictionary<String,Any>
        //kUserDefaults.setValue(emptyDict, forKey: kContestNotificationsDictionaryKey)
        
        // Removed in build 211016
        //kUserDefaults.setValue(emptyFavs, forKey: kUserScoreboardsArrayKey)
        
        let emptySchoolInfoDictionary = [:] as Dictionary<String,Any>
        let emptyAdminRolesDictionary = [:] as Dictionary<String,Any>
        kUserDefaults.setValue(emptySchoolInfoDictionary, forKey: kNewSchoolInfoDictionaryKey)
        kUserDefaults.setValue(emptyAdminRolesDictionary, forKey: kUserAdminRolesDictionaryKey)
        
        let emptyArray = [] as Array<Any>
        kUserDefaults.setValue(emptyArray, forKey: kUserAdminRolesArrayKey)
        
        kUserDefaults.setValue("", forKey: kUserEmailKey)
        kUserDefaults.setValue("", forKey: kUserFirstNameKey)
        kUserDefaults.setValue("", forKey: kUserLastNameKey)
        kUserDefaults.setValue("", forKey: kUserZipKey)
        kUserDefaults.setValue("", forKey: kUserPhotoUrlKey)
        kUserDefaults.setValue("", forKey: kUserCareerPhotoUrlKey)
        kUserDefaults.setValue("", forKey: kUserTypeKey)
        kUserDefaults.setValue("", forKey: kUserGenderKey)
        kUserDefaults.setValue("", forKey: kUserBirthdateKey)
        kUserDefaults.setValue("", forKey: kTokenBusterKey)
        kUserDefaults.setValue(NSNumber(integerLiteral: 0), forKey: kSelectedFavoriteIndexKey)
        kUserDefaults.setValue(NSNumber(integerLiteral: 0), forKey: kSelectedFavoriteSectionKey)
        kUserDefaults.setValue(kDefaultSchoolLocation, forKey: kCurrentLocationKey)
        
        // Reset the tool tip keys
        kUserDefaults.setValue(NSNumber.init(integerLiteral: 0), forKey: kAppLaunchCountKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipOneShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipTwoShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipThreeShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipFourShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipFiveShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipSixShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipSevenShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipEightShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipNineShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kVideoUploadToolTipShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kTeamVideoToolTipShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kCareerVideoToolTipShownKey)
        
        // Log out of Branch
        Branch.getInstance().logout()
        
        //kUserDefaults.synchronize()
        
        // Clear the cookie jar
        let cookieJar = HTTPCookieStorage.shared

        for cookie in cookieJar.cookies!
        {
            if cookie.domain.contains(".maxpreps.com")
            {
                cookieJar.deleteCookie(cookie)
            }
        }
        
        // Clear the WKWebView cookies
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes())
        { records in records.forEach { record in
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            print("Cookie ::: \(record) deleted")
            
        }}
        
        // Empty the WKWebView caches
        WKWebsiteDataStore.default().removeData(ofTypes: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache], modifiedSince: Date(timeIntervalSince1970: 0)) {
            print("Caches Emptied")
        }
    }
    
    // MARK: - Save User Info

    class func saveUserInfo(userId: String, email: String, firstName: String, lastName: String, zip: String, photoUrl: String,careerPhotoUrl: String, type: String, birthdate: String, gender: String, adminRoles: Array<Dictionary<String,Any>>)
    {
        kUserDefaults.setValue(userId, forKey: kUserIdKey)
        kUserDefaults.setValue(email, forKey: kUserEmailKey)
        kUserDefaults.setValue(firstName, forKey: kUserFirstNameKey)
        kUserDefaults.setValue(lastName, forKey: kUserLastNameKey)
        kUserDefaults.setValue(zip, forKey: kUserZipKey)
        kUserDefaults.setValue(photoUrl, forKey: kUserPhotoUrlKey)
        kUserDefaults.setValue(careerPhotoUrl, forKey: kUserCareerPhotoUrlKey)
        kUserDefaults.setValue(type, forKey: kUserTypeKey)
        kUserDefaults.setValue(gender, forKey: kUserGenderKey)
        
        // The birthdate is in UTC format an needs to be converted
        let dateFormatter = DateFormatter()
        dateFormatter.isLenient = true
        dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
        let birthdateObj = dateFormatter.date(from: birthdate)
        
        // It's possible that the birthdate object couldn't be created
        if (birthdateObj != nil)
        {
            dateFormatter.dateFormat = "M/d/yyyy"
            let convertedDate = dateFormatter.string(from: birthdateObj!)
            kUserDefaults.setValue(convertedDate, forKey: kUserBirthdateKey)
        }
        else
        {
            kUserDefaults.setValue("", forKey: kUserBirthdateKey)
        }
        
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
        /*
         let kUserAdminRolesArrayKey = "UserAdminRolesArray"    // Array
         let kRoleNameKey = "RoleName"
         let kRoleTitleKey = "RoleTitle"
         let kRoleSchoolIdKey = "SchoolId"
         let kRollAllSeasonIdKey = "AccessId2"
         let kRoleSchoolNameKey = "SchoolName"
         let kRoleSportKey = "Sport"
         let kRoleGenderKey = "Gender"
         let kRoleTeamLevelKey = "TeamLevel"
         */
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
            
            /*
             let kEmptyGuid = "00000000-0000-0000-0000-000000000000"
             let kStandardAdminUserId = "01"
             let kAffiliateAdminUserId = "02"
             let kStateAssociationAdminUserId = "03"
             let kPhotographerUserId = "04"
             let kWriterUserId = "05"
             let kStatSupplierUserId = "06"
             let kTournamentDirectorUserId = "07"
             let kMeetManagerUserId = "08"
             let kCareerAdminUserId = "09"
             */
            
            roleDictionary.updateValue(refactoredRole, forKey: roleKey)
            rolesArray.append(refactoredRole)
        }
        // Clear out existing roles
        kUserDefaults.removeObject(forKey: kUserAdminRolesDictionaryKey)
        kUserDefaults.removeObject(forKey: kUserAdminRolesArrayKey)
        
        // Save to prefs
        kUserDefaults.setValue(roleDictionary, forKey: kUserAdminRolesDictionaryKey)
        kUserDefaults.setValue(rolesArray, forKey: kUserAdminRolesArrayKey)
    }
    
    // MARK: - Tracking Status
    
    class func trackingStatusForAds() -> String
    {
        let status = ATTrackingManager.trackingAuthorizationStatus
        
        switch status
        {
        case .notDetermined:
            return "not_determined"
        case .denied:
            return "denied"
        case .restricted:
            return "restricted"
        case .authorized:
            return "authorized"
        default:
            return "unknown"
        }
    }
    
    // MARK: - Is Athlete My Favorite Athlete
    
    class func isAthleteMyFavoriteAthlete(careerId: String) -> Bool
    {
        // Look for this athlete in the favoriteAthletes array
        var favoriteAthletesIdentifierArray = [] as Array<String>
        
        if let favoriteAthletes = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
        {
            for favoriteAthlete in favoriteAthletes
            {
                let item = favoriteAthlete  as! Dictionary<String, Any>
                let careerProfileId = item["careerProfileId"] as! String
                favoriteAthletesIdentifierArray.append(careerProfileId)
            }
        }
        
        // Check to see if the athlete is already a favorite
       let result = favoriteAthletesIdentifierArray.filter { $0 == careerId }
        
        if (result.isEmpty == false)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    // MARK: - Is Team My Favorite Team
    
    class func isTeamMyFavoriteTeam(schoolId: String, gender: String, sport: String, teamLevel: String, season: String) -> Bool
    {
        // Build the favorite team identifier array so it we know whether to show the follow buttons in the teamDetailVC
        var favoriteTeamIdentifierArray = [] as Array<String>
        
        if let favorites = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
        {
            for item in favorites
            {
                let favorite = item as! Dictionary<String, Any>
                
                let favoriteGender = favorite[kNewGenderKey] as! String
                let favoriteSport = favorite[kNewSportKey] as! String
                let favoriteTeamLevel = favorite[kNewLevelKey] as! String
                let favoriteSchoolId = favorite[kNewSchoolIdKey] as! String
                let favoriteSeason = favorite[kNewSeasonKey] as! String
                            
                let identifier = String(format: "%@_%@_%@_%@_%@", favoriteSchoolId, favoriteGender, favoriteSport, favoriteTeamLevel, favoriteSeason)
                            
                favoriteTeamIdentifierArray.append(identifier)
            }
        }
        
        // Check to see if the team is already a favorite
        let identifier = String(format: "%@_%@_%@_%@_%@", schoolId, gender, sport, teamLevel, season)
        let result = favoriteTeamIdentifierArray.filter { $0 == identifier }
        
        if (result.isEmpty == false)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    class func isTeamMyFavoriteTeamWithId(schoolId: String, gender: String, sport: String, teamLevel: String, season: String) -> (isFavorite: Bool, teamId: Int)
    {
        // Build the favorite team identifier array so it we know whether to show the follow buttons in the teamDetailVC
        var favoriteTeamIdentifierArray = [] as Array<String>
        var favoriteTeamIdArray = [] as Array<Int>
        
        if let favorites = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
        {
            for item in favorites
            {
                let favorite = item as! Dictionary<String, Any>
                
                let favoriteGender = favorite[kNewGenderKey] as! String
                let favoriteSport = favorite[kNewSportKey] as! String
                let favoriteTeamLevel = favorite[kNewLevelKey] as! String
                let favoriteSchoolId = favorite[kNewSchoolIdKey] as! String
                let favoriteSeason = favorite[kNewSeasonKey] as! String
                let favoriteTeamId = favorite[kNewUserfavoriteTeamIdKey] as! Int
                            
                let identifier = String(format: "%@_%@_%@_%@_%@", favoriteSchoolId, favoriteGender, favoriteSport, favoriteTeamLevel, favoriteSeason)
                            
                favoriteTeamIdentifierArray.append(identifier)
                favoriteTeamIdArray.append(favoriteTeamId)
            }
        }
        
        // Check to see if the team is already a favorite
        let identifier = String(format: "%@_%@_%@_%@_%@", schoolId, gender, sport, teamLevel, season)
        let result = favoriteTeamIdentifierArray.filter { $0 == identifier }
        
        if (result.isEmpty == false)
        {
            // Get the index of the identifier
            let index = favoriteTeamIdentifierArray.firstIndex(of: identifier)
            let teamId = favoriteTeamIdArray[index!]
            return (true, teamId)
        }
        else
        {
            return (false, 0)
        }
    }
    
    // MARK: - User Team Role
    
    class func userTeamRole(schoolId: String, allSeasonId: String) -> String
    {
        // The highest role for a team is returned
        
        let adminRoles = kUserDefaults.dictionary(forKey: kUserAdminRolesDictionaryKey)
        let coachRoleKey = schoolId + "_" + allSeasonId
        let adRoleKey = schoolId + "_" + kEmptyGuid
        
        if (adminRoles![kStandardAdminUserId] != nil)
        {
            return "school administrator"
        }
        
        if (adminRoles![adRoleKey] != nil)
        {
            let adminRole = adminRoles![adRoleKey] as! Dictionary<String,Any>
            let roleName = adminRole[kRoleNameKey] as! String
            
            if (roleName == "Athletic Director")
            {
                return "athletic director"
            }
        }
        
        if (adminRoles![coachRoleKey] != nil)
        {
            let adminRole = adminRoles![coachRoleKey] as! Dictionary<String,Any>
            let roleTitle = adminRole[kRoleTitleKey] as! String
            return roleTitle.lowercased()
        }
        
        return "no role assigned"
    }
    
    // MARK: - Can User Edit Career
    
    class func userCanEditCareer() -> (canEdit: Bool, careerId: String, isAthlete: Bool, isParent: Bool, isOther: Bool)
    {
        let adminRoles = kUserDefaults.dictionary(forKey: kUserAdminRolesDictionaryKey)
        
        var parentFound = false
        var athleteFound = false
        var parentCareerId = ""
        var athleteCareerId = ""
        
        if ((adminRoles![kCareerAdminParentUserId] == nil) && (adminRoles![kCareerAdminAthleteUserId] == nil))
        {
            return (false, "", false, false, false)
        }
        
        if (adminRoles![kCareerAdminParentUserId] != nil)
        {
            let adminRole = adminRoles![kCareerAdminParentUserId] as! Dictionary<String,Any>
            parentCareerId = adminRole[kRoleCareerIdKey] as! String
            let permissions = adminRole[kRolePermissionsKey] as! Array<Dictionary<String,String>>
            
            // Look for "CAREERADMIN_ATHLETE" or ""CAREERADMIN_PARENT" to figure out if this is the athlete or parent
            for permission in permissions
            {
                let identifier = permission["identifier"]
                if (identifier == "CAREERADMIN_PARENT")
                {
                    parentFound = true
                }
            }
        }
        
        if (adminRoles![kCareerAdminAthleteUserId] != nil)
        {
            let adminRole = adminRoles![kCareerAdminAthleteUserId] as! Dictionary<String,Any>
            athleteCareerId = adminRole[kRoleCareerIdKey] as! String
            let permissions = adminRole[kRolePermissionsKey] as! Array<Dictionary<String,String>>
            
            // Look for "CAREERADMIN_ATHLETE" or ""CAREERADMIN_PARENT" to figure out if this is the athlete or parent
            for permission in permissions
            {
                let identifier = permission["identifier"]
                if (identifier == "CAREERADMIN_ATHLETE")
                {
                    athleteFound = true
                }
            }
        }
            
        if (athleteFound == false) && (parentFound == true)
        {
            return (true, parentCareerId, false, true, false)
        }
        else if (athleteFound == true) && (parentFound == false)
        {
            return (true, athleteCareerId, true, false, false)
        }
        else if (athleteFound == true) && (parentFound == true)
        {
            return (true, parentCareerId, true, true, false)
        }
        else
        {
            return (true, kEmptyGuid, false, false, true)
        }

    }
    
    class func userCanEditSpecificCareer(careerId: String) -> (canEdit: Bool, isAthlete: Bool, isParent: Bool)
    {
        let adminRolesDictionary = kUserDefaults.dictionary(forKey: kUserAdminRolesDictionaryKey)
        let adminRolesArray = kUserDefaults.array(forKey: kUserAdminRolesArrayKey)
        
        var parentFound = false
        var athleteFound = false
        
        if ((adminRolesDictionary![kCareerAdminParentUserId] == nil) && (adminRolesDictionary![kCareerAdminAthleteUserId] == nil))
        {
            return (false, false, false)
        }
        
        for item in adminRolesArray!
        {
            let adminRole = item as! Dictionary<String,Any>
            let testCareerId = adminRole[kRoleCareerIdKey] as! String
            let permissions = adminRole[kRolePermissionsKey] as! Array<Dictionary<String,String>>
            
            if (careerId == testCareerId)
            {
                // Look for "CAREERADMIN_ATHLETE" or ""CAREERADMIN_PARENT" to figure out if this is the athlete or parent
                for permission in permissions
                {
                    let identifier = permission["identifier"]
                    if (identifier == "CAREERADMIN_PARENT")
                    {
                        parentFound = true
                    }
                    else if (identifier == "CAREERADMIN_ATHLETE")
                    {
                        athleteFound = true
                    }
                }
            }
        }
        
        if (athleteFound == false) && (parentFound == true)
        {
            return (true, false, true)
        }
        else if (athleteFound == true) && (parentFound == false)
        {
            return (true, true, false)
        }
        else if (athleteFound == true) && (parentFound == true)
        {
            return (true, true, true)
        }
        else
        {
            return (false, false, false)
        }
    }
    
    // MARK: - Is User a Coach
    
    class func userIsCoach() -> (isCoach: Bool, schoolId: String, ssid: String)
    {
        var userIsCoach = false
        var schoolId = ""
        var ssid = ""
        
        // Search the profile for the head coach, assistant coach, or statistician role
        let adminRoles = kUserDefaults.dictionary(forKey: kUserAdminRolesDictionaryKey)
        let allRoles = adminRoles?.values
        
        for item in allRoles!
        {
            let role = item as! Dictionary<String,Any>
            let roleName = role[kRoleNameKey] as! String
            
            if ((roleName == "Head Coach") || (roleName == "Assistant Coach") || (roleName == "Statistician"))
            {
                // The schoolId and ssid are needed for the coach user profile feed
                userIsCoach = true
                schoolId = role[kRoleSchoolIdKey] as! String
                ssid = role[kRoleSSIDKey] as! String
                break
            }
        }
        
        return (userIsCoach, schoolId, ssid)
    }
    
    // MARK: - Is User an AD
    
    class func userIsAnAD() -> (isAD: Bool, schoolId: String, ssid: String)
    {
        var userIsAD = false
        var schoolId = ""
        
        // Search the profile for the head coach, assistant coach, or statistician role
        let adminRoles = kUserDefaults.dictionary(forKey: kUserAdminRolesDictionaryKey)
        let allRoles = adminRoles?.values
        
        for item in allRoles!
        {
            let role = item as! Dictionary<String,Any>
            let roleName = role[kRoleNameKey] as! String
            
            if (roleName == "Athletic Director")
            {
                // The schoolId is needed for the AD user profile feed
                userIsAD = true
                schoolId = role[kRoleSchoolIdKey] as! String
                break
            }
        }
        
        return (userIsAD, schoolId, kEmptyGuid)
    }
    
    // MARK: - Is User an Admin
    
    class func isUserAnAdmin(schoolId: String, allSeasonId: String) -> Bool
    {
        var userIsAdmin = false
        let adminRoles = kUserDefaults.dictionary(forKey: kUserAdminRolesDictionaryKey)
        let coachRoleKey = schoolId + "_" + allSeasonId
        let adRoleKey = schoolId + "_" + kEmptyGuid
        
        if (adminRoles![kStandardAdminUserId] != nil)
        {
            userIsAdmin = true
        }
        
        if (adminRoles![adRoleKey] != nil)
        {
            let adminRole = adminRoles![adRoleKey] as! Dictionary<String,Any>
            let roleName = adminRole[kRoleNameKey] as! String
            
            if (roleName == "Athletic Director")
            {
                userIsAdmin = true
            }
        }
        
        if (adminRoles![coachRoleKey] != nil)
        {
            let adminRole = adminRoles![coachRoleKey] as! Dictionary<String,Any>
            let roleName = adminRole[kRoleNameKey] as! String
            
            if ((roleName == "Head Coach") || (roleName == "Assistant Coach") || (roleName == "Statistician"))
            {
                userIsAdmin = true
            }
        }
        
        return userIsAdmin
    }
    
    // MARK: - Privacy
    
    class func isUserMinorAged() -> Bool
    {
        if ((kUserDefaults.string(forKey: kUserIdKey) != kTestDriveUserId) && (kUserDefaults.string(forKey: kUserIdKey) != kEmptyGuid))
        {
            // Real User
            let birthdateString = kUserDefaults.string(forKey: kUserBirthdateKey) ?? ""
            
            if (birthdateString != "")
            {
                // Get the age of the user
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "M/d/yyyy"
                let birthdate = dateFormatter.date(from: birthdateString)
                if (birthdate != nil)
                {
                    let timeInterval = birthdate!.timeIntervalSinceNow
                    let age = -timeInterval / (365.25 * 24 * 60 * 60)
                    print(String(age))
                    
                    if (age < 18)
                    {
                        print("Too young")
                        return true
                    }
                    else
                    {
                        print("Old enough")
                        return false
                    }
                }
                else
                {
                    return false // Force to adult
                }
            }
            else
            {
                return false // Force to adult
            }
        }
        else
        {
            return false // Guest user is an adult
        }
    }
    
    class func privacyStatusForUser(consentCategory: String) -> Int8
    {
        if (self.isUserMinorAged() == true)
        {
            return 0
        }
        else
        {
            // Get the privacy status from OneTrust
            // The consentCategory is either "2" or "4"
            let consent = OTPublishersHeadlessSDK.shared.getConsentStatus(forCategory: consentCategory)
            return consent
        }
    }
    
    // MARK: - Date to Nearest 5 minutes
    
    class func dateToNearest5Minutes(date: Date) -> Date
    {
        let roundedTimeInterval = ((date.timeIntervalSinceReferenceDate / 300.0).rounded(.toNearestOrEven) * 300.0)
        let roundedDate = Date(timeIntervalSinceReferenceDate: roundedTimeInterval)
        
        return roundedDate
    }
    
    // MARK: - Year Start and End Methods
    
    class func getOneYearCalendarSpan(start: Bool) -> Date
    {
        let dateFormatter = DateFormatter()
        
        // Get the current year
        dateFormatter.dateFormat = "yyyy"
        let currentYearString = dateFormatter.string(from: Date())
        let currentYear = Int(currentYearString)!
        
        // Get the current month
        dateFormatter.dateFormat = "M"
        let currentMonth = dateFormatter.string(from: Date())
        
        print("Month: " + currentMonth + ", Year: " + currentYearString)
        
        var startYear = 0
        var endYear = 0

        switch currentMonth
        {
        case "1":
            startYear = currentYear - 1
            endYear = currentYear
        case "2":
            startYear = currentYear - 1
            endYear = currentYear
        case "3":
            startYear = currentYear - 1
            endYear = currentYear
        case "4":
            startYear = currentYear - 1
            endYear = currentYear
        case "5":
            startYear = currentYear - 1
            endYear = currentYear
        case "6":
            startYear = currentYear - 1
            endYear = currentYear
        case "7":
            startYear = currentYear - 1
            endYear = currentYear
        case "8":
            startYear = currentYear
            endYear = currentYear + 1
        case "9":
            startYear = currentYear
            endYear = currentYear + 1
        case "10":
            startYear = currentYear
            endYear = currentYear + 1
        case "11":
            startYear = currentYear
            endYear = currentYear + 1
        case "12":
            startYear = currentYear
            endYear = currentYear + 1
        default:
            startYear = 0
            endYear = 0
        }
        
        if (start == true)
        {
            let beginYearString = "8/1/" + String(startYear)
            dateFormatter.dateFormat = "M/d/yyyy"
            let beginYearDate = dateFormatter.date(from: beginYearString)
            return beginYearDate!
        }
        else
        {
            let endYearString = "7/31/" + String(endYear)
            dateFormatter.dateFormat = "M/d/yyyy"
            let endYearDate = dateFormatter.date(from: endYearString)
            return endYearDate!
        }
        
    }
    
    class func getTwoYearCalendarSpan(start: Bool) -> Date
    {
        let dateFormatter = DateFormatter()
        
        // Get the current year
        dateFormatter.dateFormat = "yyyy"
        let currentYearString = dateFormatter.string(from: Date())
        let currentYear = Int(currentYearString)!
        
        // Get the current month
        dateFormatter.dateFormat = "M"
        let currentMonth = dateFormatter.string(from: Date())
        
        print("Month: " + currentMonth + ", Year: " + currentYearString)
        
        var startYear = 0
        var endYear = 0

        switch currentMonth
        {
        case "1":
            startYear = currentYear - 1
            endYear = currentYear + 1
        case "2":
            startYear = currentYear - 1
            endYear = currentYear + 1
        case "3":
            startYear = currentYear - 1
            endYear = currentYear + 1
        case "4":
            startYear = currentYear - 1
            endYear = currentYear + 1
        case "5":
            startYear = currentYear - 1
            endYear = currentYear + 1
        case "6":
            startYear = currentYear - 1
            endYear = currentYear + 1
        case "7":
            startYear = currentYear - 1
            endYear = currentYear + 1
        case "8":
            startYear = currentYear
            endYear = currentYear + 2
        case "9":
            startYear = currentYear
            endYear = currentYear + 2
        case "10":
            startYear = currentYear
            endYear = currentYear + 2
        case "11":
            startYear = currentYear
            endYear = currentYear + 2
        case "12":
            startYear = currentYear
            endYear = currentYear + 2
        default:
            startYear = 0
            endYear = 0
        }
        
        if (start == true)
        {
            let beginYearString = "8/1/" + String(startYear)
            dateFormatter.dateFormat = "M/d/yyyy"
            let beginYearDate = dateFormatter.date(from: beginYearString)
            return beginYearDate!
        }
        else
        {
            let endYearString = "7/31/" + String(endYear)
            dateFormatter.dateFormat = "M/d/yyyy"
            let endYearDate = dateFormatter.date(from: endYearString)
            return endYearDate!
        }
        
    }
    
    class func getThreeYearCalendarSpan(start: Bool) -> Date
    {
        let dateFormatter = DateFormatter()
        
        // Get the current year
        dateFormatter.dateFormat = "yyyy"
        let currentYearString = dateFormatter.string(from: Date())
        let currentYear = Int(currentYearString)!
        
        // Get the current month
        dateFormatter.dateFormat = "M"
        let currentMonth = dateFormatter.string(from: Date())
        
        print("Month: " + currentMonth + ", Year: " + currentYearString)
        
        var startYear = 0
        var endYear = 0

        switch currentMonth
        {
        case "1":
            startYear = currentYear - 2
            endYear = currentYear + 1
        case "2":
            startYear = currentYear - 2
            endYear = currentYear + 1
        case "3":
            startYear = currentYear - 2
            endYear = currentYear + 1
        case "4":
            startYear = currentYear - 2
            endYear = currentYear + 1
        case "5":
            startYear = currentYear - 2
            endYear = currentYear + 1
        case "6":
            startYear = currentYear - 2
            endYear = currentYear + 1
        case "7":
            startYear = currentYear - 2
            endYear = currentYear + 1
        case "8":
            startYear = currentYear - 1
            endYear = currentYear + 2
        case "9":
            startYear = currentYear - 1
            endYear = currentYear + 2
        case "10":
            startYear = currentYear - 1
            endYear = currentYear + 2
        case "11":
            startYear = currentYear - 1
            endYear = currentYear + 2
        case "12":
            startYear = currentYear - 1
            endYear = currentYear + 2
        default:
            startYear = 0
            endYear = 0
        }
        
        if (start == true)
        {
            let beginYearString = "8/1/" + String(startYear)
            dateFormatter.dateFormat = "M/d/yyyy"
            let beginYearDate = dateFormatter.date(from: beginYearString)
            return beginYearDate!
        }
        else
        {
            let endYearString = "7/31/" + String(endYear)
            dateFormatter.dateFormat = "M/d/yyyy"
            let endYearDate = dateFormatter.date(from: endYearString)
            return endYearDate!
        }
        
    }
    
    // MARK: - Extract Video ID from URL
    
    class func extractVideoIdFromString(_ urlString: String) -> (String)
    {
        // This function looks for a videoId within a url string. It returns an empty string if it wasn't found
        if let urlComponents = URLComponents(url: URL(string: urlString)!, resolvingAgainstBaseURL: false)
        {
            // Skip if not www.maxpreps.com
            if let host = urlComponents.host
            {
                //print(host)
                if (host.lowercased() != "www.maxpreps.com")
                {
                    return ""
                }
            }
            
            if let qp = urlComponents.queryItems?.filter({ $0.name == "videoid" }).first
            {
                let value = qp.value
                
                // Check if this is a GUID
                if let uuid = UUID(uuidString: value!)
                {
                    print("videoid intercepted")
                    return uuid.uuidString
                }
            }
            /*
            // Disable this until a video with a query parameter of "id=" is discovered during testing
            if let qp = urlComponents.queryItems?.filter({ $0.name == "id" }).first
            {
                let value = qp.value
                
                // Check if this is a GUID
                if let uuid = UUID(uuidString: value!)
                {
                    // Skip if the urlString contains "/photographer/"
                    if (urlString.contains("/photographer/"))
                    {
                        return ""
                    }
                    else
                    {
                        print("id intercepted")
                        return uuid.uuidString
                    }
                }
            }
            */
            if let qp = urlComponents.queryItems?.filter({ $0.name == "v" }).first
            {
                let value = qp.value
                
                // Check if this is a GUID
                if let uuid = UUID(uuidString: value!)
                {
                    print("v intercepted")
                    return uuid.uuidString
                }
            }
        }
        
        return ""
    }
    
    // MARK: - Get UTC Time Offset
    
    class func getUTCTimeOffset()
    {
        /*
        LegacyFeeds.getUTCTime { (timeOffset, error) in
            if (error == nil)
            {
                SharedData.utcTimeOffset = timeOffset!
            }
            else
            {
                SharedData.utcTimeOffset = 0
            }
        }
        */
        NewFeeds.getUTCTime { timeOffset, error in
            if (error == nil)
            {
                print("Get UTC Time Success")
                SharedData.utcTimeOffset = timeOffset!
            }
            else
            {
                print("Get UTC Time Failed")
                SharedData.utcTimeOffset = 0
            }
        }
    }
    
    // MARK: - App ID Cookies
    
    class func setAppIdCookie()
    {
        let tomorrow = NSDate(timeIntervalSinceNow: 86400)
        var cookieOneValue = "devicetype%3Diphone%26appname%3Dmpscoreboard"
        
        if (SharedData.deviceType as! DeviceType == DeviceType.ipad)
        {
            cookieOneValue = "devicetype%3Dipad%26appname%3Dmpscoreboard"
        }
        
        let cookieOneProperties = [HTTPCookiePropertyKey.name:"MaxPrepsApp", HTTPCookiePropertyKey.value:cookieOneValue, HTTPCookiePropertyKey.version:"0", HTTPCookiePropertyKey.domain:".maxpreps.com", HTTPCookiePropertyKey.path:"/", HTTPCookiePropertyKey.expires:tomorrow] as [HTTPCookiePropertyKey : Any]
        
        let newCookieOne = HTTPCookie(properties: cookieOneProperties)
        
        HTTPCookieStorage.shared.setCookie(newCookieOne!)
        
    }
    
    // MARK: - Alert Methods
    
    //  Converted to Swift 5.3 by Swiftify v5.3.25403 - https://swiftify.com/
    class func showAlert(in viewController: UIViewController?, withActionNames arrActionName: [AnyHashable]?, title: String?, message: String?, lastItemCancelType cancelType: Bool, block: @escaping (_ tag: Int) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        for i in 0..<(arrActionName?.count ?? 0) {
            var style: Int = UIAlertAction.Style.default.rawValue

            if i == (arrActionName?.count ?? 0) - 1 {
                if (cancelType)
                {
                    style = UIAlertAction.Style.destructive.rawValue
                }
            }

            var action: UIAlertAction? = nil
            if let style = UIAlertAction.Style(rawValue: style) {
                action = UIAlertAction(title: arrActionName?[i] as? String, style: style, handler: { action in
                    //if block != nil {
                        block(i)
                    //}
                    alert.dismiss(animated: true) {

                    }
                })
            }

            if let action = action {
                alert.addAction(action)
            }
        }

        alert.modalPresentationStyle = .fullScreen
        viewController?.present(alert, animated: true)
    }
    
    //  Converted to Swift 5.3 by Swiftify v5.3.25403 - https://swiftify.com/
    class func showDarkAlert(in viewController: UIViewController?, withActionNames arrActionName: [AnyHashable]?, title: String?, message: String?, lastItemCancelType cancelType: Bool, block: @escaping (_ tag: Int) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.overrideUserInterfaceStyle = .dark
        
        for i in 0..<(arrActionName?.count ?? 0) {
            var style: Int = UIAlertAction.Style.default.rawValue

            if i == (arrActionName?.count ?? 0) - 1 {
                if (cancelType)
                {
                    style = UIAlertAction.Style.destructive.rawValue
                }
            }

            var action: UIAlertAction? = nil
            if let style = UIAlertAction.Style(rawValue: style) {
                action = UIAlertAction(title: arrActionName?[i] as? String, style: style, handler: { action in
                    //if block != nil {
                        block(i)
                    //}
                    alert.dismiss(animated: true) {

                    }
                })
            }

            if let action = action {
                alert.addAction(action)
            }
        }

        alert.modalPresentationStyle = .fullScreen
        viewController?.present(alert, animated: true)
    }
    
    //  Converted to Swift 5.3 by Swiftify v5.3.25403 - https://swiftify.com/
    class func showActionSheet(in viewController: UIViewController?, withActionNames arrActionName: [AnyHashable]?, title: String?, message: String?, block: @escaping (_ tag: Int) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)


        for i in 0..<(arrActionName?.count ?? 0) {
            let action = UIAlertAction(title: arrActionName?[i] as? String, style: .default, handler: { action in
                //if block != nil {
                    block(i)
                //}
                alert.dismiss(animated: true) {

                }
            })

            alert.addAction(action)
        }

        // Adjust the default fonts
        if let title = title {
            let aTitle = NSMutableAttributedString(string: title, attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)
            ])
            alert.setValue(aTitle, forKey: "attributedTitle")
        }

        if let message = message {
            let aMessage = NSMutableAttributedString(string: message, attributes: [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
            ])
            alert.setValue(aMessage, forKey: "attributedMessage")
        }

        alert.modalPresentationStyle = .fullScreen
        viewController?.present(alert, animated: true)
    }
    
    
    // MARK: - File Methods
    
    class func documentDirectory() -> String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                    .userDomainMask,
                                                                    true)
        return documentDirectory[0]
    }
    
    class func append(toPath path: String, withPathComponent pathComponent: String) -> String?
    {
        if var pathURL = URL(string: path)
        {
            pathURL.appendPathComponent(pathComponent)
            
            return pathURL.absoluteString
        }
        
        return nil
    }
    
    class func readFile(fromDocumentsWithFileName fileName: String)
    {
        guard let filePath = self.append(toPath: self.documentDirectory(),
                                         withPathComponent: fileName) else {
                                            return
        }
        
        do {
            let savedString = try String(contentsOfFile: filePath)
            
            print(savedString)
        }
        catch
        {
            print("Error reading saved file")
        }
    }
    
    class func saveStringFile(text: String, toDirectory directory: String, withFileName fileName: String) {
        guard let filePath = self.append(toPath: directory, withPathComponent: fileName)
        else
        {
            return
        }
        
        do {
            try text.write(toFile: filePath, atomically: true, encoding: .utf8)
        }
        catch
        {
            print("Error", error)
            return
        }
        
        print("Save successful")
    }
    
    class func saveDataFile(data: Data, toDirectory directory: String, withFileName fileName: String)
    {
        guard let filePath = self.append(toPath: directory, withPathComponent: fileName)
        else
        {
            return
        }
        
        do
        {
            try data.write(to: URL(string: filePath)!)
        }
        catch
        {
            print("Error", error)
            return
        }
        
        print("Save successful")
    }
    
    // MARK: - Download Data Async
    
    class func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ())
    {
        // Replace "http://" with "https://" since some image urls are not secure.
        var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        comps.scheme = "https"
        let https = comps.url!
        
        URLSession.shared.dataTask(with: https, completionHandler: completion).resume()
    }
    
    // MARK: - GenderSport Helpers
    
    class func genderCommaSportFrom(gender: String, sport: String) -> (String)
    {
        let noAmpersandSport = sport.replacingOccurrences(of: "&", with: "")
        let noWhitespaceSport = noAmpersandSport.replacingOccurrences(of: " ", with: "")
        
        return gender.lowercased() + "," + noWhitespaceSport.lowercased()
    }
    
    class func genderSportFrom(gender: String, sport: String) -> (String)
    {
        if ((sport.lowercased() == "football") || (sport.lowercased() == "softball") || (sport.lowercased() == "baseball") || (sport.lowercased() == "field hockey"))
        {
            return sport
        }
        else
        {
            return gender + " " + sport
        }
    }
    
    class func shortGenderSportFrom(gender: String, sport: String) -> (String)
    {
        if ((sport.lowercased() == "football") || (sport.lowercased() == "softball") || (sport.lowercased() == "baseball") || (sport.lowercased() == "field hockey"))
        {
            return sport
        }
        else
        {
            if (gender == "Boys")
            {
                return "B. " + sport
            }
            else if (gender == "Girls")
            {
                return "G. " + sport
            }
            else
            {
                return "Co. " + sport
            }
        }
    }
    
    class func shortGenderSportLevelFrom(gender: String, sport: String, level: String) -> (String)
    {
        if ((sport.lowercased() == "football") || (sport.lowercased() == "softball") || (sport.lowercased() == "baseball") || (sport.lowercased() == "field hockey"))
        {
            if (level == "Varsity")
            {
                return sport
            }
            else if (level == "JV")
            {
                return "JV " + sport
            }
            else
            {
                return "Fr " + sport
            }
        }
        else
        {
            if (gender == "Boys")
            {
                if (level == "Varsity")
                {
                    return "B. " + sport
                }
                else if (level == "JV")
                {
                    return "B. JV " + sport
                }
                else
                {
                    return "B. Fr " + sport
                }
            }
            else if (gender == "Girls")
            {
                if (level == "Varsity")
                {
                    return "G. " + sport
                }
                else if (level == "JV")
                {
                    return "G. JV " + sport
                }
                else
                {
                    return "G. Fr " + sport
                }
            }
            else
            {
                if (level == "Varsity")
                {
                    return "Co. " + sport
                }
                else if (level == "JV")
                {
                    return "Co. JV " + sport
                }
                else
                {
                    return "Co. Fr " + sport
                }
            }
        }
    }
    
    class func genderSportLevelFrom(gender: String, sport: String, level: String) -> (String)
    {
        if ((sport.lowercased() == "football") || (sport.lowercased() == "softball") || (sport.lowercased() == "baseball") || (sport.lowercased() == "field hockey"))
        {
            return level + " " + sport
        }
        else
        {
            return level + " " + gender + " " + sport
        }
    }
    
    class func genderSportShortLevelFrom(gender: String, sport: String, level: String) -> (String)
    {
        var shortLevel = ""
        
        if (level == "Varsity")
        {
            shortLevel = "Var."
        }
        else if (level == "JV")
        {
            shortLevel = "JV"
        }
        else if (level == "Freshman")
        {
            shortLevel = "Fr."
        }
        else if (level == "8th")
        {
            shortLevel = "8th"
        }
        else if (level == "7th")
        {
            shortLevel = "7th"
        }
        else if (level == "6th")
        {
            shortLevel = "6th"
        }
        else if (level == "5th")
        {
            shortLevel = "5th"
        }
        
        if ((sport.lowercased() == "football") || (sport.lowercased() == "softball") || (sport.lowercased() == "baseball") || (sport.lowercased() == "field hockey"))
        {
            return shortLevel + " " + sport
        }
        else
        {
            return shortLevel + " " + gender + " " + sport
        }
    }
    
    class func shortGradeFrom(grade: String) -> (String)
    {
        var shortGrade = ""
        
        if (grade == "Senior")
        {
            shortGrade = "Sr."
        }
        else if (grade == "Junior")
        {
            shortGrade = "Jr."
        }
        else if (grade == "Sophomore")
        {
            shortGrade = "So."
        }
        else if (grade == "Freshman")
        {
            shortGrade = "Fr."
        }
        else if (grade == "8th")
        {
            shortGrade = "8th"
        }
        else if (grade == "7th")
        {
            shortGrade = "7th"
        }
        else if (grade == "6th")
        {
            shortGrade = "6th"
        }
        else if (grade == "5th")
        {
            shortGrade = "5th"
        }
        
        return shortGrade
    }
    
    class func shortGradeFromClassYear(year: Int) -> (String)
    {
        var shortGrade = ""
        
        if (year == 12)
        {
            shortGrade = "Sr."
        }
        else if (year == 11)
        {
            shortGrade = "Jr."
        }
        else if (year == 10)
        {
            shortGrade = "So."
        }
        else if (year == 9)
        {
            shortGrade = "Fr."
        }
        else if (year == 8)
        {
            shortGrade = "8th"
        }
        else if (year == 7)
        {
            shortGrade = "7th"
        }
        else if (year == 6)
        {
            shortGrade = "6th"
        }
        else if (year == 5)
        {
            shortGrade = "5th"
        }
        
        return shortGrade
    }
    
    class func sportShortLevelFrom(sport: String, level: String) -> (String)
    {
        var shortLevel = ""
        
        if (level == "Varsity")
        {
            shortLevel = "Var."
        }
        else if (level == "JV")
        {
            shortLevel = "JV"
        }
        else if (level == "Freshman")
        {
            shortLevel = "Fr."
        }
        else if (level == "8th")
        {
            shortLevel = "8th"
        }
        else if (level == "7th")
        {
            shortLevel = "7th"
        }
        else if (level == "6th")
        {
            shortLevel = "6th"
        }
        else if (level == "5th")
        {
            shortLevel = "5th"
        }
        
        return shortLevel + " " + sport
        
    }
    
    // MARK: - Sport Images
    
    class func getImageForSport(_ sport: String) -> (UIImage)
    {
        var image : UIImage
        
        if (sport == "Bass Fishing")
        {
            image = UIImage(named: "BassFishing")!
        }
        else if (sport == "Cheer")
        {
            image = UIImage(named: "Cheer")!
        }
        else if (sport == "Dance Team")
        {
            image = UIImage(named: "Dance")!
        }
        else if (sport == "Drill")
        {
            image = UIImage(named: "Drill")!
        }
        else if (sport == "Poms")
        {
            image = UIImage(named: "Cheer")!
        }
        else if (sport == "Weight Lifting")
        {
            image = UIImage(named: "WeightLifting")!
        }
        else if (sport == "Wheelchair Sports")
        {
            image = UIImage(named: "Wheelchair")!
        }
        else if (sport == "Cross Country")
        {
            image = UIImage(named: "CrossCountry")!
        }
        else if (sport == "Gymnastics")
        {
            image = UIImage(named: "Gymnastics")!
        }
        else if (sport == "Indoor Track & Field")
        {
            image = UIImage(named: "IndoorTrackAndField")!
        }
        else if (sport == "Judo")
        {
            image = UIImage(named: "Judo")!
        }
        else if (sport == "Ski & Snowboard")
        {
            image = UIImage(named: "SkiAndSnowboarding")!
        }
        else if (sport == "Swimming")
        {
            image = UIImage(named: "Swimming")!
        }
        else if (sport == "Track & Field")
        {
            image = UIImage(named: "TrackAndField")!
        }
        else if (sport == "Wrestling")
        {
            image = UIImage(named: "Wrestling")!
        }
        else if (sport == "Archery")
        {
            image = UIImage(named: "Archery")!
        }
        else if (sport == "Badminton")
        {
            image = UIImage(named: "Badminton")!
        }
        else if (sport == "Baseball")
        {
            image = UIImage(named: "Baseball")!
        }
        else if (sport == "Basketball")
        {
            image = UIImage(named: "Basketball")!
        }
        else if (sport == "Bowling")
        {
            image = UIImage(named: "Bowling")!
        }
        else if (sport == "Canoe Paddling")
        {
            image = UIImage(named: "CanoePaddling")!
        }
        else if (sport == "Fencing")
        {
            image = UIImage(named: "Fencing")!
        }
        else if (sport == "Field Hockey")
        {
            image = UIImage(named: "FieldHockey")!
        }
        else if (sport == "Flag Football")
        {
            image = UIImage(named: "Football")!
        }
        else if (sport == "Football")
        {
            image = UIImage(named: "Football")!
        }
        else if (sport == "Ice Hockey")
        {
            image = UIImage(named: "IceHockey")!
        }
        else if (sport == "Lacrosse")
        {
            image = UIImage(named: "Lacrosse")!
        }
        else if (sport == "Riflery")
        {
            image = UIImage(named: "Riflery")!
        }
        else if (sport == "Rugby")
        {
            image = UIImage(named: "Rugby")!
        }
        else if (sport == "Slow Pitch Softball")
        {
            image = UIImage(named: "Softball")!
        }
        else if (sport == "Soccer")
        {
            image = UIImage(named: "Soccer")!
        }
        else if (sport == "Softball")
        {
            image = UIImage(named: "Softball")!
        }
        else if (sport == "Water Polo")
        {
            image = UIImage(named: "WaterPolo")!
        }
        else if (sport == "Golf")
        {
            image = UIImage(named: "Golf")!
        }
        else if (sport == "Sand Volleyball") // will delete sand soon
        {
            image = UIImage(named: "Volleyball")!
        }
        else if (sport == "Beach Volleyball")
        {
            image = UIImage(named: "Volleyball")!
        }
        else if (sport == "Tennis")
        {
            image = UIImage(named: "Tennis")!
        }
        else if (sport == "Volleyball")
        {
            image = UIImage(named: "Volleyball")!
        }
        else if (sport == "Speech")
        {
            image = UIImage(named: "Speech")!
        }
        else
        {
            image = UIImage()
        }
        
        return image
    }
    
    // MARK: - Sport Filter Colors
    
    class func getColorForSport(_ sport: String) -> (UIColor)
    {
        var color = UIColor.yellow
        
        if (sport == "Bass Fishing")
        {
            color = UIColor.colorFromHex("203042")
        }
        else if (sport == "Cheer")
        {
            color = UIColor.colorFromHex("8f0018")
        }
        else if (sport == "Dance Team")
        {
            color = UIColor.colorFromHex("8f0018")
        }
        else if (sport == "Drill")
        {
            color = UIColor.colorFromHex("454444")
        }
        else if (sport == "Poms")
        {
            color = UIColor.colorFromHex("8f0018")
        }
        else if (sport == "Weight Lifting")
        {
            color = UIColor.colorFromHex("222222")
        }
        else if (sport == "Wheelchair Sports")
        {
            color = UIColor.colorFromHex("1580a5")
        }
        else if (sport == "Cross Country")
        {
            color = UIColor.colorFromHex("d5350b")
        }
        else if (sport == "Gymnastics")
        {
            color = UIColor.colorFromHex("8f0018")
        }
        else if (sport == "Indoor Track & Field")
        {
            color = UIColor.colorFromHex("d5350b")
        }
        else if (sport == "Judo")
        {
            color = UIColor.colorFromHex("203042")
        }
        else if (sport == "Ski & Snowboard")
        {
            color = UIColor.colorFromHex("1580a5")
        }
        else if (sport == "Swimming")
        {
            color = UIColor.colorFromHex("046dff")
        }
        else if (sport == "Track & Field")
        {
            color = UIColor.colorFromHex("d5350b")
        }
        else if (sport == "Wrestling")
        {
            color = UIColor.colorFromHex("203042")
        }
        else if (sport == "Archery")
        {
            color = UIColor.colorFromHex("454444")
        }
        else if (sport == "Badminton")
        {
            color = UIColor.colorFromHex("222222")
        }
        else if (sport == "Baseball")
        {
            color = UIColor.colorFromHex("022c66")
        }
        else if (sport == "Basketball")
        {
            return UIColor.mpBlueColor()
        }
        else if (sport == "Bowling")
        {
            color = UIColor.colorFromHex("454444")
        }
        else if (sport == "Canoe Paddling")
        {
            color = UIColor.colorFromHex("203042")
        }
        else if (sport == "Fencing")
        {
            color = UIColor.colorFromHex("454444")
        }
        else if (sport == "Field Hockey")
        {
            color = UIColor.colorFromHex("005b34")
        }
        else if (sport == "Flag Football")
        {
            color = UIColor.colorFromHex("cc0022")
        }
        else if (sport == "Football")
        {
            color = UIColor.colorFromHex("cc0022")
        }
        else if (sport == "Ice Hockey")
        {
            color = UIColor.colorFromHex("1580a5")
        }
        else if (sport == "Lacrosse")
        {
            color = UIColor.colorFromHex("005b34")
        }
        else if (sport == "Riflery")
        {
            color = UIColor.colorFromHex("454444")
        }
        else if (sport == "Rugby")
        {
            color = UIColor.colorFromHex("cc0022")
        }
        else if (sport == "Slow Pitch Softball")
        {
            color = UIColor.colorFromHex("022c66")
        }
        else if (sport == "Soccer")
        {
            color = UIColor.colorFromHex("00341e")
        }
        else if (sport == "Softball")
        {
            color = UIColor.colorFromHex("022c66")
        }
        else if (sport == "Water Polo")
        {
            color = UIColor.colorFromHex("046dff")
        }
        else if (sport == "Golf")
        {
            color = UIColor.colorFromHex("00341e")
        }
        else if (sport == "Sand Volleyball") // will delete sand soon
        {
            color = UIColor.colorFromHex("046dff")
        }
        else if (sport == "Beach Volleyball")
        {
            color = UIColor.colorFromHex("046dff")
        }
        else if (sport == "Tennis")
        {
            color = UIColor.colorFromHex("222222")
        }
        else if (sport == "Volleyball")
        {
            color = UIColor.colorFromHex("046dff")
        }
        else if (sport == "Speech")
        {
            color = UIColor.colorFromHex("454444")
        }
        
        return color
    }
    
    // MARK: - Positions for Sport
    
    class func positionsForSport(_ sport: String) -> Array<String>
    {
        if ((sport == "Baseball") || (sport == "Softball") || (sport == "SlowPitch Softball"))
        {
            return ["--","1B","2B","3B","C","CF","DH","INF","LF","LHP","OF","P","RF","RHP","SS","UTIL"]
        }
        else if (sport == "Basketball")
        {
            return ["--","C","F","G","P","PF","PG","SF","SG","W"]
        }
        else if (sport == "Field Hockey")
        {
            return ["--","D","F","G","M","SW"]
        }
        else if (sport == "Football")
        {
            return ["--","ATH","B","C","CB","COA","D","DB","DE","DL","DT","FB","FS","G","GB","HB","ILB","K","KR","LB","LS","MLB","NG","OC","OG","OL","OLB","OT","P","PR","QB","RB","S","SB","SE","SS","T","TB","TE","TRN","WB","WR"]
        }
        else if (sport == "Flag Football")
        {
            return ["--","ATH","B","C","CB","COA","D","DB","DE","DL","DT","FB","FS","G","GB","HB","ILB","LB","LS","MLB","NG","OC","OG","OL","OLB","OT","P","PR","QB","RB","S","SB","SE","SS","T","TB","TE","TRN","WB","WR"]
        }
        else if ((sport == "Golf") || (sport == "Tennis"))
        {
            return ["--","Left","Right"]
        }
        else if (sport == "Ice Hockey")
        {
            return ["--","C","D","F","G","LD","LW","RD","RW","W"]
        }
        else if (sport == "Lacrosse")
        {
            return ["--","A","D","DM","G","LSM","M"]
        }
        else if (sport == "Soccer")
        {
            return ["--","D","FB","FORW","GK","HB","MF","STRK","SWEP"]
        }
        else if (sport == "Swimming")
        {
            return ["--","200 M.R.","200 Free","200 IM","50 Free","100 Fly","100 Free","500 Free","200 F.R.","100 Back","100 Brst.","400 F.R."]
        }
        else if ((sport == "Track & Field") || (sport == "Indoor Track & Field"))
        {
            return ["--","100M","200M","400M","800M","1600M","3200M","400RL","800RL","4x4RL", "4x8RL","300H","HJ","PV","LJ","TJ","Shot","Disc","110H","800MR"]
        }
        else if (sport == "Volleyball")
        {
            return ["--","DS","L","MB","MH","OH","OPP","RS","S"]
        }
        else if ((sport == "Beach Volleyball") || (sport == "Sand Volleyball")) // Will delete sand soon
        {
            return ["--","DEF","BLK","SPLT"]
        }
        else if (sport == "Water Polo")
        {
            return ["--","DR","UT","GK","2M","2MD","ATK","D"]
        }
        else
        {
            return["--"]
        }
    }
    
    // MARK: - Core Sports
    
    class func isCoreSport(_ sport: String) -> Bool
    {
        /*
         Baseball
         Basketball
         Beach Volleyball
         Field Hockey
         Flag Football
         Football
         Ice Hockey
         Lacrosse
         Sand Volleyball
         Soccer
         Softball
         Volleyball
         Water Polo
         */
        if (sport.lowercased() == "baseball") || (sport.lowercased() == "basketball") || (sport.lowercased() == "field hockey") || (sport.lowercased() == "flag football") || (sport.lowercased() == "football") || (sport.lowercased() == "ice hockey") || (sport.lowercased() == "lacrosse") || (sport.lowercased() == "soccer") || (sport.lowercased() == "softball") || (sport.lowercased() == "volleyball") || (sport.lowercased() == "water polo") || (sport.lowercased() == "beach volleyball") || (sport.lowercased() == "sand volleyball") // will delete sand soon
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    // MARK: - Sport is Dual Gender
    
    class func sportIsDualGender(sport: String) -> Bool
    {
        if ((sport.lowercased() == "football") || (sport.lowercased() == "softball") || (sport.lowercased() == "baseball") || (sport.lowercased() == "field hockey"))
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    // MARK: - Sport Uses Match Instead of Game
    
    class func sportUsesMatchInsteadOfGame(sport: String) -> Bool
    {
        if (sport.lowercased() == "volleyball") || (sport.lowercased() == "tennis") || (sport.lowercased() == "golf") || (sport.lowercased() == "sand volleyball") || (sport.lowercased() == "beach volleyball") || (sport.lowercased() == "water polo")
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    // MARK: - Weight Classes for Gender
    
    class func weightClassForGender(_ gender: String) -> Array<String>
    {
        if (gender == "Male")
        {
            return ["--","106 lbs.", "113 lbs.","120 lbs.","126 lbs.","132 lbs.","138 lbs.","145 lbs.","152 lbs.","160 lbs.","170 lbs.","182 lbs.","192 lbs.","220 lbs.","285 lbs."]
        }
        else if (gender == "Female")
        {
            return ["--","98 lbs.", "103 lbs.","108 lbs.","114 lbs.","118 lbs.","122 lbs.","126 lbs.","126 lbs.","132 lbs.","138 lbs.","146 lbs.","154 lbs.","165 lbs.","189 lbs.","253 lbs."]
        }
        else
        {
            return ["--"]
        }
    }
    
    // MARK: - Mascot Improver Method
    
    class func renderImprovedMascot(sourceImage: UIImage, destinationImageView: UIImageView)
    {
        let scaledImage = ImageHelper.image(with: sourceImage, scaledTo: CGSize(width: destinationImageView.frame.size.width, height: destinationImageView.frame.size.height))
        
        let cornerColor = sourceImage.getColorIfCornersMatch()
        
        if (cornerColor != nil)
        {
            //print ("Corner Color match")

            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0

            // Use the scaled image if the color is white or the alpha is zero
            cornerColor!.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            
            if (((red == 1) && (green == 1) && (blue == 1)) || (alpha == 0))
            {
                destinationImageView.image = scaledImage
            }
            else
            {
                let roundedImage = UIImage.maskRoundedImage(image: scaledImage!, radius: destinationImageView.frame.size.width / 2.0)
                destinationImageView.image = roundedImage
            }
        }
        else
        {
            print("Corner Color Mismatch")
            destinationImageView.image = scaledImage
        }
    }
    
    // MARK: - FreeWheel URL Method
    
    class func buildFreeWheelURL(pidMode: Bool, videoInfo: Dictionary<String,String>) -> String
    {
        // Base URL
        var adUrlString = "https://7f077.v.fwmrm.net/ad/g/1?"
        
        // Add the ASNW parameter
        adUrlString.append("asnw=520311")
        
        // Build a Dictionary for the global key-value pairs
        var globalParamDict: Dictionary<String,String> = [:]
        
        // Make a second dictionary for the fw parameters
        var fwParamDict: Dictionary<String,String> = [:]
        
        // CAID
        var caid = ""
        
        if (pidMode == true)
        {
            // PID CAID
            caid = videoInfo["mpxId"]!
        }
        else
        {
            // URL CAID
            var partner = videoInfo["externalPartner"]!
            partner = partner.replacingOccurrences(of: " ", with: "%20")
            
            if (partner.lowercased() == "hudl")
            {
                caid = "DFB48443-1C6E-BEB6-4FEC-B7571F86413D"
            }
            else if (partner.lowercased() == "fantag")
            {
                caid = "E1B39980-447E-A609-6463-970F3B6EE790"
            }
            else if ((partner.lowercased() == "vrv") || (partner.lowercased() == "matrix"))
            {
                caid = "8EDB428F-F641-230A-CEDE-971E11A89B05"
            }
            else
            {
                caid = "E6472494-D95D-40FA-8C14-2EE6B40AF277"
            }
        }
        
        globalParamDict.updateValue(caid, forKey: "caid")
        
        // CSID
        var csid = ""
        
        if (SharedData.deviceType as! DeviceType == DeviceType.ipad)
        {
            csid = "vcbs_maxpreps_mobile_iostablet_vod"
        }
        else
        {
            csid = "vcbs_maxpreps_mobile_iosphone_vod"
        }
        
        globalParamDict.updateValue(csid, forKey: "csid")
        
        // FLAG (Updated in V6.2.1, removed qtcd, added dtrd)
        //let flag = "%2Bamcb%2Bemcr%2Bsltp%2Bslcb%2Bqtcb%2Bvicb%2Bfbad%2Bsync%2Bnucr%2Baeti"
        let flag = "%2Bamcb%2Bemcr%2Bsltp%2Bslcb%2Bdtrd%2Bvicb%2Bfbad%2Bsync%2Bnucr%2Baeti"
        globalParamDict.updateValue(flag, forKey: "flag")
        
        // METR
        globalParamDict.updateValue("1023", forKey: "metr")
        
        // NW
        globalParamDict.updateValue("520311", forKey: "nw")
        
        // PROF
        let prof = "520311%3AGoogleDAICSAI_v01_COPPA"
        globalParamDict.updateValue(prof, forKey: "prof")
        
        // PVRN
        let pvrn = FeedsHelper.getRandomNumberString(16)
        globalParamDict.updateValue(pvrn, forKey: "pvrn")
        
        // RESP
        globalParamDict.updateValue("vmap1%2Bvast4", forKey: "resp")
        
        // SSNW
        globalParamDict.updateValue("520311", forKey: "ssnw")
        
        // VPRN
        let vprn = FeedsHelper.getRandomNumberString(16)
        globalParamDict.updateValue(vprn, forKey: "vprn")
        
        // Privacy (Moved to the parameter dictionary in V6.2.1)
        //let ccpaString = kUserDefaults.string(forKey: "IABUSPrivacy_String") ?? ""
        //globalParamDict.updateValue(ccpaString, forKey: "_fw_us_privacy")
        
        // Expand the dictionary into a giant string
        let globalQueryString = FeedsHelper.expandDictionary(intoQueryString: globalParamDict)
        
        // Append the the adUrlString
        adUrlString.append(globalQueryString)
        
        // Add a semicolon here
        adUrlString.append(";")
        
        // Add the first item after the semicolon manually
        
        // App Bundle (removed in V6.2.4)
        //let app_bundle = Bundle.main.bundleIdentifier
        //let appBundleQueryParam = "_fw_app_bundle=" + app_bundle!
        //adUrlString.append(appBundleQueryParam)
        
        // _fw_continuous_play
        fwParamDict.updateValue("0", forKey: "_fw_continuous_play")
        
        // _fw_h_referer (removed in V6.2.4)
        //let app_bundle = Bundle.main.bundleIdentifier
        //fwParamDict.updateValue(app_bundle!, forKey: "_fw_h_referer")
        
        // _fw_nielson_app_id
        let _fw_nielson_app_id = "P0C0C37AD-20C4-4EF7-AF25-BEBCB16DF85E"
        fwParamDict.updateValue(_fw_nielson_app_id, forKey: "_fw_nielson_app_id")
        
        // _fw_vcid2
        let _fw_vcid2 = kUserDefaults.object(forKey: kVCID2Key) as! String
        fwParamDict.updateValue(_fw_vcid2, forKey: "_fw_vcid2")
        
        // fms_vcid2type
        let type = kUserDefaults.object(forKey: kVCID2TypeKey) as! String
        fwParamDict.updateValue(type, forKey: "fms_vcid2type")
        
        // sz
        fwParamDict.updateValue("640x480", forKey: "sz")
        
        // Conduit (Added in V6.1.5, MPA-1535)
        fwParamDict.updateValue("[GOOGLE_INSTREAM_VIDEO_NONCE]", forKey: "givn")
        
        // Privacy (Moved to the parameter dictionary in V6.2.1)
        let ccpaString = kUserDefaults.string(forKey: "IABUSPrivacy_String") ?? ""
        fwParamDict.updateValue(ccpaString, forKey: "_fw_us_privacy")
        
        // Added in V6.2.8
        if (self.isUserMinorAged() == true)
        {
            fwParamDict.updateValue("1", forKey: "_fw_coppa")
        }
        else
        {
            fwParamDict.updateValue("0", forKey: "_fw_coppa")
        }
        
        // Added in V6.3.1
        if (self.privacyStatusForUser(consentCategory: "4") == 0)
        {
            fwParamDict.updateValue("1", forKey: "_fw_is_lat")
        }
        else
        {
            fwParamDict.updateValue("0", forKey: "_fw_is_lat")
        }
        
        /*
        // The Avia player takes care of this
        // Ad tracking
        let idfaString = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        let formattedIdfaString = "idfa:" + idfaString
        
        let status = ATTrackingManager.trackingAuthorizationStatus
        
        switch status
        {
        case .notDetermined:
            fwParamDict.updateValue("0", forKey: "_fw_atts")
        case .denied:
            fwParamDict.updateValue("2", forKey: "_fw_atts")
        case .restricted:
            fwParamDict.updateValue("1", forKey: "_fw_atts")
        case .authorized:
            fwParamDict.updateValue("3", forKey: "_fw_atts")
            fwParamDict.updateValue(formattedIdfaString, forKey: "_fw_did")
        default:
            fwParamDict.updateValue("0", forKey: "_fw_atts")
        }
        
         // Add the UVP and IMA verson
         NSString *version = [NSString stringWithFormat:@"uvpn_%@", kUVPNVersion];
         [fwParamDict setObject:version forKey:@"playername_version"];
         [fwParamDict setObject:@"3.12.1" forKey:@"ima_sdkv"];
         */
        
        let fwQueryString = FeedsHelper.expandDictionary(intoQueryString: fwParamDict)
        adUrlString.append(fwQueryString)
        //print("Ad URL String: " + adUrlString)
        
        return adUrlString
        
        // Hardcoded sample URL from Skinner app
        //return "https://7f077.v.fwmrm.net/ad/g/1?asnw=520311&caid=HqZyR0jQvWuhGbX9ARxdkGYBmk9wxfw_&csid=vcbs_rachaelray_desktop_web_vod&flag=%2Bdtrd%2Bsync%2Bqtcb%2Bvicb%2Bemcr%2Baeti%2Bsltp%2Bfbad%2Bscpv%2Bslcb&metr=1023&nw=520311&prof=520311%3AGoogleDAICSAI_v01&pvrn=[RANDOM]&ssnw=520311&vprn=[RANDOM]&resp=vmap1%2Bvast4;_fw_continuous_play%3D0&_fw_h_referer=https%3A%2F%2Fstaging.rachaelrayshow.com%2Fvideo%2Fhow-to-make-smoky-spanish-chicken-with-peppers-roasted-potatoes-rachael-ray%3Fcaid%3DFMtgrrHaGj3j1okdHwg6jX3fU_6DMZSn&cpPre=0&cpSession=0&description_url=https%3A%2F%2Fwww.rachaelrayshow.com&embed=0&partner=rachaelray&section=videos&show=rachaelray&site=ctd&sz=640x483&keywords=at_home%2Cchicken%2Cpotatoes%2Cpeppers%2Cspanish%2Cone-pan%2Crachaelray%2Crachael_ray%2Crachel_ray%2Crachael_ray_show%2Cfood%2Crecipe%2Chow_to%2Cone_pan%2Cpimenton%2Cpaprika%2Croasted%2Cpan_con_tomate&ptype=video&vguid=f5061ec7-ec80-7b38-ddfd-1588324dfc06&ftag=false&_fw_vcid2=fd019673-1c71-4f5c-af98-ae428a813344&fms_vcid2type=userid&fms_userid=fd019673-1c71-4f5c-af98-ae428a813344&host=staging.rachaelrayshow.com"
    }
    
    // MARK: - A/B Test Helper
    
    class func userABTestValue() -> String
    {
        // Returns empty string if logged out, a guest. or not group A
        // Returns "maxpreps|190|abtest" if user is in group A
        
        let groupAFirstCharacters = ["0", "1", "2"]
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        if ((userId == kEmptyGuid) || (userId == kTestDriveUserId))
        {
            return ""
        }
        else
        {
            let firstCharacter = userId?.first
            if (groupAFirstCharacters.contains(String(firstCharacter!)) == true)
            {
                return "maxpreps|190|abtest"
            }
            else
            {
                return ""
            }
        }
    }
    
    // MARK: - Video Autoplay Helper
    
    class func videoAutoplayIsOk() -> Bool
    {
        // Is the battery good and does the network match the user's autoplay preferences?
        let mode = kUserDefaults.object(forKey: kVideoAutoplayModeKey) as! NSNumber
        let autoplayMode = mode.intValue
        var autoplayOk = false
        
        switch autoplayMode
        {
        case 1: // WiFi autoplay
            if ((self.isConnectedToWiFi() == true) && (self.hasGoodBatteryLevel() == true))
            {
                autoplayOk = true
                break
            }
        case 2: // WiFi or Cell Data autoplay
            if (self.hasGoodBatteryLevel() == true)
            {
                autoplayOk = true
                break
            }
        default:
            autoplayOk = false
            break
        }
        
        return autoplayOk
    }
    
    class func hasGoodBatteryLevel() -> Bool
    {
        var goodBattery = false
        var chargingOrFull = false
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        if (UIDevice.current.batteryLevel > 0.3)
        {
            goodBattery = true
        }
        
        if ((UIDevice.current.batteryState == .charging) || (UIDevice.current.batteryState == .full))
        {
            chargingOrFull = true
        }
        
        return goodBattery || chargingOrFull
    }
    
    class func isConnectedToWiFi() -> Bool
    {
        let reachability = Reachability.forInternetConnection()
        reachability!.startNotifier()
        
        let status = reachability?.currentReachabilityStatus()
        
        if (status == ReachableViaWiFi)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    /*
    class func notWorkingIsWifiEnabled() -> Bool
    {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress)
        {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false
        {
            return false
        }
        
        // Only Working for WIFI
        let isReachable = flags == .reachable
        return isReachable
        
        // This doesn't always return true
        //let needsConnection = flags == .connectionRequired
        //return isReachable && !needsConnection
        
        
        // Working for Cellular and WIFI
        //let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        //let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        //let ret = (isReachable && !needsConnection)
        
        //return ret
    }
    */
}
