//
//  AddGameViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 9/22/21.
//

import UIKit

protocol AddGameViewControllerDelegate: AnyObject
{
    func addGameSaveButtonTouched()
    func addGameCancelButtonTouched()
}

class AddGameViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, IQActionSheetPickerViewDelegate, CustomDatePickerViewDelegate, SearchOpponentViewControllerDelegate, ScheduleCalendarViewControllerDelegate
{
    weak var delegate: AddGameViewControllerDelegate?
    
    var selectedTeam : Team?
    var availableDates: Array<Date>!
    var ssid : String?
    var gameAdded = false
    var gameTypes: Array<String>!
    
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
    
    @IBOutlet weak var tabBarContainer: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var addAnotherButton: UIButton!
    
    private var customDatePickerView: CustomDatePickerView!
    private var searchOpponentVC: SearchOpponentViewController!
    private var calendarVC: ScheduleCalendarViewController!
    
    private var tickTimer: Timer!
    private var positions = [""]
    private var scrollViewInitialHeight = 0
    private var currentSport = ""
    private var currentGender = ""
    private var teamColor = UIColor.mpRedColor()
    
    private var selectedSchool = School(fullName: "", name: "", schoolId: "", address: "", state: "", city: "", zip: "", searchDistance: 0.0, latitude: "", longitude: "")
    private var selectedDate = Date()
    private var selectedTime = Date()
    private var selectedGameType = -1
    
    private let kTextViewDefaultText = "Add additional details here..."
    private let kHomeAwayTypes = ["Home","Away","Neutral"]
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Save Contest
    
    private func saveContest(single: Bool)
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
        
