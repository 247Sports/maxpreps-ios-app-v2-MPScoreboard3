//
//  EditStaffUserViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/5/23.
//

import UIKit
import AVFoundation

protocol EditStaffUserViewControllerDelegate: AnyObject
{
    func editStaffUserSaveOrDeleteButtonTouched()
    func editStaffUserDeletePhotoButtonTouched()
    func editStaffUserCancelButtonTouched()
}

class EditStaffUserViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, IQActionSheetPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    weak var delegate: EditStaffUserViewControllerDelegate?
    
    var selectedTeam : Team?
    var ssid : String?
    var currentStaff : RosterStaff?
    
    private var kContainerHeight = 612.0
    private var tickTimer: Timer!
    private var teamColor = UIColor.mpRedColor()
    
    private var photoPicker: UIImagePickerController!
    private var cameraPicker: UIImagePickerController!
    
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    
    @IBOutlet weak var nameContainerView: UIView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var editPhotoImageView: UIImageView!
    
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var positionContainerView: UIView!
    @IBOutlet weak var positionTextField: UITextField!
    
    @IBOutlet weak var bioContainerView: UIView!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var bioTextCountLabel: UILabel!
    
    @IBOutlet weak var twitterContainerView: UIView!
    @IBOutlet weak var twitterTextField: UITextField!
    
    @IBOutlet weak var facebookContainerView: UIView!
    @IBOutlet weak var facebookTextField: UITextField!
    
    @IBOutlet weak var tabBarContainer: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Delete Photo
    
    private func deletePhotoAndFile()
    {
        NewFeeds.deleteUserImage(completionHandler: { (error) in
                       
            if (error == nil)
            {
                print("Delete User Image Success")
                
                self.userPhotoImageView.image = UIImage(named: "Avatar")
                
                // Clear out any photo file that may exist
                do
                {
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileURL = documentsDirectory.appendingPathComponent(kStaffImageTempFileName)
                    
                    try FileManager.default.removeItem(at: fileURL)
                }
                catch let error as NSError
                {
                    print("Delete File Error: \(error.domain)")
                }
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Photo Deleted", message: "It may take 30 minutes for the photo to be removed from the roster.", lastItemCancelType: false) { tag in
                    
                    self.delegate?.editStaffUserDeletePhotoButtonTouched()
                }
                
                /*
                OverlayView.showTwoLinePopupOverlay(withMessage: "Success! It may take 30 minutes for the photo to be removed everywhere.", boldText: "Success!", withDismissHandler: {
                    
                    self.delegate?.editStaffUserDeletePhotoButtonTouched()
                    
                })
                */
            }
            else
            {
                print("Delete User Image Failed")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to delete your photo.", lastItemCancelType: false) { tag in
                    
                }
            }
        })
    }
    
    // MARK: - Choose Photo from Library
    
    private func choosePhotoFromLibrary()
    {
        photoPicker = UIImagePickerController()
        photoPicker?.delegate = self
        photoPicker?.allowsEditing = true
        photoPicker?.sourceType = .photoLibrary
        photoPicker?.modalPresentationStyle = .fullScreen
        
        // Add this on top of everything
        kAppKeyWindow.rootViewController!.present(photoPicker, animated: true)
        {
            
        }
    }
    
    // MARK: - Take Photo from Camera
    
    private func takePhotoFromCamera(useFront: Bool)
    {
        if (UIImagePickerController.isSourceTypeAvailable(.camera))
        {
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            
            if (authStatus == .authorized)
            {
                self.showCameraPicker(useFront: useFront)
            }
            else if (authStatus == .notDetermined)
            {
                // Requst access
                AVCaptureDevice.requestAccess(for: .video) { (granted) in
                    if (granted)
                    {
                        DispatchQueue.main.async
                        {
                            self.showCameraPicker(useFront: useFront)
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async
                        {
                            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This app does not have access to the Camera.\nYou can enable access in the device's Privacy Settings.", lastItemCancelType: false) { (tag) in
                                
                            }
                        }
                    }
                }
            }
            else if (authStatus == .restricted)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "You've been restricted from using the camera on this device. Without camera access this feature won't work. Please contact the device owner so they can give you access.", lastItemCancelType: false) { (tag) in
                    
                }
            }
            else
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This app does not have access to the Camera.\nYou can enable access in the device's Privacy Settings.", lastItemCancelType: false) { (tag) in
                    
                }
            }
        }
        else
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Camera is not available on this device.", lastItemCancelType: false) { (tag) in
                
            }
        }
    }
    
    private func showCameraPicker(useFront: Bool)
    {
        cameraPicker = UIImagePickerController()
        cameraPicker?.delegate = self
        cameraPicker?.allowsEditing = false
        cameraPicker?.sourceType = .camera
        cameraPicker?.showsCameraControls = false
        
        if (useFront == true)
        {
            cameraPicker?.cameraDevice = .front
        }
        else
        {
            cameraPicker?.cameraDevice = .rear
        }
        
        // Shift the camera rect down so it is below the notch and status bar
        cameraPicker?.cameraViewTransform = CGAffineTransform.init(translationX: 0, y: CGFloat(SharedData.topNotchHeight + kStatusBarHeight))
                
        self.addCameraOverlay(cameraPicker!)
        self.cameraPicker?.modalPresentationStyle = .fullScreen
        
        kAppKeyWindow.rootViewController!.present(self.cameraPicker!, animated: true) {
            
        }
    }
    
    private func addCameraOverlay(_ imagePicker : UIImagePickerController)
    {
        let frameWidth = (imagePicker.cameraOverlayView?.frame.size.width)!
        let frameHeight = frameWidth * 1.333
        
        let outlineViewWidth = frameWidth
        let outlineViewHeight = outlineViewWidth
        
        let overlayContainer = UIView(frame: CGRect(x: 0, y: kStatusBarHeight + SharedData.topNotchHeight, width: Int(kDeviceWidth), height: Int(kDeviceHeight) - kStatusBarHeight - SharedData.topNotchHeight - SharedData.bottomSafeAreaHeight))
        overlayContainer.backgroundColor = .clear
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.frame = CGRect(x: 5, y: 5, width: 40, height: 40)
        cancelButton.setImage(UIImage(named: "StopVideo"), for: .normal)
        cancelButton.addTarget(self, action: #selector(self.cancelCameraButtonTouched), for: .touchUpInside)
        overlayContainer.addSubview(cancelButton)
        
        let outlineView = UIView(frame: CGRect(x: (frameWidth - outlineViewWidth) / 2.0, y: (frameHeight - outlineViewHeight) / 2.0, width: outlineViewWidth, height: outlineViewHeight))
        outlineView.backgroundColor = .clear
        outlineView.layer.cornerRadius = frameWidth / 2.0
        outlineView.layer.borderWidth = 2.0
        outlineView.layer.borderColor = UIColor.mpLightGrayColor().cgColor
        outlineView.clipsToBounds = true
        overlayContainer.addSubview(outlineView)
        
        let helperLabel = UILabel(frame: CGRect(x: 30.0, y: frameHeight + 20, width: overlayContainer.frame.size.width - 60, height: 20.0))
        helperLabel.font = .systemFont(ofSize: 13)
        helperLabel.textColor = UIColor.mpLightGrayColor()
        helperLabel.textAlignment = .center
        helperLabel.adjustsFontSizeToFitWidth = true
        helperLabel.minimumScaleFactor = 0.5
        helperLabel.text = "Adjust your camera so the image fills the circle"
        overlayContainer.addSubview(helperLabel)
        
        let takePictureButton = UIButton(type: .custom)
        takePictureButton.frame = CGRect(x: (overlayContainer.frame.size.width - 200) / 2, y: frameHeight + 70, width: 200, height: 40)
        takePictureButton.setTitle("TAKE PICTURE", for: .normal)
        takePictureButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 15)
        takePictureButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        takePictureButton.backgroundColor = UIColor.mpWhiteColor()
        takePictureButton.layer.cornerRadius = 8.0
        takePictureButton.clipsToBounds = true
        takePictureButton.addTarget(self, action: #selector(self.takePictureTouched), for: .touchUpInside)
        overlayContainer.addSubview(takePictureButton)
        
        imagePicker.cameraOverlayView = overlayContainer
    }
    
    @objc private func cancelCameraButtonTouched()
    {
        kAppKeyWindow.rootViewController!.dismiss(animated: true)
        {
            self.cameraPicker = nil
        }
    }
    
    @objc private func takePictureTouched()
    {
        cameraPicker?.takePicture()
    }
    
    // MARK: - Image Picker Delegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        var userImage: UIImage
        
        if (picker == cameraPicker)
        {
            userImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        }
        else
        {
            userImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        }
        
        // Scale the image to 300 x 300 so it can be used elsewhere on the website and still look good.
        let croppedImageWidth = userImage.size.width
        let croppedImageHeight = croppedImageWidth
        
        let croppedImage = ImageHelper.cropImage(userImage, in: CGRect(x: (userImage.size.width - croppedImageWidth) / 2.0, y: (userImage.size.height - croppedImageHeight) / 2.0, width: croppedImageWidth, height: croppedImageHeight))
        
        let scaledImage = ImageHelper.image(with: croppedImage, scaledTo:  CGSize(width: 300, height: 300))
        userPhotoImageView.image = scaledImage
        
        // Save the image to a temp file
        guard let data = scaledImage!.jpegData(compressionQuality: 1.0) else { return }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let fileURL = documentsDirectory.appendingPathComponent(kStaffImageTempFileName)
        
        do
        {
            try data.write(to: fileURL)
            
            let fileManager = FileManager()
            
            if (fileManager.fileExists(atPath: fileURL.path))
            {
                print("Save File Success")
            }
            else
            {
                print("Save File Failed")
            }
        }
        catch
        {
            print("Save File Error", error)
        }
        
        // Close the image picker
        if (picker == cameraPicker)
        {
            kAppKeyWindow.rootViewController!.dismiss(animated: true)
            {
                self.cameraPicker = nil
            }
        }
        else
        {
            kAppKeyWindow.rootViewController!.dismiss(animated: true)
            {
                self.photoPicker = nil
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        kAppKeyWindow.rootViewController!.dismiss(animated: true, completion:{
 
            self.photoPicker = nil;
        })
    }
    
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
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        let badWords = IODProfanityFilter.rangesOfFilteredWords(in: textField.text)
        
        if (badWords!.count > 0)
        {
            MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "Language", message: "The text that you have entered is objectionable and can not be used.", lastItemCancelType: false) { tag in
                
                textField.text = ""
            }
            return
        }
        else
        {
            if (textField.text!.containsEmoji == true)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "You can't use special characters in this field.", lastItemCancelType: false) { tag in
                    
                    textField.text = ""
                }
                return
            }
        }
        
        // Check the facebook textField
        if (textField == facebookTextField)
        {
            if (textField.text!.count > 0)
            {
                if ((((textField.text!.contains("facebook.com") == false) && (textField.text!.contains("fb.com") == false))) ||
                    (textField.text!.isValidUrl == false))
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Bad URL", message: "The facebook URL is not valid. Make sure the URL begins with \"https://\"", lastItemCancelType: false) { tag in
                        
                    }
                    return
                }
            }
        }
        else if (textField == twitterTextField)
        {
            if ((textField.text!.count > 0) && (textField.text!.first != "@"))
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Bad Username", message: "An X username must start with an @.", lastItemCancelType: false) { tag in
                    
                }
                return
            }
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
    
    // MARK: - TextView Delegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        textView.textColor = UIColor.mpBlackColor()
        
        if (textView.text == kCareerProfileBioTextViewDefaultText)
        {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == "")
        {
            textView.text = kCareerProfileBioTextViewDefaultText
            textView.textColor = UIColor.mpLightGrayColor()
        }
        else
        {
            let badWords = IODProfanityFilter.rangesOfFilteredWords(in: bioTextView.text)
            
            if (badWords!.count > 0)
            {
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "Language", message: "The text that you have entered is objectionable and can not be used.", lastItemCancelType: false) { tag in

                    self.bioTextView.text = kCareerProfileBioTextViewDefaultText
                    self.bioTextView.textColor = UIColor.mpLightGrayColor()
                }
                return
            }
            else
            {
                if (bioTextView.text.containsEmoji == true)
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "You can't use special characters in this field.", lastItemCancelType: false) { tag in
                        
                    }
                    return
                }
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if let paste = UIPasteboard.general.string, text == paste
        {
            // Pasteboard
            if ((textView.text.count + text.count) > 500)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Excess Length", message: "The text that you are pasting will exceed the 500 character limit.", lastItemCancelType: false) { tag in
                    
                }
                return false
            }
            return true
        }
        else
        {
            // Normal typing
            if (text == "\n")
            {
                return false
            }
            
            if (range.location > 499)
            {
                return false
            }
            return true
        }
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
        
        // Get the data for the user cells
        NewFeeds.getCoachUserProfile(schoolId: self.selectedTeam!.schoolId, ssid: self.ssid!) { result, error in
            
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
                print("Get Coach User Profile Success")
                                
                let bio = result!["bio"] as? String ?? ""
                
                if (bio.count > 0)
                {
                    self.bioTextView.text = bio
                    self.bioTextView.textColor = UIColor.mpBlackColor()
                }
                else
                {
                    self.bioTextView.text = kUserProfileBioTextViewDefaultText
                    self.bioTextView.textColor = UIColor.mpLightGrayColor()
                }
                
                let facebookProfile = result!["facebookUrl"] as? String ?? ""
                self.facebookTextField.text = facebookProfile
                
                let twitterHandle = result!["twitterHandle"] as? String ?? ""
                self.twitterTextField.text = twitterHandle
            }
        }
        
    }
    
    // MARK: - Update Coach User Profile
    
    private func updateCoachUserProfile()
    {
        NewFeeds.updateCoachUserProfile(bio: bioTextView.text!, faceBookProfile: facebookTextField.text!, twitterHandle: twitterTextField.text!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!) { result, error in
   
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                if (self.progressOverlay != nil)
                {
                    self.progressOverlay.hide(animated: false)
                    self.progressOverlay = nil
                }
            }
            
            if (error == nil)
            {
                print("Update Coach User Profile Success")
                
                OverlayView.showTwoLinePopupOverlay(withMessage: "Success! Your changes may take up to 30 minutes to be reflected on the account.", boldText: "Success!", withDismissHandler: {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                    {
                        self.delegate?.editStaffUserSaveOrDeleteButtonTouched()
                    }
                })
            }
            else
            {
                print("Update Coach User Profile Failed")
                
                let errorMessage = error?.localizedDescription
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: errorMessage, lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func cancelButtonTouched(_ sender: UIButton)
    {
        self.delegate?.editStaffUserCancelButtonTouched()
    }
    
    @IBAction func editPhotoButtonTouched(_ sender: UIButton)
    {
        MiscHelper.showAlert(in: self, withActionNames: ["Photo Library", "Front Camera", "Rear Camera", "Delete Photo", "Cancel"], title: "Select Photo Source", message: kUploadPhotoMessage, lastItemCancelType: false) { (tag) in
            if (tag == 0)
            {
                self.choosePhotoFromLibrary()
            }
            else if (tag == 1)
            {
                self.takePhotoFromCamera(useFront: true)
            }
            else if (tag == 2)
            {
                self.takePhotoFromCamera(useFront: false)
            }
            else if (tag == 3)
            {
                self.deletePhotoAndFile()
            }
        }
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
        
        // Call the update staff feed
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        RosterFeeds.updateSecureStaff(schoolId: selectedTeam!.schoolId, ssid: self.ssid!, staffId: (self.currentStaff?.contactId)!, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, email: emailTextField.text!, position: positionTextField.text!) { result, error in
            
            /*
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                if (self.progressOverlay != nil)
                {
                    self.progressOverlay.hide(animated: false)
                    self.progressOverlay = nil
                }
            }
            */
            
            if (error == nil)
            {
                print("Update Staff Successful")

                let fileManager = FileManager()
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsDirectory.appendingPathComponent(kStaffImageTempFileName)
                
                if (fileManager.fileExists(atPath: fileURL.path))
                {
                    let data = NSData(contentsOf: fileURL)! as Data
                    
                    // Call the feed
                    NewFeeds.saveUserImage(imageData: data) { result, error in
                        
                        if (error == nil)
                        {
                            print("Save User Photo Success")
                            
                            self.updateCoachUserProfile()
                        }
                        else
                        {
                            // Hide the busy indicator
                            DispatchQueue.main.async
                            {
                                if (self.progressOverlay != nil)
                                {
                                    self.progressOverlay.hide(animated: false)
                                    self.progressOverlay = nil
                                }
                            }
                            
                            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to save the photo.", lastItemCancelType: false) { tag in
                            
                            }
                        }
                    }
                }
                else
                {
                    self.updateCoachUserProfile()
                }
            }
            else
            {
                print("Update Staff Failed")
                
                // Hide the busy indicator
                DispatchQueue.main.async
                {
                    if (self.progressOverlay != nil)
                    {
                        self.progressOverlay.hide(animated: false)
                        self.progressOverlay = nil
                    }
                }
                
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
                            self.delegate?.editStaffUserSaveOrDeleteButtonTouched()
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
    
    @objc private func bioDoneButtonTouched()
    {
        bioTextView.resignFirstResponder()
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
        
        // Update the athleteDetailsTextCountLabel
        if (bioTextView.text != kCareerProfileBioTextViewDefaultText)
        {
           bioTextCountLabel.text = String(bioTextView.text!.count) + " / 500 Characters"
        }
        else
        {
            bioTextCountLabel.text = "0 / 500 Characters"
        }
    }
    
    // MARK: - Keyboard Accessory Views
    
    private func addKeyboardAccessoryView()
    {
        let bioAccessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        bioAccessoryView.backgroundColor = UIColor.mpGrayButtonBorderColor()
        
        let doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: kDeviceWidth - 85, y: 6, width: 80, height: 30)
        doneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        doneButton.addTarget(self, action: #selector(bioDoneButtonTouched), for: .touchUpInside)
        bioAccessoryView.addSubview(doneButton)
        bioTextView!.inputAccessoryView = bioAccessoryView
    
    }
    
    // MARK: - Keyboard Notifications
    
    @objc private func keyboardDidShow(notification: Notification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            //print("Keyboard Height: " + String(Int(keyboardSize.size.height)))

            // Need to use the device coordinates for this calculation
            var innerContainerViewBottom = 0
            
            if (bioTextView.isFirstResponder == true)
            {
                innerContainerViewBottom = Int(containerScrollView.frame.origin.y) + Int(bioContainerView.frame.origin.y) + Int(bioContainerView.frame.size.height)
            }
            else if (twitterTextField.isFirstResponder == true)
            {
                innerContainerViewBottom = Int(containerScrollView.frame.origin.y) + Int(twitterContainerView.frame.origin.y) + Int(twitterContainerView.frame.size.height)
            }
            else if (facebookTextField.isFirstResponder == true)
            {
                innerContainerViewBottom = Int(containerScrollView.frame.origin.y) + Int(facebookContainerView.frame.origin.y) + Int(facebookContainerView.frame.size.height)
            }
            
            let keyboardTop = Int(kDeviceHeight) - Int(keyboardSize.size.height)
            
            if (keyboardTop < innerContainerViewBottom)
            {
                let difference = innerContainerViewBottom - keyboardTop
                containerScrollView.contentOffset = CGPoint(x: 0, y: difference)
            }
            
            // Increase the scroll size
            containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: kContainerHeight + keyboardSize.size.height - 110.0)
        }
    }
    
    @objc private func keyboardDidHide(notification: Notification)
    {
        //print("Keyboard will hide")
        
        // Set the scroll size
        containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: kContainerHeight)
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
        
        self.addKeyboardAccessoryView()
        
        // Add the keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
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
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

}
