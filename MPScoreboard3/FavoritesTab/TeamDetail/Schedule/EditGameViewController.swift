//
//  EditGameViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/7/21.
//

import UIKit

protocol EditGameViewControllerDelegate: AnyObject
{
    func editGameSaveOrDeleteButtonTouched()
    func editGameCancelButtonTouched()
}

class EditGameViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, IQActionSheetPickerViewDelegate, CustomDatePickerViewDelegate, SearchOpponentViewControllerDelegate, ScheduleCalendarViewControllerDelegate, AddPOGViewControllerDelegate
{
    weak var delegate: EditGameViewControllerDelegate?
    
    var selectedTeam : Team?
    var availableDates: Array<Date>!
    var ssid : String?
    var year = ""
    var contestId: String?
    var gameTypes: Array<String>!
    var contestState = 0
    var boxScoreUpdated = false
    
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var containerScrollView: UIScrollView!
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var homeAwayTextField: UITextField!
    @IBOutlet weak var gameTypeTextField: UITextField!
    @IBOutlet weak var opponentTextField: UITextField!
    
    @IBOutlet weak var gameDetailsContainerView: UIView!
    @IBOutlet weak var gameDetailsTextView: UITextView!
    @IBOutlet weak var gameDetailsTextCountLabel: UILabel!
    @IBOutlet weak var gameDetailsHeaderLabel: UILabel!
    
    @IBOutlet weak var scoreContainerView: UIView!
    @IBOutlet weak var scoreTextField: UITextField!
    
    @IBOutlet weak var statsContainerView: UIView!
    @IBOutlet weak var statsTextField: UITextField!
    
    @IBOutlet weak var footballPOGContainerView: UIView!
    @IBOutlet weak var footballOverallTextField: UITextField!
    @IBOutlet weak var footballDefensiveTextField: UITextField!
    @IBOutlet weak var footballOffensiveTextField: UITextField!
    @IBOutlet weak var footballSpecialTeamsTextField: UITextField!
    @IBOutlet weak var footballOverallImageView: UIImageView!
    @IBOutlet weak var footballDefensiveImageView: UIImageView!
    @IBOutlet weak var footballOffensiveImageView: UIImageView!
    @IBOutlet weak var footballSpecialTeamsImageView: UIImageView!
    @IBOutlet weak var footballOverallDeleteButton: UIButton!
    @IBOutlet weak var footballDefensiveDeleteButton: UIButton!
    @IBOutlet weak var footballOffensiveDeleteButton: UIButton!
    @IBOutlet weak var footballSpecialTeamsDeleteButton: UIButton!
    
    @IBOutlet weak var regularPOGContainerView: UIView!
    @IBOutlet weak var regularOverallTextField: UITextField!
    @IBOutlet weak var regularOverallImageView: UIImageView!
    @IBOutlet weak var regularOverallDeleteButton: UIButton!
    
    @IBOutlet weak var tabBarContainer: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    private var customDatePickerView: CustomDatePickerView!
    private var searchOpponentVC: SearchOpponentViewController!
    private var calendarVC: ScheduleCalendarViewController!
    private var webVC: WebViewController!
    private var addPOGVC: AddPOGViewController!
    private var boxScoreVC: BoxScoreViewController!
    
    private var tickTimer: Timer!
    private var trackingGuid = ""
    private var positions = [""]
    private var scrollViewInitialHeight = 0
    private var currentSport = ""
    private var currentGender = ""
    private var teamColor = UIColor.mpRedColor()
    
    private var selectedSchool = School(fullName: "", name: "", schoolId: "", address: "", state: "", city: "", zip: "", searchDistance: 0.0, latitude: "", longitude: "")
    private var selectedDate = Date()
    private var selectedTime = Date()
    private var selectedGameType = -1
    private var selectedContest = [:] as Dictionary<String,Any>
    private var playersOfTheGame = [] as Array<Dictionary<String,Any>>
    
    private let kTextViewDefaultText = "Add additional details here..."
    private let kHomeAwayTypes = ["Home","Away","Neutral"]
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Update Contest
    
