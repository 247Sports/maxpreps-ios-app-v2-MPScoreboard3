//
//  NewAccountGenderViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/21/22.
//

import UIKit

class NewAccountGenderViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
        
    var isPendingMember = false
    var userEmail = ""
    var userPassword = ""
    var userFirstName = ""
    var userLastName = ""
    var userBirthdate = ""
    
    private var tickTimer: Timer!
    
    private var kGenderValues = ["Select Gender", "Male", "Female", "Prefer not to say", "Other"]
    private var genderAliasDictionary = ["Male": "Male", "Female": "Female", "Prefer not to say": "PreferNotToSay", "Other": "Other"]
    private var currentPickerIndex = 0
    
    private var newAccountZipcodeVC: NewAccountZipcodeViewController!
    
    // MARK: - Show Zipcode View Controller
    
    private func showZipcodeViewController(genderAlias: String)
    {
        if (newAccountZipcodeVC != nil)
        {
            newAccountZipcodeVC = nil
        }
        
        newAccountZipcodeVC = NewAccountZipcodeViewController(nibName: "NewAccountZipcodeViewController", bundle: nil)
        newAccountZipcodeVC.userEmail = self.userEmail
        newAccountZipcodeVC.userPassword = self.userPassword
        newAccountZipcodeVC.userFirstName = self.userFirstName
        newAccountZipcodeVC.userLastName = self.userLastName
        newAccountZipcodeVC.userBirthdate = self.userBirthdate
        newAccountZipcodeVC.userGenderAlias = genderAlias
        newAccountZipcodeVC.isPendingMember = self.isPendingMember
        
        self.navigationController?.pushViewController(newAccountZipcodeVC, animated: true)
    }
    
    // MARK: - TextField Delegate
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        return false
    }
    
    // MARK: - Picker View Delegates
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat
    {
        return 36
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return kGenderValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return kGenderValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if (row == 0)
        {
            genderTextField.text = ""
            return
        }
        
        currentPickerIndex = row
        genderTextField.text = kGenderValues[row]
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
        if (genderTextField.text!.count > 0)
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
        let genderAlias = genderAliasDictionary[genderTextField.text!]
        
        self.showZipcodeViewController(genderAlias: genderAlias!)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
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
        nextButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
        nextButton.isEnabled = false
        
        errorMessageLabel.text = ""
        errorMessageLabel.alpha = 0.0
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
        
        // Tracking
        let trackingGuid = NSUUID().uuidString
        TrackingManager.trackState(featureName: "gender", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (newAccountZipcodeVC != nil)
        {
            newAccountZipcodeVC = nil
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
    }

}
