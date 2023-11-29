//
//  TrackingManager.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/15/22.
//

import Foundation

class TrackingManager: NSObject
{
    // MARK: - Page Tracking
    
    class func trackState(featureName: String, trackingGuid: String, cData: Dictionary<String,Any>)
    {
        // Skip if the featureName is empty
        if (featureName == "")
        {
            return
        }
        
        // Skip if the featureName doesn't exist in the shared trackingDictionary
        if (SharedData.trackingDictionary[featureName] == nil)
        {
            print("Tracking Key Missing")
            //let trackingDict = SharedData.trackingDictionary
            //print(trackingDict)
            return
        }
        
        // Load the basics
        var contextData = [:] as Dictionary<String,Any>
        
        var rsid = "cbsimaxprepsapp"
        
        if ((kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch) || (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev))
        {
            rsid = "cbsimaxprepsapp-dev"
        }
        
        contextData["siteCode"] = "maxpreps"
        contextData["sitePrimaryRsid"] = rsid
        contextData["siteEdition"] = "us"
        contextData["brandplatformid"] = "maxpreps_app_ios"
        contextData["pageViewGuid"] = trackingGuid.lowercased()
        contextData["MID"] = kUserDefaults.string(forKey: kAdobeMarketingCloudIdKey) //SharedData.adobeMID
        
        let shortVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let version = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        let appId = String(format: "MPScoreboard3 %@ (%@)", shortVersion, version)
        contextData["appID"] = appId
        
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        if (userId == kEmptyGuid)
        {
            contextData[kTrackingUserIdKey] = ""
            contextData[kTrackingUserStateKey] = "not authenticated"
            contextData[kTrackingUserTypeKey] = "anon"
        }
        else if (userId == kTestDriveUserId)
        {
            contextData[kTrackingUserIdKey] = userId
            contextData[kTrackingUserStateKey] = "not authenticated"
            contextData[kTrackingUserTypeKey] = "anon"
        }
        else
        {
            contextData[kTrackingUserIdKey] = userId
            contextData[kTrackingUserStateKey] = "authenticated"
            contextData[kTrackingUserTypeKey] = "registered"
        }
        
        // The siteHier and pageType are extracted from a shared dictionary that was created from the Tracking.csv file during app init. The key for this dictionary is the featureName property which is set from the caller. This is used to find which line to use in the csv file.
        
        let innerTrackingDictionary = SharedData.trackingDictionary[featureName] as! Dictionary<String,String>
        let siteHier = innerTrackingDictionary[kTrackingSiteHierKey]
        let pageType = innerTrackingDictionary[kTrackingPageTypeKey]

        contextData[kTrackingSiteHierKey] = siteHier
        contextData[kTrackingPageTypeKey] = pageType
        contextData[kTrackingPageNameKey] = featureName
        
        // Finally look for the various tracking keys in the cData to append to the contextDictionary
        let trackingUserTeamRole = cData[kTrackingUserTeamRoleKey] as? String ?? ""
        let trackingSportGender = cData[kTrackingSportGenderKey] as? String ?? "no gender assigned"
        let trackingSportLevel = cData[kTrackingSportLevelKey] as? String ?? "no level assigned"
        let trackingSportName = cData[kTrackingSportNameKey] as? String ?? "no sport assigned"
        let trackingSchoolName = cData[kTrackingSchoolNameKey] as? String ?? "no school assigned"
        let trackingSchoolState = cData[kTrackingSchoolStateKey] as? String ?? "no school assigned"
        let trackingSchoolYear = cData[kTrackingSchoolYearKey] as? String ?? "no year specified"
        let trackingSeason = cData[kTrackingSeasonKey] as? String ?? "no season assigned"
        let trackingCareerName = cData[kTrackingCareerNameKey] as? String ?? "no player assigned"
        let trackingTeamId = cData[kTrackingTeamIdKey] as? String ?? "no school assigned"
        let trackingPlayerId = cData[kTrackingPlayerIdKey] as? String ?? "no player assigned"
        let trackingArticleId = cData[kTrackingArticleIdKey] as? String ?? ""
        let trackingArticleTitle = cData[kTrackingArticleTitleKey] as? String ?? ""
        let trackingArticleType = cData[kTrackingArticleTypeKey] as? String ?? ""
        let trackingFiltersApplied = cData[kTrackingFiltersAppliedKey] as? String ?? ""
        let trackingClickText = cData[kTrackingClickTextKey] as? String ?? ""
        let trackingFtag = cData[kTrackingFtagKey] as? String ?? ""
        
