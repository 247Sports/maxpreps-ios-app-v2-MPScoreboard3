//
//  Constants.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/2/21.
//

import Foundation
import UIKit

/*
 Schedule Feed Enumerations
 public enum HomeAwayTypes : byte
     {
         Home = 0,
         Away = 1,
         Neutral = 2
     }
 public enum ContestTypes : byte
     {
         Conference = 0,
         NonConference = 1,
         Tournament = 2,
         Exhibition = 3,
         Playoff = 4,
         ConferenceTournament = 5
     }

public enum DateCodes : byte
     {
         Default = 0,
         DateTBA = 1,
         TimeTBA = 2,
         DateTimeTBA = 4
     }
 */

// MARK: - Enumerations
enum DeviceType
{
    case ipad
    case iphone
}

enum AspectRatio
{
    case low
    case medium
    case high
}

enum FavoriteDetailCellMode
{
    case allCells
    case allCellsOneContest
    case noArticlesAllContests
    case noArticlesOneContest
    case noContests
    case noContestsOrArticles
}

enum TimelineItemType: Int
{
    case unknown = 0, article, photos, videos, statsUpdated, rosterAdded, pogAward, poyAward, analystAward
}

enum SkeletonImageType: Int
{
    case latest = 0, rankings, scoreboards, scores, stats
}

// MARK: - Shared Data
struct SharedData
{
    static var deviceType: Any = DeviceType.ipad
    static var deviceAspectRatio: Any = AspectRatio.low
    static var allSchools = Array<School>()
    static var topNotchHeight = 0
    static var bottomSafeAreaHeight = 0
    static var utcTimeOffset : TimeInterval = 0
    static var statsHorizontalScrollValue = 0
    static var deviceToken = ""
    static var coldLaunch = true
    static var trackingDictionary : Dictionary<String,Any> = [:]
    static var newsTabBaseGuid = ""
    static var followingTabBaseGuid = ""
    static var scoresTabBaseGuid = ""
    //static var adobeMID = ""
    static var ncsaExtraAthleteDictionary : Dictionary<String,Any> = [:]
    static var userAgent = ""
    static var verticalVideoPlayCount = 0
}

// MARK: - Gender Sport List
let kSearchGenderSportsArray = ["Boys Baseball","Boys Basketball","Boys Cross Country","Boys Flag Football","Boys Football","Boys Golf","Boys Ice Hockey","Boys Lacrosse","Boys Soccer","Boys Swimming","Boys Tennis","Boys Track & Field","Boys Volleyball","Boys Water Polo","Boys Wrestling","Girls Basketball","Girls Cross Country","Girls Field Hockey","Girls Flag Football","Girls Golf","Girls Ice Hockey","Girls Lacrosse","Girls Soccer","Girls Softball","Girls Swimming","Girls Tennis","Girls Track & Field","Girls Volleyball","Girls Water Polo","Girls Wrestling"]

let kSearchBoysSportsArray = ["Baseball","Basketball","Cross Country","Flag Football","Football","Golf","Ice Hockey","Lacrosse","Soccer","Swimming","Tennis","Track & Field","Volleyball","Water Polo","Wrestling"]

let kSearchGirlsSportsArray = ["Basketball","Cross Country","Field Hockey","Flag Football","Golf","Ice Hockey","Lacrosse","Soccer","Softball","Swimming","Tennis","Track & Field","Volleyball","Water Polo","Wrestling"]

// Reduced Sports Array removes cross country, golf, track & field, swimming, tennis, and wrestling
let kSearchReducedBoysSportsArray = ["Baseball","Basketball","Flag Football","Football","Ice Hockey","Lacrosse","Soccer","Volleyball","Water Polo"]

let kSearchReducedGirlsSportsArray = ["Basketball","Field Hockey","Flag Football","Ice Hockey","Lacrosse","Soccer","Softball","Volleyball","Water Polo"]

let kLatestTabReducedSportsArray = ["Baseball","Basketball","Flag Football","Football","Ice Hockey","Lacrosse","Soccer","Volleyball","Water Polo","Field Hockey","Softball"]

let kAllSportsArray = ["Bass Fishing","Cheer","Dance Team","Drill","Poms","Weight Lifting","Wheelchair Sports","Cross Country","Gymnastics","Indoor Track & Field","Judo","Ski & Snowboard","Swimming","Track & Field","Wrestling","Archery","Badminton","Baseball","Basketball","Bowling","Canoe Paddling","Fencing","Field Hockey","Flag Football","Football","Ice Hockey","Lacrosse","Riflery","Rugby","Slow Pitch Softball","Soccer","Softball","Water Polo","Golf","Beach Volleyball","Tennis","Volleyball","Speech"]

// NCSA Sport List
let kNCSAGenderSportsArray = ["Boys Baseball", "Boys Basketball", "Boys Diving", "Boys Football", "Boys Golf", "Boys Ice Hockey", "Boys Lacrosse", "Boys Rowing", "Boys Soccer", "Boys Swimming", "Boys Tennis", "Boys Track & Field", "Boys Volleyball", "Boys Water Polo", "Boys Wrestling", "Girls Basketball", "Girls Diving", "Girls Field Hockey", "Girls Golf", "Girls Ice Hockey", "Girls Lacrosse", "Girls Rowing", "Girls Soccer", "Girls Softball", "Girls Swimming", "Girls Tennis", "Girls Track & Field", "Girls Volleyball", "Girls Water Polo"]

let kNCSASportsArray = ["Baseball", "Basketball", "Diving", "Football", "Golf", "IceHockey", "Lacrosse", "Rowing", "Soccer", "Swimming", "Tennis", "TrackField", "Volleyball", "WaterPolo", "Wrestling", "Basketball", "Diving", "FieldHockey", "Golf", "IceHockey", "Lacrosse", "Rowing", "Soccer", "Softball", "Swimming", "Tennis", "TrackField", "Volleyball", "WaterPolo"]

let kNCSAGenderArray = ["Boys", "Boys", "Boys", "Boys", "Boys", "Boys", "Boys", "Boys", "Boys", "Boys", "Boys", "Boys", "Boys", "Boys", "Boys", "Girls", "Girls", "Girls", "Girls", "Girls", "Girls", "Girls", "Girls", "Girls", "Girls", "Girls", "Girls", "Girls", "Girls"]

/*
             NcsaCodesByGenderSport.Add("boys,baseball", 17706);
             NcsaCodesByGenderSport.Add("boys,football", 17633);
             NcsaCodesByGenderSport.Add("boys,basketball", 17638);
             NcsaCodesByGenderSport.Add("boys,diving", 17652);
             NcsaCodesByGenderSport.Add("boys,golf", 17659);
             NcsaCodesByGenderSport.Add("boys,icehockey", 17665);
             NcsaCodesByGenderSport.Add("boys,lacrosse", 17707);
             NcsaCodesByGenderSport.Add("boys,rowing", 17644);
             NcsaCodesByGenderSport.Add("boys,soccer", 17683);
             NcsaCodesByGenderSport.Add("boys,swimming", 17687);
             NcsaCodesByGenderSport.Add("boys,tennis", 17689);
             NcsaCodesByGenderSport.Add("boys,trackfield", 17691);
             NcsaCodesByGenderSport.Add("boys,volleyball", 17695);
             NcsaCodesByGenderSport.Add("boys,waterpolo", 17701);
             NcsaCodesByGenderSport.Add("boys,wrestling", 17635);
             NcsaCodesByGenderSport.Add("girls,fieldhockey", 17711);
             NcsaCodesByGenderSport.Add("girls,softball", 17634);
             NcsaCodesByGenderSport.Add("girls,basketball", 17639);
             NcsaCodesByGenderSport.Add("girls,diving", 17653);
             NcsaCodesByGenderSport.Add("girls,golf", 17660);
             NcsaCodesByGenderSport.Add("girls,icehockey", 17666);
             NcsaCodesByGenderSport.Add("girls,lacrosse", 17708);
             NcsaCodesByGenderSport.Add("girls,rowing", 17645);
             NcsaCodesByGenderSport.Add("girls,soccer", 17684);
             NcsaCodesByGenderSport.Add("girls,swimming", 17688);
             NcsaCodesByGenderSport.Add("girls,tennis", 17690);
             NcsaCodesByGenderSport.Add("girls,trackfield", 17692);
             NcsaCodesByGenderSport.Add("girls,volleyball", 17696);
             NcsaCodesByGenderSport.Add("girls,waterpolo", 17702);
 */


// MARK: - State Name List
let kStateShortNamesArray = ["AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT", "VA","WA","WV","WI","WY"]

let kStateNamesArray = ["Alabama",
"Alaska",
"Arizona",
"Arkansas",
"California",
"Colorado",
"Connecticut",
"Delaware",
"District of Columbia",
"Florida",
"Georgia",
"Hawaii",
"Idaho",
"Illinois",
"Indiana",
"Iowa",
"Kansas",
"Kentucky",
"Louisiana",
"Maine",
"Maryland",
"Massachusetts",
"Michigan",
"Minnesota",
"Mississippi",
"Missouri",
"Montana",
"Nebraska",
"Nevada",
"New Hampshire",
"New Jersey",
"New Mexico",
"New York",
"North Carolina",
"North Dakota",
"Ohio",
"Oklahoma",
"Oregon",
"Pennsylvania",
"Rhode Island",
"South Carolina",
"South Dakota",
"Tennessee",
"Texas",
"Utah",
"Vermont",
"Virginia",
"Washington",
"West Virginia",
"Wisconsin",
"Wyoming"]

let kShortStateLookupDictionary = ["Alabama": "AL",
        "Alaska": "AK",
        "Arizona": "AZ",
        "Arkansas": "AR",
        "California": "CA",
        "Colorado": "CO",
        "Connecticut": "CT",
        "Delaware": "DE",
        "District of Columbia": "DC",
        "Florida": "FL",
        "Georgia": "GA",
        "Hawaii": "HI",
        "Idaho": "ID",
        "Illinois": "IL",
        "Indiana": "IN",
        "Iowa": "IA",
        "Kansas": "KS",
        "Kentucky": "KY",
        "Louisiana": "LA",
        "Maine": "ME",
        "Maryland": "MD",
        "Massachusetts": "MA",
        "Michigan": "MI",
        "Minnesota": "MN",
        "Mississippi": "MS",
        "Missouri": "MO",
        "Montana": "MT",
        "Nebraska": "NE",
        "Nevada": "NV",
        "New Hampshire": "NH",
        "New Jersey": "NJ",
        "New Mexico": "NM",
        "New York": "NY",
        "North Carolina": "NC",
        "North Dakota": "ND",
        "Ohio": "OH",
        "Oklahoma": "OK",
        "Oregon": "OR",
        "Pennsylvania": "PA",
        "Rhode Island": "RI",
        "South Carolina": "SC",
        "South Dakota": "SD",
        "Tennessee": "TN",
        "Texas": "TX",
        "Utah": "UT",
        "Vermont": "VT",
        "Virginia": "VA",
        "Washington": "WA",
        "West Virginia": "WV",
        "Wisconsin": "WI",
        "Wyoming": "WY"]

// MARK: - General Constants
let kDeviceWidth = UIScreen.main.bounds.size.width
let kDeviceHeight = UIScreen.main.bounds.size.height
//let kAppKeyWindow = UIApplication.shared.keyWindow!
let kAppKeyWindow = UIApplication.shared.windows.first(where: \.isKeyWindow)!
let kUserDefaults = UserDefaults.standard
let kStatusBarHeight = 20
let kNavBarHeight = 44
let kTabBarHeight = 49
let kNavBarFontSize = CGFloat(19)
let kAppIdentifierQueryParam = "brandplatformid=maxpreps_app_ios&apptype=scores&appplatform=ios"
let kUserImageFastlyParam = "&auto=webp&format=pjpg&fit=cover&width=128&crop=1:1,smart"
let kMaxPrepsScheduleDateFormat = "yyyy-MM-dd'T'HH:mm:ss"

let kEmptyGuid = "00000000-0000-0000-0000-000000000000"
let kStandardAdminUserId = "01"
let kAffiliateAdminUserId = "02"
let kStateAssociationAdminUserId = "03"
let kPhotographerUserId = "04"
let kWriterUserId = "05"
let kStatSupplierUserId = "06"
let kTournamentDirectorUserId = "07"
let kMeetManagerUserId = "08"
let kCareerAdminAthleteUserId = "09"
let kCareerAdminParentUserId = "10"

