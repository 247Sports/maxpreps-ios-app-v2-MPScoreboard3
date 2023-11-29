//
//  NewCoachProfileViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 7/11/23.
//

import UIKit
import AVFoundation

class NewCoachProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var schoolId = ""
    var ssid = ""
    
    private var webVC: WebViewController!
    private var notificationsVC: NotificationsViewController!
    private var editAccountVC: NewEditAccountViewController!
    private var specialOffersVC: SpecialOffersViewController!
    private var appSettingsVC: AppSettingsViewController!
    private var myTeamsVC: MyTeamsViewController!
    private var contributionsVC: ContributionsViewController!
    private var claimedProfilesVC: ClaimedProfilesViewController!
    private var staffDetailVC: StaffDetailViewController!
    private var coachTeamsVC: CoachTeamsViewController!
    
    private var photoPicker : UIImagePickerController?
    private var cameraPicker : UIImagePickerController?
    
    private var myTeamsHeaderView: ProfilesAndTeamsHeaderViewCell?
    private var accountHeaderView: ProfilesAndTeamsHeaderViewCell?
    private var settingsHeaderView: ProfilesAndTeamsHeaderViewCell?
    private var helpHeaderView: ProfilesAndTeamsHeaderViewCell?
    
    private var progressOverlay: ProgressHUD!
    private var profileData = [:] as Dictionary<String,Any>
    private var tableHasMyTeams = false
    private var trackingGuid = ""
    
    // MARK: - Show Coach Teams view Controller
    
    private func showCoachTeamsViewController()
    {
        coachTeamsVC = CoachTeamsViewController(nibName: "CoachTeamsViewController", bundle: nil)
        self.navigationController?.pushViewController(coachTeamsVC, animated: true)
    }
    
    // MARK: - Show My Teams View Controller
    
    private func showMyTeamsViewController()
    {
        let myTeams = self.profileData["myTeams"] as! Array<Dictionary<String,Any>>
        
        myTeamsVC = MyTeamsViewController(nibName: "MyTeamsViewController", bundle: nil)
        myTeamsVC.sportTeams = myTeams
        myTeamsVC.athleteName = userNameLabel.text!
        self.navigationController?.pushViewController(myTeamsVC, animated: true)
    }
    
    // MARK: - Show Claimed Profiles View Controller
    
    private func showClaimedProfilesViewController()
    {
        claimedProfilesVC = ClaimedProfilesViewController(nibName: "ClaimedProfilesViewController", bundle: nil)
        claimedProfilesVC.userProfileType = "Coach"
        self.navigationController?.pushViewController(claimedProfilesVC, animated: true)
    }
    
    // MARK: - Show My Contributions View Controller
    
    private func showMyContributionsViewController()
    {
        contributionsVC = ContributionsViewController(nibName: "ContributionsViewController", bundle: nil)
        contributionsVC.profileData = self.profileData
        self.navigationController?.pushViewController(contributionsVC, animated: true)
    }
    
    // MARK: - Show Account Info View Controller
    
    private func showAccountInfoViewController()
    {
        editAccountVC = NewEditAccountViewController(nibName: "NewEditAccountViewController", bundle: nil)
        self.navigationController?.pushViewController(editAccountVC, animated: true)
        
        // Tracking
        TrackingManager.trackState(featureName: "personal-info-home", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
    }
    
    // MARK: - Show Notifications View Controller
    
    private func showNotificationsViewController()
    {
        // Show the Notifications VC
        notificationsVC = NotificationsViewController(nibName: "NotificationsViewController", bundle: nil)
        self.navigationController?.pushViewController(notificationsVC, animated: true)
    }
    
    // MARK: - Show Settings View Controller
    
    private func showSettingsViewController()
    {
        appSettingsVC = AppSettingsViewController(nibName: "AppSettingsViewController", bundle: nil)
        self.navigationController?.pushViewController(appSettingsVC, animated: true)
    }
    
    // MARK: - Show Special Offers View Controller
    
    private func showSpecialOffersViewController()
    {
        // Show the SpecialOffers VC
        specialOffersVC = SpecialOffersViewController(nibName: "SpecialOffersViewController", bundle: nil)
        self.navigationController?.pushViewController(specialOffersVC, animated: true)
    }
    
    // MARK: - Show Web View Controller
    
    private func showWebViewController(urlString: String, title: String)
    {
        self.hidesBottomBarWhenPushed = true
        
        webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC.titleString = title
        webVC.urlString = urlString
        webVC.titleColor = UIColor.mpBlackColor()
        webVC.navColor = UIColor.mpWhiteColor()
        webVC.allowRotation = false
        webVC.showShareButton = true
        webVC.showScrollIndicators = false
        webVC.showLoadingOverlay = true
        webVC.showBannerAd = false
        webVC.tabBarVisible = false
        webVC.enableAdobeQueryParameter = true

        self.navigationController?.pushViewController(webVC, animated: true)
        //self.hidesBottomBarWhenPushed = false
    }
    
    // MARK: - Get Coach User Profile
    
    private func getCoachUserProfile()
    {
        tableHasMyTeams = false
        
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
                
        NewFeeds.getCoachUserProfile(schoolId: self.schoolId, ssid: self.ssid) { result, error in
            
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
                
                self.profileData = result!
                
                if (self.profileData.count > 0)
                {
                    let myTeams = self.profileData["myTeams"] as! Array<Dictionary<String,Any>>
                    if (myTeams.count > 0)
                    {
                        self.tableHasMyTeams = true
                    }
                }
            }
            else
            {
                print("Get Coach User Profile Failed")
            }
            
            self.profileTableView.reloadData()
        }
    }
    
    // MARK: - Load User Image
    
    func loadUserImage()
    {
        let userPhotoUrlString = kUserDefaults.string(forKey: kUserPhotoUrlKey)
        
        if (userPhotoUrlString!.count > 0)
        {
            let url = URL(string: userPhotoUrlString!)
            
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
    
    private func deleteUserImage()
    {
        NewFeeds.deleteUserImage(completionHandler: { (error) in
                       
            if (error == nil)
            {
                print("Delete User Image Success")
                
                self.userImageView.image = UIImage(named: "Avatar")
                
                OverlayView.showPopupOverlay(withMessage: "Photo Deleted")
                {
                    // Message the tab bar controller to get user info so the images update everywhere
                    let tabController = self.tabBarController as! TabBarController
                    tabController.getUserInfo()
                }
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
            
            NewFeeds.saveUserImage(imageData: data) { urlString, error in
                
                self.dismiss(animated: true, completion:{
         
                    self.cameraPicker = nil;
                })
                
                if (error == nil)
                {
                    print("Image Upload Success")
                    
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Photo Saved", message: "Your photo was successfully saved. It will be visible in the rest of the app after processing is finished.", lastItemCancelType: false) { tag in
                        
                        // Message the tab bar controller to get user info so the images update everywhere
                        let tabController = self.tabBarController as! TabBarController
                        tabController.getUserInfo()
                    }
                    /*
                    // Add some delay so the image picker can dismiss
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                    { [self] in
                        
                        OverlayView.showPopupOverlay(withMessage: "Photo Saved")
                        {
                            // Message the tab bar controller to get user info so the images update everywhere
                            let tabController = self.tabBarController as! TabBarController
                            tabController.getUserInfo()
                        }
                    }
                    */
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

            NewFeeds.saveUserImage(imageData: data) { urlString, error in
                
                self.dismiss(animated: true, completion:{
         
                    self.photoPicker = nil;
                })
                
                if (error == nil)
                {
                    print("Image Upload Success")
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Photo Saved", message: "Your photo was successfully saved. It will be visible in the rest of the app after processing is finished.", lastItemCancelType: false) { tag in
                        
                        // Message the tab bar controller to get user info so the images update everywhere
                        let tabController = self.tabBarController as! TabBarController
                        tabController.getUserInfo()
                    }
                    /*
                    // Add some delay so the image picker can dismiss
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                    { [self] in
                        
                        OverlayView.showPopupOverlay(withMessage: "Photo Saved")
                        {
                            // Message the tab bar controller to get user info so the images update everywhere
                            let tabController = self.tabBarController as! TabBarController
                            tabController.getUserInfo()
                        }
                    }
                    */
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
 
            self.photoPicker = nil;
        })
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section == 0)
        {
            if (tableHasMyTeams == true)
            {
                return 3
            }
            else
            {
                return 2
            }
        }
        else if ((section == 1) || (section == 2))
        {
            return 2
        }
        else if (section == 3)
        {
            return 3
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (indexPath.section == 0)
        {
            if (indexPath.row == 0)
            {
                return 58.0
            }
            else
            {
                return 48.0
            }
        }
        else if (indexPath.section == 1)
        {
            return 58.0
        }
        else if (indexPath.section == 2)
        {
            return 48.0
        }
        else if (indexPath.section == 3)
        {
            if (indexPath.row == 2)
            {
                return 52.0
            }
            else
            {
                return 48.0
            }
        }
        else
        {
            return 176.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if ((section == 0) || (section == 1) || (section == 2) || (section == 3))
        {
            return 50.0
        }
        else
        {
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (section == 4)
        {
            return  120.0
        }
        else
        {
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (section == 0)
        {
            let view = UIView()
            view.addSubview(myTeamsHeaderView!)
            return view
        }
        else if (section == 1)
        {
            let view = UIView()
            view.addSubview(accountHeaderView!)
            return view
        }
        else if (section == 2)
        {
            let view = UIView()
            view.addSubview(settingsHeaderView!)
            return view
        }
        else if (section == 3)
        {
            let view = UIView()
            view.addSubview(helpHeaderView!)
            return view
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        if (section == 4)
        {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 120))
            view.backgroundColor = UIColor.mpHeaderBackgroundColor()
            
            let footerLabel = UILabel(frame: CGRect(x: 16, y: 10, width: kDeviceWidth - 32, height: 90))
            footerLabel.font = UIFont.mpRegularFontWith(size: 13)
            footerLabel.textColor = UIColor.mpDarkGrayColor()
            footerLabel.textAlignment = .center
            footerLabel.numberOfLines = 5
            view.addSubview(footerLabel)
            
            // Add some app information
            let shortVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            let version = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            let currentYear = dateFormatter.string(from: Date())
            
            let iosVersion = ProcessInfo().operatingSystemVersion
            
            footerLabel.text = String(format: "App Version: %@ (build %@)\niOS version: %@.%@.%@\n\nCopyright 2015-%@, CBS Interactive Inc.\nAll Rights Reserved.", shortVersion, version, String(iosVersion.majorVersion), String(iosVersion.minorVersion), String(iosVersion.patchVersion), currentYear)
            
            return view
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (indexPath.section == 0)
        {
            if (indexPath.row == 0)
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "NewProfileMediumTableViewCell") as? NewProfileMediumTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("NewProfileMediumTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? NewProfileMediumTableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.titleLabel.text = "Manage Teams"
                cell?.subtitleLabel.text = "Teams you have admin access to"
                cell?.iconImageView.image = UIImage(named: "NewAdminTeamsIcon")
                
                return cell!
            }
            else if (indexPath.row == 1)
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "NewProfileShortTableViewCell") as? NewProfileShortTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("NewProfileShortTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? NewProfileShortTableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.titleLabel.text = "My Claimed Profiles"
                cell?.iconImageView.image = UIImage(named: "NewClaimProfileIcon")
                
                return cell!
            }
            else
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "NewProfileShortTableViewCell") as? NewProfileShortTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("NewProfileShortTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? NewProfileShortTableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.titleLabel.text = "My Teams"
                cell?.iconImageView.image = UIImage(named: "NewMyTeamsIcon")
                
                return cell!
            }
        }
        else if (indexPath.section == 1)
        {
            if (indexPath.row == 0)
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "NewProfileMediumTableViewCell") as? NewProfileMediumTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("NewProfileMediumTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? NewProfileMediumTableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.titleLabel.text = "My Contributions"
                cell?.subtitleLabel.text = "Uploaded videos and scores"
                cell?.iconImageView.image = UIImage(named: "NewMyContributionsIcon")
                
                return cell!
            }
            else
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "NewProfileMediumTableViewCell") as? NewProfileMediumTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("NewProfileMediumTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? NewProfileMediumTableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.titleLabel.text = "Account Info"
                cell?.subtitleLabel.text = kUserDefaults.string(forKey: kUserEmailKey)
                cell?.iconImageView.image = UIImage(named: "NewAccountInfoIcon")
                
                return cell!
            }
        }
        else if (indexPath.section == 2)
        {
            if (indexPath.row == 0)
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "NewProfileShortTableViewCell") as? NewProfileShortTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("NewProfileShortTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? NewProfileShortTableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.titleLabel.text = "Notifications"
                cell?.iconImageView.image = UIImage(named: "NewNotificationsIcon")
                
                return cell!
            }
            else
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "NewProfileShortTableViewCell") as? NewProfileShortTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("NewProfileShortTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? NewProfileShortTableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.titleLabel.text = "App Settings"
                cell?.iconImageView.image = UIImage(named: "NewAppSettingsIcon")
                
                return cell!
            }
        }
        else if (indexPath.section == 3)
        {
            if (indexPath.row == 0)
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "NewProfileShortTableViewCell") as? NewProfileShortTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("NewProfileShortTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? NewProfileShortTableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.titleLabel.text = "Support"
                cell?.iconImageView.image = UIImage(named: "NewSupportIcon")
                
                return cell!
            }
            else if (indexPath.row == 1)
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "NewProfileShortTableViewCell") as? NewProfileShortTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("NewProfileShortTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? NewProfileShortTableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.titleLabel.text = "Send Feedback"
                cell?.iconImageView.image = UIImage(named: "NewFeedbackIcon")
                
                return cell!
            }
            else
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "NewProfileSpecialTableViewCell") as? NewProfileSpecialTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("NewProfileSpecialTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? NewProfileSpecialTableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.titleLabel.text = "Special Offers"
                cell?.iconImageView.image = UIImage(named: "NewSpecialOffersIcon")
                
                return cell!
            }
        }
        else
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "NewProfileSocialTableViewCell") as? NewProfileSocialTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("NewProfileSocialTableViewCell", owner: self, options: nil)
                cell = nib![0] as? NewProfileSocialTableViewCell
            }
            
            cell?.selectionStyle = .none
            
            cell?.signoutButton.addTarget(self, action: #selector(signoutButtonTouched), for: .touchUpInside)
            cell?.twitterButton.addTarget(self, action: #selector(twitterButtonTouched), for: .touchUpInside)
            cell?.facebookButton.addTarget(self, action: #selector(facebookButtonTouched), for: .touchUpInside)
            cell?.youTubeButton.addTarget(self, action: #selector(youTubeButtonTouched), for: .touchUpInside)
            cell?.tikTokButton.addTarget(self, action: #selector(tikTokButtonTouched), for: .touchUpInside)
            cell?.instagramButton.addTarget(self, action: #selector(instagramButtonTouched), for: .touchUpInside)
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
            
        if (indexPath.section == 0) // Profile and Teams section
        {
            if (indexPath.row == 0)
            {
                self.showCoachTeamsViewController()
            }
            else if (indexPath.row == 1)
            {
                self.showClaimedProfilesViewController()
            }
            else
            {
                self.showMyTeamsViewController()
            }
        }
        else if (indexPath.section == 1) // Account section
        {
            if (indexPath.row == 0)
            {
                self.showMyContributionsViewController()
            }
            else
            {
                self.showAccountInfoViewController()
            }
        }
        else if (indexPath.section == 2) // Settings section
        {
            if (indexPath.row == 0)
            {
                self.showNotificationsViewController()
            }
            else
            {
                self.showSettingsViewController()
            }
        }
        else if (indexPath.section == 3) // Help section
        {
            if (indexPath.row == 0)
            {
                self.showWebViewController(urlString: kTechSupportUrl, title: "Support")
            }
            else if (indexPath.row == 1)
            {
                self.showWebViewController(urlString: "https://support.maxpreps.com/hc/en-us/requests/new?ticket_form_id=14520918612635", title: "Send Feedback")
            }
            else
            {
                self.showSpecialOffersViewController()
            }
        }
    }
    
    // MARK: - Clear User Prefs and Dismiss
    
    private func clearUserPrefsAndDismiss()
    {
        // Clear out the user's prefs
        MiscHelper.logoutUser()
        
        self.navigationController?.popToRootViewController(animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            NotificationCenter.default.post(name: Notification.Name("Logout"), object: self, userInfo: nil)
        }
    }
    
    // MARK: - Button Methods
   
    @IBAction func backButtontouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func viewProfileButtonTouched(_ sender: UIButton)
    {
        // Use the first adminTeams object to get the teamColor, schoolId, ssid.
        let adminTeams = self.profileData["adminTeams"] as! Array<Dictionary<String,Any>>
        if (adminTeams.count > 0)
        {
            let firstTeam = adminTeams.first!
            let teamColor = firstTeam["schoolColor1"] as! String
            let position = firstTeam["adminRoleTitle"] as! String
            
            // Build a RosterStaff object with just userId, firstName, lastName, photoUrl, and position since this is all that is needed
            let userId = self.profileData["userId"] as! String
            let userFirstName = self.profileData["userFirstName"] as! String
            let userLastName = self.profileData["userLastName"] as! String
            let photoUrl = self.profileData["photoUrl"] as! String
            
            let selectedStaff = RosterStaff(contactId: "", userId: userId, roleId: "", userFirstName: userFirstName, userLastName: userLastName, userEmail: "", position: position, roleName: "", photoUrl: photoUrl)
            
            self.tabBarController?.tabBar.isHidden = false
            
            // This is added to disable tha tabbar buttons
            let tabBarControllerItems = self.tabBarController?.tabBar.items

            if let tabArray = tabBarControllerItems
            {
                let tabBarItem1 = tabArray[0]
                let tabBarItem2 = tabArray[1]
                let tabBarItem3 = tabArray[2]

                tabBarItem1.isEnabled = false
                tabBarItem2.isEnabled = false
                tabBarItem3.isEnabled = false
            }
            
            if (staffDetailVC != nil)
            {
                staffDetailVC = nil
            }
            
            staffDetailVC = StaffDetailViewController(nibName: "StaffDetailViewController", bundle: nil)
            staffDetailVC.selectedStaff = selectedStaff
            staffDetailVC.teamColor = teamColor
            
            self.navigationController?.pushViewController(staffDetailVC, animated: true)
        }
        else
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "We are unable to open your profile because no teams were found.", lastItemCancelType: false) { (tag) in
            }
        }
    }
    
    @IBAction func editPhotoButtonTouched(_ sender: UIButton)
    {
        // Click Tracking
        let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"user-photo-prompt", kClickTrackingModuleNameKey: "user photo", kClickTrackingModuleLocationKey:"user profile", kClickTrackingModuleActionKey: "impression", kClickTrackingClickTextKey:"Delete"]
        
        TrackingManager.trackEvent(featureName: "update-image", cData: cData)
        
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
                self.deleteUserImage()
            }
            
            // Click Tracking
            if (tag == 3)
            {
                let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"user-photo-prompt", kClickTrackingModuleNameKey: "user photo", kClickTrackingModuleLocationKey:"user profile", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:"Delete"]
                
                TrackingManager.trackEvent(featureName: "update-image", cData: cData)
            }
            else
            {
                let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"user-photo-prompt", kClickTrackingModuleNameKey: "user photo", kClickTrackingModuleLocationKey:"user profile", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:"Add"]
                
                TrackingManager.trackEvent(featureName: "update-image", cData: cData)
            }
        }
    }
    
    @objc private func signoutButtonTouched()
    {
        // Show the alert
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Sign Out", style: .destructive, handler: { [self] action in
            
            alert.dismiss(animated: true) { [self] in
                
                self.clearUserPrefsAndDismiss()
                
                // Click Tracking
                let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"sign-out-button-click", kClickTrackingModuleNameKey: "sign-out", kClickTrackingModuleLocationKey:"settings home", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:""]
                
                TrackingManager.trackEvent(featureName: "sign-out", cData: cData)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { action in
            
        })
        
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        
        alert.modalPresentationStyle = .fullScreen
        present(alert, animated: true)
    }
    
    @objc private func twitterButtonTouched()
    {
        self.showWebViewController(urlString: kMaxPrepsTwitterUrl, title: "X")
    }
    
    @objc private func facebookButtonTouched()
    {
        self.showWebViewController(urlString: kMaxPrepsFacebookUrl, title: "Facebook")
    }
    
    @objc private func youTubeButtonTouched()
    {
        self.showWebViewController(urlString: kMaxPrepsYouTubeUrl, title: "YouTube")
    }
    
    @objc private func tikTokButtonTouched()
    {
        self.showWebViewController(urlString: kMaxPrepsTikTokUrl, title: "TikTok")
    }
    
    @objc private func instagramButtonTouched()
    {
        self.showWebViewController(urlString: kMaxPrepsInstagramUrl, title: "Instagram")
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        trackingGuid = NSUUID().uuidString

        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        profileTableView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height)
        profileTableView.contentInsetAdjustmentBehavior = .never
        profileTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -20.0, right: 0)
        
        userImageView.layer.cornerRadius = userImageView.frame.size.height / 2
        userImageView.layer.borderWidth = 1
        userImageView.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        userImageView.clipsToBounds = true
        
        let myTeamsNib = Bundle.main.loadNibNamed("ProfilesAndTeamsHeaderViewCell", owner: self, options: nil)
        myTeamsHeaderView = myTeamsNib![0] as? ProfilesAndTeamsHeaderViewCell
        myTeamsHeaderView?.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 50)
        myTeamsHeaderView?.titleLabel.text = "Profiles and Teams"
        
        let accountNib = Bundle.main.loadNibNamed("ProfilesAndTeamsHeaderViewCell", owner: self, options: nil)
        accountHeaderView = accountNib![0] as? ProfilesAndTeamsHeaderViewCell
        accountHeaderView?.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 50)
        accountHeaderView?.titleLabel.text = "Account"
        
        let settingsNib = Bundle.main.loadNibNamed("ProfilesAndTeamsHeaderViewCell", owner: self, options: nil)
        settingsHeaderView = settingsNib![0] as? ProfilesAndTeamsHeaderViewCell
        settingsHeaderView?.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 50)
        settingsHeaderView?.titleLabel.text = "Settings"
        
        let helpNib = Bundle.main.loadNibNamed("ProfilesAndTeamsHeaderViewCell", owner: self, options: nil)
        helpHeaderView = helpNib![0] as? ProfilesAndTeamsHeaderViewCell
        helpHeaderView?.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 50)
        helpHeaderView?.titleLabel.text = "Help"
        
        self.loadUserImage()
        
        self.getCoachUserProfile()
        
        // This will change to use the name from the feed
        let firstName = kUserDefaults.string(forKey: kUserFirstNameKey)
        let lastName = kUserDefaults.string(forKey: kUserLastNameKey)
        
        if ((firstName != nil) && (lastName != nil))
        {
            userNameLabel.text = firstName! + " " + lastName!
        }
        else
        {
            userNameLabel.text = ""
        }
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // This is added to enable the tabbar buttons when returning from the VCs
        let tabBarControllerItems = self.tabBarController?.tabBar.items
        
        if let tabArray = tabBarControllerItems
        {
            let tabBarItem1 = tabArray[0]
            let tabBarItem2 = tabArray[1]
            let tabBarItem3 = tabArray[2]
            
            tabBarItem1.isEnabled = true
            tabBarItem2.isEnabled = true
            tabBarItem3.isEnabled = true
        }
        
        // This is added to reset the background when returning from the VCs
        kAppKeyWindow.rootViewController!.view.backgroundColor = UIColor.mpWhiteColor()
        
        self.tabBarController?.tabBar.isHidden = true
    
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (webVC != nil)
        {
            webVC = nil
        }
        
        if (notificationsVC != nil)
        {
            notificationsVC = nil
        }
        
        if (specialOffersVC != nil)
        {
            specialOffersVC = nil
        }
        
        if (staffDetailVC != nil)
        {
            staffDetailVC = nil
        }
        
        if (editAccountVC != nil)
        {
            if (editAccountVC.userInfoUpdated == true)
            {
                // Update the user name label
                let firstName = kUserDefaults.string(forKey: kUserFirstNameKey)
                let lastName = kUserDefaults.string(forKey: kUserLastNameKey)
                
                if ((firstName != nil) && (lastName != nil))
                {
                    userNameLabel.text = firstName! + " " + lastName!
                }
                else
                {
                    userNameLabel.text = ""
                }
                
                self.getCoachUserProfile()
            }
            
            editAccountVC = nil
        }
        
        // Pop the nav to the root if the user logged out
        if (appSettingsVC != nil)
        {
            let logout = appSettingsVC?.logoutTouched
            if (logout == true)
            {
                //self.navigationController?.popToRootViewController(animated: false)
                self.clearUserPrefsAndDismiss()
            }
        }
        
        if (myTeamsVC != nil)
        {
            myTeamsVC = nil
        }
        
        if (coachTeamsVC != nil)
        {
            coachTeamsVC = nil
        }
        
        if (contributionsVC != nil)
        {
            contributionsVC = nil
        }
        
        if (claimedProfilesVC != nil)
        {
            claimedProfilesVC = nil
        }
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
