//
//  EditAthleteViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/1/21.
//

import UIKit
import AVFoundation

protocol EditAthleteViewControllerDelegate: AnyObject
{
    func editAthleteSaveOrDeleteButtonTouched()
    func editAthleteCancelButtonTouched()
}

class EditAthleteViewController: UIViewController, UITextFieldDelegate, IQActionSheetPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    weak var delegate: EditAthleteViewControllerDelegate?
    
    var selectedTeam : Team?
    var ssid : String?
    var currentAthlete : RosterAthlete?
    
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    
    @IBOutlet weak var nameContainerView: UIView!
    @IBOutlet weak var athletePhotoImageView: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var gradeContainerView: UIView!
    @IBOutlet weak var gradeTextField: UITextField!
    
    @IBOutlet weak var jerseyContainerView: UIView!
    @IBOutlet weak var jerseyTextField: UITextField!
    
    @IBOutlet weak var heightContainerView: UIView!
    @IBOutlet weak var heightTextField: UITextField!
    
    @IBOutlet weak var weightContainerView: UIView!
    @IBOutlet weak var weightTextField: UITextField!
    
    @IBOutlet weak var genderContainerView: UIView!
    @IBOutlet weak var genderTextField: UITextField!
    
    @IBOutlet weak var weightClassContainerView: UIView!
    @IBOutlet weak var weightClassTextField: UITextField!
    
    @IBOutlet weak var positionsContainerView: UIView!
    @IBOutlet weak var positionsTextField: UITextField!
    @IBOutlet weak var positionsLabel: UILabel!
    
    @IBOutlet weak var captainContainerView: UIView!
    @IBOutlet weak var captainButton: UIButton!
    
    @IBOutlet weak var tabBarContainer: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    private var isCaptain = false
    private var tickTimer: Timer!
    private var positions = [""]
    private var scrollViewInitialHeight = 0
    private var currentSport = ""
    private var currentGender = ""
    private var teamColor = UIColor.mpRedColor()
    
    private var photoPicker: UIImagePickerController!
    private var cameraPicker: UIImagePickerController!
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Update Athlete
    
    private func updateAthlete()
    {
        // Create the positions string
        var positionsString = ""
        
        if (positions.count == 1)
        {
            positionsString = positions[0]
        }
        else if (positions.count == 2)
        {
            positionsString = positions[0] + "," + positions[1]
        }
        else if (positions.count == 3)
        {
            positionsString = positions[0] + "," + positions[1] + "," + positions[2]
        }
        
        // Create the grade string
        var gradeString = ""
        
        if (gradeTextField.text == "5th")
        {
            gradeString = "5"
        }
        else if (gradeTextField.text == "6th")
        {
            gradeString = "6"
        }
        else if (gradeTextField.text == "7th")
        {
            gradeString = "7"
        }
        else if (gradeTextField.text == "8th")
        {
            gradeString = "8"
        }
        else if (gradeTextField.text == "Fr")
        {
            gradeString = "9"
        }
        else if (gradeTextField.text == "So")
        {
            gradeString = "10"
        }
        else if (gradeTextField.text == "Jr")
        {
            gradeString = "11"
        }
        else if (gradeTextField.text == "Sr")
        {
            gradeString = "12"
        }
        
        // Some of the feed properties vary with sport
        var weightClassString = ""
        var weightString = ""
        
        if (currentSport == "Wrestling")
        {
            // There are no positions or weight in wrestling
            weightClassString = (weightClassTextField.text?.replacingOccurrences(of: " lbs.", with: ""))!
            positionsString = ""
        }
        else if ((currentSport == "Golf") || (currentSport == "Tennis"))
        {
            // There is no weightClass in golf or tennis
            weightString = (weightTextField.text?.replacingOccurrences(of: " lbs.", with: ""))!
        }
        else
        {
            // There is no weightClass in the other sports
            weightString = (weightTextField.text?.replacingOccurrences(of: " lbs.", with: ""))!
        }
        
        // Create feet and inches from the height String
        var heightFeetString = ""
        var heightInchesString = ""
        
        if (heightTextField.text!.count > 0)
        {
            let heightArray = heightTextField.text?.components(separatedBy: " ")
            
            if (heightArray?.count == 2)
            {
                heightFeetString = heightArray![0].replacingOccurrences(of: "'", with: "")
                heightInchesString = heightArray![1].replacingOccurrences(of: "\"", with: "")
            }
        }
        
        // Call the feed
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        RosterFeeds.updateSecureAthlete(athleteId: currentAthlete!.athleteId, firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, classYear: gradeString, jersey: jerseyTextField.text!, heightFeet: heightFeetString, heightInches: heightInchesString, weight: weightString, weightClass: weightClassString, positions: positionsString, gender: genderTextField.text!, isCaptain: isCaptain, bio: "") { result, error in
            
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
                print("Update Athlete Success")
                
                // Get the athleteId from the response
                if let athleteId = result!["athleteId"] as? String
                {                    
                    // Call the save photo feed
                    print("AthleteId = " + athleteId)
                    
                    // Save the athlete photo if it exists
                    let fileManager = FileManager()
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let fileURL = documentsDirectory.appendingPathComponent(kAthleteImageTempFileName)
                    
                    if (fileManager.fileExists(atPath: fileURL.path))
                    {
                        let data = NSData(contentsOf: fileURL)! as Data
                        
                        RosterFeeds.addAthletePhoto(schoolId: self.selectedTeam!.schoolId, ssid: self.ssid!, athleteId: athleteId, imageData: data) { result, error in
                            
                            if (error == nil)
                            {
                                print("Save Athlete Photo Success")
                                
                                OverlayView.showPopupOverlay(withMessage: "Athlete Updated")
                                {
                                    self.delegate?.editAthleteSaveOrDeleteButtonTouched()
                                }
                            }
                            else
                            {
                                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to save the athlete photo.", lastItemCancelType: false) { tag in
                                    
                                }
                            }
                        }
                    }
                    else
                    {
                        OverlayView.showPopupOverlay(withMessage: "Athlete Updated")
                        {
                            self.delegate?.editAthleteSaveOrDeleteButtonTouched()
                        }
                    }
                }
                else
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "AthleteId was not returned.", lastItemCancelType: false) { tag in
                        
                    }
                }
            }
            else
            {
                print("Update Athlete Failed")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to update this athlete.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - Delete Photo
    
    private func deletePhotoAndFile(updateServer: Bool)
    {
        athletePhotoImageView.image = UIImage(named: "Avatar")
        
        // Clear out any photo file that may exist
        do
        {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(kAthleteImageTempFileName)
            
            try FileManager.default.removeItem(at: fileURL)
            
            if (updateServer == true)
            {
                // Call the delete photo feed
                //MBProgressHUD.showAdded(to: self.view, animated: true)
                if (progressOverlay == nil)
                {
                    progressOverlay = ProgressHUD()
                    progressOverlay.show(animated: false)
                }
                
                RosterFeeds.deleteAthletePhoto(schoolId: selectedTeam!.schoolId, ssid: self.ssid!, athleteId: currentAthlete!.athleteId) { result, error in
                    
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
                    
                    if (error) == nil
                    {
                        print("Delete Athlete Photo Success")
                        OverlayView.showPopupOverlay(withMessage: "Photo Removed")
                        {
                            
                        }
                    }
                    else
                    {
                        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to delete the athlete's photo from the server.", lastItemCancelType: false) { tag in
                            
                        }
                    }
                }
            }
            
        }
        catch let error as NSError
        {
            print("Delete File Error: \(error.domain)")
        }
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
        athletePhotoImageView.image = scaledImage
        
        // Save the image to a temp file
        guard let data = scaledImage!.jpegData(compressionQuality: 1.0) else { return }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let fileURL = documentsDirectory.appendingPathComponent(kAthleteImageTempFileName)
        
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
        if (textField == gradeTextField)
        {
            let picker = IQActionSheetPickerView(title: "Select Year", delegate: self)
            picker.toolbarButtonColor = UIColor.mpWhiteColor()
            picker.toolbarTintColor = UIColor.mpPickerToolbarColor()
            picker.titlesForComponents = [["5th","6th","7th","8th","Fr","So","Jr","Sr"]]
            picker.tag = 1
            picker.show()
            
            return false
        }
        else if (textField == genderTextField)
        {
            let picker = IQActionSheetPickerView(title: "Select Gender", delegate: self)
            picker.toolbarButtonColor = UIColor.mpWhiteColor()
            picker.toolbarTintColor = UIColor.mpPickerToolbarColor()
            picker.titlesForComponents = [["Male","Female"]]
            picker.tag = 2
            picker.show()
            
            return false
        }
        else if (textField == heightTextField)
        {
            let picker = IQActionSheetPickerView(title: "Select Height", delegate: self)
            picker.toolbarButtonColor = UIColor.mpWhiteColor()
            picker.toolbarTintColor = UIColor.mpPickerToolbarColor()
            picker.titlesForComponents = [["--","4'","5'","6'","7'"],["0\"","1\"","2\"","3\"","4\"","5\"","6 \"","7\"","8\"","9\"", "10\"","11\""]]
            picker.tag = 3
            picker.show()
            
            return false
        }
        else if (textField == weightClassTextField)
        {
            if (genderTextField.text == "")
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Missing Gender", message: "You need to select the gender before choosing a weight class.", lastItemCancelType: false) { tag in
                    
                }
                
                return false
            }
            
            let picker = IQActionSheetPickerView(title: "Select Height", delegate: self)
            picker.toolbarButtonColor = UIColor.mpWhiteColor()
            picker.toolbarTintColor = UIColor.mpPickerToolbarColor()
            picker.tag = 4
            picker.titlesForComponents = [MiscHelper.weightClassForGender(genderTextField.text!)]
      
            picker.show()
            
            return false
        }
        else if (textField == positionsTextField)
        {
            let picker = IQActionSheetPickerView(title: "Select Position", delegate: self)
            picker.toolbarButtonColor = UIColor.mpWhiteColor()
            picker.toolbarTintColor = UIColor.mpPickerToolbarColor()
            picker.tag = 5
            
            let positions = MiscHelper.positionsForSport(currentSport)
            
            // Golf and Tennis have only one item
            if ((currentSport == "Golf") || (currentSport == "Tennis"))
            {
                picker.titlesForComponents = [positions]
            }
            else
            {
                picker.titlesForComponents = [positions, positions, positions]
            }
            picker.show()
            
            // Shift the container up a bit so the textField can be seen
            let positionsContainerLocation = Int(containerScrollView.frame.origin.y) + Int(positionsContainerView.frame.origin.y) + 30
            let pickerHeight = 300 + SharedData.bottomSafeAreaHeight
            let difference = Int(kDeviceHeight) - pickerHeight
            
            if (positionsContainerLocation > difference)
            {
                let shift = positionsContainerLocation - difference
                containerScrollView.contentOffset = CGPoint(x: 0, y: shift)
            }
            
            return false
        }
        else
        {
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if (textField == weightTextField)
        {
            weightTextField.text = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        // Append lbs. to the value
        if (textField == weightTextField)
        {
            if (weightTextField.text!.count > 0)
            {
                weightTextField.text = weightTextField.text! + " lbs."
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
        // Only allow up to 3 characters
        if ((textField == jerseyTextField) || (textField == weightTextField))
        {
            if (range.location > 2)
            {
                return false
            }
            else
            {
                return true
            }
        }
        
        return true
    }
    
    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelectTitles titles: [String])
    {
        switch pickerView.tag
        {
        case 1: // Grade
            gradeTextField.text = titles.first
            break
            
        case 2: // Gender
            if (titles.first == "--")
            {
                genderTextField.text = ""
            }
            else
            {
                genderTextField.text = titles.first
            }
            break
            
        case 3: // Height
            if (titles.first == "--")
            {
                heightTextField.text = ""
            }
            else
            {
                heightTextField.text = titles.first! + " " + titles.last!
            }
            break
            
        case 4: // Weight Class
            if (titles.first == "--")
            {
                weightClassTextField.text = ""
            }
            else
            {
                weightClassTextField.text = titles.first
            }
            break
            
        case 5: // Positions
            
            containerScrollView.contentOffset = CGPoint(x: 0, y: 0)
            
            if (titles.count == 3)
            {
                let position1 = titles[0]
                let position2 = titles[1]
                let position3 = titles[2]
                
                positions.removeAll()
                
                if (position1 != "--")
                {
                    positions.append(position1)
                }
                
                if (position2 != "--")
                {
                    positions.append(position2)
                }
                
                if (position3 != "--")
                {
                    positions.append(position3)
                }
                
                if (positions.count == 0)
                {
                    positionsTextField.text = ""
                }
                else if (positions.count == 1)
                {
                    positionsTextField.text = positions.first
                }
                else if (positions.count == 2)
                {
                    positionsTextField.text = positions.first! + ", " + positions.last!
                }
                else
                {
                    positionsTextField.text = positions[0] + ", " + positions[1] + ", " + positions[2]
                }
            }
            else // Golf and Tennis only have one component
            {
                let position1 = titles[0]
                
                positions.removeAll()
                
                if (position1 != "--")
                {
                    positions.append(position1)
                }
                
                if (positions.count == 0)
                {
                    positionsTextField.text = ""
                }
                else
                {
                    positionsTextField.text = positions.first
                }
            }
            break
            
        default:
            break
        }
        
    }
    
    func actionSheetPickerViewDidCancel(_ pickerView: IQActionSheetPickerView)
    {
        if (pickerView.tag == 5)
        {
            containerScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func cancelButtonTouched(_ sender: UIButton)
    {
        self.delegate?.editAthleteCancelButtonTouched()
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
                self.deletePhotoAndFile(updateServer: true)
            }
        }
    }
    
    @IBAction func captainButtonTouched(_ sender: UIButton)
    {
        isCaptain = !isCaptain
        
        if (isCaptain == true)
        {
            captainButton.setImage(UIImage(named: "CheckBoxBlue"), for: .normal)
        }
        else
        {
            captainButton.setImage(UIImage(named: "CheckBoxOff"), for: .normal)
        }
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
        
        // Check for a weight that is out of bounds
        if (weightTextField.text!.count > 0)
        {
            let weightString = (weightTextField.text?.replacingOccurrences(of: " lbs.", with: ""))!
            let weightNumber = Int(weightString)
            if (weightNumber! > 400) || (weightNumber! < 80)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Weight Error", message: "The entered weight must be from 80 to 400 lbs.", lastItemCancelType: false) { tag in
                    
                }
                return
            }
        }
        
        self.updateAthlete()
    }
    
    @IBAction func deleteButtonTouched(_ sender: UIButton)
    {
        MiscHelper.showAlert(in: self, withActionNames: ["Delete", "Cancel"], title: "Delete Athlete", message: "Are you sure you want to delete this athlete from the roster?", lastItemCancelType: false) { (tag) in
            if (tag == 0)
            {
                // Call the feed
                //MBProgressHUD.showAdded(to: self.view, animated: true)
                if (self.progressOverlay == nil)
                {
                    self.progressOverlay = ProgressHUD()
                    self.progressOverlay.show(animated: false)
                }
                
                RosterFeeds.deleteSecureAthlete(schoolId: self.selectedTeam!.schoolId, ssid: self.ssid!, athleteId: self.currentAthlete!.athleteId) { result, error in
                    
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
                        print("Delete Athlete Success")
                        
                        OverlayView.showPopupOverlay(withMessage: "Athlete Deleted")
                        {
                            self.delegate?.editAthleteSaveOrDeleteButtonTouched()
                        }
                    }
                    else
                    {
                        print("Delete Athlete Failed")
                        
                        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to delete this athlete.", lastItemCancelType: false) { tag in
                            
                        }
                    }
                }
            }
        }
    }
    
    @objc private func jerseyDoneButtonTouched()
    {
        jerseyTextField.resignFirstResponder()
    }
    
    @objc private func weightDoneButtonTouched()
    {
        weightTextField.resignFirstResponder()
    }
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        let firstName = firstNameTextField.text?.trimmingCharacters(in: .whitespaces)
        let lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespaces)
        
        // Require the gender for wrestling
        if (currentSport == "Wrestling")
        {
            if ((firstName!.count > 0) && (lastName!.count > 0) && (gradeTextField.text!.count > 0) && (genderTextField.text!.count > 0))
            {
                saveButton.backgroundColor = teamColor
                saveButton.isEnabled = true
            }
            else
            {
                saveButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
                saveButton.isEnabled = false
            }
        }
        else
        {
            if ((firstName!.count > 0) && (lastName!.count > 0) && (gradeTextField.text!.count > 0))
            {
                saveButton.backgroundColor = teamColor
                saveButton.isEnabled = true
            }
            else
            {
                saveButton.backgroundColor = UIColor.mpGrayButtonBorderColor()
                saveButton.isEnabled = false
            }
        }
    }
    
    // MARK: - Load User Interface
    
    private func loadUserInterface()
    {
        // Adjust the positions title label to reflect the sport
        if ((currentSport == "Golf") || (currentSport == "Tennis"))
        {
            positionsLabel.text = "R/L Handed"
        }
        else if ((currentSport == "Track & Field") || (currentSport == "Swimming"))
        {
            positionsLabel.text = "Specialty"
        }

        let topContentHeight = Int(nameContainerView.frame.size.height) + Int(jerseyContainerView.frame.size.height) + Int(gradeContainerView.frame.size.height) + Int(heightContainerView.frame.size.height)
        
        var bottomContentHeight = 0

        if (currentSport == "Wrestling")
        {
            weightContainerView.isHidden = true
            
            // Move the weightClass, positions, and captain containers after the gender container
            weightClassContainerView.frame = CGRect(x: 0.0, y: genderContainerView.frame.origin.y + genderContainerView.frame.size.height, width: weightClassContainerView.frame.size.width, height: weightClassContainerView.frame.size.height)
            
            positionsContainerView.frame = CGRect(x: 0.0, y: weightClassContainerView.frame.origin.y + weightClassContainerView.frame.size.height, width: positionsContainerView.frame.size.width, height: positionsContainerView.frame.size.height)
            
            captainContainerView.frame = CGRect(x: 0.0, y: positionsContainerView.frame.origin.y + positionsContainerView.frame.size.height, width: captainContainerView.frame.size.width, height: captainContainerView.frame.size.height)
            
            bottomContentHeight = Int(genderContainerView.frame.size.height) + Int(weightClassContainerView.frame.size.height) + Int(positionsContainerView.frame.size.height) + Int(captainContainerView.frame.size.height)
        }
        else
        {
            // Hide the weightClassContainer and genderContainer
            weightClassContainerView.isHidden = true
            genderContainerView.isHidden = true
            
            if (currentGender == "Girls")
            {
                // Hide the weight container and move the positions and captain containers up
                weightContainerView.isHidden = true
                
                positionsContainerView.frame = CGRect(x: 0.0, y: heightContainerView.frame.origin.y + heightContainerView.frame.size.height, width: positionsContainerView.frame.size.width, height: positionsContainerView.frame.size.height)
                
                captainContainerView.frame = CGRect(x: 0.0, y: positionsContainerView.frame.origin.y + positionsContainerView.frame.size.height, width: captainContainerView.frame.size.width, height: captainContainerView.frame.size.height)
                
                bottomContentHeight = Int(positionsContainerView.frame.size.height) + Int(captainContainerView.frame.size.height)
            }
            else
            {
                positionsContainerView.frame = CGRect(x: 0.0, y: weightContainerView.frame.origin.y + weightContainerView.frame.size.height, width: positionsContainerView.frame.size.width, height: positionsContainerView.frame.size.height)
                
                captainContainerView.frame = CGRect(x: 0.0, y: positionsContainerView.frame.origin.y + positionsContainerView.frame.size.height, width: captainContainerView.frame.size.width, height: captainContainerView.frame.size.height)
                
                bottomContentHeight = Int(weightContainerView.frame.size.height) + Int(positionsContainerView.frame.size.height) + Int(captainContainerView.frame.size.height)
            }
        }
        
        // Check to see if the positions container should be hidden. This MiscHelper method returns an array with one element if no posiitons exist.
        let positionsArray = MiscHelper.positionsForSport(currentSport)
        
        if (positionsArray.count == 1)
        {
            positionsContainerView.isHidden = true
            
            captainContainerView.frame = CGRect(x: 0.0, y: positionsContainerView.frame.origin.y, width: captainContainerView.frame.size.width, height: captainContainerView.frame.size.height)
            
            bottomContentHeight = bottomContentHeight - Int(positionsContainerView.frame.size.height)
        }
        
        // Set the scrollView content size
        containerScrollView.contentSize = CGSize(width: Int(kDeviceWidth), height: topContentHeight + bottomContentHeight)
        
        
        // Now populate the athlete info into the various cells
        firstNameTextField.text = currentAthlete!.firstName
        lastNameTextField.text = currentAthlete!.lastName
        jerseyTextField.text = currentAthlete!.jersey
        
        // Height
        if ((currentAthlete!.heightFeet.count > 0) && (currentAthlete!.heightInches.count > 0))
        {
            heightTextField.text = currentAthlete!.heightFeet + "' " + currentAthlete!.heightInches + "\""
        }
        
        // Grade
        if (currentAthlete!.classYear == "5")
        {
            gradeTextField.text = "5th"
        }
        else if (currentAthlete!.classYear == "6")
        {
            gradeTextField.text = "6th"
        }
        else if (currentAthlete!.classYear == "7")
        {
            gradeTextField.text = "7th"
        }
        else if (currentAthlete!.classYear == "8")
        {
            gradeTextField.text = "8th"
        }
        else if (currentAthlete!.classYear == "9")
        {
            gradeTextField.text = "Fr"
        }
        else if (currentAthlete!.classYear == "10")
        {
            gradeTextField.text = "So"
        }
        else if (currentAthlete!.classYear == "11")
        {
            gradeTextField.text = "Jr"
        }
        else if (currentAthlete!.classYear == "12")
        {
            gradeTextField.text = "Sr"
        }

        // Weight
        if (currentAthlete!.weight.count > 0)
        {
            weightTextField.text = currentAthlete!.weight + " lbs."
        }
        
        // WeightClass
        if (currentAthlete!.weightClass.count > 0)
        {
            weightClassTextField.text = currentAthlete!.weightClass + " lbs."
        }
        
        // Positions
        //var positions = [] as Array<String>
        positions.removeAll()
        
        if (currentAthlete!.position1.count > 0)
        {
            positions.append(currentAthlete!.position1)
        }
        
        if (currentAthlete!.position2.count > 0)
        {
            positions.append(currentAthlete!.position2)
        }
        
        if (currentAthlete!.position3.count > 0)
        {
            positions.append(currentAthlete!.position3)
        }
        
        if (positions.count == 1)
        {
            positionsTextField.text = positions[0]
        }
        else if (positions.count == 2)
        {
            positionsTextField.text = positions[0] + ", " + positions[1]
        }
        else if (positions.count == 3)
        {
            positionsTextField.text = positions[0] + ", " + positions[1] + ", " + positions[2]
        }
        
        // Gender
        if (currentAthlete!.isFemale == true)
        {
            genderTextField.text = "Female"
        }
        else
        {
            genderTextField.text = "Male"
        }
        
        // Captain button
        isCaptain = currentAthlete!.isCaptain
        
        if (isCaptain == true)
        {
            captainButton.setImage(UIImage(named: "CheckBoxBlue"), for: .normal)
        }
        else
        {
            captainButton.setImage(UIImage(named: "CheckBoxOff"), for: .normal)
        }
        
        // Roster image
        let photoUrl = currentAthlete!.photoUrl
        
        if (photoUrl.count > 0)
        {
            let url = URL(string: photoUrl)
            
            // Get the data and make an image
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        self.athletePhotoImageView.image = image
                    }
                }
            }
        }
    }
    
    // MARK: - Keyboard Notifications
    
    @objc private func keyboardDidShow(notification: Notification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            print("Keyboard Height: " + String(Int(keyboardSize.size.height)))
            
            // Need to subtract the tabBarContainer height from the keyboard height
            let scrollViewDifference = Int(keyboardSize.size.height) - Int(tabBarContainer.frame.size.height)
            containerScrollView.frame = CGRect(x: 0, y: Int(fakeStatusBar.frame.size.height) + Int(navView.frame.size.height) - 12, width: Int(kDeviceWidth), height: scrollViewInitialHeight - scrollViewDifference)
        }
    }
    
    @objc private func keyboardDidHide(notification: Notification)
    {
        //print("Keyboard will hide")
        containerScrollView.frame = CGRect(x: 0, y: Int(fakeStatusBar.frame.size.height) + Int(navView.frame.size.height) - 12, width: Int(kDeviceWidth), height: scrollViewInitialHeight)
    }
    
    // MARK: - Numeric Keyboard Accessory Views
    
    private func addNumericKeyboardAccessoryViews()
    {
        let jerseyAccessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        jerseyAccessoryView.backgroundColor = UIColor.mpRedColor()
        
        let jerseyDoneButton = UIButton(type: .custom)
        jerseyDoneButton.frame = CGRect(x: kDeviceWidth - 85, y: 5, width: 80, height: 30)
        jerseyDoneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        jerseyDoneButton.setTitle("Done", for: .normal)
        jerseyDoneButton.setTitleColor(UIColor.mpWhiteColor(), for: .normal)
        jerseyDoneButton.addTarget(self, action: #selector(jerseyDoneButtonTouched), for: .touchUpInside)
        jerseyAccessoryView.addSubview(jerseyDoneButton)
        jerseyTextField!.inputAccessoryView = jerseyAccessoryView
        
        let weightAccessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        weightAccessoryView.backgroundColor = UIColor.mpRedColor()
        
        let weightDoneButton = UIButton(type: .custom)
        weightDoneButton.frame = CGRect(x: kDeviceWidth - 85, y: 5, width: 80, height: 30)
        weightDoneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        weightDoneButton.setTitle("Done", for: .normal)
        weightDoneButton.setTitleColor(UIColor.mpWhiteColor(), for: .normal)
        weightDoneButton.addTarget(self, action: #selector(weightDoneButtonTouched), for: .touchUpInside)
        weightAccessoryView.addSubview(weightDoneButton)
        weightTextField!.inputAccessoryView = weightAccessoryView
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        currentSport = selectedTeam!.sport
        currentGender = selectedTeam!.gender
        
        fakeStatusBar.backgroundColor = .clear
        
        let hexColorString = self.selectedTeam?.teamColor
        teamColor = ColorHelper.color(fromHexString: hexColorString, colorCorrection: true)!
 
        // Size and locate the fakeStatusBar, navBar, containerScrollView, and tabBarContainer
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 76 + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        
        scrollViewInitialHeight = Int(kDeviceHeight) - Int(fakeStatusBar.frame.size.height) - Int(navView.frame.size.height) + 12 - 90 - Int(SharedData.bottomSafeAreaHeight)
        
        containerScrollView.frame = CGRect(x: 0, y: Int(fakeStatusBar.frame.size.height) + Int(navView.frame.size.height) - 12, width: Int(kDeviceWidth), height: scrollViewInitialHeight)
        tabBarContainer.frame = CGRect(x: 0, y: Int(kDeviceHeight) - 90 - SharedData.bottomSafeAreaHeight, width: Int(kDeviceWidth), height: 90 + SharedData.bottomSafeAreaHeight)
        
        navView.layer.cornerRadius = 12
        navView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        navView.clipsToBounds = true
        
        saveButton.layer.cornerRadius = 8
        saveButton.clipsToBounds = true
        saveButton.backgroundColor = teamColor
        saveButton.isEnabled = false
        
        deleteButton.setTitleColor(teamColor, for: .normal)
        deleteButton.layer.cornerRadius = 8
        deleteButton.layer.borderWidth = 1
        deleteButton.layer.borderColor = teamColor.cgColor
        deleteButton.clipsToBounds = true
        
        // Add a shadow to the tabBarContainer
        let shadowPath = UIBezierPath(rect: tabBarContainer.bounds)
        tabBarContainer.layer.masksToBounds = false
        tabBarContainer.layer.shadowColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        tabBarContainer.layer.shadowOffset = CGSize(width: 0, height: -3)
        tabBarContainer.layer.shadowOpacity = 0.5
        tabBarContainer.layer.shadowPath = shadowPath.cgPath
        
        athletePhotoImageView.layer.cornerRadius = athletePhotoImageView.frame.size.width / 2
        athletePhotoImageView.clipsToBounds = true
        
        // Add the keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
        
        // Add Accessory views to the number keypads
        self.addNumericKeyboardAccessoryViews()
        
        // Update the UI to match the sport
        self.loadUserInterface()
        
        // Clear out the temp image file
        self.deletePhotoAndFile(updateServer: false)
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
