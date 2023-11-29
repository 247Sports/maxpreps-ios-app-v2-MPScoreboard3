//
//  UpdatePasswordViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 7/6/22.
//

import UIKit

class UpdatePasswordViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var oldPasswordContainerView: UIView!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordContainerView: UIView!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordContainerView: UIView!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var showPasswordButton: UIButton!
        
    private var showPassword = false
    private var tickTimer: Timer!
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Update Password
    
    private func updatePassword()
    {
        NewFeeds.updateUserPassword(oldPassword: oldPasswordTextField.text!, newPassword: newPasswordTextField.text!, confirmPassword: confirmPasswordTextField.text!) { statusCode, error in
            
            if (error == nil)
            {
                if (statusCode == 200)
                {
                    OverlayView.showPopupOverlay(withMessage: "Password Updated") {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                else if (statusCode == 400)
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Oops", message: "The old password is incorrect.", lastItemCancelType: false) { tag in
                        
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
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if (textField == oldPasswordTextField)
        {
            oldPasswordContainerView.layer.borderColor = UIColor.mpDarkGrayColor().cgColor
        }
        else if (textField == newPasswordTextField)
        {
            newPasswordContainerView.layer.borderColor = UIColor.mpDarkGrayColor().cgColor
        }
        else if (textField == confirmPasswordTextField)
        {
            confirmPasswordContainerView.layer.borderColor = UIColor.mpDarkGrayColor().cgColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        oldPasswordContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        newPasswordContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        confirmPasswordContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
    }
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        if ((oldPasswordTextField.text!.count > 0) && (newPasswordTextField.text!.count > 7) && (confirmPasswordTextField.text!.count > 7))
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
        self.view.endEditing(true)
        
        if (newPasswordTextField.text != confirmPasswordTextField.text)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Oops", message: "The new passwords do not match.", lastItemCancelType: false) { tag in
                
            }
            return
        }
        
        if ((newPasswordTextField.text!.containsEmoji == true) || (confirmPasswordTextField.text!.containsEmoji == true))
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Oops", message: "Special characters can not be used.", lastItemCancelType: false) { tag in
                
            }
            return
        }
        
        if (MiscHelper.isValidPassword(newPasswordTextField.text!) == true)
        {
            self.updatePassword()
        }
        else
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Oops", message: "The new password does not meet the minimum requirements.", lastItemCancelType: false) { tag in
                
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
            oldPasswordTextField.isSecureTextEntry = false
        }
        else
        {
            let attributedString = NSMutableAttributedString(string: "SHOW", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 13), NSAttributedString.Key.foregroundColor: UIColor.mpGrayColor()])
            
            showPasswordButton.setAttributedTitle(attributedString, for: .normal)
            oldPasswordTextField.isSecureTextEntry = true
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Size the fakeStatusBar, navBar, and scrollView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        containerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height)
        
        oldPasswordContainerView.layer.cornerRadius = 8
        oldPasswordContainerView.layer.borderWidth = 1
        oldPasswordContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        oldPasswordContainerView.clipsToBounds = true
        
        newPasswordContainerView.layer.cornerRadius = 8
        newPasswordContainerView.layer.borderWidth = 1
        newPasswordContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        newPasswordContainerView.clipsToBounds = true
        
        confirmPasswordContainerView.layer.cornerRadius = 8
        confirmPasswordContainerView.layer.borderWidth = 1
        confirmPasswordContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        confirmPasswordContainerView.clipsToBounds = true
        
        saveButton.layer.cornerRadius = 8.0
        saveButton.clipsToBounds = true
        saveButton.backgroundColor = UIColor.mpLightGrayColor()
        saveButton.isEnabled = false
        
        let attributedString = NSMutableAttributedString(string: "SHOW", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 13), NSAttributedString.Key.foregroundColor: UIColor.mpGrayColor()])
        
        showPasswordButton.setAttributedTitle(attributedString, for: .normal)
        
        oldPasswordTextField.becomeFirstResponder()
        
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
