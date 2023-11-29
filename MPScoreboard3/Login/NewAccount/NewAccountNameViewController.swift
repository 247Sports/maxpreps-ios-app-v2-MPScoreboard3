//
//  NewAccountNameViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/18/22.
//

import UIKit

class NewAccountNameViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var underlineView1: UIView!
    @IBOutlet weak var underlineView2: UIView!
    @IBOutlet weak var errorMessageLabel1: UILabel!
    @IBOutlet weak var errorMessageLabel2: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    private var tickTimer: Timer!
    
    var isPendingMember = false
    var userEmail = ""
    var userPassword = ""
    
    private var newAccountBirthdateVC: NewAccountBirthdateViewController!
    
    // MARK: - Show Birthdate View Controller
    
    private func showBirthdateViewController()
    {
        if (newAccountBirthdateVC != nil)
        {
            newAccountBirthdateVC = nil
        }
        
        newAccountBirthdateVC = NewAccountBirthdateViewController(nibName: "NewAccountBirthdateViewController", bundle: nil)
        newAccountBirthdateVC.userEmail = self.userEmail
        newAccountBirthdateVC.userPassword = self.userPassword
        newAccountBirthdateVC.userFirstName = firstNameTextField.text!
        newAccountBirthdateVC.userLastName = lastNameTextField.text!
        newAccountBirthdateVC.isPendingMember = self.isPendingMember
        
        self.navigationController?.pushViewController(newAccountBirthdateVC, animated: true)
    }
    
    // MARK: - TextField Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if (textField == firstNameTextField)
        {
            if ((firstNameTextField.text!.containsEmoji == true) && (lastNameTextField.text!.containsEmoji == false))
            {
                self.showErrorMessage1("Special characters are not allowed.")
                return true
            }
            else if ((firstNameTextField.text!.containsEmoji == false) && (lastNameTextField.text!.containsEmoji == true))
            {
                self.showErrorMessage2("Special characters are not allowed.")
                return true
            }
            else if ((firstNameTextField.text!.containsEmoji == true) && (lastNameTextField.text!.containsEmoji == true))
            {
                self.showErrorMessage1("Special characters are not allowed.")
                self.showErrorMessage2("Special characters are not allowed.")
                return true
            }
            else
            {
                lastNameTextField.becomeFirstResponder()
                return true
            }
        }
        else
        {
            if ((firstNameTextField.text!.containsEmoji == true) && (lastNameTextField.text!.containsEmoji == false))
            {
                self.showErrorMessage1("Special characters are not allowed.")
                return true
            }
            
            if ((firstNameTextField.text!.containsEmoji == false) && (lastNameTextField.text!.containsEmoji == true))
            {
                self.showErrorMessage2("Special characters are not allowed.")
                return true
            }
            
            if ((firstNameTextField.text!.containsEmoji == true) && (lastNameTextField.text!.containsEmoji == true))
            {
                self.showErrorMessage1("Special characters are not allowed.")
                self.showErrorMessage2("Special characters are not allowed.")
                return true
            }
            
            // Check for bad words
            let badFirstNames = IODProfanityFilter.rangesOfFilteredWords(in: firstNameTextField.text!)
            let badLastNames = IODProfanityFilter.rangesOfFilteredWords(in: lastNameTextField.text!)
            
            if (badFirstNames!.count > 0)
            {
                self.showErrorMessage1("Offensive language.")
            }
            
            if (badLastNames!.count > 0)
            {
                self.showErrorMessage2("Offensive language.")
            }
            
            if (badFirstNames!.count == 0) && (badLastNames!.count == 0)
            {
                self.showBirthdateViewController()
            }
            
            return true
        }
    }
    
    // MARK: - Show Error Messages
    
    private func showErrorMessage1(_ message: String)
    {
        errorMessageLabel1.text = message
        errorMessageLabel1.alpha = 1.0
        underlineView1.backgroundColor = UIColor.mpRedColor()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5)
        {
            UIView.animate(withDuration: 0.25, animations: {
                
                self.errorMessageLabel1.alpha = 0.0
                self.underlineView1.backgroundColor = UIColor.mpGrayButtonBorderColor()
            })
            { (finished) in
                
                self.errorMessageLabel1.text = ""
            } 
        }
    }
    
    private func showErrorMessage2(_ message: String)
    {
        errorMessageLabel2.text = message
        errorMessageLabel2.alpha = 1.0
        underlineView2.backgroundColor = UIColor.mpRedColor()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5)
        {
            UIView.animate(withDuration: 0.25, animations: {
                
                self.errorMessageLabel2.alpha = 0.0
                self.underlineView2.backgroundColor = UIColor.mpGrayButtonBorderColor()
            })
            { (finished) in
                
                self.errorMessageLabel2.text = ""
            }
        }
    }
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        if ((firstNameTextField.text!.count > 0) && (lastNameTextField.text!.count > 0))
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
        if ((firstNameTextField.text!.containsEmoji == true) && (lastNameTextField.text!.containsEmoji == false))
        {
            self.showErrorMessage1("Special characters are not allowed.")
            return
        }
        
        if ((firstNameTextField.text!.containsEmoji == false) && (lastNameTextField.text!.containsEmoji == true))
        {
            self.showErrorMessage2("Special characters are not allowed.")
            return
        }
        
        if ((firstNameTextField.text!.containsEmoji == true) && (lastNameTextField.text!.containsEmoji == true))
        {
            self.showErrorMessage1("Special characters are not allowed.")
            self.showErrorMessage2("Special characters are not allowed.")
            return
        }
        
        // Check for bad words
        let badFirstNames = IODProfanityFilter.rangesOfFilteredWords(in: firstNameTextField.text!)
        let badLastNames = IODProfanityFilter.rangesOfFilteredWords(in: lastNameTextField.text!)
        
        if (badFirstNames!.count > 0)
        {
            self.showErrorMessage1("Offensive language.")
        }
        
        if (badLastNames!.count > 0)
        {
            self.showErrorMessage2("Offensive language.")
        }
        
        if (badFirstNames!.count == 0) && (badLastNames!.count == 0)
        {
            self.showBirthdateViewController()
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
                
        nextButton.layer.cornerRadius = nextButton.frame.size.height / 2.0
        nextButton.clipsToBounds = true
        nextButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
        nextButton.isEnabled = false
        
        errorMessageLabel1.text = ""
        errorMessageLabel1.alpha = 0.0
        
        errorMessageLabel2.text = ""
        errorMessageLabel2.alpha = 0.0
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
        
        // Add the keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Tracking
        let trackingGuid = NSUUID().uuidString
        TrackingManager.trackState(featureName: "name", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        firstNameTextField.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (newAccountBirthdateVC != nil)
        {
            newAccountBirthdateVC = nil
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
