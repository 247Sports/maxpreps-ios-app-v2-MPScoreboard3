//
//  JoinTeamStatisticianMessageViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/6/22.
//

import UIKit

class JoinTeamStatisticianMessageViewController: UIViewController, UITextViewDelegate
{
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageTextCountLabel: UILabel!
    @IBOutlet weak var sendRequestButton: UIButton!
    
    var selectedTeam : Team?
    var selectedStaffMember : RosterStaff?
    var existingCoachMode = false
    var requestSent = false
    
    let kDefaultMessageText = "e.g. I am Taylor's mom and am willing to help enter stats this season."
    private var tickTimer: Timer!
    private var trackingGuid = ""
    
    private var successVC: JoinTeamStatisticianSuccessViewController!
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Request Volunteer Access Feed
    
    private func requestVolunteerAccess()
    {
        // Show the busy indicator
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        var coachUserId = ""
        var coachEmail = ""
        var coachFirstName = ""
        var coachLastName = ""
        var message = ""
        
        if (existingCoachMode == false)
        {
            coachFirstName = selectedStaffMember!.userFirstName
            coachLastName = selectedStaffMember!.userLastName
            coachEmail = selectedStaffMember!.userEmail
            coachUserId = kEmptyGuid // Important for the API to work
        }
        else
        {
            // Names and email are not needed if the coach is known
            coachUserId = selectedStaffMember!.userId
        }
        
        if (messageTextView.text == kDefaultMessageText)
        {
            message = ""
        }
        else
        {
            message = messageTextView.text
        }
        
        NewFeeds.requestVolunteerAccess(schoolId: selectedTeam!.schoolId, allSeasonId: selectedTeam!.allSeasonId, season: selectedTeam!.season, message: message, coachUserId: coachUserId, coachFirstName: coachFirstName, coachLastName: coachLastName, coachEmail: coachEmail, coachPhone: "") { result, error in
  
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
                print("Request Volunteer Access Success")
                
                /*
                 ▿ 0 : 2 elements
                   - key : "status"
                   - value : 1
                 */
                
                /*
                 Unknown = 0,
                 Success = 1,
                 Failed = 2
                 */
                let status = result!["status"] as! Int
                
                if (status == 1)
                {
                    self.showSuccessViewController()
                    
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

                    TrackingManager.trackState(featureName: "statistician-request-sent", trackingGuid: self.trackingGuid, cData: cData)
                }
                else
                {
                    OverlayView.showPopdownOverlay(withMessage: "Something went wrong when requesting volunteer access.", title: "Oops!", overlayColor: UIColor.mpWhiteColor()) {
                    }
                }
            }
            else
            {
                print("Request Coach Access Failed")
                
                OverlayView.showPopdownOverlay(withMessage: "Something went wrong when requesting volunteer access.", title: "Oops!", overlayColor: UIColor.mpWhiteColor()) {
                    
                }
            }
        }
    }
    
    // MARK: - Show Success View Controller
    
    private func showSuccessViewController()
    {
        if (successVC != nil)
        {
            successVC = nil
        }
        
        successVC = JoinTeamStatisticianSuccessViewController(nibName: "JoinTeamStatisticianSuccessViewController", bundle: nil)
        self.navigationController?.pushViewController(successVC, animated: true)
    }
    
    // MARK: - TextView Delegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == kDefaultMessageText)
        {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        let badWords = IODProfanityFilter.rangesOfFilteredWords(in: messageTextView.text)
        
        if (badWords!.count > 0)
        {
            OverlayView.showPopdownOverlay(withMessage: "Offensive Language.", title: "Oops!", overlayColor: UIColor.mpWhiteColor()) {
                
            }
            return
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if let paste = UIPasteboard.general.string, text == paste
        {
            // Pasteboard
            if ((textView.text.count + text.count) > 500)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Excess Length", message: "The text that you are pasting will exceed the 500 character limit.", lastItemCancelType: false) { tag in
                    
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
            
            if (range.location > 499)
            {
                return false
            }
            return true
        }
    }
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        // Update the messageTextCountLabel
        messageTextCountLabel.text = String(messageTextView.text!.count) + " / 500 Characters"
        
        /*
        if (messageTextView.text != kDefaultMessageText)
        {
            messageTextCountLabel.text = String(messageTextView.text!.count) + " / 500 Characters"
        }
        else
        {
            messageTextCountLabel.text = "0 / 500 Characters"
        }
        */
    }
    
    // MARK: - Show Error Message
    
    private func showErrorMessage(_ message:String)
    {
        OverlayView.showPopdownOverlay(withMessage: message, title: "Oops!", overlayColor: UIColor.mpWhiteColor()) {
            
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func keyboardDoneButtonTouched()
    {
        messageTextView.resignFirstResponder()
    }
    
    @IBAction func sendRequestButtonTouched()
    {
        // Check for emojis and bad words
        if (messageTextView.text!.containsEmoji == true)
        {
            self.showErrorMessage("Special characters are not allowed.")
            return
        }
        
        // Check for bad words
        let badText = IODProfanityFilter.rangesOfFilteredWords(in: messageTextView.text!)
        
        if (badText!.count > 0)
        {
            self.showErrorMessage("Offensive language.")
            return
        }
        
        self.requestVolunteerAccess()
    }
    
    // MARK: - Keyboard Accessory Views
    
    private func addKeyboardAccessoryView()
    {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        accessoryView.backgroundColor = UIColor(red: 192.0/255.0, green: 4.0/255.0, blue: 0, alpha: 1)
        
        let keyboardDoneButton = UIButton(type: .custom)
        keyboardDoneButton.frame = CGRect(x: kDeviceWidth - 85, y: 5, width: 80, height: 30)
        keyboardDoneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        keyboardDoneButton.setTitle("Done", for: .normal)
        keyboardDoneButton.setTitleColor(UIColor.mpWhiteColor(), for: .normal)
        keyboardDoneButton.addTarget(self, action: #selector(keyboardDoneButtonTouched), for: .touchUpInside)
        accessoryView.addSubview(keyboardDoneButton)
        messageTextView!.inputAccessoryView = accessoryView
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        trackingGuid = NSUUID().uuidString

        navView.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight + 44)
        containerView.frame = CGRect(x: 0, y: navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight))
        
        messageTextView.layer.cornerRadius = 8
        messageTextView.clipsToBounds = true
        
        sendRequestButton.layer.cornerRadius = sendRequestButton.frame.size.height / 2.0
        sendRequestButton.clipsToBounds = true
        
        messageTextView.text = kDefaultMessageText
        
        self.addKeyboardAccessoryView()
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
        
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

        TrackingManager.trackState(featureName: "message-coach", trackingGuid: trackingGuid, cData: cData)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
        
        if (successVC != nil)
        {
            self.requestSent = successVC.requestSent
            if (successVC.requestSent == true)
            {
                self.navigationController?.popViewController(animated: false)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if (successVC != nil)
        {
            successVC = nil
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
        tickTimer.invalidate()
        tickTimer = nil
    }
}
