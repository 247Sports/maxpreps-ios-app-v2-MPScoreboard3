//
//  Team.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/11/21.
//

import Foundation

struct Team
{
    var teamId: Int
    var allSeasonId: String
    //var genderSport: String
    var gender: String
    var sport: String
    var teamColor: String
    var mascotUrl: String
    var schoolName: String
    var teamLevel: String
    var schoolId: String
    var schoolState: String
    var schoolCity: String
    var schoolFullName: String
    var season: String
    var notifications: Array<Any>
    
    // New favorite schema
    /*
     let kNewSchoolMascotKey = "schoolMascot"                        // String
     let kNewSportKey = "sport"                                       // String
     let kNewSchoolIdKey = "schoolId"                                 // String
     let kNewUserfavoriteTeamIdKey = "userFavoriteTeamId"             // Double
     let kNewSchoolCityKey = "schoolCity"                             // String
     let kNewAllSeasonIdKey = "allSeasonId"                           // String
     let kNewLevelKey = "level"                                       // String
     let kNewSeasonKey = "season"                                     // String
     let kNewSchoolMascotUrlKey = "schoolMascotUrl"                   // String
     let kNewSchoolNameKey = "schoolName"                             // String
     let kNewSchoolFormattedNameKey = "schoolFormattedName"           // String
     let kNewGenderKey = "gender"                                     // String
     let kNewSchoolStateKey = "schoolState"                           // String
     let kNewNotificationSettingsKey = "notificationSettings"         // Array
     */
    
    // Old Favorite feed schema
    /*
     - key : "favoriteTeamId"
     - key : "GenderSport"
     - key : "SchoolName"
     - key : "TeamLevel"
     - key : "SchoolId"
     - key : "SchoolState"
     - key : "SchoolFullName"
     - key : "Season"
     - key : "Notifications"
          [
           - key : ShortName
           - key : Name
           - key : Enabled
           - key : SortOrder
          ]
     */
}
