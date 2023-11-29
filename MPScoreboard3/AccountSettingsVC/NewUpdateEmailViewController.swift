//
//  NewUpdateEmailViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/13/23.
//

import UIKit

class NewUpdateEmailViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var showPasswordButton: UIButton!
    
    var emailUpdated = false
    
    private var showPassword = false
    private var tickTimer: Timer!
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Validate Email Method
    
    private func validateEmail()
    {        
        if (emailTextField.text!.contains(" ") == true)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Oops...", message: "You can not include a whitespace in your email.", lastItemCancelType: false) { tag in
                
            }
            return
        }
        
        NewFeeds.validateAccountEmail(email: emailTextField.text!) { result, error in

            if (error == nil)
            {
                print("Validate Email Success")
                let accountExists = result!["accountExists"] as! Bool
                
                if (accountExists == true)
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This email is already registered with MaxPreps and can not be used.", lastItemCancelType: false) { tag in
                        
                    }
                }
                else
                {
                    // Call the API to update the email
                    self.updateEmail()
                }
            }
            else
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "A server error has occurred.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - Update Email
    
    private func updateEmail()
    {
        let email = kUserDefaults.string(forKey: kUserEmailKey)
        
        NewFeeds.updateUserEmail(currentEmail: email!, newEmail: emailTextField.text!, password: passwordTextField.text!) {statusCode, error in
            
            if (error == nil)
            {
                if (statusCode == 200)
                {
                    self.emailUpdated = true
                    
                    // Update the user's email in the prefs
                    kUserDefaults.set(self.emailTextField.text, forKey: kUserEmailKey)
                    
                    OverlayView.showPopupOverlay(withMessage: "Email Updated") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                else if (statusCode == 400)
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Oops", message: "The password is incorrect.", lastItemCancelType: false) { tag in
                        
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
    
    // MARK: - TextField Delegates

    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
    }
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        if ((emailTextField.text!.count > 0) && (passwordTextField.text!.count > 0))
        {
            saveButton.backgroundColor = UIColor.mpRedColor()
            saveButton.isEnabled = true
        }
        else
        {
            saveButton.backgroundColor = UIColor.mpLightGrayColor()
            saveButton.isEnabled = false
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonTouched(_ sender: UIButton)
    {
        if (MiscHelper.isValidEmailAddress(emailTextField.text!) == true)
        {
            self.view.endEditing(true)
            
            if ((emailTextField.text!.containsEmoji == true) || (passwordTextField.text!.containsEmoji == true))
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Oops", message: "Special characters can not be used.", lastItemCancelType: false) { tag in
                    
                }
            }
            else
            {
                self.validateEmail()
            }
        }
        else
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Oops", message: "Invalid email address.", lastItemCancelType: false) { tag in
                
            }
        }
    }
    
    @IBAction func showPasswordButtonTouched(_ sender: UIButton)
    {
        showPassword = !showPassword
        
        if (showPassword == true)
        {
            let attributedString = NSMutableAttributedString(string: "HIDE", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 13), NSAttributedString.Key.foregroundColor: UIColor.mpGrayColor()])
            
            showPasswordButton.setAttributedTitle(attributedString, for: .normal)
            passwordTextField.isSecureTextEntry = false
        }
        else
        {
            let attributedString = NSMutableAttributedString(string: "SHOW", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 13), NSAttributedString.Key.foregroundColor: UIColor.mpGrayColor()])
            
            showPasswordButton.setAttributedTitle(attributedString, for: .normal)
            passwordTextField.isSecureTextEntry = true
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and scrollView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        containerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height) // - CGFloat(SharedData.bottomSafeAreaHeight))
        
        saveButton.layer.cornerRadius = 8.0
        saveButton.clipsToBounds = true
        saveButton.backgroundColor = UIColor.mpLightGrayColor()
        saveButton.isEnabled = false
        
        let attributedString = NSMutableAttributedString(string: "SHOW", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 13), NSAttributedString.Key.foregroundColor: UIColor.mpGrayColor()])
        
        showPasswordButton.setAttributedTitle(attributedString, for: .normal)
        
        emailTextField.becomeFirstResponder()

        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        
        setNeedsStatusBarAppearanceUpdate()
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
    }

}
