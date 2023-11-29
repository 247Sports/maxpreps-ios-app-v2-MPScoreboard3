//
//  NewAccountZipcodeViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/21/22.
//

import UIKit

class NewAccountZipcodeViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var zipcodeTextField: UITextField!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
        
    var isPendingMember = false
    var userEmail = ""
    var userPassword = ""
    var userFirstName = ""
    var userLastName = ""
    var userBirthdate = ""
    var userGenderAlias = ""
    
    private var tickTimer: Timer!
    
    private var newAccountRoleVC: NewAccountRoleViewController!
    
    // MARK: - Show Role View Controller
    
    private func showRoleViewController()
    {
        if (newAccountRoleVC != nil)
        {
            newAccountRoleVC = nil
        }
        
        newAccountRoleVC = NewAccountRoleViewController(nibName: "NewAccountRoleViewController", bundle: nil)
        newAccountRoleVC.userEmail = self.userEmail
        newAccountRoleVC.userPassword = self.userPassword
        newAccountRoleVC.userFirstName = self.userFirstName
        newAccountRoleVC.userLastName = self.userLastName
        newAccountRoleVC.userBirthdate = self.userBirthdate
        newAccountRoleVC.userGenderAlias = self.userGenderAlias
        newAccountRoleVC.userZipcode = zipcodeTextField.text!
        newAccountRoleVC.isPendingMember = self.isPendingMember
        
        self.navigationController?.pushViewController(newAccountRoleVC, animated: true)
    }
    
    // MARK: - TextField Delegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
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
        if (zipcodeTextField.text!.count > 4)
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
        NewFeeds.validateZipcode(zipcode: zipcodeTextField.text!) { error in
            
            if (error == nil)
            {
                self.showRoleViewController()
            }
            else
            {
                self.showErrorMessage("Please enter a valid zip code")
            }
        }
        
        /*
        let state = ZipCodeHelper.state(forZipCode: zipcodeTextField.text!)
        
        if (state == "")
        {
            self.showErrorMessage("Please enter a valid zip code")
        }
        else
        {
            self.showRoleViewController()
        }
        */
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
        TrackingManager.trackState(featureName: "zip-code", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        zipcodeTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
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
