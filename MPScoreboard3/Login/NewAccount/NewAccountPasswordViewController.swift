//
//  NewAccountPasswordViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/18/22.
//

import UIKit

class NewAccountPasswordViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    var isPendingMember = false
    var userEmail = ""
    
    private var tickTimer: Timer!
    private var showPassword = false
    
    private var newAccountNameVC: NewAccountNameViewController!
    
    // MARK: - Show Name View Controller
    
    private func showNameViewController()
    {
        if (newAccountNameVC != nil)
        {
            newAccountNameVC = nil
        }
        
        newAccountNameVC = NewAccountNameViewController(nibName: "NewAccountNameViewController", bundle: nil)
        newAccountNameVC.userEmail = self.userEmail
        newAccountNameVC.userPassword = passwordTextField.text!
        newAccountNameVC.isPendingMember = self.isPendingMember
        
        self.navigationController?.pushViewController(newAccountNameVC, animated: true)
    }
    
    // MARK: - TextField Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Minimum 8 characters
        if (passwordTextField.text!.count > 7)
        {
            if (MiscHelper.isValidPassword(passwordTextField.text!) == true)
            {
                if (passwordTextField.text!.containsEmoji == true)
                {
                    self.showErrorMessage("Special characters not allowed.")
                }
                else
                {
                    self.showNameViewController()
                }
            }
            else
            {
                self.showErrorMessage("The password does not meet requirements.")
            }
        }
        
        return true
    }
    
    // MARK: - Show Error Message
    
    private func showErrorMessage(_ message: String)
    {
        errorMessageLabel.text = message
        errorMessageLabel.alpha = 1.0
        underlineView.backgroundColor = UIColor.mpRedColor()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5)
        {
            UIView.animate(withDuration: 0.25, animations: {
                
                self.errorMessageLabel.alpha = 0.0
                self.underlineView.backgroundColor = UIColor.mpGrayButtonBorderColor()
            })
            { (finished) in
                
                self.errorMessageLabel.text = ""
            } 
        }
    }
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        // Minimum 8 characters
        if (passwordTextField.text!.count > 7)
        {
            nextButton.backgroundColor = UIColor.mpNegativeRedColor()
            nextButton.isEnabled = true
        }
        else
        {
            nextButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
            nextButton.isEnabled = false
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonTouched(_ sender: UIButton)
    {
        if (MiscHelper.isValidPassword(passwordTextField.text!) == true)
        {
            if (passwordTextField.text!.containsEmoji == true)
            {
                self.showErrorMessage("Special characters not allowed.")
            }
            else
            {
                self.showNameViewController()
            }
        }
        else
        {
            self.showErrorMessage("The password does not meet requirements.")
        }
    }
    
    @IBAction func showPasswordButtonTouched(_ sender: UIButton)
    {
        showPassword = !showPassword
        
        if (showPassword == true)
        {
            let attributedString = NSMutableAttributedString(string: "HIDE", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 13), NSAttributedString.Key.foregroundColor: UIColor.mpLightGrayColor()])
            
            showPasswordButton.setAttributedTitle(attributedString, for: .normal)
            passwordTextField.isSecureTextEntry = false
        }
        else
        {
            let attributedString = NSMutableAttributedString(string: "SHOW", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 13), NSAttributedString.Key.foregroundColor: UIColor.mpLightGrayColor()])
            
            showPasswordButton.setAttributedTitle(attributedString, for: .normal)
            passwordTextField.isSecureTextEntry = true
        }
    }
    
    // MARK: - Keyboard Notifications
    
    @objc private func keyboardDidShow(notification: Notification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            print("Keyboard Height: " + String(Int(keyboardSize.size.height)))
            
            let innerContainerHeight = kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height - keyboardSize.size.height
            
            innerContainerView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: innerContainerHeight)
        }
    }
    
    @objc private func keyboardDidHide(notification: Notification)
    {
        //print("Keyboard will hide")
        
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and innerContainer
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        
        // Default keyboard height = 260. This will change later
        let innerContainerHeight = kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight) - 260.0
        
        innerContainerView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: innerContainerHeight)
        
        let attributedString = NSMutableAttributedString(string: "SHOW", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 13), NSAttributedString.Key.foregroundColor: UIColor.mpLightGrayColor()])
        
        showPasswordButton.setAttributedTitle(attributedString, for: .normal)
        
        nextButton.layer.cornerRadius = nextButton.frame.size.height / 2.0
        nextButton.clipsToBounds = true
        nextButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
        nextButton.isEnabled = false
        
        errorMessageLabel.text = ""
        errorMessageLabel.alpha = 0.0
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
        
        // Add the keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Tracking
        let trackingGuid = NSUUID().uuidString
        TrackingManager.trackState(featureName: "password", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        passwordTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (newAccountNameVC != nil)
        {
            newAccountNameVC = nil
        }
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
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
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

}