let kTestDriveUserId = "01234567-89AB-CDEF-FEDC-BA9876543210"
let kRosterImageTempFileName = "111.jpg"
let kAthleteImageTempFileName = "222.jpg"
let kStaffImageTempFileName = "333.jpg"

let kCoachAllAccessPermissionId = "20B19769-89E9-45D3-947D-95FCFE3AD4DC".lowercased()
let kCoachDataPermissionId = "B1B50AC7-56C2-4CEE-B177-E6EAE284817F".lowercased()
let kCoachCommunicationPermissionId = "A80C8E18-F4E0-46C8-A509-6D47489D512D".lowercased()

let kDaveEmail = "dsmith4021@comcast.net"
let kDavePassword = "loriann"
let kDave120Email = "dave120@maxpreps.com"
let kDave120Password = "123456"
let kDave122Email = "dave122@maxpreps.com"
let kDave122Password = "123456"
let kAppleUserEmail = "apple@maxpreps.com"

let kUserProfileBioTextViewDefaultText = "Add your info here..."
let kCareerProfileBioTextViewDefaultText = "Tell us about yourself..."
let kShareMessageText = "Here is something from MaxPreps I thought you would like: "
let kUploadPhotoMessage = "Only upload an image that you own or have the rights to publish. We will deny any images that are watermarked, heavily filtered, or display any cartoon or design other than the image itself."
let kUploadTeamPhotoMessage = "For best results, rotate your phone when using the camera or choose landscape photos from you library.\nOnly upload an image that you own or have the rights to publish. We will deny any images that are watermarked, heavily filtered, or display any cartoon or design other than the image itself."

// MARK: - Server Mode Keys
let kServerModeKey = "ServerMode"
let kServerModeProduction = "Production"
let kServerModeStaging = "Staging"
let kServerModeDev = "Dev"
let kServerModeBranch = "Branch"
let kBranchValue = "BranchValue"

// MARK: - Other Prefs
let kDebugDialogsKey = "DebugDialogs"
let kNotificationMasterEnableKey = "NotificationMasterEnable2"
let kVideoAutoplayModeKey = "VideoAutoplayMode2"
//let kVideoPipEnableKey = "VideoPipEnable"
let kAudioMixEnableKey = "AudioMixEnable"
let kOneTrustShownKey = "OTPreferenceCenterShownOnce"     // Bool
let kVerticalVideoBumpCountKey = "VerticalVideoBumpCount" // Int

// MARK: - Tool Tip Keys
let kAppLaunchCountKey = "AppLaunchCount"
let kToolTipOneShownKey = "ToolTipOneShown"
let kToolTipTwoShownKey = "ToolTipTwoShown"
let kToolTipThreeShownKey = "ToolTipThreeShown"
let kToolTipFourShownKey = "ToolTipFourShown"
let kToolTipFiveShownKey = "ToolTipFiveShown"
let kToolTipSixShownKey = "ToolTipSixShown"
let kToolTipSevenShownKey = "ToolTipSevenShown"
let kToolTipEightShownKey = "ToolTipEightShown"
let kToolTipNineShownKey = "ToolTipNineShown"
let kVideoUploadToolTipShownKey = "VideoUploadToolTipShown"
let kTeamVideoToolTipShownKey = "TeamVideoToolTipShown"
let kCareerVideoToolTipShownKey = "CareerVideoToolTipShown"

// MARK: - Page Tracking Keys
let kTrackingPageTypeKey = "pageType"
let kTrackingSiteHierKey = "siteHier"
let kTrackingPageNameKey = "pageName"
let kTrackingUserStateKey = "userState"
let kTrackingUserTypeKey = "userType"
let kTrackingUserIdKey = "userId"
let kTrackingUserTeamRoleKey = "userTeamRole"
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
let kTrackingCareerIdKey = "careerId"   // Added in V6.3.2. Value is the same as playerId
let kTrackingArticleIdKey = "articleId"
let kTrackingArticleTitleKey = "articleTitle"
let kTrackingArticleTypeKey = "articleType"
let kTrackingFiltersAppliedKey = "filtersApplied"
let kTrackingClickTextKey = "clickText"
let kTrackingFtagKey = "ftag"
let kEmptyTrackingContextData = [:] as Dictionary<String,Any>

// MARK: - Click Tracking Keys
let kClickTrackingEventKey = "event"
let kClickTrackingActionKey = "action"
let kClickTrackingModuleNameKey = "moduleName"
let kClickTrackingModuleLocationKey = "moduleLocation"
let kClickTrackingModuleActionKey = "moduleAction"
let kClickTrackingClickTextKey = "clickText"

/*
// MARK: - Video Tracking Keys
let kVideoTrackingVideoIdKey = "videoId"
let kVideoTrackingNameKey = "name"
let kVideoTrackingMediaDurationKey = "duration"
let kVideoTrackingMediaMutedKey = "mediaMuted"
let kVideoTrackingMediaAutoPlayKey = "mediaAutoPlay"
let kVideoTrackingFtagKey = "ftag"
*/

// MARK: - User Info
let kUserEmailKey = "Email"                            // String
let kUserPasswordKey = "Password"                      // String
let kUserIdKey = "UserId"                              // String
let kUserFirstNameKey = "FirstName"                    // String
let kUserLastNameKey = "LastName"                      // String
let kUserZipKey = "Zip"                                // String
let kUserTypeKey = "Type"                              // String
let kUserBirthdateKey = "Birthdate"                    // String
let kUserGenderKey = "Gender"                          // String
let kLatitudeKey = "Latitude"                          // String
let kLongitudeKey = "Longitude"                        // String
let kCurrentLocationKey = "CurrentLocation"            // Dictionary
let kUserPhotoUrlKey = "UserPhotoUrl"                  // String
let kUserCareerPhotoUrlKey = "UserCareerPhotoUrl"      // String

// MARK: - Admin Roles
let kUserAdminRolesDictionaryKey = "UserAdminRolesDictionary"    // Dictionary (saved to prefs)
let kUserAdminRolesArrayKey = "UserAdminRolesArray"    // Array (saved to prefs)
let kRoleNameKey = "RoleName"
let kRoleTitleKey = "RoleTitle"
let kRoleSchoolIdKey = "SchoolId"
let kRoleSSIDKey = "SSID"
let kRollAllSeasonIdKey = "AccessId2"
let kRoleSchoolNameKey = "SchoolName"
let kRoleSportKey = "Sport"
let kRoleGenderKey = "Gender"
let kRoleTeamLevelKey = "TeamLevel"
let kRoleCareerIdKey = "AccessId1"
let kRolePermissionsKey = "Permissions"

// MARK: - User Favorite Teams, Athletes, and School Info Keys

let kSelectedFavoriteIndexKey = "SelectedFavoriteIndex"          // Int
let kSelectedFavoriteSectionKey = "SelectedFavoriteSection"      // Int (0=Teams, 1=Athletes)
let kMaxFavoriteTeamsCount = 16
let kMaxFavoriteAthletesCount = 16

// User Favorite Team Keys
let kNewUserFavoriteTeamsArrayKey = "NewUserFavoriteTeamsArray"  // Array
let kNewSchoolMascotKey = "schoolMascot"                         // String
let kNewSportKey = "sport"                                       // String
let kNewSchoolIdKey = "schoolId"                                 // String
let kNewUserfavoriteTeamIdKey = "userFavoriteTeamId"             // Int
let kNewSchoolCityKey = "schoolCity"                             // String
let kNewAllSeasonIdKey = "allSeasonId"                           // String
let kNewLevelKey = "level"                                       // String
let kNewSeasonKey = "season"                                     // String
let kNewSchoolMascotUrlKey = "schoolMascotUrl"                   // String
let kNewSchoolColor1Key = "schoolColor1"                         // String
let kNewSchoolNameKey = "schoolName"                             // String
let kNewSchoolFormattedNameKey = "schoolFormattedName"           // String
let kNewGenderKey = "gender"                                     // String
let kNewSchoolStateKey = "schoolState"                           // String
let kNewNotificationSettingsKey = "notificationSettings"         // Array
let kNewNotificationSortOrderKey = "sortOrder"                   // Int
let kNewNotificationNameKey = "name"                             // String
let kNewNotificationShortNameKey = "shortName"                   // String
let kNewNotificationIsEnabledForAppKey = "isEnabledForApp"       // Bool
let kNewNotificationIsEnabledForEmailKey = "isEnabledForEmail"   // Bool
//let kNewNotificationIsEnabledForSmsKey = "isEnabledForSms"       // Bool
//let kNewNotificationIsEnabledForWebKey = "isEnabledForWeb"       // Bool
let kNewNotificationUserFavoriteTeamNotificationSettingIdKey = "userFavoriteTeamNotificationSettingId"  // String
let kNewNotificationUserFavoriteTeamIdKey = "userFavoriteTeamId" // String

// User Favorite Athletes Keys
let kUserFavoriteAthletesArrayKey = "UserFavoriteAthletesArray"         // Array
let kCareerProfileFirstNameKey = "careerProfileFirstName"               // String
let kCareerProfileLastNameKey = "careerProfileLastName"                 // String
let kCareerProfileSchoolNameKey = "schoolName"                          // String
let kCareerProfileSchoolIdKey = "schoolId"                              // String
let kCareerProfileSchoolColor1Key = "schoolColor1"                      // String
let kCareerProfileSchoolMascotUrlKey = "schoolMascotUrl"                // String
let kCareerProfileSchoolCityKey = "schoolCity"                          // String
let kCareerProfileSchoolStateKey = "schoolState"                        // String
let kCareerProfileIdKey = "careerProfileId"                             // String
let kCareerProfilePhotoUrlKey = "photoUrl"                              // String
let kCareerProfileNotificationSettingsKey = "notificationSettings"      // Array

// User Scoreboard Keys
let kScoreboardDefaultNameKey = "scoreboardDefaultName"                 // String
let kScoreboardAliasNameKey = "scoreboardAliasName"                     // String
let kScoreboardGenderKey = "scoreboardGender"                           // String
let kScoreboardSportKey = "scoreboardSport"                             // String
let kScoreboardStateNameKey = "scoreboardStateName"                     // String
let kScoreboardStateCodeKey = "scoreboardStateCode"                     // String
let kScoreboardEntityNameKey = "scoreboardEntityName"                   // String
let kScoreboardEntityIdKey = "scoreboardEntityId"                       // String
let kScoreboardDivisionTypeKey = "scoreboardDivisionType"               // String
let kScoreboardSectionNameKey = "scoreboardSectionName"                 // String
let kUserScoreboardsArrayKey = "userScoreboardsArray"                   // Array
let kFootballScoreboardInstalledKey = "footballScoreboardInstalled"     // Bool
let kBasketballScoreboardInstalledKey = "basketballScoreboardInstalled" // Bool
let kBaseballScoreboardInstalledKey = "baseballScoreboardInstalled"     // Bool

// Contest Notification Key
let kContestNotificationsDictionaryKey = "contestNotificationsDictionary"  // Dictionary
let kContestNotificationSettingsKey = "contestNotificationSettings"     // Array
let kContestNotificationDateKey = "contestNotificationDate"             // Date

// Contest Notification Types
let kFootballContestNotifications = [[kNewNotificationNameKey:"Final Score", kNewNotificationShortNameKey:"FS", kNewNotificationIsEnabledForAppKey: false], [kNewNotificationNameKey:"Qtr. Scores & Overtime", kNewNotificationShortNameKey:"PS", kNewNotificationIsEnabledForAppKey: false], [kNewNotificationNameKey:"All Scoring Updates", kNewNotificationShortNameKey:"SC", kNewNotificationIsEnabledForAppKey: false], [kNewNotificationNameKey:"Game Reporter Status", kNewNotificationShortNameKey:"LSI", kNewNotificationIsEnabledForAppKey: false], [kNewNotificationNameKey:"Game Start", kNewNotificationShortNameKey:"GS", kNewNotificationIsEnabledForAppKey: false], [kNewNotificationNameKey:"Red Zone/Big Play Alert", kNewNotificationShortNameKey:"RZBP", kNewNotificationIsEnabledForAppKey: false], [kNewNotificationNameKey:"Possesion Update", kNewNotificationShortNameKey:"PU", kNewNotificationIsEnabledForAppKey: false], [kNewNotificationNameKey:"Game Delayed/Postponed", kNewNotificationShortNameKey:"GD", kNewNotificationIsEnabledForAppKey: false]]
let kBasketballContestNotifications = [[kNewNotificationNameKey:"Final Score", kNewNotificationShortNameKey:"FS", kNewNotificationIsEnabledForAppKey: false], [kNewNotificationNameKey:"Qtr. Scores & Overtime", kNewNotificationShortNameKey:"PS", kNewNotificationIsEnabledForAppKey: false], [kNewNotificationNameKey:"All Scoring Updates", kNewNotificationShortNameKey:"SC", kNewNotificationIsEnabledForAppKey: false], [kNewNotificationNameKey:"Game Reporter Status", kNewNotificationShortNameKey:"LSI", kNewNotificationIsEnabledForAppKey: false], [kNewNotificationNameKey:"Game Start", kNewNotificationShortNameKey:"GS", kNewNotificationIsEnabledForAppKey: false], [kNewNotificationNameKey:"Game Delayed/Postponed", kNewNotificationShortNameKey:"GD", kNewNotificationIsEnabledForAppKey: false], [kNewNotificationNameKey:"Upcoming Game", kNewNotificationShortNameKey:"UG", kNewNotificationIsEnabledForAppKey: false]]
let kOtherSportContestNotifications = [[kNewNotificationNameKey:"Final Score", kNewNotificationShortNameKey:"FS", kNewNotificationIsEnabledForAppKey: false], [kNewNotificationNameKey:"All Scoring Updates", kNewNotificationShortNameKey:"SC", kNewNotificationIsEnabledForAppKey: false]]

