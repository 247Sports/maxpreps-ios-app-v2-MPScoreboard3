//
//  EditPlayerInfoViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/12/23.
//

import UIKit

protocol EditPlayerInfoViewControllerDelegate: AnyObject
{
    func editPlayerInfoViewControllerDidCancel()
    func editPlayerInfoViewControllerDidSave()
}

class EditPlayerInfoViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, IQActionSheetPickerViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var athleteDetailsTextView: UITextView!
    @IBOutlet weak var athleteDetailsTextCountLabel: UILabel!
    @IBOutlet weak var twitterTextField: UITextField!
    @IBOutlet weak var instagramTextField: UITextField!
    @IBOutlet weak var snapchatTextField: UITextField!
    @IBOutlet weak var tiktokTextField: UITextField!
    @IBOutlet weak var facebookTextField: UITextField!
    @IBOutlet weak var gameChangerTextField: UITextField!
    @IBOutlet weak var hudlTextField: UITextField!
    @IBOutlet weak var classYearTextField: UITextField!
    @IBOutlet weak var twitterContainerView: UIView!
    @IBOutlet weak var instagramContainerView: UIView!
    @IBOutlet weak var snapchatContainerView: UIView!
    @IBOutlet weak var tiktokContainerView: UIView!
    @IBOutlet weak var facebookContainerView: UIView!
    @IBOutlet weak var gameChangerContainerView: UIView!
    @IBOutlet weak var hudlContainerView: UIView!
    
    weak var delegate: EditPlayerInfoViewControllerDelegate?
    
    var playerInfoDictionary: Dictionary<String,Any> = [:]
    var firstName = ""
    var lastName = ""
    var careerId = ""
    var graduatingClass = 0
    
    private var kContainerHeight = 1036.0
    private var tickTimer: Timer!
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Save Data
    
    private func saveData()
    {
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        var bioText = ""
        
        if (athleteDetailsTextView.text! != kCareerProfileBioTextViewDefaultText)
        {
            bioText = athleteDetailsTextView.text!
        }

        CareerFeeds.updateAthletePlayerInfo(careerId: self.careerId, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, bio: bioText, twitter: twitterTextField.text!, instagram: instagramTextField.text!, snapchat: snapchatTextField.text!, tikTok: tiktokTextField.text!, facebook: facebookTextField.text!, gameChanger: gameChangerTextField.text!, hudl: hudlTextField.text!, classYear: classYearTextField.text!) { result, error in
            
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                if (self.progressOverlay != nil)
                {
                    self.progressOverlay.hide(animated: false)
                    self.progressOverlay = nil
                }
            }
            
            if (error == nil)
            {
                print("Update Athlete User Profile Success")
                
                OverlayView.showTwoLinePopupOverlay(withMessage: "Success! Your changes may take up to 30 minutes to be reflected on the account.", boldText: "Success!", withDismissHandler: {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                    {
                        self.delegate?.editPlayerInfoViewControllerDidSave()
                    }
                })
            }
            else
            {
                print("Update Athlete User Profile Failed")
                
                let errorMessage = error?.localizedDescription
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: errorMessage, lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - Load Data
    
    private func loadData()
    {
         let bio = playerInfoDictionary["bio"] as? String ?? ""
        
        if (bio == "")
        {
            athleteDetailsTextView.text = kCareerProfileBioTextViewDefaultText
            athleteDetailsTextView.textColor = UIColor.mpLightGrayColor()
        }
        else
        {
            athleteDetailsTextView.text = bio
            athleteDetailsTextView.textColor = UIColor.mpBlackColor()
        }
        
        firstNameTextField.text = self.firstName
        lastNameTextField.text = self.lastName
        
        // A -1 value means the prperty was null in the feed
        if (self.graduatingClass != -1)
        {
            classYearTextField.text = String(graduatingClass)
        }
        
        twitterTextField.text = playerInfoDictionary["twitterHandle"] as? String ?? ""
        instagramTextField.text = playerInfoDictionary["instagram"] as? String ?? ""
        snapchatTextField.text = playerInfoDictionary["snapchat"] as? String ?? ""
        tiktokTextField.text = playerInfoDictionary["tikTok"] as? String ?? ""
        facebookTextField.text = playerInfoDictionary["facebookProfile"] as? String ?? ""
        hudlTextField.text = playerInfoDictionary["hudl"] as? String ?? ""
        gameChangerTextField.text = playerInfoDictionary["gameChanger"] as? String ?? ""
    }
    
    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelectTitles titles: [String])
    {
        classYearTextField.text = titles.first
    }
    
    func actionSheetPickerViewDidCancel(_ pickerView: IQActionSheetPickerView)
    {
        
    }
    
    // MARK: - TextView Delegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        textView.textColor = UIColor.mpBlackColor()
        
        if (textView.text == kCareerProfileBioTextViewDefaultText)
        {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == "")
        {
            textView.text = kCareerProfileBioTextViewDefaultText
            textView.textColor = UIColor.mpLightGrayColor()
        }
        else
        {
            let badWords = IODProfanityFilter.rangesOfFilteredWords(in: athleteDetailsTextView.text)
            
            if (badWords!.count > 0)
            {
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "Language", message: "The text that you have entered is objectionable and can not be used.", lastItemCancelType: false) { tag in

                    self.athleteDetailsTextView.text = kCareerProfileBioTextViewDefaultText
                    self.athleteDetailsTextView.textColor = UIColor.mpLightGrayColor()
                }
                return
            }
            else
            {
                if (athleteDetailsTextView.text.containsEmoji == true)
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "You can't use special characters in this field.", lastItemCancelType: false) { tag in
                        
                    }
                    return
                }
            }
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
    
    // MARK: - TextField Delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if (textField == classYearTextField)
        {
            var yearsArray: Array<String> = []
            
            // Get the current year
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            let currentYearString = dateFormatter.string(from: Date())
            let currentYear = Int(currentYearString)!
            
            for year in 2004...currentYear + 8
            {
                yearsArray.append(String(year))
            }
            
            let reversedYearsArray = Array(yearsArray.reversed())
            
            let picker = IQActionSheetPickerView(title: "Select Year", delegate: self)
            picker.toolbarButtonColor = UIColor.mpDarkGrayColor()
            picker.toolbarTintColor = UIColor.mpGrayButtonBorderColor()
            picker.titlesForComponents = [reversedYearsArray]
            picker.tag = 1
            
            // Preload the starting index if possible
            if (classYearTextField.text! != "")
            {
                if let startingIndex = reversedYearsArray.firstIndex(of: classYearTextField.text!)
                {
                    picker.selectIndexes([NSNumber(integerLiteral: startingIndex)], animated: false)
                }
            }
            
            picker.show()
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        let badWords = IODProfanityFilter.rangesOfFilteredWords(in: textField.text)
        
        if (badWords!.count > 0)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Language", message: "The text that you have entered is objectionable and can not be used.", lastItemCancelType: false) { tag in

                textField.text = ""
            }
            return
        }
        else
        {
            if (textField.text!.containsEmoji == true)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "You can't use special characters in this field.", lastItemCancelType: false) { tag in
                    
                    textField.text = ""
                }
                return
            }
        }
        
        // Check the facebook textField
        if (textField == facebookTextField)
        {
            if (textField.text!.count > 0)
            {
                if ((((textField.text!.contains("facebook.com") == false) && (textField.text!.contains("fb.com") == false))) || (textField.text!.isValidUrl == false))
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Bad URL", message: "The facebook URL is not valid. Make sure the URL begins with \"https://\"", lastItemCancelType: false) { tag in
                        
                    }
                    return
                }
            }
        }
        else if (textField == gameChangerTextField)
        {
            if (textField.text!.count > 0)
            {
                if ((textField.text!.contains("gc.com") == false) || (textField.text!.isValidUrl == false))
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Bad URL", message: "The GameChanger URL is not valid. Make sure the URL begins with \"https://\"", lastItemCancelType: false) { tag in
                        
                    }
                    return
                }
            }
        }
        else if (textField == hudlTextField)
        {
            if (textField.text!.count > 0)
            {
                if ((textField.text!.contains("hudl.com") == false) || (textField.text!.isValidUrl == false))
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Bad URL", message: "The Hudl URL is not valid. Make sure the URL begins with \"https://\"", lastItemCancelType: false) { tag in
                        
                    }
                    return
                }
            }
        }
        else if (textField == twitterTextField)
        {
            if ((textField.text!.count > 0) && (textField.text!.first != "@"))
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Bad Username", message: "An X username must start with an @.", lastItemCancelType: false) { tag in
                    
                }
                return
            }
        }
        else if (textField == tiktokTextField)
        {
            if ((textField.text!.count > 0) && (textField.text!.first != "@"))
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Bad Username", message: "The TikTok username must start with an @.", lastItemCancelType: false) { tag in
                    
                }
                return
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()

        return true
    }
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        // Update the athleteDetailsTextCountLabel
        if (athleteDetailsTextView.text != kCareerProfileBioTextViewDefaultText)
        {
            athleteDetailsTextCountLabel.text = String(athleteDetailsTextView.text!.count) + " / 500 Characters"
        }
        else
        {
            athleteDetailsTextCountLabel.text = "0 / 500 Characters"
        }
        
        // Disable the save button if a keyboard is visible
        if ((firstNameTextField.isFirstResponder == true) || (lastNameTextField.isFirstResponder == true) || (athleteDetailsTextView.isFirstResponder == true) || (twitterTextField.isFirstResponder == true) || (instagramTextField.isFirstResponder == true) || (snapchatTextField.isFirstResponder == true) ||
            (tiktokTextField.isFirstResponder == true) ||
            (facebookTextField.isFirstResponder == true) ||
            (gameChangerTextField.isFirstResponder == true) ||
            (hudlTextField.isFirstResponder == true))
        {
            saveButton.isEnabled = false
        }
        else
        {
            // Disable the Save button if the first or last name is missing
            if (firstNameTextField.text == "") || (lastNameTextField.text == "")
            {
                saveButton.isEnabled = false
            }
            else
            {
                saveButton.isEnabled = true
            }
        }
    }
    
    // MARK: - Keyboard Accessory Views
    
    private func addKeyboardAccessoryView()
    {
        let athleteDetailsAccessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        athleteDetailsAccessoryView.backgroundColor = UIColor.mpGrayButtonBorderColor()
        
        let athleteDetailsDoneButton = UIButton(type: .custom)
        athleteDetailsDoneButton.frame = CGRect(x: kDeviceWidth - 85, y: 6, width: 80, height: 30)
        athleteDetailsDoneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        athleteDetailsDoneButton.setTitle("Done", for: .normal)
        athleteDetailsDoneButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        athleteDetailsDoneButton.addTarget(self, action: #selector(athleteDetailsDoneButtonTouched), for: .touchUpInside)
        athleteDetailsAccessoryView.addSubview(athleteDetailsDoneButton)
        athleteDetailsTextView!.inputAccessoryView = athleteDetailsAccessoryView
    
    }
    
    // MARK: - Button Methods
    
    @IBAction func cancelButtonTouched()
    {
        self.delegate?.editPlayerInfoViewControllerDidCancel()
    }
    
    @IBAction func saveButtonTouched()
    {
        // Validate athleteDetailsTextView for emojis one last time. The bad words were erased for the textFields and textView already
        if (athleteDetailsTextView.text.containsEmoji == true)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "You can't use special characters in this field.", lastItemCancelType: false) { tag in
                
            }
            return
        }
        
        // Check twitter that it starts with an @
        if (twitterTextField.text!.count > 0)
        {
            let firstCharacter = twitterTextField.text?.first
            if (firstCharacter != "@")
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Bad Username", message: "An X username must start with an @.", lastItemCancelType: false) { tag in
                    
                }
                return
            }
        }
        
        // Check tiktok that it starts with an @
        if (tiktokTextField.text!.count > 0)
        {
            let firstCharacter = tiktokTextField.text?.first
            if (firstCharacter != "@")
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Bad Username", message: "A TikTok username must start with an @.", lastItemCancelType: false) { tag in
                    
                }
                return
            }
        }
        
        // Check the facebook textField
        if (facebookTextField.text!.count > 0)
        {
            if ((((facebookTextField.text!.contains("facebook.com") == false) && (facebookTextField.text!.contains("fb.com") == false))) || (facebookTextField.text!.isValidUrl == false))
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Bad URL", message: "The facebook URL is not valid. Make sure the URL begins with \"https://\"", lastItemCancelType: false) { tag in
                    
                }
                return
            }
        }
        
        // Check the gameChanger textField
        if (gameChangerTextField.text!.count > 0)
        {
            if ((gameChangerTextField.text!.contains("gc.com") == false) || (gameChangerTextField.text!.isValidUrl == false))
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Bad URL", message: "The GameChanger URL is not valid. Make sure the URL begins with \"https://\"", lastItemCancelType: false) { tag in
                    
                }
                return
            }
        }
        
        // Check the hudl textField
        if (hudlTextField.text!.count > 0)
        {
            if ((hudlTextField.text!.contains("hudl.com") == false) || (hudlTextField.text!.isValidUrl == false))
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Bad URL", message: "The Hudl URL is not valid. Make sure the URL begins with \"https://\"", lastItemCancelType: false) { tag in
                    
                }
                return
            }
        }
        
        // If we've gotten this far, then go ahead and save the data
        self.saveData()
    }
    
    @objc private func athleteDetailsDoneButtonTouched()
    {
        athleteDetailsTextView.resignFirstResponder()
    }
    
    // MARK: - Keyboard Notifications
    
    @objc private func keyboardDidShow(notification: Notification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            //print("Keyboard Height: " + String(Int(keyboardSize.size.height)))

            // Need to use the device coordinates for this calculation
            var innerContainerViewBottom = 0
            
            if (twitterTextField.isFirstResponder == true)
            {
                innerContainerViewBottom = Int(containerScrollView.frame.origin.y) + Int(twitterContainerView.frame.origin.y) + Int(twitterContainerView.frame.size.height)
            }
            else if (instagramTextField.isFirstResponder == true)
            {
                innerContainerViewBottom = Int(containerScrollView.frame.origin.y) + Int(instagramContainerView.frame.origin.y) + Int(instagramContainerView.frame.size.height)
            }
            else if (snapchatTextField.isFirstResponder == true)
            {
                innerContainerViewBottom = Int(containerScrollView.frame.origin.y) + Int(snapchatContainerView.frame.origin.y) + Int(snapchatContainerView.frame.size.height)
            }
            else if (tiktokTextField.isFirstResponder == true)
            {
                innerContainerViewBottom = Int(containerScrollView.frame.origin.y) + Int(tiktokContainerView.frame.origin.y) + Int(tiktokContainerView.frame.size.height)
            }
            else if (facebookTextField.isFirstResponder == true)
            {
                innerContainerViewBottom = Int(containerScrollView.frame.origin.y) + Int(facebookContainerView.frame.origin.y) + Int(facebookContainerView.frame.size.height)
            }
            else if (gameChangerTextField.isFirstResponder == true)
            {
                innerContainerViewBottom = Int(containerScrollView.frame.origin.y) + Int(gameChangerContainerView.frame.origin.y) + Int(gameChangerContainerView.frame.size.height)
            }
            else if (hudlTextField.isFirstResponder == true)
            {
                innerContainerViewBottom = Int(containerScrollView.frame.origin.y) + Int(hudlContainerView.frame.origin.y) + Int(hudlContainerView.frame.size.height)
            }
            
            let keyboardTop = Int(kDeviceHeight) - Int(keyboardSize.size.height)
            
            if (keyboardTop < innerContainerViewBottom)
            {
                let difference = innerContainerViewBottom - keyboardTop
                containerScrollView.contentOffset = CGPoint(x: 0, y: difference)
            }
            
            // Increase the scroll size
            containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: kContainerHeight + keyboardSize.size.height - 20.0)
        }
    }
    
    @objc private func keyboardDidHide(notification: Notification)
    {
        //print("Keyboard will hide")
        //containerScrollView.contentOffset = CGPoint(x: 0, y: 0)
        
        // Set the scroll size
        containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: kContainerHeight)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        fakeStatusBar.backgroundColor = .clear

        // Size the fakeStatusBar, navBar, and containerScrollView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight + 12)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        containerScrollView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height)
        
        // Set the scroll size
        containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: kContainerHeight)
        
        navView.layer.cornerRadius = 12
        navView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        navView.clipsToBounds = true
        
        athleteDetailsTextView.layer.cornerRadius = 6
        athleteDetailsTextView.layer.borderWidth = 0.5
        athleteDetailsTextView.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        athleteDetailsTextView.clipsToBounds = true
        
        self.addKeyboardAccessoryView()
        
        // Add the keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
        
        self.loadData()
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

    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        // Add some delay so the view is partially showing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
        {
            UIView.animate(withDuration: 0.3)
            { [self] in
                fakeStatusBar.backgroundColor = UIColor(white: 0, alpha: 0.2)
            }
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
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
