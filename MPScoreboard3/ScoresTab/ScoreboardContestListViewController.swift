//
//  ScoreboardContestListViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 9/7/21.
//

import UIKit
import GoogleMobileAds
//import MoPubAdapter
import DTBiOSSDK
import AdSupport
import AppTrackingTransparency

class ScoreboardContestListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewModalWebViewControllerDelegate, DTBAdCallback, GADBannerViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var horizLine: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var dateContainerScrollView: UIScrollView!
    @IBOutlet weak var contestTableView: UITableView!
    
    var selectedScoreboard = [:] as! Dictionary<String,String>
    
    private var leftShadow : UIImageView!
    private var rightShadow : UIImageView!
    
    private var allContestsArray = [] as! Array<Dictionary<String,Any>>
    private var availableDatesArray = [] as! Array<Date>
    private var contestResultsArray = [] as! Array<Dictionary<String,Any>>
    private var systemNotificationsEnabled = false
    private var selectedDateIndex = -1
    private var scoreboardRefreshControl = UIRefreshControl()
    
    private var modalWebVC: NewModalWebViewController!
    
    private var googleBannerAdView: GAMBannerView!
    private var bannerBackgroundView: UIVisualEffectView! //UIImageView!
    
    private var trackingGuid = ""
    private var tickTimer: Timer!
    private var skeletonOverlay: SkeletonHUD!
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
        NimbusBidder(request: .forBannerAd(position: "scores")),
        APSBidder(adLoader: apsLoader)
    ]
    
    lazy var dynamicPriceManager = DynamicPriceManager(bidders: bidders, refreshInterval: TimeInterval(kNimbusAdTimerValue))
    
    // MARK: - ModalWebViewControllerDelegate
    
    func modalWebViewControllerCancelButtonTouched()
    {
        self.dismiss(animated: true)
        {
            // Check if the setting may have changed
            let center = UNUserNotificationCenter.current()
            center.getNotificationSettings(completionHandler: { settings in
              
                if (settings.authorizationStatus == .authorized)
                {
                    self.systemNotificationsEnabled = true
                }
                else
                {
                    self.systemNotificationsEnabled = false
                }
                
                self.modalWebVC = nil
                
                DispatchQueue.main.async
                {
                    self.contestTableView.reloadData()
                    self.loadBannerViews()
                }
            })
        }
    }
    
    // MARK: - Show ModalWebVC
    
    private func showModalWebViewController(urlString: String, showShareButton: Bool, contestId: String, sport: String, contestDate: Date, duplicateNotification: Bool)
    {
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
                
        modalWebVC = NewModalWebViewController(nibName: "NewModalWebViewController", bundle: nil)
        modalWebVC.delegate = self
        modalWebVC.modalPresentationStyle = .overCurrentContext
        modalWebVC.titleString = ""
        modalWebVC.urlString = urlString
        modalWebVC.showLoadingOverlay = true
        modalWebVC.showScrollIndicators = false
        modalWebVC.showBannerAd = true
        modalWebVC.showVideoBanner = true
        modalWebVC.adId = kUserDefaults.value(forKey: kScoresBannerAdIdKey) as! String
        modalWebVC.showShareButton = showShareButton
        modalWebVC.enableAdobeQueryParameter = true
        //modalWebVC.trackingContext = [:]
        modalWebVC.contestId = contestId
        modalWebVC.sport = sport
        modalWebVC.contestDate = contestDate
        modalWebVC.duplicateNotification = duplicateNotification
        modalWebVC.trackingKey = "scoreboard"
        modalWebVC.trackingContextData = kEmptyTrackingContextData
        
        self.present(modalWebVC, animated: true)
        {
            
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
        let contestObject = allContestsArray[selectedDateIndex]
        let contests = contestObject["contestIds"] as! Array<String>
        
        contestResultsArray.removeAll()
        
        if (scoreboardRefreshControl.isRefreshing == false)
        {
            //MBProgressHUD.showAdded(to: self.view, animated: true)
            if (skeletonOverlay == nil)
            {
                skeletonOverlay = SkeletonHUD()
                let height = kDeviceHeight - navView.frame.origin.y - navView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight)
                
                skeletonOverlay.show(skeletonFrame: CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: height), imageType: .scoreboards, parentView: self.view)
            }
        }
        
        NewFeeds.getScoreboardContestResults(contests: contests, includeRankings: false) { results, error in
            
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
            
            // Update the table
            self.contestTableView.reloadData()
        }
    }
    
    // MARK: - Get Scoreboard Contests
    
    private func getScoreboardContests()
    {
        // Acceptable values for Context are:
        // National = 1, State = 2, Section = 3, StateDivision = 4, SectionDivision = 5, Association = 6, League = 7, DMA = 8
        // The entityId will be a GUID, stateCode, or 25 depending on the scoreboard type
        
        let scoreboardName = selectedScoreboard[kScoreboardDefaultNameKey]
        let divisionType = selectedScoreboard[kScoreboardDivisionTypeKey]
        let entityId = selectedScoreboard[kScoreboardEntityIdKey]
        let gender = selectedScoreboard[kScoreboardGenderKey]
        let sport = selectedScoreboard[kScoreboardSportKey]
        let genderCommaSport = MiscHelper.genderCommaSportFrom(gender: gender!, sport: sport!)
        
        var context = ""
        
        switch scoreboardName
        {
        case "national":
            context = "1"
        case "state":
            context = "2"
        case "section":
            context = "3"
        case "division":
            if (divisionType == "StateDivision")
            {
                context = "4"
            }
            else
            {
                context = "5"
            }
        case "association":
            context = "6"
        case "league":
            context = "7"
        case "dma":
            context = "8"
        default:
            context = ""
        }
        
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
                
        NewFeeds.getScoreboardContests(context: context, id: entityId!, genderCommaSport: genderCommaSport) { results, error in
            
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
                print("Get Scoreboard Contests Success")
                
                self.allContestsArray = results!
                self.contestTableView.reloadData()
                
                for result in results!
                {
                    var contestDateString = result["date"] as! String
                    contestDateString = contestDateString.replacingOccurrences(of: "Z", with: "")
                    let dateFormatter = DateFormatter()
                    dateFormatter.isLenient = true
                    dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
                    //dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
                    let contestDate = dateFormatter.date(from: contestDateString)
                           
                    // Add the date object to the array
                    self.availableDatesArray.append(contestDate!)
                }
                
                self.addDateButtons()
                
            }
            else
            {
                print("Get Scoreboard Contests Failed")
            }
        }
    }
    
    // MARK: - Check For Duplicate Notification
    
    private func checkForDuplicateNotification(schoolIdA: String, schoolIdB: String, gender: String, sport: String) -> Bool
    {
        // Iterate through all favorite teans to see if there is a match
        var matchFound = false
        let favoriteTeams = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
        
        for item in favoriteTeams!
        {
            let favorite = item as! Dictionary<String,Any>
            let favoriteGender = favorite[kNewGenderKey] as! String
            let favoriteSport = favorite[kNewSportKey] as! String
            let favoriteTeamLevel = favorite[kNewLevelKey] as! String
            let favoriteSchoolId = favorite[kNewSchoolIdKey] as! String
            
            if ((favoriteSchoolId == schoolIdA) || (favoriteSchoolId == schoolIdB))
            {
                if ((favoriteGender == gender) && (favoriteSport == sport) && (favoriteTeamLevel == "Varsity"))
                {
                    matchFound = true
                    break
                }
            }
        }
        
        return matchFound
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
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 110
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        //return 0.01
        return 62
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // This keeps the code from a crash if the user changes the date while scrolling
        if (contestResultsArray.count > indexPath.row)
        {
            // Choose the cell to use based upon contestState
            let contest = contestResultsArray[indexPath.row]
            let calculatedFieldsObj = contest["calculatedFields"] as! Dictionary<String,Any>
            let contestState = calculatedFieldsObj["contestState"] as! Int
            
            // ScoreNotReported == 5
            if (contestState == 5)
            {
                // Use the ScoreboardContestNoScoreTableViewCell
                var cell = tableView.dequeueReusableCell(withIdentifier: "ScoreboardContestNoScoreTableViewCell") as? ScoreboardContestNoScoreTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("ScoreboardContestNoScoreTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? ScoreboardContestNoScoreTableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.loadData(contest)
                
                cell?.reportScoreButton.tag = 100 + indexPath.row
                cell?.reportScoreButton.addTarget(self, action: #selector(reportScoreButtonTouched), for: .touchUpInside)
                
                return cell!
            }
            else
            {
                // Use the ScoreboardContestTableViewCell
                var cell = tableView.dequeueReusableCell(withIdentifier: "ScoreboardContestTableViewCell") as? ScoreboardContestTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("ScoreboardContestTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? ScoreboardContestTableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.loadData(contest)
                
                // Show the bell icon if pregame or in process AND if a notification has been set
                cell?.bellIconImageView.isHidden = true
                
                if ((contestState == 2) || (contestState == 3))
                {
                    // Update the bell by parsing the contestNotifications for this contest
                    let existingContestNotifications = kUserDefaults.dictionary(forKey: kContestNotificationsDictionaryKey)
                    let contestId = contest["contestId"] as! String
                    
                    // Use the defaults if this contest didn't exist in prefs
                    if (existingContestNotifications![contestId] != nil)
                    {
                        let existingContestNotification = existingContestNotifications![contestId] as! Dictionary<String,Any>
                        let notificationsArray = existingContestNotification[kContestNotificationSettingsKey] as! Array<Any>
                        
                        var notificationFound = false
                        
                        for item in notificationsArray
                        {
                            let notification = item as! Dictionary<String,Any>
                            let isEnabled = notification[kNewNotificationIsEnabledForAppKey] as! Bool
                            
                            if (isEnabled == true)
                            {
                                notificationFound = true
                                break
                            }
                        }
                        
                        if (notificationFound == true)
                        {
                            cell?.bellIconImageView.isHidden = false
                            
                            // Dim the bell if the system notifications have been disabled
                            if (systemNotificationsEnabled == true)
                            {
                                cell?.bellIconImageView.image = UIImage(named: "ContestNotificationOn")
                            }
                            else
                            {
                                cell?.bellIconImageView.image = UIImage(named: "ContestNotificationOnDisabled")
                            }
                        }
                    }
                }
                
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
            
            return cell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let contest = contestResultsArray[indexPath.row]
        let calculatedFieldsObj = contest["calculatedFields"] as! Dictionary<String,Any>
        let hasContestPage = calculatedFieldsObj["hasContestPage"] as! Bool
        
        if (hasContestPage == true)
        {
            let contestState = calculatedFieldsObj["contestState"] as! Int
            let urlString = calculatedFieldsObj["canonicalUrl"] as! String
            let contestId = contest["contestId"] as! String
            let gender = selectedScoreboard[kScoreboardGenderKey] ?? ""
            let sport = selectedScoreboard[kScoreboardSportKey] ?? ""
            
            let dateString = contest["date"] as! String
            
            let teams = contest["teams"] as! Array<Dictionary<String,Any>>
            let teamA = teams[0]
            let teamB = teams[1]
            
            let schoolIdA = teamA["teamId"] as? String ?? "" // Might be NULL
            let schoolIdB = teamB["teamId"] as? String ?? "" // Might be NULL
            
            // Check if either team is already a favorite team
            let notificationAlreadyExists = self.checkForDuplicateNotification(schoolIdA: schoolIdA, schoolIdB: schoolIdB, gender: gender, sport: sport)
            
            let dateFormatter = DateFormatter()
            dateFormatter.isLenient = true
            dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
            let date = dateFormatter.date(from: dateString) ?? Date()
            
            // This determines if the bell should be hidden or not
            if ((contestState == 2) || (contestState == 3))
            {
                self.showModalWebViewController(urlString: urlString, showShareButton: true, contestId: contestId, sport: sport, contestDate: date, duplicateNotification: notificationAlreadyExists)
            }
            else
            {
                self.showModalWebViewController(urlString: urlString, showShareButton: true, contestId: contestId, sport: sport, contestDate: date, duplicateNotification: false)
            }
        }
        else
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Not Available", message: "There is no box score available for this game.", lastItemCancelType: false) { tag in
                
            }
        }
    }
    
    // MARK: - Add Date Buttons
    
    private func addDateButtons()
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
            let dateString = dateFormatter.string(from: date).uppercased()
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
            navView.addSubview(leftShadow)
        }
                
        if (rightShadow == nil)
        {
            rightShadow = UIImageView(frame: CGRect(x: Int(kDeviceWidth) - 70, y: Int(dateContainerScrollView.frame.origin.y), width: 70, height: Int(dateContainerScrollView.frame.size.height) - 1))
            rightShadow.image = UIImage(named: "RightShadowWhite")
            rightShadow.clipsToBounds = true
            rightShadow.tag = 201
            navView.addSubview(rightShadow)
        }
        
        leftShadow.isHidden = true
        horizLine.isHidden = false
        
        if (dateContainerScrollView.contentSize.width <= dateContainerScrollView.frame.size.width)
        {
            rightShadow.isHidden = true
        }
        
        // Preset the date to today
        let today = Date()
        let todayString = dateFormatter.string(from: today).uppercased()
        print(todayString)
        
        var activeButtonCenterX = 0
        var exactMatch = false
        
        // First look for an exact match
        for item in dateContainerScrollView.subviews
        {
            let button = item as! UIButton
 
            if (button.titleLabel?.text == todayString)
            {
                button.setTitle("TODAY", for: .normal)
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
                let closestDateString = dateFormatter.string(from: closestDate!).uppercased()
                
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
                    let closestDateString = dateFormatter.string(from: closestDate!).uppercased()
                    
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
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "There are no games scheduled for this scoreboard.", lastItemCancelType: false) { tag in
                        
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
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
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
        
        // Get the contest results
        self.getContestResults()
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
            
            self.showModalWebViewController(urlString: urlString, showShareButton: false, contestId: contestId, sport: "", contestDate: Date(), duplicateNotification: false)
        }
        else
        {
            let reason = calculatedFieldsObj["reasonWhyCannotEnterScores"] as! String
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Not Allowed", message: reason, lastItemCancelType: false) { tag in
                
            }
        }
    }
    
    @IBAction func testButtonTouched()
    {
        if (skeletonOverlay == nil)
        {
            skeletonOverlay = SkeletonHUD()
            let height = kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight)
            
            skeletonOverlay.show(skeletonFrame: CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: height), imageType: .scoreboards, parentView: self.view)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2)
        {
            if (self.skeletonOverlay != nil)
            {
                self.skeletonOverlay.hide()
                self.skeletonOverlay = nil
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
            self.bannerBackgroundView.frame = CGRect(x: 0, y: Int(kDeviceHeight) - SharedData.bottomSafeAreaHeight - Int(GADAdSizeBanner.size.height) - 12, width: Int(kDeviceWidth), height: Int(GADAdSizeBanner.size.height) + 12)
            
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
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        contestTableView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight))
        
        // Add refresh control to the table view
        scoreboardRefreshControl.tintColor = UIColor.mpLightGrayColor()
        //let attributedString = NSMutableAttributedString(string: "Refreshing Scores", attributes: [NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 14), NSAttributedString.Key.foregroundColor: UIColor.mpLightGrayColor()])
        //scoreboardRefreshControl.attributedTitle = attributedString
        scoreboardRefreshControl.addTarget(self, action: #selector(pullToRefresh), for: UIControl.Event.valueChanged)
        contestTableView.addSubview(scoreboardRefreshControl)
        
        let defaultName = selectedScoreboard[kScoreboardDefaultNameKey]
        let gender = selectedScoreboard[kScoreboardGenderKey]
        let sport = selectedScoreboard[kScoreboardSportKey]
        
        if (defaultName == "national") || (defaultName == "state")
        {
            titleLabel.text = selectedScoreboard[kScoreboardAliasNameKey]
        }
        else
        {
            //if ((scoreboardType == "league") || (scoreboardType == "division"))
            //{
                //let title = entityName! + " (" + sectionName! + ")"
                //titleLabel.text = title
            //}
            //else
            //{
                titleLabel.text = selectedScoreboard[kScoreboardEntityNameKey]
            //}
            
        }
        
        let genderSport = MiscHelper.genderSportLevelFrom(gender: gender!, sport: sport!, level: "Varsity")
        subtitleLabel.text = genderSport

        horizLine.isHidden = true
        
        self.getScoreboardContests()
        
        // Add an observer for the app going into the background
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
        
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings(completionHandler: { settings in
          
            if (settings.authorizationStatus == .authorized)
            {
                self.systemNotificationsEnabled = true
            }
            else
            {
                self.systemNotificationsEnabled = false
            }
        })
        
        // Show the ad
        self.loadBannerViews()
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