// Latest Tab Filter Keys
let kLatestTabFilterGenderKey = "gender"
let kLatestTabFilterSportKey = "sport"
let kLatestTabFilterLevelKey = "level"
let kLatestTabFilterTeamIdKey = "teamId"
let kLatestTabFilterStateKey = "state"

// School Info Dictionary Keys
let kNewSchoolInfoDictionaryKey = "NewSchoolInfoDictionary"     // Dictionary
let kNewSchoolInfoNameKey = "name"                              // String
let kNewSchoolInfoFullNameKey = "formattedName"                 // String
let kNewSchoolInfoSchoolIdKey = "schoolId"                      // String
let kNewSchoolInfoMascotUrlKey = "mascotUrl"                    // String
let kNewSchoolInfoColor1Key = "color1"                          // String

// MARK: - Default School Constants

//let kDefaultSchoolName = "Abbeville"
//let kDefaultSchoolFullName = "Abbeville (AL)"
//let kDefaultSchoolId = "78EE5E47-5386-4384-8A8B-0628CF8B9E8B"
//let kDefaultSchoolState = "AL"
// Oak Ridge
let kDefaultSchoolLocation = [kLatitudeKey: "38.679866", kLongitudeKey: "-121.070664"]
//let kDefaultZipCode = "36310"
let kMissingSchoolColor = "E10500"

// MARK: - Third Party SDK Keys

// Amazon Ads
let kAmazonAdAppKey = "f7d3ca9b746e4ec38e05ef4650cfe6c2"
let kAmazonBannerAdSlotUUID = "337595cf-dad8-4123-ad3c-b8e581982afd"
let kAmazonInlineAdSlotUUID = "ac1729f3-9ea6-4cba-a391-e325c95b2fd0"

// Google Ads
let kNewsBannerAdIdKey = "NewsBannerAdId"
let kScoresBannerAdIdKey = "ScoresBannerAdId"
let kTeamsBannerAdIdKey = "TeamsBannerAdId"
let kAthleteBannerAdIdKey = "AthleteBannerAdId"
let kGoogleAdTimerValue = 32 // Was 17, changed in V6.1.3
let kNimbusAdTimerValue = 100000 // Was 30, changed in V6.3.1

// MoPub
let kMoPubAdUnitIdentifier = "652c5ed280be404ea2d10fc2ae26dc5f"

// FMS keys
let kFallbackUserIdKey = "FallbackUserId"
let kVCID2Key = "VCID2"
let kVCID2TypeKey = "VCID2Type"
let kUID2Key = "UID2"

// Adobe Marketing Cloud ID
let kAdobeMarketingCloudIdKey = "AdobeMarketingCloudId"

// ComScore
let kComScoreId = "3005086"

// Nimbus
let kNimbusDevPublisherNameKey = "dev-publisher"
let kNimbusDevApiKey = "DEV-af79-4612-87a9-aa70c17e8dc6"
let kNimbusPublisherNameKey = "cbsi-maxpreps"
let kNimbusApiKey = "9fa5ec1e-e4be-45b5-8e24-ceff2c31862e"

// MARK: - Feed Constants and URLs

// Feed Constants
let kSessionIdKey = "SessionId"
let kRequestKey = "Request"
let kMaxPrepsAppError = "MP App Error"
let kTokenBusterKey = "TokenBuster"

// Host for updating the individual school files for each state (appended with "state=<CA, WA, ALL, etc.>)
let kDownloadSchoolListHostProduction = "https://production.api.maxpreps.com/gatewayapp/schools-file/v1"
let kDownloadSchoolListHostStaging = "https://stag.api.maxpreps.com/gatewayapp/schools-file/v1"
let kDownloadSchoolListHostDev = "https://dev.api.maxpreps.com/gatewayapp/schools-file/v1"

// Host for getting UTC time from the server (Legacy API)
let kUtcLegacyTimeHostProduction = "https://prod.api.maxpreps.com/teamapp/utilities/utc/v1"

// Host for getting UTC time from the server (GET)
let kUtcTimeHostProduction = "https://production.api.maxpreps.com/utilities/times/utc/now/v1?format=MM.dd.yyyy.HH.mm"
let kUtcTimeHostStaging = "https://stag.api.maxpreps.com/utilities/times/utc/now/v1?format=MM.dd.yyyy.HH.mm"
let kUtcTimeHostDev = "https://dev.api.maxpreps.com/utilities/times/utc/now/v1?format=MM.dd.yyyy.HH.mm"

// Old URL used to populate a browser with a user's login cookies (appended with "?sessionId=<value>")
let kOldLoginUserWithIdHostProduction = "https://secure.maxpreps.com/feeds/apps_json/common/login_user.ashx"
let kOldLoginUserWithIdHostStaging = "https://secure-staging.maxpreps.com/feeds/apps_json/common/login_user.ashx"
let kOldLoginUserWithIdHostDev = "https://secure-dev.maxpreps.com/feeds/apps_json/common/login_user.ashx"

// URL for logging in a user with email/password (POST)
let kLoginUserWithEmailHostProduction = "https://production.api.maxpreps.com/gatewayapp/user-login/v1?source=MaxprepsApp_IOS"
let kLoginUserWithEmailHostStaging = "https://stag.api.maxpreps.com/gatewayapp/user-login/v1?source=MaxprepsApp_IOS"
let kLoginUserWithEmailHostDev = "https://dev.api.maxpreps.com/gatewayapp/user-login/v1?source=MaxprepsApp_IOS"

// URL for validating a user with userId (POST)
let kValidateUserWithUserIdHostProduction = "https://production.api.maxpreps.com/gatewayapp/user-login/v1?userid=%@&source=MaxprepsApp_IOS"
let kValidateUserWithUserIdHostStaging = "https://stag.api.maxpreps.com/gatewayapp/user-login/v1?userid=%@&source=MaxprepsApp_IOS"
let kValidateUserWithUserIdHostDev = "https://dev.api.maxpreps.com/gatewayapp/user-login/v1?userid=%@&source=MaxprepsApp_IOS"

// URL for resetting the user's password (GET)
let kResetPasswordHostProduction = "https://production.api.maxpreps.com/gatewayapp/user-reset-password-request/v1?email=%@"
let kResetPasswordHostStaging = "https://stag.api.maxpreps.com/gatewayapp/user-reset-password-request/v1?email=%@"
let kResetPasswordHostDev = "https://dev.api.maxpreps.com/gatewayapp/user-reset-password-request/v1?email=%@"

// URL for deleting a user account (DELETE)
let kDeleteUserAccountHostProduction = "https://production.api.maxpreps.com/users/%@/v1"
let kDeleteUserAccountHostStaging = "https://stag.api.maxpreps.com/users/%@/v1"
let kDeleteUserAccountHostDev = "https://dev.api.maxpreps.com/users/%@/v1"

// URL for validating an email (GET)
let kValidateEmailHostProduction = "https://production.api.maxpreps.com/gatewayapp/user-email-info/v1?email=%@"
let kValidateEmailHostStaging = "https://stag.api.maxpreps.com/gatewayapp/user-email-info/v1?email=%@"
let kValidateEmailHostDev = "https://dev.api.maxpreps.com/gatewayapp/user-email-info/v1?email=%@"

// URL for validating the zip code (GET)
let kValidateZipcodeHostProduction = "https://production.api.maxpreps.com/states/zipcodes/%@/v1"
let kValidateZipcodeHostStaging = "https://stag.api.maxpreps.com/states/zipcodes/%@/v1"
let kValidateZipcodeHostDev = "https://dev.api.maxpreps.com/states/zipcodes/%@/v1"

// URL for creating a new user account
let kCreateUserAccountHostProduction = "https://production.api.maxpreps.com/gatewayapp/user-register/v1?maxprepsMessaging=%@&partnerMessaging=%@"
let kCreateUserAccountHostStaging = "https://stag.api.maxpreps.com/gatewayapp/user-register/v1?maxprepsMessaging=%@&partnerMessaging=%@"
let kCreateUserAccountHostDev = "https://dev.api.maxpreps.com/gatewayapp/user-register/v1?maxprepsMessaging=%@&partnerMessaging=%@"

// URL for updating the user's email (POST)
let kUpdateUserEmailHostProduction = "https://production.api.maxpreps.com/gatewayapp/user-email-update/v1"
let kUpdateUserEmailHostStaging = "https://stag.api.maxpreps.com/gatewayapp/user-email-update/v1"
let kUpdateUserEmailHostDev = "https://dev.api.maxpreps.com/gatewayapp/user-email-update/v1"

// URL for updating the user's password (POST)
let kUpdateUserPasswordHostProduction = "https://production.api.maxpreps.com/gatewayapp/user-password-update/v1"
let kUpdateUserPasswordHostStaging = "https://stag.api.maxpreps.com/gatewayapp/user-password-update/v1"
let kUpdateUserPasswordHostDev = "https://dev.api.maxpreps.com/gatewayapp/user-password-update/v1"

// URL for updating a user's account (PATCH)
let kUpdateUserAccountHostProduction = "https://production.api.maxpreps.com/gatewayapp/user-patch/v1?userid=%@"
let kUpdateUserAccountHostStaging = "https://stag.api.maxpreps.com/gatewayapp/user-patch/v1?userid=%@"
let kUpdateUserAccountHostDev = "https://dev.api.maxpreps.com/gatewayapp/user-patch/v1?userid=%@"

// URL for getting user eligible subscription categories (GET)
let kGetUserEligibleSubscriptionCategoriesHostProduction = "https://production.api.maxpreps.com/users/%@/eligible-subscription-categories/v1"
let kGetUserEligibleSubscriptionCategoriesHostStaging = "https://stag.api.maxpreps.com/users/%@/eligible-subscription-categories/v1"
let kGetUserEligibleSubscriptionCategoriesHostDev = "https://dev.api.maxpreps.com/users/%@/eligible-subscription-categories/v1"

// URL for getting user subscription topics (GET)
let kGetUserSubscriptionTopicsHostProduction = "https://production.api.maxpreps.com/users/%@/subscription-topics/v1"
let kGetUserSubscriptionTopicsHostStaging = "https://stag.api.maxpreps.com/users/%@/subscription-topics/v1"
let kGetUserSubscriptionTopicsHostDev = "https://dev.api.maxpreps.com/users/%@/subscription-topics/v1"

// URL for creating a subscription (POST)
let kCreateUserSubscriptionHostProduction = "https://production.api.maxpreps.com/users/%@/subscription-topics/bulk/create/v1"
let kCreateUserSubscriptionHostStaging = "https://stag.api.maxpreps.com/users/%@/subscription-topics/bulk/create/v1"
let kCreateUserSubscriptionHostDev = "https://dev.api.maxpreps.com/users/%@/subscription-topics/bulk/create/v1"

// URL for deleting a subscription (POST)
let kDeleteUserSubscriptionHostProduction = "https://production.api.maxpreps.com/users/%@/subscription-topics/bulk/delete/v1"
let kDeleteUserSubscriptionHostStaging = "https://stag.api.maxpreps.com/users/%@/subscription-topics/bulk/delete/v1"
let kDeleteUserSubscriptionHostDev = "https://dev.api.maxpreps.com/users/%@/subscription-topics/bulk/delete/v1"

