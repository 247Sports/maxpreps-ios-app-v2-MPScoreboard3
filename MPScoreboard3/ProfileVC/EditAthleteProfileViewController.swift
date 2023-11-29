//
//  EditAthleteProfileViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 11/11/21.
//

import UIKit
import AVFoundation

class EditAthleteProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var fillerView: UIView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    private var profileAboutView: ProfileAboutTableViewCell!
    
    private var photoPicker : UIImagePickerController?
    private var cameraPicker : UIImagePickerController?
    
    var careerId = ""
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Get Athlete User Profile
    
    private func getAthleteUserProfile()
    {
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        print("Career ID: " + self.careerId)
        
        NewFeeds.getAthleteUserProfile(careerId: self.careerId) { result, error in
            
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
                print("Get Athlete User Profile Success")
                
                // Update the athlete profile name in case it is different
                let firstName = result!["firstName"] as? String ?? ""
                let lastName = result!["lastName"] as? String ?? ""
                self.userNameLabel.text = firstName + " " + lastName
                
                let photoUrl = result!["photoUrl"] as? String ?? ""
                self.loadUserImage(photoUrl: photoUrl)
                
                self.profileAboutView.loadData(data: result!)
            }
            else
            {
                print("Get Athlete User Profile Failed")
            }
        }
    }
    
    // MARK: - Load User Image
    
    func loadUserImage(photoUrl: String)
    {
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
                        self.userImageView.image = image
                    }
                }
            }
        }
    }

    // MARK: - Delete Photo
    
    private func deleteCareerImage()
    {
        NewFeeds.deleteCareerImage(careerId: self.careerId, completionHandler: { (error) in
            
            self.userImageView.image = UIImage(named: "Avatar")
                        
            if (error == nil)
            {
                print("Delete User Image Success")
                OverlayView.showPopupOverlay(withMessage: "Photo Deleted")
                {
                    
                }
            }
            else
            {
                print("Delete User Image Failed")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to delete this photo.", lastItemCancelType: false) { tag in
                    
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
        self.present(photoPicker!, animated: true)
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
        
        self.present(self.cameraPicker!, animated: true) {
            
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
        self.dismiss(animated: true){
            
        }
    }
    
    @objc private func takePictureTouched()
    {
        cameraPicker?.takePicture()
    }
    
    // MARK: - Image Picker Delegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if (picker == cameraPicker)
        {
            // Scale the image to 300 x 300 so it can be used elsewhere on the website and still look good.
            let userImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            let croppedImageWidth = userImage.size.width
            let croppedImageHeight = croppedImageWidth
            
            let croppedImage = ImageHelper.cropImage(userImage, in: CGRect(x: (userImage.size.width - croppedImageWidth) / 2.0, y: (userImage.size.height - croppedImageHeight) / 2.0, width: croppedImageWidth, height: croppedImageHeight))
            
            let scaledImage = ImageHelper.image(with: croppedImage, scaledTo:  CGSize(width: 300, height: 300))
            userImageView.image = scaledImage
            
            guard let data = scaledImage!.jpegData(compressionQuality: 1.0) else { return }
            
            NewFeeds.saveCareerImage(careerId: self.careerId, imageData: data) { error in
                
                self.dismiss(animated: true, completion:{
         
                    self.cameraPicker = nil
                })
                
                if (error == nil)
                {
                    print("Image Upload Success")
                    
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Photo Saved", message: "Your photo was successfully saved. It will be visible in your child's profile after it has been approved.", lastItemCancelType: false) { tag in
                    }
                }
                else
                {
                    print("Image Upload Failure")
                    
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to save your photo.", lastItemCancelType: false) { tag in
                        
                    }
                }
            }
            
        }
        else
        {
            // Scale the image to 300 x 300 so it can be used elsewhere on the website and still look good.
            let userImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
            let scaledImage = ImageHelper.image(with: userImage, scaledTo:  CGSize(width: 300, height: 300))
            userImageView.image = scaledImage
            
            guard let data = scaledImage!.jpegData(compressionQuality: 1.0) else { return }

            NewFeeds.saveCareerImage(careerId: self.careerId, imageData: data) { error in
                
                self.dismiss(animated: true, completion:{
         
                    self.photoPicker = nil
                })
                
                if (error == nil)
                {
                    print("Image Upload Success")
                    
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Photo Saved", message: "Your photo was successfully saved. It will be visible in your child's profile after it has been approved.", lastItemCancelType: false) { tag in
                    }
                }
                else
                {
                    print("Image Upload Failure")
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to save your photo.", lastItemCancelType: false) { tag in
                        
                    }
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion:{
 
            self.photoPicker = nil
        })
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
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
                self.deleteCareerImage()
            }
        }
    }
    
    @objc private func saveInfoButtonTouched()
    {
        let facebookProfile = profileAboutView.facebookTextField.text
        let twitterHandle = profileAboutView.twitterTextField.text
        let classYearString = profileAboutView.classYearTextField.text
        
        if ((twitterHandle!.count > 0) && (twitterHandle!.first != "@"))
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Ax X handle username start with an @.", lastItemCancelType: false) { tag in
                
            }
            return
        }
        
        var bio = ""
        if (profileAboutView.athleteDetailsTextView.text != kUserProfileBioTextViewDefaultText)
        {
            bio = profileAboutView.athleteDetailsTextView.text
        }
        
        if (bio.containsEmoji == true)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "You can't use special characters in the bio.", lastItemCancelType: false) { tag in
                
            }
            return
        }
        
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.updateAthleteUserProfile(careerId: self.careerId, bio: bio, faceBookProfile: facebookProfile!, twitterHandle: twitterHandle!, classYear: classYearString!) { result, error in
   
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
                print("Update Athlete User Profile Success")
                
                OverlayView.showPopupOverlay(withMessage: "Saved")
                {
                    self.dismiss(animated: true) {
                        
                    }
                }
            }
            else
            {
                print("Update Athlete User Profile Failed")
                
                let errorMessage = error?.localizedDescription
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: errorMessage, lastItemCancelType: false) { tag in
                    
                }
                
                /*
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to save your changes.", lastItemCancelType: false) { tag in
                    
                }
                */
            }
        }
        
    }
    
    // MARK: - Keyboard Notifications
    
    @objc private func keyboardDidShow(notification: Notification)
    {
        // Don't shift if the textView is active
        if (profileAboutView.athleteDetailsTextViewActive == true)
        {
            return
        }

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            //print("Keyboard Height: " + String(Int(keyboardSize.size.height)))

            // Need to use the device coordinates for this calculation
            let twitterContainerViewBottom = Int(containerScrollView.frame.origin.y) + 280
            
            let keyboardTop = Int(kDeviceHeight) - Int(keyboardSize.size.height)
            
            if (keyboardTop < twitterContainerViewBottom)
            {
                let difference = twitterContainerViewBottom - keyboardTop
                containerScrollView.contentOffset = CGPoint(x: 0, y: difference)
            }
        }
    }
    
    @objc private func keyboardDidHide(notification: Notification)
    {
        //print("Keyboard will hide")
        containerScrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        fillerView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: fillerView.frame.size.height)
        containerScrollView.frame = CGRect(x: 0, y: fillerView.frame.origin.y + fillerView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - fillerView.frame.origin.y - fillerView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight))
        
        let aboutNib = Bundle.main.loadNibNamed("ProfileAboutTableViewCell", owner: self, options: nil)
        profileAboutView = aboutNib![0] as? ProfileAboutTableViewCell
        profileAboutView.frame = CGRect(x: 0.0, y: headerView.frame.size.height, width: kDeviceWidth, height: 430.0)
        profileAboutView.saveInfoButton.addTarget(self, action: #selector(saveInfoButtonTouched), for: .touchUpInside)
        containerScrollView.addSubview(profileAboutView)
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2.0
        userImageView.clipsToBounds = true
        
        userNameLabel.text = ""
        
        // Add the keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.getAthleteUserProfile()
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    
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
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
