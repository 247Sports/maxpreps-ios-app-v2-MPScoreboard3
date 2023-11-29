//
//  ScheduleViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 9/14/21.
//

import UIKit
import SwiftUI
import GoogleMobileAds
//import MoPubAdapter
import DTBiOSSDK
import AdSupport
import AppTrackingTransparency

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CustomActionSheetTripleViewDelegate, AddGameViewControllerDelegate, EditGameViewControllerDelegate, CopyScheduleViewControllerDelegate, CalendarSubscribeAlertViewDelegate, DTBAdCallback, GADBannerViewDelegate
{
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var recordView: UIView!
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var calendarSyncButton: UIButton!
    
    var selectedTeam : Team?
    var ssid : String?
    var year = ""
    var selectedYearIndex = 0
    
    private var userIsAdmin = false
    private var attentionHeaderIsCollapsed = true
    private var isReverseSorted = false
    private var attentionHeaderIsAnimating = false
    private var addButton: UIButton!
    
    private var teamVideos: Array<Dictionary<String,Any>> = []
    private var contestItems: Array<Dictionary<String,Any>> = []
    private var reversedContestItems: Array<Dictionary<String,Any>> = []
    private var futureContestItems: Array<Dictionary<String,Any>> = []
    private var futureReversedContestItems: Array<Dictionary<String,Any>> = []
    private var deletedContestItems: Array<Dictionary<String,Any>> = []
    private var scoredItems: Array<Dictionary<String,Any>> = []
    private var contestCallouts: Array<Dictionary<String,Any>> = []
    private var footerLinks: Array<Dictionary<String,Any>> = []
    private var availableDatesArray: Array<Date> = []
    private var gameTypeAliasArray: Array<String> = []
    //private var shouldDisplayExhibition = false
    //private var shouldDisplayTournament = false
    //private var shouldDisplayConferenceTournament = false
    
    private var videoHeaderView: VideoHeaderViewCell!
    private var gameAttentionHeaderView: GamesNeedAttentionHeaderViewCell!
    private var scheduleHeaderView: ScheduleHeaderViewCell!
    private var scheduleFooterView: ScheduleFooterViewCell!
    private var customActionSheetTripleView: CustomActionSheetTripleView!
    private var addGameVC: AddGameViewController!
    private var editGameVC: EditGameViewController!
    private var deletedGamesVC: DeletedGamesViewController!
    private var copyScheduleVC: CopyScheduleViewController!
    private var scoreCorrectionVC: ScoreCorrectionViewController!
    private var calenderSubscribeAlertView: CalendarSubscribeAlertView!
    private var boxScoreVC: BoxScoreViewController!
    
    private var googleBannerAdView: GAMBannerView!
    private var bannerBackgroundView: UIVisualEffectView! //UIImageView!
    
    private var trackingGuid = ""
    private var userTeamRole = ""
    private var tickTimer: Timer!
    
    private var progressOverlay: ProgressHUD!
    
    private let kGameTypes = ["Conference","Non-Conference","Tournament","Exhibition","Playoff","Conference Tournament"]
    /*
    Conference = 0,
    NonConference = 1,
    Tournament = 2,
    Exhibition = 3,
    Playoff = 4,
    ConferenceTournament = 5
    */
    
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
    
    // MARK: - Show Web View
    
    private func showWebView(urlString: String, title: String, showShare: Bool, showBannerAd: Bool, contestId: String)
    {
        if (videoHeaderView != nil)
        {
            videoHeaderView.stopVideo()
        }
        
        // Color changed
        let webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC.titleString = title
        webVC.urlString = urlString
        //webVC.titleColor = UIColor.mpWhiteColor()
        //webVC.navColor = navView.backgroundColor!
        webVC.titleColor = UIColor.mpBlackColor()
        webVC.navColor = UIColor.mpWhiteColor()
        webVC.allowRotation = false
        webVC.showShareButton = showShare
        webVC.showScrollIndicators = true
        webVC.showLoadingOverlay = true
        webVC.showBannerAd = showBannerAd
        webVC.adId = kUserDefaults.value(forKey: kTeamsBannerAdIdKey) as! String
        webVC.tabBarVisible = true
        webVC.enableAdobeQueryParameter = true
        webVC.contestId = contestId
        webVC.trackingKey = "schedule-home"
        webVC.trackingContextData = kEmptyTrackingContextData

        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    // MARK: - Show EditGameViewController
    
    private func showEditGameViewController(contestId: String, contestState: Int)
    {
        // Stop the video player
        if (videoHeaderView != nil)
        {
            videoHeaderView.stopVideo()
        }
        
        if (editGameVC != nil)
        {
            editGameVC = nil
        }
        
        var gameTypes = kGameTypes
        
        if (self.gameTypeAliasArray.count > 0)
        {
            gameTypes = self.gameTypeAliasArray
        }
        
        editGameVC = EditGameViewController(nibName: "EditGameViewController", bundle: nil)
        editGameVC.delegate = self
        editGameVC.selectedTeam = self.selectedTeam
        editGameVC.contestId = contestId
        editGameVC.availableDates = self.availableDatesArray
        editGameVC.ssid = self.ssid
        editGameVC.gameTypes = gameTypes
        editGameVC.contestState = contestState
        editGameVC.year = self.year

        let editGameNavController = TopNavigationController(rootViewController: editGameVC)
        editGameNavController.modalPresentationStyle = .fullScreen
        
        self.tabBarController?.tabBar.isHidden = true
        
        self.present(editGameNavController, animated: true)
        {
            
        }
        
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
        cData[kTrackingSchoolYearKey] = self.year
        cData[kTrackingUserTeamRoleKey] = userTeamRole
        
        TrackingManager.trackState(featureName: "schedule-manage", trackingGuid: trackingGuid, cData: cData)
    }
    
    // MARK: - Show BoxScoreViewController
    
    private func showBoxScoreViewController(contest: Dictionary<String,Any>)
    {
        boxScoreVC = BoxScoreViewController(nibName: "BoxScoreViewController", bundle: nil)
        boxScoreVC.selectedTeam = self.selectedTeam
        boxScoreVC.selectedContest = contest
        boxScoreVC.ssid = self.ssid
        
        /*
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = navView.backgroundColor
        self.navigationController?.navigationBar.tintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mpWhiteColor(), .font: UIFont.mpSemiBoldFontWith(size: kNavBarFontSize)]
        */
        
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(boxScoreVC, animated: true)
        self.hidesBottomBarWhenPushed = false
        
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
        cData[kTrackingSchoolYearKey] = self.year
        cData[kTrackingUserTeamRoleKey] = userTeamRole
        
        TrackingManager.trackState(featureName: "score-manage", trackingGuid: trackingGuid, cData: cData)
    }
    
    // MARK: - Get Schedule
    
    private func getSchedule()
    {
        isReverseSorted = false
        
        teamVideos.removeAll()
        contestItems.removeAll()
        reversedContestItems.removeAll()
        futureContestItems.removeAll()
        deletedContestItems.removeAll()
        scoredItems.removeAll()
        contestCallouts.removeAll()
        footerLinks.removeAll()
        availableDatesArray.removeAll()
        gameTypeAliasArray.removeAll()
        //shouldDisplayExhibition = false
        //shouldDisplayTournament = false
        //shouldDisplayConferenceTournament = false
        
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        ScheduleFeeds.getSchedule(schoolId: selectedTeam!.schoolId, ssid: ssid!) { result, error in
            
            self.scheduleTableView.isHidden = false
            
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
                print("Get Schedule Success")
                
                let overallStanding = result!["overallStanding"] as! Dictionary<String, Any>
                let leagueStanding = result!["leagueStanding"] as! Dictionary<String, Any>
                self.teamVideos = result!["videos"] as! Array<Dictionary<String, Any>>
                self.contestCallouts = result!["contestCallouts"] as! Array<Dictionary<String, Any>>
                self.footerLinks = result!["footerLinks"] as! Array<Dictionary<String, Any>>
                
                if (result!["contestTypeAliases"] != nil)
                {
                    self.gameTypeAliasArray = result!["contestTypeAliases"] as! Array<String>
                }
                
                // Load the record label
                let overallRecord = overallStanding["overallWinLossTies"] as! String
                let leagueName = leagueStanding["leagueName"] as! String
                let leagueRecord = leagueStanding["conferenceWinLossTies"] as! String
                let leaguePlacement = leagueStanding["conferenceStandingPlacement"] as! String
                
                if (leagueName.count > 0)
                {
                    self.recordLabel.text = overallRecord + " Overall | " + leagueRecord + " " + leagueName + " - " + leaguePlacement
                }
                else
                {
                    self.recordLabel.text = overallRecord + " Overall"
                }
                
                // Iterate through the contests to break them into non-deleted and deleted contest arrays
                let contests = result!["contests"] as! Array<Dictionary<String,Any>>
                
                for item in contests
                {
                    let contest = item["contest"] as! Dictionary<String,Any>
                    let isDeleted = contest["isDeleted"] as! Bool
                    
                    if (isDeleted == true)
                    {
                        self.deletedContestItems.append(item)
                    }
                    else
                    {
                        self.contestItems.append(item)
                        
                        // Build the futureContestItemArray
                        var contestDateString = contest["date"] as? String ?? "1901-01-01T00:00:00"
                        contestDateString = contestDateString.replacingOccurrences(of: "Z", with: "")
                        let dateFormatter = DateFormatter()
                        dateFormatter.isLenient = true
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                        dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
                        //dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                        let contestDate = dateFormatter.date(from: contestDateString)
                        
                        if (contestDate != nil)
                        {
                            // Add the date to theavailableDatesArray for the add/edit views to use
                            self.availableDatesArray.append(contestDate!)
                            
                            dateFormatter.dateFormat = "M/d"
                            let dateString = dateFormatter.string(from: contestDate!)
                            let date = dateFormatter.date(from: dateString) ?? Date()
                            
                            let todayString = dateFormatter.string(from: Date())
                            let today = dateFormatter.date(from: todayString) ?? Date()
                            
                            if (date >= today)
                            {
                                self.futureContestItems.append(item)
                            }
                            
                            // Build the scoredItems
                            let calculatedFieldsObj = item["calculatedFields"] as! Dictionary<String,Any>
                            let contestState = calculatedFieldsObj["contestState"] as! Int
                            
                            if (contestState == 4)
                            {
                                self.scoredItems.append(item)
                            }
                        }
                        /*
                        else
                        {
                            let message = String(format: "Date: %@", contestDateString)
                            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Malformed Date Found", message: message, lastItemCancelType: false) { tag in
                                
                            }
                        }
                        */
                    }
                }
                
                self.reversedContestItems = self.contestItems.reversed()
                
                print("Contest Count = " + String(self.contestItems.count))
                print("Deleted Contest Count = " + String(self.deletedContestItems.count))
                
                // Hide the calendar sync button if there are no contests
                if (self.contestItems.count == 0)
                {
                    self.calendarSyncButton.isHidden = true
                }
                else
                {
                    self.calendarSyncButton.isHidden = false
                    
                    // Add the contest count to the seasonLabel
                    self.scheduleHeaderView.seasonLabel.text = String(format: "20%@ %@ Team (%d)", self.year, self.selectedTeam!.teamLevel, self.contestItems.count)
                }
                
                /*
                // Hide the sort button if less than two items
                if (self.contestItems.count < 2)
                {
                    self.scheduleHeaderView.scheduleSortButton.isHidden = true
                }
                else
                {
                    self.scheduleHeaderView.scheduleSortButton.isHidden = false
                }
                */
                // Hide the showDeletedButton if not admin or no contests
                if (self.deletedContestItems.count == 0) || (self.userIsAdmin == false)
                {
                    self.scheduleHeaderView.scheduleShowDeletedButton.isHidden = true
                }
                else
                {
                    self.scheduleHeaderView.scheduleShowDeletedButton.isHidden = false
                }
                
                // Hide the scoreCorrectionButton if no games with scores
                if (self.scoredItems.count == 0)
                {
                    self.scheduleFooterView.scoreCorrectionButton.isHidden = true
                    self.scheduleFooterView.separatorLine.isHidden = true
                    self.scheduleFooterView.scheduleCorrectionButton.center = CGPoint(x: kDeviceWidth / 2.0, y: self.scheduleFooterView.scheduleCorrectionButton.center.y)
                }
                else
                {
                    self.scheduleFooterView.scoreCorrectionButton.isHidden = false
                    self.scheduleFooterView.separatorLine.isHidden = false
                    self.scheduleFooterView.scheduleCorrectionButton.frame = CGRect(x: 63, y: 6, width: 116, height: 30)
                }
                
                /*
                // These properties are used in the add/edit contest classes for the game type
                if (result!["ShouldDisplayExhibition"] != nil)
                {
                    self.shouldDisplayExhibition = result!["ShouldDisplayExhibition"] as! Bool
                }
                
                if (result!["shouldDisplayTournament"] != nil)
                {
                    self.shouldDisplayTournament = result!["shouldDisplayTournament"] as! Bool
                }
                
                if (result!["shouldDisplayConferenceTournament"] != nil)
                {
                    self.shouldDisplayConferenceTournament = result!["shouldDisplayConferenceTournament"] as! Bool
                }
                */
                
                // Add the videoHeader if a video is available
                if (self.teamVideos.count > 0)
                {
                    // Skip over this code if the header already exists
                    if (self.videoHeaderView == nil)
                    {
                        // This moves to the feed return method. The height is variable
                        let videoHeight = ((kDeviceWidth * 9) / 16)
                        let videoSize = CGSize(width: kDeviceWidth, height: videoHeight)
                        let videoHeaderNib = Bundle.main.loadNibNamed("VideoHeaderViewCell", owner: self, options: nil)
                        self.videoHeaderView = videoHeaderNib![0] as? VideoHeaderViewCell
                        self.videoHeaderView.parentVC = self
                        self.videoHeaderView.frame = CGRect(x: 0, y: Int(self.navView.frame.size.height), width: Int(kDeviceWidth), height: Int(videoSize.height) + 52)
                        self.view.insertSubview(self.videoHeaderView, belowSubview: self.navView)
                        
                        self.videoHeaderView.loadVideoSize(videoSize)
                        
                        let videoObj = self.teamVideos.first!
                        self.videoHeaderView.loadData(videoObj, teamColor: self.navView.backgroundColor!)
                    }
                }
            }
            else
            {
                print("Get Schedule Failed")
            }
            
            self.scheduleTableView.reloadData()
        }
    }
    
    // MARK: - CalendarSubscribeAlertViewDelegate Methods
    
    func closeCalendarSubscribeAlertAfterCancelButtonTouched()
    {
        calenderSubscribeAlertView.removeFromSuperview()
        calenderSubscribeAlertView = nil
    }
    
    func closeCalendarSubscribeAlertAfterAppleButtonTouched()
    {
        calenderSubscribeAlertView.removeFromSuperview()
        calenderSubscribeAlertView = nil
        
        // Get the correct URL
        var urlString = ""
        
        // Build the subdomain
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kSubscribedCalendarDev, selectedTeam!.schoolId, self.ssid!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kSubscribedCalendarDev, selectedTeam!.schoolId, self.ssid!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kSubscribedCalendarStaging, selectedTeam!.schoolId, self.ssid!)
        }
        else
        {
            urlString = String(format: kSubscribedCalendarProduction, selectedTeam!.schoolId, self.ssid!)
        }
        
        UIApplication.shared.open(URL(string: urlString)!, options: [:]) { result in
            
        }
    }
    
    func closeCalendarSubscribeAlertAfterThirdPartyButtonTouched()
    {
        calenderSubscribeAlertView.removeFromSuperview()
        calenderSubscribeAlertView = nil
        
        /// Get the correct URL
        var urlString = ""
        
        // Build the subdomain
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kSubscribedCalendarDev, selectedTeam!.schoolId, self.ssid!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kSubscribedCalendarDev, selectedTeam!.schoolId, self.ssid!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kSubscribedCalendarStaging, selectedTeam!.schoolId, self.ssid!)
        }
        else
        {
            urlString = String(format: kSubscribedCalendarProduction, selectedTeam!.schoolId, self.ssid!)
        }
        
        UIPasteboard.general.string = urlString
        
        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Link Copied", message: "The link to your team's calendar has been copied into the Pasteboard. You can subscribe to this link in your third party calendar app.", lastItemCancelType: false) { (tag) in
        }
    }
    
    func closeCalendarSubscribeAlertAfterUnsubscribeButtonTouched()
    {
        calenderSubscribeAlertView.removeFromSuperview()
        calenderSubscribeAlertView = nil
        
        // Different messages to deselect a calendar
        switch UIDevice.current.systemVersion.compare("15.0.0", options: .numeric)
        {
        case .orderedSame, .orderedDescending:
            print("iOS >= 15")
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Unsubscribe", message: "To unsubscribe from a calendar you need to open the Calendar app, select Calendars, then deselect the team's calendar entry.", lastItemCancelType: false) { (tag) in
            }
        case .orderedAscending:
            print("iOS < 15.0")
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Unsubscribe", message: "To unsubscribe from a calendar you need to open Settings, select Calendars, select Accounts, then select the calendar that you wish to unsubscribe. Select \"Delete Account\"", lastItemCancelType: false) { (tag) in
            }
        }
    }
    
    // MARK: - CopyScheduleViewController Delegates
    
    func copyScheduleSucceeded()
    {
        self.tabBarController?.tabBar.isHidden = false
        
        self.dismiss(animated: true)
        {
            self.copyScheduleVC = nil
            
            // Add some delay so the server can get it's job done
            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            { [self] in
                self.getSchedule()
            }
        }
    }
    
    func copyScheduleCancelButtonTouched()
    {
        self.tabBarController?.tabBar.isHidden = false
        
        self.dismiss(animated: true)
        {
            self.copyScheduleVC = nil
        }
    }
    
    // MARK: - EditGameViewController Delegates
    
    func editGameCancelButtonTouched()
    {
        self.tabBarController?.tabBar.isHidden = false
        
        if (editGameVC.boxScoreUpdated == true)
        {
            self.getSchedule()
        }

        self.dismiss(animated: true)
        {
            self.editGameVC = nil
        }
    }
    
    func editGameSaveOrDeleteButtonTouched()
    {
        self.tabBarController?.tabBar.isHidden = false
        
        self.dismiss(animated: true)
        {
            self.getSchedule()
            
            self.editGameVC = nil
        }
    }
    
    // MARK: - AddGameViewController Delegates
    
    func addGameCancelButtonTouched()
    {
        self.tabBarController?.tabBar.isHidden = false
        
        // Thsi handles the case where the user pressed save and add another, but canceled the second
        if (addGameVC.gameAdded == true)
        {
            self.dismiss(animated: true)
            {
                self.getSchedule()
                
                self.addGameVC = nil
            }
        }
        else
        {
            self.dismiss(animated: true)
            {
                self.addGameVC = nil
            }
        }
    }
    
    func addGameSaveButtonTouched()
    {
        self.tabBarController?.tabBar.isHidden = false
        self.dismiss(animated: true)
        {
            self.getSchedule()
            
            self.addGameVC = nil
        }
    }
    
    // MARK: - CustomActionSheetTripleView Delegates
    
    func closeCustomTripleActionSheetAfterButtonTwoTouched()
    {
        // Add Staff
        customActionSheetTripleView.removeFromSuperview()
        customActionSheetTripleView = nil
    
        if (addGameVC != nil)
        {
            addGameVC = nil
        }
        
        addGameVC = AddGameViewController(nibName: "AddGameViewController", bundle: nil)
        addGameVC.delegate = self
        addGameVC.selectedTeam = self.selectedTeam
        //addGameVC.schoolId = selectedTeam!.schoolId
        addGameVC.ssid = self.ssid
        
        self.tabBarController?.tabBar.isHidden = true
        
        let addGameNavController = UINavigationController(rootViewController: addGameVC)
        addGameNavController.modalPresentationStyle = .overCurrentContext
        
        self.present(addGameNavController, animated: true)
        {
            
        }
        
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
        cData[kTrackingSchoolYearKey] = self.year
        cData[kTrackingUserTeamRoleKey] = userTeamRole
        
        TrackingManager.trackState(featureName: "schedule-manage", trackingGuid: trackingGuid, cData: cData)
    }
    
    func closeCustomTripleActionSheetAfterCancelButtonTouched()
    {
        customActionSheetTripleView.removeFromSuperview()
        customActionSheetTripleView = nil
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section == 0)
        {
            return 0
        }
        else if (section == 1)
        {
            if (attentionHeaderIsCollapsed == true)
            {
                return 0
            }
            else
            {
                return contestCallouts.count
            }
        }
        else
        {
            if (contestItems.count > 0)
            {
                return contestItems.count
            }
            else
            {
                return 1 // EmptyScheduleTableViewCell or EmptyScheduleAdminTableViewCell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (indexPath.section == 0)
        {
            return 0
        }
        else if (indexPath.section == 1)
        {
            if (attentionHeaderIsCollapsed == true)
            {
                return 0
            }
            else
            {
                return 45
            }
        }
        else
        {
            if (contestItems.count > 0)
            {
                // Decide which cell to use
                var item: Dictionary<String,Any>
                
                if (isReverseSorted == true)
                {
                    item = reversedContestItems[indexPath.row]
                }
                else
                {
                    item = contestItems[indexPath.row]
                }
                
                var isTournament = false
                var hasLocation = false
                
                if (item["tournamentInfo"] is NSNull)
                {
                    isTournament = false
                }
                else
                {
                    isTournament = true
                }

                let contest = item["contest"] as! Dictionary<String,Any>
                if (contest["location"] is NSNull)
                {
                    hasLocation = false
                }
                else
                {
                    let location = contest["location"] as! String
                    
                    if (location.count > 0)
                    {
                        hasLocation = true
                    }
                }
                
                if (isTournament == false) && (hasLocation == false)
                {
                    return 68
                }
                else if ((hasLocation == true) && (isTournament == false)) || ((hasLocation == false) && (isTournament == true))
                {
                    return 88
                }
                else
                {
                    return 108
                }
            }
            else
            {
                if (userIsAdmin == true)
                {
                    return 310
                }
                else
                {
                    return 148
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if (section == 0)
        {
            if (teamVideos.count > 0)
            {
                return videoHeaderView.frame.size.height
            }
            else
            {
                return 0.01
            }
        }
        else if (section == 1)
        {
            if (userIsAdmin == true)
            {
                if (contestCallouts.count > 0)
                {
                    return gameAttentionHeaderView.frame.size.height
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
            if (contestItems.count > 0)
            {
                return scheduleHeaderView.frame.size.height
            }
            else
            {
                return 0.01
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (section == 2)
        {
            if (userIsAdmin == true)
            {
                if (contestItems.count > 0)
                {
                    // Pad for the ad is 62
                    return 90 + 62
                }
                else
                {
                    return 62 //0.01
                }
            }
            else
            {
                if (contestItems.count > 0)
                {
                    return scheduleFooterView.frame.size.height + 82
                }
                else
                {
                    return 62 //0.01
                }
            }
        }
        else
        {
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (section == 0)
        {
            return nil
        }
        else if (section == 1)
        {
            if (userIsAdmin == true)
            {
                if (contestCallouts.count > 0)
                {
                    gameAttentionHeaderView.gameCountLabel.text = String(contestCallouts.count)
                    
                    if (contestCallouts.count == 1)
                    {
                        gameAttentionHeaderView.titleLabel.text = "Game Needs Attention"
                    }
                    else
                    {
                        gameAttentionHeaderView.titleLabel.text = "Games Need Attention"
                    }
                    
                    let view = UIView()
                    view.addSubview(gameAttentionHeaderView)
                    return view
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
            if (contestItems.count > 0)
            {
                let view = UIView()
                view.addSubview(scheduleHeaderView)
                return view
            }
            else
            {
                return nil
            }
        }

    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        if (section == 2)
        {
            if (userIsAdmin == true)
            {
                if (contestItems.count > 0)
                {
                    let view = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 90))
                    view.backgroundColor = UIColor.mpHeaderBackgroundColor()
                    return view
                }
                else
                {
                    return nil
                }
            }
            else
            {
                if (contestItems.count > 0)
                {
                    let view = UIView()
                    view.addSubview(scheduleFooterView)
                    return view
                }
                else
                {
                    return nil
                }
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
            var cell = tableView.dequeueReusableCell(withIdentifier: "GamesNeedAttentionTableViewCell") as? GamesNeedAttentionTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("GamesNeedAttentionTableViewCell", owner: self, options: nil)
                cell = nib![0] as? GamesNeedAttentionTableViewCell
            }
            
            cell?.selectionStyle = .none
            
            let contestCallout = contestCallouts[indexPath.row]
            cell?.loadData(contestCallout)
            
            cell?.layer.cornerRadius = 12
            cell?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                        
            if (indexPath.row == (contestCallouts.count - 1))
            {
                cell?.clipsToBounds = true
            }
            else
            {
                cell?.clipsToBounds = false
            }
            
            return cell!
        }
        else if (indexPath.section == 2)
        {
            if (contestItems.count > 0)
            {
                let colorString = selectedTeam?.teamColor
                let teamColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
                
                var gameTypes = kGameTypes
                
                if (self.gameTypeAliasArray.count > 0)
                {
                    gameTypes = self.gameTypeAliasArray
                }
                
                // Decide which cell to use
                var item: Dictionary<String,Any>
                
                if (isReverseSorted == true)
                {
                    item = reversedContestItems[indexPath.row]
                }
                else
                {
                    item = contestItems[indexPath.row]
                }
                
                var isTournament = false
                var hasLocation = false
                
                if (item["tournamentInfo"] is NSNull)
                {
                    isTournament = false
                }
                else
                {
                    isTournament = true
                }

                let contest = item["contest"] as! Dictionary<String,Any>
                var showBar = false
                
                // Compare the contestDate with the futureContestItemArray's first item to show the bar
                if (futureContestItems.count > 0)
                {
                    let nearestFutureItem = futureContestItems.first!
                    let nearestFutureContest = nearestFutureItem["contest"] as! Dictionary<String,Any>

                    let contestId = contest["contestId"] as! String
                    let futureContestId = nearestFutureContest["contestId"] as! String
                    
                    if (contestId == futureContestId)
                    {
                        showBar = true
                    }
                }
                
                // See if the location property exists
                if (contest["location"] is NSNull)
                {
                    hasLocation = false
                }
                else
                {
                    let location = contest["location"] as! String
                    
                    if (location.count > 0)
                    {
                        hasLocation = true
                    }
                }
                
                if (hasLocation == false) && (isTournament == false)
                {
                    if (userIsAdmin == false)
                    {
                        var cell = tableView.dequeueReusableCell(withIdentifier: "ShortContestTableViewCell") as? ShortContestTableViewCell
                        
                        if (cell == nil)
                        {
                            let nib = Bundle.main.loadNibNamed("ShortContestTableViewCell", owner: self, options: nil)
                            cell = nib![0] as? ShortContestTableViewCell
                        }
                        
                        cell?.selectionStyle = .none
         
                        cell?.loadData(item, teamColor: teamColor!, myTeamId: selectedTeam!.schoolId, showBar: showBar, gameTypeAliases: gameTypes)
                        
                        cell?.reportScoreButton.tag = 100 + indexPath.row
                        cell?.reportScoreButton.addTarget(self, action: #selector(reportScoreButtonTouched(_:)), for: .touchUpInside)
                        
                        return cell!
                    }
                    else
                    {
                        var cell = tableView.dequeueReusableCell(withIdentifier: "ShortContestAdminTableViewCell") as? ShortContestAdminTableViewCell
                        
                        if (cell == nil)
                        {
                            let nib = Bundle.main.loadNibNamed("ShortContestAdminTableViewCell", owner: self, options: nil)
                            cell = nib![0] as? ShortContestAdminTableViewCell
                        }
                        
                        cell?.selectionStyle = .none
         
                        cell?.loadData(item, teamColor: teamColor!, myTeamId: selectedTeam!.schoolId, showBar: showBar, gameTypeAliases: gameTypes)
                        
                        cell?.editButton.tag = 100 + indexPath.row
                        cell?.editButton.addTarget(self, action: #selector(editButtonTouched(_:)), for: .touchUpInside)
                        
                        return cell!
                    }
                    
                }
                else if ((hasLocation == true) && (isTournament == false)) || ((hasLocation == false) && (isTournament == true))
                {
                    if (userIsAdmin == false)
                    {
                        var cell = tableView.dequeueReusableCell(withIdentifier: "MediumContestTableViewCell") as? MediumContestTableViewCell
                        
                        if (cell == nil)
                        {
                            let nib = Bundle.main.loadNibNamed("MediumContestTableViewCell", owner: self, options: nil)
                            cell = nib![0] as? MediumContestTableViewCell
                        }
                        
                        cell?.selectionStyle = .none
                                        
                        cell?.loadData(item, teamColor: teamColor!, myTeamId: selectedTeam!.schoolId, showBar: showBar, gameTypeAliases: gameTypes)
                        
                        cell?.reportScoreButton.tag = 100 + indexPath.row
                        cell?.reportScoreButton.addTarget(self, action: #selector(reportScoreButtonTouched(_:)), for: .touchUpInside)
                        
                        cell?.tournamentLinkbutton.tag = 100 + indexPath.row
                        cell?.tournamentLinkbutton.addTarget(self, action: #selector(tournamentLinkButtonTouched(_:)), for: .touchUpInside)
                        
                        return cell!
                    }
                    else
                    {
                        var cell = tableView.dequeueReusableCell(withIdentifier: "MediumContestAdminTableViewCell") as? MediumContestAdminTableViewCell
                        
                        if (cell == nil)
                        {
                            let nib = Bundle.main.loadNibNamed("MediumContestAdminTableViewCell", owner: self, options: nil)
                            cell = nib![0] as? MediumContestAdminTableViewCell
                        }
                        
                        cell?.selectionStyle = .none
                                        
                        cell?.loadData(item, teamColor: teamColor!, myTeamId: selectedTeam!.schoolId, showBar: showBar, gameTypeAliases: gameTypes)
                        
                        cell?.editButton.tag = 100 + indexPath.row
                        cell?.editButton.addTarget(self, action: #selector(editButtonTouched(_:)), for: .touchUpInside)
                        
                        cell?.tournamentLinkbutton.tag = 100 + indexPath.row
                        cell?.tournamentLinkbutton.addTarget(self, action: #selector(tournamentLinkButtonTouched(_:)), for: .touchUpInside)
                        
                        return cell!
                    }
                }
                else
                {
                    if (userIsAdmin == false)
                    {
                        var cell = tableView.dequeueReusableCell(withIdentifier: "TallContestTableViewCell") as? TallContestTableViewCell
                        
                        if (cell == nil)
                        {
                            let nib = Bundle.main.loadNibNamed("TallContestTableViewCell", owner: self, options: nil)
                            cell = nib![0] as? TallContestTableViewCell
                        }
                        
                        cell?.selectionStyle = .none
                                        
                        cell?.loadData(item, teamColor: teamColor!, myTeamId: selectedTeam!.schoolId, showBar: showBar, gameTypeAliases: gameTypes)
                        
                        cell?.reportScoreButton.tag = 100 + indexPath.row
                        cell?.reportScoreButton.addTarget(self, action: #selector(reportScoreButtonTouched(_:)), for: .touchUpInside)
                        
                        cell?.tournamentLinkbutton.tag = 100 + indexPath.row
                        cell?.tournamentLinkbutton.addTarget(self, action: #selector(tournamentLinkButtonTouched(_:)), for: .touchUpInside)
                        
                        return cell!
                    }
                    else
                    {
                        var cell = tableView.dequeueReusableCell(withIdentifier: "TallContestAdminTableViewCell") as? TallContestAdminTableViewCell
                        
                        if (cell == nil)
                        {
                            let nib = Bundle.main.loadNibNamed("TallContestAdminTableViewCell", owner: self, options: nil)
                            cell = nib![0] as? TallContestAdminTableViewCell
                        }
                        
                        cell?.selectionStyle = .none
                                        
                        cell?.loadData(item, teamColor: teamColor!, myTeamId: selectedTeam!.schoolId, showBar: showBar, gameTypeAliases: gameTypes)
                        
                        cell?.editButton.tag = 100 + indexPath.row
                        cell?.editButton.addTarget(self, action: #selector(editButtonTouched(_:)), for: .touchUpInside)
                        
                        cell?.tournamentLinkbutton.tag = 100 + indexPath.row
                        cell?.tournamentLinkbutton.addTarget(self, action: #selector(tournamentLinkButtonTouched(_:)), for: .touchUpInside)
                        
                        return cell!
                    }
                }
            }
            else
            {
                if (userIsAdmin == true)
                {
                    let colorString = selectedTeam?.teamColor
                    let teamColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
                    
                    var cell = tableView.dequeueReusableCell(withIdentifier: "EmptyScheduleAdminTableViewCell") as? EmptyScheduleAdminTableViewCell
                    
                    if (cell == nil)
                    {
                        let nib = Bundle.main.loadNibNamed("EmptyScheduleAdminTableViewCell", owner: self, options: nil)
                        cell = nib![0] as? EmptyScheduleAdminTableViewCell
                    }
                    
                    cell?.selectionStyle = .none
                    
                    cell?.copyScheduleButton.backgroundColor = teamColor
                    cell?.copyScheduleButton.addTarget(self, action: #selector(copyScheduleButtonTouched(_:)), for: .touchUpInside)
                    
                    return cell!
                }
                else
                {
                    var cell = tableView.dequeueReusableCell(withIdentifier: "EmptyScheduleTableViewCell") as? EmptyScheduleTableViewCell
                    
                    if (cell == nil)
                    {
                        let nib = Bundle.main.loadNibNamed("EmptyScheduleTableViewCell", owner: self, options: nil)
                        cell = nib![0] as? EmptyScheduleTableViewCell
                    }
                    
                    cell?.selectionStyle = .none
                    
                    cell?.subtitleLabel.text = "Games have not yet been added to the " + year + " season."
                    
                    return cell!
                }
                
            }
        }
        else
        {
            // This should never get called
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cell1")
            
            if (cell == nil)
            {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell1")
            }
            
            cell?.selectionStyle = .none
            
            cell?.contentView.backgroundColor = UIColor.mpWhiteColor()
            cell?.textLabel?.textColor = UIColor.mpBlackColor()
            cell?.textLabel?.font = UIFont.mpBoldFontWith(size: 16)
            
            cell?.textLabel?.text = "Item: " + String(indexPath.row)
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.section == 1)
        {
            let contestCallout = contestCallouts[indexPath.row]
            let calloutText = contestCallout["calloutText"] as! String
            
            // Look at the calloutText to decide where to go
            if (calloutText == "Add Score")
            {
                // Find the contest from the contestItems Array
                let calloutContestId = contestCallout["contestId"] as! String
                
                for item in contestItems
                {
                    let contest = item["contest"] as! Dictionary<String,Any>
                    let contestId = contest["contestId"] as! String
                    
                    if (contestId == calloutContestId)
                    {
                        self.showBoxScoreViewController(contest: contest)
                        break
                    }
                }
            }
            else if (calloutText == "Add Stats")
            {
                // This goes to a web view
                let urlString = contestCallout["calloutLink"] as! String
                
                self.showWebView(urlString: urlString, title: "Stats", showShare: false, showBannerAd: false, contestId: "")
                
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
                cData[kTrackingSchoolYearKey] = self.year
                cData[kTrackingUserTeamRoleKey] = userTeamRole
                
                TrackingManager.trackState(featureName: "missing-stats", trackingGuid: trackingGuid, cData: cData)
            }
            else if (calloutText.contains("Opponent"))
            {
                let contestId = contestCallout["contestId"] as! String
                
                self.showEditGameViewController(contestId: contestId, contestState: 6)
            }
            else if (calloutText.contains("Date"))
            {
                let contestId = contestCallout["contestId"] as! String
                
                self.showEditGameViewController(contestId: contestId, contestState: 7)
            }
            else
            {
                let contestId = contestCallout["contestId"] as! String
                
                self.showEditGameViewController(contestId: contestId, contestState: 5)
            }
            
            // Click Tracking
            let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"games-need attention-button-click", kClickTrackingModuleNameKey: "schedule", kClickTrackingModuleLocationKey:"schedule home", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:""]
            
            TrackingManager.trackEvent(featureName: "games-needs-attention", cData: cData)
        }
        else if (indexPath.section == 2)
        {
            if (contestItems.count > 0)
            {
                var item: Dictionary<String,Any>
                
                if (isReverseSorted == true)
                {
                    item = reversedContestItems[indexPath.row]
                }
                else
                {
                    item = contestItems[indexPath.row]
                }
                
                let calculatedFields = item["calculatedFields"] as! Dictionary<String,Any>
                
                if (calculatedFields["canonicalUrl"] is NSNull)
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Not Available", message: "The contest page for this game is not available.", lastItemCancelType: false) { tag in
                        
                    }
                }
                else
                {
                    let urlString = calculatedFields["canonicalUrl"] as! String
                    let contestId = item["contestId"] as? String ?? ""
                    self.showWebView(urlString: urlString, title: "Box Score", showShare: true, showBannerAd: true, contestId: contestId)
                    
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
                    cData[kTrackingSchoolYearKey] = self.year
                    cData[kTrackingUserTeamRoleKey] = userTeamRole
                    
                    TrackingManager.trackState(featureName: "score-manage", trackingGuid: trackingGuid, cData: cData)
                }
            }
        }
    }
    
    // MARK: - Sort Menu Methods
    
    private var menuItems: [UIAction]
    {
        return [
            UIAction(title: "Date: Oldest First", image: nil, handler: { (_) in
                print("Oldest First Touched")
                self.isReverseSorted = false
                self.scheduleTableView.reloadData()
            }),
            UIAction(title: "Date: Newest First", image: nil, handler: { (_) in
                print("Newest First Touched")
                self.isReverseSorted = true
                self.scheduleTableView.reloadData()
            })
        ]
    }

    private var sortMenu: UIMenu
    {
        return UIMenu(title: "Sort Games By", image: nil, identifier: nil, options: [], children: menuItems)
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        // Kill any video that may be running
        if (videoHeaderView != nil)
        {
            videoHeaderView.cleanupVideoPlayer()
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func addButtonTouched(_ sender: UIButton)
    {
        /*
        if (customActionSheetTripleView != nil)
        {
            customActionSheetTripleView.removeFromSuperview()
            customActionSheetTripleView = nil
        }
        
        customActionSheetTripleView = CustomActionSheetTripleView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight), buttonZeroTitle: nil, buttonOneTitle: nil, buttonTwoTitle: "Add Game", color: navView.backgroundColor)
        customActionSheetTripleView.delegate = self
        
        kAppKeyWindow.rootViewController!.view.addSubview(customActionSheetTripleView)
        
        
        customActionSheetTripleView.removeFromSuperview()
        customActionSheetTripleView = nil
        */
        
        // Stop the video player
        if (videoHeaderView != nil)
        {
            videoHeaderView.stopVideo()
        }
    
        if (addGameVC != nil)
        {
            addGameVC = nil
        }
        
        var gameTypes = kGameTypes
        
        if (self.gameTypeAliasArray.count > 0)
        {
            gameTypes = self.gameTypeAliasArray
        }
        
        addGameVC = AddGameViewController(nibName: "AddGameViewController", bundle: nil)
        addGameVC.delegate = self
        addGameVC.selectedTeam = self.selectedTeam
        addGameVC.availableDates = self.availableDatesArray
        addGameVC.ssid = self.ssid
        addGameVC.gameTypes = gameTypes
        addGameVC.modalPresentationStyle = .overCurrentContext
        
        self.tabBarController?.tabBar.isHidden = true
        
        self.present(addGameVC, animated: true)
        {
            
        }
    }
    
    @IBAction func calendarSyncButtonTouched(_ sender: UIButton)
    {
        // Stop the video player
        if (videoHeaderView != nil)
        {
            videoHeaderView.stopVideo()
        }
        
        if (calenderSubscribeAlertView != nil)
        {
            calenderSubscribeAlertView.removeFromSuperview()
            calenderSubscribeAlertView = nil
        }
        calenderSubscribeAlertView = CalendarSubscribeAlertView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight), color: UIColor.mpRedColor())
        calenderSubscribeAlertView.delegate = self
        
        kAppKeyWindow.rootViewController!.view.addSubview(calenderSubscribeAlertView)
        
        // Click Tracking
        let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"calendar-sync-button-click", kClickTrackingModuleNameKey: "calendar sync", kClickTrackingModuleLocationKey:"schedule home", kClickTrackingModuleActionKey: "impression", kClickTrackingClickTextKey:""]
        
        TrackingManager.trackEvent(featureName: "calendar-sync", cData: cData)
    }
    
    @objc private func attentionHeaderButtonTouched()
    {
        // This blocks the header from expanding/collapsing until the animation is done
        if (attentionHeaderIsAnimating == true)
        {
            return
        }
        attentionHeaderIsAnimating = true
        
        scheduleTableView.setContentOffset(.zero, animated: true)
        
        attentionHeaderIsCollapsed = !attentionHeaderIsCollapsed
        
        var indexPaths = [IndexPath]()
        var index = 0
        
        for _ in contestCallouts
        {
            let indexPath = IndexPath(row: index, section: 1)
            indexPaths.append(indexPath)
            index += 1
        }
        
        if (attentionHeaderIsCollapsed == false)
        {
            UIView.animate(withDuration: 0.2)
            { [self] in
                self.gameAttentionHeaderView.downArrowImageView.transform = CGAffineTransform(rotationAngle: .pi * 0.999)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                
                self.gameAttentionHeaderView.innerBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                self.scheduleTableView.insertRows(at: indexPaths, with: .fade)
                self.attentionHeaderIsAnimating = false
            })
            
            // Click Tracking
            let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"games-need attention-button-click", kClickTrackingModuleNameKey: "schedule", kClickTrackingModuleLocationKey:"schedule home", kClickTrackingModuleActionKey: "impression", kClickTrackingClickTextKey:""]
            
            TrackingManager.trackEvent(featureName: "games-needs-attention", cData: cData)
        }
        else
        {
            UIView.animate(withDuration: 0.2)
            { [self] in
                self.gameAttentionHeaderView.downArrowImageView.transform = .identity
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                
                self.gameAttentionHeaderView.innerBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                self.scheduleTableView.deleteRows(at: indexPaths, with: .fade)
                self.attentionHeaderIsAnimating = false
            })
        }
    }
    
    @objc private func showDeletedGamesButtonTouched()
    {
        // Stop the video player
        if (videoHeaderView != nil)
        {
            videoHeaderView.stopVideo()
        }
        
        var gameTypes = kGameTypes
        
        if (self.gameTypeAliasArray.count > 0)
        {
            gameTypes = self.gameTypeAliasArray
        }
        
        deletedGamesVC = DeletedGamesViewController(nibName: "DeletedGamesViewController", bundle: nil)
        deletedGamesVC.selectedTeam = selectedTeam
        deletedGamesVC.ssid = ssid
        deletedGamesVC.deletedGames = deletedContestItems
        deletedGamesVC.gameTypeAliases = gameTypes
        deletedGamesVC.year = self.year
        
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(deletedGamesVC, animated: true)
        self.hidesBottomBarWhenPushed = false
        
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
        cData[kTrackingSchoolYearKey] = self.year
        cData[kTrackingUserTeamRoleKey] = userTeamRole
        
        TrackingManager.trackState(featureName: "schedule-deleted", trackingGuid: trackingGuid, cData: cData)
        
    }
    
    @objc private func tournamentLinkButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        var item: Dictionary<String,Any>
        
        if (isReverseSorted == true)
        {
            item = reversedContestItems[index]
        }
        else
        {
            item = contestItems[index]
        }
        
        if (item["tournamentInfo"] is NSNull)
        {

        }
        else
        {
            let tournamentInfo = item["tournamentInfo"] as! Dictionary<String,Any>
            let bracketUrl = tournamentInfo["tournamentCanonicalUrl"] as! String
            
            self.showWebView(urlString: bracketUrl, title: "Bracket", showShare: true, showBannerAd: true, contestId: "")
        }
    }
    
    @objc private func reportScoreButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        var item: Dictionary<String,Any>
        
        if (isReverseSorted == true)
        {
            item = reversedContestItems[index]
        }
        else
        {
            item = contestItems[index]
        }
        let calculatedFieldsObj = item["calculatedFields"] as! Dictionary<String,Any>
        let allowReportFinalScore = calculatedFieldsObj["allowReportFinalScore"] as! Bool
        
        if (allowReportFinalScore == true)
        {
            // Call the web view
            let contest = item["contest"] as! Dictionary<String,Any>
            let ssid = contest["sportSeasonId"] as! String
            let contestId = contest["contestId"] as! String
            
            // Get the correct base URL
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
            
            let urlString = String(format: kReportScoresHostGeneric, subDomain, contestId, ssid)
            
            self.showWebView(urlString: urlString, title: "Report Score", showShare: false, showBannerAd: false, contestId: "")
            
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
            cData[kTrackingSchoolYearKey] = self.year
            cData[kTrackingUserTeamRoleKey] = userTeamRole
            
            TrackingManager.trackState(featureName: "score-manage", trackingGuid: trackingGuid, cData: cData)
        }
        else
        {
            let reason = calculatedFieldsObj["reasonWhyCannotEnterScores"] as! String
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Not Allowed", message: reason, lastItemCancelType: false) { tag in
                
            }
        }
    }
    
    @objc private func editButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        var item: Dictionary<String,Any>
        
        if (isReverseSorted == true)
        {
            item = reversedContestItems[index]
        }
        else
        {
            item = contestItems[index]
        }
        
        let contest = item["contest"] as! Dictionary<String,Any>
        let contestId = contest["contestId"] as! String
        let calculatedFieldsObj = item["calculatedFields"] as! Dictionary<String,Any>
        let contestState = calculatedFieldsObj["contestState"] as! Int
        
        self.showEditGameViewController(contestId: contestId, contestState: contestState)
    }
    
    @objc private func scheduleCorrectionButtonTouched(_ sender: UIButton)
    {
        self.showWebView(urlString: "https://support.maxpreps.com/hc/en-us/articles/4418837516443", title: "Schedule Correction", showShare: false, showBannerAd: false, contestId: "")
        
        /*
        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Coming Soon", message: "This will open the schedule correction web view when it is available.", lastItemCancelType: false) { (tag) in
        }
        */
    }
    
    @objc private func scoreCorrectionButtonTouched(_ sender: UIButton)
    {
        // Stop the video player
        if (videoHeaderView != nil)
        {
            videoHeaderView.stopVideo()
        }
        
        var gameTypes = kGameTypes
        
        if (self.gameTypeAliasArray.count > 0)
        {
            gameTypes = self.gameTypeAliasArray
        }
        
        scoreCorrectionVC = ScoreCorrectionViewController(nibName: "ScoreCorrectionViewController", bundle: nil)
        scoreCorrectionVC.selectedTeam = selectedTeam
        scoreCorrectionVC.ssid = ssid
        scoreCorrectionVC.scoredGames = scoredItems
        scoreCorrectionVC.gameTypeAliases = gameTypes
        
        //self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(scoreCorrectionVC, animated: true)
        //self.hidesBottomBarWhenPushed = false
    }
    
    @objc private func copyScheduleButtonTouched(_ sender: UIButton)
    {
        // Stop the video player
        if (videoHeaderView != nil)
        {
            videoHeaderView.stopVideo()
        }
        
        if (copyScheduleVC != nil)
        {
            copyScheduleVC = nil
        }
        
        copyScheduleVC = CopyScheduleViewController(nibName: "CopyScheduleViewController", bundle: nil)
        copyScheduleVC.delegate = self
        copyScheduleVC.selectedTeam = self.selectedTeam
        copyScheduleVC.ssid = self.ssid
        copyScheduleVC.year = self.year
        copyScheduleVC.modalPresentationStyle = .overCurrentContext
        
        self.tabBarController?.tabBar.isHidden = true
        
        self.present(copyScheduleVC, animated: true) {
            
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
        
        //let status = ATTrackingManager.trackingAuthorizationStatus
        
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
                if (self.addButton != nil)
                {
                    self.addButton.transform = CGAffineTransform(translationX: 0, y: -62)
                }
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
            
            if (addButton != nil)
            {
                // Animate the addButtonDown
                UIView.animate(withDuration: 0.16, animations: {

                    if (self.addButton != nil)
                    {
                        self.addButton.transform = CGAffineTransform(translationX: 0, y: 0)
                    }
                })
                { (finished) in
                    
                }
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
        if (videoHeaderView != nil)
        {
            let yScroll = scrollView.contentOffset.y
            
            if (yScroll <= 0)
            {
                videoHeaderView.transform = .identity
            }
            else
            {
                videoHeaderView.transform = CGAffineTransform(translationX: 0, y: -yScroll)
            }
        }
    }
    
    // MARK: - Orientation Changed Method
    
    @objc private func orientationChanged()
    {
        if (videoHeaderView != nil)
        {
            if UIDevice.current.orientation.isLandscape
            {
                print("Landscape")
                videoHeaderView.maximizeVideoPlayer()
            }
            else
            {
                print("Portrait")
                videoHeaderView.minimizeVideoPlayer()
            }
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

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        // Explicitly set the header view size. The items within the view are pinned to the bottom
        navView.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight + 76)
        scheduleTableView.frame = CGRect(x: 0, y: Int(navView.frame.size.height), width: Int(kDeviceWidth), height: Int(kDeviceHeight) - Int(navView.frame.size.height) - SharedData.bottomSafeAreaHeight - kTabBarHeight)
        
        recordLabel.text = ""
        
        let hexColorString = self.selectedTeam?.teamColor
        let currentTeamColor = ColorHelper.color(fromHexString: hexColorString, colorCorrection: true)!
        navView.backgroundColor = currentTeamColor
        
        let gameAttentionNib = Bundle.main.loadNibNamed("GamesNeedAttentionHeaderViewCell", owner: self, options: nil)
        gameAttentionHeaderView = gameAttentionNib![0] as? GamesNeedAttentionHeaderViewCell
        gameAttentionHeaderView.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 56)
        gameAttentionHeaderView.gamesNeedAttentionButton.addTarget(self, action: #selector(attentionHeaderButtonTouched), for: .touchUpInside)
        
        let scheduleHeaderNib = Bundle.main.loadNibNamed("ScheduleHeaderViewCell", owner: self, options: nil)
        scheduleHeaderView = scheduleHeaderNib![0] as? ScheduleHeaderViewCell
        scheduleHeaderView.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 100)
        scheduleHeaderView.scheduleSortButton.menu = sortMenu
        scheduleHeaderView.scheduleSortButton.showsMenuAsPrimaryAction = true
        scheduleHeaderView.scheduleShowDeletedButton.addTarget(self, action: #selector(showDeletedGamesButtonTouched), for: .touchUpInside)
        scheduleHeaderView.seasonLabel.text = "20" + self.year + " " + selectedTeam!.teamLevel + " Team"
        
        let scheduleFooterNib = Bundle.main.loadNibNamed("ScheduleFooterViewCell", owner: self, options: nil)
        scheduleFooterView = scheduleFooterNib![0] as? ScheduleFooterViewCell
        scheduleFooterView.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 42)
        scheduleFooterView.scheduleCorrectionButton.addTarget(self, action: #selector(scheduleCorrectionButtonTouched), for: .touchUpInside)
        scheduleFooterView.scoreCorrectionButton.addTarget(self, action: #selector(scoreCorrectionButtonTouched), for: .touchUpInside)
        
        // Add the + button to the lower right corner if a team admin
        userIsAdmin = MiscHelper.isUserAnAdmin(schoolId: self.selectedTeam!.schoolId, allSeasonId: self.selectedTeam!.allSeasonId)
        
        if (userIsAdmin == true)
        {
            addButton = UIButton(type: .custom)
            addButton.frame = CGRect(x: Int(kDeviceWidth) - 76, y: Int(scheduleTableView.frame.origin.y) + Int(scheduleTableView.frame.size.height) - 76, width: 60, height: 60)
            addButton.layer.cornerRadius = addButton.frame.size.width / 2
            addButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.33).cgColor
            addButton.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
            addButton.layer.shadowOpacity = 1.0
            addButton.layer.shadowRadius = 4.0
            addButton.clipsToBounds = false
            addButton.backgroundColor = currentTeamColor
            addButton.setImage(UIImage(named: "WhitePlus"), for: .normal)
            addButton.addTarget(self, action: #selector(addButtonTouched), for: .touchUpInside)
            self.view.addSubview(addButton)
        }
        
        print(selectedTeam!.gender, selectedTeam!.teamLevel, selectedTeam!.sport, selectedTeam!.season, self.year)
        
        scheduleTableView.isHidden = true
        self.getSchedule()
        /*
        // Add a device orientation handler if on an iPhone
        if (SharedData.deviceType as! DeviceType == DeviceType.iphone)
        {
            NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        }
        */
        
        // Add an observer for the app going into the background
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
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
        
        if (deletedGamesVC != nil)
        {
            if (deletedGamesVC.gameRestored == true)
            {
                self.getSchedule()
            }
        }
        
        // Show the ad
        self.loadBannerViews()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (deletedGamesVC != nil)
        {
            deletedGamesVC = nil
        }
        
        if (scoreCorrectionVC != nil)
        {
            scoreCorrectionVC = nil
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
        
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
}