// URL for getting user special offers (GET)
let kGetUserSpecialOffersHostProduction = "https://production.api.maxpreps.com/users/%@/special-offers/v1"
let kGetUserSpecialOffersHostStaging = "https://stag.api.maxpreps.com/users/%@/special-offers/v1"
let kGetUserSpecialOffersHostDev = "https://dev.api.maxpreps.com/users/%@/special-offers/v1"

// URL for updating user special offers (POST)
let kUpdateUserSpecialOffersHostProduction = "https://production.api.maxpreps.com/users/%@/special-offers/%d/opt-in/v1"
let kUpdateUserSpecialOffersHostStaging = "https://stag.api.maxpreps.com/users/%@/special-offers/%d/opt-in/v1"
let kUpdateUserSpecialOffersHostDev = "https://dev.api.maxpreps.com/users/%@/special-offers/%d/opt-in/v1"

// URL for getting user favorite teams (GET)
let kNewGetUserFavoriteTeamsHostProduction = "https://production.api.maxpreps.com/gatewayapp/user-favorite-teams/v1?userid=%@"
let kNewGetUserFavoriteTeamsHostStaging = "https://stag.api.maxpreps.com/gatewayapp/user-favorite-teams/v1?userid=%@"
let kNewGetUserFavoriteTeamsHostDev = "https://dev.api.maxpreps.com/gatewayapp/user-favorite-teams/v1?userid=%@"

// URL for deleting a single user favorite team (DELETE)
let kNewDeleteUserFavoriteTeamHostProduction = "https://production.api.maxpreps.com/users/%@/favorite-teams/%@/v1"
let kNewDeleteUserFavoriteTeamHostStaging = "https://stag.api.maxpreps.com/users/%@/favorite-teams/%@/v1"
let kNewDeleteUserFavoriteTeamHostDev = "https://dev.api.maxpreps.com/users/%@/favorite-teams/%@/v1"

// URL for saving a single user favorite team (POST)
let kNewSaveUserFavoriteTeamHostProduction = "https://production.api.maxpreps.com/users/%@/favorite-teams/v1?sendEmail=true"
let kNewSaveUserFavoriteTeamHostStaging = "https://stag.api.maxpreps.com/users/%@/favorite-teams/v1?sendEmail=true"
let kNewSaveUserFavoriteTeamHostDev = "https://dev.api.maxpreps.com/users/%@/favorite-teams/v1?sendEmail=true"

// URL for updating a user favorite team notification setting (PATCH)
let kNewUpdateUserFavoriteTeamNotificationHostProduction =  "https://production.api.maxpreps.com/users/favorite-teams/notification-settings/%@/v1"
let kNewUpdateUserFavoriteTeamNotificationHostStaging = "https://stag.api.maxpreps.com/users/favorite-teams/notification-settings/%@/v1"
let kNewUpdateUserFavoriteTeamNotificationHostDev = "https://dev.api.maxpreps.com/users/favorite-teams/notification-settings/%@/v1"

// URL for getting user favorite athletes (GET)
let kGetUserFavoriteAthletesHostProduction = "https://production.api.maxpreps.com/gatewayapp/user-favorite-careers/v1?userid=%@"
let kGetUserFavoriteAthletesHostStaging = "https://stag.api.maxpreps.com/gatewayapp/user-favorite-careers/v1?userid=%@"
let kGetUserFavoriteAthletesHostDev = "https://dev.api.maxpreps.com/gatewayapp/user-favorite-careers/v1?userid=%@"

// URL for adding a user favorite athlete (POST)
let kAddUserFavoriteAthleteHostProduction = "https://production.api.maxpreps.com/users/%@/favorite-careers/v1?sendEmail=true"
let kAddUserFavoriteAthleteHostStaging = "https://stag.api.maxpreps.com/users/%@/favorite-careers/v1?sendEmail=true"
let kAddUserFavoriteAthleteHostDev = "https://dev.api.maxpreps.com/users/%@/favorite-careers/v1?sendEmail=true"

// URL for adding user favorite athletes (POST)
let kDeleteUserFavoriteAthleteHostProduction = "https://production.api.maxpreps.com/users/%@/favorite-careers/%@/v1"
let kDeleteUserFavoriteAthleteHostStaging = "https://stag.api.maxpreps.com/users/%@/favorite-careers/%@/v1"
let kDeleteUserFavoriteAthleteHostDev = "https://dev.api.maxpreps.com/users/%@/favorite-careers/%@/v1"

// URL for updating a user favorite athlete notification setting (PATCH)
let kUpdateUserFavoriteAthleteNotificationHostProduction =  "https://production.api.maxpreps.com/users/%@/careers/%@/short-names/all/favorite-careers/notification-settings/v1"
let kUpdateUserFavoriteAthleteNotificationHostStaging = "https://stag.api.maxpreps.com/users/%@/careers/%@/short-names/all/favorite-careers/notification-settings/v1"
let kUpdateUserFavoriteAthleteNotificationHostDev = "https://dev.api.maxpreps.com/users/%@/careers/%@/short-names/all/favorite-careers/notification-settings/v1"

// URL for getting school info for a group of schools (mascot, color, etc)
let kNewGetInfoForSchoolsHostProduction = "https://production.api.maxpreps.com/schools/lean-schools/bulk/v1"
let kNewGetInfoForSchoolsHostStaging = "https://stag.api.maxpreps.com/schools/lean-schools/bulk/v1"
let kNewGetInfoForSchoolsHostDev = "https://dev.api.maxpreps.com/schools/lean-schools/bulk/v1"

// URL for getting info (teams) for a particular school
let kNewGetTeamsForSchoolHostProduction = "https://production.api.maxpreps.com/gatewayapp/school-info/v1?schoolId=%@"
let kNewGetTeamsForSchoolHostStaging = "https://stag.api.maxpreps.com/gatewayapp/school-info/v1?schoolId=%@"
let kNewGetTeamsForSchoolHostDev = "https://dev.api.maxpreps.com/gatewayapp/school-info/v1?schoolId=%@"

// URL for using Bitly URL compression
let kBitlyUrlConverterHostProduction = "https://production.api.maxpreps.com/utilities/bitly/shorten/v1?url=%@"
let kBitlyUrlConverterHostStaging = "https://stag.api.maxpreps.com/utilities/bitly/shorten/v1?url=%@"
let kBitlyUrlConverterHostDev = "https://dev.api.maxpreps.com/utilities/bitly/shorten/v1?url=%@"

// URL for getting the ssid's for a team using the allSeasonId
let kGetSSIDsForTeamHostProduction = "https://production.api.maxpreps.com/teams/%@/allsportseasons/%@/sportseasons/v1"
let kGetSSIDsForTeamHostStaging = "https://stag.api.maxpreps.com/teams/%@/allsportseasons/%@/sportseasons/v1"
let kGetSSIDsForTeamHostDev = "https://dev.api.maxpreps.com/teams/%@/allsportseasons/%@/sportseasons/v1"

// URL for getting the team record
let kGetTeamRecordHostProduction = "https://production.api.maxpreps.com/gatewayapp/team-standings/v1?teamid=%@&sportseasonid=%@&maxcount=3"
let kGetTeamRecordHostStaging = "https://stag.api.maxpreps.com/gatewayapp/team-standings/v1?teamid=%@&sportseasonid=%@&maxcount=3"
let kGetTeamRecordHostDev = "https://dev.api.maxpreps.com/gatewayapp/team-standings/v1?teamid=%@&sportseasonid=%@&maxcount=3"

// URL for getting a team's item availability
let kGetTeamAvailabilityHostProduction = "https://production.api.maxpreps.com/teams/%@/sportseasons/%@/data-availability/v1"
let kGetTeamAvailabilityHostStaging = "https://stag.api.maxpreps.com/teams/%@/sportseasons/%@/data-availability/v1"
let kGetTeamAvailabilityHostDev = "https://dev.api.maxpreps.com/teams/%@/sportseasons/%@/data-availability/v1"

// URL for getting team videos (GET)
let kGetTeamVideosHostProduction = "https://production.api.maxpreps.com/gatewayapp/team-all-season-videos/v1?teamId=%@&allSeasonId=%@&page=1&itemCount=60&sort=%d"
let kGetTeamVideosHostStaging = "https://stag.api.maxpreps.com/gatewayapp/team-all-season-videos/v1?teamId=%@&allSeasonId=%@&page=1&itemCount=60&sort=%d"
let kGetTeamVideosHostDev = "https://dev.api.maxpreps.com/gatewayapp/team-all-season-videos/v1?teamId=%@&allSeasonId=%@&page=1&itemCount=60&sort=%d"

// URL for getting careers that are tagged to videos
let kGetVideoTaggedCareersHostProduction = "https://production.api.maxpreps.com/gatewayapp/video-career-references/v1?videoid=%@"
let kGetVideoTaggedCareersHostStaging = "https://stag.api.maxpreps.com/gatewayapp/video-career-references/v1?videoid=%@"
let kGetVideoTaggedCareersHostDev = "https://dev.api.maxpreps.com/gatewayapp/video-career-references/v1?videoid=%@"

// URLs for searching for an athlete
let kAthleteSearchHostProduction = "https://production.api.maxpreps.com/gatewayapp/roster-athlete-search/v1?term=%@&gender=%@&sport=%@" // optional "&maxresults=%@&state=%@&year=%@"
let kAthleteSearchHostStaging = "https://stag.api.maxpreps.com/gatewayapp/roster-athlete-search/v1?term=%@&gender=%@&sport=%@" // optional "&maxresults=%@&state=%@&year=%@"
let kAthleteSearchHostDev = "https://dev.api.maxpreps.com/gatewayapp/roster-athlete-search/v1?term=%@&gender=%@&sport=%@" // optional "&maxresults=%@&state=%@&year=%@"

// URLs for getting team detail for the tall favorites cards
let kGetTeamDetailCardHostProduction = "https://production.api.maxpreps.com/gatewayapp/team-cards/v1?scheduleCount=2&latestCount=5"
let kGetTeamDetailCardHostStaging = "https://stag.api.maxpreps.com/gatewayapp/team-cards/v1?scheduleCount=2&latestCount=5"
let kGetTeamDetailCardHostDev = "https://dev.api.maxpreps.com/gatewayapp/team-cards/v1?scheduleCount=2&latestCount=5"

// URL for saving user image (POST)
let kSaveUserImageHostProduction = "https://production.api.maxpreps.com/visualcontent/user-submitted-images/users/%@/qwixcore-profile-image/v1"
let kSaveUserImageHostStaging = "https://stag.api.maxpreps.com/visualcontent/user-submitted-images/users/%@/qwixcore-profile-image/v1"
let kSaveUserImageHostDev = "https://dev.api.maxpreps.com/visualcontent/user-submitted-images/users/%@/qwixcore-profile-image/v1"

// URL for deleting user image (DELETE)
let kDeleteUserImageHostProduction = "https://production.api.maxpreps.com/visualcontent/user-submitted-images/users/%@/qwixcore-profile-image/v1"
let kDeleteUserImageHostStaging = "https://stag.api.maxpreps.com/visualcontent/user-submitted-images/users/%@/qwixcore-profile-image/v1"
let kDeleteUserImageHostDev = "https://dev.api.maxpreps.com/visualcontent/user-submitted-images/users/%@/qwixcore-profile-image/v1"

// URL for saving or deleting a career image (POST)
let kSaveCareerImageHostProduction = "https://production.api.maxpreps.com/visualcontent/user-submitted-images/careers/%@/careers/v1?userid=%@"
let kSaveCareerImageHostStaging = "https://stag.api.maxpreps.com/visualcontent/user-submitted-images/careers/%@/careers/v1?userid=%@"
let kSaveCareerImageHostDev = "https://dev.api.maxpreps.com/visualcontent/user-submitted-images/careers/%@/careers/v1?userid=%@"

let kDeleteCareerImageHostProduction = "https://production.api.maxpreps.com/visualcontent/user-submitted-images/careers/%@/careers/v1"
let kDeleteCareerImageHostStaging = "https://stag.api.maxpreps.com/visualcontent/user-submitted-images/careers/%@/careers/v1"
let kDeleteCareerImageHostDev = "https://dev.api.maxpreps.com/visualcontent/user-submitted-images/careers/%@/careers/v1"

// URL for getting the career home data (GET)
let kGetCareerHomeHostProduction = "https://production.api.maxpreps.com/gatewayapp/career-profile-tab/v1?careerid=%@"
let kGetCareerHomeHostStaging = "https://stag.api.maxpreps.com/gatewayapp/career-profile-tab/v1?careerid=%@"
let kGetCareerHomeHostDev = "https://dev.api.maxpreps.com/gatewayapp/career-profile-tab/v1?careerid=%@"