        contextData[kTrackingUserTeamRoleKey] = trackingUserTeamRole
        contextData[kTrackingSportGenderKey] = trackingSportGender
        contextData[kTrackingSportLevelKey] = trackingSportLevel
        contextData[kTrackingSportNameKey] = trackingSportName
        contextData[kTrackingSchoolNameKey] = trackingSchoolName
        contextData[kTrackingSchoolStateKey] = trackingSchoolState
        contextData[kTrackingSchoolYearKey] = trackingSchoolYear
        contextData[kTrackingSeasonKey] = trackingSeason
        contextData[kTrackingCareerNameKey] = trackingCareerName
        contextData[kTrackingTeamIdKey] = trackingTeamId
        contextData[kTrackingPlayerIdKey] = trackingPlayerId
        contextData[kTrackingCareerIdKey] = trackingPlayerId // Added in build 6.3.2
        contextData[kTrackingArticleIdKey] = trackingArticleId
        contextData[kTrackingArticleTitleKey] = trackingArticleTitle
        contextData[kTrackingArticleTypeKey] = trackingArticleType
        contextData[kTrackingFiltersAppliedKey] = trackingFiltersApplied
        contextData[kTrackingClickTextKey] = trackingClickText
        contextData[kTrackingFtagKey] = trackingFtag
        
        // Fire off the tracking
        ADBMobile.trackState(pageType, data: contextData)
        
        print(featureName + " page tracking sent")
        
        if ((featureName == "career-video-watch") || (featureName == "video-watch") || (featureName == "team-video-watch"))
        {
            print("Video tracking sent")
        }
        
        /*
         // Page Tracking Keys
         let kTrackingSportGenderKey = "sportGender"
         let kTrackingSportLevelKey = "sportLevel"
         let kTrackingSportNameKey = "sportName"
         let kTrackingSchoolNameKey = "schoolName"
         let kTrackingSchoolStateKey = "schoolState"
         let kTrackingSchoolYearKey = "schoolYear"
         let kTrackingSeasonKey = "season"
         let kTrackingCareerNameKey = "careerName"
         let kTrackingTeamIdKey = "teamId"
         let kTrackingPlayerIdKey = "playerId"
         let kTrackingCareerIdKey = "careerId"
         let kTrackingArticleIdKey = "articleId"
         let kTrackingArticleTitleKey = "articleTitle"
         let kTrackingArticleTypeKey = "articleType"
         let kTrackingFiltersApplied = "filtersApplied"
         let kTrackingFtagKey = "ftag"
         */

    }
    
    // MARK: - Click Tracking
    
    class func trackEvent(featureName: String, cData: Dictionary<String,Any>)
    {
        // Skip if the featureName is empty
        if (featureName == "")
        {
            return
        }
        
        // Skip if the featureName doesn't exist in the shared trackingDictionary
        if (SharedData.trackingDictionary[featureName] == nil)
        {
            print("Tracking Key Missing")
            //let trackingDict = SharedData.trackingDictionary
            //print(trackingDict)
            return
        }
        
        // Load the basics
        var contextData = [:] as Dictionary<String,Any>
        
        var rsid = "cbsimaxprepsapp"
        
        if ((kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch) || (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev))
        {
            rsid = "cbsimaxprepsapp-dev"
        }
        
        contextData["siteCode"] = "maxpreps"
        contextData["sitePrimaryRsid"] = rsid
        contextData["siteEdition"] = "us"
        contextData["brandplatformid"] = "maxpreps_app_ios"
        contextData["MID"] = kUserDefaults.string(forKey: kAdobeMarketingCloudIdKey) //SharedData.adobeMID
        
