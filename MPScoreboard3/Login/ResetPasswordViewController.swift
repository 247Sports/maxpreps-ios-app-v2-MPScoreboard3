//
//  ResetPasswordViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/15/22.
//

import UIKit

class ResetPasswordViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var sendResetButton: UIButton!
    
    private var tickTimer: Timer!
    private var resetSuccessful = false
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Reset Password Feed
    
    private func resetPassword()
    {
        // Show the busy indicator
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.resetUserPassword(email: emailTextField.text!) { error in
            
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
                self.messageLabel.text = "If you have an account registered with that email address, you will receive an email shortly with instructions to reset your password."
                self.sendResetButton.setTitle("BACK TO LOGIN", for: .normal)
                
                self.resetSuccessful = true
            }
            else
            {
                print("Login Failed")
                
                let errorMessage = error?.localizedDescription
                
                OverlayView.showPopdownOverlay(withMessage: errorMessage, title: "Oops!", overlayColor: UIColor.mpPinkMessageColor()) {
                }
            }
        }
    }
    
    // MARK: - TextField Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()

        return true
    }
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        if (emailTextField.text!.count > 0)
        {
            sendResetButton.backgroundColor = UIColor.mpRedColor()
            sendResetButton.isEnabled = true
        }
        else
        {
            sendResetButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
            sendResetButton.isEnabled = false
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendResetButtonTouched(_ sender: UIButton)
    {
        if (resetSuccessful == true)
        {
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            if (MiscHelper.isValidEmailAddress(emailTextField.text!) == true)
            {
                emailTextField.resignFirstResponder()
                self.resetPassword()
            }
            else
            {
                OverlayView.showPopdownOverlay(withMessage: "The email is not valid.", title: "Oops!", overlayColor: UIColor.mpPinkMessageColor()) {
                }
            }
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and innerContainer
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        innerContainerView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height + 16, width: kDeviceWidth, height: innerContainerView.frame.size.height)
        
        sendResetButton.layer.cornerRadius = sendResetButton.frame.size.height / 2.0
        sendResetButton.clipsToBounds = true
        sendResetButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
        sendResetButton.isEnabled = false
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
        
        // Tracking
        let trackingGuid = NSUUID().uuidString
        TrackingManager.trackState(featureName: "reset-password", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
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
    }
}