// URL for getting the career profile bio data (GET)
let kGetCareerProfileBioHostProduction = "https://production.api.maxpreps.com/gatewayapp/career-profile-bio-tab/v1?careerid=%@"
let kGetCareerProfileBioHostStaging = "https://stag.api.maxpreps.com/gatewayapp/career-profile-bio-tab/v1?careerid=%@"
let kGetCareerProfileBioHostDev = "https://dev.api.maxpreps.com/gatewayapp/career-profile-bio-tab/v1?careerid=%@"

// URL for getting the career timeline data (GET)
let kGetCareerTimelineHostProduction = "https://production.api.maxpreps.com/gatewayapp/career-timeline-tab/v1?careerid=%@&page=%d&itemCount=%d"
let kGetCareerTimelineHostStaging = "https://stag.api.maxpreps.com/gatewayapp/career-timeline-tab/v1?careerid=%@&page=%d&itemCount=%d"
let kGetCareerTimelineHostDev = "https://dev.api.maxpreps.com/gatewayapp/career-timeline-tab/v1?careerid=%@&page=%d&itemCount=%d"

// URL for getting the career awards data (GET)
let kGetCareerAwardsHostProduction = "https://production.api.maxpreps.com/gatewayapp/career-awards-tab/v1?careerid=%@"
let kGetCareerAwardsHostStaging = "https://stag.api.maxpreps.com/gatewayapp/career-awards-tab/v1?careerid=%@"
let kGetCareerAwardsHostDev = "https://dev.api.maxpreps.com/gatewayapp/career-awards-tab/v1?careerid=%@"

// URL for getting the career photos (GET)
let kGetCareerPhotosHostProduction = "https://production.api.maxpreps.com/gatewayapp/career-photos-tab/v1?careerid=%@"
let kGetCareerPhotosHostStaging = "https://stag.api.maxpreps.com/gatewayapp/career-photos-tab/v1?careerid=%@"
let kGetCareerPhotosHostDev = "https://dev.api.maxpreps.com/gatewayapp/career-photos-tab/v1?careerid=%@"

// URL for getting the career videos (GET)
let kGetCareerVideosHostProduction = "https://production.api.maxpreps.com/gatewayapp/career-videos-tab/v1?careerid=%@&page=%d&itemCount=%d&sort=%@"
let kGetCareerVideosHostStaging = "https://stag.api.maxpreps.com/gatewayapp/career-videos-tab/v1?careerid=%@&page=%d&itemCount=%d&sort=%@"
let kGetCareerVideosHostDev = "https://dev.api.maxpreps.com/gatewayapp/career-videos-tab/v1?careerid=%@&page=%d&itemCount=%d&sort=%@"

// URL for getting the career news (GET)
let kGetCareerNewsHostProduction = "https://production.api.maxpreps.com/gatewayapp/career-news-tab/v1?careerid=%@"
let kGetCareerNewsHostStaging = "https://stag.api.maxpreps.com/gatewayapp/career-news-tab/v1?careerid=%@"
let kGetCareerNewsHostDev = "https://dev.api.maxpreps.com/gatewayapp/career-news-tab/v1?careerid=%@"

// URL for getting the career stats navigation header info (GET)
let kGetCareerStatsHeaderHostProduction = "https://production.api.maxpreps.com/gatewayapp/career-stats-tab/v1?careerid=%@"
let kGetCareerStatsHeaderHostStaging = "https://stag.api.maxpreps.com/gatewayapp/career-stats-tab/v1?careerid=%@"
let kGetCareerStatsHeaderHostDev = "https://dev.api.maxpreps.com/gatewayapp/career-stats-tab/v1?careerid=%@"

// URL for getting the career stats (GET)
let kGetCareerStatsHostProduction = "https://production.api.maxpreps.com/gatewayapp/career-season-stats/rollup/v1?careerid=%@&gendersport=%@"
let kGetCareerStatsHostStaging = "https://stag.api.maxpreps.com/gatewayapp/career-season-stats/rollup/v1?careerid=%@&gendersport=%@"
let kGetCareerStatsHostDev = "https://dev.api.maxpreps.com/gatewayapp/career-season-stats/rollup/v1?careerid=%@&gendersport=%@"

// URL for getting the season stats (GET)
let kGetSeasonStatsHostProduction = "https://production.api.maxpreps.com/gatewayapp/season-contest-stats/rollup/v1?athleteid=%@&teamid=%@&sportseasonid=%@"
let kGetSeasonStatsHostStaging = "https://stag.api.maxpreps.com/gatewayapp/season-contest-stats/rollup/v1?athleteid=%@&teamid=%@&sportseasonid=%@"
let kGetSeasonStatsHostDev = "https://dev.api.maxpreps.com/gatewayapp/season-contest-stats/rollup/v1?athleteid=%@&teamid=%@&sportseasonid=%@"

// URL for getting the video info for the video player (GET) (Legacy API)
let kGetVideoInfoLegacyHostProduction = "https://www.maxpreps.com/feeds/video/get_video_details.ashx"
let kGetVideoInfoLegacyHostStaging = "https://staging.maxpreps.com/feeds/video/get_video_details.ashx"
let kGetVideoInfoLegacyHostDev = "https://dev.maxpreps.com/feeds/video/get_video_details.ashx"

// URL for getting the video info for the video player (GET) (New API)
let kGetVideoInfoProduction = "https://production.api.maxpreps.com/videos/%@/v1"
let kGetVideoInfoStaging = "https://stag.api.maxpreps.com/videos/%@/v1"
let kGetVideoInfoDev = "https://dev.api.maxpreps.com/videos/%@/v1"

// URL for getting the contest videos for the video banners (GET)
let kGetContestVideosProduction = "https://production.api.maxpreps.com/gatewayapp/banner-videos/v1?maxCount=%d&contestId=%@"
let kGetContestVideosStaging = "https://stag.api.maxpreps.com/gatewayapp/banner-videos/v1?maxCount=%d&contestId=%@"
let kGetContestVideosDev = "https://dev.api.maxpreps.com/gatewayapp/banner-videos/v1?maxCount=%d&contestId=%@"

// URL for get secure rosters (GET)
let kGetSecureRostersProduction = "https://production.api.maxpreps.com/gatewayapp/team-rosters/v1?teamid=%@&sportseasonid=%@&sort=%@"
let kGetSecureRostersStaging = "https://stag.api.maxpreps.com/gatewayapp/team-rosters/v1?teamid=%@&sportseasonid=%@&sort=%@"
let kGetSecureRostersDev = "https://dev.api.maxpreps.com/gatewayapp/team-rosters/v1?teamid=%@&sportseasonid=%@&sort=%@"

let kGetPublicRostersProduction = "https://production.api.maxpreps.com/gatewayapp/team-rosters/public/v1?teamid=%@&sportseasonid=%@&sort=%@"
let kGetPublicRostersStaging = "https://stag.api.maxpreps.com/gatewayapp/team-rosters/public/v1?teamid=%@&sportseasonid=%@&sort=%@"
let kGetPublicRostersDev = "https://dev.api.maxpreps.com/gatewayapp/team-rosters/public/v1?teamid=%@&sportseasonid=%@&sort=%@"

// URL for adding an athlete to the roster (POST)
let kAddSecureAthleteProduction = "https://production.api.maxpreps.com/rosters/team-roster/teams/%@/sportseasons/%@/athletes/v1"
let kAddSecureAthleteStaging = "https://stag.api.maxpreps.com/rosters/team-roster/teams/%@/sportseasons/%@/athletes/v1"
let kAddSecureAthleteDev = "https://dev.api.maxpreps.com/rosters/team-roster/teams/%@/sportseasons/%@/athletes/v1"

// URL for updating an athlete (PATCH)
let kUpdateSecureAthleteProduction = "https://production.api.maxpreps.com/rosters/team-roster/athletes/%@/v1"
let kUpdateSecureAthleteStaging = "https://stag.api.maxpreps.com/rosters/team-roster/athletes/%@/v1"
let kUpdateSecureAthleteDev = "https://dev.api.maxpreps.com/rosters/team-roster/athletes/%@/v1"

// URL for deleting an athlete (POST)
let kDeleteSecureAthleteProduction = "https://production.api.maxpreps.com/rosters/team-roster/teams/%@/sportseasons/%@/athletes/%@/remove/v1"
let kDeleteSecureAthleteStaging = "https://production.api.maxpreps.com/rosters/team-roster/teams/%@/sportseasons/%@/athletes/%@/remove/v1"
let kDeleteSecureAthleteDev = "https://production.api.maxpreps.com/rosters/team-roster/teams/%@/sportseasons/%@/athletes/%@/remove/v1"

// URL for restoring an athlete (POST)
let kRestoreAthleteSecureProduction = "https://production.api.maxpreps.com/rosters/team-roster/teams/%@/sportseasons/%@/athletes/%@/restore/v1"
let kRestoreAthleteSecureStaging = "https://stag.api.maxpreps.com/rosters/team-roster/teams/%@/sportseasons/%@/athletes/%@/restore/v1"
let kRestoreAthleteSecureDev = "https://dev.api.maxpreps.com/rosters/team-roster/teams/%@/sportseasons/%@/athletes/%@/restore/v1"

// URL for copying last season's roster to the given sport season (POST)
let kCopyRosterSecureProduction = "https://production.api.maxpreps.com/rosters/team-roster/teams/%@/sportseasons/%@/copy-athletes/v1"
let kCopyRosterSecureStaging = "https://stag.api.maxpreps.com/rosters/team-roster/teams/%@/sportseasons/%@/copy-athletes/v1"
let kCopyRosterSecureDev = "https://dev.api.maxpreps.com/rosters/team-roster/teams/%@/sportseasons/%@/copy-athletes/v1"

// URL for adding staff to the roster (POST)
let kAddSecureStaffProduction = "https://production.api.maxpreps.com/rosters/staff-roster/teams/%@/sportseasons/%@/staff/v1"
let kAddSecureStaffStaging = "https://stag.api.maxpreps.com/rosters/staff-roster/teams/%@/sportseasons/%@/staff/v1"
let kAddSecureStaffDev = "https://dev.api.maxpreps.com/rosters/staff-roster/teams/%@/sportseasons/%@/staff/v1"

// URL for updating or deleting a staff member (PATCH/DELETE)
let kUpdateOrDeleteSecureStaffProduction = "https://production.api.maxpreps.com/rosters/staff-roster/teams/%@/sportseasons/%@/staff/%@/v1"
let kUpdateOrDeleteSecureStaffStaging = "https://stag.api.maxpreps.com/rosters/staff-roster/teams/%@/sportseasons/%@/staff/%@/v1"
let kUpdateOrDeleteSecureStaffDev = "https://dev.api.maxpreps.com/rosters/staff-roster/teams/%@/sportseasons/%@/staff/%@/v1"

// URL for adding or deleting an athlete photo (MULTIPART-POST or DELETE)
let kAddOrDeleteAthletePhotoProduction = "https://production.api.maxpreps.com/rosters/team-roster/teams/%@/sportseasons/%@/athletes/%@/roster-photos/v1"
let kAddOrDeleteAthletePhotoStaging = "https://stag.api.maxpreps.com/rosters/team-roster/teams/%@/sportseasons/%@/athletes/%@/roster-photos/v1"
let kAddOrDeleteAthletePhotoDev = "https://dev.api.maxpreps.com/rosters/team-roster/teams/%@/sportseasons/%@/athletes/%@/roster-photos/v1"

// URL for getting or deleting a team photo (GET/DELETE)
let kGetOrDeleteTeamPhotoProduction = "https://production.api.maxpreps.com/visualcontent/images/teams/%@/sportseasons/%@/team-photo/v1"
let kGetOrDeleteTeamPhotoStaging = "https://stag.api.maxpreps.com/visualcontent/images/teams/%@/sportseasons/%@/team-photo/v1"
let kGetOrDeleteTeamPhotoDev = "https://dev.api.maxpreps.com/visualcontent/images/teams/%@/sportseasons/%@/team-photo/v1"

// URL for adding a team photo (MULTIPART-POST)
let kAddTeamPhotoProduction = "https://production.api.maxpreps.com/visualcontent/user-submitted-images/teams/%@/sportseasons/%@/teams/v1?userId=%@"
let kAddTeamPhotoStaging = "https://stag.api.maxpreps.com/visualcontent/user-submitted-images/teams/%@/sportseasons/%@/teams/v1?userId=%@"
let kAddTeamPhotoDev = "https://dev.api.maxpreps.com/visualcontent/user-submitted-images/teams/%@/sportseasons/%@/teams/v1?userId=%@"