        // Call the feed
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        ScheduleFeeds.addSecureContest(myTeamSchoolId: selectedTeam!.schoolId, opponentSchoolId: selectedSchool.schoolId, opponentTBA: opponentTBA, ssid: self.ssid!, dateString: selectedDateString, dateCode: dateCode, myTeamHomeAway: myTeamHomeAway, opponentHomeAway: opponentHomeAway, contestType: self.selectedGameType, location: gameDetails) { result, message, error in
            
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
                print("Add Contest Success")
                
                var title = "Game Added"
                
                if (MiscHelper.sportUsesMatchInsteadOfGame(sport: self.selectedTeam!.sport) == true)
                {
                    title = "Match Added"
                }
                
                OverlayView.showPopupOverlay(withMessage: title)
                {
                    self.gameAdded = true
                    
                    if (single == true)
                    {
                        self.delegate?.addGameSaveButtonTouched()
                    }
                    else
                    {
                        self.clearInputFields()
                    }
                }
            }
            else
            {
                print("Add Contest Failed")
                
                //var message = "Something went wrong when trying to add this game."
                
                //if (MiscHelper.sportUsesMatchInsteadOfGame(sport: self.selectedTeam!.sport) == true)
                //{
                    //message = "Something went wrong when trying to add this match."
                //}
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: message, lastItemCancelType: false) { tag in
                    
                }
            }
        } 
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
    
    // MARK: - TextField Delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if (textField == dateTextField)
        {
            calendarVC = ScheduleCalendarViewController(nibName: "ScheduleCalendarViewController", bundle: nil)
            calendarVC.delegate = self
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
            searchOpponentVC.schoolId = selectedTeam!.schoolId
            searchOpponentVC.teamLevel = selectedTeam!.teamLevel
            searchOpponentVC.ssid = self.ssid
            searchOpponentVC.modalPresentationStyle = .overCurrentContext
            self.present(searchOpponentVC, animated: true) {
                
            }
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
    
    // MARK: - Clear Input Fields
    
    private func clearInputFields()
    {
        dateTextField.text = ""
        timeTextField.text = ""
        homeAwayTextField.text = ""
        gameTypeTextField.text = ""
        opponentTextField.text = ""
        gameDetailsTextView.text = kTextViewDefaultText
        gameDetailsTextView.textColor = UIColor.mpLightGrayColor()
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
            
            addAnotherButton.layer.borderColor = teamColor.cgColor
            addAnotherButton.setTitleColor(teamColor, for: .normal)
            addAnotherButton.isEnabled = true
        }
        else
        {
            saveButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
            saveButton.isEnabled = false
            
            addAnotherButton.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
            addAnotherButton.setTitleColor(UIColor.mpGrayButtonBorderColor(), for: .normal)
            addAnotherButton.isEnabled = false
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func cancelButtonTouched(_ sender: UIButton)
    {
        self.delegate?.addGameCancelButtonTouched()
    }
    
    @objc private func gameDetailsDoneButtonTouched()
    {
        gameDetailsTextView.resignFirstResponder()
    }
    
    @IBAction func saveButtonTouched(_ sender: UIButton)
    {
        self.saveContest(single: true)
    }
    
    @IBAction func addAnotherButtonTouched(_ sender: UIButton)
    {
        self.saveContest(single: false)
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

        currentSport = selectedTeam!.sport
        currentGender = selectedTeam!.gender
        
        if (MiscHelper.sportUsesMatchInsteadOfGame(sport: currentSport) == true)
        {
            navTitleLabel.text = "Add Match"
            gameDetailsHeaderLabel.text = "Match Details (optional)"
        }
        
        fakeStatusBar.backgroundColor = .clear
        
        let hexColorString = self.selectedTeam?.teamColor
        teamColor = ColorHelper.color(fromHexString: hexColorString, colorCorrection: true)!
 
        // Size and locate the fakeStatusBar, navBar, containerScrollView, and tabBarContainer
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 76 + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        
        scrollViewInitialHeight = Int(kDeviceHeight) - Int(fakeStatusBar.frame.size.height) - Int(navView.frame.size.height) + 12 - 90 - Int(SharedData.bottomSafeAreaHeight)
        
        containerScrollView.frame = CGRect(x: 0, y: Int(fakeStatusBar.frame.size.height) + Int(navView.frame.size.height) - 12, width: Int(kDeviceWidth), height: scrollViewInitialHeight)
        tabBarContainer.frame = CGRect(x: 0, y: Int(kDeviceHeight) - 90 - SharedData.bottomSafeAreaHeight, width: Int(kDeviceWidth), height: 90 + SharedData.bottomSafeAreaHeight)
        
        containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: gameDetailsContainerView.frame.origin.y + gameDetailsContainerView.frame.size.height)
        
        navView.layer.cornerRadius = 12
        navView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        navView.clipsToBounds = true
        
        gameDetailsTextView.layer.cornerRadius = 6
        gameDetailsTextView.layer.borderWidth = 0.5
        gameDetailsTextView.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        gameDetailsTextView.clipsToBounds = true
        
        saveButton.layer.cornerRadius = 8
        saveButton.clipsToBounds = true
        saveButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
        saveButton.isEnabled = false
        
        addAnotherButton.setTitleColor(UIColor.mpGrayButtonBorderColor(), for: .normal)
        addAnotherButton.layer.cornerRadius = 8
        addAnotherButton.layer.borderWidth = 1
        addAnotherButton.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        addAnotherButton.clipsToBounds = true
        addAnotherButton.isEnabled = false
        
        // Add a shadow to the tabBarContainer
        let shadowPath = UIBezierPath(rect: tabBarContainer.bounds)
        tabBarContainer.layer.masksToBounds = false
        tabBarContainer.layer.shadowColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        tabBarContainer.layer.shadowOffset = CGSize(width: 0, height: -3)
        tabBarContainer.layer.shadowOpacity = 0.5
        tabBarContainer.layer.shadowPath = shadowPath.cgPath
        
        // Add the keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
        
        self.addKeyboardAccessoryView()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
                
        setNeedsStatusBarAppearanceUpdate()
        
        // Add some delay so the view is partially showing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
        {
            UIView.animate(withDuration: 0.3)
            { [self] in
                fakeStatusBar.backgroundColor = UIColor(white: 0, alpha: 0.6)
            }
        }
        
        /*
        if (searchOpponentVC != nil)
        {
            opponentTextField.text = searchOpponentVC.selectedSchool.name
        }
        */
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

        /*
        if (searchOpponentVC != nil)
        {
            searchOpponentVC = nil
        }
        */
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
        tickTimer.invalidate()
        tickTimer = nil
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

}