        let shortVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let version = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        let appId = String(format: "MPScoreboard3 %@ (%@)", shortVersion, version)
        contextData["appID"] = appId
        
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        if (userId == kEmptyGuid)
        {
            contextData[kTrackingUserIdKey] = ""
            contextData[kTrackingUserStateKey] = "not authenticated"
            contextData[kTrackingUserTypeKey] = "anon"
        }
        else if (userId == kTestDriveUserId)
        {
            contextData[kTrackingUserIdKey] = userId
            contextData[kTrackingUserStateKey] = "not authenticated"
            contextData[kTrackingUserTypeKey] = "anon"
        }
        else
        {
            contextData[kTrackingUserIdKey] = userId
            contextData[kTrackingUserStateKey] = "authenticated"
            contextData[kTrackingUserTypeKey] = "registered"
        }
        
        // The siteHier and pageType are extracted from a shared dictionary that was created from the Tracking.csv file during app init. The key for this dictionary is the featureName property which is set from the caller. This is used to find which line to use in the csv file.
        
        let innerTrackingDictionary = SharedData.trackingDictionary[featureName] as! Dictionary<String,String>
        let siteHier = innerTrackingDictionary[kTrackingSiteHierKey]
        let pageType = innerTrackingDictionary[kTrackingPageTypeKey]

        contextData[kTrackingSiteHierKey] = siteHier
        contextData[kTrackingPageTypeKey] = pageType
        contextData[kTrackingPageNameKey] = featureName
        
        // Finally look for the various tracking keys in the cData to append to the contextDictionary
        let clickTrackingEvent = cData[kClickTrackingEventKey] as? String ?? ""
        let clickTrackingAction = cData[kClickTrackingActionKey] as? String ?? ""
        let clickTrackingModuleName = cData[kClickTrackingModuleNameKey] as? String ?? ""
        let clickTrackingModuleLocation = cData[kClickTrackingModuleLocationKey] as? String ?? ""
        let clickTrackingModuleAction = cData[kClickTrackingModuleActionKey] as? String ?? ""
        let clickTrackingClickText = cData[kClickTrackingClickTextKey] as? String ?? ""
        
        contextData[kClickTrackingEventKey] = clickTrackingEvent
        contextData[kClickTrackingActionKey] = clickTrackingAction
        contextData[kClickTrackingModuleNameKey] = clickTrackingModuleName
        contextData[kClickTrackingModuleLocationKey] = clickTrackingModuleLocation
        contextData[kClickTrackingModuleActionKey] = clickTrackingModuleAction
        contextData[kClickTrackingClickTextKey] = clickTrackingClickText
        
        // Fire off the tracking
        ADBMobile.trackAction(clickTrackingAction, data: contextData)
        
        print(featureName + " click tracking sent")
        
        /*
         let kClickTrackingEventKey = "event"
         let kClickTrackingActionKey = "action"
         let kClickTrackingModuleNameKey = "moduleName"
         let kClickTrackingModuleLocationKey = "moduleLocation"
         let kClickTrackingModuleActionKey = "moduleAction"
         let kClickTrackingClickTextKey = "clickText"
         */
    }
    
    // MARK: - Video Tracking Dictionary
    
    class func buildVideoContextData(featureName: String, videoId: String, videoTitle: String, videoDuration: Int, isMuted: Bool, isAutoPlay: Bool, cData: Dictionary<String,Any>, trackingGuid: String, ftag: String) -> Dictionary<String,Any>
    {
        // Load the basics
        var contextData = [:] as Dictionary<String,Any>
        
        contextData["brandplatformid"] = "maxpreps_app_ios"
        contextData["pageViewGuid"] = trackingGuid.lowercased()
        contextData["MID"] = kUserDefaults.string(forKey: kAdobeMarketingCloudIdKey) //SharedData.adobeMID
        
        let shortVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let version = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        let appId = String(format: "MPScoreboard3 %@ (%@)", shortVersion, version)
        contextData["appID"] = appId
        
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        if (userId == kEmptyGuid)
        {
            contextData[kTrackingUserIdKey] = ""
            contextData[kTrackingUserStateKey] = "not authenticated"
            contextData[kTrackingUserTypeKey] = "anon"
        }
        else if (userId == kTestDriveUserId)
        {
            contextData[kTrackingUserIdKey] = userId
            contextData[kTrackingUserStateKey] = "not authenticated"
            contextData[kTrackingUserTypeKey] = "anon"
        }
        else
        {
            contextData[kTrackingUserIdKey] = userId
            contextData[kTrackingUserStateKey] = "authenticated"
            contextData[kTrackingUserTypeKey] = "registered"
        }
        
