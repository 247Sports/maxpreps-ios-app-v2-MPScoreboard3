//
//  AppDelegate.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/1/21.
//

import UIKit
import DTBiOSSDK
import AdSupport
import AppTrackingTransparency
import AviaTrackingCore
import AviaTrackingComscore
//import MoPubAdapter
import GoogleMobileAds
import AirshipCore
import BranchSDK
import OTPublishersHeadlessSDK
import Qualtrics
import NimbusKit
import WebKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, PushNotificationDelegate, RegistrationDelegate, DeepLinkDelegate
{
    private var deepLinkBusy = false
    
    // MARK: - Get FMS Data
    
    private func getFMSData()
    {
        // Build three dictionaries that are required by the feed
        let bundleId = Bundle.main.bundleIdentifier
        
        // Build the App Info Dictionary
        let appInfo = ["bundle": bundleId ?? "", "googledai": 0, "coppa": 0] as [String : Any]
        
        // Build the Device Info Dictionary
        let status = ATTrackingManager.trackingAuthorizationStatus
        var trackingEnabled = false
        
        var deviceInfo: Dictionary<String,Any>
        
        switch status
        {
        case .notDetermined:
            deviceInfo = ["lat":0]
            trackingEnabled = false
            break
        case .denied:
            deviceInfo = ["lat":0]
            trackingEnabled = false
            break
        case .restricted:
            deviceInfo = ["lat":0]
            trackingEnabled = false
            break
        case .authorized:
            deviceInfo = ["lat":1]
            trackingEnabled = true
            break
        default:
            deviceInfo = ["lat":0]
            trackingEnabled = false
            break
        }

        // Build the Identifiers Dictionary
        let idfaString = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        let userId = kUserDefaults.object(forKey: kUserIdKey) as! String
        let fallbackId = (kUserDefaults.object(forKey: kFallbackUserIdKey) as! String).lowercased()
        
        var identifierDictionary: Dictionary<String,Any>
        
        if (userId == kTestDriveUserId) || (userId == kEmptyGuid)
        {
            if (trackingEnabled == true)
            {
                identifierDictionary = ["ifa":idfaString, "ifatype":"idfa", "userid":fallbackId]
            }
            else
            {
                identifierDictionary = ["idfv":fallbackId]
            }
        }
        else
        {
            // Logged in
            let userEmail = kUserDefaults.object(forKey: kUserEmailKey) as! String
            let hashedEmail = FeedsHelper.sha256Hash(forText: userEmail)
            
            if (trackingEnabled == true)
            {
                identifierDictionary = ["ifa":idfaString, "ifatype":"idfa", "emailhash":hashedEmail, "subscriberid":userId, "userid":fallbackId]
            }
            else
            {
                identifierDictionary = ["emailhash":hashedEmail, "subscriberid":userId, "idfv":fallbackId]
            }
        }
        
        // Call the feed
        NewFeeds.getFMSData(appInfo: appInfo, deviceInfo: deviceInfo, identifiers: identifierDictionary)
        { result, error in
            
            if (error == nil)
            {
                print("FMS Feed Success")
                
                /*
                 {
                     "fms_id_ttl" = 172800;
                     "fms_params" =     {
                         "_fw_vcid2" = 91981b5eb3154fd9e769f7252028181ce65c891d5214521634e22abd9b7132f6;
                         "fms_emailhash" = 91981b5eb3154fd9e769f7252028181ce65c891d5214521634e22abd9b7132f6;
                         "fms_idfv" = "6e3e69a2-0150-43f6-bca3-a135820b75ca";
                         "fms_subscriberid" = "c3b23e5b-13ce-4d98-949c-ca41eaa31ab5";
                         "fms_userid" = "6e3e69a2-0150-43f6-bca3-a135820b75ca";
                         "fms_vcid2type" = emailhash;
                         // Optional if lat = 0
                         // fms_uid2 = xxxxxx
                     };
                 }
                */
                
                let fms_params = result!["fms_params"] as! Dictionary<String,Any>
                let vcid2 = fms_params["_fw_vcid2"] as! String
                let type = fms_params["fms_vcid2type"] as! String
                let uid2 = fms_params["fms_uid2"] as? String ?? ""
                //print("VCID2: " + vcid2)
                kUserDefaults.setValue(vcid2, forKey: kVCID2Key)
                kUserDefaults.setValue(type, forKey: kVCID2TypeKey)
                kUserDefaults.setValue(uid2, forKey: kUID2Key)
            }
            else
            {
                print("FMS Feed Failed")
                
                // Fallback sequence
                if (identifierDictionary["emailhash"] != nil)
                {
                    kUserDefaults.setValue(identifierDictionary["emailhash"], forKey: kVCID2Key)
                    kUserDefaults.setValue("emailhash", forKey: kVCID2TypeKey)
                }
                else
                {
                    if (identifierDictionary["ifa"] != nil)
                    {
                        kUserDefaults.setValue(identifierDictionary["ifa"], forKey: kVCID2Key)
                        kUserDefaults.setValue("ifa", forKey: kVCID2TypeKey)
                    }
                    else
                    {
                        if (identifierDictionary["idfv"] != nil)
                        {
                            kUserDefaults.setValue(identifierDictionary["idfv"], forKey: kVCID2Key)
                            kUserDefaults.setValue("idfv", forKey: kVCID2TypeKey)
                        }
                        else
                        {
                            kUserDefaults.setValue(userId, forKey: kVCID2Key)
                            kUserDefaults.setValue("userid", forKey: kVCID2TypeKey)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Master School List Method
    
    func getSchoolsFile()
    {
        SharedData.allSchools.removeAll()
        
        var filePath = Bundle.main.path(forResource: "ALL", ofType: "txt")
        
        // This code checks for a ALL.txt data file in the documents directory
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("ALL.txt")
        {
            let patchPath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: patchPath)
            {
                print("School patch file exists.")
                filePath = patchPath
            }
            else
            {
                print("School patch file doesnt exist.")
            }
        }
        else
        {
            print("An error happened while checking for the schools file.")
        }
        
        // Read the file
        var wordstring = ""
        do {
            wordstring = try String(contentsOfFile: filePath!, encoding: .utf8)
        }
        catch
        {
            print("Couldn't read file")
        }
        
        // Split the string into an array
        let lineArray = wordstring.components(separatedBy: "\n")
                
        print("Initial School Count = " + String(lineArray.count))
    
        let currentLocation = kUserDefaults.object(forKey: kCurrentLocationKey) as! Dictionary<String,String>
        
        let centerLatitudeString = currentLocation[kLatitudeKey] //kUserDefaults.string(forKey: kLatitudeKey) ?? "0.0"
        let centerLongitudeString = currentLocation[kLongitudeKey] //kUserDefaults.string(forKey: kLongitudeKey) ?? "0.0"
        print("Latitude: " + centerLatitudeString! + ", Longitude: " + centerLongitudeString!)
        
        let centerLatitude = Float(centerLatitudeString!) ?? 0.0
        let centerLongitude = Float(centerLongitudeString!) ?? 0.0
        
        //for (index, line) in lineArray.enumerated()
        for (_, line) in lineArray.enumerated()
        {
            let schoolDataArray = line.components(separatedBy: "|")
            
            // The ALL.txt data is arranged as follows:
            // School(city, state) | GUID | URL | Name | Address | City | State | Zip | Phone | Longitude | Latitude
            
            if (schoolDataArray.count < 7)
            {
                //print("Error: Schools file line " + String(index) + " is missing elements")
                continue;
            }
            
            let state = schoolDataArray[6]
            
            // Remove schools with no state (international)
            if (state.count == 0)
            {
                //print("School Remove due to missing state.");
                continue;
            }
            
            let latitudeString = schoolDataArray[10]
            let longitudeString = schoolDataArray[9]
            
            let schoolLatitude = Float(latitudeString) ?? 0.0
            let schoolLongitude = Float(longitudeString) ?? 0.0
            
            let deltaLatitude = centerLatitude - schoolLatitude
            let deltaLongitude = centerLongitude - schoolLongitude
            
            let distanceSquared = (deltaLongitude * deltaLongitude) + (deltaLatitude * deltaLatitude)
            
            let school = School(fullName: schoolDataArray[0], name: schoolDataArray[3], schoolId: schoolDataArray[1], address: schoolDataArray[4], state: schoolDataArray[6], city: schoolDataArray[5], zip: schoolDataArray[7], searchDistance: distanceSquared, latitude: latitudeString, longitude: longitudeString)
            
            SharedData.allSchools.append(school)
            
        }
        print("Final School Count: " + String(SharedData.allSchools.count))
    }
    
    // MARK: - Build Tracking Dictionary
    
    private func buildTrackingDictionary()
    {
        // Initialize the three base tab GUIDs so they are ready to use
        SharedData.newsTabBaseGuid = NSUUID().uuidString
        SharedData.followingTabBaseGuid = NSUUID().uuidString
        SharedData.scoresTabBaseGuid = NSUUID().uuidString
        
        let filePath = Bundle.main.path(forResource: "Tracking", ofType: "csv")
        
        // Read the file
        var wordstring = ""
        do {
            wordstring = try String(contentsOfFile: filePath!, encoding: .utf8)
        }
        catch
        {
            print("Couldn't read file")
        }
            
        // Split the string into an array
        let lineArray = wordstring.components(separatedBy: "\n")
                
        print("CSV Line Count = " + String(lineArray.count))
        
        var lineNumber = 0 // For debugging the file
        
        // Split up the components
        for (_, line) in lineArray.enumerated()
        {
            lineNumber += 1
            let trackingDataArray = line.components(separatedBy: ",")
            
            // The Tracking.csv file is arranged as follows:
            // Page Category | Where is the page | For Web | For App | App Description | Type | Project | Channel | Feature | Sub Feature | Site Hier | Page Type | Is Tracked
            
            if (trackingDataArray.count < 12)
            {
                continue;
            }
            
            // Skip non-app items
            let isForApp = trackingDataArray[3]
            if (isForApp != "Yes")
            {
                continue
            }
            
            let trackingKey = trackingDataArray[8]
            //print(trackingKey)
            
            /*
            if ((trackingKey == "sport-home") || (trackingKey == "sport-playoffs"))
            {
                print("Key Found")
            }
            */
            if (trackingKey != "")
            {
                let siteHier = trackingDataArray[10]
                
                // Check that the siteHier has four components
                let siteHierArray = siteHier.components(separatedBy: "|")
                if (siteHierArray.count != 4)
                {
                    print("Incorrect Site Hier Component Count: " + trackingKey + " , Line:" + String(lineNumber))
                    continue
                }
                let pageType = trackingDataArray[11]
                let trackingItem = [kTrackingSiteHierKey:siteHier, kTrackingPageTypeKey:pageType]
                
                // Add to the tracking dictionary
                if (SharedData.trackingDictionary[trackingKey] == nil)
                {
                    SharedData.trackingDictionary[trackingKey] = trackingItem
                }
                else
                {
                    print("Duplicate Tracking Key Found: " + trackingKey + " , Line:" + String(lineNumber))
                }
            }
        }
        
        print("Tracking Dictionary Count = " + String(SharedData.trackingDictionary.keys.count))
    }
    
    // MARK: - Google Ads
    
    func loadGoolgeAdIds()
    {
        //if (kUserDefaults.string(forKey: kServerModeKey) == kServerModeDev) || (kUserDefaults.string(forKey: kServerModeKey) == kServerModeBranch)
        if (kUserDefaults.bool(forKey: kDebugDialogsKey) == true)
        {
            /*
            // Google Ad Ids for Dev from CBS
            [prefs setObject:@"/7336/appaw-maxpreps/latest" forKey:kNewsBannerAdIdKey];
            [prefs setObject:@"/7336/appaw-maxpreps/scores" forKey:kScoresBannerAdIdKey];
            [prefs setObject:@"/7336/appaw-maxpreps/teams" forKey:kTeamsBannerAdIdKey];
            [prefs setObject:@"/7336/appaw-maxpreps/athlete" forKey:kAthleteBannerAdIdKey];
            */
            
            let googleTestId = "ca-app-pub-3940256099942544/2934735716"
            kUserDefaults.setValue(googleTestId, forKey: kNewsBannerAdIdKey)
            kUserDefaults.setValue(googleTestId, forKey: kScoresBannerAdIdKey)
            kUserDefaults.setValue(googleTestId, forKey: kTeamsBannerAdIdKey)
            kUserDefaults.setValue(googleTestId, forKey: kAthleteBannerAdIdKey)
        }
        else
        {
            kUserDefaults.setValue("/8264/appaw-maxpreps/latest", forKey: kNewsBannerAdIdKey)
            kUserDefaults.setValue("/8264/appaw-maxpreps/scores", forKey: kScoresBannerAdIdKey)
            kUserDefaults.setValue("/8264/appaw-maxpreps/teams", forKey: kTeamsBannerAdIdKey)
            kUserDefaults.setValue("/8264/appaw-maxpreps/athlete", forKey: kAthleteBannerAdIdKey)
        }
    }
    
    private func loadGoogleCoppaSettings()
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
                    
                    if (age < 16)
                    {
                        print("Too young")
                        GADMobileAds.sharedInstance().requestConfiguration.tag(forChildDirectedTreatment: true)
                    }
                    else
                    {
                        print("Old enough")
                    }
                    
                    print(String(age))
                }
            }
        }
    }
    
    // MARK: - Nimbus Init
    
    private func initializeNimbus()
    {
        if (kUserDefaults.bool(forKey: kDebugDialogsKey) == true)
        {
            Nimbus.shared.initialize(publisher: kNimbusDevPublisherNameKey, apiKey: kNimbusDevApiKey)
            Nimbus.shared.testMode = true
            
            // Added in V6.3.1
            let ccpaString = kUserDefaults.string(forKey: "IABUSPrivacy_String") ?? ""
            Nimbus.shared.usPrivacyString = ccpaString
            
            // Added in V6.3.2
            Nimbus.shared.coppa = MiscHelper.isUserMinorAged()
            
            // Added in V6.3.2
            let uid2 = kUserDefaults.string(forKey: kUID2Key) ?? ""
            if (uid2 != "")
            {
                NimbusAdManager.extendedIds = [NimbusExtendedId(source: uid2, id: "UID2-Token")]
            }
        }
        else
        {
            Nimbus.shared.initialize(publisher: kNimbusPublisherNameKey, apiKey: kNimbusApiKey)
            Nimbus.shared.testMode = false
            
            // Added in V6.3.1
            let ccpaString = kUserDefaults.string(forKey: "IABUSPrivacy_String") ?? ""
            Nimbus.shared.usPrivacyString = ccpaString
            
            // Added in V6.3.2
            Nimbus.shared.coppa = MiscHelper.isUserMinorAged()
            
            // Added in V6.3.2
            let uid2 = kUserDefaults.string(forKey: kUID2Key) ?? ""
            if (uid2 != "")
            {
                NimbusAdManager.extendedIds = [NimbusExtendedId(source: uid2, id: "UID2-Token")]
            }
        }
    }

    // MARK: - Init MoPub
    
    private func initializeMoPub()
    {
        /*
        let sdkConfig = MPMoPubConfiguration(adUnitIdForAppInitialization: kMoPubAdUnitIdentifier)
        sdkConfig.loggingLevel = .info
        MoPub.sharedInstance().initializeSdk(with: sdkConfig, completion: nil)
        */
    }
    
    // MARK: - Init Trackers
    
    private func initUVPNTracking()
    {
        /*
        // Moved to Adobe init
        // Set the AdobeMorketingCloudID for use elsewhere in the app
        DispatchQueue.global().async
        {
            let orgUserId = ADBMobile.visitorMarketingCloudID()
            kUserDefaults.setValue(orgUserId, forKey: kAdobeMarketingCloudIdKey)
        }
        */
        //UVPNVideoTrackingManager.loadLocalTrackingConfig("VideoTrackingConfig", isTealium: false)

        var urlString : String
        
        if ((kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev) || (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch))
        {
            urlString = "https://tags.tiqcdn.com/utag/cbsi/maxpreps-ios/qa/utag.js"
        }
        else
        {
            urlString = "https://tags.tiqcdn.com/utag/cbsi/maxpreps-ios/prod/utag.js"
        }
        
        UVPNVideoTrackingManager.loadTrackingConfig(urlString, isTealium: true)
        { buckets, error in
            
            if let buckets = buckets
            {
                NSLog("HURRAY - Got the buckets - \(buckets)")
            }
            else
            {
                //Try fetching later
                NSLog("Got Errors - " + String(describing: error?.localizedDescription))
            }
        }
        
        //UVPNComscoreVideoTracker.startComscore(publisherId: kComScoreId, debugMode: true, applicationName: nil)
        
        // Changed in V6.3.1
        if (MiscHelper.privacyStatusForUser(consentCategory: "4") == 0)
        {
            let persistentLabels = ["cs_ucfr":0]
            UVPNComscoreVideoTracker.startComscore(publisherId: kComScoreId, debugMode: true,applicationName: nil, persistentLabels: persistentLabels)
        }
        else if (MiscHelper.privacyStatusForUser(consentCategory: "4") == 1)
        {
            let persistentLabels = ["cs_ucfr":1]
            UVPNComscoreVideoTracker.startComscore(publisherId: kComScoreId, debugMode: true,applicationName: nil, persistentLabels: persistentLabels)
        }
        else
        {
            // Skip the persistent labels
            UVPNComscoreVideoTracker.startComscore(publisherId: kComScoreId, debugMode: true, applicationName: nil)
        }
    }
    
    private func initAdobeTracking()
    {
        var filePath = ""
        
        if ((kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev) || (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch))
        {
            filePath = Bundle.main.path(forResource: "ADBMobileConfig-dev", ofType: "json")!
        }
        else
        {
            filePath = Bundle.main.path(forResource: "ADBMobileConfig", ofType: "json")!
        }
        
        ADBMobile.overrideConfigPath(filePath)
        
        let contextData = ["brandplatformid":"maxpreps_app_ios"]
        ADBMobile.collectLifecycleData(withAdditionalData: contextData)
        
        ADBMobile.setDebugLogging(false)
        ADBMobile.keepLifecycleSessionAlive()
        
        let idfaString = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        ADBMobile.setAdvertisingIdentifier(idfaString)
        
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        if ((kUserDefaults.string(forKey: kUserIdKey) == kTestDriveUserId) || (kUserDefaults.string(forKey: kUserIdKey) == kEmptyGuid))
        {
            ADBMobile.visitorSyncIdentifiers(["other":""])
        }
        else
        {
            ADBMobile.visitorSyncIdentifiers(["other":userId!])
        }
        
        //SharedData.adobeMID = ADBMobile.visitorMarketingCloudID() ?? ""
        
        // Set the AdobeMorketingCloudID for use elsewhere in the app
        DispatchQueue.global().async
        {
            let orgUserId = ADBMobile.visitorMarketingCloudID()
            kUserDefaults.setValue(orgUserId, forKey: kAdobeMarketingCloudIdKey)
        }
        
        print("Done")
    }
    
    // MARK: - Amazon Ad Init
    
    private func initializeAmazonAds()
    {
        DTBAds.sharedInstance().setAppKey(kAmazonAdAppKey)
        DTBAds.sharedInstance().setLogLevel(DTBLogLevelOff)
        DTBAds.sharedInstance().testMode = false
        //DTBAds.sharedInstance().setAPSFrequencyCappingIdFeatureEnabled(true)
        
        // Added for the Nimbus SDK 2.4.1 upgrade
        DTBAds.sharedInstance().addCustomAttribute("omidPartnerName", value: "Google")
        DTBAds.sharedInstance().addCustomAttribute("omidPartnerVersion", value: GADMobileAds.sharedInstance().sdkVersion)
    }
        
    // MARK: - Init Branch
    
    private func initBranch(launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    {
        if (kUserDefaults.bool(forKey: kDebugDialogsKey) == true)
        {
            Branch.setUseTestBranchKey(true)
            //Branch.getInstance().validateSDKIntegration()
        }
        else
        {
            Branch.setUseTestBranchKey(false)
        }
        
        let branch = Branch.getInstance()
        branch.enableLogging()
        
        switch UIDevice.current.systemVersion.compare("15.0.0", options: .numeric)
        {
        case .orderedSame, .orderedDescending:
            print("iOS >= 15")
            branch.checkPasteboardOnInstall()
        case .orderedAscending:
            print("iOS < 15.0")
        }
        
        // Add the Adobe marketing ID
        let adobeId = kUserDefaults.string(forKey: kAdobeMarketingCloudIdKey)
        
        branch.setRequestMetadataKey("$marketing_cloud_visitor_id", value:adobeId)
        
        // Listener for Branch Deep Link data
        //branch.initSession(launchOptions: launchOptions) { (params, error) in
        
        // This version of initSession includes the source UIScene in the callback
        let branchScene = BranchScene.shared()
        branchScene.initSession(launchOptions: launchOptions, registerDeepLinkHandler: { (params, error, scene) in
            
           
            let userId = kUserDefaults.string(forKey: kUserIdKey)
            if (userId != kEmptyGuid)
            {
                branch.setIdentity(userId)
            }
            /*
            if (params!["maxpreps_context"] == nil)
            {
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "Branch Callback", message: "maxpreps_context not found.", lastItemCancelType: false) { tag in
                    
                }
                return
            }
            */
            
            // Deep link data (nav to page, display content, etc)
            // Don't try if the user is not logged in
            // The tabBarController will handle deep linking when login has finished
            
            if (kUserDefaults.string(forKey: kUserIdKey) != kEmptyGuid)
            {
                self.showDeepLink(parameters: params!)
            }
        })
    }
    
    // MARK: - Init One Trust
    
    private func initOneTrust()
    {
        var domainId = "048a5b83-3f44-413e-a911-7f8abd0f6c33"
        
        if (kUserDefaults.bool(forKey: kDebugDialogsKey) == true)
        {
            domainId = "048a5b83-3f44-413e-a911-7f8abd0f6c33-test"
        }
        
        OTPublishersHeadlessSDK.shared.startSDK(storageLocation: "cdn.cookielaw.org", domainIdentifier: domainId, languageCode: "en") { OTResponse in
            
            //OTPublishersHeadlessSDK.shared.checkAndLogConsent(for: .idfa)
            //print(OTResponse.responseString as Any)
            //print("Done")
        }
        
        /*
         // CBS Code
         private func initializeOTSDKData(completion: @escaping ()->()) {
             let sdkParams = OTSdkParams(countryCode: nil, regionCode: nil)
             let domainIdentifier: String
             #if DEBUG
             domainIdentifier = "3635a6b8-4f34-418e-adad-49dea7fd7faa-test"
             #else
             domainIdentifier = "3635a6b8-4f34-418e-adad-49dea7fd7faa"
             #endif
             OTPublishersHeadlessSDK.shared.startSDK(storageLocation: "cdn.cookielaw.org",
                                                     domainIdentifier: domainIdentifier,
                                                     languageCode: "en",
                                                     params: sdkParams) {[weak self] (response) in
                 logDebug("Current CCPA String: \(self?.ccpaString ?? "[NONE]")", tag: "OTHeadlessSDK")
                 completion()
             }
         }
         */
    }
    
    // MARK: - Init Airship
    
    private func initAirship(launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    {
        Airship.logLevel = .trace
        Airship.takeOff(launchOptions: launchOptions)
        Airship.shared.deepLinkDelegate = self
        Airship.push.autobadgeEnabled = true
        Airship.push.pushNotificationDelegate = self
        Airship.push.registrationDelegate = self
        Airship.push.notificationOptions = [.sound, .alert]
        Airship.push.updateRegistration()
    }
    
    // MARK: - Init Qualtrics
    
    private func initQualtrics()
    {
        // Added in V6.3.1
        if (MiscHelper.privacyStatusForUser(consentCategory: "4") == 0)
        {
            return
        }
        
        // Qualtrics Constants
        let kQualtricsBrandId = "cbs"
        let kQualtricsInterceptId = "SI_2cnYhBe5zJDnZDT"
        let kQualtricsProjectId = "ZN_37MPtKLTsYZ3Yj3"
        
        Qualtrics.shared.initializeProject(brandId: kQualtricsBrandId, projectId: kQualtricsProjectId, extRefId: kQualtricsInterceptId, completion: { (myInitializationResult) in
            
            print(myInitializationResult)
            
        })
    }
    
    // MARK: - Register for Notifications
    
    func registerForNotifications()
    {
        // This called by the TabBarController after login is closed
        print("Register for Notifications called")
        
        //SharedData.deviceToken = ""
        Airship.push.userPushNotificationsEnabled = true
        
        /*
        let center  = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                        
            if error == nil
            {
                DispatchQueue.main.async
                {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        */
    }
    
    // MARK: - Push Notification Delegate
    
    func receivedNotificationResponse(_ notificationResponse: UNNotificationResponse, completionHandler: @escaping () -> Void)
    {
        let responseDictionary = notificationResponse.notification.request.content.userInfo
         
        // Look for the action property to determine if this is a athlete, team, or contest notification
        // Empty notification strings are indicated with a #
        let action = responseDictionary["action"] as? String ?? ""
        let itemType = responseDictionary["itemType"] as? String ?? ""
        let careerId = responseDictionary["playerIds"] as? String ?? ""
        //let ssid = responseDictionary["ssId"] as? String ?? ""
        //let schoolId = responseDictionary["schoolIds"] as? String ?? ""
        let urlString = responseDictionary["url"] as? String ?? ""
        
        // Debug
        //let message = String(format: "action: %@\nitemType: %@", action,itemType)
        //MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "Notification", message: message, lastItemCancelType: false) { tag in
            
        //}
        
        if (action.lowercased() == "career")
        {
            // The tabName is the itemType
            let userInfo = ["careerId":careerId, "type":"career", "ftag":"", "tabName": itemType]
            
            // Post a system notification
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
            {
                NotificationCenter.default.post(name: Notification.Name("FollowingDeepLink"), object: self, userInfo: userInfo)
            }
        }
        else if (action.lowercased() == "team")
        {
            if (urlString.count > 1)
            {
                // Added itemType to V6.2.8 so the web title can be set to
                let userInfo = ["url":urlString, "type":"web", "ftag":"", "itemType":itemType]
                
                // Post a system notification
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                {
                    NotificationCenter.default.post(name: Notification.Name("LatestDeepLink"), object: self, userInfo: userInfo)
                }
            }
        }
        else if (action.lowercased() == "contest")
        {
            if (urlString.count > 1)
            {
                // Added itemType to V6.2.8 so the web title can be set to
                let userInfo = ["url":urlString, "type":"web", "ftag":"", "itemType":itemType]
                
                // Post a system notification
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                {
                    NotificationCenter.default.post(name: Notification.Name("ScoresDeepLink"), object: self, userInfo: userInfo)
                }
            }
        }
        else // Backup case
        {
            if (urlString.count > 1)
            {
                let userInfo = ["url":urlString, "type":"web", "ftag":""]
                
                // Post a system notification
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                {
                    NotificationCenter.default.post(name: Notification.Name("LatestDeepLink"), object: self, userInfo: userInfo)
                }
            }
        }
        
        // Call Tracking
        TrackingManager.trackNotification(responseDictionary)
    }
    
    func receivedBackgroundNotification(_ userInfo: [AnyHashable: Any], completionHandler: @escaping (UIBackgroundFetchResult) -> Swift.Void)
    {
        // Application received a background notification
        print("The application received a background notification");

        // Call the completion handler
        completionHandler(.noData)
    }

    func receivedForegroundNotification(_ userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Swift.Void)
    {
        // Application received a foreground notification
        print("The application received a foreground notification");
        
        // Reset the badge
        Airship.push.resetBadge()
        
        // Call Tracking
        TrackingManager.trackNotification(userInfo)
        
        completionHandler()
    }
    
    func extend(_ options: UNNotificationPresentationOptions, notification: UNNotification) -> UNNotificationPresentationOptions
    {
        print("Foreground Options")
        return options.union([.banner, .sound])
    }

    // MARK: - Airship Registration Delegate
    
    func apnsRegistrationSucceeded(withDeviceToken deviceToken: Data)
    {
        let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        
        SharedData.deviceToken = tokenString
        print(tokenString)
    }
    
    func apnsRegistrationFailedWithError(_ error: Error)
    {
        SharedData.deviceToken = ""
    }
    
    // MARK: - Branch Deep Link Delegate for Airship
    
    func receivedDeepLink(_ deepLink: URL, completionHandler: @escaping () -> Void)
    {
        if (Branch.getInstance().handleDeepLink(withNewSession: deepLink) == true)
        {
            completionHandler()
            return
        }
    }
    
    // MARK: - Open URL Delegates
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool
    {
        // Warm launch deep link
        return Branch.getInstance().application(app, open: url, options: options)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    {
      // handler for Universal Links
        return Branch.getInstance().continue(userActivity)
    }
    
    // MARK: - Deep Linking
    
    func showDeepLink(parameters: Dictionary<AnyHashable,Any>)
    {
        /*
        if (self.deepLinkBusy == true)
        {
            return
        }
        else
        {
            self.deepLinkBusy = true
        }
        
        // Set the deepLinkBusy flag to false after 2 seconds. This prevents multiple deep links from occurring
        DispatchQueue.main.asyncAfter(deadline: .now() + 3)
        {
            self.deepLinkBusy = false
        }
        */
        
        //print(parameters as? [String: AnyObject] ?? {})
        // maxpreps_career_id
        // maxpreps_context
        // maxpreps_tab
        
        if let context = parameters["maxpreps_context"] as? String
        {
            //MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "Deep Link", message: context, lastItemCancelType: false) { tag in
                
            //}
            
            if (context.lowercased() == "web")
            {
                let canonicalUrl = parameters["$canonical_url"] as? String ?? ""
                let tab = parameters["maxpreps_tab"] as? String ?? ""
                let ftag = parameters["maxpreps_ftag"] as? String ?? ""
                
                if ((canonicalUrl.count > 0) && (tab.count > 0))
                {
                    let responseDictionary = ["url":canonicalUrl, "type":"web", "ftag":ftag]
                    
                    // Post a system notification
                    // Add a little delay so the screen can settle down
                    if (tab == "0")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                        {
                            NotificationCenter.default.post(name: Notification.Name("LatestDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                    else if (tab == "1")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            NotificationCenter.default.post(name: Notification.Name("FollowingDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                    else if (tab == "2")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            NotificationCenter.default.post(name: Notification.Name("ScoresDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                }
            }
            else if (context.lowercased() == "career")
            {
                let careerId = parameters["maxpreps_career_id"] as? String ?? ""
                let tab = parameters["maxpreps_tab"] as? String ?? ""
                let ftag = parameters["maxpreps_ftag"] as? String ?? ""
                
                if ((careerId.count > 0) && (tab.count > 0))
                {
                    let responseDictionary = ["careerId":careerId, "type":"career", "ftag":ftag, "tabName": ""]
                     
                    // Post a system notification
                    // Add a little delay so the screen can settle down
                    if (tab == "0")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                        {
                            NotificationCenter.default.post(name: Notification.Name("LatestDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                    else if (tab == "1")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            NotificationCenter.default.post(name: Notification.Name("FollowingDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                    else if (tab == "2")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            NotificationCenter.default.post(name: Notification.Name("ScoresDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                }
            }
            else if (context.lowercased() == "career/videos")
            {
                let careerId = parameters["maxpreps_career_id"] as? String ?? ""
                let tab = parameters["maxpreps_tab"] as? String ?? ""
                let ftag = parameters["maxpreps_ftag"] as? String ?? ""
                
                if ((careerId.count > 0) && (tab.count > 0))
                {
                    let responseDictionary = ["careerId":careerId, "type":"career", "ftag":ftag, "tabName": "videos"]
                     
                    // Post a system notification
                    // Add a little delay so the screen can settle down
                    if (tab == "0")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                        {
                            NotificationCenter.default.post(name: Notification.Name("LatestDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                    else if (tab == "1")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            NotificationCenter.default.post(name: Notification.Name("FollowingDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                    else if (tab == "2")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            NotificationCenter.default.post(name: Notification.Name("ScoresDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                }
            }
            else if (context.lowercased() == "team")
            {
                let schoolId = parameters["maxpreps_school_id"] as? String ?? ""
                let ssid = parameters["maxpreps_ssid"] as? String ?? ""
                let tab = parameters["maxpreps_tab"] as? String ?? ""
                let ftag = parameters["maxpreps_ftag"] as? String ?? ""
                
                if ((schoolId.count > 0) && (ssid.count > 0) && (tab.count > 0))
                {
                    let responseDictionary = ["schoolId":schoolId, "ssid":ssid, "type":"team", "ftag":ftag, "tabName": ""]
                     
                    // Post a system notification
                    // Add a little delay so the screen can settle down
                    if (tab == "0")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                        {
                            NotificationCenter.default.post(name: Notification.Name("LatestDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                    else if (tab == "1")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            NotificationCenter.default.post(name: Notification.Name("FollowingDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                    else if (tab == "2")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            NotificationCenter.default.post(name: Notification.Name("ScoresDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                }
            }
            else if (context.lowercased() == "team/videos")
            {
                let schoolId = parameters["maxpreps_school_id"] as? String ?? ""
                let ssid = parameters["maxpreps_ssid"] as? String ?? ""
                let tab = parameters["maxpreps_tab"] as? String ?? ""
                let ftag = parameters["maxpreps_ftag"] as? String ?? ""
                
                if ((schoolId.count > 0) && (ssid.count > 0) && (tab.count > 0))
                {
                    let responseDictionary = ["schoolId":schoolId, "ssid":ssid, "type":"team", "ftag":ftag, "tabName": "videos"]
                     
                    // Post a system notification
                    // Add a little delay so the screen can settle down
                    if (tab == "0")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                        {
                            NotificationCenter.default.post(name: Notification.Name("LatestDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                    else if (tab == "1")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            NotificationCenter.default.post(name: Notification.Name("FollowingDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                    else if (tab == "2")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            NotificationCenter.default.post(name: Notification.Name("ScoresDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                }
            }
            else if (context.lowercased() == "team/schedule")
            {
                let schoolId = parameters["maxpreps_school_id"] as? String ?? ""
                let ssid = parameters["maxpreps_ssid"] as? String ?? ""
                let tab = parameters["maxpreps_tab"] as? String ?? ""
                let ftag = parameters["maxpreps_ftag"] as? String ?? ""
                
                if ((schoolId.count > 0) && (ssid.count > 0) && (tab.count > 0))
                {
                    let responseDictionary = ["schoolId":schoolId, "ssid":ssid, "type":"team", "ftag":ftag, "tabName": "schedule"]
                     
                    // Post a system notification
                    // Add a little delay so the screen can settle down
                    if (tab == "0")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                        {
                            NotificationCenter.default.post(name: Notification.Name("LatestDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                    else if (tab == "1")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            NotificationCenter.default.post(name: Notification.Name("FollowingDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                    else if (tab == "2")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            NotificationCenter.default.post(name: Notification.Name("ScoresDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                }
            }
            else if (context.lowercased() == "team/rankings")
            {
                let schoolId = parameters["maxpreps_school_id"] as? String ?? ""
                let ssid = parameters["maxpreps_ssid"] as? String ?? ""
                let tab = parameters["maxpreps_tab"] as? String ?? ""
                let ftag = parameters["maxpreps_ftag"] as? String ?? ""
                
                if ((schoolId.count > 0) && (ssid.count > 0) && (tab.count > 0))
                {
                    let responseDictionary = ["schoolId":schoolId, "ssid":ssid, "type":"team", "ftag":ftag, "tabName": "rankings"]
                     
                    // Post a system notification
                    // Add a little delay so the screen can settle down
                    if (tab == "0")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                        {
                            NotificationCenter.default.post(name: Notification.Name("LatestDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                    else if (tab == "1")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            NotificationCenter.default.post(name: Notification.Name("FollowingDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                    else if (tab == "2")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            NotificationCenter.default.post(name: Notification.Name("ScoresDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                }
            }
            else if (context.lowercased() == "team/photos")
            {
                let schoolId = parameters["maxpreps_school_id"] as? String ?? ""
                let ssid = parameters["maxpreps_ssid"] as? String ?? ""
                let tab = parameters["maxpreps_tab"] as? String ?? ""
                let ftag = parameters["maxpreps_ftag"] as? String ?? ""
                
                if ((schoolId.count > 0) && (ssid.count > 0) && (tab.count > 0))
                {
                    let responseDictionary = ["schoolId":schoolId, "ssid":ssid, "type":"team", "ftag":ftag, "tabName": "photos"]
                     
                    // Post a system notification
                    // Add a little delay so the screen can settle down
                    if (tab == "0")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                        {
                            NotificationCenter.default.post(name: Notification.Name("LatestDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                    else if (tab == "1")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            NotificationCenter.default.post(name: Notification.Name("FollowingDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                    else if (tab == "2")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                        {
                            NotificationCenter.default.post(name: Notification.Name("ScoresDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                }
            }
            else if (context.lowercased() == "user/notifications")
            {
                let tab = parameters["maxpreps_tab"] as? String ?? ""
                let ftag = parameters["maxpreps_ftag"] as? String ?? ""
                
                if (tab.count > 0)
                {
                    let responseDictionary = ["type":"user", "ftag":ftag, "tabName": "notifications"]
                     
                    // Post a system notification
                    // Add a little delay so the screen can settle down
                    if (tab == "0")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                        {
                            NotificationCenter.default.post(name: Notification.Name("LatestDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                }
            }
            else if (context.lowercased() == "arena/playoffs")
            {
                let tab = parameters["maxpreps_tab"] as? String ?? ""
                let ftag = parameters["maxpreps_ftag"] as? String ?? ""
                let gender = parameters["maxpreps_gender"] as? String ?? ""
                let sport = parameters["maxpreps_sport"] as? String ?? ""
                
                if ((tab.count > 0) && (gender.count > 0) && (sport.count > 0))
                {
                    let responseDictionary = ["type":"arena", "ftag":ftag, "tabName": "playoffs", "gender": gender, "sport": sport]
                     
                    // Post a system notification
                    // Add a little delay so the screen can settle down
                    if (tab == "0")
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                        {
                            NotificationCenter.default.post(name: Notification.Name("LatestDeepLink"), object: self, userInfo: responseDictionary)
                        }
                    }
                }
            }
        }
        else
        {
            //MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "Deep Link", message: "MaxPreps meta tags not found.", lastItemCancelType: false) { tag in
                
            //}
            
            // Fallback case where the URL is decomposed
            let canonicalUrl = parameters["$canonical_url"] as? String ?? ""
            
            if (canonicalUrl.count > 0)
            {
                let responseDictionary = ["url":canonicalUrl, "type":"web", "ftag":""]
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                {
                    NotificationCenter.default.post(name: Notification.Name("LatestDeepLink"), object: self, userInfo: responseDictionary)
                }
            }
        }
    }
    
    // MARK: - Add Scoreboards
    
    private func addScoreboards()
    {
        var footballScoreboardFound = false
        var basketballScoreboardFound = false
        var baseballScoreboardFound = false
        
        var allScoreboards = kUserDefaults.array(forKey: kUserScoreboardsArrayKey) as! Array<Dictionary<String,String>>
        
        // Get the current month
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M"
        let currentMonth = dateFormatter.string(from: Date())
        
        // Iterate through all of the scoreboards to look for a gender-sport match
        for scoreboard in allScoreboards
        {
            let gender = scoreboard[kScoreboardGenderKey]
            let sport = scoreboard[kScoreboardSportKey]
            let type = scoreboard[kScoreboardDefaultNameKey]
            
            if (("Boys" == gender) && ("Football" == sport) && (type == "national"))
            {
                footballScoreboardFound = true
            }
            
            if (("Boys" == gender) && ("Basketball" == sport) && (type == "national"))
            {
                basketballScoreboardFound = true
            }
            
            if (("Boys" == gender) && ("Baseball" == sport) && (type == "national"))
            {
                baseballScoreboardFound = true
            }
        }
        
        var installFootball = false
        var installBasketball = false
        var installBaseball = false
        
        switch currentMonth
        {
        case "1":
            installFootball = false
            installBasketball = true
            installBaseball = false
        case "2":
            installFootball = false
            installBasketball = true
            installBaseball = false
        case "3":
            installFootball = false
            installBasketball = true
            installBaseball = false
        case "4":
            installFootball = false
            installBasketball = false
            installBaseball = true
        case "5":
            installFootball = false
            installBasketball = false
            installBaseball = true
        case "6":
            installFootball = false
            installBasketball = true
            installBaseball = false
        case "7":
            installFootball = false
            installBasketball = false
            installBaseball = false
        case "8":
            installFootball = true
            installBasketball = false
            installBaseball = false
        case "9":
            installFootball = true
            installBasketball = false
            installBaseball = false
        case "10":
            installFootball = true
            installBasketball = false
            installBaseball = false
        case "11":
            installFootball = true
            installBasketball = false
            installBaseball = false
        case "12":
            installFootball = false
            installBasketball = true
            installBaseball = false
        default:
            return
        }
        
        let footballInstalledPreviously = kUserDefaults.bool(forKey: kFootballScoreboardInstalledKey)
        let basketballInstalledPreviously = kUserDefaults.bool(forKey: kBasketballScoreboardInstalledKey)
        let baseballInstalledPreviously = kUserDefaults.bool(forKey: kBaseballScoreboardInstalledKey)
        
        if ((footballScoreboardFound == false) && (installFootball == true) && (footballInstalledPreviously == false))
        {
            // Add National Football
            let selectedMetro = [kScoreboardDefaultNameKey: "national", kScoreboardAliasNameKey: "Top National Teams", kScoreboardGenderKey: "Boys", kScoreboardSportKey: "Football", kScoreboardStateNameKey: "Top National Teams", kScoreboardStateCodeKey: "", kScoreboardEntityIdKey: "25", kScoreboardEntityNameKey: "", kScoreboardDivisionTypeKey: "", kScoreboardSectionNameKey: ""]
            
            // Save the scoreboard to prefs
            allScoreboards.append(selectedMetro)
            kUserDefaults.setValue(allScoreboards, forKey: kUserScoreboardsArrayKey)
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: true), forKey: kFootballScoreboardInstalledKey)
        }
        
        if ((basketballScoreboardFound == false) && (installBasketball == true) && (basketballInstalledPreviously == false))
        {
            // Add National Basketball
            let selectedMetro = [kScoreboardDefaultNameKey: "national", kScoreboardAliasNameKey: "Top National Teams", kScoreboardGenderKey: "Boys", kScoreboardSportKey: "Basketball", kScoreboardStateNameKey: "Top National Teams", kScoreboardStateCodeKey: "", kScoreboardEntityIdKey: "25", kScoreboardEntityNameKey: "", kScoreboardDivisionTypeKey: "", kScoreboardSectionNameKey: ""]
            
            // Save the scoreboard to prefs
            allScoreboards.append(selectedMetro)
            kUserDefaults.setValue(allScoreboards, forKey: kUserScoreboardsArrayKey)
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: true), forKey: kBasketballScoreboardInstalledKey)
        }

        if ((baseballScoreboardFound == false) && (installBaseball == true) && (baseballInstalledPreviously == false))
        {
            // Add National Baseball
            let selectedMetro = [kScoreboardDefaultNameKey: "national", kScoreboardAliasNameKey: "Top National Teams", kScoreboardGenderKey: "Boys", kScoreboardSportKey: "Baseball", kScoreboardStateNameKey: "Top National Teams", kScoreboardStateCodeKey: "", kScoreboardEntityIdKey: "25", kScoreboardEntityNameKey: "", kScoreboardDivisionTypeKey: "", kScoreboardSectionNameKey: ""]
            
            // Save the scoreboard to prefs
            allScoreboards.append(selectedMetro)
            kUserDefaults.setValue(allScoreboards, forKey: kUserScoreboardsArrayKey)
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: true), forKey: kBaseballScoreboardInstalledKey)
        }
    }
    
    // MARK: - Init Preferences
    
    func initPreferences()
    {
        if (kUserDefaults.object(forKey: kCurrentLocationKey) == nil)
        {
            // EDH is located here -121.070664, 38.679866. Used as the default
            //let initialLocation = [kLatitudeKey: "38.679866", kLongitudeKey: "-121.070664"]
            //kUserDefaults.setValue(initialLocation, forKey: kCurrentLocationKey)
            
            kUserDefaults.setValue(kDefaultSchoolLocation, forKey: kCurrentLocationKey)
        }
        
        // Initialize the userId
        if (kUserDefaults.object(forKey: kUserIdKey) == nil)
        {
            kUserDefaults.setValue(kEmptyGuid, forKey: kUserIdKey)
        }
        
        // Initialize the user email
        if (kUserDefaults.object(forKey: kUserEmailKey) == nil)
        {
            kUserDefaults.setValue("", forKey: kUserEmailKey)
        }
        
        // Initialize the user first name
        if (kUserDefaults.object(forKey: kUserFirstNameKey) == nil)
        {
            kUserDefaults.setValue("", forKey: kUserFirstNameKey)
        }
        
        // Initialize the user last name
        if (kUserDefaults.object(forKey: kUserLastNameKey) == nil)
        {
            kUserDefaults.setValue("", forKey: kUserLastNameKey)
        }
        
        // Initialize the user zip
        if (kUserDefaults.object(forKey: kUserZipKey) == nil)
        {
            kUserDefaults.setValue("", forKey: kUserZipKey)
        }
                
        // Initialize the token buster
        if (kUserDefaults.object(forKey: kTokenBusterKey) == nil)
        {
            kUserDefaults.setValue("", forKey: kTokenBusterKey)
        }
        
        // Initialize the photoUrl
        if (kUserDefaults.object(forKey: kUserPhotoUrlKey) == nil)
        {
            kUserDefaults.setValue("", forKey: kUserPhotoUrlKey)
        }
        
        // Initialize the careerPhotoUrl
        if (kUserDefaults.object(forKey: kUserCareerPhotoUrlKey) == nil)
        {
            kUserDefaults.setValue("", forKey: kUserCareerPhotoUrlKey)
        }
        
        // Force Production Server
        if (kUserDefaults.object(forKey: kServerModeKey) == nil)
        {
            kUserDefaults.setValue(kServerModeProduction, forKey: kServerModeKey)
        }
        
        // Set the initial branch value
        if (kUserDefaults.object(forKey: kBranchValue) == nil)
        {
            kUserDefaults.setValue("", forKey: kBranchValue)
        }
        
        // Video Autoplay
        if (kUserDefaults.object(forKey: kVideoAutoplayModeKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(value: 2), forKey: kVideoAutoplayModeKey)
        }
        
        // Debug Dialogs
        if (kUserDefaults.object(forKey: kDebugDialogsKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kDebugDialogsKey)
        }
        
        // Notification Master Enable (Changed in V6.1.8)
        //if (kUserDefaults.object(forKey: kNotificationMasterEnableKey) == nil)
        //{
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: true), forKey: kNotificationMasterEnableKey)
        //}
        /*
        // Video PIP Enable and audio mix
        if (kUserDefaults.object(forKey: kVideoPipEnableKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: true), forKey: kVideoPipEnableKey)
        }
        */
        if (kUserDefaults.object(forKey: kAudioMixEnableKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: true), forKey: kAudioMixEnableKey)
        }
        
        // SelectedFavoriteIndex
        if (kUserDefaults.object(forKey: kSelectedFavoriteIndexKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(integerLiteral: 0), forKey: kSelectedFavoriteIndexKey)
        }
        
        // SelectedFavoriteSection
        if (kUserDefaults.object(forKey: kSelectedFavoriteSectionKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(integerLiteral: 0), forKey: kSelectedFavoriteSectionKey)
        }
        
        if (kUserDefaults.object(forKey: kNewUserFavoriteTeamsArrayKey) == nil)
        {
            let emptyFavs = [] as Array<Any>
            kUserDefaults.setValue(emptyFavs, forKey: kNewUserFavoriteTeamsArrayKey)
        }
        
        if (kUserDefaults.object(forKey: kUserFavoriteAthletesArrayKey) == nil)
        {
            let emptyFavs = [] as Array<Any>
            kUserDefaults.setValue(emptyFavs, forKey: kUserFavoriteAthletesArrayKey)
        }
        
        if (kUserDefaults.object(forKey: kUserScoreboardsArrayKey) == nil)
        {
            let emptyFavs = [] as Array<Any>
            kUserDefaults.setValue(emptyFavs, forKey: kUserScoreboardsArrayKey)
        }
        
        if (kUserDefaults.object(forKey: kFootballScoreboardInstalledKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kFootballScoreboardInstalledKey)
        }
        
        if (kUserDefaults.object(forKey: kBasketballScoreboardInstalledKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kBasketballScoreboardInstalledKey)
        }
        
        if (kUserDefaults.object(forKey: kBaseballScoreboardInstalledKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kBaseballScoreboardInstalledKey)
        }
        
        if (kUserDefaults.object(forKey: kContestNotificationsDictionaryKey) == nil)
        {
            let emptyDict = [:] as Dictionary<String,Any>
            kUserDefaults.setValue(emptyDict, forKey: kContestNotificationsDictionaryKey)
        }
        
        if (kUserDefaults.object(forKey: kNewSchoolInfoDictionaryKey) == nil)
        {
            let emptyDictionary = [:] as Dictionary<String,Any>
            kUserDefaults.setValue(emptyDictionary, forKey: kNewSchoolInfoDictionaryKey)
        }
        
        if (kUserDefaults.object(forKey: kUserAdminRolesDictionaryKey) == nil)
        {
            let emptyDictionary = [:] as Dictionary<String,Any>
            kUserDefaults.setValue(emptyDictionary, forKey: kUserAdminRolesDictionaryKey)
        }
        
        if (kUserDefaults.object(forKey: kUserAdminRolesArrayKey) == nil)
        {
            let emptyArray = [] as Array<Any>
            kUserDefaults.setValue(emptyArray, forKey: kUserAdminRolesArrayKey)
        }
        
        // Make a fallback user identifier for the FMS feed
        if (kUserDefaults.object(forKey: kFallbackUserIdKey) == nil)
        {
            let guid = NSUUID()
            kUserDefaults.setValue(guid.uuidString, forKey: kFallbackUserIdKey)
        }
        
        if (kUserDefaults.object(forKey: kAdobeMarketingCloudIdKey) == nil)
        {
            kUserDefaults.setValue("", forKey: kAdobeMarketingCloudIdKey)
        }
        
        if (kUserDefaults.object(forKey: kVCID2Key) == nil)
        {
            kUserDefaults.setValue("", forKey: kVCID2Key)
        }
        
        if (kUserDefaults.object(forKey: kVCID2TypeKey) == nil)
        {
            kUserDefaults.setValue("", forKey: kVCID2TypeKey)
        }
        
        if (kUserDefaults.object(forKey: kUID2Key) == nil)
        {
            kUserDefaults.setValue("", forKey: kUID2Key)
        }
        
        if (kUserDefaults.object(forKey: kOneTrustShownKey) == nil)
        {
            kUserDefaults.setValue(false, forKey: kOneTrustShownKey)
        }
        
        if (kUserDefaults.object(forKey: kVerticalVideoBumpCountKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(integerLiteral: 0), forKey: kVerticalVideoBumpCountKey)
        }
        
        // Populate some national scoreboards
        self.addScoreboards()
    }
    
    // MARK: - Global Appearance
    
    func setupGlobalAppearance()
    {
        // Global Appearance settings
        
        // Change the back button to use a better arrow
        let backImage = UIImage(named: "BackArrowBlack")
        UINavigationBar.appearance().backIndicatorImage = backImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage
        UINavigationBar.appearance().backItem?.backButtonDisplayMode = .default //.minimal

        // Change the tab bar colors and font
        // This is ignored in iOS 15.
        // These attributes are now set in the tabBarController
        
        //UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.mpDarkGrayColor(), NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 12)], for: .normal)
        //UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.mpRedColor(), NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 12)], for: .selected)
        
        // This is needed in iOS 15 to get rid of the extra pad
        if #available(iOS 15.0, *)
        {
            UITableView.appearance().sectionHeaderTopPadding = 0
        }

    }
    
    // MARK: - App Lifecycle

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // Update the global UTC time value
        MiscHelper.getUTCTimeOffset()
        
        // Delay the launch slightly
        Thread.sleep(forTimeInterval: 0.5)
        
        // Set the cold launch flag
        SharedData.coldLaunch = true
        
        let kRootDirectory = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("").path
        print("Application Root: " + kRootDirectory);
        
        // Set the global device type
        let deviceType = UIDevice.current.model.lowercased()
        
        if (deviceType == "ipad")
        {
            SharedData.deviceType = DeviceType.ipad
        }
        else
        {
            SharedData.deviceType = DeviceType.iphone
        }
        
        // Set the device aspect ratio
        
        // iPhone 4s - 640 x 960 (@2x) (320 x 480) Aspect = 1.5
        // iPhone 5 - 640 x 1136 (@2x) (320 x 568) Aspect = 1.775
        // iPhone 6 - 750 x 1334 (@2x) (375 x 667) Aspect = 1.778
        // iPhone 6+  1242 × 2208 (@3x) (414 x 736) Aspect = 1.777
        // iPhone X, 12 Mini - 1125 x 2436 (@3x) (375 x 812) Aspect = 2.165
        // iPhone Xr, 11 - 828 x 1792 (@2x) (414 x 896) Aspect = 2.164
        // iPhone Xs Max - 1242 x 2688 (@3x) (414 x 896) Aspect = 2.164
        // iPhone 12, 12 Pro - 1170 x 2532 (@3x) (390 x 844) Aspect = 2.164
        // iPhone 12 Pro Max - 1284 x 2788 (@3x) (428 x 926) Aspect = 2.163
        
        let aspectRatio: CGFloat = kDeviceHeight / kDeviceWidth
        
        if (aspectRatio <= 1.5)
        {
            SharedData.deviceAspectRatio = AspectRatio.low
        }
        else if ((aspectRatio > 1.5) && (aspectRatio < 2))
        {
            SharedData.deviceAspectRatio = AspectRatio.medium
        }
        else
        {
            SharedData.deviceAspectRatio = AspectRatio.high
        }
        
        // Get the userAgent for tracking
        SharedData.userAgent = WKWebView().value(forKey: "userAgent") as! String
        
        
        // Init the user prefs
        self.initPreferences()
        
        // Setup global appearance
        self.setupGlobalAppearance()

        // Load the schools file
        self.getSchoolsFile()
        
        // Init Airship
        self.initAirship(launchOptions: launchOptions)
        
        // Build the tracking dictionary
        self.buildTrackingDictionary()
        
        // Initialize Amazon Ads
        self.initializeAmazonAds()
        
        // No longer needed
        //self.initializeMoPub()
        
        // Load the Google Ad IDs
        self.loadGoolgeAdIds()
        
        // Load the Google COPPA setting
        self.loadGoogleCoppaSettings()
        
        // Load Nimbus
        self.initializeNimbus()
        
        // Get the FMS data for the video player
        self.getFMSData()
        
        // Init Adobe Tracking
        self.initAdobeTracking()
        
        // Init UVPN Tracking with Comscore
        self.initUVPNTracking()
        
        // Init Branch
        self.initBranch(launchOptions: launchOptions)
        
        // Init OneTrust
        self.initOneTrust()
        
        // Init Qualtrics
        self.initQualtrics()
        
        // Logout the user if they are a guest
        if (kUserDefaults.string(forKey: kUserIdKey) == kTestDriveUserId)
        {
            // Clear out the user's prefs
            MiscHelper.logoutUser()
        }
        
        // Clear out any shortcut items from the old red app
        UIApplication.shared.shortcutItems = nil
        
        return true
    }

    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}

