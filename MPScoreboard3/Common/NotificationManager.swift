//
//  NotificationManager.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/11/22.
//

import Foundation
import AirshipCore

class NotificationManager: NSObject
{
    class func loadAirshipNotifications()
    {
        let userId = (kUserDefaults.string(forKey: kUserIdKey))
        let masterNotificationsEnabled = (kUserDefaults.value(forKey: kNotificationMasterEnableKey)) as! Bool
                      
        var channelsArray = [] as Array<String>
        
        if ((userId != kEmptyGuid) && (userId != kTestDriveUserId) && (masterNotificationsEnabled == true))
        {
            // Set the named user
            Airship.contact.identify(userId!)
            
            // Add the userId as a channel
            let userString = String(format: "user_%@", userId!.lowercased())
            channelsArray.append(userString)
            
            // Iterate through the favorite teams to build the channels
            let favoriteTeams = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
            
            for item in favoriteTeams!
            {
                let favorite = item as! Dictionary<String,Any>
                let schoolId = favorite[kNewSchoolIdKey] as! String
                let gender = favorite[kNewGenderKey] as! String
                let sport = favorite[kNewSportKey] as! String
                let teamLevel = favorite[kNewLevelKey] as! String
                let season = favorite[kNewSeasonKey] as! String
                
                let notifications = favorite[kNewNotificationSettingsKey] as! Array<Dictionary<String,Any>>
                
                for notification in notifications
                {
                    let pushEnabled = notification[kNewNotificationIsEnabledForAppKey] as! Bool
                    
                    if (pushEnabled == true)
                    {
                        let shortName = notification[kNewNotificationShortNameKey] as! String
                        
                        let favoriteString = String(format: "team_%@_%@_%@_%@_%@_%@", schoolId.lowercased(), gender.lowercased(), sport.lowercased(), teamLevel.lowercased(), season.lowercased(), shortName.lowercased())
                        
                        channelsArray.append(favoriteString)
                    }
                }
            }
            
            // Add the favorite athletes
            let favoriteAthletes = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
            
            for item in favoriteAthletes!
            {
                let favorite = item as! Dictionary<String,Any>
                let careerId = favorite[kCareerProfileIdKey] as! String
                
                let notifications = favorite[kCareerProfileNotificationSettingsKey] as! Array<Dictionary<String,Any>>
                
                for notification in notifications
                {
                    let pushEnabled = notification[kNewNotificationIsEnabledForAppKey] as! Bool
                    
                    if (pushEnabled == true)
                    {
                        channelsArray.append(String(format: "career_%@_all", careerId))
                    }
                }
            }
            
            
            // Cleanup expired contest notifications from prefs (24 hours old)
            let originalNotificationDict = kUserDefaults.dictionary(forKey: kContestNotificationsDictionaryKey)
            var newNotificationDict: Dictionary<String,Any> = [:]
            let allKeys = originalNotificationDict!.keys
            
            for contestId in allKeys
            {
                let notification = originalNotificationDict![contestId] as! Dictionary<String,Any>
                let contestStartDate = notification[kContestNotificationDateKey] as! Date
                let datePlusTwentyFourHours = contestStartDate.addingTimeInterval(24.0 * 60.0 * 60.0)
                if (datePlusTwentyFourHours > Date())
                {
                    newNotificationDict.updateValue(notification, forKey: contestId)
                }
            }
            
            // Update prefs
            kUserDefaults.set(newNotificationDict, forKey: kContestNotificationsDictionaryKey)
            
            // Add the remaining contest notifications
            let newKeys = newNotificationDict.keys
            
            for newContestId in newKeys
            {
                let notification = newNotificationDict[newContestId] as! Dictionary<String,Any>
                let settingsArray = notification[kContestNotificationSettingsKey] as! Array<Dictionary<String,Any>>
                
                for setting in settingsArray
                {
                    let pushEnabled = setting[kNewNotificationIsEnabledForAppKey] as! Bool
                    
                    if (pushEnabled == true)
                    {
                        let shortName = setting[kNewNotificationShortNameKey] as! String
                        channelsArray.append(String(format: "contest_%@_%@", newContestId, shortName.lowercased()))
                    }
                }
            }
        }
        
        Airship.channel.tags = channelsArray
        //Airship.push.notificationOptions = [.alert, .sound] // Doesn't work
        Airship.push.updateRegistration()
    }
    
    class func clearAirshipNotifications()
    {
        Airship.contact.reset()
        Airship.channel.tags = []
        //Airship.push.notificationOptions = [.alert, .sound] // Doesn't work
        Airship.push.updateRegistration()
    }
}