        // Add the visitorId
        let orgUserId = kUserDefaults.value(forKey: kAdobeMarketingCloudIdKey) as! String
        contextData["visitorId"] = orgUserId
        
        // Add the video specific items
        if ((kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev) || (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch))
        {
            contextData["isDev"] = NSNumber(booleanLiteral: true)
        }
        else
        {
            contextData["isDev"] = NSNumber(booleanLiteral: false)
        }
        
        contextData["isDai"] = NSNumber(booleanLiteral: false)
        contextData["playerName"] = "Avia 15.5.0"
        contextData["closedCaptions"] = NSNumber(booleanLiteral: false)
        contextData["subtitleLanguage"] = "english"
        contextData["videoId"] = videoId
        contextData["name"] = videoTitle
        contextData["duration"] = NSNumber(integerLiteral: videoDuration)
        contextData["mediaMuted"] = NSNumber(booleanLiteral: isMuted)
        contextData["mediaAutoPlay"] = NSNumber(booleanLiteral: isAutoPlay)
        contextData["ftag"] = ftag
        
        // Added in V6.2.6
        contextData["streamType"] = "vod"
        
        // Added in V6.2.6
        let iosVersion = ProcessInfo().operatingSystemVersion
        contextData["osVersion"] = String(format: "%@.%@.%@", String(iosVersion.majorVersion), String(iosVersion.minorVersion), String(iosVersion.patchVersion))
        
        // Added in V6.2.6
        contextData["userAgent"] = SharedData.userAgent
        
        // Append the cData from the calling page if the cData isn't empty
        if (cData.keys.count > 0)
        {
            contextData = contextData.merge(dict: cData)
        }
        
        // Skip if the featureName is empty
        if (featureName == "")
        {
            print("Video Dictionary Built")
            return contextData
        }
        
        // Skip if the featureName doesn't exist in the shared trackingDictionary
        if (SharedData.trackingDictionary[featureName] == nil)
        {
            print("Tracking Key Missing")
            //let trackingDict = SharedData.trackingDictionary
            //print(trackingDict)
            print("Video Dictionary Built")
            return contextData
        }
                
        // The siteHier and pageType are extracted from a shared dictionary that was created from the Tracking.csv file during app init. The key for this dictionary is the featureName property which is set from the caller. This is used to find which line to use in the csv file.
        
        let innerTrackingDictionary = SharedData.trackingDictionary[featureName] as! Dictionary<String,String>
        let siteHier = innerTrackingDictionary[kTrackingSiteHierKey]
        let pageType = innerTrackingDictionary[kTrackingPageTypeKey]

        contextData[kTrackingSiteHierKey] = siteHier
        contextData[kTrackingPageTypeKey] = pageType
        contextData[kTrackingPageNameKey] = featureName
        
        // Add the siteSection and pageTitle (Addded in V6.2.6)
        let siteHierArray = siteHier?.components(separatedBy: "|")
        
        if (siteHierArray!.count > 3)
        {
            let h1 = siteHierArray![0]
            let h2 = siteHierArray![1]
            let h3 = siteHierArray![2]
            let h4 = siteHierArray![3]
            let siteSection = String(format: "%@|%@|||%@|%@", h1, h2, h3, h4)
            contextData["siteSection"] = siteSection
            
            let pageName = String(format: "%@/%@/%@", h1, h2, h3)
            contextData["pageName"] = pageName
        }
        print("Video Dictionary Built")
        
        return contextData

    }
    
    // MARK: - Notification Tracking
    
    class func trackNotification(_ notificationPacket: Dictionary<AnyHashable,Any>)
    {
        // Build the cData Dictionary
        var cData = [:] as Dictionary<String,String>
        var rsid = "cbsimaxprepsapp"
        