// Old User Image Feed URLs
let kGetUserImageUrlProduction = "https://secure.maxpreps.com/utility/member/handlers/get_qwixcore_profile_image.ashx"
let kGetUserImageUrlStaging = "https://secure-staging.maxpreps.com/utility/member/handlers/get_qwixcore_profile_image.ashx"
let kGetUserImageUrlDev = "https://secure-dev.maxpreps.com/utility/member/handlers/get_qwixcore_profile_image.ashx"

// URL for getting the favorite team contests and dates on the scores tab (POST)
let kGetFavoriteTeamContestsProduction = "https://production.api.maxpreps.com/gatewayapp/contest-ids-grouped-by-date-by-all-season-teams/v1"
let kGetFavoriteTeamContestsStaging = "https://stag.api.maxpreps.com/gatewayapp/contest-ids-grouped-by-date-by-all-season-teams/v1"
let kGetFavoriteTeamContestsDev = "https://dev.api.maxpreps.com/gatewayapp/contest-ids-grouped-by-date-by-all-season-teams/v1"

// URL for getting the favorite team contest results on the scores tab (POST)
let kGetFavoriteTeamContestResultsProduction = "https://production.api.maxpreps.com/gatewayapp/scoreboard-contests-by-ids/v1?userid=%@"
let kGetFavoriteTeamContestResultsStaging = "https://stag.api.maxpreps.com/gatewayapp/scoreboard-contests-by-ids/v1?userid=%@"
let kGetFavoriteTeamContestResultsDev = "https://dev.api.maxpreps.com/gatewayapp/scoreboard-contests-by-ids/v1?userid=%@"

// URL for getting the scoreboard entities in the AddMetroVC (GET)
let kGetScoreboardEntitiesProduction = "https://production.api.maxpreps.com/gatewayapp/groupings/state-sports/v1?statecode=%@&gendersport=%@"
let kGetScoreboardEntitiesStaging = "https://stag.api.maxpreps.com/gatewayapp/groupings/state-sports/v1?statecode=%@&gendersport=%@"
let kGetScoreboardEntitiesDev = "https://dev.api.maxpreps.com/gatewayapp/groupings/state-sports/v1?statecode=%@&gendersport=%@"

// URL for getting scoreboard contests and dates on the scores tab (GET)
let kGetScoreboardContestsProduction = "https://production.api.maxpreps.com/gatewayapp/contest-ids-grouped-by-date-by-context/v1?context=%@&id=%@&gendersport=%@&level=varsity&excludetbadate=true"
let kGetScoreboardContestsStaging = "https://stag.api.maxpreps.com/gatewayapp/contest-ids-grouped-by-date-by-context/v1?context=%@&id=%@&gendersport=%@&level=varsity&excludetbadate=true"
let kGetScoreboardContestsDev = "https://dev.api.maxpreps.com/gatewayapp/contest-ids-grouped-by-date-by-context/v1?context=%@&id=%@&gendersport=%@&level=varsity&excludetbadate=true"

// URL for getting the scoreboard contest results on the scores tab (POST)
let kGetScoreboardContestResultsProduction = "https://production.api.maxpreps.com/gatewayapp/scoreboard-contests-by-ids/basic/v1"
let kGetScoreboardContestResultsStaging = "https://stag.api.maxpreps.com/gatewayapp/scoreboard-contests-by-ids/basic/v1"
let kGetScoreboardContestResultsDev = "https://dev.api.maxpreps.com/gatewayapp/scoreboard-contests-by-ids/basic/v1"

// URL for getting the schedule for a particular team (GET)
let kGetScheduleProduction = "https://production.api.maxpreps.com/gatewayapp/team-schedule/v1?teamid=%@&sportseasonid=%@"
let kGetScheduleStaging = "https://stag.api.maxpreps.com/gatewayapp/team-schedule/v1?teamid=%@&sportseasonid=%@"
let kGetScheduleDev = "https://dev.api.maxpreps.com/gatewayapp/team-schedule/v1?teamid=%@&sportseasonid=%@"

// URL for getting the leagueId for a particular team (GET)
let kGetLeaguesForTeamProduction = "https://production.api.maxpreps.com/schools/%@/sportseasons/%@/leagues/v1"
let kGetLeaguesForTeamStaging = "https://stag.api.maxpreps.com/schools/%@/sportseasons/%@/leagues/v1"
let kGetLeaguesForTeamDev = "https://dev.api.maxpreps.com/schools/%@/sportseasons/%@/leagues/v1"

// URL for getting the teams in a particular league (GET)
let kGetTeamsForLeagueProduction = "https://production.api.maxpreps.com/teams/leagues/%@/sportseasons/%@/teams/v1"
let kGetTeamsForLeagueStaging = "https://stag.api.maxpreps.com/teams/leagues/%@/sportseasons/%@/teams/v1"
let kGetTeamsForLeagueDev = "https://dev.api.maxpreps.com/teams/leagues/%@/sportseasons/%@/teams/v1"

// URL for getting a single contest (GET)
let kGetContestProduction = "https://production.api.maxpreps.com/contests/teams/%@/sportseasons/%@/contests/%@/basic/v1"
let kGetContestStaging = "https://stag.api.maxpreps.com/contests/teams/%@/sportseasons/%@/contests/%@/basic/v1"
let kGetContestDev = "https://dev.api.maxpreps.com/contests/teams/%@/sportseasons/%@/contests/%@/basic/v1"

// URL for adding a contest (POST)
let kAddSecureContestProduction = "https://production.api.maxpreps.com/contests/teams/%@/sportseasons/%@/contests/v1"
let kAddSecureContestStaging = "https://stag.api.maxpreps.com/contests/teams/%@/sportseasons/%@/contests/v1"
let kAddSecureContestDev = "https://dev.api.maxpreps.com/contests/teams/%@/sportseasons/%@/contests/v1"

// URL for updating a contest (PATCH)
let kUpdateSecureContestProduction = "https://production.api.maxpreps.com/contests/teams/%@/sportseasons/%@/contests/%@/v1?sortedByIndex=true"
let kUpdateSecureContestStaging = "https://stag.api.maxpreps.com/contests/teams/%@/sportseasons/%@/contests/%@/v1?sortedByIndex=true"
let kUpdateSecureContestDev = "https://dev.api.maxpreps.com/contests/teams/%@/sportseasons/%@/contests/%@/v1?sortedByIndex=true"

// URL for deleting a contest (POST)
let kDeleteSecureContestProduction = "https://production.api.maxpreps.com/contests/teams/%@/sportseasons/%@/contests/remove/v1"
let kDeleteSecureContestStaging = "https://stag.api.maxpreps.com/contests/teams/%@/sportseasons/%@/contests/remove/v1"
let kDeleteSecureContestDev = "https://dev.api.maxpreps.com/contests/teams/%@/sportseasons/%@/contests/remove/v1"

// URL for restoring a contest (POST)
let kRestoreSecureContestProduction = "https://production.api.maxpreps.com/contests/teams/%@/sportseasons/%@/contests/restore/v1"
let kRestoreSecureContestStaging = "https://stag.api.maxpreps.com/contests/teams/%@/sportseasons/%@/contests/restore/v1"
let kRestoreSecureContestDev = "https://dev.api.maxpreps.com/contests/teams/%@/sportseasons/%@/contests/restore/v1"

// URL for copying a schedule (POST)
let kCopyTeamScheduleProduction = "https://production.api.maxpreps.com/contests/teams/%@/sportseasons/%@/copy-schedule/v1"
let kCopyTeamScheduleStaging = "https://stag.api.maxpreps.com/contests/teams/%@/sportseasons/%@/copy-schedule/v1"
let kCopyTeamScheduleDev = "https://dev.api.maxpreps.com/contests/teams/%@/sportseasons/%@/copy-schedule/v1"

// Subscribed Calendar URL
let kSubscribedCalendarProduction = "https://production.api.maxpreps.com/contests/teams/%@/sportseasons/%@/calendars/v1/calendar.ics"
let kSubscribedCalendarStaging = "https://stag.api.maxpreps.com/contests/teams/%@/sportseasons/%@/calendars/v1/calendar.ics"
let kSubscribedCalendarDev = "https://dev.api.maxpreps.com/contests/teams/%@/sportseasons/%@/calendars/v1/calendar.ics"

// URL for getting players of the game (GET)
let kGetPlayersOfTheGameProduction = "https://production.api.maxpreps.com/contests/teams/%@/sportseasons/%@/contests/%@/playerofthegame/v1"
let kGetPlayersOfTheGameStaging = "https://stag.api.maxpreps.com/contests/teams/%@/sportseasons/%@/contests/%@/playerofthegame/v1"
let kGetPlayersOfTheGameDev = "https://dev.api.maxpreps.com/contests/teams/%@/sportseasons/%@/contests/%@/playerofthegame/v1"

// URL for adding a player of the game (POST)
let kAddPlayerOfTheGameProduction = "https://production.api.maxpreps.com/contests/teams/%@/sportseasons/%@/playerofthegame/v1"
let kAddPlayerOfTheGameStaging = "https://stag.api.maxpreps.com/contests/teams/%@/sportseasons/%@/playerofthegame/v1"
let kAddPlayerOfTheGameDev = "https://dev.api.maxpreps.com/contests/teams/%@/sportseasons/%@/playerofthegame/v1"

// URL for updating a player of the game (PATCH)
let kUpdatePlayerOfTheGameProduction = "https://production.api.maxpreps.com/contests/teams/%@/sportseasons/%@/playerofthegame/%@/v1"
let kUpdatePlayerOfTheGameStaging = "https://stag.api.maxpreps.com/contests/teams/%@/sportseasons/%@/playerofthegame/%@/v1"
let kUpdatePlayerOfTheGameDev = "https://dev.api.maxpreps.com/contests/teams/%@/sportseasons/%@/playerofthegame/%@/v1"

// URL for deleting the player of the game (DELETE)
let kDeletePlayerOfTheGameProduction = "https://production.api.maxpreps.com/contests/teams/%@/sportseasons/%@/playerofthegame/%@/v1"
let kDeletePlayerOfTheGameStaging = "https://stag.api.maxpreps.com/contests/teams/%@/sportseasons/%@/playerofthegame/%@/v1"
let kDeletePlayerOfTheGameDev = "https://dev.api.maxpreps.com/contests/teams/%@/sportseasons/%@/playerofthegame/%@/v1"

// URL for getting the box score (GET)
let kGetBoxScoresProduction = "https://production.api.maxpreps.com/gatewayapp/contest-box-score/v1?teamid=%@&sportseasonid=%@&contestid=%@"
let kGetBoxScoresStaging = "https://stag.api.maxpreps.com/gatewayapp/contest-box-score/v1?teamid=%@&sportseasonid=%@&contestid=%@"
let kGetBoxScoresDev = "https://dev.api.maxpreps.com/gatewayapp/contest-box-score/v1?teamid=%@&sportseasonid=%@&contestid=%@"

// URL for saving the box score (POST)
let kUpdateBoxScoreProduction = "https://production.api.maxpreps.com/contests/teams/%@/sportseasons/%@/contests/%@/scores/v1"
let kUpdateBoxScoreStaging = "https://stag.api.maxpreps.com/contests/teams/%@/sportseasons/%@/contests/%@/scores/v1"
let kUpdateBoxScoreDev = "https://dev.api.maxpreps.com/contests/teams/%@/sportseasons/%@/contests/%@/scores/v1"

// URL for getting the Athlete User Profile (GET)
let kGetAthleteUserProfileProduction = "https://production.api.maxpreps.com/gatewayapp/user-profile/athlete/v1?userid=%@&careerid=%@"
let kGetAthleteUserProfileStaging = "https://stag.api.maxpreps.com/gatewayapp/user-profile/athlete/v1?userid=%@&careerid=%@"
let kGetAthleteUserProfileDev = "https://dev.api.maxpreps.com/gatewayapp/user-profile/athlete/v1?userid=%@&careerid=%@"

// URL for updating the athlete profile (PATCH)
let kUpdateAthleteUserProfileProduction = "https://production.api.maxpreps.com/careers/%@/v1"
let kUpdateAthleteUserProfileStaging = "https://stag.api.maxpreps.com/careers/%@/v1"
let kUpdateAthleteUserProfileDev = "https://dev.api.maxpreps.com/careers/%@/v1"

