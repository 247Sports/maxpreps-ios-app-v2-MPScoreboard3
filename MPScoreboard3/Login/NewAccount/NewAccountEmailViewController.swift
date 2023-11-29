//
//  NewAccountEmailViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/17/22.
//

import UIKit

class NewAccountEmailViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    private var tickTimer: Timer!
    private var isPendingMember = false
    
    private var newAccountPasswordVC: NewAccountPasswordViewController!
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Show Password View Controller
    
    private func showPasswordViewController()
    {
        if (newAccountPasswordVC != nil)
        {
            newAccountPasswordVC = nil
        }
        
        let fixedEmail = emailTextField.text!.replacingOccurrences(of: " ", with: "")
        
        newAccountPasswordVC = NewAccountPasswordViewController(nibName: "NewAccountPasswordViewController", bundle: nil)
        newAccountPasswordVC.userEmail = fixedEmail
        newAccountPasswordVC.isPendingMember = self.isPendingMember
        
        self.navigationController?.pushViewController(newAccountPasswordVC, animated: true)
    }
    
    // MARK: - Validate Email Method
    
    private func validateEmail()
    {
        // Show the busy indicator
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        let fixedEmail = emailTextField.text!.replacingOccurrences(of: " ", with: "")
        
        NewFeeds.validateAccountEmail(email: fixedEmail) { result, error in
            
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
                print("Validate Email Success")
                let accountExists = result!["accountExists"] as! Bool
                let isMember = result!["isMember"] as! Bool
                
                if (isMember == true)
                {
                    self.showErrorMessage("This email is already registered with MaxPreps.")
                }
                else
                {
                    if (accountExists == true)
                    {
                        self.isPendingMember = true
                    }
                    else
                    {
                        self.isPendingMember = false
                    }
                    
                    self.showPasswordViewController()
                }
                
                /*
                 ▿ 0 : 2 elements
                   - key : "accountExists"
                   - value : 1
                 ▿ 1 : 2 elements
                   - key : "email"
                   - value : dsmith4021@comcast.net
                 ▿ 2 : 2 elements
                   - key : "isLockedOut"
                   - value : 0
                 ▿ 3 : 2 elements
                   - key : "isMember"
                   - value : 1
                 */
            }
            else
            {
                self.showErrorMessage("A server error has occurred.")
            }
        }
    }
    
    // MARK: - TextField Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if (emailTextField.text!.count > 0)
        {
            if (MiscHelper.isValidEmailAddress(emailTextField.text!) == true)
            {
                if (emailTextField.text!.containsEmoji == true)
                {
                    self.showErrorMessage("Special characters not allowed.")
                }
                else
                {
                    self.validateEmail()
                }
            }
            else
            {
                self.showErrorMessage("Invalid email address.")
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
        if (emailTextField.text!.count > 0)
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
        if (MiscHelper.isValidEmailAddress(emailTextField.text!) == true)
        {
            if (emailTextField.text!.containsEmoji == true)
            {
                self.showErrorMessage("Special characters not allowed.")
            }
            else
            {
                self.validateEmail()
            }
        }
        else
        {
            self.showErrorMessage("Invalid email address.")
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
        
        // 291, 336
        
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
        TrackingManager.trackState(featureName: "email", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        emailTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (newAccountPasswordVC != nil)
        {
            newAccountPasswordVC = nil
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