        if ((kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch) || (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev))
        {
            rsid = "cbsimaxprepsapp-dev"
        }
        
        cData["siteCode"] = "maxpreps"
        cData["sitePrimaryRsid"] = rsid
        cData["siteEdition"] = "us"
        cData["brandplatformid"] = "maxpreps_app_ios"
        cData["MID"] = kUserDefaults.string(forKey: kAdobeMarketingCloudIdKey)
        
        let shortVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let version = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        let appId = String(format: "MPScoreboard3 %@ (%@)", shortVersion, version)
        cData["appID"] = appId
        
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        if (userId == kEmptyGuid)
        {
            cData[kTrackingUserIdKey] = ""
            cData[kTrackingUserStateKey] = "not authenticated"
            cData[kTrackingUserTypeKey] = "anon"
        }
        else if (userId == kTestDriveUserId)
        {
            cData[kTrackingUserIdKey] = userId
            cData[kTrackingUserStateKey] = "not authenticated"
            cData[kTrackingUserTypeKey] = "anon"
        }
        else
        {
            cData[kTrackingUserIdKey] = userId
            cData[kTrackingUserStateKey] = "authenticated"
            cData[kTrackingUserTypeKey] = "registered"
        }
        
        // Set the siteType
        let careerId = notificationPacket["playerIds"] as? String ?? ""
        
        if (careerId.count > 1)
        {
            cData["siteType"] = "native_career"
        }
        else
        {
            cData["siteType"] = "webview"
        }

        // Use one a particular cData dictionary based upon the notification alertType
        /*
         Ranking
         Stats
         Photogallery
         Video
         Article
         Contest
         Headline
         CoachNote
         TeamsAppActivity
         Academics
         Measurements
         Unknown
         */
        let itemType = notificationPacket["itemType"] as? String ?? ""

        switch itemType.lowercased()
        {
        case "ranking":
            cData["screenName"] = "latest|latest-home|notification-rankings|notification"
        case "stats":
            cData["screenName"] = "latest|latest-home|notification-stats|notification"
        case "photogallery":
            cData["screenName"] = "latest|latest-home|notification-photogallery|notification"
        case "video":
            cData["screenName"] = "latest|latest-home|notification-video|notification"
        case "article":
            cData["screenName"] = "latest|latest-home|notification-article|notification"
        case "contest":
            cData["screenName"] = "latest|latest-home|notification-contest|notification"
        case "academics":
            cData["screenName"] = "following|career-profile|notification-academics|notification"
        case "measurements":
            cData["screenName"] = "following|career-profile|notification-measurements|notification"
        default:
            cData["screenName"] = "latest|latest-home|notification-other|notification"
        }
        
        // Extract the screen name from the cData
        let screenName = cData["screenName"]!
        
        // Split the screen name into seperate components
        var project = ""
        var channel = ""
        var feature = ""
        var subFeature = ""
        
        let screenNameArray = screenName.components(separatedBy: "|")
        if (screenNameArray.count == 4)
        {
            project = screenNameArray[0]
            channel = screenNameArray[1]
            feature = screenNameArray[2]
            subFeature = screenNameArray[3]
        }
        
        cData["project"] = project
        cData["channel"] = channel
        cData["feature"] = feature
        cData["subFeature"] = subFeature
        cData["pageType"] = channel

        // Build the site section and site heir (siteHeir = screenName)
        let siteHeir = String(format: "%@|%@|%@|%@", project, channel, feature, subFeature)
        let siteSection = String(format: "%@|%@|||%@|%@", project, channel, feature, subFeature)
        
        cData["siteHeir"] = siteHeir
        cData["siteSection"] = siteSection
        
        
        // Check to see if the property exists, else force to an empty string
        let notificationId = notificationPacket["_"] as? String ?? ""
        let action = notificationPacket["action"] as? String ?? ""
        let type = notificationPacket["type"] as? String ?? ""
        var schoolIds = notificationPacket["schoolIds"] as? String ?? ""
        let subType = notificationPacket["subType"] as? String ?? ""
        let sender = notificationPacket["sender"] as? String ?? ""
        let gender = notificationPacket["gender"] as? String ?? ""
        let sport = notificationPacket["sport"] as? String ?? ""
        let level = notificationPacket["level"] as? String ?? ""
        let season = notificationPacket["season"] as? String ?? ""
        let apsDict = notificationPacket["aps"] as? Dictionary<String,Any> ?? [:]
        
