//
//  TeamDetailViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 7/25/23.
//

import UIKit
import MapKit
import AVFoundation
import GoogleMobileAds
//import MoPubAdapter
import DTBiOSSDK
import AdSupport
import AppTrackingTransparency

class TeamDetailViewController: UIViewController, UIScrollViewDelegate, IQActionSheetPickerViewDelegate, UITableViewDelegate, UITableViewDataSource, DTBAdCallback, GADBannerViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var yearSelectorButton: UIButton!
   
    @IBOutlet weak var floatingContainerView: UIView!
    @IBOutlet weak var teamContainerView: UIView!
    @IBOutlet weak var teamImageContainerView: UIView!
    @IBOutlet weak var teamImageView: UIImageView!
    @IBOutlet weak var teamInitialLabel: UILabel!
    @IBOutlet weak var teamImageEditButton: UIButton!
    @IBOutlet weak var floatingTitleLabel: UILabel!
    @IBOutlet weak var floatingSubtitleLabel: UILabel!
    @IBOutlet weak var floatingFollowersLabel: UILabel!
    @IBOutlet weak var saveFavoriteButton: UIButton!
    @IBOutlet weak var removeFavoriteButton: UIButton!
    @IBOutlet weak var sportIconImageView: UIImageView!
    @IBOutlet weak var adminIndicatorView: UIImageView!
    @IBOutlet weak var teamSelectorButton: UIButton!
    
    @IBOutlet weak var itemScrollView: UIScrollView!
    @IBOutlet weak var horizLine: UIView!
    private var leftShadow : UIImageView!
    private var rightShadow : UIImageView!
    
    var selectedTeam : Team?
    var showSaveFavoriteButton = false
    var showRemoveFavoriteButton = false
    var selectedSSID = ""
    var ftag = "" // Added for deep link attribution
    var tabName = "" // Added to switch tabs when the view is loaded
    
    private var bottomTabBarPad = 0
    private var activeTeamsArray = [] as Array<Dictionary<String,Any>>
    private var currentTeam =  [:] as Dictionary<String,Any>
    private var yearArray = [] as Array<String>
    //private var seasonYearArray = [] as Array<String>
    private var selectedYearIndex = 0
    private var filteredItems = [] as Array<String>
    private var selectedItemIndex = 0
    private var userIsAdmin = false
    
    private var contestsArray = [] as Array<Dictionary<String,Any>>
    private var leadersObj = [:] as Dictionary<String,Any>
    private var leagueStandingObj = [:] as Dictionary<String,Any>
    private var overallStandingObj = [:] as Dictionary<String,Any>
    private var schoolColor1 = ""
    private var schoolColor2 = ""
    private var schoolColor3 = ""
    private var schoolMascotName = ""
    private var schoolCity = ""
    private var schoolState = ""
    
    private var liveScoringSignupUrl = ""
    private var tournamentName = ""
    private var tournamentBracketName = ""
    private var tournamentCanonicalUrl = ""
    
    private var homeTableView: UITableView!
    private var statsHeaderView: TeamHomeStatsHeaderViewCell!
    private var statsFooterView: TeamHomeStatsFooterViewCell!
    
    private var allItems = ["Roster","Schedule","Stats","Rankings","Standings","Videos","Photos","News"] //["Roster","Schedule","Stats","Rankings","Standings","Videos","Photos","News","Shop"]
    
    private var rosterVC: RosterViewController!
    private var scheduleVC: ScheduleViewController!
    private var tableInitialHeight = 0
    private var videoPlayerVC: VideoPlayerViewController!
    private var webVC: WebViewController!
    private var athleteDetailVC: NewAthleteDetailViewController!
    private var teamSelectorVC: TeamSelectorViewController!
    private var teamVideoCenterVC: TeamVideoCenterViewController!
    
    private var googleBannerAdView: GAMBannerView!
    private var bannerBackgroundView: UIVisualEffectView! //UIImageView!
    
    private var trackingGuid = ""
    private var userTeamRole = ""
    private var tickTimer: Timer!
    private var teamRefreshControl = UIRefreshControl()
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Nimbus Variables
    
    let apsLoader: DTBAdLoader = {
        let loader = DTBAdLoader()
        loader.setAdSizes([
            DTBAdSize(bannerAdSizeWithWidth: 320, height: 50, andSlotUUID: kAmazonBannerAdSlotUUID) as Any
        ])
        return loader
    }()
    
    lazy var bidders: [Bidder] = [
        // Position identifies this placement in our dashboard, it is freeform so I matched the Google ad unit name
        NimbusBidder(request: .forBannerAd(position: "team")),
        APSBidder(adLoader: apsLoader)
    ]
    
    lazy var dynamicPriceManager = DynamicPriceManager(bidders: bidders, refreshInterval: TimeInterval(kNimbusAdTimerValue))
    
    // MARK: - Reload View With Different Sport
    
    private func reloadViewWithDifferentSport(newTeam: Team)
    {
        // Reset the tableView to the top
        self.homeTableView.setContentOffset(.zero, animated: false)
        
        // Update the selectedTeam components
        self.selectedTeam!.sport = newTeam.sport
        self.selectedTeam!.teamLevel = newTeam.teamLevel
        self.selectedTeam!.gender = newTeam.gender
        self.selectedTeam!.season = newTeam.season
        self.selectedTeam!.allSeasonId = newTeam.allSeasonId
        
        print(String(format: "SchoolId: %@", newTeam.schoolId))
        print(String(format: "AllSeasonId: %@", newTeam.allSeasonId))
        
        self.showSaveFavoriteButton = false
        self.showRemoveFavoriteButton = false

        let userId = kUserDefaults.value(forKey: kUserIdKey) as! String
        let isFavorite = MiscHelper.isTeamMyFavoriteTeam(schoolId: self.selectedTeam!.schoolId, gender: self.selectedTeam!.gender, sport: self.selectedTeam!.sport, teamLevel: self.selectedTeam!.teamLevel, season: self.selectedTeam!.season)
        
        if (isFavorite == true)
        {
            if (userId != kTestDriveUserId)
            {
                self.showSaveFavoriteButton = false
                self.showRemoveFavoriteButton = true
            }
        }
        else
        {
            if (userId != kTestDriveUserId)
            {
                self.showSaveFavoriteButton = true
                self.showRemoveFavoriteButton = false
            }
        }
        
        // Show or hide the favorite buttons
        saveFavoriteButton.isHidden = !self.showSaveFavoriteButton
        removeFavoriteButton.isHidden = !self.showRemoveFavoriteButton
        
        // This will be unhidden when the feed finishes
        yearSelectorButton.isHidden = true
        adminIndicatorView.isHidden = true
        teamImageEditButton.isHidden = true
        
        homeTableView.isHidden = true
        
        // Show or hide the adminContainer
       userIsAdmin = MiscHelper.isUserAnAdmin(schoolId: self.selectedTeam!.schoolId, allSeasonId: self.selectedTeam!.allSeasonId)
        
        if (userIsAdmin == true)
        {
            adminIndicatorView.isHidden = false
        }

        let genderSportLevel = MiscHelper.genderSportLevelFrom(gender: self.selectedTeam!.gender, sport: self.selectedTeam!.sport, level: self.selectedTeam!.teamLevel)
        
        var floatingSubtitle = ""
        
        if (self.selectedTeam!.sport.lowercased() == "soccer")
        {
            floatingSubtitle = String(format: "%@ (%@)", genderSportLevel, self.selectedTeam!.season)
        }
        else
        {
            floatingSubtitle = genderSportLevel
        }
         
        subtitleLabel.text = genderSportLevel
        floatingSubtitleLabel.text = floatingSubtitle
        
        // Set the sport icon and shift it to the left of the floatingSubtitle
        let sportImage = MiscHelper.getImageForSport(self.selectedTeam!.sport)
        sportIconImageView.image = sportImage
        
        let subtitleTextWidth = floatingSubtitle.widthOfString(usingFont: floatingSubtitleLabel.font)
        sportIconImageView.frame = CGRect(x: ((kDeviceWidth - subtitleTextWidth) / 2) - 22, y: sportIconImageView.frame.origin.y, width: sportIconImageView.frame.size.width, height: sportIconImageView.frame.size.height)
        
        // Get the SSID's for the active team
        self.getSSIDsForTeam(schoolId: self.selectedTeam!.schoolId, allSeasonId: self.selectedTeam!.allSeasonId)
    }
    
    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelectTitles titles: [String])
    {
        let title = titles.first
        // Search for the team that matches the selected year
        selectedYearIndex = yearArray.firstIndex(of: title!)!
        
        let year = yearArray[selectedYearIndex]
        yearSelectorButton.setTitle(year, for: .normal)
        
        // Update the year in the header
        statsHeaderView.yearLabel.text = String(format: "20%@ Season", year)

        currentTeam = activeTeamsArray[selectedYearIndex]
        
        // Get the available items
        self.getAvailbleItems()
        
        selectedItemIndex = 0
        
        // Get the homeTableView data
        self.getNativeTeamHomeData()
    }
    
    // MARK: - Show System Map
    
    private func showSystemMap(latitude: Double, longitude: Double, name: String)
    {
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: options)
    }
    
    // MARK: - Show Detail Web View Controller
    
    private func showDetailWebViewController(_ title: String)
    {
        //let item = filteredItems[selectedItemIndex]
        let ssid = currentTeam["sportSeasonId"] as! String
        let schoolId = currentTeam["schoolId"] as! String
        let allSeasonId = currentTeam["allSeasonId"] as! String
        
        // Get the correct URL using the selectedItemIndex and the filteredItemsArray
        var urlString = ""
        var subDomain = ""
        
        // Build the subdomain
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            let branchValue = kUserDefaults.string(forKey: kBranchValue)
            subDomain = String(format: "branch-%@.fe", branchValue!.lowercased())
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            subDomain = "dev"
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            subDomain = "staging"
        }
        else
        {
            subDomain = "www"
        }
        
        var replacementTitle = ""
        var trackingKey = ""
        
        /*
         let kTrackingPageTypeKey = "pageType"
         let kTrackingSiteHierKey = "siteHier"
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
         let kTrackingArticleIdKey = "articleId"
         let kTrackingArticleTitleKey = "articleTitle"
         let kTrackingArticleTypeKey = "articleType"
         let kTrackingFiltersAppliedKey = "filtersApplied"
         let kTrackingClickTextKey = "clickText"
         let kEmptyTrackingContextData = ["key":"noValue"]
         */
        
        // Build the tracking context data object
        var cData = kEmptyTrackingContextData
        
        let schoolName = self.selectedTeam?.schoolName
        let schoolState = self.selectedTeam?.schoolState
        let sport = self.selectedTeam?.sport
        let level = self.selectedTeam?.teamLevel
        let gender = self.selectedTeam?.gender
        let season = self.selectedTeam?.season
        let year = currentTeam["year"] as! String
        
        cData[kTrackingSchoolNameKey] = schoolName
        cData[kTrackingSchoolStateKey] = schoolState
        cData[kTrackingTeamIdKey] = schoolId
        cData[kTrackingSportNameKey] = sport
        cData[kTrackingSportLevelKey] = level
        cData[kTrackingSportGenderKey] = gender
        cData[kTrackingSeasonKey] = season
        cData[kTrackingSchoolYearKey] = year
        cData[kTrackingUserTeamRoleKey] = userTeamRole
        
        switch title
        {
        case "Home": // No longer used
            // Choose different URLs depending on the year
            if (selectedYearIndex == 0)
            {
                // Choose the team home url if the current year
                urlString = String(format: kTeamHomeHostGeneric, subDomain, schoolId, ssid, allSeasonId)
            }
            else
            {
                // Changed in MPA-1888
                urlString = String(format: kNewScheduleHostGeneric, subDomain, schoolId, ssid)
                /*
                // Choose the team schedule url if prior years
                if (userIsAdmin == true)
                {
                    urlString = String(format: kNonReactScheduleHostGeneric, subDomain, schoolId, ssid)
                }
                else
                {
                    urlString = String(format: kScheduleHostGeneric, subDomain, schoolId, ssid, allSeasonId)
                }
                */
            }
            
            replacementTitle = "Home"
        
        case "Roster": // No longer used
            urlString = String(format: kRosterHostGeneric, subDomain, schoolId, ssid, allSeasonId)
            replacementTitle = "Roster"
            
        case "Schedule": // Used for non-core sports
            // Changed in MPA-1888
            urlString = String(format: kNewScheduleHostGeneric, subDomain, schoolId, ssid)
            /*
            if (userIsAdmin == true)
            {
                urlString = String(format: kNonReactScheduleHostGeneric, subDomain, schoolId, ssid)
            }
            else
            {
                urlString = String(format: kScheduleHostGeneric, subDomain, schoolId, ssid, allSeasonId)
            }
            */
            replacementTitle = "Schedule"
            
        case "Stats":
            urlString = String(format: kStatsHostGeneric, subDomain, schoolId, ssid, allSeasonId)
            replacementTitle = "Stats"
            trackingKey = "team-stats-home"
            
        case "News":
            urlString = String(format: kArticlesHostGeneric, subDomain, schoolId, ssid, allSeasonId)
            replacementTitle = "News"
            trackingKey = "articles-home"
            
        case "Standings":
            urlString = String(format: kStandingsHostGeneric, subDomain, schoolId, ssid, allSeasonId)
            replacementTitle = "Standings"
            trackingKey = "standings-home"
            
        case "Rankings":
            urlString = String(format: kRankingsHostGeneric, subDomain, schoolId, ssid, allSeasonId)
            replacementTitle = "Rankings"
            trackingKey = "rankings-home"
            
        case "Photos":
            urlString = String(format: kPhotosHostGeneric, subDomain, schoolId, ssid, allSeasonId)
            replacementTitle = "Photos"
            trackingKey = "photo-galleries"
            
        case "Videos":
            urlString = String(format: kVideosHostGeneric, subDomain, schoolId, ssid, allSeasonId)
            replacementTitle = "Videos"
            trackingKey = "videos-home"
            
        case "Shop":
            urlString = String(format: kSportsWearHostGeneric, subDomain, schoolId, ssid, allSeasonId)
            replacementTitle = "Shop"
            
        default:
            return
        }
        
        // Use a track event
        if (trackingKey != "")
        {
            TrackingManager.trackEvent(featureName: trackingKey, cData: cData)
        }
        
        webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC.titleString = replacementTitle
        webVC.urlString = urlString
        webVC.titleColor = UIColor.mpBlackColor()
        webVC.navColor = UIColor.mpWhiteColor()
        webVC.allowRotation = false
        webVC.showShareButton = true
        webVC.showScrollIndicators = true
        webVC.showLoadingOverlay = true
        webVC.showBannerAd = true
        webVC.adId = kUserDefaults.value(forKey: kTeamsBannerAdIdKey) as! String
        webVC.tabBarVisible = true
        webVC.enableAdobeQueryParameter = true
        webVC.trackingContextData = cData
        webVC.trackingKey = trackingKey
        
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    // MARK: - Show Generic Web View Controller
    
    private func showGenericWebViewController(urlString: String, title: String, contestId: String)
    {
        webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC.titleString = title
        webVC.urlString = urlString
        webVC.titleColor = UIColor.mpBlackColor()
        webVC.navColor = UIColor.mpWhiteColor()
        webVC.allowRotation = false
        webVC.showShareButton = true
        webVC.showScrollIndicators = false
        webVC.showLoadingOverlay = true
        webVC.showBannerAd = true
        webVC?.adId = kUserDefaults.value(forKey: kTeamsBannerAdIdKey) as! String
        webVC.tabBarVisible = true
        webVC.enableAdobeQueryParameter = true
        webVC.contestId = contestId
        webVC.trackingKey = "team-home"
        webVC.trackingContextData = kEmptyTrackingContextData

        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    // MARK: - Show Roster View Controller
    
    private func showRosterViewController()
    {
        let ssid = currentTeam["sportSeasonId"] as! String
        let year = currentTeam["year"] as! String
        
        rosterVC = RosterViewController(nibName: "RosterViewController", bundle: nil)
        rosterVC.selectedTeam = self.selectedTeam
        rosterVC.ssid = ssid
        rosterVC.year = year
        rosterVC.selectedYearIndex = selectedYearIndex
     
        self.navigationController?.pushViewController(rosterVC, animated: true)
        
        // Build the tracking context data object
        var cData = kEmptyTrackingContextData
        
        let schoolName = self.selectedTeam?.schoolName
        let schoolState = self.selectedTeam?.schoolState
        let schoolId = self.selectedTeam?.schoolId
        let sport = self.selectedTeam?.sport
        let level = self.selectedTeam?.teamLevel
        let gender = self.selectedTeam?.gender
        let season = self.selectedTeam?.season
        
        cData[kTrackingSchoolNameKey] = schoolName
        cData[kTrackingSchoolStateKey] = schoolState
        cData[kTrackingTeamIdKey] = schoolId
        cData[kTrackingSportNameKey] = sport
        cData[kTrackingSportLevelKey] = level
        cData[kTrackingSportGenderKey] = gender
        cData[kTrackingSeasonKey] = season
        cData[kTrackingSchoolYearKey] = year
        cData[kTrackingUserTeamRoleKey] = userTeamRole
        
        TrackingManager.trackState(featureName: "roster-home", trackingGuid: trackingGuid, cData: cData)
    }
    
    // MARK: - Show Schedule View Controller
    
    private func showScheduleViewController()
    {
        let ssid = currentTeam["sportSeasonId"] as! String
        let year = currentTeam["year"] as! String
        
        scheduleVC = ScheduleViewController(nibName: "ScheduleViewController", bundle: nil)
        scheduleVC.selectedTeam = self.selectedTeam
        scheduleVC.ssid = ssid
        scheduleVC.year = year
        scheduleVC.selectedYearIndex = selectedYearIndex
     
        self.navigationController?.pushViewController(scheduleVC, animated: true)
        
        // Build the tracking context data object
        var cData = kEmptyTrackingContextData
        
        let schoolName = self.selectedTeam?.schoolName
        let schoolState = self.selectedTeam?.schoolState
        let schoolId = self.selectedTeam?.schoolId
        let sport = self.selectedTeam?.sport
        let level = self.selectedTeam?.teamLevel
        let gender = self.selectedTeam?.gender
        let season = self.selectedTeam?.season
        
        cData[kTrackingSchoolNameKey] = schoolName
        cData[kTrackingSchoolStateKey] = schoolState
        cData[kTrackingTeamIdKey] = schoolId
        cData[kTrackingSportNameKey] = sport
        cData[kTrackingSportLevelKey] = level
        cData[kTrackingSportGenderKey] = gender
        cData[kTrackingSeasonKey] = season
        cData[kTrackingSchoolYearKey] = year
        cData[kTrackingUserTeamRoleKey] = userTeamRole
        
        TrackingManager.trackState(featureName: "schedule-home", trackingGuid: trackingGuid, cData: cData)
    }
    
    // MARK: - Show Team Video View Controller
    
    private func showTeamVideoViewController()
    {
        //self.clearBannerAd()
        
        //let allSeasonId = currentTeam["allSeasonId"] as! String
        let schoolId = currentTeam["schoolId"] as! String
        
        // Build the tracking context data object
        var cData = kEmptyTrackingContextData
        
        let schoolName = self.selectedTeam?.schoolName
        let schoolState = self.selectedTeam?.schoolState
        let sport = self.selectedTeam?.sport
        let level = self.selectedTeam?.teamLevel
        let gender = self.selectedTeam?.gender
        let season = self.selectedTeam?.season
        let year = currentTeam["year"] as! String
        
        cData[kTrackingSchoolNameKey] = schoolName
        cData[kTrackingSchoolStateKey] = schoolState
        cData[kTrackingTeamIdKey] = schoolId
        cData[kTrackingSportNameKey] = sport
        cData[kTrackingSportLevelKey] = level
        cData[kTrackingSportGenderKey] = gender
        cData[kTrackingSeasonKey] = season
        cData[kTrackingSchoolYearKey] = year
        cData[kTrackingUserTeamRoleKey] = userTeamRole
        
        let ssid = currentTeam["sportSeasonId"] as! String
        
        teamVideoCenterVC = TeamVideoCenterViewController(nibName: "TeamVideoCenterViewController", bundle: nil)
        teamVideoCenterVC.trackingContextData = cData
        teamVideoCenterVC.trackingKey = "team-video-watch"
        teamVideoCenterVC.selectedTeam = self.selectedTeam
        teamVideoCenterVC.activeTeams = self.activeTeamsArray
        teamVideoCenterVC.ssid = ssid
     
        self.navigationController?.pushViewController(teamVideoCenterVC, animated: true)
        
        
        TrackingManager.trackState(featureName: "team-video-watch", trackingGuid: trackingGuid, cData: cData)
    }
    
    // MARK: - Show Team Selector
    
    private func showTeamSelectorViewController()
    {
        let schoolId = self.selectedTeam!.schoolId
        let schoolName = self.selectedTeam!.schoolName
        let schoolFullName = self.selectedTeam!.schoolFullName
        
        let selectedSchool = School(fullName: schoolFullName, name: schoolName, schoolId: schoolId, address: "", state: "", city: "", zip: "", searchDistance: 0.0, latitude: "0.0", longitude: "0.0")

        teamSelectorVC = TeamSelectorViewController(nibName: "TeamSelectorViewController", bundle: nil)
        teamSelectorVC?.selectedSchool = selectedSchool
        teamSelectorVC?.teamDetailViewControllerIsParent = true
        teamSelectorVC?.teamDetailCurrentSport = self.selectedTeam!.sport
        teamSelectorVC?.teamDetailCurrentGender = self.selectedTeam!.gender
        teamSelectorVC?.teamDetailCurrentTeamLevel = self.selectedTeam!.teamLevel
        teamSelectorVC?.teamDetailCurrentSeason = self.selectedTeam!.season
        
        self.navigationController?.pushViewController(teamSelectorVC!, animated: true)
        
        // Tracking
        let schoolState = self.selectedTeam!.schoolState
        let cData = [kTrackingTeamIdKey:schoolId, kTrackingSchoolNameKey:schoolName, kTrackingSchoolStateKey:schoolState]
                    
        TrackingManager.trackState(featureName: "school-home", trackingGuid: trackingGuid, cData: cData as Dictionary<String, Any>)
    }
    
    // MARK: - Load Favorite Count Label
    
    private func loadFavoriteCountLabel(_ favoriteCount32: Int32)
    {
        // Unhide the followers label and load it up if the favorite count > 0
        if (favoriteCount32 > 0)
        {
            floatingFollowersLabel.isHidden = false
            
            var favoriteCountString = ""
            if (favoriteCount32 < 1000)
            {
                favoriteCountString = String(favoriteCount32)
            }
            else
            {
                let favoriteCountFloat = Float(favoriteCount32)
                let scaledFavoriteCount = favoriteCountFloat / 1000.0
                let scaledFavoriteCountString = String(format: "%1.2f", scaledFavoriteCount)
                favoriteCountString = String(format: "%@k", scaledFavoriteCountString)
            }
            var title = ""
            if (favoriteCount32 == 1)
            {
                title = String(format: "%@ Follower", favoriteCountString)
            }
            else
            {
                title = String(format: "%@ Followers", favoriteCountString)
            }
            let attributedString = NSMutableAttributedString(string: title)
            
            // Bold
            let range = title.range(of: favoriteCountString)
            let convertedRange = NSRange(range!, in: title)

            attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpBoldFontWith(size: 14), NSAttributedString.Key.foregroundColor: UIColor.mpBlackColor()], range: convertedRange)
            floatingFollowersLabel.attributedText = attributedString
        }
        else
        {
            floatingFollowersLabel.isHidden = true
        }
    }
    
    // MARK: - Get Native Team Home Data
    
    private func getNativeTeamHomeData()
    {
        let schoolId = currentTeam["schoolId"] as! String
        let ssid = currentTeam["sportSeasonId"] as! String
        
        if (teamRefreshControl.isRefreshing == false)
        {
            if (progressOverlay == nil)
            {
                progressOverlay = ProgressHUD()
                progressOverlay.show(animated: false)
            }
        }
        
        NewFeeds.getNativeTeamHome(schoolId: schoolId, ssid: ssid) { result, error in
            
            // Hide the busy indicator if it exists
            DispatchQueue.main.async
            {
                if (self.progressOverlay != nil)
                {
                    self.progressOverlay.hide(animated: false)
                    self.progressOverlay = nil
                }
            }
            
            //Hide the refresh control after a little delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
            {
                self.teamRefreshControl.endRefreshing()
            }
            
            if (error == nil)
            {
                print("Get native teams home success.")
                
                self.schoolColor1 = result!["schoolColor1"] as? String ?? ""
                self.schoolColor2 = result!["schoolColor2"] as? String ?? ""
                self.schoolColor3 = result!["schoolColor3"] as? String ?? ""
                self.schoolMascotName = result!["schoolMascot"] as? String ?? ""
                self.schoolCity = result!["schoolCity"] as? String ?? ""
                self.schoolState = result!["schoolState"] as? String ?? ""
                
                self.contestsArray = result!["contests"] as! Array<Dictionary<String,Any>>
                self.leagueStandingObj = result!["leagueStanding"] as! Dictionary<String,Any>
                self.overallStandingObj = result!["overallStanding"] as! Dictionary<String,Any>
                
                self.liveScoringSignupUrl = result!["liveScoringSignupUrl"] as? String ?? ""
                //self.liveScoringSignupUrl = "https://g.branch.maxpreps.com/m/scores/play_by_play_signup.aspx?schoolid=74c1621c-e0cf-4821-b5e1-3c8170c8125a&ssid=e46d33f9-793e-4697-a968-d0f08f92017c"
                
                self.tournamentName = result!["tournamentName"] as? String ?? ""
                self.tournamentBracketName = result!["tournamentBracketName"] as? String ?? ""
                self.tournamentCanonicalUrl = result!["tournamentCanonicalUrl"] as? String ?? ""
                
                if (result!["leaders"] != nil)
                {
                    // leaders object could be NULL
                    self.leadersObj = result!["leaders"] as? Dictionary<String,Any> ?? [:]
                }
                else
                {
                    self.leadersObj.removeAll()
                }
                
                let favoriteCount = result!["favoriteCount"] as? NSNumber ?? NSNumber.init(integerLiteral: 0)
                let favoriteCount32 = favoriteCount.int32Value
                self.loadFavoriteCountLabel(favoriteCount32)
            }
            else
            {
                print("Get native teams home failed.")
            }
            
            self.homeTableView.isScrollEnabled = true
            self.homeTableView.isHidden = false
            self.homeTableView.reloadData()
            
            /*
            // Disable scrolling if the tableView
            var pbpCellHeight = 0
            if (self.liveScoringSignupUrl.count > 0)
            {
                pbpCellHeight = 92
            }
            
            var playoffCellHeight = 0
            if (self.tournamentCanonicalUrl.count > 0)
            {
                playoffCellHeight = 108
            }
            
            let gameCellHeight = self.contestsArray.count * 205
            
            var groupStatsHeight = 0
            
            if (self.leadersObj["groupStats"] != nil)
            {
                let groupStatsArray = self.leadersObj["groupStats"] as! Array<Dictionary<String,Any>>
                if (groupStatsArray.count > 0)
                {
                    groupStatsHeight = (groupStatsArray.count * 92) + 58 + 44
                }
            }
            
            // This delay is advised because the reload is asynchronous
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
            {
                if ((pbpCellHeight + playoffCellHeight + gameCellHeight + 235 + groupStatsHeight + 104) <= self.tableInitialHeight)
                {
                    self.homeTableView.isScrollEnabled = false
                }
            }
            */
        }
    }
    
    // MARK: - Get User Favorite Teams from Database
    
    private func getUserFavoriteTeamsFromDatabase()
    {
        NewFeeds.getUserFavoriteTeams(completionHandler: { error in
            
            if error == nil
            {
                print("Download user favorite teams success")
            }
            else
            {
                print("Download user favorite teams error")
            }
        })
        
        // Update the locationTracking regions in the app delegate
        //[appDelegate addRegionsForTracking];
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
    
    // MARK: - Save User Favorite
    
    private func saveUserFavoriteTeam(_ favorite: Dictionary<String,Any>)
    {
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.saveUserFavoriteTeam(favorite){ (result, error) in
 
            if error == nil
            {
                // Get the user favorites so the prefs get updated
                NewFeeds.getUserFavoriteTeams(completionHandler: { error in
                    
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
                        self.getUserFavoriteTeamsFromDatabase()
                        
                        OverlayView.showPopupOverlay(withMessage: "Team Saved")
                        { [self] in
                            // Hide the save button and show the date
                            self.showSaveFavoriteButton = false
                            self.showRemoveFavoriteButton = true
                            //self.yearSelectorButton.isHidden = false
                            self.saveFavoriteButton.isHidden = true
                            self.removeFavoriteButton.isHidden = false
                            
                            // Update the selectedTeam.teamId property since it will be 0 when coming from search
                            // Iterate to find the matching team
                            for favorite in result!
                            {
                                //let favorite = item as! Dictionary<String,Any>
                                let schoolId = favorite[kNewSchoolIdKey] as! String
                                let allSeasonId = favorite[kNewAllSeasonIdKey] as! String
                                
                                if ((self.selectedTeam?.schoolId == schoolId) && (self.selectedTeam?.allSeasonId == allSeasonId))
                                {
                                    self.selectedTeam?.teamId = favorite["userFavoriteTeamRefId"] as! Int
                                }
                            }
                        }
                        print("Download user favorites success")
                        
                        // Post a notification that the favorite teams have been updated
                        NotificationCenter.default.post(name: Notification.Name("FavoriteTeamsUpdated"), object: nil)
                    }
                    else
                    {
                        print("Download user favorites error")
                    }
                })
                
                //self.navigationController?.popViewController(animated: true)
            }
            else
            {
                print("Save user favorites error")
                
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
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "There was a server error when following this team.", lastItemCancelType: false) { (tag) in
                    
                }
            }
        }
    }
    
    // MARK: - Get Available Items
    
    private func getAvailbleItems()
    {
        let ssid = currentTeam["sportSeasonId"] as! String
        let schoolId = currentTeam["schoolId"] as! String
        
        filteredItems.removeAll()
        
        //filteredItems.append("Home")
        
        NewFeeds.getAvailableItemsForTeam(ssid, schoolId: schoolId) { (result, error) in
            
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
            
            if error == nil
            {
                /*
                 sportSeasonId
                 teamId
                 hasProPhotos
                 hasTeamRoster
                 maxprepsTeamPreviewModifiedOn
                 hasImportedTeamPreview
                 hasLeagueStandings
                 hasStandings
                 hasRankings
                 hasMaxprepsTeamPreview
                 hasContests
                 hasStats
                 maxprepsTeamPreviewCreatedOn
                 isPrepsSportsEnabled
                 hasVideos
                 hasArticles
                 updatedOn
                 */
                
                // Iterate through the allItems array and only save the available ones in the filteredItems array
                for item in self.allItems
                {
                    switch item
                    {
                    case "Roster":
                        //let value = result?["hasTeamRoster"] as! Bool
                        //if (value == true)
                        //{
                            self.filteredItems.append(item)
                        //}
                    case "Schedule":
                        //let value = result?["hasContests"] as! Bool
                        //if (value == true)
                        //{
                            // Only include the schedule if in the current yesr
                            //if (self.selectedYearIndex == 0)
                            //{
                                self.filteredItems.append(item)
                            //}
                        //}
                    case "Stats":
                        let value = result?["hasStats"] as! Bool
                        if (value == true)
                        {
                            self.filteredItems.append(item)
                        }
                    case "News":
                        let value = result?["hasArticles"] as! Bool
                        if (value == true)
                        {
                            self.filteredItems.append(item)
                        }
                    case "Standings":
                        let hasStandings = result?["hasStandings"] as! Bool
                        //let hasLeagueStandings = result?["hasLeagueStandings"] as! Bool
                        if (hasStandings == true)// && (hasLeagueStandings == true))
                        {
                            self.filteredItems.append(item)
                        }
                    case "Rankings":
                        let value = result?["hasRankings"] as! Bool
                        if (value == true)
                        {
                            self.filteredItems.append(item)
                        }
                    case "Photos":
                        let value = result?["hasProPhotos"] as! Bool
                        if (value == true)
                        {
                            self.filteredItems.append(item)
                        }
                    case "Videos":
                        /*
                        // No upload version
                        let value = result?["hasVideos"] as! Bool
                        if (value == true)
                        {
                            self.filteredItems.append(item)
                        }
                        */
                        
                        /*
                        // Always show the video tab if the user is logged in
                        let userId = kUserDefaults.string(forKey: kUserIdKey)
                        if (userId == kTestDriveUserId)
                        {
                            let value = result?["hasVideos"] as! Bool
                            if (value == true)
                            {
                                self.filteredItems.append(item)
                            }
                        }
                        else
                        {
                            self.filteredItems.append(item)
                        }
                        */
                        self.filteredItems.append(item)
                        
                    case "Shop":
                        let value = result?["isPrepsSportsEnabled"] as! Bool
                        if (value == true)
                        {
                            self.filteredItems.append(item)
                        }
                    default:
                        continue
                    }
                }
            }
            else
            {
                print("Get available items failed")
            }
            
            self.loadItemSelector()
        }
    }
    
    // MARK: - Build Active Tears Array
    
    private func buildActiveYearsArray()
    {
        yearArray.removeAll()
        
        for item in activeTeamsArray
        {
            let year = item["year"] as! String
            yearArray.append(year)
        }
        
        if (activeTeamsArray.count > 0)
        {
            // Added in January to allow the DetailVC to open on a different year
            // If the selectedSSID exists, try to find a match in the activeTeams array to get the selectedYearIndex
            if (self.selectedSSID.count > 0)
            {
                var index = 0
                for item in activeTeamsArray
                {
                    let ssid = item["sportSeasonId"] as! String
                    
                    if (ssid == self.selectedSSID)
                    {
                        selectedYearIndex = index
                        break
                    }
                    
                    index += 1
                }
            }
            
            currentTeam = activeTeamsArray[selectedYearIndex]
            
            // Get the available items
            self.getAvailbleItems()
            
            // Load the browser
            selectedItemIndex = 0
            //self.addNewBrowser()
            
            let year = currentTeam["year"] as! String
            
            yearSelectorButton.setTitle(year, for: .normal)
            
            // Update the year in the header
            statsHeaderView.yearLabel.text = String(format: "20%@ Season", year)
            
            //if (self.showSaveFavoriteButton == false)
            //{
                yearSelectorButton.isHidden = false
            //}
            //else
            //{
                //yearSelectorButton.isHidden = true
            //}
            
            // Build the tracking context data object
            var cData = kEmptyTrackingContextData
            
            let schoolName = self.selectedTeam?.schoolName
            let schoolState = self.selectedTeam?.schoolState
            let schoolId = self.selectedTeam?.schoolId
            let sport = self.selectedTeam?.sport
            let level = self.selectedTeam?.teamLevel
            let gender = self.selectedTeam?.gender
            let season = self.selectedTeam?.season
            
            cData[kTrackingSchoolNameKey] = schoolName
            cData[kTrackingSchoolStateKey] = schoolState
            cData[kTrackingTeamIdKey] = schoolId
            cData[kTrackingSportNameKey] = sport
            cData[kTrackingSportLevelKey] = level
            cData[kTrackingSportGenderKey] = gender
            cData[kTrackingSeasonKey] = season
            cData[kTrackingSchoolYearKey] = year
            cData[kTrackingUserTeamRoleKey] = userTeamRole
            cData[kTrackingFtagKey] = self.ftag
            
            TrackingManager.trackState(featureName: "team-home", trackingGuid: trackingGuid, cData: cData)
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
            
            yearSelectorButton.isHidden = true
            
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "There was an error accessing this teams information.", lastItemCancelType: false) { (tag) in
                
            }
        }
    }

    // MARK: - Get SSID's for Team
    
    private func getSSIDsForTeam(schoolId: String, allSeasonId: String)
    {
        // Show the busy indicator
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        activeTeamsArray.removeAll()
        
        NewFeeds.getSSIDsForTeam(allSeasonId, schoolId: schoolId) { (result, error) in
            
            if error == nil
            {
                // Filter out teams with non-matching seasons
                for team in result!
                {
                    let season = team["season"] as! String
                    let isPublished = team["isPublished"] as! NSNumber
                    
                    if (season == self.selectedTeam?.season)
                    {
                        // Add the team for admins whether it is published or not
                        if (self.userIsAdmin == true)
                        {
                            self.activeTeamsArray.append(team)
                        }
                        else
                        {
                            // Only add the team for regular users if it is published
                            if (isPublished.boolValue == true)
                            {
                                self.activeTeamsArray.append(team)
                            }
                        }
                        
                    }
                }
                
                //self.activeTeamsArray = result!
                
                self.buildActiveYearsArray()
                print("Get SSID's success")
            }
            else
            {
                print("Get SSID's error")
                
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
            }
        }
    }
    
    // MARK: - Load Item Selector
    
    private func loadItemSelector()
    {
        selectedItemIndex = 0
        
        // Remove existing buttons
        let itemScrollViewSubviews = itemScrollView.subviews
        for subview in itemScrollViewSubviews
        {
            subview.removeFromSuperview()
        }
        
        // Remove the shadows from to top view
        let mainSubviews = self.view.subviews
        for subview in mainSubviews
        {
            if (subview.tag == 200) || (subview.tag == 201)
            {
                subview.removeFromSuperview()
            }
        }
        
        var overallWidth = 0
        let pad = 10
        var leftPad = 0
        let rightPad = 10
        var index = 0
        
        for item in filteredItems
        {
            let itemWidth = Int(item.widthOfString(usingFont: UIFont.mpSemiBoldFontWith(size: 13))) + (2 * pad)
            let tag = filteredItems.firstIndex(of: item)! + 100
            
            // Add the left pad to the first cell
            if (index == 0)
            {
                leftPad = 10
            }
            else
            {
                leftPad = 0
            }
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: overallWidth + leftPad, y: 0, width: itemWidth, height: Int(itemScrollView.frame.size.height) - 1)
            button.backgroundColor = .clear
            button.setTitle(item, for: .normal)
            button.tag = tag
            button.addTarget(self, action: #selector(self.itemTouched), for: .touchUpInside)
            button.titleLabel?.font = UIFont.mpRegularFontWith(size: 13)
            button.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
            
            itemScrollView.addSubview(button)
            
            index += 1
            overallWidth += (itemWidth + leftPad)
        }
        
        itemScrollView.contentSize = CGSize(width: overallWidth + rightPad, height: Int(itemScrollView.frame.size.height))
        
        // Add the left and right shadows
        leftShadow = UIImageView(frame: CGRect(x: 0, y: Int(itemScrollView.frame.origin.y), width: 70, height: Int(itemScrollView.frame.size.height)))
        leftShadow.image = UIImage(named: "LeftShadowWhite")
        leftShadow.clipsToBounds = true
        leftShadow.tag = 200
        self.view.addSubview(leftShadow)
        leftShadow.isHidden = true
        
        rightShadow = UIImageView(frame: CGRect(x: Int(kDeviceWidth) - 70, y: Int(itemScrollView.frame.origin.y), width: 70, height: Int(itemScrollView.frame.size.height)))
        rightShadow.image = UIImage(named: "RightShadowWhite")
        rightShadow.clipsToBounds = true
        rightShadow.tag = 201
        self.view.addSubview(rightShadow)
        
        if (itemScrollView.contentSize.width <= itemScrollView.frame.size.width)
        {
            rightShadow.isHidden = true
        }
        
        // Get the homeTableView data
        self.getNativeTeamHomeData()
    }
    
    // MARK: - Logout User
    
    private func logoutUser()
    {
        // Clear out the user's prefs
        MiscHelper.logoutUser()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            // Show the login landing page from the tabBarController
            let tabBarController = self.tabBarController as! TabBarController
            tabBarController.selectedIndex = 0
            tabBarController.showLoginHomeVC()
            
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section == 1)
        {
            return 2
        }
        else if (section == 0)
        {
            return self.contestsArray.count
        }
        else if (section == 2)
        {
            return 1
        }
        else if (section == 3)
        {
            if (self.leadersObj["groupStats"] != nil)
            {
                let groupStatsArray = self.leadersObj["groupStats"] as! Array<Dictionary<String,Any>>
                return groupStatsArray.count
            }
            else
            {
                return 0
            }
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (indexPath.section == 1)
        {
            if (indexPath.row == 0)
            {
                if (self.liveScoringSignupUrl.count > 0)
                {
                    return 92
                }
                else
                {
                    return 0
                }
            }
            else
            {
                if (self.tournamentCanonicalUrl.count > 0)
                {
                    return 108
                }
                else
                {
                    return 0
                }
            }
        }
        else if (indexPath.section == 0)
        {
            return 205
        }
        else if (indexPath.section == 2)
        {
            return 235
        }
        else if (indexPath.section == 3)
        {
            return 92
        }
        else
        {
            return 104
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if (section == 1)
        {
            return 0.01
        }
        else if (section == 0)
        {
            if (self.contestsArray.count > 0)
            {
                return 8
            }
            else
            {
                return 0.01
            }
        }
        else if (section == 2)
        {
            return 8
        }
        else if (section == 3)
        {
            if (self.leadersObj["groupStats"] != nil)
            {
                let groupStatsArray = self.leadersObj["groupStats"] as! Array<Dictionary<String,Any>>
                if (groupStatsArray.count > 0)
                {
                    return statsHeaderView.frame.size.height
                }
                else
                {
                    return 0.01
                }
            }
            else
            {
                return 0.01
            }
        }
        else
        {
            return 8.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (section == 3)
        {
            if (self.leadersObj["groupStats"] != nil)
            {
                let groupStatsArray = self.leadersObj["groupStats"] as! Array<Dictionary<String,Any>>
                if (groupStatsArray.count > 0)
                {
                    return statsFooterView.frame.size.height
                }
                else
                {
                    return 0.01
                }
            }
            else
            {
                return 0.01
            }
        }
        else if (section == 4)
        {
            // Add pad to the bottom of the table to allow for full scrolling
            var pbpCellHeight = 0
            if (self.liveScoringSignupUrl.count > 0)
            {
                pbpCellHeight = 92
            }
            
            var playoffCellHeight = 0
            if (self.tournamentCanonicalUrl.count > 0)
            {
                playoffCellHeight = 108
            }
            
            let gameCellHeight = self.contestsArray.count * 213
            var groupStatsHeight = 0
            
            if (self.leadersObj["groupStats"] != nil)
            {
                let groupStatsArray = self.leadersObj["groupStats"] as! Array<Dictionary<String,Any>>
                groupStatsHeight = (groupStatsArray.count * 92) + 58 + 44
            }
            
            if ((pbpCellHeight + playoffCellHeight + gameCellHeight + 235 + groupStatsHeight + 104) > (self.tableInitialHeight + 450))
            {
                return 62 // Ad pad
            }
            else
            {
                return CGFloat((self.tableInitialHeight + 450) - (pbpCellHeight + playoffCellHeight + gameCellHeight + 235 + groupStatsHeight + 104) + 62) // Ad pad
            }
        }
        else
        {
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (section == 3)
        {
            if (self.leadersObj["groupStats"] != nil)
            {
                let groupStatsArray = self.leadersObj["groupStats"] as! Array<Dictionary<String,Any>>
                if (groupStatsArray.count > 0)
                {
                    return statsHeaderView
                }
                else
                {
                    return nil
                }
            }
            else
            {
                return nil
            }
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        if (section == 3)
        {
            if (self.leadersObj["groupStats"] != nil)
            {
                let groupStatsArray = self.leadersObj["groupStats"] as! Array<Dictionary<String,Any>>
                if (groupStatsArray.count > 0)
                {
                    return statsFooterView
                }
                else
                {
                    return nil
                }
            }
            else
            {
                return nil
            }
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (indexPath.section == 1)
        {
            if (indexPath.row == 0)
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "TeamHomePBPTableViewCell") as? TeamHomePBPTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("TeamHomePBPTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? TeamHomePBPTableViewCell
                }
                
                cell?.selectionStyle = .none
                
                // Set the colors
                let schoolColorString = self.selectedTeam?.teamColor
                let schoolColor = ColorHelper.color(fromHexString: schoolColorString, colorCorrection: true)!
                cell?.imageContainerView.backgroundColor = schoolColor
                
                return cell!
            }
            else
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "TeamHomePlayoffTableViewCell") as? TeamHomePlayoffTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("TeamHomePlayoffTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? TeamHomePlayoffTableViewCell
                }
                
                cell?.selectionStyle = .none
                
                cell?.loadData(title: self.tournamentName, subtitle: self.tournamentBracketName)
                
                return cell!
            }
        }
        else if (indexPath.section == 0)
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "TeamHomeGameTableViewCell") as? TeamHomeGameTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("TeamHomeGameTableViewCell", owner: self, options: nil)
                cell = nib![0] as? TeamHomeGameTableViewCell
            }
            
            cell?.selectionStyle = .none
            
            let contest = self.contestsArray[indexPath.row]
            cell?.loadData(contest, mySchoolId: self.selectedTeam!.schoolId)
            
            cell?.previewBoxscoreButton.tag = 100 + indexPath.row
            cell?.previewBoxscoreButton.addTarget(self, action: #selector(contestButtonTouched(_:)), for: .touchUpInside)
            
            cell?.largeContestButton.tag = 100 + indexPath.row
            cell?.largeContestButton.addTarget(self, action: #selector(contestButtonTouched(_:)), for: .touchUpInside)
            
            return cell!
        }
        else if (indexPath.section == 2)
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "TeamHomeStandingsTableViewCell") as? TeamHomeStandingsTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("TeamHomeStandingsTableViewCell", owner: self, options: nil)
                cell = nib![0] as? TeamHomeStandingsTableViewCell
            }
            
            cell?.selectionStyle = .none
            
            cell?.loadData(overall: overallStandingObj, league: leagueStandingObj)
            
            cell?.seasonLabel.text = ""
            
            // Update the year in the cell
            if (yearArray.count > 0)
            {
                let year = yearArray[selectedYearIndex]                
                cell?.seasonLabel.text = String(format: "20%@ Season", year)
            }
            
            cell?.leagueStandingButton.addTarget(self, action: #selector(leagueButtonTouched), for: .touchUpInside)
            
            return cell!
        }
        else if (indexPath.section == 3)
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "TeamHomeStatsTableViewCell") as? TeamHomeStatsTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("TeamHomeStatsTableViewCell", owner: self, options: nil)
                cell = nib![0] as? TeamHomeStatsTableViewCell
            }
            
            cell?.selectionStyle = .none
            cell?.horizLine.isHidden = false
            
            if (self.leadersObj["groupStats"] != nil)
            {
                let groupStatsArray = self.leadersObj["groupStats"] as! Array<Dictionary<String,Any>>
                
                if ((groupStatsArray.count - 1) == indexPath.row)
                {
                    cell?.horizLine.isHidden = true
                }
                
                let statObj = groupStatsArray[indexPath.row]
                cell?.loadData(statObj)
            }
            
            return cell!
        }
        else
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "TeamHomeSchoolInfoTableViewCell") as? TeamHomeSchoolInfoTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("TeamHomeSchoolInfoTableViewCell", owner: self, options: nil)
                cell = nib![0] as? TeamHomeSchoolInfoTableViewCell
            }
            
            cell?.selectionStyle = .none
            
            cell?.loadData(color1: self.schoolColor1, color2: self.schoolColor2, color3: self.schoolColor3, schoolCity: self.schoolCity, schoolState: self.schoolState, mascotName: self.schoolMascotName)
            
            cell?.locationButton.addTarget(self, action: #selector(locationButtonTouched), for: .touchUpInside)
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.section == 1)
        {
            if (indexPath.row == 0)
            {
                //print(self.liveScoringSignupUrl)
                self.showGenericWebViewController(urlString: self.liveScoringSignupUrl, title: "Live Scoring", contestId: "")
            }
            else
            {
                self.showGenericWebViewController(urlString: self.tournamentCanonicalUrl, title: "Playoffs", contestId: "")
            }
        }
        else if (indexPath.section == 3)
        {
            if (self.leadersObj["groupStats"] != nil)
            {
                let groupStatsArray = self.leadersObj["groupStats"] as! Array<Dictionary<String,Any>>
                
                let statObj = groupStatsArray[indexPath.row]
                let athletes = statObj["athletes"] as! Array<Dictionary<String,Any>>
                
                // Temporary
                if (athletes.count == 0)
                {
                    return
                }
                let athlete = athletes[0]
                
                let firstName = athlete["athleteFirstName"] as? String ?? ""
                let lastName = athlete["athleteLastName"] as? String ?? ""
                let careerProfileId = athlete["careerId"] as! String
                let schoolName = athlete["schoolName"] as! String
                let schoolState = athlete["schoolState"] as! String
                let schoolCity = athlete["schoolCity"] as! String
                let schoolId = athlete["teamId"] as! String
                let schoolColor = athlete["schoolColor1"] as! String
                let schoolMascotUrl = athlete["schoolMascotUrl"] as! String
                let photoUrl = athlete["athletePhotoUrl"] as! String
                
                let selectedAthlete = Athlete(firstName: firstName, lastName: lastName, schoolName: schoolName, schoolState: schoolState, schoolCity: schoolCity, schoolId: schoolId, schoolColor: schoolColor, schoolMascotUrl: schoolMascotUrl, careerId: careerProfileId, photoUrl: photoUrl)
                
                athleteDetailVC = NewAthleteDetailViewController(nibName: "NewAthleteDetailViewController", bundle: nil)
                athleteDetailVC.selectedAthlete = selectedAthlete
                
                // Check to see if the athlete is already a favorite
                let isFavorite = MiscHelper.isAthleteMyFavoriteAthlete(careerId: careerProfileId)
                
                var showSaveFavoriteButton = false
                var showRemoveFavoriteButton = false
                
                if (isFavorite == true)
                {
                    showSaveFavoriteButton = false
                    showRemoveFavoriteButton = true
                }
                else
                {
                    showSaveFavoriteButton = true
                    showRemoveFavoriteButton = false
                }
                
                athleteDetailVC.showSaveFavoriteButton = showSaveFavoriteButton
                athleteDetailVC.showRemoveFavoriteButton = showRemoveFavoriteButton
                /*
                athleteDetailVC.showSaveFavoriteButton = false
                
                if (kUserDefaults.object(forKey: kUserIdKey) as! String == kTestDriveUserId)
                {
                    athleteDetailVC.showRemoveFavoriteButton = false
                }
                else
                {
                    athleteDetailVC.showRemoveFavoriteButton = true
                }
                */
                self.navigationController?.pushViewController(athleteDetailVC, animated: true)
                
                /*
                 ▿ 6 elements
                   ▿ 0 : 2 elements
                     - key : "fullStatLeadersUrl"
                     - value : https://www.maxpreps.com/high-schools/de-la-salle-spartans-(concord,ca)/football-21/stats.htm
                   ▿ 1 : 2 elements
                     - key : "athletes"
                     ▿ value : 1 element
                       ▿ 0 : 20 elements
                         ▿ 0 : 2 elements
                           - key : schoolState
                           - value : CA
                         ▿ 1 : 2 elements
                           - key : sportSeasonId
                           - value : 97e3f828-856d-419e-b94f-7f41319fe3d3
                         ▿ 2 : 2 elements
                           - key : athleteFirstName
                           - value : Charles
                         ▿ 3 : 2 elements
                           - key : athleteGrade
                           - value : Junior
                         ▿ 4 : 2 elements
                           - key : schoolMascotUrl
                           - value : https://dw3jhbqsbya58.cloudfront.net/fit-in/1024x1024/school-mascot/c/5/1/c510b298-3a73-4bcf-8855-96c998d8e26e.gif?version=634129029600000000
                         ▿ 5 : 2 elements
                           - key : schoolColor1
                           - value : 00824B
                         ▿ 6 : 2 elements
                           - key : schoolName
                           - value : De La Salle
                         ▿ 7 : 2 elements
                           - key : schoolCity
                           - value : Concord
                         ▿ 8 : 2 elements
                           - key : athletePosition2
                           - value : DB
                         ▿ 9 : 2 elements
                           - key : rowNumber
                           - value : 1
                         ▿ 10 : 2 elements
                           - key : athleteLastName
                           - value : Greer
                         ▿ 11 : 2 elements
                           - key : schoolFormattedName
                           - value : De La Salle (Concord, CA)
                         ▿ 12 : 2 elements
                           - key : careerId
                           - value : 32074160-c702-ea11-80ce-a444a33a3a97
                         ▿ 13 : 2 elements
                           - key : schoolNameAcronym
                           - value : DLSHS
                         ▿ 14 : 2 elements
                           - key : teamId
                           - value : c510b298-3a73-4bcf-8855-96c998d8e26e
                         ▿ 15 : 2 elements
                           - key : stats
                           ▿ value : 1 element
                             ▿ 0 : 5 elements
                               ▿ 0 : 2 elements
                                 - key : value
                                 - value : 103.4
                               ▿ 1 : 2 elements
                                 - key : displayName
                                 - value : Rushing Yards Per Game
                               ▿ 2 : 2 elements
                                 - key : name
                                 - value : RushingYardsPerGame
                               ▿ 3 : 2 elements
                                 - key : header
                                 - value : Y/G
                               ▿ 4 : 2 elements
                                 - key : field
                                 - value : s60
                         ▿ 16 : 2 elements
                           - key : athleteId
                           - value : 3a3a029c-b7bb-482a-8188-86db71ec52cc
                         ▿ 17 : 2 elements
                           - key : athletePhotoUrl
                           - value :
                         ▿ 18 : 2 elements
                           - key : athletePosition3
                           - value :
                         ▿ 19 : 2 elements
                           - key : athletePosition1
                           - value : RB
                   ▿ 2 : 2 elements
                     - key : "subGroup"
                     - value :
                   ▿ 3 : 2 elements
                     - key : "statName"
                     - value : RushingYardsPerGame
                   ▿ 4 : 2 elements
                     - key : "group"
                     - value :
                   ▿ 5 : 2 elements
                     - key : "statDisplayName"
                     - value : Rushing Yards Per Game
                 */

            }
        }
        else if (indexPath.section == 4)
        {
            self.showTeamSelectorViewController()
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func yearSelectorButtonTouched(_ sender: UIButton)
    {
        let picker = IQActionSheetPickerView(title: "Select Year", delegate: self)
        picker.toolbarButtonColor = UIColor.mpWhiteColor()
        picker.toolbarTintColor = UIColor.mpPickerToolbarColor() //currentTeamColor
        picker.titlesForComponents = [yearArray]
        picker.show()
    }
    
    @IBAction func saveFavoriteButtonTouched(_ sender: UIButton)
    {
        var favorites = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
        
        if (favorites != nil) && (favorites!.count >= kMaxFavoriteTeamsCount)
        {
            let messageTitle = String(kMaxFavoriteTeamsCount) + " Team Limit"
            let messageText = "The maximum number of teams you can follow is " + String(kMaxFavoriteTeamsCount) + ".  You must unfollow a team in order to add another."
            
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: messageTitle, message: messageText, lastItemCancelType: false) { (tag) in
                
            }
            return
        }
        
        MiscHelper.showAlert(in: self, withActionNames: ["Cancel", "Follow"], title: "Follow Team", message: "Do you want to follow this team?", lastItemCancelType: false) { (tag) in
            if (tag == 1)
            {
                let gender = self.selectedTeam?.gender
                let sport = self.selectedTeam?.sport
                let teamLevel = self.selectedTeam?.teamLevel
                let season = self.selectedTeam?.season
                let schoolId = self.selectedTeam?.schoolId
                let schoolName = self.selectedTeam?.schoolName
                let schoolFullName = self.selectedTeam?.schoolFullName
                let schoolState = self.selectedTeam?.schoolState
                let schoolCity = self.selectedTeam?.schoolCity
                let allSeasonId = self.selectedTeam?.allSeasonId
                let teamColor = self.selectedTeam?.teamColor
                let mascotUrl = self.selectedTeam?.mascotUrl
                
                // Update the selectedTeam
                let newFavorite = [kNewGenderKey:gender!, kNewSportKey:sport!, kNewLevelKey:teamLevel!, kNewSeasonKey:season!, kNewSchoolIdKey:schoolId!, kNewSchoolNameKey:schoolName!, kNewSchoolFormattedNameKey:schoolFullName!, kNewSchoolStateKey:schoolState!, kNewSchoolCityKey:schoolCity!, kNewSchoolInfoColor1Key:teamColor!, kNewSchoolMascotUrlKey:mascotUrl!, kNewUserfavoriteTeamIdKey:0, kNewAllSeasonIdKey:allSeasonId!, kNewNotificationSettingsKey:[]] as [String : Any]
                
                // Update prefs
                favorites!.append(newFavorite)
                
                kUserDefaults.set(favorites, forKey: kNewUserFavoriteTeamsArrayKey)
                
                // Update the SchoolInfo dictionary in prefs so the school list stays current
                self.getNewSchoolInfo(favorites!)
                
                // Update the DB
                self.saveUserFavoriteTeam(newFavorite)
                
                // Click Tracking
                let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"team-unfollow-button-click", kClickTrackingModuleNameKey: "user preferences", kClickTrackingModuleLocationKey:"unfollow team prompt", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:""]
                
                TrackingManager.trackEvent(featureName: "team-follow/unfollow", cData: cData)
            }
        }
    }
    
    @IBAction func removeFavoriteButtonTouched(_ sender: UIButton)
    {
        MiscHelper.showAlert(in: self, withActionNames: ["Cancel", "Unfollow"], title: "Unfollow Team", message: "Do you want to unfollow this team?", lastItemCancelType: false) { (tag) in
            if (tag == 1)
            {
                let teamId = self.selectedTeam?.teamId
                let team = [kNewUserfavoriteTeamIdKey: teamId!]
                
                NewFeeds.deleteUserFavoriteTeam(favorite: team) { (error) in
                    
                    if error == nil
                    {
                        OverlayView.showPopupOverlay(withMessage: "Team Unfollowed")
                        {
                            // Hide the save button and show the date
                            self.showSaveFavoriteButton = true
                            self.showRemoveFavoriteButton = false
                            self.saveFavoriteButton.isHidden = false
                            self.removeFavoriteButton.isHidden = true
                            
                            // Update the favorites saved in prefs
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
                            {
                                self.getUserFavoriteTeamsFromDatabase()
                            }
                            
                            // Post a notification that the favorite teams have been updated
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0)
                            {
                                NotificationCenter.default.post(name: Notification.Name("FavoriteTeamsUpdated"), object: nil)
                            }
                        }
        
                        print("Delete user favorites success")
   
                        // Click Tracking
                        let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"team-follow-button-click", kClickTrackingModuleNameKey: "user preferences", kClickTrackingModuleLocationKey:"follow team prompt", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:""]
                        
                        TrackingManager.trackEvent(featureName: "team-follow/unfollow", cData: cData)
                    }
                    else
                    {
                        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "There was a server problem when unfollowing this team.", lastItemCancelType: false) { (tag) in
                            
                        }
                    }
                }
            }
        }
    }
    
    @objc private func itemTouched(_ sender: UIButton)
    {
        selectedItemIndex = sender.tag - 100

        if (sender.titleLabel?.text == "Roster")
        {
            self.showRosterViewController()
        }
        else if (sender.titleLabel?.text == "Schedule")
        {
            let isCoreSport = MiscHelper.isCoreSport(selectedTeam!.sport)
            if (isCoreSport == true)
            {
                self.showScheduleViewController()
            }
            else
            {
                self.showDetailWebViewController((sender.titleLabel?.text)!)
            }
        }
        else if (sender.titleLabel?.text == "Videos")
        {
            self.showTeamVideoViewController()
        }
        else
        {
            self.showDetailWebViewController((sender.titleLabel?.text)!)
        }
    }
    
    @IBAction func schoolButtonTouched(_ sender: UIButton)
    {
        self.showTeamSelectorViewController()
    }
    
    @IBAction func editMascotButtonTouched(_ sender: UIButton)
    {
        
    }
    
    @objc private func fullStatsButtonTouched()
    {
        if (self.leadersObj["groupStats"] != nil)
        {
            let groupStatsArray = self.leadersObj["groupStats"] as! Array<Dictionary<String,Any>>
            
            let statsObj = groupStatsArray[0]
            let urlString = statsObj["fullStatLeadersUrl"] as! String
            
            self.showGenericWebViewController(urlString: urlString, title: "Full Stats", contestId: "")
        }
    }
    
    @objc private func locationButtonTouched()
    {
        var latitude = "0.0"
        var longitude = "0.0"
        var schoolName = ""
        
        // Search through the local database to find the school location
        let schoolId = selectedTeam?.schoolId
        
        // Iterate through the allSchools to find a matching schoolId
        for school in SharedData.allSchools
        {
            if (schoolId == school.schoolId)
            {
                // Match is found
                latitude = school.latitude
                longitude = school.longitude
                schoolName = school.name
                break
            }
        }
        
        if (schoolName == "")
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "We could not find this school's location in our database.", lastItemCancelType: false) { (tag) in
            }
            
            return
        }
        
        // Build the click tracking context data object
        let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"maps-button-click", kClickTrackingModuleNameKey: "maps", kClickTrackingModuleLocationKey:"team home", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:""]

        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!))
        {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let selectAppleAction = UIAlertAction(title: "Open Apple Maps", style: .default, handler: { [self] action in
                
                alert.dismiss(animated: true) { [self] in
                    
                    let lat = Double(latitude)!
                    let long = Double(longitude)!
                    
                    self.showSystemMap(latitude: lat, longitude: long, name: schoolName)
                    
                    TrackingManager.trackEvent(featureName: "maps", cData: cData)
                }
            })
            
            let selectGoogleAction = UIAlertAction(title: "Open Google Maps", style: .default, handler: { action in
                
                alert.dismiss(animated: true) {
                    
                    let url = String(format: "comgooglemaps://?center=%@,%@&zoom=14&views=traffic", latitude, longitude)
                    
                    UIApplication.shared.open(URL(string:url)!, options: [:], completionHandler: nil)
                    
                    TrackingManager.trackEvent(featureName: "maps", cData: cData)
                }
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { action in
                
            })
            
            alert.addAction(selectAppleAction)
            alert.addAction(selectGoogleAction)
            alert.addAction(cancelAction)
            
            alert.modalPresentationStyle = .fullScreen
            present(alert, animated: true)
            
            /*
            MiscHelper.showActionSheet(in: self, withActionNames: ["Apple Maps", "Google Maps", "Cancel"], title: "", message: "Select Map Application") { tag in
                
                if (tag == 0)
                {
                    let lat = Double(latitude)!
                    let long = Double(longitude)!
                    
                    self.showSystemMap(latitude: lat, longitude: long, name: schoolName)
                }
                else if (tag == 1)
                {
                    let url = String(format: "comgooglemaps://?center=%@,%@&zoom=14&views=traffic", latitude, longitude)
                    
                    UIApplication.shared.open(URL(string:url)!, options: [:], completionHandler: nil)
                }
            }
            */
        }
        else
        {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let selectAction = UIAlertAction(title: "Open Apple Maps", style: .default, handler: { [self] action in
                
                alert.dismiss(animated: true) { [self] in
                    
                    let lat = Double(latitude)!
                    let long = Double(longitude)!
                    
                    self.showSystemMap(latitude: lat, longitude: long, name: schoolName)
                    
                    TrackingManager.trackEvent(featureName: "maps", cData: cData)
                }
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { action in
                
            })
            
            alert.addAction(selectAction)
            alert.addAction(cancelAction)
            
            alert.modalPresentationStyle = .fullScreen
            present(alert, animated: true)
            
        }
    }
    
    @objc private func leagueButtonTouched()
    {
        print("League Touched")
        let urlString = leagueStandingObj["canonicalUrl"] as? String ?? ""
        
        if (urlString.count > 0)
        {
            self.showGenericWebViewController(urlString: urlString, title: "League Standings", contestId: "")
        }
    }
    
    @objc private func contestButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let contest = self.contestsArray[index]
        let calculatedFields = contest["calculatedFields"] as! Dictionary<String,Any>
        let urlString = calculatedFields["canonicalUrl"] as? String ?? ""
        let reportScoreUrl =  contest["reportScoreUrl"] as? String ?? ""
        let contestState = calculatedFields["contestState"] as! Int
        let contestId =  contest["contestId"] as? String ?? ""
        
        if (contestState == 2) // Pregame
        {
            if (urlString.count > 0)
            {
                self.showGenericWebViewController(urlString: urlString, title: "Preview", contestId: "")
            }
        }
        else if ((contestState == 3) || (contestState == 4)) // Live or Final
        {
            if (urlString.count > 0)
            {
                self.showGenericWebViewController(urlString: urlString, title: "Box Score", contestId: contestId)
            }
        }
        else if (contestState == 5) // No score
        {
            if (reportScoreUrl.count > 0)
            {
                self.showGenericWebViewController(urlString: reportScoreUrl, title: "Report Score", contestId: "")
            }
            else
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "We couldn't find this contest.", lastItemCancelType: false) { (tag) in
                }
            }
        }
    }
    
    // MARK: - Amazon Banner Ad Methods
    
    private func requestAmazonBannerAd()
    {
        let adSize = DTBAdSize(bannerAdSizeWithWidth: 320, height: 50, andSlotUUID: kAmazonBannerAdSlotUUID)
        let adLoader = DTBAdLoader()
        adLoader.setAdSizes([adSize!])
        adLoader.loadAd(self)
    }
    
    func onSuccess(_ adResponse: DTBAdResponse!)
    {
        var adResponseDictionary = adResponse.customTargeting()
        
        adResponseDictionary!.updateValue(trackingGuid, forKey: "vguid")
        
        let ccpaString = kUserDefaults.string(forKey: "IABUSPrivacy_String") ?? ""
        adResponseDictionary!.updateValue(ccpaString, forKey: "us_privacy")
        
        // To be added in V6.2.8
        if (MiscHelper.isUserMinorAged() == true)
        {
            adResponseDictionary!.updateValue("1", forKey: "tfcd")
        }
        
        print("Received Amazon Banner Ad")
        
        let request = GAMRequest()
        request.customTargeting = adResponseDictionary
        /*
        // Add a location
        let location = ZipCodeHelper.locationForAd() as! Dictionary<String, String>
        let latitudeValue = Float(location[kLatitudeKey]!)
        let longitudeValue = Float(location[kLongitudeKey]!)
        
        if ((latitudeValue != 0) && (longitudeValue != 0))
        {
            request.setLocationWithLatitude(CGFloat(latitudeValue!), longitude: CGFloat(longitudeValue!), accuracy: 30)
        }
        */
        if (googleBannerAdView != nil)
        {
            googleBannerAdView.load(request)
        }
    }
    
    func onFailure(_ error: DTBAdError)
    {
        print("Amazon Banner Ad Failed")
        
        let request = GAMRequest()
        
        var customTargetDictionary = [:] as Dictionary<String, String>
        let idfaString = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        customTargetDictionary.updateValue(trackingGuid, forKey: "vguid")
        customTargetDictionary.updateValue(idfaString, forKey: "idtype")
        
        // Get the ATT type string to add to the custonTargetDictionary
        let trackingString = MiscHelper.trackingStatusForAds()
        customTargetDictionary.updateValue(trackingString, forKey: "attmas")
        
        let ccpaString = kUserDefaults.string(forKey: "IABUSPrivacy_String") ?? ""
        customTargetDictionary.updateValue(ccpaString, forKey: "us_privacy")
        
        // To be added in V6.2.8
        if (MiscHelper.isUserMinorAged() == true)
        {
            customTargetDictionary.updateValue("1", forKey: "tfcd")
        }
        
        request.customTargeting = customTargetDictionary
        /*
        // Add a location
        let location = ZipCodeHelper.locationForAd() as! Dictionary<String, String>
        let latitudeValue = Float(location[kLatitudeKey]!)
        let longitudeValue = Float(location[kLongitudeKey]!)
        
        if ((latitudeValue != 0) && (longitudeValue != 0))
        {
            request.setLocationWithLatitude(CGFloat(latitudeValue!), longitude: CGFloat(longitudeValue!), accuracy: 30)
        }
        */
        /*
        // Add MoPub
        let extras = GADMoPubNetworkExtras()
        extras.privacyIconSize = 20
        request.register(extras)
        */
        
        if (googleBannerAdView != nil)
        {
            googleBannerAdView.load(request)
        }
    }
    
    // MARK: - Google Ad Methods
    
    private func loadBannerViews()
    {
        // Removed for Nimbus
        /*
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
        */
        
        self.clearBannerAd()
        
        // Removed for Nimbus
        // Add a timer to request a new ad after 15 seconds
        //tickTimer = Timer.scheduledTimer(timeInterval: TimeInterval(kGoogleAdTimerValue), target: self, selector: #selector(adTimerExpired), userInfo: nil, repeats: true)
        
        //GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["ab075279b6aba4510e894e3563b029dc"]
        let adId = kUserDefaults.value(forKey: kTeamsBannerAdIdKey) as! String
        print("AdId: ", adId)
        
        googleBannerAdView = GAMBannerView(adSize: GADAdSizeBanner, origin: CGPoint(x: (kDeviceWidth - GADAdSizeBanner.size.width) / 2.0, y: 6.0))
        googleBannerAdView.delegate = self
        googleBannerAdView.adUnitID = adId
        googleBannerAdView.rootViewController = self
        
        // Removed for Nimbus
        //self.requestAmazonBannerAd()
        
        // Added for Nimbus
        // Starts a task to refresh every 30 seconds with proper foreground/background notifications
        //dynamicPriceManager.autoRefresh { [weak self] request in
        dynamicPriceManager.autoRefresh { request in
            
            request.customTargeting?.updateValue(self.trackingGuid, forKey: "vguid")
            
            // Get the ATT type string to add to the customTargetDictionary
            let trackingString = MiscHelper.trackingStatusForAds()
            request.customTargeting?.updateValue(trackingString, forKey: "attmas")
            
            let ccpaString = kUserDefaults.string(forKey: "IABUSPrivacy_String") ?? ""
            request.customTargeting?.updateValue(ccpaString, forKey: "us_privacy")
            
            let idfaString = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            request.customTargeting?.updateValue(idfaString, forKey: "idtype")
            
            let abTestString = MiscHelper.userABTestValue()
            if (abTestString != "")
            {
                request.customTargeting?.updateValue(abTestString, forKey: "test")
            }
            
            // To be added in V6.2.8
            if (MiscHelper.isUserMinorAged() == true)
            {
                request.customTargeting?.updateValue("1", forKey: "tfcd")
            }
            
            if (self.googleBannerAdView != nil)
            {
                self.googleBannerAdView.load(request)
            }
        }
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView)
    {
        print("Received Google Banner Ad")
        
        /* // MoPub is disabled
        if (bannerView.responseInfo?.adNetworkClassName != "GADMAdapterGoogleAdMobAds")
        {
            print("MoPub Ad Served")
         if (kUserDefaults.bool(forKey: kDebugDialogsKey) == true)
            {
                tickTimer.invalidate()
                tickTimer = nil
                
                MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "MoPub Ad", message: "", lastItemCancelType: false) { tag in
                    
                }
            }
        }
        */
        
        // Added for Nimbus
        if (bannerBackgroundView != nil)
        {
            bannerBackgroundView.removeFromSuperview()
            bannerBackgroundView = nil
        }
        
        // Delay added for Nimbus
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
        {
            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            self.bannerBackgroundView = UIVisualEffectView(effect: blurEffect)
            self.bannerBackgroundView.frame = CGRect(x: 0, y: Int(kDeviceHeight) - kTabBarHeight - SharedData.bottomSafeAreaHeight - Int(GADAdSizeBanner.size.height) - 12, width: Int(kDeviceWidth), height: Int(GADAdSizeBanner.size.height) + 12)
            
            // Add the background to the view and the banner ad to the background
            self.view.addSubview(self.bannerBackgroundView)
            self.bannerBackgroundView.contentView.addSubview(bannerView)
            
            // Move it down so it is hidden
            self.bannerBackgroundView.transform = CGAffineTransform(translationX: 0, y: self.bannerBackgroundView.frame.size.height + 5)
            
            // Animate the ad up
            UIView.animate(withDuration: 0.25, animations: {
                self.bannerBackgroundView.transform = CGAffineTransform(translationX: 0, y: 0)
                
            })
            { (finished) in
                
            }
        }
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error)
    {
        print("Google Banner Ad Failed")
        
        // Added for Nimbus
        if (bannerBackgroundView != nil)
        {
            bannerBackgroundView.removeFromSuperview()
            bannerBackgroundView = nil
        }
    }
    
    private func clearBannerAd()
    {
        // Added for Nimbus
        dynamicPriceManager.cancelRefresh()
        
        if (googleBannerAdView != nil)
        {
            googleBannerAdView.removeFromSuperview()
            googleBannerAdView = nil
            
            if (bannerBackgroundView != nil)
            {
                bannerBackgroundView.removeFromSuperview()
                bannerBackgroundView = nil
            }
        }
    }

    // MARK: - Ad Timer
    
    @objc private func adTimerExpired()
    {
        self.loadBannerViews()
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if (scrollView == itemScrollView)
        {
            let xScroll = scrollView.contentOffset.x
            
            if (xScroll > 0)
            {
                leftShadow.isHidden = false
            }
            else
            {
                leftShadow.isHidden = true
            }
            
            if (xScroll >= scrollView.contentSize.width - scrollView.frame.size.width)
            {
                rightShadow.isHidden = true
            }
            else
            {
                rightShadow.isHidden = false
            }
        }
        
        if (scrollView == homeTableView)
        {
            let yScroll = Int(scrollView.contentOffset.y)
            
            if (yScroll <= 0)
            {
                floatingContainerView.transform = CGAffineTransform.identity
                itemScrollView.transform = CGAffineTransform.identity
                leftShadow.transform = CGAffineTransform.identity
                rightShadow.transform = CGAffineTransform.identity
                horizLine.transform = CGAffineTransform.identity
                saveFavoriteButton.transform = CGAffineTransform.identity
                removeFavoriteButton.transform = CGAffineTransform.identity
                teamSelectorButton.transform = CGAffineTransform.identity
                
                //browserView.updateFrame(CGRect(x: 0, y: Int(itemScrollView.frame.origin.y) + Int(itemScrollView.frame.size.height), width: Int(kDeviceWidth), height: tableInitialHeight))
                homeTableView.frame = CGRect(x: 0, y: Int(itemScrollView.frame.origin.y) + Int(itemScrollView.frame.size.height), width: Int(kDeviceWidth), height: tableInitialHeight)
                
                titleLabel.alpha = 0
                subtitleLabel.alpha = 0
                floatingContainerView.alpha = 1
                saveFavoriteButton.alpha = 1
                removeFavoriteButton.alpha = 1
                teamSelectorButton.alpha = 1
                floatingContainerView.isHidden = false
            }
            else if ((yScroll > 0) && (yScroll < Int(floatingContainerView.frame.size.height - itemScrollView.frame.size.height - 12)))
            {
                floatingContainerView.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
                itemScrollView.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
                leftShadow.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
                rightShadow.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
                horizLine.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
                saveFavoriteButton.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
                removeFavoriteButton.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
                teamSelectorButton.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
                
                //browserView.updateFrame(CGRect(x: 0, y: Int(itemScrollView.frame.origin.y) + Int(itemScrollView.frame.size.height), width: Int(kDeviceWidth), height: tableInitialHeight + yScroll))
                
                homeTableView.frame = CGRect(x: 0, y: Int(itemScrollView.frame.origin.y) + Int(itemScrollView.frame.size.height), width: Int(kDeviceWidth), height: tableInitialHeight + yScroll)
                
                // Fade the bottom text at double the scroll rate
                let bottomFadeOut = 1.0 - (CGFloat(2 * yScroll) / CGFloat(floatingContainerView.frame.size.height - navView.frame.size.height))
                let topFadeIn = (CGFloat(1 * yScroll) / CGFloat(floatingContainerView.frame.size.height - navView.frame.size.height))
                titleLabel.alpha = topFadeIn
                subtitleLabel.alpha = topFadeIn
                floatingContainerView.alpha = bottomFadeOut
                saveFavoriteButton.alpha = bottomFadeOut
                removeFavoriteButton.alpha = bottomFadeOut
                teamSelectorButton.alpha = bottomFadeOut
                floatingContainerView.isHidden = false
                
            }
            else
            {
                floatingContainerView.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
                itemScrollView.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
                leftShadow.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
                rightShadow.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
                horizLine.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
                saveFavoriteButton.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
                removeFavoriteButton.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
                teamSelectorButton.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
                
                //browserView.updateFrame(CGRect(x: 0, y: Int(itemScrollView.frame.origin.y) + Int(itemScrollView.frame.size.height), width: Int(kDeviceWidth), height: tableInitialHeight + Int(floatingContainerView.frame.size.height) - Int(itemScrollView.frame.size.height) - 12))
                
                homeTableView.frame = CGRect(x: 0, y: Int(itemScrollView.frame.origin.y) + Int(itemScrollView.frame.size.height), width: Int(kDeviceWidth), height: tableInitialHeight + Int(floatingContainerView.frame.size.height) - Int(itemScrollView.frame.size.height) - 12)
                            
                titleLabel.alpha = 1
                subtitleLabel.alpha = 1
                floatingContainerView.alpha = 0
                saveFavoriteButton.alpha = 0
                removeFavoriteButton.alpha = 0
                teamSelectorButton.alpha = 0
                floatingContainerView.isHidden = true
                
            }
        }
    }
    
    // MARK: - Pull to Refresh
    
    @objc private func pullToRefresh()
    {
        if (teamRefreshControl.isRefreshing == true)
        {
            self.getNativeTeamHomeData()
        }
    }
    
    // MARK: - App Entered Background Notification
    
    @objc private func applicationDidEnterBackground()
    {
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
        
        self.clearBannerAd()
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        trackingGuid = NSUUID().uuidString
                
        userTeamRole = MiscHelper.userTeamRole(schoolId: self.selectedTeam!.schoolId, allSeasonId: self.selectedTeam!.allSeasonId)
        print(userTeamRole)
        
        // This VC uses it's own Navigation bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        bottomTabBarPad = 0
        //if (self.tabBarController?.tabBar.isHidden == false)
        //{
            bottomTabBarPad = kTabBarHeight
        //}

        // Explicitly set the nav and statusBar sizes.
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: Int(fakeStatusBar.frame.size.height), width: Int(kDeviceWidth), height: Int(navView.frame.size.height))
                
        floatingContainerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: floatingContainerView.frame.size.height)
        floatingContainerView.isUserInteractionEnabled = false
        
        teamContainerView.layer.cornerRadius = 12
        teamContainerView.clipsToBounds = true
        teamContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        teamImageContainerView.layer.cornerRadius = teamImageContainerView.frame.size.width / 2
        teamImageContainerView.clipsToBounds = true
        
        itemScrollView.frame = CGRect(x: 0, y: Int(fakeStatusBar.frame.size.height + floatingContainerView.frame.size.height), width: Int(kDeviceWidth), height: Int(itemScrollView.frame.size.height))
        
        horizLine.frame = CGRect(x: 0, y: itemScrollView.frame.origin.y + itemScrollView.frame.size.height - 1, width: kDeviceWidth, height: 1)
        
        tableInitialHeight = Int(kDeviceHeight) - Int(itemScrollView.frame.origin.y) - Int(itemScrollView.frame.size.height) - SharedData.bottomSafeAreaHeight - bottomTabBarPad
        
        // Instantiate the stats header and footer views
        let statsHeaderNib = Bundle.main.loadNibNamed("TeamHomeStatsHeaderViewCell", owner: self, options: nil)
        statsHeaderView = statsHeaderNib![0] as? TeamHomeStatsHeaderViewCell
        
        let statsFooterNib = Bundle.main.loadNibNamed("TeamHomeStatsFooterViewCell", owner: self, options: nil)
        statsFooterView = statsFooterNib![0] as? TeamHomeStatsFooterViewCell
        statsFooterView.fullStatsButton.addTarget(self, action: #selector(fullStatsButtonTouched), for: .touchUpInside)
        
        homeTableView = UITableView(frame: CGRect(x: 0, y: Int(itemScrollView.frame.origin.y) + Int(itemScrollView.frame.size.height), width: Int(kDeviceWidth), height: tableInitialHeight), style: .grouped)
        homeTableView.delegate = self
        homeTableView.dataSource = self
        homeTableView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        homeTableView.separatorStyle = .none
        homeTableView.showsVerticalScrollIndicator = false
        self.view.addSubview(homeTableView)
        homeTableView.isHidden = true
        
        // Add pull-to-refresh control
        teamRefreshControl.tintColor = UIColor.mpLightGrayColor()
        //let attributedString = NSMutableAttributedString(string: "Refreshing", attributes: [NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 14), NSAttributedString.Key.foregroundColor: UIColor.mpLightGrayColor()])
        //teamRefreshControl.attributedTitle = attributedString
        //teamRefreshControl.attributedTitle = attributedString
        teamRefreshControl.addTarget(self, action: #selector(pullToRefresh), for: UIControl.Event.valueChanged)
        homeTableView.addSubview(teamRefreshControl)

        titleLabel.alpha = 0
        subtitleLabel.alpha = 0
        
        // Load the title and subtitle labels
        let schoolName = self.selectedTeam?.schoolName
        titleLabel.text = schoolName
        floatingTitleLabel.text = schoolName
        
        floatingFollowersLabel.isHidden = true
        
        let sport = self.selectedTeam?.sport
        let level = self.selectedTeam?.teamLevel
        let gender = self.selectedTeam?.gender
        let season = self.selectedTeam?.season
        let genderSportLevel = MiscHelper.genderSportLevelFrom(gender: gender!, sport: sport!, level: level!)
        
        var floatingSubtitle = ""
        
        if (sport!.lowercased() == "soccer")
        {
            floatingSubtitle = String(format: "%@ (%@)", genderSportLevel, season!)
        }
        else
        {
            floatingSubtitle = genderSportLevel
        }
        
        subtitleLabel.text = genderSportLevel
        floatingSubtitleLabel.text = floatingSubtitle
        
        // Set the sport icon and shift it to the left of the floatingSubtitle
        let sportImage = MiscHelper.getImageForSport(sport!)
        sportIconImageView.image = sportImage
        
        let subtitleTextWidth = floatingSubtitle.widthOfString(usingFont: floatingSubtitleLabel.font)
        sportIconImageView.frame = CGRect(x: ((kDeviceWidth - subtitleTextWidth) / 2) - 22, y: sportIconImageView.frame.origin.y, width: sportIconImageView.frame.size.width, height: sportIconImageView.frame.size.height)
        
        // Set the colors
        let schoolColorString = self.selectedTeam?.teamColor
        let schoolColor = ColorHelper.color(fromHexString: schoolColorString, colorCorrection: true)!
        
        fakeStatusBar.backgroundColor = schoolColor
        navView.backgroundColor = schoolColor
        
        // Tint the save and remove buttons
        saveFavoriteButton.frame.origin = CGPoint(x: kDeviceWidth - 50.0, y: fakeStatusBar.frame.size.height + 58.0)
        let saveImage = UIImage(named: "SaveFavoriteIcon")?.withRenderingMode(.alwaysTemplate)
        saveFavoriteButton.tintColor = schoolColor
        saveFavoriteButton.setImage(saveImage, for: .normal)
        
        removeFavoriteButton.frame.origin = CGPoint(x: kDeviceWidth - 50.0, y: fakeStatusBar.frame.size.height + 58.0)
        let removeImage = UIImage(named: "RemoveFavoriteIcon")?.withRenderingMode(.alwaysTemplate)
        removeFavoriteButton.tintColor = schoolColor
        removeFavoriteButton.setImage(removeImage, for: .normal)
        
        // Darken the background of the yearSelectorButton
        yearSelectorButton.layer.cornerRadius = 8
        yearSelectorButton.layer.borderWidth = 1
        yearSelectorButton.layer.borderColor = UIColor.init(white: 1.0, alpha: 0.3).cgColor
        yearSelectorButton.clipsToBounds = true
        //yearSelectorButton.backgroundColor = schoolColor.darker(by: 10)
        
        // Show or hide the favorite buttons
        saveFavoriteButton.isHidden = !self.showSaveFavoriteButton
        removeFavoriteButton.isHidden = !self.showRemoveFavoriteButton
        
        // This will be unhidden when the feed finishes
        yearSelectorButton.isHidden = true
        
        adminIndicatorView.isHidden = true
        teamImageEditButton.isHidden = true
        
        // Show or hide the adminContainer
       userIsAdmin = MiscHelper.isUserAnAdmin(schoolId: self.selectedTeam!.schoolId, allSeasonId: self.selectedTeam!.allSeasonId)
        
        if (userIsAdmin == true)
        {
            adminIndicatorView.isHidden = false
        }
        
        // Load the initialLabel
        let initial = String(schoolName!.prefix(1))
        teamInitialLabel.isHidden = true
        teamInitialLabel.textColor = schoolColor
        teamInitialLabel.text = initial.uppercased()
        
        // Load the mascot image
        let mascotUrl = self.selectedTeam?.mascotUrl
        
        if (mascotUrl!.count > 0)
        {
            let url = URL(string: mascotUrl!)

            // Get the data and make an image
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        // Render the mascot using this helper
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: self.teamImageView)
                    }
                    else
                    {
                        self.teamInitialLabel.isHidden = false
                    }
                }
            }
        }
        else
        {
            teamInitialLabel.isHidden = false
        }
        
        
        // Get the SSID's for the active team
        self.getSSIDsForTeam(schoolId: self.selectedTeam!.schoolId, allSeasonId: self.selectedTeam!.allSeasonId)
        
        // Added to remind guest users that they can not save the team
        let userId = kUserDefaults.object(forKey: kUserIdKey) as! String
        
        if (userId == kTestDriveUserId)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["Join", "Later"], title: "Guest Login", message: "You must be a member to add or edit your favorite teams and athletes.", lastItemCancelType: false) { tag in
                
                if (tag == 0)
                {
                    self.logoutUser()
                }
                
            }
        }
        
        // Show the ad
        //self.loadBannerViews()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = false
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mpBlackColor(), .font: UIFont.mpSemiBoldFontWith(size: kNavBarFontSize)]
        
        if (scheduleVC != nil)
        {
            // Get the native team home data in case the schedule changed
            self.getNativeTeamHomeData()
        }
        
        // Reload the page using a new sport
        if (teamSelectorVC != nil)
        {
            // This determines if the back button was touched
            if (teamSelectorVC.selectedTeam?.sport != "")
            {
                self.reloadViewWithDifferentSport(newTeam: teamSelectorVC.selectedTeam!)
            }
        }
        
        // Stop any running video
        if (teamVideoCenterVC != nil)
        {
            teamVideoCenterVC.stopVideo()
        }
        
        // Show the ad (Changed to here in V6.3.1
        self.loadBannerViews()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (tabName == "videos")
        {
            // Clear the tabName out so the TeamVideoCenter will only show once
            tabName = ""
            self.showTeamVideoViewController()
        }
        else if (tabName == "schedule")
        {
            // Clear the tabName out so the Schedule will only show once
            tabName = ""
            self.showScheduleViewController()
        }
        else if (tabName == "rankings")
        {
            // Clear the tabName out
            tabName = ""
            
            // Press the button after some delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                for subview in self.itemScrollView.subviews as Array<UIView>
                {
                    if (subview is UIButton)
                    {
                        let button = subview as! UIButton
                        if (button.titleLabel?.text == "Rankings")
                        {
                            self.itemTouched(button)
                            break
                        }
                    }
                }
            }
        }
        else if (tabName == "photos")
        {
            // Clear the tabName out
            tabName = ""
            
            // Press the button after some delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                for subview in self.itemScrollView.subviews as Array<UIView>
                {
                    if (subview is UIButton)
                    {
                        let button = subview as! UIButton
                        if (button.titleLabel?.text == "Photos")
                        {
                            self.itemTouched(button)
                            break
                        }
                    }
                }
            }
        }
        
        if (webVC != nil)
        {
            webVC = nil
            //self.loadBannerViews()
        }
        
        if (rosterVC != nil)
        {
            rosterVC = nil
            //self.loadBannerViews()
        }
        
        if (scheduleVC != nil)
        {
            scheduleVC = nil
            //self.loadBannerViews()
        }
        
        if (videoPlayerVC != nil)
        {
            videoPlayerVC = nil
            //self.loadBannerViews()
        }
        
        if (athleteDetailVC != nil)
        {
            athleteDetailVC = nil
            //self.loadBannerViews()
        }
        
        if (teamSelectorVC != nil)
        {
            teamSelectorVC = nil
            //self.loadBannerViews()
        }
        
        if (teamVideoCenterVC != nil)
        {
            teamVideoCenterVC = nil
            //self.loadBannerViews()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
        
        self.clearBannerAd()
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

    deinit
    {
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
}
