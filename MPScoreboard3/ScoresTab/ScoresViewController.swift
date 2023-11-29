//
//  ScoresViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/1/21.
//

import UIKit
import GoogleMobileAds
//import MoPubAdapter
import DTBiOSSDK
import AdSupport
import AppTrackingTransparency

class ScoresViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, CalendarViewControllerDelegate, NewModalWebViewControllerDelegate, DTBAdCallback, GADBannerViewDelegate, ToolTipFourDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var scoresTableView: UITableView!
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var largeTitleLabel: UILabel!
    @IBOutlet weak var dateContainerScrollView : UIScrollView!
    @IBOutlet weak var testButton : UIButton!
    
    private var profileButton : UIButton?
    private var leftShadow : UIImageView!
    private var rightShadow : UIImageView!
    private var scoreboardHeaderView : UIView!
    private var scoreboardsScrollView : UIScrollView!
    private var leftScoreboardsShadow : UIImageView!
    private var rightScoreboardsShadow : UIImageView!
    private var scoreboardRefreshControl = UIRefreshControl()
    
    private var searchVC: SearchViewController!
    private var athleteProfileVC: NewAthleteProfileViewController!
    private var fanProfileVC: NewFanProfileViewController!
    private var parentProfileVC: NewParentProfileViewController!
    private var coachProfileVC: NewCoachProfileViewController!
    private var adProfileVC: NewADProfileViewController!
    private var guestProfileVC: NewGuestProfileViewController!
    private var calendarVC: CalendarViewController!
    private var modalWebVC: NewModalWebViewController!
    private var addScoreboardVC: AddScoreboardViewController!
    private var scoreboardContestListVC: NewScoreboardContestListViewController!
    private var videoPlayerVC: VideoPlayerViewController!
    private var teamDetailVC: TeamDetailViewController!
    private var athleteDetailVC: NewAthleteDetailViewController!
    
    private var bottomTabBarPad = 0
    private var selectedDateIndex = -1
    
    private var availableDatesArray = [] as! Array<Date>
    private var allContestsArray = [] as! Array<Dictionary<String,Any>>
    private var contestResultsArray = [] as! Array<Dictionary<String,Any>>
    private var scoreboardsArray = [] as Array
    
    private var googleBannerAdView: GAMBannerView!
    private var bannerBackgroundView: UIVisualEffectView! //UIImageView!
    
    private var trackingGuid = ""
    private var tickTimer: Timer!
    private var skeletonOverlay: SkeletonHUD!
    private var toolTipFourVC: ToolTipFourViewController!
    private var toolTipActive = false
    
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
        NimbusBidder(request: .forBannerAd(position: "scores")),
        APSBidder(adLoader: apsLoader)
    ]
    
    lazy var dynamicPriceManager = DynamicPriceManager(bidders: bidders, refreshInterval: TimeInterval(kNimbusAdTimerValue))
    
    // MARK: - ModalWebViewControllerDelegate
    
    func modalWebViewControllerCancelButtonTouched()
    {
        self.dismiss(animated: true)
        {
            self.modalWebVC = nil
            self.tabBarController?.tabBar.isHidden = false
            
            self.loadBannerViews()
        }
    }
    
    // MARK: - CalendarViewControllerDelegates
    
    func calendarViewControllerCancelButtonTouched()
    {
        self.dismiss(animated: true)
        {
            self.tabBarController?.tabBar.isHidden = false
            self.calendarVC = nil
        }
    }
    
    func calendarViewControllerSelectedDateButtonTouched()
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E MMM d"
        var dateString = dateFormatter.string(from: calendarVC.selectedDate!).uppercased()
        
        let today = Date()
        let calendar = Calendar(identifier: .gregorian)
        
        // Change the dateString to "TODAY"
        if (calendar.isDate(today, inSameDayAs: calendarVC.selectedDate!) == true)
        {
            dateString = "TODAY"
        }
        
        var activeButtonCenterX = 0
        
        // First look for an exact match
        for item in dateContainerScrollView.subviews
        {
            let button = item as! UIButton
 
            if (button.titleLabel?.text == dateString)
            {
                activeButtonCenterX = Int(button.center.x)
                
                // Auto-touch the button so it gets highlighted
                self.dateButtonTouched(button)
                break
            }
        }
        
        // Scroll today's date to the middle
        var scrollOffset = 0
        if (activeButtonCenterX > Int(dateContainerScrollView.frame.size.width / 2))
        {
            scrollOffset = activeButtonCenterX - Int(dateContainerScrollView.frame.size.width / 2)
            dateContainerScrollView.contentOffset = CGPoint(x: scrollOffset, y: 0)
        }
        
        self.dismiss(animated: true)
        {
            self.tabBarController?.tabBar.isHidden = false
            self.calendarVC = nil
        }
    }
    
    // MARK: - Show Video Player
    
    private func showVideoPlayer(videoId: String, trackingKey: String, trackingContextData: Dictionary<String,Any>)
    {
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
        
        self.clearBannerAd()
        
        if (videoPlayerVC != nil)
        {
            videoPlayerVC = nil
        }
        
        videoPlayerVC = VideoPlayerViewController(nibName: "VideoPlayerViewController", bundle: nil)
        videoPlayerVC.videoIdString = videoId
        videoPlayerVC.trackingContextData = trackingContextData
        videoPlayerVC.trackingKey = trackingKey
        videoPlayerVC.modalPresentationStyle = .fullScreen
        self.present(videoPlayerVC, animated: true)
        {
            
        }
    }
    
    // MARK: - Show ModalWebVC
    
    private func showModalWebViewController(urlString: String, showShareButton: Bool, ftag: String, contestId: String, showVideoBanner: Bool)
    {
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
        
        self.clearBannerAd()
        
        if (modalWebVC != nil)
        {
            modalWebVC = nil
        }
                
        modalWebVC = NewModalWebViewController(nibName: "NewModalWebViewController", bundle: nil)
        modalWebVC.delegate = self
        modalWebVC.modalPresentationStyle = .overCurrentContext
        modalWebVC.titleString = ""
        modalWebVC.urlString = urlString
        modalWebVC.showLoadingOverlay = true
        modalWebVC.showScrollIndicators = false
        modalWebVC.showBannerAd = true
        modalWebVC.showVideoBanner = showVideoBanner
        modalWebVC.adId = kUserDefaults.value(forKey: kScoresBannerAdIdKey) as! String
        modalWebVC.showShareButton = showShareButton
        modalWebVC.enableAdobeQueryParameter = true
        //modalWebVC.trackingContext = [:]
        modalWebVC.ftag = ftag
        modalWebVC.contestId = contestId
        modalWebVC.trackingKey = "score-home"
        modalWebVC.trackingContextData = kEmptyTrackingContextData
        modalWebVC.sport = ""
        
        self.tabBarController?.tabBar.isHidden = true
        self.present(modalWebVC, animated: true)
        {
            
        }
    }
    
    // MARK: - Notification and Deep Link Handlers
    
    @objc private func showScoresWebBrowser(notification: Notification)
    {
        if let urlString = notification.userInfo?["url"] as? String
        {
            print(urlString)
            
            if (urlString.count > 0)
            {
                var fixedUrlString = ""
                
                if ((urlString.contains("http://") == true) || (urlString.contains("https://") == true))
                {
                    fixedUrlString = urlString
                }
                else
                {
                    fixedUrlString = String(format: "https://%@", urlString)
                }
                
                let ftag = notification.userInfo!["ftag"] as! String
                let itemType = notification.userInfo!["itemType"] as? String ?? ""
                
                // Added in V6.2.8 to allow video banner ads to be displayed
                if (itemType.lowercased() == "contest")
                {
                    // The video banner can be displayed from the notification
                    self.showModalWebViewController(urlString: fixedUrlString, showShareButton: true, ftag: ftag, contestId: "", showVideoBanner: true)
                }
                else
                {
                    self.showModalWebViewController(urlString: fixedUrlString, showShareButton: true, ftag: ftag, contestId: "", showVideoBanner: false)
                }
            }
        }
    }
    
    @objc private func showCareerDeepLink(notification: Notification)
    {
        let careerId = notification.userInfo!["careerId"] as! String
        let ftag = notification.userInfo!["ftag"] as! String
        //print(careerId)
        
        NewFeeds.getCareerDeepLinkInfo(careerId: careerId) { careerInfo, error in
            
            if (error == nil)
            {
                let firstName = careerInfo!["firstName"] as? String ?? ""
                let lastName = careerInfo!["lastName"] as? String ?? ""
                let careerProfileId = careerInfo!["careerId"] as! String
                let schoolName = careerInfo!["schoolName"] as! String
                let schoolState = careerInfo!["schoolState"] as! String
                let schoolCity = careerInfo!["schoolCity"] as! String
                let schoolId = careerInfo!["schoolId"] as! String
                let schoolColor = careerInfo!["schoolColor"] as! String
                let schoolMascotUrl = careerInfo!["schoolMascotUrl"] as! String
                let photoUrl = careerInfo!["photoUrl"] as! String
                
                let selectedAthlete = Athlete(firstName: firstName, lastName: lastName, schoolName: schoolName, schoolState: schoolState, schoolCity: schoolCity, schoolId: schoolId, schoolColor: schoolColor, schoolMascotUrl: schoolMascotUrl, careerId: careerProfileId, photoUrl: photoUrl)
                
                if (self.athleteDetailVC != nil)
                {
                    self.athleteDetailVC = nil
                }
                
                self.athleteDetailVC = NewAthleteDetailViewController(nibName: "NewAthleteDetailViewController", bundle: nil)
                self.athleteDetailVC.selectedAthlete = selectedAthlete
                self.athleteDetailVC.ftag = ftag
                
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
                
                self.athleteDetailVC.showSaveFavoriteButton = showSaveFavoriteButton
                self.athleteDetailVC.showRemoveFavoriteButton = showRemoveFavoriteButton

                self.navigationController?.pushViewController(self.athleteDetailVC, animated: true)
            }
        }
    }
    
    @objc private func showTeamDeepLink(notification: Notification)
    {
        /*
        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Deep Link", message: "Team deep link.", lastItemCancelType: false) { tag in
            
        }
        */
        let schoolId = notification.userInfo!["schoolId"] as! String
        let ssid = notification.userInfo!["ssid"] as! String
        let ftag = notification.userInfo!["ftag"] as! String
        let tabName = notification.userInfo!["tabName"] as? String ?? ""
        
        NewFeeds.getTeamDeepLinkInfo(schoolId: schoolId, ssid: ssid) { teamInfo, error in
            
            if (error == nil)
            {
                /*
                 "teamId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                     "sportSeasonId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                     "allSeasonId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                     "gender": "string",
                     "sport": "string",
                     "level": "string",
                     "season": "string",
                     "year": "string",
                     "schoolName": "string",
                     "schoolFormattedName": "string",
                     "schoolCity": "string",
                     "schoolState": "string",
                     "schoolMascot": "string",
                     "schoolMascotUrl": "string",
                     "schoolColor": "string"
                 */
                let schoolId = teamInfo!["teamId"] as! String
                let name = teamInfo!["schoolName"] as! String
                let city = teamInfo!["schoolCity"] as! String
                let state = teamInfo!["schoolState"] as! String
                let fullName = String(format: "%@ (%@, %@)", name, city, state)
                let gender = teamInfo!["gender"] as! String
                let sport = teamInfo!["sport"] as! String
                let level = teamInfo!["level"] as! String
                let season = teamInfo!["season"] as! String
                let allSeasonId = teamInfo!["allSeasonId"] as! String
                let sportSeasonId = teamInfo!["sportSeasonId"] as! String
                let mascotUrlString = teamInfo!["schoolMascotUrl"] as! String
                let hexColorString = teamInfo!["schoolColor"] as! String
                
                if (self.teamDetailVC != nil)
                {
                    self.teamDetailVC = nil
                }
                
                var showSaveFavoriteButton = false
                var showRemoveFavoriteButton = false
                
                // Check to see if the team is already a favorite
                let isFavoriteTeam = MiscHelper.isTeamMyFavoriteTeamWithId(schoolId: schoolId, gender: gender, sport: sport, teamLevel: level, season: season).isFavorite
                let teamId = MiscHelper.isTeamMyFavoriteTeamWithId(schoolId: schoolId, gender: gender, sport: sport, teamLevel: level, season: season).teamId
                
                let selectedTeamObj = Team(teamId: teamId, allSeasonId: allSeasonId, gender: gender, sport: sport, teamColor: hexColorString, mascotUrl: mascotUrlString, schoolName: name, teamLevel: level, schoolId: schoolId, schoolState: state, schoolCity: city, schoolFullName: fullName, season: season, notifications: [])
                
                if (isFavoriteTeam == true)
                {
                    showSaveFavoriteButton = false
                    showRemoveFavoriteButton = true
                }
                else
                {
                    showSaveFavoriteButton = true
                    showRemoveFavoriteButton = false
                }
                
                self.teamDetailVC = TeamDetailViewController(nibName: "TeamDetailViewController", bundle: nil)
                self.teamDetailVC.selectedTeam = selectedTeamObj
                self.teamDetailVC.selectedSSID = sportSeasonId
                self.teamDetailVC.showSaveFavoriteButton = showSaveFavoriteButton
                self.teamDetailVC.showRemoveFavoriteButton = showRemoveFavoriteButton
                self.teamDetailVC.ftag = ftag
                self.teamDetailVC.tabName = tabName
                self.navigationController?.pushViewController(self.teamDetailVC, animated: true)
            }
        }
    }
    
    // MARK: - Show Guest Profile VC
    
    private func showGuestProfileVC()
    {
        guestProfileVC = NewGuestProfileViewController(nibName: "NewGuestProfileViewController", bundle: nil)
        let guestProfileNav = TopNavigationController()
        guestProfileNav.viewControllers = [guestProfileVC] as Array
        guestProfileNav.modalPresentationStyle = .fullScreen
        self.present(guestProfileNav, animated: true)
        {
            
        }
    }
    
    // MARK: - Load User Image
    
    @objc private func loadUserImage()
    {
        // Get the user image
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        if (userId == kTestDriveUserId)
        {
            let image = UIImage.init(named: "EmptyProfileButton")
            profileButton?.setImage(image, for: .normal)
            return
        }
        
        if ((MiscHelper.userIsCoach().isCoach == false) && (MiscHelper.userIsAnAD().isAD == false))
        {
            // Load the user image or the career image
            let canEditCareer = MiscHelper.userCanEditCareer().canEdit
            
            if (canEditCareer == true)
            {
                let isAthlete = MiscHelper.userCanEditCareer().isAthlete
                let isParent = MiscHelper.userCanEditCareer().isParent
                if ((isAthlete == true) && (isParent == false))
                {
                    self.loadCareerImage()
                    return
                }
            }
        }
        
        let userPhotoUrlString = kUserDefaults.string(forKey: kUserPhotoUrlKey)
        
        if (userPhotoUrlString!.count > 0)
        {
            let url = URL(string: userPhotoUrlString!)
            
            // Get the data and make an image
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        self.profileButton?.setImage(image, for: .normal)
                    }
                    else
                    {
                        let image = UIImage.init(named: "EmptyProfileButton")
                        self.profileButton?.setImage(image, for: .normal)
                    }
                }
            }
        }
        else
        {
            let image = UIImage.init(named: "EmptyProfileButton")
            self.profileButton?.setImage(image, for: .normal)
        }
    }
    
    // MARK: - Load Career Image
    
    private func loadCareerImage()
    {
        let careerPhotoUrlString = kUserDefaults.string(forKey: kUserCareerPhotoUrlKey)
        
        if (careerPhotoUrlString!.count > 0)
        {
            let url = URL(string: careerPhotoUrlString!)
            
            // Get the data and make an image
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        self.profileButton?.setImage(image, for: .normal)
                    }
                    else
                    {
                        let image = UIImage.init(named: "EmptyProfileButton")
                        self.profileButton?.setImage(image, for: .normal)
                    }
                }
            }
        }
        else
        {
            let image = UIImage.init(named: "EmptyProfileButton")
            self.profileButton?.setImage(image, for: .normal)
        }
    }
    
    // MARK: - Get Favorite Teams Contests
    
    private func getFavoriteTeamsContests()
    {
        let favoriteTeams = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey) as! Array<Dictionary<String,Any>>
        
        if (favoriteTeams.count == 0)
        {
            contestResultsArray.removeAll()
            scoresTableView.isHidden = false
            scoresTableView.reloadData()
            return
        }
        
        // Build a teams array for the feed from the favoriteTeams
        var teams = [] as Array<Dictionary<String,String>>
        
        for favorite in favoriteTeams
        {
            let schoolId = favorite[kNewSchoolIdKey] as! String
            let allSeasonId = favorite[kNewAllSeasonIdKey] as! String
            let team = ["teamId":schoolId, "allSeasonId": allSeasonId]
            
            teams.append(team)
        }
        
        self.availableDatesArray.removeAll()
        self.allContestsArray.removeAll()
                
        NewFeeds.getFavoriteTeamContests(teams) { results, error in
            
            if (error == nil)
            {
                print("Get Favorite Team Contests Success")
                
                self.allContestsArray = results!
                
                for result in results!
                {
                    var contestDateString = result["date"] as! String
                    contestDateString = contestDateString.replacingOccurrences(of: "Z", with: "")
                    let dateFormatter = DateFormatter()
                    dateFormatter.isLenient = true
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
                    //dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                    let contestDate = dateFormatter.date(from: contestDateString)
                           
                    if (contestDate != nil)
                    {
                        // Add the date object to the array
                        self.availableDatesArray.append(contestDate!)
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
                
                if (self.availableDatesArray.count > 0)
                {
                    self.addDateButtons()
                }
                else
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "There are no contests scheduled for your favorite teams.", lastItemCancelType: false) { tag in
                        
                    }
                }
            }
            else
            {
                print("Get Favorite Team Contests Failed")
            }
            
            self.scoresTableView.isHidden = false
            self.scoresTableView.reloadData()
        }
    }
    
    // MARK: - Get Contest Results
    
    private func getContestResults()
    {
        // This handles the deleted game corner case where the date exists, but the contest does not
        if ((allContestsArray.count - 1) < selectedDateIndex)
        {
            return
        }
        
        // Extract the contestIds for the selected date
        //print("Index:" + String(selectedDateIndex))
        //print("All ContestArray: " + String(allContestsArray.count))
        //var contestObject = [:] as Dictionary<String,Any>
        //if (selectedDateIndex < 0)
        //{
            //contestObject = allContestsArray[0]
        //}
        //else
        //{
            let contestObject = allContestsArray[selectedDateIndex]
        //}
        let contests = contestObject["contestIds"] as! Array<String>
        
        contestResultsArray.removeAll()
        
        if (scoreboardRefreshControl.isRefreshing == false)
        {
            //MBProgressHUD.showAdded(to: self.view, animated: true)
            if (skeletonOverlay == nil)
            {
                skeletonOverlay = SkeletonHUD()
                let height = kDeviceHeight - titleContainerView.frame.origin.y - titleContainerView.frame.size.height - CGFloat(kTabBarHeight) - CGFloat(SharedData.bottomSafeAreaHeight)
                
                skeletonOverlay.show(skeletonFrame: CGRect(x: 0, y: titleContainerView.frame.origin.y + titleContainerView.frame.size.height, width: kDeviceWidth, height: height), imageType: .scores, parentView: self.view)
            }
        }
        
        NewFeeds.getFavoriteTeamContestResults(contests: contests) { results, error in
            
            self.scoresTableView.isHidden = false
            
            // Hide the busy indicator
            if (self.scoreboardRefreshControl.isRefreshing == false)
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                {
                    //MBProgressHUD.hide(for: self.view, animated: true)
                    if (self.skeletonOverlay != nil)
                    {
                        self.skeletonOverlay.hide()
                        self.skeletonOverlay = nil
                    }
                }
            }
            else
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                { [self] in
                    self.scoreboardRefreshControl.endRefreshing()
                    self.scoresTableView.reloadData()
                }
            }
            
            if (error == nil)
            {
                print("Get Contest Results Success")
                self.contestResultsArray = results!
                
                if (self.contestResultsArray.count == 0)
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "No Contests", message: "There were no contests found for this date.", lastItemCancelType: false) { tag in
                    
                    }
                }
            }
            else
            {
                print("Get Contest Results Failed")
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "There was an error while retrieving the contests for this date.", lastItemCancelType: false) { tag in
                    
                }
            }
            
            self.scoresTableView.reloadData()
        }
    }
    
    // MARK: - Team A/B Helper
    
    private func teamInfoForContest(contest: Dictionary<String,Any>) -> TeamLight
    {
        let teams = contest["teams"] as! Array<Dictionary<String,Any>>
        let teamA = teams.first
        let teamB = teams.last
        let schoolIdA = teamA!["teamId"] as? String ?? ""
        let allSeasonlIdA = teamA!["allSeasonId"] as? String ?? ""
        let mascotUrlA = teamA!["mascotUrl"] as? String ?? ""
        let colorA = teamA!["color1"] as? String ?? kMissingSchoolColor
        let schoolIdB = teamB!["teamId"] as? String ?? ""
        let allSeasonlIdB = teamB!["allSeasonId"] as? String ?? ""
        let mascotUrlB = teamB!["mascotUrl"] as? String ?? ""
        let colorB = teamB!["color1"] as? String ?? kMissingSchoolColor
        
        // Iterate through the user's favorites to find a matching schoolId and allSeasonId
        let favoriteTeams = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
        
        var matchedTeam = TeamLight(gender: "", sport: "", teamLevel: "", teamColor: "", mascotUrl: "", schoolName: "")
        
        for item in favoriteTeams!
        {
            let favoriteTeam = item as! Dictionary<String,Any>
            let schoolId = favoriteTeam[kNewSchoolIdKey] as! String
            let allSeasonId = favoriteTeam[kNewAllSeasonIdKey] as! String
  
            if ((schoolId == schoolIdA) && (allSeasonId == allSeasonlIdA))
            {
                matchedTeam.schoolName = favoriteTeam[kNewSchoolNameKey] as! String
                matchedTeam.teamLevel = favoriteTeam[kNewLevelKey] as! String
                matchedTeam.gender = favoriteTeam[kNewGenderKey] as! String
                matchedTeam.sport = favoriteTeam[kNewSportKey] as! String
                matchedTeam.teamColor = colorA
                matchedTeam.mascotUrl = mascotUrlA
                break
            }
            
            if ((schoolId == schoolIdB) && (allSeasonId == allSeasonlIdB))
            {
                matchedTeam.schoolName = favoriteTeam[kNewSchoolNameKey] as! String
                matchedTeam.teamLevel = favoriteTeam[kNewLevelKey] as! String
                matchedTeam.gender = favoriteTeam[kNewGenderKey] as! String
                matchedTeam.sport = favoriteTeam[kNewSportKey] as! String
                matchedTeam.teamColor = colorB
                matchedTeam.mascotUrl = mascotUrlB
                break
            }
        }
            
        return matchedTeam
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (contestResultsArray.count > 0)
        {
            return contestResultsArray.count
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (contestResultsArray.count == 0)
        {
            return 60
        }
        
        // This keeps the code from a crash if the user changes the date while scrolling
        if (contestResultsArray.count > indexPath.row)
        {
            let contest = contestResultsArray[indexPath.row]
            let calculatedFieldsObj = contest["calculatedFields"] as! Dictionary<String,Any>
            let contestState = calculatedFieldsObj["contestState"] as! Int
            
            // Contest state enums
            // 0: Unknown
            // 1: Deleted
            // 2: Pregame
            // 3: In Progress
            // 4: Boxscore
            // 5: Score not Reported
            
            switch contestState
            {
            case 2:
                //let sport = contest["sport"] as! String
                
                // Use the basic cell if not football or basketball
                //if (sport == "Football") || (sport == "Basketball")
                // This has been changed to use a flag in V6.0.5
                let teams = contest["teams"] as! Array<Dictionary<String,Any>>
                let teamA = teams[0]
                let teamB = teams[1]
                let isScoreSignupAvailableA = teamA["isScorerSignUpAvailable"] as! Bool
                let isScoreSignupAvailableB = teamB["isScorerSignUpAvailable"] as! Bool
                
                if ((isScoreSignupAvailableA == true) || (isScoreSignupAvailableB == true))
                {
                    return 234 // PreGameWithLive
                }
                else
                {
                    //return 138 // Basic
                    let nfhsStreamUrl = contest["nfhsStreamUrl"] as! String
                    
                    if (nfhsStreamUrl.count == 0)
                    {
                        return 138 // Basic
                    }
                    else
                    {
                        return 234 // LiveWithVideo
                    }
                }
            case 3:
                let nfhsStreamUrl = contest["nfhsStreamUrl"] as! String
                
                if (nfhsStreamUrl.count == 0)
                {
                    return 138 // Basic
                }
                else
                {
                    return 234 // LiveWithVideo
                }
            case 4:
                let videos = contest["videos"] as! Array<Dictionary<String,Any>>
                
                if (videos.count > 0)
                {
                    return 234
                }
                else
                {
                    return 138
                }
            case 5:
                let videos = contest["videos"] as! Array<Dictionary<String,Any>>
                
                if (videos.count > 0)
                {
                    return 262
                }
                else
                {
                    return 166
                }
            default:
                return 44
            }
        }
        else
        {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return scoreboardHeaderView.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (contestResultsArray.count == 0)
        {
            return 0.01
        }
        
        // Calculate the height of the cells to see if they are less than the visible height or exceed the visible height by at least 80. If they don't then add some footer padding.
        
        // Includes the banner height
        let visibleHeight = Int(kDeviceHeight) - Int(fakeStatusBar.frame.size.height) - Int(navView.frame.size.height) - Int(titleContainerView.frame.size.height) - kTabBarHeight - SharedData.bottomSafeAreaHeight - 62
        
        var contentHeight = Int(scoreboardHeaderView.frame.size.height)
        
        for contest in contestResultsArray
        {
            let calculatedFieldsObj = contest["calculatedFields"] as! Dictionary<String,Any>
            let contestState = calculatedFieldsObj["contestState"] as! Int
            
            // Contest state enums
            // 0: Unknown
            // 1: Deleted
            // 2: Pregame
            // 3: In Progress
            // 4: Boxscore
            // 5: Score not Reported
            
            switch contestState
            {
            case 2:
                let sport = contest["sport"] as! String
                
                // Use the basic cell if not football or basketball
                if (sport == "Football") || (sport == "Basketball")
                {
                    contentHeight += 234 // PreGameWithLive
                }
                else
                {
                    contentHeight += 138 // Basic
                }
            case 3:
                let nfhsStreamUrl = contest["nfhsStreamUrl"] as! String
                
                if (nfhsStreamUrl.count == 0)
                {
                    contentHeight += 138 // Basic
                }
                else
                {
                    contentHeight += 234 // LiveGameWithVideo
                }
            case 4:
                let videos = contest["videos"] as! Array<Dictionary<String,Any>>
                
                if (videos.count > 0)
                {
                    contentHeight += 234
                }
                else
                {
                    contentHeight += 138
                }
            case 5:
                let videos = contest["videos"] as! Array<Dictionary<String,Any>>
                
                if (videos.count > 0)
                {
                    contentHeight += 262
                }
                else
                {
                    contentHeight += 166
                }
            default:
                contentHeight += 0
            }
        }
        
        // Calculate the pad amount
        if (contentHeight <= visibleHeight)
        {
            // If the content height is less than the visible height, use the difference plus 150
            return CGFloat(visibleHeight - contentHeight + 150)
        }
        else if ((contentHeight - 150) > visibleHeight)
        {
            // If the content height is 150 pixels greater than the visible height then add enough pad for the banner ad
            return 60.0
        }
        else
        {
            // Add enough pad to add up to 150
            let overhang = contentHeight - visibleHeight
            return CGFloat(150 - overhang)
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return scoreboardHeaderView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (contestResultsArray.count == 0)
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            
            if (cell == nil)
            {
                cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            }
            
            cell?.contentView.backgroundColor = UIColor.mpHeaderBackgroundColor()
            cell?.selectionStyle = .none
            cell?.textLabel?.text = ""
            cell?.textLabel?.textColor = UIColor.mpBlackColor()
            cell?.textLabel?.font = UIFont.mpItalicFontWith(size: 17)
            cell?.textLabel?.text = "No Favorite Teams"
            
            return cell!
        }
        
        // This keeps the code from a crash if the user changes the date while scrolling
        if (contestResultsArray.count > indexPath.row)
        {
            let contest = contestResultsArray[indexPath.row]
            let calculatedFieldsObj = contest["calculatedFields"] as! Dictionary<String,Any>
            let contestState = calculatedFieldsObj["contestState"] as! Int
            //let sport = contest["sport"] as! String
            
            // Get the matching team info so the left portion of the cells can be loaded
            let matchingTeam = self.teamInfoForContest(contest: contest)
            
            // Contest state enums
            // 0: Unknown
            // 1: Deleted
            // 2: Pregame
            // 3: In Progress
            // 4: Boxscore
            // 5: Score not Reported

            
            // Decide what type of cell to use based upon game state and other critereon
            if (contestState == 2)
            {
                // Use the basic cell or liveGameWithVideo cells if not football or basketball
                //if (sport == "Football") || (sport == "Basketball")
                // The sport check has been replaced by a flag in V6.0.5
                let teams = contest["teams"] as! Array<Dictionary<String,Any>>
                let teamA = teams[0]
                let teamB = teams[1]
                let isScoreSignupAvailableA = teamA["isScorerSignUpAvailable"] as! Bool
                let isScoreSignupAvailableB = teamB["isScorerSignUpAvailable"] as! Bool
                
                if ((isScoreSignupAvailableA == true) || (isScoreSignupAvailableB == true))
                {
                    // PreGameWithLiveCell
                    var cell = tableView.dequeueReusableCell(withIdentifier: "PreGameWithLiveTableViewCell") as? PreGameWithLiveTableViewCell
                    
                    if (cell == nil)
                    {
                        let nib = Bundle.main.loadNibNamed("PreGameWithLiveTableViewCell", owner: self, options: nil)
                        cell = nib![0] as? PreGameWithLiveTableViewCell
                    }
                    
                    cell?.selectionStyle = .none
                    
                    let color = ColorHelper.color(fromHexString: matchingTeam.teamColor, colorCorrection: true)
                    cell?.addShapeLayers(color: color!)
                    
                    cell?.loadData(contest, teamInfo: matchingTeam)
                    
                    // Add the button targets
                    cell?.bottomLeftButton.tag = 100 + indexPath.row
                    cell?.bottomLeftButton.addTarget(self, action: #selector(leftScorerButtonTouched(_:)), for: .touchUpInside)
                    
                    cell?.bottomRightButton.tag = 100 + indexPath.row
                    cell?.bottomRightButton.addTarget(self, action: #selector(rightScorerButtonTouched(_:)), for: .touchUpInside)
                    
                    cell?.viewLiveButton.tag = 100 + indexPath.row
                    cell?.viewLiveButton.addTarget(self, action: #selector(liveGameVideoPlayButtonTouched(_:)), for: .touchUpInside)
                                        
                    return cell!
                }
                else
                {
                    // Use either the Basic or the LiveGameWithVideo cell
                    let nfhsStreamUrl = contest["nfhsStreamUrl"] as! String
                    
                    if (nfhsStreamUrl.count == 0)
                    {
                        // BasicScoresCell
                        var cell = tableView.dequeueReusableCell(withIdentifier: "BasicScoresTableViewCell") as? BasicScoresTableViewCell
                        
                        if (cell == nil)
                        {
                            let nib = Bundle.main.loadNibNamed("BasicScoresTableViewCell", owner: self, options: nil)
                            cell = nib![0] as? BasicScoresTableViewCell
                        }
                        
                        cell?.selectionStyle = .none
                        
                        let color = ColorHelper.color(fromHexString: matchingTeam.teamColor, colorCorrection: true)
                        cell?.addShapeLayers(color: color!)
                        
                        cell?.loadData(contest, teamInfo: matchingTeam)
                        
                        return cell!
                    }
                    else
                    {
                        // LiveGameWithVideoCell
                        var cell = tableView.dequeueReusableCell(withIdentifier: "LiveGameWithVideoTableViewCell") as? LiveGameWithVideoTableViewCell
                        
                        if (cell == nil)
                        {
                            let nib = Bundle.main.loadNibNamed("LiveGameWithVideoTableViewCell", owner: self, options: nil)
                            cell = nib![0] as? LiveGameWithVideoTableViewCell
                        }
                        
                        cell?.selectionStyle = .none
                        
                        let color = ColorHelper.color(fromHexString: matchingTeam.teamColor, colorCorrection: true)
                        cell?.addShapeLayers(color: color!)
                        
                        cell?.loadData(contest, teamInfo: matchingTeam)
                        cell?.videoPlayButton.tag = 100 + indexPath.row
                        cell?.videoPlayButton.addTarget(self, action: #selector(liveGameVideoPlayButtonTouched(_:)), for: .touchUpInside)
                        
                        return cell!
                    }
                    /*
                    // BasicScoresCell
                    var cell = tableView.dequeueReusableCell(withIdentifier: "BasicScoresTableViewCell") as? BasicScoresTableViewCell
                    
                    if (cell == nil)
                    {
                        let nib = Bundle.main.loadNibNamed("BasicScoresTableViewCell", owner: self, options: nil)
                        cell = nib![0] as? BasicScoresTableViewCell
                    }
                    
                    cell?.selectionStyle = .none
                    
                    let color = ColorHelper.color(fromHexString: matchingTeam.teamColor, colorCorrection: true)
                    cell?.addShapeLayers(color: color!)
                    
                    cell?.loadData(contest, teamInfo: matchingTeam)
                    
                    return cell!
                    */
                }
            }
            else if (contestState == 3)
            {
                // Use either the Basic or the LiveGameWithVideo cell
                let nfhsStreamUrl = contest["nfhsStreamUrl"] as! String
                
                if (nfhsStreamUrl.count == 0)
                {
                    // BasicScoresCell
                    var cell = tableView.dequeueReusableCell(withIdentifier: "BasicScoresTableViewCell") as? BasicScoresTableViewCell
                    
                    if (cell == nil)
                    {
                        let nib = Bundle.main.loadNibNamed("BasicScoresTableViewCell", owner: self, options: nil)
                        cell = nib![0] as? BasicScoresTableViewCell
                    }
                    
                    cell?.selectionStyle = .none
                    
                    let color = ColorHelper.color(fromHexString: matchingTeam.teamColor, colorCorrection: true)
                    cell?.addShapeLayers(color: color!)
                    
                    cell?.loadData(contest, teamInfo: matchingTeam)
                    
                    return cell!
                }
                else
                {
                    // LiveGameWithVideoCell
                    var cell = tableView.dequeueReusableCell(withIdentifier: "LiveGameWithVideoTableViewCell") as? LiveGameWithVideoTableViewCell
                    
                    if (cell == nil)
                    {
                        let nib = Bundle.main.loadNibNamed("LiveGameWithVideoTableViewCell", owner: self, options: nil)
                        cell = nib![0] as? LiveGameWithVideoTableViewCell
                    }
                    
                    cell?.selectionStyle = .none
                    
                    let color = ColorHelper.color(fromHexString: matchingTeam.teamColor, colorCorrection: true)
                    cell?.addShapeLayers(color: color!)
                    
                    cell?.loadData(contest, teamInfo: matchingTeam)
                    cell?.videoPlayButton.tag = 100 + indexPath.row
                    cell?.videoPlayButton.addTarget(self, action: #selector(liveGameVideoPlayButtonTouched(_:)), for: .touchUpInside)
                    
                    return cell!
                }
            }
            else if (contestState == 4)
            {
                let videos = contest["videos"] as! Array<Dictionary<String,Any>>
                if (videos.count == 0)
                {
                    // BasicScoresCell
                    var cell = tableView.dequeueReusableCell(withIdentifier: "BasicScoresTableViewCell") as? BasicScoresTableViewCell
                    
                    if (cell == nil)
                    {
                        let nib = Bundle.main.loadNibNamed("BasicScoresTableViewCell", owner: self, options: nil)
                        cell = nib![0] as? BasicScoresTableViewCell
                    }
                    
                    cell?.selectionStyle = .none
                    
                    let color = ColorHelper.color(fromHexString: matchingTeam.teamColor, colorCorrection: true)
                    cell?.addShapeLayers(color: color!)
                    
                    cell?.loadData(contest, teamInfo: matchingTeam)
                    
                    return cell!
                }
                else
                {
                    // PostGameWithVideoCell
                    var cell = tableView.dequeueReusableCell(withIdentifier: "PostGameWithVideoTableViewCell") as? PostGameWithVideoTableViewCell
                    
                    if (cell == nil)
                    {
                        let nib = Bundle.main.loadNibNamed("PostGameWithVideoTableViewCell", owner: self, options: nil)
                        cell = nib![0] as? PostGameWithVideoTableViewCell
                    }
                    
                    cell?.selectionStyle = .none
                    
                    let color = ColorHelper.color(fromHexString: matchingTeam.teamColor, colorCorrection: true)
                    cell?.addShapeLayers(color: color!)
                    
                    cell?.loadData(contest, teamInfo: matchingTeam)
                    
                    cell?.videoPlayButton.tag = 100 + indexPath.row
                    cell?.videoPlayButton.addTarget(self, action: #selector(videoPlayButtonTouched(_:)), for: .touchUpInside)
                    
                    return cell!
                }
            }
            else if (contestState == 5)
            {
                let videos = contest["videos"] as! Array<Dictionary<String,Any>>
                if (videos.count == 0)
                {
                    // PostGameNoScoreCell
                    var cell = tableView.dequeueReusableCell(withIdentifier: "PostGameNoScoreTableViewCell") as? PostGameNoScoreTableViewCell
                    
                    if (cell == nil)
                    {
                        let nib = Bundle.main.loadNibNamed("PostGameNoScoreTableViewCell", owner: self, options: nil)
                        cell = nib![0] as? PostGameNoScoreTableViewCell
                    }
                    
                    cell?.selectionStyle = .none
                    
                    let color = ColorHelper.color(fromHexString: matchingTeam.teamColor, colorCorrection: true)
                    cell?.addShapeLayers(color: color!)
                    
                    cell?.loadData(contest, teamInfo: matchingTeam)
                    
                    cell?.reportScoreButton.tag = 100 + indexPath.row
                    cell?.reportScoreButton.addTarget(self, action: #selector(reportScoreButtonTouched(_:)), for: .touchUpInside)
                    
                    return cell!
                }
                else
                {
                    // PostGameWithVideoNoScoreCell
                    var cell = tableView.dequeueReusableCell(withIdentifier: "PostGameWithVideoNoScoreTableViewCell") as? PostGameWithVideoNoScoreTableViewCell
                    
                    if (cell == nil)
                    {
                        let nib = Bundle.main.loadNibNamed("PostGameWithVideoNoScoreTableViewCell", owner: self, options: nil)
                        cell = nib![0] as? PostGameWithVideoNoScoreTableViewCell
                    }
                    
                    cell?.selectionStyle = .none
                    
                    let color = ColorHelper.color(fromHexString: matchingTeam.teamColor, colorCorrection: true)
                    cell?.addShapeLayers(color: color!)
                    
                    cell?.loadData(contest, teamInfo: matchingTeam)
                    
                    cell?.reportScoreButton.tag = 100 + indexPath.row
                    cell?.reportScoreButton.addTarget(self, action: #selector(reportScoreButtonTouched(_:)), for: .touchUpInside)
                    
                    cell?.videoPlayButton.tag = 100 + indexPath.row
                    cell?.videoPlayButton.addTarget(self, action: #selector(videoPlayButtonTouched(_:)), for: .touchUpInside)
                    
                    return cell!
                }
            }
            else
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
                
                if (cell == nil)
                {
                    cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
                }
                
                cell?.textLabel?.text = "Unknown Cell Type"
                
                return cell!
            }
        }
        else
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cell2")
            
            if (cell == nil)
            {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell2")
            }
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (contestResultsArray.count == 0)
        {
            return
        }
        
        let contest = contestResultsArray[indexPath.row]
        let contestId = contest["contestId"] as? String ?? ""
        let calculatedFieldsObj = contest["calculatedFields"] as! Dictionary<String,Any>
        let hasContestPage = calculatedFieldsObj["hasContestPage"] as! Bool
        
        if (hasContestPage == true)
        {
            let urlString = calculatedFieldsObj["canonicalUrl"] as? String ?? ""
            self.showModalWebViewController(urlString: urlString, showShareButton: true, ftag: "", contestId: contestId, showVideoBanner: true)
            
            /*
            let contestState = calculatedFieldsObj["contestState"] as! Int
            
            // Show the notification switch if pregame or live only
            if (contestState == 2) || (contestState == 3)
            {
                self.showModalWebViewController(urlString: urlString, showShareButton: true, ftag: "")
            }
            else
            {
                self.showModalWebViewController(urlString: urlString, showShareButton: true, ftag: "")
            }
            */
        }
        else
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Not Available", message: "There is no box score available for this game.", lastItemCancelType: false) { tag in
                
            }
        }
    }
        
    // MARK: - Button Methods
    
    @objc private func profileButtonTouched()
    {
        if (toolTipActive == true)
        {
            return
        }
        
        // Show the SettingsVC is a test drive user
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        if (userId == kTestDriveUserId)
        {
            self.showGuestProfileVC()
        }
        else
        {
            if (MiscHelper.userIsAnAD().isAD == true)
            {
                print("User is an AD")
                
                self.hidesBottomBarWhenPushed = true
                
                adProfileVC = NewADProfileViewController(nibName: "NewADProfileViewController", bundle: nil)
                adProfileVC.schoolId = MiscHelper.userIsAnAD().schoolId
                self.navigationController?.pushViewController(adProfileVC, animated: true)
                
                self.hidesBottomBarWhenPushed = false
            }
            else
            {
                if (MiscHelper.userIsCoach().isCoach == true)
                {
                    print("User is a coach")
                    
                    self.hidesBottomBarWhenPushed = true
                    
                    coachProfileVC = NewCoachProfileViewController(nibName: "NewCoachProfileViewController", bundle: nil)
                    coachProfileVC.schoolId = MiscHelper.userIsCoach().schoolId
                    coachProfileVC.ssid = MiscHelper.userIsCoach().ssid
                    self.navigationController?.pushViewController(coachProfileVC, animated: true)
                    
                    self.hidesBottomBarWhenPushed = false
                }
                else
                {
                    print("User is not a coach")
                    
                    let canEditCareer = MiscHelper.userCanEditCareer().canEdit
                    
                    if (canEditCareer == true)
                    {
                        let isAthlete = MiscHelper.userCanEditCareer().isAthlete
                        let isParent = MiscHelper.userCanEditCareer().isParent
                        let isOther = MiscHelper.userCanEditCareer().isOther
                        
                        if (isOther == false)
                        {
                            let careerId = MiscHelper.userCanEditCareer().careerId
                            
                            if (isAthlete == true) && (isParent == false)
                            {
                                self.hidesBottomBarWhenPushed = true
                                
                                athleteProfileVC = NewAthleteProfileViewController(nibName: "NewAthleteProfileViewController", bundle: nil)
                                athleteProfileVC.careerId = careerId
                                self.navigationController?.pushViewController(athleteProfileVC, animated: true)
                                
                                self.hidesBottomBarWhenPushed = false
                                return
                            }
                            
                            if (isAthlete == false) && (isParent == true)
                            {
                                self.hidesBottomBarWhenPushed = true
                                
                                parentProfileVC = NewParentProfileViewController(nibName: "NewParentProfileViewController", bundle: nil)
                                parentProfileVC.careerId = careerId
                                self.navigationController?.pushViewController(parentProfileVC, animated: true)
                                
                                self.hidesBottomBarWhenPushed = false
                                return
                            }
                            
                            if (isAthlete == true) && (isParent == true)
                            {
                                self.hidesBottomBarWhenPushed = true
                                
                                parentProfileVC = NewParentProfileViewController(nibName: "NewParentProfileViewController", bundle: nil)
                                parentProfileVC.careerId = careerId
                                self.navigationController?.pushViewController(parentProfileVC, animated: true)
                                
                                self.hidesBottomBarWhenPushed = false
                                return
                            }
                        }
                    }
                    
                    // Fallback case is the Fan
                    self.hidesBottomBarWhenPushed = true
                    
                    fanProfileVC = NewFanProfileViewController(nibName: "NewFanProfileViewController", bundle: nil)
                    self.navigationController?.pushViewController(fanProfileVC, animated: true)
                    
                    self.hidesBottomBarWhenPushed = false
                }
            }
        }
    }
    
    @IBAction func searchButtonTouched(_ sender: UIButton)
    {
        if (toolTipActive == true)
        {
            return
        }
        
        searchVC = SearchViewController(nibName: "SearchViewController", bundle: nil)
        self.navigationController?.pushViewController(searchVC!, animated: true)
    }
    
    @IBAction func calendarButtonTouched(_ sender: UIButton)
    {
        if (toolTipActive == true)
        {
            return
        }
        
        calendarVC = CalendarViewController(nibName: "CalendarViewController", bundle: nil)
        calendarVC.delegate = self
        calendarVC.availableDates = availableDatesArray
        calendarVC.allContests = allContestsArray
        calendarVC.selectedDate = Date()
        calendarVC.modalPresentationStyle = .overCurrentContext
        
        self.tabBarController?.tabBar.isHidden = true
        self.present(calendarVC, animated: true)
        {
            
        }
    }
    
    @IBAction func testButtonTouched(_ sender: UIButton)
    {
        
    }
    
    @objc private func dateButtonTouched(_ sender: UIButton)
    {
        // Skip if the button hasn't changed
        if ((sender.tag - 100) == selectedDateIndex)
        {
            return
        }
        
        // Change the font of the all of the buttons to regular, hide the underline view
        for subview in dateContainerScrollView.subviews as Array<UIView>
        {
            if (subview is UIButton)
            {
                let button = subview as! UIButton
                button.titleLabel?.font = UIFont.mpRegularFontWith(size: 13)
                button.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
                
                let horizLine = button.subviews[0]
                horizLine.isHidden = true
            }
        }
        
        // Set the selected item's font to bold
        selectedDateIndex = sender.tag - 100
        sender.titleLabel?.font = UIFont.mpBoldFontWith(size: 13)
        sender.setTitleColor(UIColor.mpBlackColor(), for: .normal)
        
        // Show the underline on the button
        let horizLine = sender.subviews[0]
        horizLine.isHidden = false
        
        self.getContestResults()
    }
    
    @objc private func addScoreboardButtonTouched()
    {
        if (toolTipActive == true)
        {
            return
        }
        
        addScoreboardVC = AddScoreboardViewController(nibName: "AddScoreboardViewController", bundle: nil)
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(addScoreboardVC, animated: true)
        self.hidesBottomBarWhenPushed = false
        
        // Click Tracking
        let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"add-scoreboard-button-click", kClickTrackingModuleNameKey: "scoreboard", kClickTrackingModuleLocationKey:"scores home", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:""]
        
        TrackingManager.trackEvent(featureName: "scoreboard-add", cData: cData)
    }
    
    @objc private func scoreboardButtonTouched(_ sender: UIButton)
    {
        if (scoreboardContestListVC != nil)
        {
            scoreboardContestListVC = nil
        }
        
        let index = sender.tag - 100
        let scoreboard = scoreboardsArray[index] as! Dictionary<String,String>
        
        scoreboardContestListVC = NewScoreboardContestListViewController(nibName: "NewScoreboardContestListViewController", bundle: nil)
        scoreboardContestListVC.selectedScoreboard = scoreboard
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(scoreboardContestListVC, animated: true)
        self.hidesBottomBarWhenPushed = false
        
        let gender = scoreboard["scoreboardGender"]
        let sport = scoreboard["scoreboardSport"]
        let cData = [kTrackingSportNameKey:sport, kTrackingSportGenderKey:gender]
        
        TrackingManager.trackState(featureName: "scoreboard", trackingGuid: trackingGuid, cData: cData as Dictionary<String, Any>)
    }
    
    @objc private func deleteScoreboardButtonTouched(_ sender: UIButton)
    {
        MiscHelper.showAlert(in: self, withActionNames: ["Delete", "Cancel"], title: "Delete Scoreboard", message: "Are you sure you want to delete this scoreboard?", lastItemCancelType: false) { tag in
            
            if (tag == 0)
            {
                let index = sender.tag - 100
                self.scoreboardsArray.remove(at: index)
                
                // Update the prefs
                kUserDefaults.setValue(self.scoreboardsArray, forKey: kUserScoreboardsArrayKey)
                
                // Reload the scoreboard items
                self.addScoreboardButtons()
            }
        }
    }
    
    @objc private func leftScorerButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let contest = contestResultsArray[index]
        let contestId = contest["contestId"] as? String ?? ""
        
        //let teams = contest["teams"] as! Array<Dictionary<String,Any>>
        //let team = teams.first!
        //let teamHasScorer = team["hasAssignedScorer"] as! Bool
        
        //if (teamHasScorer == false)
        //{
            let calculatedFieldsObj = contest["calculatedFields"] as! Dictionary<String,Any>
            let urlString = calculatedFieldsObj["canonicalUrl"] as! String
        
            self.showModalWebViewController(urlString: urlString, showShareButton: false, ftag: "", contestId: contestId, showVideoBanner: true)
        //}
    }
    
    @objc private func rightScorerButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let contest = contestResultsArray[index]
        let contestId = contest["contestId"] as? String ?? ""
        
        //let teams = contest["teams"] as! Array<Dictionary<String,Any>>
        //let team = teams.last!
        //let teamHasScorer = team["hasAssignedScorer"] as! Bool
        
        //if (teamHasScorer == false)
        //{
            let calculatedFieldsObj = contest["calculatedFields"] as! Dictionary<String,Any>
            let urlString = calculatedFieldsObj["canonicalUrl"] as! String
        
            self.showModalWebViewController(urlString: urlString, showShareButton: false, ftag: "", contestId: contestId, showVideoBanner: true)
        //}
    }
    
    @objc private func liveGameVideoPlayButtonTouched(_ sender: UIButton)
    {
        MiscHelper.showAlert(in: self, withActionNames: ["Continue", "Cancel"], title: "Open Safari", message: "You are now leaving MaxPreps and going to the NFHS Network.", lastItemCancelType: false) { tag in
            
            if (tag == 0)
            {
                let index = sender.tag - 100
                let contest = self.contestResultsArray[index]
                let nfhsStreamUrl = contest["nfhsStreamUrl"] as! String
                
                UIApplication.shared.open(URL(string: nfhsStreamUrl)!, options: [:]) { completion in
                    
                }
            }
        }
    }
    
    @objc private func reportScoreButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let contest = contestResultsArray[index]
        let calculatedFieldsObj = contest["calculatedFields"] as! Dictionary<String,Any>
        let allowReportFinalScore = calculatedFieldsObj["allowReportFinalScore"] as! Bool
        
        if (allowReportFinalScore == true)
        {
            // Call the web view
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
            
            self.showModalWebViewController(urlString: urlString, showShareButton: false, ftag: "", contestId: contestId, showVideoBanner: true)
        }
        else
        {
            let reason = calculatedFieldsObj["reasonWhyCannotEnterScores"] as! String
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Not Allowed", message: reason, lastItemCancelType: false) { tag in
                
            }
        }
    }
    
    @objc private func videoPlayButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let contest = contestResultsArray[index]
        let videos = contest["videos"] as! Array<Dictionary<String,Any>>
        let video = videos.first!
        let videoId = video["videoId"] as! String
        
        self.showVideoPlayer(videoId: videoId, trackingKey: "score-home", trackingContextData: kEmptyTrackingContextData)
    }
    
    // MARK: - Add Date Buttons Method
    
    @objc private func addDateButtons()
    {
        // Remove existing buttons
        let itemScrollViewSubviews = dateContainerScrollView.subviews
        for subview in itemScrollViewSubviews
        {
            subview.removeFromSuperview()
        }
        
        // Reset the selectedDateIndex
        selectedDateIndex = -1

        var overallWidth = 0
        let pad = 10
        var leftPad = 0
        let rightPad = 10
        var index = 0
        
        //let itemWidth = 45 + (2 * pad)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E MMM d"
        
        for date in availableDatesArray
        {
            //let dateString = dateFormatter.string(from: date).uppercased()
            let dateString = dateFormatter.string(from: date)
            let itemWidth = Int(dateString.widthOfString(usingFont: UIFont.mpSemiBoldFontWith(size: 13))) + (2 * pad)
            let tag = availableDatesArray.firstIndex(of: date)! + 100
            
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
            button.frame = CGRect(x: overallWidth + leftPad, y: 0, width: itemWidth, height: Int(dateContainerScrollView.frame.size.height))
            button.backgroundColor = .clear
            button.setTitle(dateString, for: .normal)
            button.tag = tag
            button.addTarget(self, action: #selector(self.dateButtonTouched), for: .touchUpInside)
            
            // Add a line at the bottom of each button
            let textWidth = itemWidth - (2 * pad)
            let line = UIView(frame: CGRect(x: (button.frame.size.width - CGFloat(textWidth)) / 2.0, y: button.frame.size.height - 5, width: CGFloat(textWidth), height: 4))
            line.backgroundColor = UIColor.mpRedColor()

            // Round the top corners
            line.clipsToBounds = true
            line.layer.cornerRadius = 4
            line.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            
            button.addSubview(line)
            
            if (index == 0)
            {
                button.titleLabel?.font = UIFont.mpBoldFontWith(size: 13)
                button.setTitleColor(UIColor.mpBlackColor(), for: .normal)
            }
            else
            {
                button.titleLabel?.font = UIFont.mpRegularFontWith(size: 13)
                button.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
                
                // Hide the inactive horiz line
                let horizLine = button.subviews[0]
                horizLine.isHidden = true
            }
            
            dateContainerScrollView.addSubview(button)
            
            index += 1
            overallWidth += (itemWidth + leftPad)
        }
        
        dateContainerScrollView.contentSize = CGSize(width: overallWidth + rightPad, height: Int(dateContainerScrollView.frame.size.height))
        
        // Add the left and right shadows
        if (leftShadow == nil)
        {
            leftShadow = UIImageView(frame: CGRect(x: 0, y: Int(dateContainerScrollView.frame.origin.y), width: 70, height: Int(dateContainerScrollView.frame.size.height) - 1))
            leftShadow.image = UIImage(named: "LeftShadowWhite")
            leftShadow.clipsToBounds = true
            leftShadow.tag = 200
            titleContainerView.addSubview(leftShadow)
        }
                
        if (rightShadow == nil)
        {
            rightShadow = UIImageView(frame: CGRect(x: Int(kDeviceWidth) - 70, y: Int(dateContainerScrollView.frame.origin.y), width: 70, height: Int(dateContainerScrollView.frame.size.height) - 1))
            rightShadow.image = UIImage(named: "RightShadowWhite")
            rightShadow.clipsToBounds = true
            rightShadow.tag = 201
            titleContainerView.addSubview(rightShadow)
        }
        
        leftShadow.isHidden = true
        
        if (dateContainerScrollView.contentSize.width <= dateContainerScrollView.frame.size.width)
        {
            rightShadow.isHidden = true
        }
        
        // Preset the date to today
        let today = Date()
        //let todayString = dateFormatter.string(from: today).uppercased()
        let todayString = dateFormatter.string(from: today)
        print(todayString)
        
        var activeButtonCenterX = 0
        var exactMatch = false
        
        // First look for an exact match
        for item in dateContainerScrollView.subviews
        {
            let button = item as! UIButton
 
            if (button.titleLabel?.text == todayString)
            {
                button.setTitle("Today", for: .normal)
                activeButtonCenterX = Int(button.center.x)
                
                // Auto-touch the button so it gets highlighted
                self.dateButtonTouched(button)
                exactMatch = true
                break
            }
        }
        
        // If no exact match, find the nearest date prior to today
        if (exactMatch == false)
        {
            // Build a temp array of prior dates
            var priorDateArray: Array<Date> = []
            var futureDateArray: Array<Date> = []
            
            // Iterate through all dates and keep the ones that are prior to today
            for date in availableDatesArray
            {
                if (date < today)
                {
                    priorDateArray.append(date)
                }
                
                if (date > today)
                {
                    futureDateArray.append(date)
                }
            }
            
            if (priorDateArray.count > 0)
            {
                let closestDate = priorDateArray.last
                //let closestDateString = dateFormatter.string(from: closestDate!).uppercased()
                let closestDateString = dateFormatter.string(from: closestDate!)
                
                for item in dateContainerScrollView.subviews
                {
                    let button = item as! UIButton
                    
                    if (button.titleLabel?.text == closestDateString)
                    {
                        activeButtonCenterX = Int(button.center.x)
                        
                        // Auto-touch the button so it gets highlighted
                        self.dateButtonTouched(button)
                        break
                    }
                }
            }
            else
            {
                // Just use the first item from the future
                if (futureDateArray.count > 0)
                {
                    let closestDate = futureDateArray.first
                    //let closestDateString = dateFormatter.string(from: closestDate!).uppercased()
                    let closestDateString = dateFormatter.string(from: closestDate!)
                    
                    for item in dateContainerScrollView.subviews
                    {
                        let button = item as! UIButton
                        
                        if (button.titleLabel?.text == closestDateString)
                        {
                            activeButtonCenterX = Int(button.center.x)
                            
                            // Auto-touch the button so it gets highlighted
                            self.dateButtonTouched(button)
                            break
                        }
                    }
                }
                else
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "There are no games scheduled.", lastItemCancelType: false) { tag in
                        
                    }
                }
            }
        }
        
        // Scroll today's date to the middle
        var scrollOffset = 0
        if (activeButtonCenterX > Int(dateContainerScrollView.frame.size.width / 2))
        {
            scrollOffset = activeButtonCenterX - Int(dateContainerScrollView.frame.size.width / 2)
            dateContainerScrollView.contentOffset = CGPoint(x: scrollOffset, y: 0)
            leftShadow.isHidden = false
        }
    }
    
    private func addScoreboardButtons()
    {
        // Remove existing buttons
        let scoreboardScrollViewSubviews = scoreboardsScrollView.subviews
        for subview in scoreboardScrollViewSubviews
        {
            subview.removeFromSuperview()
        }
        
        var overallWidth = 0
        let textLeadingPad = 28
        let textTrailingPad = 28
        let leftPad = 10
        let rightPad = 10
        var index = 0
        var itemWidth = 0
                
        // Iterate through the scoreboards so a button can be added for each
        for item in scoreboardsArray
        {
            let scoreboard = item as! Dictionary<String,String>
            let defaultName = scoreboard[kScoreboardDefaultNameKey]
            var title = ""
            
            if (defaultName == "national") || (defaultName == "state")
            {
                title = scoreboard[kScoreboardAliasNameKey]!//.uppercased()
            }
            else
            {
                title = scoreboard[kScoreboardEntityNameKey]!//.uppercased()
            }
            
            // Limit the title to 20 characters
            if (title.count > 20)
            {
                let substring = title.prefix(20)
                title = substring + "..."
            }
            
            itemWidth = Int(title.widthOfString(usingFont: UIFont.mpSemiBoldFontWith(size: 14))) + textLeadingPad + textTrailingPad
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: overallWidth + leftPad, y: 7, width: itemWidth, height: 30)
            button.backgroundColor = UIColor.mpWhiteColor()
            button.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 14)
            button.setTitle(title, for: .normal)
            button.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
            button.tag = 100 + index
            button.layer.cornerRadius = 15
            //button.clipsToBounds = true
            
            // Add a shadow to the button
            button.layer.masksToBounds = false
            button.layer.shadowColor = UIColor(white: 0.6, alpha: 1.0).cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 2.0)
            button.layer.shadowRadius = 2
            button.layer.shadowOpacity = 0.5
            
            button.addTarget(self, action: #selector(self.scoreboardButtonTouched), for: .touchUpInside)
            scoreboardsScrollView.addSubview(button)
            
            let sport = scoreboard[kScoreboardSportKey]!
            
            /*
            // Add a colored background to the left corner of the pill if the sport is dual gender
            let gender = scoreboard[kScoreboardGenderKey]!
            
            if (MiscHelper.sportIsDualGender(sport: sport) == true)
            {
                if (gender == "Boys")
                {
                    button.backgroundColor = UIColor(red: 220.0/255.0, green: 230.0/255.0, blue: 255.0/255.0, alpha: 1)
                }
                else if (gender == "Girls")
                {
                    button.backgroundColor = UIColor(red: 255.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1)
                }
            }
            */
            
            // Add the sport icon on top of the button
            let sportIconImageView = UIImageView(frame: CGRect(x: 10, y: 9, width: 12, height: 12))
            sportIconImageView.isUserInteractionEnabled = true
            let image = MiscHelper.getImageForSport(sport)
            sportIconImageView.image = image
            button.addSubview(sportIconImageView)
            
            // Add a delete button to the end
            let deleteButton = UIButton(type: .custom)
            deleteButton.frame = CGRect(x: itemWidth - 30, y: 0, width: 30, height: 30)
            deleteButton.setImage(UIImage(named: "SmallDeleteIcon"), for: .normal)
            deleteButton.tag = 100 + index
            deleteButton.addTarget(self, action: #selector(deleteScoreboardButtonTouched), for: .touchUpInside)
            button.addSubview(deleteButton)
            
            index += 1
            overallWidth += (itemWidth + leftPad)
        }
        
        let addScoreboardButton = UIButton(type: .custom)
        addScoreboardButton.frame = CGRect(x: overallWidth + leftPad, y: 7, width: 150, height: 30)
        addScoreboardButton.backgroundColor = UIColor.mpWhiteColor()
        addScoreboardButton.setTitle("Add Scoreboard", for: .normal)
        addScoreboardButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 14)
        addScoreboardButton.setTitleColor(UIColor.mpBlueColor(), for: .normal)
        addScoreboardButton.setImage(UIImage(named: "RoundBluePlus"), for: .normal)
        addScoreboardButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: -3)
        addScoreboardButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
        addScoreboardButton.layer.cornerRadius = 15
        //addScoreboardButton.clipsToBounds = true
        
        // Add a shadow to the button
        addScoreboardButton.layer.masksToBounds = false
        addScoreboardButton.layer.shadowColor = UIColor(white: 0.6, alpha: 1.0).cgColor
        addScoreboardButton.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        addScoreboardButton.layer.shadowRadius = 2
        addScoreboardButton.layer.shadowOpacity = 0.5
        
        addScoreboardButton.addTarget(self, action: #selector(addScoreboardButtonTouched), for: .touchUpInside)
        scoreboardsScrollView.addSubview(addScoreboardButton)
        
        overallWidth += (150 + leftPad)
        
        scoreboardsScrollView.contentSize = CGSize(width: overallWidth + rightPad, height: Int(scoreboardsScrollView.frame.size.height))
        
        // Add the left and right shadows
        if (leftScoreboardsShadow == nil)
        {
            leftScoreboardsShadow = UIImageView(frame: CGRect(x: 0, y: Int(scoreboardsScrollView.frame.origin.y), width: 70, height: Int(scoreboardsScrollView.frame.size.height)))
            leftScoreboardsShadow.image = UIImage(named: "LeftShadowWhite")
            leftScoreboardsShadow.tag = 200
            scoreboardHeaderView.addSubview(leftScoreboardsShadow)
        }
                
        if (rightScoreboardsShadow == nil)
        {
            rightScoreboardsShadow = UIImageView(frame: CGRect(x: Int(kDeviceWidth) - 70, y: Int(scoreboardsScrollView.frame.origin.y), width: 70, height: Int(scoreboardsScrollView.frame.size.height)))
            rightScoreboardsShadow.image = UIImage(named: "RightShadowWhite")
            rightScoreboardsShadow.tag = 201
            scoreboardHeaderView.addSubview(rightScoreboardsShadow)
        }
        
        leftScoreboardsShadow.isHidden = true
        
        if (scoreboardsScrollView.contentSize.width <= scoreboardsScrollView.frame.size.width)
        {
            rightScoreboardsShadow.isHidden = true
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
        let adId = kUserDefaults.value(forKey: kScoresBannerAdIdKey) as! String
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
            
            request.customTargeting?.updateValue(SharedData.scoresTabBaseGuid, forKey: "vguid")
            
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
            UIView.animate(withDuration: 0.25, animations: {self.bannerBackgroundView.transform = CGAffineTransform(translationX: 0, y: 0)})
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
    
    // MARK: - Pull to Refresh
    
    @objc private func pullToRefresh()
    {
        if (self.availableDatesArray.count > 0)
        {
            self.getContestResults()
        }
        else
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            { [self] in
                self.scoreboardRefreshControl.endRefreshing()
            }
        }
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if (scrollView == dateContainerScrollView)
        {
            let xScroll = Int(scrollView.contentOffset.x)
            
            if (xScroll <= 0)
            {
                leftShadow.isHidden = true
                rightShadow.isHidden = false
            }
            else if ((xScroll > 0) && (xScroll < (Int(dateContainerScrollView!.contentSize.width) - Int(kDeviceWidth))))
            {
                leftShadow.isHidden = false
                rightShadow.isHidden = false
            }
            else
            {
                leftShadow.isHidden = false
                rightShadow.isHidden = true
            }
        }
        else if (scrollView == scoreboardsScrollView)
        {
            let xScroll = Int(scrollView.contentOffset.x)
            
            if (xScroll <= 0)
            {
                leftScoreboardsShadow.isHidden = true
                rightScoreboardsShadow.isHidden = false
            }
            else if ((xScroll > 0) && (xScroll < (Int(scoreboardsScrollView!.contentSize.width) - Int(kDeviceWidth))))
            {
                leftScoreboardsShadow.isHidden = false
                rightScoreboardsShadow.isHidden = false
            }
            else
            {
                leftScoreboardsShadow.isHidden = false
                rightScoreboardsShadow.isHidden = true
            }
        }
        else if (scrollView == scoresTableView)
        {
            let yScroll = Int(scrollView.contentOffset.y)
            let headerHeight = Int(fakeStatusBar.frame.size.height) + Int(navView.frame.size.height) + Int(titleContainerView.frame.size.height)
            
            //print("Scroll = " + String(yScroll))
            
            if (yScroll <= 0)
            {
                titleContainerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: titleContainerView.frame.size.height)

                scoresTableView.frame = CGRect(x: 0, y: Int(fakeStatusBar.frame.size.height) + Int(navView.frame.size.height) + Int(titleContainerView.frame.size.height), width: Int(kDeviceWidth), height: Int(kDeviceHeight) - headerHeight - bottomTabBarPad - Int(SharedData.bottomSafeAreaHeight))
                
                largeTitleLabel.alpha = 1
                navTitleLabel.alpha = 0
                
                // This handles a condition where the last scroll event never gets executed because the previous one is still being drawn
                if (yScroll == 0)
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01)
                    { [self] in
                        self.largeTitleLabel.alpha = 1
                        self.navTitleLabel.alpha = 0
                    }
                }
            }
            else if ((yScroll > 0) && (yScroll < 50))
            {
                titleContainerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height - CGFloat(yScroll), width: kDeviceWidth, height: titleContainerView.frame.size.height)
                            
                scoresTableView.frame = CGRect(x: 0, y: Int(fakeStatusBar.frame.size.height) + Int(navView.frame.size.height) + Int(titleContainerView.frame.size.height) - yScroll, width: Int(kDeviceWidth), height: Int(kDeviceHeight) - headerHeight - bottomTabBarPad - Int(SharedData.bottomSafeAreaHeight) + yScroll)
                
                // Fade at twice the scroll rate
                let fade = 1.0 - (CGFloat(2 * yScroll) / titleContainerView.frame.size.height)
                largeTitleLabel.alpha = fade
                navTitleLabel.alpha = 1 - fade
            }
            else
            {
                titleContainerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height - CGFloat(50), width: kDeviceWidth, height: titleContainerView.frame.size.height)
                            
                scoresTableView.frame = CGRect(x: 0, y: Int(fakeStatusBar.frame.size.height) + Int(navView.frame.size.height) + Int(titleContainerView.frame.size.height) - 50, width: Int(kDeviceWidth), height: Int(kDeviceHeight) - headerHeight - bottomTabBarPad - Int(SharedData.bottomSafeAreaHeight) + 50)
                
                largeTitleLabel.alpha = 0
                navTitleLabel.alpha = 1
            }
        }
    }
    
    // MARK: - Tool Tip Delegates
    
    func toolTipFourClosed()
    {
        toolTipActive = false
    }
    
    // MARK: - Show Tool Tip
    
    private func showToolTip()
    {
        // Show the tool tip after a small delay if not seen before
        if (kUserDefaults.bool(forKey: kToolTipFourShownKey) == false)
        {
            let currentLaunchCount = kUserDefaults.object(forKey: kAppLaunchCountKey) as! Int
            
            if (currentLaunchCount >= 2)
            {
                // Scroll the table to the top
                scoresTableView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
                
                toolTipActive = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5)
                {
                    self.toolTipFourVC = ToolTipFourViewController(nibName: "ToolTipFourViewController", bundle: nil)
                    self.toolTipFourVC.delegate = self
                    self.toolTipFourVC.modalPresentationStyle = .overFullScreen
                    self.self.present(self.toolTipFourVC, animated: false)
                }
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
    
    // MARK: - App Will Enter Foreground Notification
    
    @objc private func applicationWillEnterForeground()
    {
        // Refresh the ad if this VC is the active one
        if (self.tabBarController?.selectedIndex == 2)
        {
            self.loadBannerViews()
            self.getFavoriteTeamsContests()
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        trackingGuid = SharedData.scoresTabBaseGuid
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                
        if (self.tabBarController?.tabBar.isHidden == false)
        {
            bottomTabBarPad = kTabBarHeight
        }

        // Explicitly set the header view sizes
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        titleContainerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: titleContainerView.frame.size.height)
                
        //let fakeStatusBarHeight = Int(fakeStatusBar.frame.size.height)
        //let navViewHeight =  Int(navView.frame.size.height)
        //let titleContainerViewHeight = Int(titleContainerView.frame.size.height)
        
        let headerHeight = Int(fakeStatusBar.frame.size.height) + Int(navView.frame.size.height) + Int(titleContainerView.frame.size.height)
        
        scoresTableView.frame = CGRect(x: 0, y: headerHeight, width: Int(kDeviceWidth), height: Int(kDeviceHeight) - headerHeight - bottomTabBarPad - Int(SharedData.bottomSafeAreaHeight))
        scoresTableView.isHidden = true
        
        // Add refresh control to the table view
        scoreboardRefreshControl.tintColor = UIColor.mpLightGrayColor()
        //let attributedString = NSMutableAttributedString(string: "Refreshing Scores", attributes: [NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 14), NSAttributedString.Key.foregroundColor: UIColor.mpLightGrayColor()])
        //scoreboardRefreshControl.attributedTitle = attributedString
        scoreboardRefreshControl.addTarget(self, action: #selector(pullToRefresh), for: UIControl.Event.valueChanged)
        scoresTableView.addSubview(scoreboardRefreshControl)
        
        // Add the profile button. The image will be updated later
        profileButton = UIButton(type: .custom)
        profileButton?.frame = CGRect(x: 20, y: 4, width: 34, height: 34)
        profileButton?.layer.cornerRadius = (profileButton?.frame.size.width)! / 2.0
        profileButton?.clipsToBounds = true
        //profileButton?.setImage(UIImage.init(named: "EmptyProfileButton"), for: .normal)
        profileButton?.addTarget(self, action: #selector(self.profileButtonTouched), for: .touchUpInside)
        navView?.addSubview(profileButton!)
        
        navTitleLabel.alpha = 0
        
        scoreboardHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        scoreboardHeaderView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        
        scoreboardsScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        scoreboardsScrollView.backgroundColor = .clear
        scoreboardsScrollView.delegate = self
        scoreboardsScrollView.showsHorizontalScrollIndicator = false
        scoreboardHeaderView.addSubview(scoreboardsScrollView)
        
        testButton.isHidden = true

        
        // Add a notification handler that validate user is finished
        NotificationCenter.default.addObserver(self, selector: #selector(loadUserImage), name: Notification.Name("GetUserInfoFinished"), object: nil)
        
        // Add a notification handler for web deep linking
        NotificationCenter.default.addObserver(self, selector: #selector(showScoresWebBrowser), name: Notification.Name("OpenScoresWebBrowser"), object: nil)
        
        // Add a notification handler for career deep linking
        NotificationCenter.default.addObserver(self, selector: #selector(showCareerDeepLink), name: Notification.Name("OpenScoresCareerDeepLink"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showTeamDeepLink), name: Notification.Name("OpenScoresTeamDeepLink"), object: nil)
        
        // Add an observer for the app going into the background
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // Add an observer for the app returning to the foreground
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
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
        
        // Set the image to the settings icon if a Test Drive user right away
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        if (userId == kTestDriveUserId)
        {
            //profileButton?.setImage(UIImage.init(named: "SettingsButton"), for: .normal)
            profileButton?.setImage(UIImage.init(named: "EmptyProfileButton"), for: .normal)
        }
        else
        {
            self.loadUserImage()
        }
        
        // Load the scoreboards
        scoreboardsArray = kUserDefaults.array(forKey: kUserScoreboardsArrayKey)!
        self.addScoreboardButtons()

        // Only get new contest-dates if entering the view from a tab switch and not returning from the calendar or the contestList
        if ((calendarVC == nil) && (scoreboardContestListVC == nil) && (videoPlayerVC == nil))
        {
            self.getFavoriteTeamsContests()
        }
        
        // Show the ad
        self.loadBannerViews()
        
        // Show the tool tip
        self.showToolTip()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (calendarVC != nil)
        {
            calendarVC = nil
        }
        
        if (addScoreboardVC != nil)
        {
            addScoreboardVC = nil
        }
        
        if (scoreboardContestListVC != nil)
        {
            scoreboardContestListVC = nil
        }
        
        if (videoPlayerVC != nil)
        {
            videoPlayerVC = nil
        }
        
        if (guestProfileVC != nil)
        {
            guestProfileVC = nil
        }
        
        if (athleteProfileVC != nil)
        {
            athleteProfileVC = nil
        }
        
        if (parentProfileVC != nil)
        {
            parentProfileVC = nil
        }
        
        if (coachProfileVC != nil)
        {
            coachProfileVC = nil
        }
        
        if (fanProfileVC != nil)
        {
            fanProfileVC = nil
        }
        
        if (adProfileVC != nil)
        {
            adProfileVC = nil
        }
        
        if (toolTipFourVC != nil)
        {
            toolTipFourVC = nil
        }
        
        if (teamDetailVC != nil)
        {
            teamDetailVC = nil
        }
        
        if (athleteDetailVC != nil)
        {
            athleteDetailVC = nil
        }
        
        // Added this to hide the tab bar when returning from the videoAd "learn more" website
        if (modalWebVC != nil)
        {
            self.tabBarController?.tabBar.isHidden = true
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
        return UIStatusBarStyle.default
    }

    override var shouldAutorotate: Bool
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
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("GetUserInfoFinished"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("OpenScoresWebBrowser"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("OpenScoresCareerDeepLink"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("OpenScoresTeamDeepLink"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
                
    }
}

