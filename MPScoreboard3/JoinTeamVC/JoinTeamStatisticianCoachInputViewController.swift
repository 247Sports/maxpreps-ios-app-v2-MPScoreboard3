//
//  JoinTeamStatisticianCoachInputViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/4/22.
//

import UIKit

class JoinTeamStatisticianCoachInputViewController: UIViewController, UITextFieldDelegate, IQActionSheetPickerViewDelegate
{
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var selectCoachBackgroundView: UIView!
    @IBOutlet weak var selectCoachLabel: UILabel!
    @IBOutlet weak var nextButton1: UIButton!
    
    @IBOutlet weak var coachContactContainerView: UIView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var firstNameBackgroundView: UIView!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var lastNameBackgroundView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailBackgroundView: UIView!
    @IBOutlet weak var nextButton2: UIButton!
    
    var selectedTeam : Team?
    var requestSent = false
    
    private var staffRoster: Array<RosterStaff> = []
    private var staffNames: Array<String> = []
    private var existingCoachMode = false
    private var selectedStaffIndex = -1
    private var tickTimer: Timer!
    private var trackingGuid = ""
    
    private var messageVC: JoinTeamStatisticianMessageViewController!
    private var progressOverlay: ProgressHUD!
    
    private var kDefaultSelectTitle = "Select Coach"
    private var kDefaultAddCoachTitle = "Add New Coach"
    private var kDefaultFirstName = "First Name*"
    private var kDefaultLastName = "Last Name*"
    private var kDefaultEmail = "Email*"
    
    // MARK: - Get Staff Roster Method
    
