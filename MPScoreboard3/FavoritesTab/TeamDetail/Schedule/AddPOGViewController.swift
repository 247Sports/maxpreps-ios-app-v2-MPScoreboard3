//
//  AddPOGViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/11/21.
//

import UIKit

protocol AddPOGViewControllerDelegate: AnyObject
{
    func addPOGSaveButtonTouched()
    func addPOGCancelButtonTouched()
}

class AddPOGViewController: UIViewController, UITextFieldDelegate, IQActionSheetPickerViewDelegate, UITextViewDelegate, POGRosterViewControllerDelegate
{
    weak var delegate: AddPOGViewControllerDelegate?
    
    var selectedTeam : Team!
    var ssid : String?
    var contestId : String?
    var type : String?
    var comments : String?
    var pogId : String?
    var editMode = false
    var selectedAthlete: RosterAthlete!
    
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rosterTextField: UITextField!
    @IBOutlet weak var detailsContainerView: UIView!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet weak var detailsTextCountLabel: UILabel!

    @IBOutlet weak var tabBarContainer: UIView!
    @IBOutlet weak var saveButton: UIButton!

    private var teamColor = UIColor.mpRedColor()
    private var tickTimer: Timer!
    
    private var pogRosterVC: POGRosterViewController!
    private var progressOverlay: ProgressHUD!
    
    private let kTextViewDefaultText = "Add details here..."
    
    // MARK: - Add POG
    
