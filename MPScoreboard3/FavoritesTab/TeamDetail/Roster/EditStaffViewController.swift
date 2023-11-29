//
//  EditStaffViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/5/23.
//

import UIKit
import AVFoundation

protocol EditStaffViewControllerDelegate: AnyObject
{
    func editStaffSaveOrDeleteButtonTouched()
    func editStaffCancelButtonTouched()
}

class EditStaffViewController: UIViewController, UITextFieldDelegate, IQActionSheetPickerViewDelegate
{
    weak var delegate: EditStaffViewControllerDelegate?
    
    var selectedTeam : Team?
    var ssid : String?
    var currentStaff : RosterStaff?
    
    private var kContainerHeight = 612.0
    private var tickTimer: Timer!
    private var teamColor = UIColor.mpRedColor()
    
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    
    @IBOutlet weak var nameContainerView: UIView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var positionContainerView: UIView!
    @IBOutlet weak var positionTextField: UITextField!
    
    @IBOutlet weak var tabBarContainer: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - TextField Delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if (textField == positionTextField)
        {
            let itemArray = ["Head Coach","Assistant Coach","Statistician"]
            
            let picker = IQActionSheetPickerView(title: "Select Position", delegate: self)
            picker.toolbarButtonColor = UIColor.mpDarkGrayColor()
            picker.toolbarTintColor = UIColor.mpGrayButtonBorderColor()
            picker.titlesForComponents = [itemArray]
            picker.tag = 1
            
            // Preload the starting index if possible
            if (positionTextField.text! != "")
            {
                if let startingIndex = itemArray.firstIndex(of: positionTextField.text!)
                {
                    picker.selectIndexes([NSNumber(integerLiteral: startingIndex)], animated: false)
                }
            }
            
            picker.show()
            return false
        }
        else if (textField == emailTextField)
        {
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
    
    // MARK: - Load User Interface
    
    private func loadUserInterface()
    {
        firstNameTextField.text = currentStaff!.userFirstName
        lastNameTextField.text = currentStaff!.userLastName
        emailTextField.text = currentStaff!.userEmail
        positionTextField.text = currentStaff!.position
                
        if (currentStaff!.photoUrl.count > 0)
        {
            let url = URL(string: currentStaff!.photoUrl)
            
            // Get the data and make an image
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        self.userPhotoImageView.image = image
                    }
                }
            }
        }
        
        /*
        // Get the photo from the userId
        if (userId.count > 0)
        {
            LegacyFeeds.getUserImage(userId: userId) { data, error in
                
                if (error == nil)
                {
                    let image = UIImage.init(data: data!)
                    
                    if (image != nil)
                    {
                        self.userPhotoImageView.image = image
                    }
                }
            }
        }
        */
        
    }
    
    // MARK: - Button Methods
    
    @IBAction func cancelButtonTouched(_ sender: UIButton)
    {
        self.delegate?.editStaffCancelButtonTouched()
    }
    
    @IBAction func updateButtonTouched(_ sender: UIButton)
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
        
        /*
        // Check for valid email removed since it can not be edited
        if (FeedsHelper.validateEmail(emailTextField.text!) == false)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Email Problem", message: "You have a malformed email address. Please fix it before sending.", lastItemCancelType: false) { tag in
                
            }
            return
        }
        */
        
        // Call the update staff feed
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        RosterFeeds.updateSecureStaff(schoolId: selectedTeam!.schoolId, ssid: self.ssid!, staffId: (self.currentStaff?.contactId)!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, email: emailTextField.text!, position: positionTextField.text!) { result, error in
            
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
                print("Update Staff Successful")

                OverlayView.showTwoLinePopupOverlay(withMessage: "Success! Your changes may take up to 30 minutes to be reflected on the account.", boldText: "Success!", withDismissHandler: {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                    {
                        self.delegate?.editStaffSaveOrDeleteButtonTouched()
                    }
                })
            }
            else
            {
                print("Update Staff Failed")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to update this staff member.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    @IBAction func deleteButtonTouched(_ sender: UIButton)
    {
        MiscHelper.showAlert(in: self, withActionNames: ["Delete", "Cancel"], title: "Delete Staff", message: "Are you sure you want to delete this staff member?", lastItemCancelType: false) { tag in
            
            if (tag == 0)
            {
                // Call the delete staff feed
                //MBProgressHUD.showAdded(to: self.view, animated: true)
                if (self.progressOverlay == nil)
                {
                    self.progressOverlay = ProgressHUD()
                    self.progressOverlay.show(animated: false)
                }
                
                RosterFeeds.deleteSecureStaff(schoolId: self.selectedTeam!.schoolId, ssid: self.ssid!, staffId: (self.currentStaff?.contactId)!) { success, error in
                    
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
                        print("Delete Staff Success")
                        
                        OverlayView.showPopupOverlay(withMessage: "Staff Deleted")
                        {
                            self.delegate?.editStaffSaveOrDeleteButtonTouched()
                        }
                    }
                    else
                    {
                        print("Delete Staff Failed")
                        
                        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to delete this staff member.", lastItemCancelType: false) { tag in
                            
                        }
                    }
                }
            }
        }
    }

    // MARK: - Check Valid Fields

    @objc private func checkValidFields()
    {
        let firstName = firstNameTextField.text?.trimmingCharacters(in: .whitespaces)
        let lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespaces)

        // Removed the requirement for a coach's email to be present since it must be included in the API and can't be edited.
        if ((firstName!.count > 0) && (lastName!.count > 0) && (positionTextField.text!.count > 0))
        {
            saveButton.isEnabled = true
            saveButton.backgroundColor = teamColor
        }
        else
        {
            saveButton.isEnabled = false
            saveButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
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
        tabBarContainer.frame = CGRect(x: 0, y: Int(kDeviceHeight) - 76 - SharedData.bottomSafeAreaHeight, width: Int(kDeviceWidth), height: 76 + SharedData.bottomSafeAreaHeight)
        containerScrollView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height - 12, width: kDeviceWidth, height: kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height - tabBarContainer.frame.size.height + 12)
        
        containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: kContainerHeight)
        
        navView.layer.cornerRadius = 12
        navView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        navView.clipsToBounds = true

        saveButton.layer.cornerRadius = 8
        saveButton.clipsToBounds = true
        saveButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
        saveButton.isEnabled = false
        
        deleteButton.setTitleColor(teamColor, for: .normal)
        deleteButton.layer.cornerRadius = 8
        deleteButton.layer.borderWidth = 1
        deleteButton.layer.borderColor = teamColor.cgColor
        deleteButton.clipsToBounds = true
        
        userPhotoImageView.layer.cornerRadius = userPhotoImageView.frame.size.width / 2
        userPhotoImageView.clipsToBounds = true
        
        // Add a shadow to the tabBarContainer
        let shadowPath = UIBezierPath(rect: tabBarContainer.bounds)
        tabBarContainer.layer.masksToBounds = false
        tabBarContainer.layer.shadowColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        tabBarContainer.layer.shadowOffset = CGSize(width: 0, height: -3)
        tabBarContainer.layer.shadowOpacity = 0.5
        tabBarContainer.layer.shadowPath = shadowPath.cgPath
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
        
        self.loadUserInterface()
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