    private func updateContest()
    {
        var opponentTBA = false
        var dateCode = -1
        var myTeamHomeAway = -1
        var opponentHomeAway = -1
        
        // Set the opponent TBA
        if (opponentTextField.text == "TBA")
        {
            opponentTBA = true
        }
        
        // Build the date code
        if (dateTextField.text == "TBA") && (timeTextField.text != "TBA")
        {
            dateCode = 1
        }
        else if (dateTextField.text != "TBA") && (timeTextField.text == "TBA")
        {
            dateCode = 2
        }
        else if (dateTextField.text == "TBA") && (timeTextField.text == "TBA")
        {
            dateCode = 4
        }
        else
        {
            dateCode = 0
        }
        
        // Block playoff games if any of the above are TBA
        if (gameTypes[selectedGameType] == "Playoff")
        {
            if ((opponentTBA == true) || (dateCode != 0))
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Playoff games can not have TBA date, TBA time or TBA opponent.", lastItemCancelType: false) { tag in

                }
                
                return
            }
        }
        
        // Build the date string
        var selectedDateString = ""
        let dateFormatter = DateFormatter()
        
        switch dateCode
        {
        case 0: // Has date and time
            // Merge selectedDate and selectedTime into a string recognized by the feed
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: self.selectedDate)
            
            dateFormatter.dateFormat = "HH:mm:ss"
            let timeString = dateFormatter.string(from: self.selectedTime)
            
            // Required format: "yyyy-MM-ddTHH:mm:ssZ"
            selectedDateString = dateString + "T" + timeString // + "Z"
        
        case 1:// Has time and TBA date
            dateFormatter.dateFormat = "HH:mm:ss"
            let timeString = dateFormatter.string(from: self.selectedTime)
            
            // Required format: "1900-01-01THH:mm:ssZ"
            selectedDateString = "1900-01-01T" + timeString // + "Z"
            
        case 2: // Has date and TBA time
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: self.selectedDate)
            
            // Required format: "yyyy-MM-ddT00:00:00Z"
            selectedDateString =  dateString + "T00:00:00"
            
        default: // TBA date and time
            // Required format: "1901-01-01T00:00:00"
            selectedDateString = "1901-01-01T00:00:00"
        }
        
        // Build the homeAway codes
        if (homeAwayTextField.text == "Home")
        {
            myTeamHomeAway = 0
            opponentHomeAway = 1
        }
        else if (homeAwayTextField.text == "Away")
        {
            myTeamHomeAway = 1
            opponentHomeAway = 0
        }
        else
        {
            myTeamHomeAway = 2
            opponentHomeAway = 2
        }
        
        // Clean up the game details (note, it maps to the location property in the feed)
        var gameDetails = ""
        
        if (gameDetailsTextView.text != kTextViewDefaultText)
        {
            gameDetails = gameDetailsTextView.text
        }
        
        // Get the existing index for myTeam (it will be converted from 1,2 to 0,1 in the feed)
        let teams = self.selectedContest["teams"] as! Array<Dictionary<String,Any>>
        
        var myTeamIndex = 0
        var opponentIndex = 0
        
        for team in teams
        {
            let teamId = team["teamId"] as? String ?? ""
            if (teamId == self.selectedTeam!.schoolId)
            {
                myTeamIndex = team["index"] as! Int
            }
        }
        
        if (myTeamIndex == 1)
        {
            opponentIndex = 2
        }
        else
        {
            opponentIndex = 1
        }
        
        // Call the feed
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        ScheduleFeeds.updateSecureContest(myTeamSchoolId: selectedTeam!.schoolId, opponentSchoolId: selectedSchool.schoolId, contestId:self.contestId!, opponentTBA: opponentTBA, ssid: self.ssid!, dateString: selectedDateString, dateCode: dateCode, myTeamHomeAway: myTeamHomeAway, opponentHomeAway: opponentHomeAway, contestType: self.selectedGameType, location: gameDetails, myTeamIndex: myTeamIndex, opponentIndex: opponentIndex) { result, message, error in
            
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
                print("Update Contest Success")
                
                var title = "Game Updated"
                
                if (MiscHelper.sportUsesMatchInsteadOfGame(sport: self.selectedTeam!.sport) == true)
                {
                    title = "Match Updated"
                }
                
                OverlayView.showPopupOverlay(withMessage: title)
                {
                    self.delegate?.editGameSaveOrDeleteButtonTouched()
                }
            }
            else
            {
                print("Update Contest Failed")
                
                /*
                var message = "Something went wrong when trying to update this game."
                
                if (MiscHelper.sportUsesMatchInsteadOfGame(sport: self.selectedTeam!.sport) == true)
                {
                    message = "Something went wrong when trying to update this match."
                }
                */
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: message, lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - Get Contest
    
    private func getContest()
    {
        // Call the feed
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        ScheduleFeeds.getContest(schoolId: self.selectedTeam!.schoolId, ssid: self.ssid!, contestId: self.contestId!) { result, error in
            
            if (error == nil)
            {
                print("Get Contest Success")
                
                self.selectedContest = result!
                self.loadUserInterface()
                
                let hasResult = self.selectedContest["hasResult"] as! Bool
                
                if (hasResult == true)
                {
                    self.getPlayersOfTheGame()
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
                }
            }
            else
            {
                print("Get Contest Failed")
                
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
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This game could not be found.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - Get Players of the Game
    
    private func getPlayersOfTheGame()
    {
        ScheduleFeeds.getPlayersOfTheGame(schoolId: self.selectedTeam!.schoolId, ssid: self.ssid!, contestId: self.contestId!) { players, error in
            
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
                print("Get POG Success")
                self.playersOfTheGame = players!

                // Set the scrollView content size
                if (self.selectedTeam!.sport == "Football")
                {
                    self.footballPOGContainerView.isHidden = false
                    self.containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: self.footballPOGContainerView.frame.origin.y + self.footballPOGContainerView.frame.size.height)
                }
                else
                {
                    self.regularPOGContainerView.isHidden = false
                    self.containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: self.regularPOGContainerView.frame.origin.y + self.regularPOGContainerView.frame.size.height)
                }
                
                self.loadPlayersOfTheGameUserInterface()
            }
            else
            {
                print("Get POG Failed")
            }
        }
    }
    
    // MARK: - Delete Player of the Game
    
    private func deletePlayerOfTheGame(pogId: String)
    {
        // Call the feed
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        ScheduleFeeds.deletePlayerOfTheGame(schoolId: self.selectedTeam!.schoolId, ssid: self.ssid!, pogId: pogId) { result, error in
            
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
                print("Delete POG Success")
                
                self.getPlayersOfTheGame()
            }
            else
            {
                print("Delete POG Failed")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "The player of the game could not be deleted.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - Show Stats Web View Controller
    
    private func showStatsWebViewController()
    {
        // Get the correct URL using the selectedItemIndex and the filteredItemsArray
        var urlString = ""
        
        // Build the subdomain
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kContestStatsHostDev, self.selectedTeam!.schoolId, self.ssid!, self.contestId!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kContestStatsHostDev, self.selectedTeam!.schoolId, self.ssid!, self.contestId!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kContestStatsHostStaging, self.selectedTeam!.schoolId, self.ssid!, self.contestId!)
        }
        else
        {
            urlString = String(format: kContestStatsHostProduction, self.selectedTeam!.schoolId, self.ssid!, self.contestId!)
        }
        
        // Build the tracking context data object
        var cData = kEmptyTrackingContextData
        
        let userTeamRole = MiscHelper.userTeamRole(schoolId: self.selectedTeam!.schoolId, allSeasonId: self.selectedTeam!.allSeasonId)
        print(userTeamRole)
        
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
        
        TrackingManager.trackState(featureName: "stats-manage", trackingGuid: trackingGuid, cData: cData)
        
        webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC.titleString = "Stats"
        webVC.urlString = urlString
        webVC.titleColor = UIColor.mpBlackColor()
        webVC.navColor = UIColor.mpWhiteColor()
        webVC.allowRotation = false
        webVC.showShareButton = false
        webVC.showScrollIndicators = true
        webVC.showLoadingOverlay = true
        webVC.showBannerAd = false
        webVC.tabBarVisible = false
        webVC.enableAdobeQueryParameter = false // Needed for stats
        webVC.trackingContextData = cData
        webVC.trackingKey = "stats-manage"

        self.navigationController?.pushViewController(webVC, animated: true)
    
    }
    
    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelectTitles titles: [String])
    {
        switch pickerView.tag
        {
        case 1: // Home/Away
            homeAwayTextField.text = titles.first
            break
            
        case 2: // Game Type
            gameTypeTextField.text = titles.first
            self.selectedGameType = self.gameTypes!.firstIndex(of: titles.first!)!
            break
            
        default:
            break
        }
        
    }
    
    func actionSheetPickerViewDidCancel(_ pickerView: IQActionSheetPickerView)
    {
        
    }
    
    // MARK: - CustomDatePickerView Delegates
    
    func closeCustomDatePickerAfterDoneButtonTouched()
    {
        if (customDatePickerView.tbaIsOn == true)
        {
            timeTextField.text = "TBA"
        }
        else
        {
            let roundedDate = MiscHelper.dateToNearest5Minutes(date: customDatePickerView.selectedDate as Date)
            print (roundedDate)
            selectedTime = roundedDate
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            
            timeTextField.text = dateFormatter.string(from: roundedDate)
        }
        
        customDatePickerView.removeFromSuperview()
        customDatePickerView = nil
    }
    
    func closeCustomDatePickerAfterCancelButtonTouched()
    {
        customDatePickerView.removeFromSuperview()
        customDatePickerView = nil
    }
    
    // MARK: - SearchOpponentViewController Delegates
    
    func searchOpponentCancelButtonTouched()
    {
        self.dismiss(animated: true) {
            self.searchOpponentVC = nil
        }
    }
    
    func searchOpponentSelectSchoolTouched()
    {
        selectedSchool = searchOpponentVC.selectedSchool
        opponentTextField.text = searchOpponentVC.selectedSchool.name
        
        self.dismiss(animated: true) {
            self.searchOpponentVC = nil
        }
    }
    
    // MARK: - ScheduleCalendarViewController Delegates
    
    func scheduleCalendarCancelButtonTouched()
    {
        self.dismiss(animated: true) {
            self.calendarVC = nil
        }
    }
    
    func scheduleCalendarSelectButtonTouched()
    {
        selectedDate = calendarVC.selectedDate
        
        if (calendarVC.tbaDate == false)
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, MMM d"
            self.dateTextField.text = dateFormatter.string(from: selectedDate)
        }
        else
        {
            self.dateTextField.text = "TBA"
        }
        self.dismiss(animated: true) {
            self.calendarVC = nil
        }
    }
    
    // MARK: - AddPOG Delegates
    
    func addPOGSaveButtonTouched()
    {
        self.dismiss(animated: true)
        {
            self.addPOGVC = nil
            
            self.getPlayersOfTheGame()
        }
    }
    
    func addPOGCancelButtonTouched()
    {
        self.dismiss(animated: true)
        {
            self.addPOGVC = nil
        }
    }
    
    // MARK: - TBA Opponent Helper Method
    
    private func opponentIsTBA() -> Bool
    {
        // Find the opponent
        var opponentTeam: Dictionary<String,Any>
        let teams = selectedContest["teams"] as! Array<Dictionary<String,Any>>
        let teamA = teams.first
        let teamB = teams.last
        let teamASchoolId = teamA!["teamId"] as? String ?? ""
        
        if (teamASchoolId == self.selectedTeam?.schoolId)
        {
            opponentTeam = teamB!
        }
        else
        {
            opponentTeam = teamA!
        }
        
        let tbaTeam = opponentTeam["isTeamTBA"] as! Bool
        return tbaTeam
    }
    
    // MARK: - TextField Delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        // Click Tracking cData
        let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"pog-button-click", kClickTrackingModuleNameKey: "edit schedule", kClickTrackingModuleLocationKey:"edit schedule", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:""]
        
        if (textField == dateTextField)
        {
            calendarVC = ScheduleCalendarViewController(nibName: "ScheduleCalendarViewController", bundle: nil)
            calendarVC.delegate = self
            calendarVC.dimmedBackground = true
            calendarVC.availableDates = self.availableDates
            calendarVC.modalPresentationStyle = .overCurrentContext
            self.present(calendarVC, animated: true) {
                
            }
        }
        else if (textField == timeTextField)
        {
            customDatePickerView = CustomDatePickerView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight), dateMode: false, barColor: UIColor.mpPickerToolbarColor())
            customDatePickerView.delegate = self
            
            self.view.addSubview(customDatePickerView)
        }
        else if (textField == homeAwayTextField)
        {
            let picker = IQActionSheetPickerView(title: "Select Location", delegate: self)
            picker.toolbarButtonColor = UIColor.mpWhiteColor()
            picker.toolbarTintColor = UIColor.mpPickerToolbarColor()
            picker.titlesForComponents = [kHomeAwayTypes]
            picker.tag = 1
            picker.show()
        }
        else if (textField == gameTypeTextField)
        {
            // Remove "Exhibition" from the gameTypes array
            var filteredGameTypes = [] as! Array<String>
            for gameType in self.gameTypes
            {
                if (gameType != "Exhibition")
                {
                    filteredGameTypes.append(gameType)
                }
            }
            
            let picker = IQActionSheetPickerView(title: "Select Game Type", delegate: self)
            picker.toolbarButtonColor = UIColor.mpWhiteColor()
            picker.toolbarTintColor = UIColor.mpPickerToolbarColor()
            picker.titlesForComponents = [filteredGameTypes]
            picker.tag = 2
            picker.show()
        }
        else if (textField == opponentTextField)
        {
            searchOpponentVC = SearchOpponentViewController(nibName: "SearchOpponentViewController", bundle: nil)
            searchOpponentVC.delegate = self
            searchOpponentVC.dimmedBackground = true
            searchOpponentVC.schoolId = selectedTeam!.schoolId
            searchOpponentVC.teamLevel = selectedTeam!.teamLevel
            searchOpponentVC.ssid = self.ssid
            searchOpponentVC.modalPresentationStyle = .overCurrentContext
            self.present(searchOpponentVC, animated: true) {
                
            }
        }
        else if (textField == scoreTextField)
        {
            // Check the game state to see if the contestState is a 3, 4 or 5
            if ((self.contestState == 3) || (self.contestState == 4) || (self.contestState == 5))
            {
                // Check if the opponent is TBA
                if (self.opponentIsTBA() == true)
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "You can not enter a score for this game because the opponent is TBA.", lastItemCancelType: false) { tag in

                    }
                }
                else
                {
                    boxScoreVC = BoxScoreViewController(nibName: "BoxScoreViewController", bundle: nil)
                    boxScoreVC.selectedTeam = self.selectedTeam
                    boxScoreVC.selectedContest = self.selectedContest
                    boxScoreVC.ssid = self.ssid
                    boxScoreVC.contestState = self.contestState
                    
                    self.navigationController?.pushViewController(boxScoreVC, animated: true)
                }
            }
            else if (self.contestState == 6) // Added contestState = 6 for TBA opponent
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "You can not enter a score for this game because the opponent is TBA.", lastItemCancelType: false) { tag in

                }
            }
            else if (self.contestState == 7) // Added contestState = 7 for TBA date
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "You can not enter a score for this game because the date is TBA.", lastItemCancelType: false) { tag in

                }
            }
            else
            {
                // Check if the date is TBA
                let dateCode = selectedContest["dateCode"] as! Int
                /*
                 Default = 0,
                 DateTBA = 1,
                 TimeTBA = 2,
                 DateTimeTBA = 4
                 */
                if ((dateCode == 1) || (dateCode == 4))
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "You can not enter a score for this game because the date is TBA.", lastItemCancelType: false) { tag in

                    }
                }
                else
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "You can not enter a score for this game because the game hasn't started.", lastItemCancelType: false) { tag in

                    }
                }
            }
        }
        else if (textField == statsTextField)
        {
            // Block stats entry if in pregame
            if (self.contestState == 2)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "You can not enter stats for this game because the game hasn't started.", lastItemCancelType: false) { tag in

                }
            }
            else
            {
                self.showStatsWebViewController()
            }
        }
        else if (textField == regularOverallTextField)
        {
            // Build a RosterAthlete object
            var pogAthlete = RosterAthlete(athleteId: "", firstName: "", lastName: "", classYear: "", jersey: "", heightInches: "", heightFeet: "", weight: "", position1: "", position2: "", position3: "", hasStats: false, isCaptain: false, isDeleted: false, photoUrl: "", weightClass: "", isPlayerOfTheGame: false, isFemale: false, bio: "", hasPhoto: false, rosterId: "", careerId: "")
            var comments = ""
            var pogId = ""
            var editMode = false
            
            for pogObj in playersOfTheGame
            {
                let type = pogObj["type"] as! String
                
                if (type == "Player")
                {
                    editMode = true
                    pogAthlete.firstName = pogObj["athleteFirstName"] as? String ?? ""
                    pogAthlete.lastName = pogObj["athleteLastName"] as? String ?? ""
                    pogAthlete.athleteId = pogObj["athleteId"] as! String
                    comments = pogObj["comments"] as! String
                    pogId = pogObj["playerOfTheGameId"] as! String
                    break
                }
            }
            
            if (addPOGVC != nil)
            {
                addPOGVC = nil
            }
            
            addPOGVC = AddPOGViewController(nibName: "AddPOGViewController", bundle: nil)
            addPOGVC.delegate = self
            addPOGVC.selectedTeam = self.selectedTeam
            addPOGVC.selectedAthlete = pogAthlete
            addPOGVC.ssid = self.ssid
            addPOGVC.contestId = self.contestId
            addPOGVC.type = "Player"
            addPOGVC.comments = comments
            addPOGVC.pogId = pogId
            addPOGVC.editMode = editMode
            addPOGVC.modalPresentationStyle = .overCurrentContext
            
            self.present(addPOGVC, animated: true) {
                
            }
            
            TrackingManager.trackEvent(featureName: "player-of-the-game", cData: cData)
        }
        else if (textField == footballOverallTextField)
        {
            // Build a RosterAthlete object
            var pogAthlete = RosterAthlete(athleteId: "", firstName: "", lastName: "", classYear: "", jersey: "", heightInches: "", heightFeet: "", weight: "", position1: "", position2: "", position3: "", hasStats: false, isCaptain: false, isDeleted: false, photoUrl: "", weightClass: "", isPlayerOfTheGame: false, isFemale: false, bio: "", hasPhoto: false, rosterId: "", careerId: "")
            var comments = ""
            var pogId = ""
            var editMode = false
            
            for pogObj in playersOfTheGame
            {
                let type = pogObj["type"] as! String
                
                if (type == "Overall")
                {
                    editMode = true
                    pogAthlete.firstName = pogObj["athleteFirstName"] as? String ?? ""
                    pogAthlete.lastName = pogObj["athleteLastName"] as? String ?? ""
                    pogAthlete.athleteId = pogObj["athleteId"] as! String
                    comments = pogObj["comments"] as! String
                    pogId = pogObj["playerOfTheGameId"] as! String
                    break
                }
            }
            
            if (addPOGVC != nil)
            {
                addPOGVC = nil
            }
            
            addPOGVC = AddPOGViewController(nibName: "AddPOGViewController", bundle: nil)
            addPOGVC.delegate = self
            addPOGVC.selectedTeam = self.selectedTeam
            addPOGVC.selectedAthlete = pogAthlete
            addPOGVC.ssid = self.ssid
            addPOGVC.contestId = self.contestId
            addPOGVC.type = "Overall"
            addPOGVC.comments = comments
            addPOGVC.pogId = pogId
            addPOGVC.editMode = editMode
            addPOGVC.modalPresentationStyle = .overCurrentContext
            
            self.present(addPOGVC, animated: true) {
                
            }
            
            TrackingManager.trackEvent(featureName: "player-of-the-game", cData: cData)
        }
        else if (textField == footballDefensiveTextField)
        {
            // Build a RosterAthlete object
            var pogAthlete = RosterAthlete(athleteId: "", firstName: "", lastName: "", classYear: "", jersey: "", heightInches: "", heightFeet: "", weight: "", position1: "", position2: "", position3: "", hasStats: false, isCaptain: false, isDeleted: false, photoUrl: "", weightClass: "", isPlayerOfTheGame: false, isFemale: false, bio: "", hasPhoto: false, rosterId: "", careerId: "")
            var comments = ""
            var pogId = ""
            var editMode = false
            
            for pogObj in playersOfTheGame
            {
                let type = pogObj["type"] as! String
                
                if (type == "Defensive")
                {
                    editMode = true
                    pogAthlete.firstName = pogObj["athleteFirstName"] as? String ?? ""
                    pogAthlete.lastName = pogObj["athleteLastName"] as? String ?? ""
                    pogAthlete.athleteId = pogObj["athleteId"] as! String
                    comments = pogObj["comments"] as! String
                    pogId = pogObj["playerOfTheGameId"] as! String
                    break
                }
            }
            
            if (addPOGVC != nil)
            {
                addPOGVC = nil
            }
            
            addPOGVC = AddPOGViewController(nibName: "AddPOGViewController", bundle: nil)
            addPOGVC.delegate = self
            addPOGVC.selectedTeam = self.selectedTeam
            addPOGVC.selectedAthlete = pogAthlete
            addPOGVC.ssid = self.ssid
            addPOGVC.contestId = self.contestId
            addPOGVC.type = "Defensive"
            addPOGVC.comments = comments
            addPOGVC.pogId = pogId
            addPOGVC.editMode = editMode
            addPOGVC.modalPresentationStyle = .overCurrentContext
            
            self.present(addPOGVC, animated: true) {
                
            }
            
            TrackingManager.trackEvent(featureName: "player-of-the-game", cData: cData)
        }
        else if (textField == footballOffensiveTextField)
        {
            // Build a RosterAthlete object
            var pogAthlete = RosterAthlete(athleteId: "", firstName: "", lastName: "", classYear: "", jersey: "", heightInches: "", heightFeet: "", weight: "", position1: "", position2: "", position3: "", hasStats: false, isCaptain: false, isDeleted: false, photoUrl: "", weightClass: "", isPlayerOfTheGame: false, isFemale: false, bio: "", hasPhoto: false, rosterId: "", careerId: "")
            var comments = ""
            var pogId = ""
            var editMode = false
            
            for pogObj in playersOfTheGame
            {
                let type = pogObj["type"] as! String
                
                if (type == "Offensive")
                {
                    editMode = true
                    pogAthlete.firstName = pogObj["athleteFirstName"] as? String ?? ""
                    pogAthlete.lastName = pogObj["athleteLastName"] as? String ?? ""
                    pogAthlete.athleteId = pogObj["athleteId"] as! String
                    comments = pogObj["comments"] as! String
                    pogId = pogObj["playerOfTheGameId"] as! String
                    break
                }
            }
            
            if (addPOGVC != nil)
            {
                addPOGVC = nil
            }
            
            addPOGVC = AddPOGViewController(nibName: "AddPOGViewController", bundle: nil)
            addPOGVC.delegate = self
            addPOGVC.selectedTeam = self.selectedTeam
            addPOGVC.selectedAthlete = pogAthlete
            addPOGVC.ssid = self.ssid
            addPOGVC.contestId = self.contestId
            addPOGVC.type = "Offensive"
            addPOGVC.comments = comments
            addPOGVC.pogId = pogId
            addPOGVC.editMode = editMode
            addPOGVC.modalPresentationStyle = .overCurrentContext
            
            self.present(addPOGVC, animated: true) {
                
            }
            
            TrackingManager.trackEvent(featureName: "player-of-the-game", cData: cData)
        }
        else if (textField == footballSpecialTeamsTextField)
        {
            // Build a RosterAthlete object
            var pogAthlete = RosterAthlete(athleteId: "", firstName: "", lastName: "", classYear: "", jersey: "", heightInches: "", heightFeet: "", weight: "", position1: "", position2: "", position3: "", hasStats: false, isCaptain: false, isDeleted: false, photoUrl: "", weightClass: "", isPlayerOfTheGame: false, isFemale: false, bio: "", hasPhoto: false, rosterId: "", careerId: "")
            var comments = ""
            var pogId = ""
            var editMode = false
            
            for pogObj in playersOfTheGame
            {
                let type = pogObj["type"] as! String
                
                if (type == "Special Teams")
                {
                    editMode = true
                    pogAthlete.firstName = pogObj["athleteFirstName"] as? String ?? ""
                    pogAthlete.lastName = pogObj["athleteLastName"] as? String ?? ""
                    pogAthlete.athleteId = pogObj["athleteId"] as! String
                    comments = pogObj["comments"] as! String
                    pogId = pogObj["playerOfTheGameId"] as! String
                    break
                }
            }
            
            if (addPOGVC != nil)
            {
                addPOGVC = nil
            }
            
            addPOGVC = AddPOGViewController(nibName: "AddPOGViewController", bundle: nil)
            addPOGVC.delegate = self
            addPOGVC.selectedTeam = self.selectedTeam
            addPOGVC.selectedAthlete = pogAthlete
            addPOGVC.ssid = self.ssid
            addPOGVC.contestId = self.contestId
            addPOGVC.type = "Special Teams"
            addPOGVC.comments = comments
            addPOGVC.pogId = pogId
            addPOGVC.editMode = editMode
            addPOGVC.modalPresentationStyle = .overCurrentContext
            
            self.present(addPOGVC, animated: true) {
                
            }
            
            TrackingManager.trackEvent(featureName: "player-of-the-game", cData: cData)
        }
        
        return false
    }
    
    // MARK: - TextView Delegates
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        textView.textColor = UIColor.mpBlackColor()
        
        if (textView.text == kTextViewDefaultText)
        {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == "")
        {
            textView.text = kTextViewDefaultText
            textView.textColor = UIColor.mpLightGrayColor()
        }
        else
        {
            let badWords = IODProfanityFilter.rangesOfFilteredWords(in: gameDetailsTextView.text)
            
            if (badWords!.count > 0)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Language", message: "The text that you have entered is objectionable and can not be used.", lastItemCancelType: false) { tag in

                    self.gameDetailsTextView.text = self.kTextViewDefaultText
                    self.gameDetailsTextView.textColor = UIColor.mpLightGrayColor()
                }
                return
            }
            
            if (textView.text.containsEmoji == true)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "You can't use special characters in this field.", lastItemCancelType: false) { tag in
                    
                }
                return
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if let paste = UIPasteboard.general.string, text == paste
        {
            // Pasteboard
            if ((textView.text.count + text.count) > 50)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Excess Length", message: "The text that you are pasting will exceed the 50 character limit.", lastItemCancelType: false) { tag in
                    
                }
                return false
            }
            return true
        }
        else
        {
            // Normal typing
            if (text == "\n")
            {
                return false
            }
            
            if (range.location > 49)
            {
                return false
            }
            return true
        }
    }
    
    // MARK: - Load User Interface
    
    private func loadUserInterface()
    {
        // Get the dateCode to decide how to set the dateLabel and timeLabel
        let dateCode = selectedContest["dateCode"] as! Int
        /*
         Default = 0,
         DateTBA = 1,
         TimeTBA = 2,
         DateTimeTBA = 4
         */
        
        var contestDateString = selectedContest["date"] as? String ?? "1901-01-01T00:00:00"
        contestDateString = contestDateString.replacingOccurrences(of: "Z", with: "")
        let dateFormatter = DateFormatter()
        dateFormatter.isLenient = true
        dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
        let contestDate = dateFormatter.date(from: contestDateString)
        
        // Set the selectedDate and selectedTime objects for the updateContest method
        self.selectedDate = contestDate!
        self.selectedTime = contestDate!
        
        switch dateCode
        {
        case 0: // Default
            dateFormatter.dateFormat = "EEEE, MMM d"
            let dateString = dateFormatter.string(from: contestDate!)
            dateTextField.text = dateString

            dateFormatter.dateFormat = "h:mm a"
            timeTextField.text = dateFormatter.string(from: contestDate!)
            
        case 1: // DateTBA
            dateTextField.text = "TBA"
            dateFormatter.dateFormat = "h:mm a"
            timeTextField.text = dateFormatter.string(from: contestDate!)
            
        case 2: // TimeTBA
            dateFormatter.dateFormat = "EEEE, MMM d"
            let dateString = dateFormatter.string(from: contestDate!)
            dateTextField.text = dateString
            
            timeTextField.text = "TBA"
            
        default:
            dateTextField.text = "TBA"
            timeTextField.text = "TBA"
        }
        
        // Find the opponent
        var opponentTeam: Dictionary<String,Any>
        var myTeam: Dictionary<String,Any>
        let teams = selectedContest["teams"] as! Array<Dictionary<String,Any>>
        let teamA = teams.first
        let teamB = teams.last
        let teamASchoolId = teamA!["teamId"] as? String ?? ""
        
        if (teamASchoolId == self.selectedTeam?.schoolId)
        {
            myTeam = teamA!
            opponentTeam = teamB!
        }
        else
        {
            myTeam = teamB!
            opponentTeam = teamA!
        }
        
        // Load the game detail
        let haType = opponentTeam["homeAwayType"] as! Int
        
        switch haType
        {
        case 0:
            homeAwayTextField.text = "Away"
        case 1:
            homeAwayTextField.text = "Home"
        case 2:
            homeAwayTextField.text = "Neutral"
        default:
            homeAwayTextField.text = "Unknown"
        }
        
        // Load the game type
        let gameType = opponentTeam["contestType"] as! Int
        self.selectedGameType = gameType
        gameTypeTextField.text = self.gameTypes![gameType]
        
        // Load the school name and schoolId into the selectedSchool obj.
        let tbaTeam = opponentTeam["isTeamTBA"] as! Bool
        
        if (tbaTeam == false)
        {
            opponentTextField.text = opponentTeam["name"] as? String
            self.selectedSchool.name = opponentTeam["name"] as! String
            self.selectedSchool.schoolId = opponentTeam["teamId"] as! String
        }
        else
        {
            opponentTextField.text = "TBA"
            self.selectedSchool.name = "TBA"
            self.selectedSchool.schoolId = ""
        }
        
        // Set the location label
        if (selectedContest["location"] is NSNull)
        {
            gameDetailsTextView.text = kTextViewDefaultText
            gameDetailsTextView.textColor = UIColor.mpLightGrayColor()
            gameDetailsTextCountLabel.text = "0 / 50 Characters"
        }
        else
        {
            let location = selectedContest["location"] as! String
            gameDetailsTextView.text = location
            gameDetailsTextView.textColor = UIColor.mpBlackColor()
            gameDetailsTextCountLabel.text = String(gameDetailsTextView.text.count) + " / 50 Characters"
        }
        
        // Load Scores
        let myTeamForfeit = myTeam["isForfeit"] as! Bool
        let opponentForfeit = opponentTeam["isForfeit"] as! Bool
        
        if (myTeamForfeit == true) || (opponentForfeit == true)
        {
            if (myTeamForfeit == true) && (opponentForfeit == true)
            {
                let scoreText = "L (DFF)"
                
                // Colorize the text
                let attributedString = NSMutableAttributedString(string: scoreText)
                let range = scoreText.range(of: "L")
                let convertedRange = NSRange(range!, in: scoreText)
                
                attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 14), NSAttributedString.Key.foregroundColor: UIColor.mpRedColor()], range: convertedRange)
                
                scoreTextField.attributedText = attributedString
            }
            else if (myTeamForfeit == true) && (opponentForfeit == false)
            {
                let scoreText = "L (FF)"
                
                // Colorize the text
                let attributedString = NSMutableAttributedString(string: scoreText)
                let range = scoreText.range(of: "L")
                let convertedRange = NSRange(range!, in: scoreText)
                
                attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 14), NSAttributedString.Key.foregroundColor: UIColor.mpRedColor()], range: convertedRange)
                
                scoreTextField.attributedText = attributedString
            }
            else
            {
                let scoreText = "W (FF)"
                
                // Colorize the text
                let attributedString = NSMutableAttributedString(string: scoreText)
                let range = scoreText.range(of: "W")
                let convertedRange = NSRange(range!, in: scoreText)
                
                attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 14), NSAttributedString.Key.foregroundColor: UIColor.mpGreenColor()], range: convertedRange)
                
                scoreTextField.attributedText = attributedString
            }
        }
        else
        {
            // Set the scores (checking for nulls)
            let myScore = myTeam["score"] as? Int ?? -1
            let opponentScore = opponentTeam["score"] as? Int ?? -1
            
            if (myScore != -1) && (opponentScore != -1)
            {
                let myResult = myTeam["result"] as? String ?? ""
                
                if (myResult.lowercased() == "w")
                {
                    let scoreText = "W " + String(myScore) + "-" + String(opponentScore)
                    
                    // Colorize the text
                    let attributedString = NSMutableAttributedString(string: scoreText)
                    let range = scoreText.range(of: "W")
                    let convertedRange = NSRange(range!, in: scoreText)
                    
                    attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 14), NSAttributedString.Key.foregroundColor: UIColor.mpGreenColor()], range: convertedRange)
                    
                    scoreTextField.attributedText = attributedString
                }
                else if (myResult.lowercased() == "l")
                {
                    let scoreText = "L " + String(myScore) + "-" + String(opponentScore)
                    
                    // Colorize the text
                    let attributedString = NSMutableAttributedString(string: scoreText)
                    let range = scoreText.range(of: "L")
                    let convertedRange = NSRange(range!, in: scoreText)
                    
                    attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 14), NSAttributedString.Key.foregroundColor: UIColor.mpRedColor()], range: convertedRange)
                    
                    scoreTextField.attributedText = attributedString
                }
                else
                {
                    scoreTextField.font = UIFont.mpRegularFontWith(size: 14)
                    scoreTextField.textColor = UIColor.mpBlackColor()
                    scoreTextField.text = "T " + String(myScore) + "-" + String(opponentScore)
                }
            }
            else
            {
                scoreTextField.text = ""
            }
        }
        
        // Load the stats
        let myTeamHasStats = myTeam["hasStats"] as! Bool
        
        if (myTeamHasStats == true)
        {
            statsTextField.text = "Stats Entered"
        }
        else
        {
            statsTextField.text = ""
        }
    }
    
    // MARK: - Load POG Interface
    
    private func loadPlayersOfTheGameUserInterface()
    {
        /*
         {
               "teamId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
               "sportSeasonId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
               "athleteId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
               "careerProfileId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
               "comments": "string",
               "type": "string",
               "createdOn": "2021-10-11T16:23:45.940Z",
               "athleteFirstName": "string",
               "athleteLastName": "string",
               "athletePhotoUrl": "string",
               "badgeUrl": "string",
               "ssid": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
               "schoolId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
               "playerOfTheGameId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
               "contestId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
               "modifiedOn": "2021-10-11T16:23:45.940Z"
             }
         */
        
        regularOverallTextField.text = ""
        footballOverallTextField.text = ""
        footballDefensiveTextField.text = ""
        footballOffensiveTextField.text = ""
        footballSpecialTeamsTextField.text = ""
        
        regularOverallImageView.image = UIImage(named: "Avatar")
        footballOverallImageView.image = UIImage(named: "Avatar")
        footballDefensiveImageView.image = UIImage(named: "Avatar")
        footballOffensiveImageView.image = UIImage(named: "Avatar")
        footballSpecialTeamsImageView.image = UIImage(named: "Avatar")
        
        for pogObj in playersOfTheGame
        {
            let type = pogObj["type"] as! String
            
            if (type == "Player")
            {
                let firstName = pogObj["athleteFirstName"] as! String
                let lastName = pogObj["athleteLastName"] as! String
                regularOverallTextField.text = firstName + " " + lastName
                
                let photoUrl = pogObj["athletePhotoUrl"] as? String ?? ""
                
                if (photoUrl.count > 0)
                {
                    let url = URL(string: photoUrl)
                    
                    // Get the data and make an image
                    MiscHelper.getData(from: url!) { data, response, error in
                        guard let data = data, error == nil else { return }
                        
                        DispatchQueue.main.async()
                        {
                            let image = UIImage(data: data)
                            
                            if (image != nil)
                            {
                                self.regularOverallImageView.image = image
                            }
                        }
                    }
                }
            }
            else if (type == "Overall")
            {
                let firstName = pogObj["athleteFirstName"] as? String ?? ""
                let lastName = pogObj["athleteLastName"] as? String ?? ""
                footballOverallTextField.text = firstName + " " + lastName
                
                let photoUrl = pogObj["athletePhotoUrl"] as? String ?? ""
                
                if (photoUrl.count > 0)
                {
                    let url = URL(string: photoUrl)
                    
                    // Get the data and make an image
                    MiscHelper.getData(from: url!) { data, response, error in
                        guard let data = data, error == nil else { return }
                        
                        DispatchQueue.main.async()
                        {
                            let image = UIImage(data: data)
                            
                            if (image != nil)
                            {
                                self.footballOverallImageView.image = image
                            }
                        }
                    }
                }
            }
            else if (type == "Defensive")
            {
                let firstName = pogObj["athleteFirstName"] as? String ?? ""
                let lastName = pogObj["athleteLastName"] as? String ?? ""
                footballDefensiveTextField.text = firstName + " " + lastName
                
                let photoUrl = pogObj["athletePhotoUrl"] as? String ?? ""
                
                if (photoUrl.count > 0)
                {
                    let url = URL(string: photoUrl)
                    
                    // Get the data and make an image
                    MiscHelper.getData(from: url!) { data, response, error in
                        guard let data = data, error == nil else { return }
                        
                        DispatchQueue.main.async()
                        {
                            let image = UIImage(data: data)
                            
                            if (image != nil)
                            {
                                self.footballDefensiveImageView.image = image
                            }
                        }
                    }
                }
            }
            else if (type == "Offensive")
            {
                let firstName = pogObj["athleteFirstName"] as? String ?? ""
                let lastName = pogObj["athleteLastName"] as? String ?? ""
                footballOffensiveTextField.text = firstName + " " + lastName
                
                let photoUrl = pogObj["athletePhotoUrl"] as? String ?? ""
                
                if (photoUrl.count > 0)
                {
                    let url = URL(string: photoUrl)
                    
                    // Get the data and make an image
                    MiscHelper.getData(from: url!) { data, response, error in
                        guard let data = data, error == nil else { return }
                        
                        DispatchQueue.main.async()
                        {
                            let image = UIImage(data: data)
                            
                            if (image != nil)
                            {
                                self.footballOffensiveImageView.image = image
                            }
                        }
                    }
                }
            }
            else if (type == "Special Teams")
            {
                let firstName = pogObj["athleteFirstName"] as? String ?? ""
                let lastName = pogObj["athleteLastName"] as? String ?? ""
                footballSpecialTeamsTextField.text = firstName + " " + lastName
                
                let photoUrl = pogObj["athletePhotoUrl"] as? String ?? ""
                
                if (photoUrl.count > 0)
                {
                    let url = URL(string: photoUrl)
                    
                    // Get the data and make an image
                    MiscHelper.getData(from: url!) { data, response, error in
                        guard let data = data, error == nil else { return }
                        
                        DispatchQueue.main.async()
                        {
                            let image = UIImage(data: data)
                            
                            if (image != nil)
                            {
                                self.footballSpecialTeamsImageView.image = image
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        // Update the gameDetailsTextCountLabel
        if (gameDetailsTextView.text != kTextViewDefaultText)
        {
            gameDetailsTextCountLabel.text = String(gameDetailsTextView.text.count) + " / 50 Characters"
        }
        else
        {
            gameDetailsTextCountLabel.text = "0 / 50 Characters"
        }
        
        if ((dateTextField.text!.count > 0) && (timeTextField.text!.count > 0) && (homeAwayTextField.text!.count > 0) && (gameTypeTextField.text!.count > 0) && (opponentTextField.text!.count > 0))
        {
            saveButton.backgroundColor = teamColor
            saveButton.isEnabled = true
            
            deleteButton.layer.borderColor = teamColor.cgColor
            deleteButton.setTitleColor(teamColor, for: .normal)
            deleteButton.isEnabled = true
        }
        else
        {
            saveButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
            saveButton.isEnabled = false
            
            deleteButton.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
            deleteButton.setTitleColor(UIColor.mpGrayButtonBorderColor(), for: .normal)
            deleteButton.isEnabled = false
        }
        
        // Show/Hide the delete POG buttons
        if (regularOverallTextField.text!.count > 0)
        {
            regularOverallDeleteButton.isHidden = false
        }
        else
        {
            regularOverallDeleteButton.isHidden = true
        }
        
        if (footballOverallTextField.text!.count > 0)
        {
            footballOverallDeleteButton.isHidden = false
        }
        else
        {
            footballOverallDeleteButton.isHidden = true
        }
        
        if (footballDefensiveTextField.text!.count > 0)
        {
            footballDefensiveDeleteButton.isHidden = false
        }
        else
        {
            footballDefensiveDeleteButton.isHidden = true
        }
        
        if (footballOffensiveTextField.text!.count > 0)
        {
            footballOffensiveDeleteButton.isHidden = false
        }
        else
        {
            footballOffensiveDeleteButton.isHidden = true
        }
        
        if (footballSpecialTeamsTextField.text!.count > 0)
        {
            footballSpecialTeamsDeleteButton.isHidden = false
        }
        else
        {
            footballSpecialTeamsDeleteButton.isHidden = true
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func cancelButtonTouched(_ sender: UIButton)
    {
        self.delegate?.editGameCancelButtonTouched()
    }
    
    @objc private func gameDetailsDoneButtonTouched()
    {
        gameDetailsTextView.resignFirstResponder()
    }
    
    @IBAction func saveButtonTouched(_ sender: UIButton)
    {
        self.updateContest()
    }
    
    @IBAction func deleteButtonTouched(_ sender: UIButton)
    {
        var title = "Delete Game"
        var message = "Are you sure you want to delete this game from the schedule?"
        
        if (MiscHelper.sportUsesMatchInsteadOfGame(sport: selectedTeam!.sport) == true)
        {
            title = "Delete Match"
            message = "Are you sure you want to delete this match from the schedule?"
        }
        
        MiscHelper.showAlert(in: self, withActionNames: ["Delete", "Cancel"], title: title, message: message, lastItemCancelType: false) { (tag) in
            if (tag == 0)
            {
                // Call the feed
                //MBProgressHUD.showAdded(to: self.view, animated: true)
                if (self.progressOverlay == nil)
                {
                    self.progressOverlay = ProgressHUD()
                    self.progressOverlay.show(animated: false)
                }
                
                ScheduleFeeds.deleteSecureContest(schoolId: self.selectedTeam!.schoolId, ssid: self.ssid!, contestId: self.contestId!) { result, error in
                    
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
                        print("Delete Game Success")
                        
                        var title = "Game Deleted"
                        
                        if (MiscHelper.sportUsesMatchInsteadOfGame(sport: self.selectedTeam!.sport) == true)
                        {
                            title = "Match Deleted"
                        }
                        OverlayView.showPopupOverlay(withMessage: title)
                        {
                            self.delegate?.editGameSaveOrDeleteButtonTouched()
                        }
                    }
                    else
                    {
                        print("Delete Game Failed")
                        
                        var message = "Something went wrong when trying to delete this game."
                        
                        if (MiscHelper.sportUsesMatchInsteadOfGame(sport: self.selectedTeam!.sport) == true)
                        {
                            message = "Something went wrong when trying to delete this match."
                        }
                        
                        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: message, lastItemCancelType: false) { tag in
                            
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func regularOverallDeleteButtonTouched()
    {
        MiscHelper.showAlert(in: self, withActionNames: ["Delete", "Cancel"], title: "Delete Player", message: "Are you sure you want to delete the player of the game?", lastItemCancelType: false) { (tag) in
            if (tag == 0)
            {
                // Find the pogId from the feed
                for pogObj in self.playersOfTheGame
                {
                    let type = pogObj["type"] as! String
                    
                    if (type == "Player")
                    {
                        let pogId = pogObj["playerOfTheGameId"] as! String
                        self.deletePlayerOfTheGame(pogId: pogId)
                    }
                }
            }
        }
    }
    
    @IBAction func footballOverallDeleteButtonTouched()
    {
        MiscHelper.showAlert(in: self, withActionNames: ["Delete", "Cancel"], title: "Delete Player", message: "Are you sure you want to delete the overall player of the game?", lastItemCancelType: false) { (tag) in
            if (tag == 0)
            {
                // Find the pogId from the feed
                for pogObj in self.playersOfTheGame
                {
                    let type = pogObj["type"] as! String
                    
                    if (type == "Overall")
                    {
                        let pogId = pogObj["playerOfTheGameId"] as! String
                        self.deletePlayerOfTheGame(pogId: pogId)
                    }
                }
            }
        }
    }
    
    @IBAction func footballDefensiveDeleteButtonTouched()
    {
        MiscHelper.showAlert(in: self, withActionNames: ["Delete", "Cancel"], title: "Delete Player", message: "Are you sure you want to delete the defensive player of the game?", lastItemCancelType: false) { (tag) in
            if (tag == 0)
            {
                // Find the pogId from the feed
                for pogObj in self.playersOfTheGame
                {
                    let type = pogObj["type"] as! String
                    
                    if (type == "Defensive")
                    {
                        let pogId = pogObj["playerOfTheGameId"] as! String
                        self.deletePlayerOfTheGame(pogId: pogId)
                    }
                }
            }
        }
    }
    
    @IBAction func footballOffensiveDeleteButtonTouched()
    {
        MiscHelper.showAlert(in: self, withActionNames: ["Delete", "Cancel"], title: "Delete Player", message: "Are you sure you want to delete the offensive player of the game?", lastItemCancelType: false) { (tag) in
            if (tag == 0)
            {
                // Find the pogId from the feed
                for pogObj in self.playersOfTheGame
                {
                    let type = pogObj["type"] as! String
                    
                    if (type == "Offensive")
                    {
                        let pogId = pogObj["playerOfTheGameId"] as! String
                        self.deletePlayerOfTheGame(pogId: pogId)
                    }
                }
            }
        }
    }
    
    @IBAction func footballSpecialTeamsDeleteButtonTouched()
    {
        MiscHelper.showAlert(in: self, withActionNames: ["Delete", "Cancel"], title: "Delete Player", message: "Are you sure you want to delete the special teams player of the game?", lastItemCancelType: false) { (tag) in
            if (tag == 0)
            {
                // Find the pogId from the feed
                for pogObj in self.playersOfTheGame
                {
                    let type = pogObj["type"] as! String
                    
                    if (type == "Special Teams")
                    {
                        let pogId = pogObj["playerOfTheGameId"] as! String
                        self.deletePlayerOfTheGame(pogId: pogId)
                    }
                }
            }
        }
    }
    
    // MARK: - Keyboard Notifications
    
    @objc private func keyboardDidShow(notification: Notification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            //print("Keyboard Height: " + String(Int(keyboardSize.size.height)))

            // Need to use the device coordinates for this calculation
            let gameDetailContainerViewBottom = Int(containerScrollView.frame.origin.y) + Int(gameDetailsContainerView.frame.origin.y) + Int(gameDetailsContainerView.frame.size.height)
            
            let keyboardTop = Int(kDeviceHeight) - Int(keyboardSize.size.height)
            
            if (keyboardTop < gameDetailContainerViewBottom)
            {
                let difference = gameDetailContainerViewBottom - keyboardTop
                containerScrollView.contentOffset = CGPoint(x: 0, y: difference)
            }
        }
    }
    
    @objc private func keyboardDidHide(notification: Notification)
    {
        //print("Keyboard will hide")
        containerScrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    // MARK: - Keyboard Accessory Views
    
    private func addKeyboardAccessoryView()
    {
        let gameDetailsAccessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        gameDetailsAccessoryView.backgroundColor = UIColor.mpRedColor()
        
        let gameDetailsDoneButton = UIButton(type: .custom)
        gameDetailsDoneButton.frame = CGRect(x: kDeviceWidth - 85, y: 5, width: 80, height: 30)
        gameDetailsDoneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        gameDetailsDoneButton.setTitle("Done", for: .normal)
        gameDetailsDoneButton.setTitleColor(UIColor.mpWhiteColor(), for: .normal)
        gameDetailsDoneButton.addTarget(self, action: #selector(gameDetailsDoneButtonTouched), for: .touchUpInside)
        gameDetailsAccessoryView.addSubview(gameDetailsDoneButton)
        gameDetailsTextView!.inputAccessoryView = gameDetailsAccessoryView
    
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        trackingGuid = NSUUID().uuidString

        currentSport = selectedTeam!.sport
        currentGender = selectedTeam!.gender
        
        if (MiscHelper.sportUsesMatchInsteadOfGame(sport: currentSport) == true)
        {
            navTitleLabel.text = "Edit Match"
            gameDetailsHeaderLabel.text = "Match Details (optional)"
        }
        
        let hexColorString = self.selectedTeam?.teamColor
        teamColor = ColorHelper.color(fromHexString: hexColorString, colorCorrection: true)!
 
        // Size and locate the fakeStatusBar, navBar, containerScrollView, and tabBarContainer
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        
        scrollViewInitialHeight = Int(kDeviceHeight) - Int(fakeStatusBar.frame.size.height) - Int(navView.frame.size.height) - 90 - Int(SharedData.bottomSafeAreaHeight)
        
        containerScrollView.frame = CGRect(x: 0, y: Int(fakeStatusBar.frame.size.height) + Int(navView.frame.size.height), width: Int(kDeviceWidth), height: scrollViewInitialHeight)
        tabBarContainer.frame = CGRect(x: 0, y: Int(kDeviceHeight) - 90 - SharedData.bottomSafeAreaHeight, width: Int(kDeviceWidth), height: 90 + SharedData.bottomSafeAreaHeight)
        
        // Set the scrollView for no POG
        self.containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: self.statsContainerView.frame.origin.y + self.statsContainerView.frame.size.height + 16)
        
        // Hide the POG containers until the feed is finished
        regularPOGContainerView.isHidden = true
        footballPOGContainerView.isHidden = true
        
        gameDetailsTextView.layer.cornerRadius = 6
        gameDetailsTextView.layer.borderWidth = 0.5
        gameDetailsTextView.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        gameDetailsTextView.clipsToBounds = true
        
        saveButton.layer.cornerRadius = 8
        saveButton.clipsToBounds = true
        saveButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
        saveButton.isEnabled = false
        saveButton.frame = CGRect(x: deleteButton.frame.origin.x + deleteButton.frame.size.width + 20, y: saveButton.frame.origin.y, width: kDeviceWidth - deleteButton.frame.size.width - deleteButton.frame.origin.x - 40, height: saveButton.frame.size.height)
        
        deleteButton.setTitleColor(UIColor.mpGrayButtonBorderColor(), for: .normal)
        deleteButton.layer.cornerRadius = 8
        deleteButton.layer.borderWidth = 1
        deleteButton.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        deleteButton.clipsToBounds = true
        deleteButton.isEnabled = false
        
        // Add a shadow to the tabBarContainer
        let shadowPath = UIBezierPath(rect: tabBarContainer.bounds)
        tabBarContainer.layer.masksToBounds = false
        tabBarContainer.layer.shadowColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        tabBarContainer.layer.shadowOffset = CGSize(width: 0, height: -3)
        tabBarContainer.layer.shadowOpacity = 0.5
        tabBarContainer.layer.shadowPath = shadowPath.cgPath
        
        regularOverallImageView.layer.cornerRadius = regularOverallImageView.frame.size.width / 2
        regularOverallImageView.clipsToBounds = true
        footballOverallImageView.layer.cornerRadius = footballOverallImageView.frame.size.width / 2
        footballOverallImageView.clipsToBounds = true
        footballDefensiveImageView.layer.cornerRadius = footballDefensiveImageView.frame.size.width / 2
        footballDefensiveImageView.clipsToBounds = true
        footballOffensiveImageView.layer.cornerRadius = footballOffensiveImageView.frame.size.width / 2
        footballOffensiveImageView.clipsToBounds = true
        footballSpecialTeamsImageView.layer.cornerRadius = footballSpecialTeamsImageView.frame.size.width / 2
        footballSpecialTeamsImageView.clipsToBounds = true
        
        // Add the keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
        
        self.addKeyboardAccessoryView()
        
        self.getContest()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
         
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setNeedsStatusBarAppearanceUpdate()
        
        // Reload the contest if returning from the boxScoreVC
        if (boxScoreVC != nil)
        {
            self.boxScoreUpdated = true
            self.getContest()
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

        if (boxScoreVC != nil)
        {
            boxScoreVC = nil
        }
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
        tickTimer.invalidate()
        tickTimer = nil
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

}