    private func addPOG()
    {
        var comments = ""
        
        if (detailsTextView.text != kTextViewDefaultText)
        {
            comments = detailsTextView.text
        }
        
        // Call the add feed
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        ScheduleFeeds.addPlayerOfTheGame(schoolId: selectedTeam!.schoolId, ssid: self.ssid!, contestId: self.contestId!, athleteId: selectedAthlete.athleteId, type: self.type!, comments: comments) { player, error in
            
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
                print("Save POG Success")
                
                OverlayView.showPopupOverlay(withMessage: "Athlete Added")
                {
                    self.delegate?.addPOGSaveButtonTouched()
                }
            }
            else
            {
                print("Save POG Failed")
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "There was a problem saving the player.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
        
        fakeStatusBar.backgroundColor = .clear
    }
    
    // MARK: - Update POG
    
    private func updatePOG()
    {
        var comments = ""
        
        if (detailsTextView.text != kTextViewDefaultText)
        {
            comments = detailsTextView.text
        }
        
        // Call the update feed
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        ScheduleFeeds.updatePlayerOfTheGame(schoolId: selectedTeam!.schoolId, ssid: self.ssid!, pogId: self.pogId!, contestId: self.contestId!, athleteId: selectedAthlete.athleteId, type: self.type!, comments: comments) { player, error in
            
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
                print("Update POG Success")
                
                OverlayView.showPopupOverlay(withMessage: "Updated")
                {
                    self.delegate?.addPOGSaveButtonTouched()
                }
            }
            else
            {
                print("Update POG Failed")
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "There was a problem updating the player of the game.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
        
        fakeStatusBar.backgroundColor = .clear
    }
    
    // MARK: - POGRosterViewController Delegates
    
    func pogRosterAthleteSelected()
    {
        selectedAthlete = pogRosterVC.selectedAthelete
        
        rosterTextField.text = selectedAthlete.firstName + " " + selectedAthlete.lastName
        
        self.dismiss(animated: true)
        {
            self.pogRosterVC = nil
        }
    }
    
    func pogRosterCancelButtonTouched()
    {
        self.dismiss(animated: true)
        {
            self.pogRosterVC = nil
        }
    }
    
    // MARK: - TextField Delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if (pogRosterVC != nil)
        {
            pogRosterVC = nil
        }
        
        pogRosterVC = POGRosterViewController(nibName: "POGRosterViewController", bundle: nil)
        pogRosterVC.delegate = self
        pogRosterVC.selectedTeam = self.selectedTeam!
        pogRosterVC.ssid = self.ssid!
        pogRosterVC.modalPresentationStyle = .overCurrentContext
                    
        self.present(pogRosterVC, animated: true) {
            
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
            let badWords = IODProfanityFilter.rangesOfFilteredWords(in: detailsTextView.text)
            
            if (badWords!.count > 0)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Language", message: "The text that you have entered is objectionable and can not be used.", lastItemCancelType: false) { tag in

                    self.detailsTextView.text = self.kTextViewDefaultText
                    self.detailsTextView.textColor = UIColor.mpLightGrayColor()
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
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        // Update the gameDetailsTextCountLabel
        if (detailsTextView.text != kTextViewDefaultText)
        {
            detailsTextCountLabel.text = String(detailsTextView.text.count) + " / 50 Characters"
        }
        else
        {
            detailsTextCountLabel.text = "0 / 50 Characters"
        }
        
        if (rosterTextField.text!.count > 0)
        {
            saveButton.backgroundColor = teamColor
            saveButton.isEnabled = true
        }
        else
        {
            saveButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
            saveButton.isEnabled = false
        }
    }
    
    // MARK: - Load User Interface
    
    private func loadUserInterface()
    {
        if (selectedAthlete.athleteId.count > 0)
        {
            rosterTextField.text = self.selectedAthlete.firstName + " " + selectedAthlete.lastName
            
            if (self.comments!.count > 0)
            {
                detailsTextView.text = self.comments
                detailsTextView.textColor = UIColor.mpBlackColor()
            }
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func cancelButtonTouched(_ sender: UIButton)
    {
        fakeStatusBar.backgroundColor = .clear
        
        self.delegate?.addPOGCancelButtonTouched()
    }

    @IBAction func saveButtonTouched(_ sender: UIButton)
    {
        if (self.editMode == false)
        {
            self.addPOG()
        }
        else
        {
            self.updatePOG()
        }
    }
    
    @objc private func detailsDoneButtonTouched()
    {
        detailsTextView.resignFirstResponder()
    }
    
    // MARK: - Keyboard Notifications
    
    @objc private func keyboardDidShow(notification: Notification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            //print("Keyboard Height: " + String(Int(keyboardSize.size.height)))
            self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardSize.height + 80 + CGFloat(SharedData.bottomSafeAreaHeight))
            
            /*
            // Need to use the device coordinates for this calculation
            let gameDetailContainerViewBottom = Int(containerScrollView.frame.origin.y) + Int(gameDetailsContainerView.frame.origin.y) + Int(gameDetailsContainerView.frame.size.height)
            
            let keyboardTop = Int(kDeviceHeight) - Int(keyboardSize.size.height)
            
            if (keyboardTop < gameDetailContainerViewBottom)
            {
                let difference = gameDetailContainerViewBottom - keyboardTop
                containerScrollView.contentOffset = CGPoint(x: 0, y: difference)
            }
            */
        }
    }
    
    @objc private func keyboardDidHide(notification: Notification)
    {
        //print("Keyboard will hide")
        self.view.transform = .identity
    }
    
    // MARK: - Keyboard Accessory Views
    
    private func addKeyboardAccessoryView()
    {
        let detailsAccessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        detailsAccessoryView.backgroundColor = UIColor.mpRedColor()
        
        let detailsDoneButton = UIButton(type: .custom)
        detailsDoneButton.frame = CGRect(x: kDeviceWidth - 85, y: 5, width: 80, height: 30)
        detailsDoneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        detailsDoneButton.setTitle("Done", for: .normal)
        detailsDoneButton.setTitleColor(UIColor.mpWhiteColor(), for: .normal)
        detailsDoneButton.addTarget(self, action: #selector(detailsDoneButtonTouched), for: .touchUpInside)
        detailsAccessoryView.addSubview(detailsDoneButton)
        detailsTextView!.inputAccessoryView = detailsAccessoryView
    
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        fakeStatusBar.backgroundColor = .clear
        
        let hexColorString = self.selectedTeam?.teamColor
        teamColor = ColorHelper.color(fromHexString: hexColorString, colorCorrection: true)!
 
        // Size and locate the fakeStatusBar, navBar, containerView, and tabBarContainer
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: Int(kDeviceHeight))
        navView.frame = CGRect(x: 0, y: kDeviceHeight - CGFloat(SharedData.bottomSafeAreaHeight) - 80 - 276, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        containerView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: CGFloat(kDeviceWidth), height: CGFloat(kDeviceHeight) - navView.frame.origin.y - navView.frame.size.height - 80 - CGFloat(SharedData.bottomSafeAreaHeight))
        
        tabBarContainer.frame = CGRect(x: 0, y: Int(kDeviceHeight) - 80 - SharedData.bottomSafeAreaHeight, width: Int(kDeviceWidth), height: 80 + SharedData.bottomSafeAreaHeight)
        
        navView.layer.cornerRadius = 12
        navView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        navView.clipsToBounds = true
        
        saveButton.layer.cornerRadius = 8
        saveButton.clipsToBounds = true
        saveButton.backgroundColor = UIColor.mpLightGrayColor()
        
        if (self.editMode == true)
        {
            saveButton.setTitle("UPDATE", for: .normal)
        }
        
        detailsTextView.layer.cornerRadius = 6
        detailsTextView.layer.borderWidth = 0.5
        detailsTextView.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        detailsTextView.clipsToBounds = true
        
        // Add a shadow to the tabBarContainer
        let shadowPath = UIBezierPath(rect: tabBarContainer.bounds)
        tabBarContainer.layer.masksToBounds = false
        tabBarContainer.layer.shadowColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        tabBarContainer.layer.shadowOffset = CGSize(width: 0, height: -3)
        tabBarContainer.layer.shadowOpacity = 0.5
        tabBarContainer.layer.shadowPath = shadowPath.cgPath
        
        self.addKeyboardAccessoryView()
        
        switch self.type
        {
        case "Overall":
            titleLabel.text = "Overall Player of the Game"
        case "Defensive":
            titleLabel.text = "Defensive Player of the Game"
        case "Offensive":
            titleLabel.text = "Offensive Player of the Game"
        case "Special Teams":
            titleLabel.text = "Special Teams Player of the Game"
        default:
            titleLabel.text = "Player of the Game"
        }
        
        // Add the keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
        
        self.loadUserInterface()
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
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
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
