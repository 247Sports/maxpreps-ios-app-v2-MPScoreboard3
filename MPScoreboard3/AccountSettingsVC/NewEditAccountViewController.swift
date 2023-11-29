//
//  NewEditAccountViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/13/23.
//

import UIKit

class NewEditAccountViewController: UIViewController, UITextFieldDelegate, IQActionSheetPickerViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var birthdateTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var zipcodeContainerView: UIView!
    @IBOutlet weak var zipcodeTextField: UITextField!
    @IBOutlet weak var roleContainerView: UIView!
    @IBOutlet weak var roleTextField: UITextField!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var editEmailButton: UIButton!
    @IBOutlet weak var editPasswordButton: UIButton!
    
    var userInfoUpdated = false
    
    private var kGenderValues = ["Male", "Female", "Prefer not to say", "Other"]
    private var kGenderAliasDictionary = ["Male": "Male", "Female": "Female", "Prefer not to say": "PreferNotToSay", "Other": "Other"]
    private var kRoleValues = ["Athlete", "Parent", "Fan", "High School Coach", "Athletic Director", "College Coach", "Statistician", "Media", "School Administrator"]
    
    private var tickTimer: Timer!
    private var progressOverlay: ProgressHUD!
    
    private var updateEmailVC: NewUpdateEmailViewController!
    private var updatePasswordVC: NewUpdatePasswordViewController!
    
    private let kContainerHeight = 634.0
    
    // MARK: - Save User Info
    
    private func saveUserInfo()
    {
        var genderAlias = ""
        
        if (genderTextField.text!.count > 0)
        {
            genderAlias = kGenderAliasDictionary[genderTextField.text!] ?? ""
        }
        
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.updateUserInfo(firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, birthdate: birthdateTextField.text!, gender: genderAlias, zipcode: zipcodeTextField.text!, userType: roleTextField.text!) { statusCode, error in
            
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
                if (statusCode == 200)
                {
                    self.userInfoUpdated = true
                    
                    // Update the user's prefs
                    kUserDefaults.set(self.firstNameTextField.text!, forKey: kUserFirstNameKey)
                    kUserDefaults.set(self.lastNameTextField.text!, forKey: kUserLastNameKey)
                    kUserDefaults.set(self.birthdateTextField.text!, forKey: kUserBirthdateKey)
                    kUserDefaults.set(self.genderTextField.text!, forKey: kUserGenderKey)
                    kUserDefaults.set(self.zipcodeTextField.text!, forKey: kUserZipKey)
                    kUserDefaults.set(self.roleTextField.text!, forKey: kUserTypeKey)
                    
                    OverlayView.showPopupOverlay(withMessage: "Account Updated") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                else if (statusCode == 400)
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Oops", message: "There is a problem with one of the fields.", lastItemCancelType: false) { tag in
                        
                    }
                }
                else
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "A server error has occurred.", lastItemCancelType: false) { tag in
                        
                    }
                }
            }
            else
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "A server error has occurred.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelectTitles titles: [String])
    {
        let title = titles.first
        
        if (pickerView.tag == 1)
        {
            genderTextField.text = title
        }
        else if (pickerView.tag == 2)
        {
            roleTextField.text = title
        }
    }
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelect date: Date)
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy"
        birthdateTextField.text = dateFormatter.string(from: date)
    }
    
    func actionSheetPickerViewDidCancel(_ pickerView: IQActionSheetPickerView)
    {

    }
    
    // MARK: - TextField Delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if (textField == birthdateTextField)
        {
            let picker = IQActionSheetPickerView(title: "Select Date", delegate: self)
            picker.backgroundColor = UIColor.mpWhiteColor()
            picker.toolbarButtonColor = UIColor.mpDarkGrayColor()
            picker.toolbarTintColor = UIColor.mpGrayButtonBorderColor()
            picker.actionSheetPickerStyle = IQActionSheetPickerStyle.datePicker
            
            // Set the maximum date to thirteen years old.
            let thirteenYearsAgo = Date().addingTimeInterval(-13 * 365.25 * 24 * 60 * 60)
            
            // Set the minimum date to 100 years ago minus a day
            let oneHunderdYearsAgo = Date().addingTimeInterval((-100 * 365.25 * 24 * 60 * 60) + (24 * 60 * 60))
            
            picker.minimumDate = oneHunderdYearsAgo
            picker.maximumDate = thirteenYearsAgo
            picker.show()
            
            return false
        }
        else if (textField == genderTextField)
        {
            let picker = IQActionSheetPickerView(title: "Select Gender", delegate: self)
            picker.tag = 1
            picker.backgroundColor = UIColor.mpWhiteColor()
            picker.toolbarButtonColor = UIColor.mpDarkGrayColor()
            picker.toolbarTintColor = UIColor.mpGrayButtonBorderColor()
            picker.titlesForComponents = [kGenderValues]
            
            // Preload the starting index if possible
            if (genderTextField.text! != "")
            {
                if let startingIndex = kGenderValues.firstIndex(of: genderTextField.text!)
                {
                    picker.selectIndexes([NSNumber(integerLiteral: startingIndex)], animated: false)
                }
            }
            
            picker.show()
            return false
        }
        else if (textField == roleTextField)
        {
            let picker = IQActionSheetPickerView(title: "Select Role", delegate: self)
            picker.tag = 2
            picker.backgroundColor = UIColor.mpWhiteColor()
            picker.toolbarButtonColor = UIColor.mpDarkGrayColor()
            picker.toolbarTintColor = UIColor.mpGrayButtonBorderColor()
            picker.titlesForComponents = [kRoleValues]
            
            // Preload the starting index if possible
            if (roleTextField.text! != "")
            {
                if let startingIndex = kRoleValues.firstIndex(of: roleTextField.text!)
                {
                    picker.selectIndexes([NSNumber(integerLiteral: startingIndex)], animated: false)
                }
            }
            
            picker.show()
            return false
        }
        else
        {
            return true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if (textField == zipcodeTextField)
        {
            if (range.location > 4)
            {
                return false
            }
            else
            {
                if (string == ".")
                {
                    return false
                }
                else
                {
                    return true
                }
            }
        }
        else
        {
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if (textField == zipcodeTextField)
        {
            if (zipcodeTextField.text?.count != 5)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Oops", message: "The zip code needs to be five digits.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        if ((firstNameTextField.text?.count == 0) || (lastNameTextField.text?.count == 0) || (zipcodeTextField.text?.count != 5))
        {
            saveButton.isEnabled = false
            saveButton.alpha = 0.5
        }
        else
        {
            saveButton.isEnabled = true
            saveButton.alpha = 1.0
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonTouched(_ sender: UIButton)
    {
        if ((firstNameTextField.text!.containsEmoji == true) || (lastNameTextField.text!.containsEmoji == true))
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Oops", message: "A name can not include special characters.", lastItemCancelType: false) { tag in
                
            }
            return
        }
        
        // Check for bad words
        let badFirstNames = IODProfanityFilter.rangesOfFilteredWords(in: firstNameTextField.text!)
        let badLastNames = IODProfanityFilter.rangesOfFilteredWords(in: lastNameTextField.text!)
        
        if ((badFirstNames!.count > 0) || (badLastNames!.count > 0))
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Language", message: "The names that you have entered are objectionable and can not be used.", lastItemCancelType: false) { tag in
                
            }
            return
        }
        
        self.saveUserInfo()
        
    }
    
    @IBAction func editEmailButtonTouched(_ sender: UIButton)
    {
        updateEmailVC = NewUpdateEmailViewController(nibName: "NewUpdateEmailViewController", bundle: nil)
        self.navigationController?.pushViewController(updateEmailVC, animated: true)
    }
    
    @IBAction func editPasswordButtonTouched(_ sender: UIButton)
    {
        updatePasswordVC = NewUpdatePasswordViewController(nibName: "NewUpdatePasswordViewController", bundle: nil)
        self.navigationController?.pushViewController(updatePasswordVC, animated: true)
    }
    
    @objc private func keyboardDoneButtonTouched()
    {
        zipcodeTextField.resignFirstResponder()
    }
    
    // MARK: - Load User Data
    
    private func loadUserData()
    {
        firstNameTextField.text = kUserDefaults.string(forKey: kUserFirstNameKey)
        lastNameTextField.text = kUserDefaults.string(forKey: kUserLastNameKey)
        birthdateTextField.text = kUserDefaults.string(forKey: kUserBirthdateKey)
        zipcodeTextField.text = kUserDefaults.string(forKey: kUserZipKey)
        roleTextField.text = kUserDefaults.string(forKey: kUserTypeKey)
        emailLabel.text = kUserDefaults.string(forKey: kUserEmailKey)
        
        let gender = kUserDefaults.string(forKey: kUserGenderKey)
        if (gender! == "PreferNotToSay")
        {
            genderTextField.text = "Prefer not to say"
        }
        else
        {
            genderTextField.text = gender!
        }
        
    }
    
    // MARK: - Keyboard Notifications
    
    @objc private func keyboardDidShow(notification: Notification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            print("Keyboard Height: " + String(Int(keyboardSize.size.height)))
            
            if (zipcodeTextField.isFirstResponder == true)
            {
                // Scroll up if the zipcodeTextField is covered
                // Need to use absolute cooordinates for this
                let bottomZipCodeContainer = containerScrollView.frame.origin.y + zipcodeContainerView.frame.origin.y + zipcodeContainerView.frame.size.height
                let keyboardOriginY = kDeviceHeight - keyboardSize.size.height
                
                if (bottomZipCodeContainer > keyboardOriginY)
                {
                    containerScrollView.contentOffset = CGPoint(x: 0, y: bottomZipCodeContainer - keyboardOriginY)
                }
            }
            
            // Increase the scroll size
            containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: kContainerHeight + keyboardSize.size.height - 40.0)
        }
    }
    
    @objc private func keyboardDidHide(notification: Notification)
    {
        //print("Keyboard will hide")
        containerScrollView.contentOffset = CGPoint(x: 0, y: 0)
        containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: kContainerHeight)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and scrollView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        containerScrollView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height)
        
        containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: kContainerHeight)
        
        // Add an Accessory view to the keyboard
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        accessoryView.backgroundColor = UIColor.mpGrayButtonBorderColor()
        
        let doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: kDeviceWidth - 85, y: 5, width: 80, height: 30)
        doneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        doneButton.addTarget(self, action: #selector(keyboardDoneButtonTouched), for: .touchUpInside)
        accessoryView.addSubview(doneButton)
        zipcodeTextField!.inputAccessoryView = accessoryView
        
        /*
        let attributedString = NSMutableAttributedString(string: "Save", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 17), NSAttributedString.Key.foregroundColor: UIColor.mpBlackColor()])
        
        saveButton.setAttributedTitle(attributedString, for: .normal)
        
        let attributedString2 = NSMutableAttributedString(string: "Edit", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 15), NSAttributedString.Key.foregroundColor: UIColor.mpBlackColor()])
        
        editEmailButton.setAttributedTitle(attributedString2, for: .normal)
        editPasswordButton.setAttributedTitle(attributedString2, for: .normal)
        */
        
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
        self.tabBarController?.tabBar.isHidden = true
        
        setNeedsStatusBarAppearanceUpdate()
        
        if (updateEmailVC != nil)
        {
            if (updateEmailVC.emailUpdated == true)
            {
                self.userInfoUpdated = true
            }
        }
        
        self.loadUserData()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (updateEmailVC != nil)
        {
            updateEmailVC = nil
        }
        
        if (updatePasswordVC != nil)
        {
            updatePasswordVC = nil
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
