//
//  NewAccountBirthdateViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/21/22.
//

import UIKit

class NewAccountBirthdateViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var birthdateTextField: UITextField!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var clearButton: UIButton!
        
    var isPendingMember = false
    var userEmail = ""
    var userPassword = ""
    var userFirstName = ""
    var userLastName = ""
    
    private var newAccountGenderVC: NewAccountGenderViewController!
    
    // MARK: - Show Gender View Controller
    
    private func showGenderViewController(birthdate: String)
    {
        if (newAccountGenderVC != nil)
        {
            newAccountGenderVC = nil
        }
        
        newAccountGenderVC = NewAccountGenderViewController(nibName: "NewAccountGenderViewController", bundle: nil)
        newAccountGenderVC.userEmail = self.userEmail
        newAccountGenderVC.userPassword = self.userPassword
        newAccountGenderVC.userFirstName = self.userFirstName
        newAccountGenderVC.userLastName = self.userLastName
        newAccountGenderVC.userBirthdate = birthdate
        newAccountGenderVC.isPendingMember = self.isPendingMember
        
        self.navigationController?.pushViewController(newAccountGenderVC, animated: true)
    }
    
    // MARK: - TextField Delegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        return false
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
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextButtonTouched(_ sender: UIButton)
    {        
        if (birthdateTextField.text!.count > 0)
        {
            self.showGenderViewController(birthdate: birthdateTextField.text!)
        }
        else
        {
            self.showErrorMessage("You must be at least 13 years old to register with MaxPreps.")
            
            MiscHelper.showAlert(in: self, withActionNames: ["Cancel", "Yes"], title: "Verify Your Age", message: "I acknowledge that I am at least 13 years old to become a MaxPreps member.", lastItemCancelType: false) { (tag) in
                
                if (tag == 1)
                {
                    self.showGenderViewController(birthdate: "")
                }
            }
        }
    }
    
    @IBAction func clearButtonTouched(_ sender: UIButton)
    {
        birthdateTextField.text = ""
        clearButton.isHidden = true
    }
    
    @IBAction func datePickerValueChanged()
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy"
        
        birthdateTextField.text = dateFormatter.string(from: datePicker.date)
        clearButton.isHidden = false
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        print("Bottom Safe Area: " + String(SharedData.bottomSafeAreaHeight))
        
        // Size the fakeStatusBar, navBar, and innerContainer
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        //pickerContainerView.frame = CGRect(x: 0, y: kDeviceHeight - CGFloat(SharedData.bottomSafeAreaHeight) - 257, width: kDeviceWidth, height: CGFloat(SharedData.bottomSafeAreaHeight) + 257)
        pickerContainerView.frame = CGRect(x: 0, y: kDeviceHeight - CGFloat(SharedData.bottomSafeAreaHeight) - 216, width: kDeviceWidth, height: CGFloat(SharedData.bottomSafeAreaHeight) + 216)
        
        // Set the inner container height
        //let innerContainerHeight = kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight) - 260.0
        let innerContainerHeight = kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight) - 216.0
        
        innerContainerView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: innerContainerHeight)
                
        nextButton.layer.cornerRadius = nextButton.frame.size.height / 2.0
        nextButton.clipsToBounds = true
        //nextButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
        //nextButton.isEnabled = false
        
        clearButton.isHidden = true
        
        errorMessageLabel.text = ""
        errorMessageLabel.alpha = 0.0
        
        // Set the maximum date to thirteen years old.
        let thirteenYearsAgo = Date().addingTimeInterval(-13 * 365.25 * 24 * 60 * 60)
        
        // Set the minimum date to 100 years ago minus a day
        let oneHunderdYearsAgo = Date().addingTimeInterval((-100 * 365.25 * 24 * 60 * 60) + (24 * 60 * 60))
        
        datePicker.minimumDate = oneHunderdYearsAgo
        datePicker.maximumDate = thirteenYearsAgo
        
        // Tracking
        let trackingGuid = NSUUID().uuidString
        TrackingManager.trackState(featureName: "birthday", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (newAccountGenderVC != nil)
        {
            newAccountGenderVC = nil
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

}