        var title = ""
        if (apsDict["alert"] != nil)
        {
            let rawTitle = apsDict["alert"] as? String ?? ""
            title = rawTitle.replacingOccurrences(of: "\n", with: "")
        }
        
        // Add the items above to the cData dictionary
        cData["alertCategory"] = itemType
        cData["alertAction"] = action
        cData["alertText"] = title
        cData["alertId"] = notificationId
        cData["alertType"] = type
        cData["alertSubType"] = subType
        cData["alertSender"] = sender
        cData["alertGender"] = gender
        cData["alertSport"] = sport
        cData["alertLevel"] = level
        cData["alertSeason"] = season
        cData["alertPlayer"] = careerId
        
        // Lastly, replace the schoolIds string if the notification is a Contest
        if (itemType.lowercased() == "contest")
        {
            // orAudience = "team_05174087-fd6c-473c-a19f-079f950530be_boys_basketball_varsity_winter_ts"
            // Temporary fix for the schoolIds missing the second school on Contest notifications
            
            // Extract the schoolIds from the "orAudience"
            let orAudience = notificationPacket["orAudience"] as? String ?? ""
            let orAudienceArray = orAudience.components(separatedBy: ",")
            
            if (orAudienceArray.count > 1)
            {
                let audienceOne = orAudienceArray[0]
                let audienceTwo = orAudienceArray[1]
                let audienceOneArray = audienceOne.components(separatedBy: "_")
                let audienceTwoArray = audienceTwo.components(separatedBy: "_")
                
                if ((audienceOneArray.count > 1) && (audienceTwoArray.count > 1))
                {
                    let schoolIdOne = audienceOneArray[1]
                    let schoolIdTwo = audienceTwoArray[1]
                    
                    schoolIds = String(format: "%@,%@", schoolIdOne, schoolIdTwo)
                }
            }
        }
        
        cData["alertSchools"] = schoolIds
        
        // Fire off the tracking
        ADBMobile.trackState(screenName, data: cData)
        
        /*
        {
            "_" = "c0bc93b4-cfce-494f-8157-448139b75562";
            action = Team;
            "action-details" = "{\"duration\":100,\"resource\":\"NowWebBrowser\",\"canRotate\":true,\"apps\":\"MaxPrepsApp\"}";
            aps =     {
                alert = "Varsity Basketball \nFinal: MaxPreps 80, MaxPreps B 60";
                badge = 5;
                sound = "Note.wav";
            };
            assetId = "d9961e52-5756-48c8-b464-830f355b0678";
            "com.urbanairship.metadata" = "eyJ2ZXJzaW9uX2lkIjoxLCJ0aW1lIjoxNTgxMzU5ODA4MzE2LCJwdXNoX2lkIjoiN2RjMDJiZTUtYmFmYy00OTkyLWI3OGQtMjlhZjE2NDBiNjNlIiwicmV0YXJnZXRpbmciOmZhbHNlfQ==";
            gender = Boys;
            itemType = Contest;
            level = Varsity;
            optionalInfo = "#";
            orAudience = "team_de0050ae-cf37-4ae6-b63d-301c97bd92d8_boys_basketball_varsity_winter_fs,team_5a9bf7f3-15c1-45e5-beda-6aee1c8fd9f7_boys_basketball_varsity_winter_fs";
            photoUrl = "#";
            schoolIds = "de0050ae-cf37-4ae6-b63d-301c97bd92d8";
            season = Winter;
            sender = "iris-automated";
            sport = Basketball;
            ssId = "dda64431-2648-4256-9dd3-2e626fa044dd";
            subType = FinalScore;
            thumbnailUrl = "#";
            type = FS;
            url = "www.maxpreps.com/m/contest/default.aspx?contestid=d9961e52-5756-48c8-b464-830f355b0678&ssid=dda64431-2648-4256-9dd3-2e626fa044dd";
        }
        */
        
    }
}