// URL for updating the athlete academic scores (PATCH). Note this can also be done by the API above
let kUpdateAthleteAcademicScoresProduction = "https://production.api.maxpreps.com/gatewayapp/career-academic-scores/v1?careerId=%@"
let kUpdateAthleteAcademicScoresStaging = "https://stag.api.maxpreps.com/gatewayapp/career-academic-scores/v1?careerId=%@"
let kUpdateAthleteAcademicScoresDev = "https://production.api.maxpreps.com/gatewayapp/career-academic-scores/v1?careerId=%@"

// URL for saving the athlete academic classes (POST)
let kSaveAthleteAcademicClassesProduction = "https://production.api.maxpreps.com/gatewayapp/career-academic-classes/v1?careerid=%@&classType=%@"
let kSaveAthleteAcademicClassesStaging = "https://stag.api.maxpreps.com/gatewayapp/career-academic-classes/v1?careerid=%@&classType=%@"
let kSaveAthleteAcademicClassesDev = "https://dev.api.maxpreps.com/gatewayapp/career-academic-classes/v1?careerid=%@&classType=%@"

// URL for adding an athlete achievement or award (POST)
let kAddAthleteAchievementsAwardsProduction = "https://production.api.maxpreps.com/gatewayapp/career-achievements-awards/v1?careerid=%@"
let kAddAthleteAchievementsAwardsStaging = "https://stag.api.maxpreps.com/gatewayapp/career-achievements-awards/v1?careerid=%@"
let kAddAthleteAchievementsAwardsDev = "https://dev.api.maxpreps.com/gatewayapp/career-achievements-awards/v1?careerid=%@"

// URL for updating or deleting an athlete achievement or award (PATCH)
let kUpdateOrDeleteAthleteAchievementsAwardsProduction = "https://production.api.maxpreps.com/gatewayapp/career-achievements-awards/v1?careerid=%@&careerAchievementAwardId=%@"
let kUpdateOrDeleteAthleteAchievementsAwardsStaging = "https://stag.api.maxpreps.com/gatewayapp/career-achievements-awards/v1?careerid=%@&careerAchievementAwardId=%@"
let kUpdateOrDeleteAthleteAchievementsAwardsDev = "https://dev.api.maxpreps.com/gatewayapp/career-achievements-awards/v1?careerid=%@&careerAchievementAwardId=%@"

// URL for adding an athlete extracurricular (POST)
let kAddAthleteExtracurricularProduction = "https://production.api.maxpreps.com/gatewayapp/career-extracurriculars/v1?careerid=%@"
let kAddAthleteExtracurricularStaging = "https://stag.api.maxpreps.com/gatewayapp/career-extracurriculars/v1?careerid=%@"
let kAddAthleteExtracurricularDev = "https://dev.api.maxpreps.com/gatewayapp/career-extracurriculars/v1?careerid=%@"

// URL for updating or deleting an athlete extracurricular (PATCH)
let kUpdateOrDeleteAthleteExtracurricularProduction = "https://production.api.maxpreps.com/gatewayapp/career-extracurriculars/v1?careerId=%@&careerExtracurricularId=%@"
let kUpdateOrDeleteAthleteExtracurricularStaging = "https://stag.api.maxpreps.com/gatewayapp/career-extracurriculars/v1?careerId=%@&careerExtracurricularId=%@"
let kUpdateOrDeleteAthleteExtracurricularDev = "https://dev.api.maxpreps.com/gatewayapp/career-extracurriculars/v1?careerId=%@&careerExtracurricularId=%@"

// URL for determining if the "Claim" profile button is visible on the career page (GET)
let kGetCareerContactsProduction = "https://production.api.maxpreps.com/careers/%@/career-contacts/v1"
let kGetCareerContactsStaging = "https://stag.api.maxpreps.com/careers/%@/career-contacts/v1"
let kGetCareerContactsDev = "https://dev.api.maxpreps.com/careers/%@/career-contacts/v1"

// URL for getting a user's detailed career contacts (GET)
let kGetUserCareerAdminContactsProduction = "https://production.api.maxpreps.com/gatewayapp/user-career-contacts-info/v1?userid=%@"
let kGetUserCareerAdminContactsStaging = "https://stag.api.maxpreps.com/gatewayapp/user-career-contacts-info/v1?userid=%@"
let kGetUserCareerAdminContactsDev = "https://dev.api.maxpreps.com/gatewayapp/user-career-contacts-info/v1?userid=%@"

// URL for determining if the user can claim this athlete (more thorough check) (GET)
// Called when the claim button is touched
let kGetAthleteClaimEligibilityProduction = "https://production.api.maxpreps.com/careers/%@/career-claim-eligibility/v1?userid=%@"
let kGetAthleteClaimEligibilityStaging = "https://stag.api.maxpreps.com/careers/%@/career-claim-eligibility/v1?userid=%@"
let kGetAthleteClaimEligibilityDev = "https://dev.api.maxpreps.com/careers/%@/career-claim-eligibility/v1?userid=%@"

// URL for claiming a career (POST)
let kClaimCareerProfileProduction = "https://production.api.maxpreps.com/users/%@/career-contact/v1"
let kClaimCareerProfileStaging = "https://stag.api.maxpreps.com/users/%@/career-contact/v1"
let kClaimCareerProfileDev = "https://dev.api.maxpreps.com/users/%@/career-contact/v1"

// URL for getting a fan's user profile (GET)
let kGetFanUserProfileProduction = "https://production.api.maxpreps.com/gatewayapp/user-profile/fan/v1?userid=%@"
let kGetFanUserProfileStaging = "https://stag.api.maxpreps.com/gatewayapp/user-profile/fan/v1?userid=%@"
let kGetFanUserProfileDev = "https://dev.api.maxpreps.com/gatewayapp/user-profile/fan/v1?userid=%@"

// URL for getting a parent's user profile (GET)
let kGetParentUserProfileProduction = "https://production.api.maxpreps.com/gatewayapp/user-profile/parent/v1?userid=%@&careerid=%@"
let kGetParentUserProfileStaging = "https://stag.api.maxpreps.com/gatewayapp/user-profile/parent/v1?userid=%@&careerid=%@"
let kGetParentUserProfileDev = "https://dev.api.maxpreps.com/gatewayapp/user-profile/parent/v1?userid=%@&careerid=%@"

// URL for getting a coach's user profile (GET)
let kGetCoachUserProfileProduction = "https://production.api.maxpreps.com/gatewayapp/user-profile/coach/v1?userid=%@&teamid=%@&sportseasonid=%@"
let kGetCoachUserProfileStaging = "https://stag.api.maxpreps.com/gatewayapp/user-profile/coach/v1?userid=%@&teamid=%@&sportseasonid=%@"
let kGetCoachUserProfileDev = "https://dev.api.maxpreps.com/gatewayapp/user-profile/coach/v1?userid=%@&teamid=%@&sportseasonid=%@"

// URL for getting an AD's user profile (GET)
let kGetADUserProfileProduction = "https://production.api.maxpreps.com/gatewayapp/user-profile/ad/v1?userid=%@&teamid=%@"
let kGetADUserProfileStaging = "https://stag.api.maxpreps.com/gatewayapp/user-profile/ad/v1?userid=%@&teamid=%@"
let kGetADUserProfileDev = "https://dev.api.maxpreps.com/gatewayapp/user-profile/ad/v1?userid=%@&teamid=%@"

// URL for updating the coach profile (PATCH)
let kUpdateCoachUserProfileProduction = "https://production.api.maxpreps.com/users/%@/qwixcore-profiles/v1"
let kUpdateCoachUserProfileStaging = "https://stag.api.maxpreps.com/users/%@/qwixcore-profiles/v1"
let kUpdateCoachUserProfileDev = "https://dev.api.maxpreps.com/users/%@/qwixcore-profiles/v1"

// URL for getting the team summaries for all of the coach's teams (GET)
let kGetCoachUserProfileTeamSummariesProduction = "https://production.api.maxpreps.com/gatewayapp/user-profile/coach/team-summaries/v1?userid=%@"
let kGetCoachUserProfileTeamSummariesStaging = "https://stag.api.maxpreps.com/gatewayapp/user-profile/coach/team-summaries/v1?userid=%@"
let kGetCoachUserProfileTeamSummariesDev = "https://dev.api.maxpreps.com/gatewayapp/user-profile/coach/team-summaries/v1?userid=%@"

// URL for getting the staff detail view's content (GET)
let kGetStaffDetailsProduction = "https://production.api.maxpreps.com/gatewayapp/user-profile/coach/public/v1?userid=%@"
let kGetStaffDetailsStaging = "https://stag.api.maxpreps.com/gatewayapp/user-profile/coach/public/v1?userid=%@"
let kGetStaffDetailsDev = "https://dev.api.maxpreps.com/gatewayapp/user-profile/coach/public/v1?userid=%@"

// URL for getting the Latest tab items (POST)
let kGetLatestTabItemsProduction = "https://production.api.maxpreps.com/gatewayapp/latest-tab/v1"
let kGetLatestTabItemsStaging = "https://stag.api.maxpreps.com/gatewayapp/latest-tab/v1"
let kGetLatestTabItemsDev = "https://dev.api.maxpreps.com/gatewayapp/latest-tab/v1"

let kGetNationalCompetitiveSeasonsProduction = "https://production.api.maxpreps.com/gatewayapp/gender-sports/%@/competitive-season-data/v1"
let kGetNationalCompetitiveSeasonsStaging = "https://stag.api.maxpreps.com/gatewayapp/gender-sports/%@/competitive-season-data/v1"
let kGetNationalCompetitiveSeasonsDev = "https://dev.api.maxpreps.com/gatewayapp/gender-sports/%@/competitive-season-data/v1"

// URL for getting the state seasons and years for a particular sport (GET)
// /states/ca/sportseasons/v1?excludeunpublished=true
let kGetStateCompetitiveSeasonsProduction = "https://production.api.maxpreps.com/states/%@/sportseasons/v1"
let kGetStateCompetitiveSeasonsStaging = "https://stag.api.maxpreps.com/states/%@/sportseasons/v1"
let kGetStateCompetitiveSeasonsDev = "https://dev.api.maxpreps.com/states/%@/sportseasons/v1"

// URL for getting player stats on the latest filter tab (GET)
let kGetAthleteStatLeadersProduction = "https://production.api.maxpreps.com/gatewayapp/athlete-stat-leaders/v1?%@"
let kGetAthleteStatLeadersStaging = "https://stag.api.maxpreps.com/gatewayapp/athlete-stat-leaders/v1?%@"
let kGetAthleteStatLeadersDev = "https://dev.api.maxpreps.com/gatewayapp/athlete-stat-leaders/v1?%@"

// URL for getting team stats on the latest filter tab (GET)
let kGetTeamStatLeadersProduction = "https://production.api.maxpreps.com/gatewayapp/team-stat-leaders/v1?%@"
let kGetTeamStatLeadersStaging = "https://stag.api.maxpreps.com/gatewayapp/team-stat-leaders/v1?%@"
let kGetTeamStatLeadersDev = "https://dev.api.maxpreps.com/gatewayapp/team-stat-leaders/v1?%@"

// URL for getting team rankings on the latest filter tab (GET)
let kGetTeamRankingsLeadersProduction = "https://production.api.maxpreps.com/gatewayapp/team-rankings/v1?%@"
let kGetTeamRankingsLeadersStaging = "https://stag.api.maxpreps.com/gatewayapp/team-rankings/v1?%@"
let kGetTeamRankingsLeadersDev = "https://dev.api.maxpreps.com/gatewayapp/team-rankings/v1?%@"

// URL for getting the playoff states and seasons in the sports arenas (GET)
let kGetSportsArenaPlayoffStateSeasonsProduction = "https://production.api.maxpreps.com/gatewayapp/groupings/playoff-sport-states-seasons/v1?gendersport=%@"
let kGetSportsArenaPlayoffStateSeasonsStaging = "https://stag.api.maxpreps.com/gatewayapp/groupings/playoff-sport-states-seasons/v1?gendersport=%@"
let kGetSportsArenaPlayoffStateSeasonsDev = "https://dev.api.maxpreps.com/gatewayapp/groupings/playoff-sport-states-seasons/v1?gendersport=%@"

// URL for getting the playoff items in the sports arenas (GET)
let kGetSportsArenaPlayoffsProduction = "https://production.api.maxpreps.com/gatewayapp/state-sport-season-playoffs/v1?statecode=%@&gendersport=%@&year=%@&season=%@"
let kGetSportsArenaPlayoffsStaging = "https://stag.api.maxpreps.com/gatewayapp/state-sport-season-playoffs/v1?statecode=%@&gendersport=%@&year=%@&season=%@"
let kGetSportsArenaPlayoffsDev = "https://dev.api.maxpreps.com/gatewayapp/state-sport-season-playoffs/v1?statecode=%@&gendersport=%@&year=%@&season=%@"

