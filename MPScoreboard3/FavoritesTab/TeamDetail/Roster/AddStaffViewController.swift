//
//  AddStaffViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/1/21.
//

import UIKit

protocol AddStaffViewControllerDelegate: AnyObject
{
    func addStaffSaveButtonTouched()
    func addStaffCancelButtonTouched()
}

class AddStaffViewController: UIViewController, UITextFieldDelegate, IQActionSheetPickerViewDelegate
{
    weak var delegate: AddStaffViewControllerDelegate?
    
    var selectedTeam : Team?
    var ssid : String?
    
    private var tickTimer: Timer!
    private var teamColor = UIColor.mpRedColor()
    
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    
    @IBOutlet weak var nameContainerView: UIView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var positionContainerView: UIView!
    @IBOutlet weak var positionTextField: UITextField!
    
    @IBOutlet weak var tabBarContainer: UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - TextField Delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if (textField == positionTextField)
        {
            let picker = IQActionSheetPickerView(title: "Select Position", delegate: self)
            picker.toolbarButtonColor = UIColor.mpWhiteColor()
            picker.toolbarTintColor = UIColor.mpPickerToolbarColor()
            picker.titlesForComponents = [["Head Coach","Assistant Coach","Statistician"]]
            picker.tag = 1
            picker.show()
            
            return false
        }
        else
        {
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        return true
    }
    
    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelectTitles titles: [String])
    {
        positionTextField.text = titles.first
    }
    
    func actionSheetPickerViewDidCancel(_ pickerView: IQActionSheetPickerView)
    {

    }
    
    // MARK: - Button Methods
    
    @IBAction func cancelButtonTouched(_ sender: UIButton)
    {
        self.delegate?.addStaffCancelButtonTouched()
    }
    
    @IBAction func saveButtonTouched(_ sender: UIButton)
    {
        // Check for bad words
        let badFirstNames = IODProfanityFilter.rangesOfFilteredWords(in: firstNameTextField.text)
        let badLastNames = IODProfanityFilter.rangesOfFilteredWords(in: lastNameTextField.text)
        
        if ((badFirstNames!.count > 0) || (badLastNames!.count > 0))
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Language", message: "The names that you have entered are objectionable and can not be used.", lastItemCancelType: false) { tag in
                
            }
            return
        }
        
        // Check for valid email
        if (FeedsHelper.validateEmail(emailTextField.text!) == false)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Email Problem", message: "You have a malformed email address. Please fix it before sending.", lastItemCancelType: false) { tag in
                
            }
            return
        }
        
        // Call the feed
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        RosterFeeds.addSecureStaff(schoolId: selectedTeam!.schoolId, ssid: self.ssid!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, email: emailTextField.text!, position: positionTextField.text!) { result, error in
            
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
                print("Add Staff Successful")

                OverlayView.showPopupOverlay(withMessage: "Staff Added")
                {
                    self.delegate?.addStaffSaveButtonTouched()
                }
            }
            else
            {
                print("Add Staff Failed")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to save this staff member.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - Check Valid Fields

    @objc private func checkValidFields()
    {
        let firstName = firstNameTextField.text?.trimmingCharacters(in: .whitespaces)
        let lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespaces)

        if ((firstName!.count > 0) && (lastName!.count > 0) && (emailTextField.text!.count > 0) && (positionTextField.text!.count > 0))
        {
            saveButton.isEnabled = true
            saveButton.layer.borderWidth = 0
            saveButton.backgroundColor = teamColor
            saveButton.setTitleColor(UIColor.mpWhiteColor(), for: .normal)
        }
        else
        {
            saveButton.isEnabled = false
            saveButton.layer.borderWidth = 1
            saveButton.backgroundColor = UIColor.mpWhiteColor()
            saveButton.setTitleColor(UIColor.mpLightGrayColor(), for: .normal)
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        fakeStatusBar.backgroundColor = .clear
        
        let hexColorString = self.selectedTeam?.teamColor
        teamColor = ColorHelper.color(fromHexString: hexColorString, colorCorrection: true)!

        // Size the fakeStatusBar, navBar, and containerScrollView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 76 + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        containerScrollView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height - 12, width: kDeviceWidth, height: kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height + 12)
        tabBarContainer.frame = CGRect(x: 0, y: Int(kDeviceHeight) - 66 - SharedData.bottomSafeAreaHeight, width: Int(kDeviceWidth), height: 66 + SharedData.bottomSafeAreaHeight)
        
        navView.layer.cornerRadius = 12
        navView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        navView.clipsToBounds = true

        saveButton.layer.cornerRadius = 8
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = UIColor.mpLightGrayColor().cgColor
        saveButton.clipsToBounds = true
        saveButton.backgroundColor = UIColor.mpWhiteColor()
        saveButton.setTitleColor(UIColor.mpLightGrayColor(), for: .normal)
        saveButton.isEnabled = false
        
        // Add a shadow to the tabBarContainer
        let shadowPath = UIBezierPath(rect: tabBarContainer.bounds)
        tabBarContainer.layer.masksToBounds = false
        tabBarContainer.layer.shadowColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        tabBarContainer.layer.shadowOffset = CGSize(width: 0, height: -3)
        tabBarContainer.layer.shadowOpacity = 0.5
        tabBarContainer.layer.shadowPath = shadowPath.cgPath
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
                
        setNeedsStatusBarAppearanceUpdate()
        
        // Add some delay so the view is partially showing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
        {
            UIView.animate(withDuration: 0.3)
            { [self] in
                fakeStatusBar.backgroundColor = UIColor(white: 0, alpha: 0.6)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

    }

    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.lightContent
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