    private func getStaffRoster()
    {
        // Show the busy indicator
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        RosterFeeds.getPublicStaffRoster(teamId: selectedTeam!.schoolId, allSeasonId: selectedTeam!.allSeasonId, season: selectedTeam!.season) { staff, error in
            
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
                print("Get Public Staff Roster Success")
                
                self.staffRoster = staff!
                self.staffNames.removeAll()
                
                for staffMember in staff!
                {
                    let name = String(format: "%@ %@", staffMember.userFirstName, staffMember.userLastName)
                    self.staffNames.append(name)
                }
                
                self.staffNames.append(self.kDefaultAddCoachTitle)
            }
            else
            {
                print("Get Public Staff Roster Failed")
                
                self.showErrorMessage("Something went wrong when requesting volunteer access.")
            }
        }
    }
    
    // MARK: - Show Optional Message View Controller
    
    private func showOptionalMessageViewController()
    {
        messageVC = JoinTeamStatisticianMessageViewController(nibName: "JoinTeamStatisticianMessageViewController", bundle: nil)
        messageVC.selectedTeam = self.selectedTeam
        messageVC.existingCoachMode = existingCoachMode
        
        if (existingCoachMode == true)
        {
            let selectedStaff = self.staffRoster[selectedStaffIndex]
            messageVC.selectedStaffMember = selectedStaff
        }
        else
        {
            let staffObj = RosterStaff(contactId: "", userId: "", roleId: "", userFirstName: firstNameTextField.text!, userLastName: lastNameTextField.text!, userEmail: emailTextField.text!, position: "", roleName: "", photoUrl: "")
            
            messageVC.selectedStaffMember = staffObj
        }
        
        self.navigationController?.pushViewController(messageVC, animated: true)
    }
    
    // MARK: - TextField Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if (textField == firstNameTextField)
        {
            lastNameTextField.becomeFirstResponder()
            return true
        }
        else if (textField == lastNameTextField)
        {
            emailTextField.becomeFirstResponder()
            return true
        }
        else
        {
            // Validate each textField for emoji and bad words
            if ((firstNameTextField.text!.containsEmoji == true) || (lastNameTextField.text!.containsEmoji == true) || (emailTextField.text!.containsEmoji == true))
            {
                self.showErrorMessage("Special characters are not allowed.")
                return true
            }
            
            // Check for bad words
            let badFirstNames = IODProfanityFilter.rangesOfFilteredWords(in: firstNameTextField.text!)
            let badLastNames = IODProfanityFilter.rangesOfFilteredWords(in: lastNameTextField.text!)
            let badEmail = IODProfanityFilter.rangesOfFilteredWords(in: emailTextField.text!)
            
            if ((badFirstNames!.count > 0) || (badLastNames!.count > 0) || (badEmail!.count > 0))
            {
                self.showErrorMessage("Offensive language.")
                return true
            }
            
            if (MiscHelper.isValidEmailAddress(emailTextField.text!) == false)
            {
                self.showErrorMessage("Please enter a valid email.")
                return true
            }
            
            emailTextField.resignFirstResponder()
            
            self.showOptionalMessageViewController()
            
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if (textField == firstNameTextField)
        {
            if (textField.text == kDefaultFirstName)
            {
                firstNameTextField.text = ""
            }
        }
        else if (textField == lastNameTextField)
        {
            if (textField.text == kDefaultLastName)
            {
                lastNameTextField.text = ""
            }
        }
        else
        {
            if (textField.text == kDefaultEmail)
            {
                emailTextField.text = ""
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if (textField == firstNameTextField)
        {
            if (textField.text == "")
            {
                firstNameTextField.text = kDefaultFirstName
            }
        }
        else if (textField == lastNameTextField)
        {
            if (textField.text == "")
            {
                lastNameTextField.text = kDefaultLastName
            }
        }
        else
        {
            if (textField.text == "")
            {
                emailTextField.text = kDefaultEmail
            }
        }
    }
    
    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelectTitles titles: [String])
    {
        selectCoachLabel.text = titles.first
        
        if (titles.first == kDefaultAddCoachTitle)
        {
            existingCoachMode = false
            coachContactContainerView.isHidden = false
        }
        else
        {
            existingCoachMode = true
            coachContactContainerView.isHidden = true
            
            // Get the selected coach index
            selectedStaffIndex = self.staffNames.firstIndex(of: titles.first!)!
        }
        
        // Build the tracking context data object
        var cData = kEmptyTrackingContextData
        
        let schoolId = self.selectedTeam?.schoolId
        let schoolName = self.selectedTeam?.schoolName
        let schoolState = self.selectedTeam?.schoolState
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

        TrackingManager.trackState(featureName: "select-coach", trackingGuid: trackingGuid, cData: cData)
    }
    
    func actionSheetPickerViewDidCancel(_ pickerView: IQActionSheetPickerView)
    {
        
    }
    
    // MARK: - Show Error Message
    
    private func showErrorMessage(_ message:String)
    {
        OverlayView.showPopdownOverlay(withMessage: message, title: "Oops!", overlayColor: UIColor.mpWhiteColor()) {
            
        }
    }
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        if (existingCoachMode == false)
        {
            if ((firstNameTextField.text!.count > 0) && (lastNameTextField.text!.count > 0) && (emailTextField.text!.count > 0) && (firstNameTextField.text! != kDefaultFirstName) && (lastNameTextField.text! != kDefaultLastName) && (emailTextField.text! != kDefaultEmail))
            {
                nextButton1.alpha = 1.0
                nextButton1.isEnabled = true
                nextButton2.alpha = 1.0
                nextButton2.isEnabled = true
            }
            else
            {
                nextButton1.alpha = 0.5
                nextButton1.isEnabled = false
                nextButton2.alpha = 0.5
                nextButton2.isEnabled = false
            }
        }
        else
        {
            if (selectCoachLabel.text != kDefaultSelectTitle)
            {
                nextButton1.alpha = 1.0
                nextButton1.isEnabled = true
                nextButton2.alpha = 1.0
                nextButton2.isEnabled = true
            }
            else
            {
                nextButton1.alpha = 0.5
                nextButton1.isEnabled = false
                nextButton2.alpha = 0.5
                nextButton2.isEnabled = false
            }
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectCoachButtonTouched(_ sender: UIButton)
    {
        let picker = IQActionSheetPickerView(title: "Select Coach", delegate: self)
        picker.toolbarButtonColor = UIColor.mpWhiteColor()
        picker.toolbarTintColor = UIColor.mpPickerToolbarColor()
        picker.titlesForComponents = [staffNames]
        picker.tag = 1
        picker.show()
    }
    
    @IBAction func nextButtonTouched(_ sender: UIButton)
    {
        if (existingCoachMode == false)
        {
            // Validate each textField for emoji and bad words
            if ((firstNameTextField.text!.containsEmoji == true) || (lastNameTextField.text!.containsEmoji == true) || (emailTextField.text!.containsEmoji == true))
            {
                self.showErrorMessage("Special characters are not allowed.")
                return
            }
            
            // Check for bad words
            let badFirstNames = IODProfanityFilter.rangesOfFilteredWords(in: firstNameTextField.text!)
            let badLastNames = IODProfanityFilter.rangesOfFilteredWords(in: lastNameTextField.text!)
            let badEmail = IODProfanityFilter.rangesOfFilteredWords(in: emailTextField.text!)
            
            if ((badFirstNames!.count > 0) || (badLastNames!.count > 0) || (badEmail!.count > 0))
            {
                self.showErrorMessage("Offensive language.")
                return
            }
            
            if (MiscHelper.isValidEmailAddress(emailTextField.text!) == false)
            {
                self.showErrorMessage("Please enter a valid email.")
                return
            }
            
            self.view.endEditing(true)
            
            self.showOptionalMessageViewController()
        }
        else
        {
            self.showOptionalMessageViewController()
        }
    }
    
    // MARK: - Keyboard Notifications
    
    @objc private func keyboardDidShow(notification: Notification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            if (existingCoachMode == false)
            {
                print("Keyboard Height: " + String(Int(keyboardSize.size.height)))
                
                // Need to use the device coordinates for this calculation
                let joinButtonBottom = Int(containerScrollView.frame.origin.y) + Int(coachContactContainerView.frame.origin.y) + Int(nextButton2.frame.origin.y) + Int(nextButton2.frame.size.height)
                
                let keyboardTop = Int(kDeviceHeight) - Int(keyboardSize.size.height)
                
                if (keyboardTop < joinButtonBottom)
                {
                    let difference = joinButtonBottom - keyboardTop
                    containerScrollView.contentOffset = CGPoint(x: 0, y: difference + 20)
                }
            }
        }
    }
    
    @objc private func keyboardDidHide(notification: Notification)
    {
        //print("Keyboard will hide")
        containerScrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        trackingGuid = NSUUID().uuidString

        navView.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight + 44)
        containerScrollView.frame = CGRect(x: 0, y: navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight))
        
        selectCoachBackgroundView.layer.cornerRadius = 8
        selectCoachBackgroundView.clipsToBounds = true
        firstNameBackgroundView.layer.cornerRadius = 8
        firstNameBackgroundView.clipsToBounds = true
        lastNameBackgroundView.layer.cornerRadius = 8
        lastNameBackgroundView.clipsToBounds = true
        emailBackgroundView.layer.cornerRadius = 8
        emailBackgroundView.clipsToBounds = true
        nextButton1.layer.cornerRadius = nextButton1.frame.size.height / 2.0
        nextButton1.clipsToBounds = true
        nextButton2.layer.cornerRadius = nextButton2.frame.size.height / 2.0
        nextButton2.clipsToBounds = true
        
        coachContactContainerView.isHidden = true
        nextButton1.isEnabled = false
        nextButton2.isEnabled = false
        nextButton1.alpha = 0.5
        nextButton2.alpha = 0.5
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
        
        // Add the keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.getStaffRoster()
        
        // Build the tracking context data object
        var cData = kEmptyTrackingContextData
        
        let schoolId = self.selectedTeam?.schoolId
        let schoolName = self.selectedTeam?.schoolName
        let schoolState = self.selectedTeam?.schoolState
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

        TrackingManager.trackState(featureName: "access-statistician", trackingGuid: trackingGuid, cData: cData)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
        
        if (messageVC != nil)
        {
            self.requestSent = messageVC.requestSent
            if (messageVC.requestSent == true)
            {
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if (messageVC != nil)
        {
            messageVC = nil
        }
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
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