// URL for getting the native team home data (GET)
let kGetNativeTeamHomeProduction = "https://production.api.maxpreps.com/gatewayapp/team-home/v1?teamid=%@&sportseasonid=%@"
let kGetNativeTeamHomeStaging = "https://stag.api.maxpreps.com/gatewayapp/team-home/v1?teamid=%@&sportseasonid=%@"
let kGetNativeTeamHomeDev = "https://dev.api.maxpreps.com/gatewayapp/team-home/v1?teamid=%@&sportseasonid=%@"

// URL for requesting coach access (POST)
let kRequestCoachAccessHostProduction = "https://production.api.maxpreps.com/gatewayapp/team-admin-access-request/v1"
let kRequestCoachAccessHostStaging = "https://stag.api.maxpreps.com/gatewayapp/team-admin-access-request/v1"
let kRequestCoachAccessHostDev = "https://dev.api.maxpreps.com/gatewayapp/team-admin-access-request/v1"

// URL for getting the public staff roster used in the join team section (GET)
let kGetPublicStaffRosterProduction = "https://production.api.maxpreps.com/gatewayapp/staff-roster/public/v1?teamid=%@&allseasonid=%@&season=%@&coachOnly=false&activeOnly=true&minInactiveMonths=10"
let kGetPublicStaffRosterStaging = "https://stag.api.maxpreps.com/gatewayapp/staff-roster/public/v1?teamid=%@&allseasonid=%@&season=%@&coachOnly=false&activeOnly=true&minInactiveMonths=10"
let kGetPublicStaffRosterDev = "https://dev.api.maxpreps.com/gatewayapp/staff-roster/public/v1?teamid=%@&allseasonid=%@&season=%@&coachOnly=false&activeOnly=true&minInactiveMonths=10"

// URL for requesting to be a volunteer statistician (POST)
let kRequestVolunteerAccessHostProduction = "https://production.api.maxpreps.com/gatewayapp/statistician-access-request/v1"
let kRequestVolunteerAccessHostStaging = "https://stag.api.maxpreps.com/gatewayapp/statistician-access-request/v1"
let kRequestVolunteerAccessHostDev = "https://dev.api.maxpreps.com/gatewayapp/statistician-access-request/v1"

// URL for getting career deep link info (GET)
let kGetCareerDeepLinkInfoHostProduction = "https://production.api.maxpreps.com/gatewayapp/career-info/v1?careerid=%@"
let kGetCareerDeepLinkInfoHostStaging = "https://stag.api.maxpreps.com/gatewayapp/career-info/v1?careerid=%@"
let kGetCareerDeepLinkInfoHostDev = "https://dev.api.maxpreps.com/gatewayapp/career-info/v1?careerid=%@"

// URL for getting team deep link info (GET)
let kGetTeamDeepLinkInfoHostProduction = "https://production.api.maxpreps.com/gatewayapp/team-info/v1?teamid=%@&sportseasonid=%@"
let kGetTeamDeepLinkInfoHostStaging = "https://stag.api.maxpreps.com/gatewayapp/team-info/v1?teamid=%@&sportseasonid=%@"
let kGetTeamDeepLinkInfoHostDev = "https://dev.api.maxpreps.com/gatewayapp/team-info/v1?teamid=%@&sportseasonid=%@"

// URL for uploading videos (MULTI-PART POST)
let kUploadVideoHostProduction = "https://production.api.maxpreps.com/videos/uploads/v1"
let kUploadVideoHostStaging = "https://stag.api.maxpreps.com/videos/uploads/v1"
let kUploadVideoHostDev = "https://dev.api.maxpreps.com/videos/uploads/v1"

// URL for getting career teams (GET)
let kGetCareerTeamsHostProduction = "https://production.api.maxpreps.com/gatewayapp/career-teams/v1?careerid=%@"
let kGetCareerTeamsHostStaging = "https://stag.api.maxpreps.com/gatewayapp/career-teams/v1?careerid=%@"
let kGetCareerTeamsHostDev = "https://dev.api.maxpreps.com/gatewayapp/career-teams/v1?careerid=%@"

// URL for incrementing the video view count (POST)
let kIncrementVideoViewCountHostProduction = "https://production.api.maxpreps.com/videos/%@/view-counts/increment/v1"
let kIncrementVideoViewCountHostStaging = "https://stag.api.maxpreps.com/videos/%@/view-counts/increment/v1"
let kIncrementVideoViewCountHostDev = "https://dev.api.maxpreps.com/videos/%@/view-counts/increment/v1"

// URL for getting a user's video contributions (GET)
let kGetUserVideoContributionsHostProduction = "https://production.api.maxpreps.com/gatewayapp/video-uploads-by-user/v1?userid=%@"
let kGetUserVideoContributionsHostStaging = "https://stag.api.maxpreps.com/gatewayapp/video-uploads-by-user/v1?userid=%@"
let kGetUserVideoContributionsHostDev = "https://dev.api.maxpreps.com/gatewayapp/video-uploads-by-user/v1?userid=%@"

// URL for updating a user's video details (PATCH)
let kUpdateUserVideoDetailsProduction = "https://production.api.maxpreps.com/gatewayapp/video-patch/v1?videoid=%@"
let kUpdateUserVideoDetailsStaging = "https://stag.api.maxpreps.com/gatewayapp/video-patch/v1?videoid=%@"
let kUpdateUserVideoDetailsDev = "https://dev.api.maxpreps.com/gatewayapp/video-patch/v1?videoid=%@"

// URL for deleting a user's video (DELETE)
let kDeleteUserContributionsVideoProduction = "https://production.api.maxpreps.com/gatewayapp/video-delete/v1?videoid=%@"
let kDeleteUserContributionsVideoStaging = "https://stag.api.maxpreps.com/gatewayapp/video-delete/v1?videoid=%@"
let kDeleteUserContributionsVideoDev = "https://dev.api.maxpreps.com/gatewayapp/video-delete/v1?videoid=%@"

// URL for untagging an athlete from a career video (DELETE)
let kUntagAthleteFromVideoProduction = "https://production.api.maxpreps.com/gatewayapp/video-career-reference/v1?videoid=%@&careerid=%@"
let kUntagAthleteFromVideoStaging = "https://stag.api.maxpreps.com/gatewayapp/video-career-reference/v1?videoid=%@&careerid=%@"
let kUntagAthleteFromVideoDev = "https://dev.api.maxpreps.com/gatewayapp/video-career-reference/v1?videoid=%@&careerid=%@"

// URL for reporting a video (POST)
let kReportVideoHostProduction = "https://production.api.maxpreps.com/videos/%@/content-reports/v1"
let kReportVideoHostStaging = "https://stag.api.maxpreps.com/videos/%@/content-reports/v1"
let kReportVideoHostDev = "https://dev.api.maxpreps.com/videos/%@/content-reports/v1"

// MARK: - Test Feeds

// URL for sending a test notification using IRIS (POST)
let kSendUserNotificationHost = "https://production.api.maxpreps.com/gatewayapp/test-notification/v1?actionType=User&alert=%@&userId=%@&environment=%@"

// URL for getting the PBP status
let kGetPlayByPlayStatusProduction = "https://contest.search.maxpreps.com/livegames/member"
let kGetPlayByPlayStatusStaging = "https://contest-staging.search.maxpreps.com/livegames/member"
let kGetPlayByPlayStatusDev = "https://contest-dev.search.maxpreps.com/livegames/member"

// MARK: - Web URLs

// Member Account Web URLs
let kMemberProfileHostProduction = "https://secure.maxpreps.com/m/member/default.aspx"
let kMemberProfileHostStaging = "https://secure-staging.maxpreps.com/m/member/default.aspx"
let kMemberProfileHostDev = "https://secure-dev.maxpreps.com/m/member/default.aspx"

let kSubscriptionsUrlProduction = "https://secure.maxpreps.com/m/member/subscriptions.aspx"
let kSubscriptionsUrlStaging = "https://secure-staging.maxpreps.com/m/member/subscriptions.aspx"
let kSubscriptionsUrlDev = "https://secure-dev.maxpreps.com/m/member/subscriptions.aspx"

// Used for tech support, policy, terms of use
let kTechSupportUrl = "https://support.maxpreps.com"
let kCBSPolicyUrl = "https://www.viacomcbsprivacy.com/policy"
let kCBSTermsOfUseUrl = "https://www.viacomcbs.legal/us/en/cbsi/terms-of-use"
let kCaliforniaNoticeUrl = "https://privacy.paramount.com/en/policy#additional-information-us-states"

// NCSA privacy policy and terms of use
let kNCSAPrivacyPolicyUrl = "https://www.imgacademy.com/privacy-policy?website=ncsasports.org"
let kNCSATermsOfUseUrl = "https://www.ncsasports.org/terms-and-conditions-of-use"

// Teams tab URLs
let kTeamHomeHostGeneric = "https://%@.maxpreps.com/team/index?schoolid=%@&ssid=%@&allSeasonId=%@"
let kRosterHostGeneric = "https://%@.maxpreps.com/team/roster?schoolid=%@&ssid=%@&allSeasonId=%@"
//let kScheduleHostGeneric = "https://%@.maxpreps.com/team/schedule?schoolid=%@&ssid=%@&allSeasonId=%@"
//let kNonReactScheduleHostGeneric = "https://%@.maxpreps.com/m/team/schedule.aspx?schoolid=%@&ssid=%@"
let kNewScheduleHostGeneric = "https://%@.maxpreps.com/local/team/schedule.aspx?schoolid=%@&ssid=%@"
let kRankingsHostGeneric = "https://%@.maxpreps.com/team/rankings?schoolid=%@&ssid=%@&allSeasonId=%@"
let kStatsHostGeneric = "https://%@.maxpreps.com/m/team/stats.aspx?schoolid=%@&ssid=%@&allSeasonId=%@"
let kStandingsHostGeneric = "https://%@.maxpreps.com/team/standings?schoolid=%@&ssid=%@&allSeasonId=%@"
let kPhotosHostGeneric = "https://%@.maxpreps.com/team/photography?schoolid=%@&ssid=%@&allSeasonId=%@"
let kVideosHostGeneric = "https://%@.maxpreps.com/m/team/videos.aspx?schoolid=%@&ssid=%@&allSeasonId=%@"
let kArticlesHostGeneric = "https://%@.maxpreps.com/m/team/articles.aspx?schoolid=%@&ssid=%@&allSeasonId=%@"
let kSportsWearHostGeneric = "https://%@.maxpreps.com/m/team/store.aspx?schoolid=%@&ssid=%@&allSeasonId=%@"
let kCareerProfileHostGeneric = "https://%@.maxpreps.com/m/career/default.aspx?careerid=%@&allSeasonId=%@"

// Report Scores URL
let kReportScoresHostGeneric = "https://%@.maxpreps.com/utility/reportscore/report_final_score.aspx?contestid=%@&ssid=%@"

// Contest Stats URL
let kContestStatsHostProduction = "https://admin.maxpreps.com/admin/m/apps/stats/view_team_stats.aspx?schoolid=%@&ssid=%@&contestid=%@"
let kContestStatsHostStaging = "https://admin-staging.maxpreps.com/admin/m/apps/stats/view_team_stats.aspx?schoolid=%@&ssid=%@&contestid=%@"
let kContestStatsHostDev = "https://admin-dev.maxpreps.com/admin/m/apps/stats/view_team_stats.aspx?schoolid=%@&ssid=%@&contestid=%@"

let kAboutRankingsHost = "https://www.maxpreps.com/news/X4MCEfnBEeC-rAAmVebEWg/how-the-maxpreps-rankings-work.htm"
let kStatDefinitionsHost = "https://www.maxpreps.com/popup/stat_descriptions.aspx?gendersport=%@"
let kStatFaqHost = "https://support.maxpreps.com/hc/en-us/articles/4404593358107"

// Social URLs
let kMaxPrepsTwitterUrl = "http://www.twitter.com/maxpreps"
let kMaxPrepsFacebookUrl = "http://www.facebook.com/maxpreps"
let kMaxPrepsYouTubeUrl = "http://m.youtube.com/maxprepssports"
let kMaxPrepsTikTokUrl = "http://www.tiktok.com/@maxpreps"
let kMaxPrepsInstagramUrl = "http://www.instagram.com/maxpreps"
