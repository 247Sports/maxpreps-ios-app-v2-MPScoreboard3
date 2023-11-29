//
//  AddAchievementsAwardsViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/25/23.
//

import UIKit

class AddAchievementsAwardsViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, IQActionSheetPickerViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionTextCountLabel: UILabel!
    
    var careerId = ""
    
    private var containerViewHeight = 0.0
    private var editAttempted = false
    private var progressOverlay: ProgressHUD!
    private var tickTimer: Timer!
    
    let kDefaultDescriptionText = "Tell us about it..."
    
    // MARK: - IQActionPickerView Delegate

    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelect date: Date)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        let dateString = dateFormatter.string(from: date)
        dateTextField.text = dateString
    }
    
    func actionSheetPickerViewDidCancel(_ pickerView: IQActionSheetPickerView)
    {
        
    }
    
    // MARK: - TextView Delegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        editAttempted = true
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        textView.textColor = UIColor.mpBlackColor()
        
        if (textView.text == kDefaultDescriptionText)
        {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == "")
        {
            textView.text = kDefaultDescriptionText
            textView.textColor = UIColor.mpLightGrayColor()
        }
        else
        {
            let badWords = IODProfanityFilter.rangesOfFilteredWords(in: descriptionTextView.text)
            
            if (badWords!.count > 0)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Language", message: "The text that you have entered is objectionable and can not be used.", lastItemCancelType: false) { tag in

                    self.descriptionTextView.text = self.kDefaultDescriptionText
                    self.descriptionTextView.textColor = UIColor.mpLightGrayColor()
                }
                return
            }
            else
            {
                if (descriptionTextView.text.containsEmoji == true)
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
        editAttempted = true
        
        if (textField == titleTextField)
        {
            return true
        }
        else
        {
            let picker = IQActionSheetPickerView(title: "Select Date", delegate: self)
            picker.backgroundColor = UIColor.mpWhiteColor()
            picker.toolbarButtonColor = UIColor.mpDarkGrayColor()
            picker.toolbarTintColor = UIColor.mpGrayButtonBorderColor()
            picker.actionSheetPickerStyle = IQActionSheetPickerStyle.datePicker

            // Set the minimum date to 1/1/2000
            let formatter = DateFormatter()
            formatter.dateFormat = "M/d/yyyy"
            let minDate = formatter.date(from: "1/1/2000")
            picker.minimumDate = minDate
            picker.maximumDate = Date() // Today
            
            // Preload the date
            if (dateTextField.text! != "")
            {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM d, yyyy"
                let date = dateFormatter.date(from: dateTextField.text!) ?? Date()
                picker.setDate(date, animated: false)
            }
            picker.show()
            
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        // Emoji detection is not needed since the keyboard is ASCII
        
        let badWords = IODProfanityFilter.rangesOfFilteredWords(in: textField.text)
        
        if (badWords!.count > 0)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Language", message: "The text that you have entered is objectionable and can not be used.", lastItemCancelType: false) { tag in

                textField.text = ""
            }
            return
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        // Limit to 50 characters
        if (range.location > 49)
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched()
    {
        if (editAttempted == false)
        {
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            MiscHelper.showAlert(in: self, withActionNames: ["Cancel", "Discard"], title: "Discard Changes?", message: "By choosing to discard, you will lose the edits you just made.", lastItemCancelType: false) { tag in
                
                if (tag == 1)
                {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func saveButtonTouched()
    {
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        // Reformat the date for the API
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        let update = dateFormatter.date(from: dateTextField.text!)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: update!)
        
        // Fix the description
        var description = ""
        
        if (descriptionTextView.text! != kDefaultDescriptionText)
        {
            description = descriptionTextView.text!
        }

        CareerFeeds.addAthleteAchievementsAwards(careerId: self.careerId, title: titleTextField.text!, description: description, dateString: dateString) { error in
            
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
                print("Add Awards Success")
                
                OverlayView.showTwoLinePopupOverlay(withMessage: "Success! Your changes will take a few minutes to be reflected on your profile.", boldText: "Success!", withDismissHandler: {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                    {
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            }
            else
            {
                print("Add Awards Failed")
                
                let errorMessage = error?.localizedDescription
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: errorMessage, lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    @objc private func descriptionDoneButtonTouched()
    {
        descriptionTextView.resignFirstResponder()
    }
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        // Update the descriptionTextCountLabel
        if (descriptionTextView.text != kDefaultDescriptionText)
        {
            descriptionTextCountLabel.text = String(descriptionTextView.text!.count) + " / 500 Characters"
        }
        else
        {
            descriptionTextCountLabel.text = "0 / 500 Characters"
        }
        
        if ((titleTextField.text!.count > 0) && (dateTextField.text!.count > 0))
        {
            saveButton.backgroundColor = UIColor.mpBlackColor()
            saveButton.isEnabled = true
        }
        else
        {
            saveButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
            saveButton.isEnabled = false
        }
    }
    
    // MARK: - Keyboard Accessory View
    
    private func addKeyboardAccessoryView()
    {
        let descriptionAccessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        descriptionAccessoryView.backgroundColor = UIColor.mpGrayButtonBorderColor()
        
        let descriptionDoneButton = UIButton(type: .custom)
        descriptionDoneButton.frame = CGRect(x: kDeviceWidth - 85, y: 6, width: 80, height: 30)
        descriptionDoneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        descriptionDoneButton.setTitle("Done", for: .normal)
        descriptionDoneButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        descriptionDoneButton.addTarget(self, action: #selector(descriptionDoneButtonTouched), for: .touchUpInside)
        descriptionAccessoryView.addSubview(descriptionDoneButton)
        descriptionTextView!.inputAccessoryView = descriptionAccessoryView
    
    }
    
    // MARK: - Keyboard Notifications
    
    @objc private func keyboardDidShow(notification: Notification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            //print("Keyboard Height: " + String(Int(keyboardSize.size.height)))
            
            // Shrink the containerScrollView height
            containerScrollView.frame.size = CGSize(width: kDeviceWidth, height: containerViewHeight + bottomContainerView.frame.size.height - keyboardSize.size.height)
        }
    }
    
    @objc private func keyboardDidHide(notification: Notification)
    {
        //print("Keyboard will hide")
        //containerScrollView.contentOffset = CGPoint(x: 0, y: 0)
        
        // Set the scroll size
        containerScrollView.frame.size = CGSize(width: kDeviceWidth, height: containerViewHeight - 10.0)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Size the fakeStatusBar, navBar, bottomContainer, and containerScrollView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        bottomContainerView.frame = CGRect(x: 0, y: Int(kDeviceHeight) - 70 - SharedData.bottomSafeAreaHeight, width: Int(kDeviceWidth), height: 70 + SharedData.bottomSafeAreaHeight)
        
        containerViewHeight = kDeviceHeight - navView.frame.origin.y - navView.frame.size.height - bottomContainerView.frame.size.height
        
        containerScrollView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: containerViewHeight)
        
        containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: 640)
        
        saveButton.layer.cornerRadius = 8
        saveButton.clipsToBounds = true
        saveButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
        saveButton.isEnabled = false
        
        descriptionTextView.layer.cornerRadius = 6
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        descriptionTextView.clipsToBounds = true
        
        self.addKeyboardAccessoryView()
        
        // Add the keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)

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
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
    }
}
