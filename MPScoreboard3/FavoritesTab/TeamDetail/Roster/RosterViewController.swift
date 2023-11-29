//
//  RosterViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 7/28/21.
//

import UIKit
import AVFoundation
import GoogleMobileAds
//import MoPubAdapter
import DTBiOSSDK
import AdSupport
import AppTrackingTransparency

class RosterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CustomActionSheetTripleViewDelegate, AddAthleteViewControllerDelegate, EditAthleteViewControllerDelegate, AddStaffViewControllerDelegate, EditStaffViewControllerDelegate, EditStaffUserViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DeletedAthletesViewControllerDelegate, DTBAdCallback, GADBannerViewDelegate
{
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var rosterTableView: UITableView!
    @IBOutlet weak var noRosterView: UIView!
    @IBOutlet weak var noRosterBackgroundImageView: UIImageView!
    @IBOutlet weak var noRosterInviteCoachButton: UIButton!
    @IBOutlet weak var noRosterTitleLabel: UILabel!
    @IBOutlet weak var noRosterDescriptionLabel: UILabel!
    
    var selectedTeam : Team?
    var ssid = ""
    var year = ""
    var selectedYearIndex = 0
    
    private var addButton: UIButton!
    private var topHeaderView: RosterTopHeaderTableViewCell!
    private var shortTopHeaderView: RosterShortTopHeaderTableViewCell!
    private var staffHeaderView: RosterStaffHeaderTableViewCell!
    private var staffFooterView: RosterStaffFooterTableViewCell!
    private var customActionSheetTripleView: CustomActionSheetTripleView!
    private var addAthleteVC: AddAthleteViewController!
    private var editAthleteVC: EditAthleteViewController!
    private var addStaffVC: AddStaffViewController!
    private var editStaffVC: EditStaffViewController!
    private var editStaffUserVC: EditStaffUserViewController!
    private var deletedAthletesVC: DeletedAthletesViewController!
    
    private var photoPicker: UIImagePickerController!
    private var cameraPicker: UIImagePickerController!
    
    private var userIsAdmin = false
    private var athleteItems: Array<RosterAthlete> = []
    private var deletedAthleteItems: Array<RosterAthlete> = []
    private var staffItems: Array<RosterStaff> = []
    private var teamPhotoUrl = ""
    //private var rosterCorrectionUrl = ""
    
    /*
    let kInviteCoachUrl = "https://www.maxpreps.com/team/staff/staff-form?ssid=%@&schoolid=%@&allseasonid=%@&isInvitingHeadCoach=1"
    
    let kAddCoachUrl = "https://www.maxpreps.com/team/staff/staff-form?ssid=%@&schoolid=%@&allseasonid=%@&isAddingHeadCoach=1"
    */
    let kInviteCoachUrl = "https://support.maxpreps.com/hc/en-us/requests/new?ticket_form_id=1260804029810"
    
    private var googleBannerAdView: GAMBannerView!
    private var bannerBackgroundView: UIVisualEffectView! //UIImageView!
    
    private var trackingGuid = ""
    private var userTeamRole = ""
    private var tickTimer: Timer!
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Nimbus Variables
    
    let apsLoader: DTBAdLoader = {
        let loader = DTBAdLoader()
        loader.setAdSizes([
            DTBAdSize(bannerAdSizeWithWidth: 320, height: 50, andSlotUUID: kAmazonBannerAdSlotUUID) as Any
        ])
        return loader
    }()
    
    lazy var bidders: [Bidder] = [
        // Position identifies this placement in our dashboard, it is freeform so I matched the Google ad unit name
        NimbusBidder(request: .forBannerAd(position: "team")),
        APSBidder(adLoader: apsLoader)
    ]
    
    lazy var dynamicPriceManager = DynamicPriceManager(bidders: bidders, refreshInterval: TimeInterval(kNimbusAdTimerValue))
        
    // MARK: - Get Rosters
    
    private func getRosters(sort: String)
    {
        if (userIsAdmin == true)
        {
            self.getSecureRosters(sort: sort)
        }
        else
        {
            self.getPublicRosters(sort: sort)
        }
    }
    
    private func getPublicRosters(sort: String)
    {
        self.athleteItems.removeAll()
        self.staffItems.removeAll()
        self.deletedAthleteItems.removeAll()
        teamPhotoUrl = ""
        //rosterCorrectionUrl = ""
        
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        // Call the feed
        RosterFeeds.getPublicRosters(teamId: selectedTeam!.schoolId, ssid: self.ssid, sort: sort) { athletes, deletedAthletes, staff, photoUrl, error in
            
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
                print("Get Roster Success")
                                
                self.athleteItems = athletes!
                self.deletedAthleteItems = deletedAthletes!
                self.staffItems = staff!
                self.teamPhotoUrl = photoUrl!
                //self.rosterCorrectionUrl = correctionUrl!
                
                // Hide the sort button if no roster
                if (self.athleteItems.count == 0)
                {
                    self.topHeaderView.rosterSortButton.isHidden = true
                    self.shortTopHeaderView.rosterSortButton.isHidden = true
                }
                else
                {
                    // Add the roster count to the headerView's seasonLabel
                    self.topHeaderView.seasonLabel.text = String(format: "20%@ %@ Team (%d)", self.year, self.selectedTeam!.teamLevel, self.athleteItems.count)
                    self.shortTopHeaderView.seasonLabel.text = String(format: "20%@ %@ Team (%d)", self.year, self.selectedTeam!.teamLevel, self.athleteItems.count)
                }
                
                // Add the staff count to the bottomHeaderView seasonLabel
                if (self.staffItems.count > 0)
                {
                    self.staffHeaderView.seasonLabel.text = String(format: "20%@ Staff (%d)", self.year, self.staffItems.count)
                }
                
                self.rosterTableView.reloadData()
                
                // Hide the table if both rosters are empty
                if (self.staffItems.count > 0) || (self.athleteItems.count > 0)
                {
                    self.rosterTableView.isHidden = false
                }
                else
                {
                    self.noRosterView.isHidden = false
                }
            }
            else
            {
                print("Get Roster Failed")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to get the roster.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    private func getSecureRosters(sort: String)
    {
        self.athleteItems.removeAll()
        self.staffItems.removeAll()
        self.deletedAthleteItems.removeAll()
        teamPhotoUrl = ""
        //rosterCorrectionUrl = ""
        
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        // Call the feed
        RosterFeeds.getSecureRosters(teamId: selectedTeam!.schoolId, ssid: self.ssid, sort: sort) { athletes, deletedAthletes, staff, photoUrl, error in
            
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
                print("Get Roster Success")
                
                self.athleteItems = athletes!
                self.deletedAthleteItems = deletedAthletes!
                self.staffItems = staff!
                self.teamPhotoUrl = photoUrl!
                //self.rosterCorrectionUrl = correctionUrl!
                
                // Hide the deleted athlete button if no deleted roster
                if (self.deletedAthleteItems.count == 0)
                {
                    self.topHeaderView.rosterShowDeletedButton.isHidden = true
                    self.shortTopHeaderView.rosterShowDeletedButton.isHidden = true
                }
                
                // Hide the sort button if no roster
                if (self.athleteItems.count == 0)
                {
                    self.topHeaderView.rosterSortButton.isHidden = true
                    self.shortTopHeaderView.rosterSortButton.isHidden = true
                }
                else
                {
                    // Add the roster count to the headerView's seasonLabel
                    self.topHeaderView.seasonLabel.text = String(format: "20%@ %@ Team (%d)", self.year, self.selectedTeam!.teamLevel, self.athleteItems.count)
                    self.shortTopHeaderView.seasonLabel.text = String(format: "20%@ %@ Team (%d)", self.year, self.selectedTeam!.teamLevel, self.athleteItems.count)
                }
                
                // Add the staff count to the bottomHeaderView seasonLabel
                if (self.staffItems.count > 0)
                {
                    self.staffHeaderView.seasonLabel.text = String(format: "20%@ Staff (%d)", self.year, self.staffItems.count)
                }
                
                self.rosterTableView.reloadData()
                
                // Hide the table if both rosters are empty
                if (self.staffItems.count > 0) || (self.athleteItems.count > 0)
                {
                    self.rosterTableView.isHidden = false
                }
                else
                {
                    self.noRosterView.isHidden = false
                }
            }
            else
            {
                print("Get Roster Failed")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to get the roster.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - Logout User
    
    private func logoutUser()
    {
        // Clear out the user's prefs
        MiscHelper.logoutUser()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            // Show the login landing page from the tabBarController
            let tabBarController = self.tabBarController as! TabBarController
            tabBarController.selectedIndex = 0
            tabBarController.showLoginHomeVC()
            
            self.navigationController?.popToRootViewController(animated: false)
        }
    }
    
    // MARK: - Save Photo
    
    private func saveTeamPhoto()
    {
        let fileManager = FileManager()
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent(kRosterImageTempFileName)
        
        if (fileManager.fileExists(atPath: fileURL.path))
        {
            let data = NSData(contentsOf: fileURL)! as Data
            print(data.count)
            
            //MBProgressHUD.showAdded(to: self.view, animated: true)
            if (progressOverlay == nil)
            {
                progressOverlay = ProgressHUD()
                progressOverlay.show(animated: false)
            }
            
            RosterFeeds.addTeamPhoto(schoolId: selectedTeam!.schoolId, ssid: self.ssid, imageData: data) { success, error in
                
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
                    print("Save Team Photo Success")
                    
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Saved", message: "Your team photo was successfully saved. It will be visible when processing is finished.", lastItemCancelType: false) { tag in
                        
                    }
                }
                else
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to save the team photo.", lastItemCancelType: false) { tag in
                        
                    }
                }
            }
        }
    }
    
    // MARK: - Delete Photo
    
    private func deleteTeamPhoto(updateServer: Bool)
    {
        //topHeaderView.teamPhotoImageView.image = UIImage(named: "EmptyTeamPhoto")
        //topHeaderView.editButton.setTitle("ADD PHOTO", for: .normal)
        
        // Clear out any photo file that may exist
        do
        {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(kRosterImageTempFileName)
            
            try FileManager.default.removeItem(at: fileURL)
        }
        catch let error as NSError
        {
            print("Delete File Error: \(error.domain)")
        }
        
        if (updateServer == true)
        {
            RosterFeeds.deleteTeamPhoto(schoolId: selectedTeam!.schoolId, ssid: self.ssid) { success, error in
                
                if (error == nil)
                {
                    print("Delete Team Photo Success")
                    
                    OverlayView.showPopupOverlay(withMessage: "Photo Deleted")
                    {
                        self.teamPhotoUrl = ""
                        self.rosterTableView.reloadData()
                    }
                }
                else
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to delete the team photo.", lastItemCancelType: false) { tag in
                        
                    }
                }
            }
        }
    }
    
    // MARK: - Show Web View
    
    private func showWebView(urlString: String, title: String)
    {
        // Color changed
        let webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC.titleString = title
        webVC.urlString = urlString
        //webVC.titleColor = UIColor.mpWhiteColor()
        //webVC.navColor = navView.backgroundColor!
        webVC.titleColor = UIColor.mpBlackColor()
        webVC.navColor = UIColor.mpWhiteColor()
        webVC.allowRotation = false
        webVC.showShareButton = false
        webVC.showScrollIndicators = true
        webVC.showLoadingOverlay = false
        webVC.showBannerAd = false
        webVC.tabBarVisible = true
        webVC.enableAdobeQueryParameter = true

        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    // MARK: - Choose Photo from Library
    
    private func choosePhotoFromLibrary()
    {
        photoPicker = UIImagePickerController()
        photoPicker?.delegate = self
        photoPicker?.allowsEditing = false //true
        photoPicker?.sourceType = .photoLibrary
        photoPicker?.modalPresentationStyle = .fullScreen
        
        self.present(photoPicker, animated: true)
        {
            
        }
    }
    
    // MARK: - Take Photo from Camera
    
    private func takePhotoFromCamera()
    {
        if (UIImagePickerController.isSourceTypeAvailable(.camera))
        {
            let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
            
            if (authStatus == .authorized)
            {
                self.showCameraPicker()
            }
            else if (authStatus == .notDetermined)
            {
                // Requst access
                AVCaptureDevice.requestAccess(for: .video) { (granted) in
                    if (granted)
                    {
                        DispatchQueue.main.async
                        {
                            self.showCameraPicker()
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
    
    private func showCameraPicker()
    {
        cameraPicker = UIImagePickerController()
        cameraPicker?.delegate = self
        cameraPicker?.allowsEditing = false
        cameraPicker?.sourceType = .camera
        cameraPicker?.showsCameraControls = true
        
        self.cameraPicker?.modalPresentationStyle = .fullScreen
        self.present(self.cameraPicker!, animated: true) {
            
        }
    }
    
    // MARK: - Image Picker Delegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        /*
        var scaledImage: UIImage
        
        if (picker == cameraPicker)
        {
            // Aspect is 4:3
            let userImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            scaledImage = ImageHelper.image(with: userImage, scaledTo:  CGSize(width: 400, height: 300))
        }
        else
        {
            // Edited image aspect is 1:1
            let userImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
            scaledImage = ImageHelper.image(with: userImage, scaledTo:  CGSize(width: 300, height: 300))
        }
        */
        let userImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let scaledImage = ImageHelper.image(with: userImage, scaledTo:  CGSize(width: 400, height: 300))
        print(scaledImage!.size.width)
        print(scaledImage!.size.height)
        
        topHeaderView.teamPhotoImageView.image = scaledImage
        
        // Save the image to a temp file
        guard let data = scaledImage!.jpegData(compressionQuality: 1.0) else { return }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let fileURL = documentsDirectory.appendingPathComponent(kRosterImageTempFileName)
        
        do
        {
            try data.write(to: fileURL)
            
            let fileManager = FileManager()
            
            if (fileManager.fileExists(atPath: fileURL.path))
            {
                print("Save File Success")
                
                // Save the photo to the DB
                self.saveTeamPhoto()
                
                self.rosterTableView.reloadData()
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
           self.dismiss(animated: true)
            {
                self.cameraPicker = nil
            }
        }
        else
        {
            self.dismiss(animated: true)
            {
                self.photoPicker = nil
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion:{
 
            self.photoPicker = nil;
        })
    }
    
    // MARK: - TableView Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section == 0)
        {
            if (athleteItems.count > 0)
            {
                return athleteItems.count
            }
            else
            {
                return 1
            }
        }
        else
        {
            if (staffItems.count > 0)
            {
                return staffItems.count
            }
            else
            {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (indexPath.section == 0)
        {
            if (athleteItems.count > 0)
            {
                return 64
            }
            else
            {
                if (userIsAdmin == true)
                {
                    return 213 - 10 // Added so it looks good
                }
                else
                {
                    return 172 - 10 // Added so it looks good
                }
            }
        }
        else
        {
            if (staffItems.count > 0)
            {
                return 64
            }
            else
            {
                if (selectedYearIndex == 0)
                {
                    return 240
                }
                else
                {
                    return 220
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if (section == 0)
        {
            if (teamPhotoUrl.count > 0)
            {
                return topHeaderView.frame.size.height
            }
            else
            {
                // Use the temp image if it is available
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsDirectory.appendingPathComponent(kRosterImageTempFileName)
                let fileManager = FileManager()
                
                if (fileManager.fileExists(atPath: fileURL.path))
                {
                    return topHeaderView.frame.size.height
                }
                else
                {
                    return shortTopHeaderView.frame.size.height
                }
            }
        }
        else
        {
            return staffHeaderView.frame.size.height
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (section == 0)
        {
            return 0.01
        }
        else
        {
            if (userIsAdmin == true)
            {
                // Add some pad at the bottom so the + button won't cover the cell
                // Add pad for the ad
                return 90 + 62
            }
            else
            {
                // Add pad for the ad
                return staffFooterView.frame.size.height + 32
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (section == 0)
        {
            if (teamPhotoUrl.count > 0)
            {
                // Return the topHeaderView
                
                // Load the photo
                let url = URL(string: teamPhotoUrl)
                
                // Get the data and make an image
                MiscHelper.getData(from: url!) { data, response, error in
                    guard let data = data, error == nil else { return }

                    DispatchQueue.main.async()
                    {
                        let image = UIImage(data: data)
                        
                        if (image != nil)
                        {
                            self.topHeaderView.teamPhotoImageView.image = image
                        }
                        else
                        {
                            self.topHeaderView.teamPhotoImageView.image = UIImage(named: "EmptyTeamPhoto")
                        }
                    }
                }
                
                return topHeaderView
            }
            else
            {
                // Use the temp image if it is available
                // Return the topHeaderView
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = documentsDirectory.appendingPathComponent(kRosterImageTempFileName)
                let fileManager = FileManager()
                
                if (fileManager.fileExists(atPath: fileURL.path))
                {
                    // Get the data from the temp and make an image
                    MiscHelper.getData(from: fileURL) { data, response, error in
                        guard let data = data, error == nil else { return }

                        DispatchQueue.main.async()
                        {
                            let image = UIImage(data: data)
                            
                            if (image != nil)
                            {
                                self.topHeaderView.teamPhotoImageView.image = image
                            }
                            else
                            {
                                self.topHeaderView.teamPhotoImageView.image = UIImage(named: "EmptyTeamPhoto")
                            }
                        }
                    }
                    
                    return topHeaderView
                }
                else
                {
                    // Return the shortTopHeaderView
                    return shortTopHeaderView
                }
            }

        }
        else
        {
            return staffHeaderView
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        if (section == 1)
        {
            if (userIsAdmin == true)
            {
                return nil
            }
            else
            {
                return staffFooterView
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (indexPath.section == 0)
        {
            if (self.athleteItems.count > 0)
            {
                // RosterAthleteTableViewCell
                var cell = tableView.dequeueReusableCell(withIdentifier: "RosterAthleteTableViewCell") as? RosterAthleteTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("RosterAthleteTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? RosterAthleteTableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.editButton.isHidden = true
                cell?.chevronImageView.isHidden = true
                cell?.editButton.tag = indexPath.row + 100
                cell?.editButton.addTarget(self, action: #selector(editAthleteButtonTouched(_:)), for: .touchUpInside)
                
                if (userIsAdmin == true)
                {
                    cell?.editButton.isHidden = false
                }
                
                let athlete = athleteItems[indexPath.row]
                
                // Load the data into the cell
                cell?.loadData(athlete: athlete)
                
                return cell!
            }
            else
            {
                if (userIsAdmin == true)
                {
                    // RosterNoAthleteTallTableViewCell
                    var cell = tableView.dequeueReusableCell(withIdentifier: "RosterNoAthleteTallTableViewCell") as? RosterNoAthleteTallTableViewCell
                    
                    if (cell == nil)
                    {
                        let nib = Bundle.main.loadNibNamed("RosterNoAthleteTallTableViewCell", owner: self, options: nil)
                        cell = nib![0] as? RosterNoAthleteTallTableViewCell
                    }
                    
                    cell?.selectionStyle = .none
                    cell?.copyFromLastSeasonButton.addTarget(self, action: #selector(copyFromLastSeasonButtonTouched(_:)), for: .touchUpInside)
                    
                    return cell!
                }
                else
                {
                    // RosterNoAthleteTallTableViewCell
                    var cell = tableView.dequeueReusableCell(withIdentifier: "RosterNoAthleteShortTableViewCell") as? RosterNoAthleteShortTableViewCell
                    
                    if (cell == nil)
                    {
                        let nib = Bundle.main.loadNibNamed("RosterNoAthleteShortTableViewCell", owner: self, options: nil)
                        cell = nib![0] as? RosterNoAthleteShortTableViewCell
                    }
                    
                    cell?.selectionStyle = .none
                    cell?.subtitleLabel.text = "Athletes have not yet been added to the " + year + " season."
                    
                    return cell!
                }
            }
        }
        else
        {
            if (staffItems.count > 0)
            {
                // RosterStaffTableViewCell
                var cell = tableView.dequeueReusableCell(withIdentifier: "RosterStaffTableViewCell") as? RosterStaffTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("RosterStaffTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? RosterStaffTableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.editButton.isHidden = true
                cell?.horizLine.isHidden = false
                cell?.clipsToBounds = false
                
                cell?.editButton.addTarget(self, action: #selector(editStaffButtonTouched(_:)), for: .touchUpInside)
                cell?.editButton.tag = indexPath.row + 100
                
                if (userIsAdmin == true)
                {
                    cell?.editButton.isHidden = false
                }
                
                if (indexPath.row == (staffItems.count - 1))
                {
                    // Hide the horizontal line and round the bottom corners
                    cell?.horizLine.isHidden = true
                    cell?.layer.cornerRadius = 12
                    cell?.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                    cell?.clipsToBounds = true
                }
                
                let staff = staffItems[indexPath.row]
                
                // Load the data into the cell
                cell?.loadData(staff: staff)
                
                return cell!
            }
            else
            {
                if (selectedYearIndex == 0)
                {
                    // RosterNoStaffTallTableViewCell
                    var cell = tableView.dequeueReusableCell(withIdentifier: "RosterNoStaffTallTableViewCell") as? RosterNoStaffTallTableViewCell
                    
                    if (cell == nil)
                    {
                        let nib = Bundle.main.loadNibNamed("RosterNoStaffTallTableViewCell", owner: self, options: nil)
                        cell = nib![0] as? RosterNoStaffTallTableViewCell
                    }
                    
                    cell?.selectionStyle = .none
                    cell?.inviteCoachButton.layer.cornerRadius = 8
                    cell?.inviteCoachButton.clipsToBounds = true
                    cell?.inviteCoachButton.backgroundColor = navView.backgroundColor
                    cell?.inviteCoachButton.addTarget(self, action: #selector(inviteCoachButtonTouched(_:)), for: .touchUpInside)
                    
                    return cell!
                }
                else
                {
                    // RosterNoStaffShortTableViewCell
                    var cell = tableView.dequeueReusableCell(withIdentifier: "RosterNoStaffShortTableViewCell") as? RosterNoStaffShortTableViewCell
                    
                    if (cell == nil)
                    {
                        let nib = Bundle.main.loadNibNamed("RosterNoStaffShortTableViewCell", owner: self, options: nil)
                        cell = nib![0] as? RosterNoStaffShortTableViewCell
                    }
                    
                    cell?.selectionStyle = .none
                    cell?.addCoachNameButton.layer.cornerRadius = 8
                    cell?.addCoachNameButton.clipsToBounds = true
                    cell?.addCoachNameButton.backgroundColor = navView.backgroundColor
                    cell?.addCoachNameButton.addTarget(self, action: #selector(addCoachButtonTouched(_:)), for: .touchUpInside)
                    
                    return cell!
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        /*
         ▿ Athlete
           - firstName : "Whitney"
           - lastName : "Montoya"
           - schoolName : "Ponderosa"
           - schoolState : "CA"
           - schoolCity : "Shingle Springs"
           - schoolId : "d9622df1-9a90-49e7-b219-d6c380c566fe"
           - schoolColor : "003300"
           - schoolMascotUrl : "https://dw3jhbqsbya58.cloudfront.net/fit-in/1024x1024/school-mascot/d/9/6/d9622df1-9a90-49e7-b219-d6c380c566fe.gif?version=636614652600000000"
           - careerId : "c305727c-629c-4397-9b0d-17e179ddb450"
           - photoUrl : ""
         */
        
        if (indexPath.section == 0)
        {
            if (self.athleteItems.count == 0)
            {
                return
            }
            
            let athlete = athleteItems[indexPath.row]
            
            let firstName = athlete.firstName
            let lastName = athlete.lastName
            let schoolName = selectedTeam?.schoolName
            let schoolId = selectedTeam?.schoolId
            let schoolColor1 = selectedTeam?.teamColor
            let schoolMascotUrl = selectedTeam?.mascotUrl
            let schoolCity = selectedTeam?.schoolCity
            let schoolState = selectedTeam?.schoolState
            let careerProfileId = athlete.careerId
            let photoUrl = athlete.photoUrl
            
            let selectedAthlete = Athlete(firstName: firstName, lastName: lastName, schoolName: schoolName!, schoolState: schoolState!, schoolCity: schoolCity!, schoolId: schoolId!, schoolColor: schoolColor1!, schoolMascotUrl: schoolMascotUrl!, careerId: careerProfileId, photoUrl: photoUrl)
            
            let athleteDetailVC = NewAthleteDetailViewController(nibName: "NewAthleteDetailViewController", bundle: nil)
            athleteDetailVC.selectedAthlete = selectedAthlete
            
            // Check to see if the athlete is already a favorite
            let isFavorite = MiscHelper.isAthleteMyFavoriteAthlete(careerId: careerProfileId)
            
            var showSaveFavoriteButton = false
            var showRemoveFavoriteButton = false
            
            if (isFavorite == true)
            {
                showSaveFavoriteButton = false
                showRemoveFavoriteButton = true
            }
            else
            {
                // Two paths depending on wheteher the user is logged in or not
                let userId = kUserDefaults.value(forKey: kUserIdKey) as! String
                
                if (userId != kTestDriveUserId)
                {
                    showSaveFavoriteButton = true
                    showRemoveFavoriteButton = false
                }
                else
                {
                    showSaveFavoriteButton = false
                    showRemoveFavoriteButton = false
                }
            }
            
            athleteDetailVC.showSaveFavoriteButton = showSaveFavoriteButton
            athleteDetailVC.showRemoveFavoriteButton = showRemoveFavoriteButton
            
            self.navigationController?.pushViewController(athleteDetailVC, animated: true)
        }
        else
        {
            if (self.staffItems.count == 0)
            {
                return
            }
            
            let staff = staffItems[indexPath.row]
            
            let staffDetailVC = StaffDetailViewController(nibName: "StaffDetailViewController", bundle: nil)
            staffDetailVC.selectedStaff = staff
            staffDetailVC.teamColor = self.selectedTeam!.teamColor
            
            self.navigationController?.pushViewController(staffDetailVC, animated: true)
        }
    }
    
    // MARK: - AddAthleteViewController Delegates
    
    func addAthleteCancelButtonTouched()
    {
        self.tabBarController?.tabBar.isHidden = false
        
        if (addAthleteVC.athleteAdded == true)
        {
            self.dismiss(animated: true)
            {
                self.getRosters(sort: "0")
                self.addAthleteVC = nil
            }
        }
        else
        {
            self.dismiss(animated: true)
            {
                self.addAthleteVC = nil
            }
        }
    }
    
    func addAthleteSaveButtonTouched()
    {
        self.tabBarController?.tabBar.isHidden = false
        self.dismiss(animated: true)
        {
            self.getRosters(sort: "0")
            self.addAthleteVC = nil
        }
    }
    
    // MARK: - EditAthleteViewController Delegates
    
    func editAthleteCancelButtonTouched()
    {
        self.tabBarController?.tabBar.isHidden = false
        self.dismiss(animated: true)
        {
            self.editAthleteVC = nil
        }
    }
    
    func editAthleteSaveOrDeleteButtonTouched()
    {
        self.tabBarController?.tabBar.isHidden = false
        self.dismiss(animated: true)
        {
            self.getRosters(sort: "0")
            self.editAthleteVC = nil
        }
    }
    
    // MARK: - AddStaffViewController Delegates
    
    func addStaffCancelButtonTouched()
    {
        self.tabBarController?.tabBar.isHidden = false
        self.dismiss(animated: true)
        {
            self.addStaffVC = nil
        }
    }
    
    func addStaffSaveButtonTouched()
    {
        self.tabBarController?.tabBar.isHidden = false
        self.dismiss(animated: true)
        {
            self.getRosters(sort: "0")
            self.addStaffVC = nil
        }
    }
    
    // MARK: - EditStaffViewController Delegates
    
    func editStaffCancelButtonTouched()
    {
        self.tabBarController?.tabBar.isHidden = false
        self.dismiss(animated: true)
        {
            self.editStaffVC = nil
        }
    }
    
    func editStaffSaveOrDeleteButtonTouched()
    {
        self.tabBarController?.tabBar.isHidden = false
        self.dismiss(animated: true)
        {
            self.getRosters(sort: "0")
            self.editStaffVC = nil
        }
    }
    
    // MARK: - EditStaffUserViewController Delegates
    
    func editStaffUserCancelButtonTouched()
    {
        self.tabBarController?.tabBar.isHidden = false
        self.dismiss(animated: true)
        {
            self.editStaffUserVC = nil
        }
    }
    
    func editStaffUserSaveOrDeleteButtonTouched()
    {
        self.tabBarController?.tabBar.isHidden = false
        self.dismiss(animated: true)
        {
            self.getRosters(sort: "0")
            self.editStaffUserVC = nil
            
            // Get user info so the photo is updated everywhere
            let tabController = self.tabBarController as! TabBarController
            tabController.getUserInfo()
        }
    }
    
    func editStaffUserDeletePhotoButtonTouched()
    {
        // Get the roster after a little delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
        {
            self.getRosters(sort: "0")
        }
        
        // Get user info so the photo is updated everywhere
        let tabController = self.tabBarController as! TabBarController
        tabController.getUserInfo()
    }
    
    // MARK: - DeletedAthletesViewControllerDelegateMethod
    
    func deletedAthleteWasRestored()
    {
        self.getRosters(sort: "0")
    }
    
    // MARK: - CustomActionSheetTripleView Delegates
    
    func closeCustomTripleActionSheetAfterButtonOneTouched()
    {
        // Add Staff
        customActionSheetTripleView.removeFromSuperview()
        customActionSheetTripleView = nil
        
        
        if (addStaffVC != nil)
        {
            addStaffVC = nil
        }
        
        addStaffVC = AddStaffViewController(nibName: "AddStaffViewController", bundle: nil)
        addStaffVC.delegate = self
        addStaffVC.selectedTeam = self.selectedTeam
        addStaffVC.ssid = self.ssid
        addStaffVC.modalPresentationStyle = .overCurrentContext
        
        self.tabBarController?.tabBar.isHidden = true
        self.present(addStaffVC, animated: true)
        {
            
        }
        
        // Build the tracking context data object
        var cData = kEmptyTrackingContextData
        
        let schoolName = self.selectedTeam?.schoolName
        let schoolState = self.selectedTeam?.schoolState
        let schoolId = self.selectedTeam?.schoolId
        let sport = self.selectedTeam?.sport
        let level = self.selectedTeam?.teamLevel
        let gender = self.selectedTeam?.gender
        let season = self.selectedTeam?.season
        
        cData[kTrackingSchoolNameKey] = schoolName
        cData[kTrackingSchoolStateKey] = schoolState
        cData[kTrackingTeamIdKey] = schoolId
        cData[kTrackingSportNameKey] = sport
        cData[kTrackingSportLevelKey] = level
        cData[kTrackingSportGenderKey] = gender
        cData[kTrackingSeasonKey] = season
        cData[kTrackingSchoolYearKey] = self.year
        cData[kTrackingUserTeamRoleKey] = userTeamRole
        
        TrackingManager.trackState(featureName: "staff-manage", trackingGuid: trackingGuid, cData: cData)
    }
    
    func closeCustomTripleActionSheetAfterButtonTwoTouched()
    {
        // Add Athlete
        customActionSheetTripleView.removeFromSuperview()
        customActionSheetTripleView = nil
        
        if (addAthleteVC != nil)
        {
            addAthleteVC = nil
        }
        
        addAthleteVC = AddAthleteViewController(nibName: "AddAthleteViewController", bundle: nil)
        addAthleteVC.delegate = self
        addAthleteVC.selectedTeam = self.selectedTeam
        addAthleteVC.ssid = self.ssid
        addAthleteVC.modalPresentationStyle = .overCurrentContext
        
        self.tabBarController?.tabBar.isHidden = true
        self.present(addAthleteVC, animated: true)
        {
            
        }
        
        // Build the tracking context data object
        var cData = kEmptyTrackingContextData
        
        let schoolName = self.selectedTeam?.schoolName
        let schoolState = self.selectedTeam?.schoolState
        let schoolId = self.selectedTeam?.schoolId
        let sport = self.selectedTeam?.sport
        let level = self.selectedTeam?.teamLevel
        let gender = self.selectedTeam?.gender
        let season = self.selectedTeam?.season
        
        cData[kTrackingSchoolNameKey] = schoolName
        cData[kTrackingSchoolStateKey] = schoolState
        cData[kTrackingTeamIdKey] = schoolId
        cData[kTrackingSportNameKey] = sport
        cData[kTrackingSportLevelKey] = level
        cData[kTrackingSportGenderKey] = gender
        cData[kTrackingSeasonKey] = season
        cData[kTrackingSchoolYearKey] = self.year
        cData[kTrackingUserTeamRoleKey] = userTeamRole
        
        TrackingManager.trackState(featureName: "athlete-manage", trackingGuid: trackingGuid, cData: cData)
    }
    
    func closeCustomTripleActionSheetAfterCancelButtonTouched()
    {
        customActionSheetTripleView.removeFromSuperview()
        customActionSheetTripleView = nil
    }
    
    // MARK: - Sort Menu Methods
    
    private var menuItems: [UIAction]
    {
        return [
            UIAction(title: "Jersey", image: nil, handler: { (_) in
                print("Jersey Touched")
                self.getRosters(sort: "0")
            }),
            UIAction(title: "Name", image: nil, handler: { (_) in
                print("Name Touched")
                self.getRosters(sort: "1")
            }),
            UIAction(title: "Grade", image: nil, handler: { (_) in
                print("Grade Touched")
                self.getRosters(sort: "2")
            })
        ]
    }

    private var sortMenu: UIMenu
    {
        return UIMenu(title: "Sort Athletes By", image: nil, identifier: nil, options: [], children: menuItems)
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func addButtonTouched(_ sender: UIButton)
    {
        if (customActionSheetTripleView != nil)
        {
            customActionSheetTripleView.removeFromSuperview()
            customActionSheetTripleView = nil
        }
        
        customActionSheetTripleView = CustomActionSheetTripleView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight), buttonZeroTitle: nil, buttonOneTitle: "Add Staff", buttonTwoTitle: "Add Athlete", color: navView.backgroundColor)
        customActionSheetTripleView.delegate = self
        
        kAppKeyWindow.rootViewController!.view.addSubview(customActionSheetTripleView)
    }
    
    @objc private func editAthleteButtonTouched(_ sender: UIButton)
    {
        if (editAthleteVC != nil)
        {
            editAthleteVC = nil
        }
        
        editAthleteVC = EditAthleteViewController(nibName: "EditAthleteViewController", bundle: nil)
        editAthleteVC.delegate = self
        editAthleteVC.selectedTeam = self.selectedTeam
        editAthleteVC.ssid = self.ssid
        
        let index = sender.tag - 100
        let athlete = athleteItems[index]
        
        editAthleteVC.currentAthlete = athlete
        
        editAthleteVC.modalPresentationStyle = .overCurrentContext
        self.tabBarController?.tabBar.isHidden = true
        self.present(editAthleteVC, animated: true) {
            
        }
        
        // Build the tracking context data object
        var cData = kEmptyTrackingContextData
        
        let schoolName = self.selectedTeam?.schoolName
        let schoolState = self.selectedTeam?.schoolState
        let schoolId = self.selectedTeam?.schoolId
        let sport = self.selectedTeam?.sport
        let level = self.selectedTeam?.teamLevel
        let gender = self.selectedTeam?.gender
        let season = self.selectedTeam?.season
        
        cData[kTrackingSchoolNameKey] = schoolName
        cData[kTrackingSchoolStateKey] = schoolState
        cData[kTrackingTeamIdKey] = schoolId
        cData[kTrackingSportNameKey] = sport
        cData[kTrackingSportLevelKey] = level
        cData[kTrackingSportGenderKey] = gender
        cData[kTrackingSeasonKey] = season
        cData[kTrackingSchoolYearKey] = self.year
        cData[kTrackingUserTeamRoleKey] = userTeamRole
        
        TrackingManager.trackState(featureName: "athlete-manage", trackingGuid: trackingGuid, cData: cData)
    }
    
    @objc private func editStaffButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let staff = staffItems[index]
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        // Open either the editStaffVC or the editStafffUserVC
        if (staff.userId == userId)
        {
            if (editStaffUserVC != nil)
            {
                editStaffUserVC = nil
            }
            
            editStaffUserVC = EditStaffUserViewController(nibName: "EditStaffUserViewController", bundle: nil)
            editStaffUserVC.delegate = self
            editStaffUserVC.selectedTeam = self.selectedTeam
            editStaffUserVC.ssid = self.ssid
            editStaffUserVC.currentStaff = staff
            
            editStaffUserVC.modalPresentationStyle = .overCurrentContext
            self.tabBarController?.tabBar.isHidden = true
            self.present(editStaffUserVC, animated: true) {
                
            }
        }
        else
        {
            if (editStaffVC != nil)
            {
                editStaffVC = nil
            }
            
            editStaffVC = EditStaffViewController(nibName: "EditStaffViewController", bundle: nil)
            editStaffVC.delegate = self
            editStaffVC.selectedTeam = self.selectedTeam
            editStaffVC.ssid = self.ssid
            editStaffVC.currentStaff = staff
            
            editStaffVC.modalPresentationStyle = .overCurrentContext
            self.tabBarController?.tabBar.isHidden = true
            self.present(editStaffVC, animated: true) {
                
            }
        }
        

        
        // Build the tracking context data object
        var cData = kEmptyTrackingContextData
        
        let schoolName = self.selectedTeam?.schoolName
        let schoolState = self.selectedTeam?.schoolState
        let schoolId = self.selectedTeam?.schoolId
        let sport = self.selectedTeam?.sport
        let level = self.selectedTeam?.teamLevel
        let gender = self.selectedTeam?.gender
        let season = self.selectedTeam?.season
        
        cData[kTrackingSchoolNameKey] = schoolName
        cData[kTrackingSchoolStateKey] = schoolState
        cData[kTrackingTeamIdKey] = schoolId
        cData[kTrackingSportNameKey] = sport
        cData[kTrackingSportLevelKey] = level
        cData[kTrackingSportGenderKey] = gender
        cData[kTrackingSeasonKey] = season
        cData[kTrackingSchoolYearKey] = self.year
        cData[kTrackingUserTeamRoleKey] = userTeamRole
        
        TrackingManager.trackState(featureName: "staff-manage", trackingGuid: trackingGuid, cData: cData)
    }
    
    @objc private func rosterShowDeletedButtonTouched(_ sender: UIButton)
    {
        deletedAthletesVC = DeletedAthletesViewController(nibName: "DeletedAthletesViewController", bundle: nil)
        deletedAthletesVC.delegate = self
        deletedAthletesVC.selectedTeam = self.selectedTeam
        deletedAthletesVC.deletedAthletes = self.deletedAthleteItems
        deletedAthletesVC.ssid = self.ssid
        deletedAthletesVC.year = self.year
     
        self.navigationController?.pushViewController(deletedAthletesVC, animated: true)
        
        // Build the tracking context data object
        var cData = kEmptyTrackingContextData
        
        let schoolName = self.selectedTeam?.schoolName
        let schoolState = self.selectedTeam?.schoolState
        let schoolId = self.selectedTeam?.schoolId
        let sport = self.selectedTeam?.sport
        let level = self.selectedTeam?.teamLevel
        let gender = self.selectedTeam?.gender
        let season = self.selectedTeam?.season
        
        cData[kTrackingSchoolNameKey] = schoolName
        cData[kTrackingSchoolStateKey] = schoolState
        cData[kTrackingTeamIdKey] = schoolId
        cData[kTrackingSportNameKey] = sport
        cData[kTrackingSportLevelKey] = level
        cData[kTrackingSportGenderKey] = gender
        cData[kTrackingSeasonKey] = season
        cData[kTrackingSchoolYearKey] = self.year
        cData[kTrackingUserTeamRoleKey] = userTeamRole
        
        TrackingManager.trackState(featureName: "roster-deleted", trackingGuid: trackingGuid, cData: cData)
    }
    
    @objc private func editPhotoButtonTouched(_ sender: UIButton)
    {
        MiscHelper.showAlert(in: self, withActionNames: ["Photo Library", "Use Camera", "Delete Photo", "Cancel"], title: "Select Photo Source", message: kUploadTeamPhotoMessage, lastItemCancelType: false) { (tag) in
            if (tag == 0)
            {
                self.choosePhotoFromLibrary()
            }
            else if (tag == 1)
            {
                self.takePhotoFromCamera()
            }
            else if (tag == 2)
            {
                self.deleteTeamPhoto(updateServer: true)
            }
            
            // Click Tracking
            let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"team-photo-button-click", kClickTrackingModuleNameKey: "team photo", kClickTrackingModuleLocationKey:"team home", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:"edit"]
            
            TrackingManager.trackEvent(featureName: "team-photo", cData: cData)
        }
    }
    
    @objc private func addPhotoButtonTouched(_ sender: UIButton)
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        // Don't allow non-members to contribute content
        if (userId == kTestDriveUserId)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["Join", "Later"], title: "Membership Required", message: "You must be a MaxPreps member to contribute content.", lastItemCancelType: false) { (tag) in
                
                if (tag == 0)
                {
                    self.logoutUser()
                }
            }
            return
        }
        
        MiscHelper.showAlert(in: self, withActionNames: ["Photo Library", "Use Camera", "Cancel"], title: "Select Photo Source", message: kUploadTeamPhotoMessage, lastItemCancelType: false) { (tag) in
            if (tag == 0)
            {
                self.choosePhotoFromLibrary()
            }
            else if (tag == 1)
            {
                self.takePhotoFromCamera()
            }
            
            // Click Tracking
            let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"team-photo-button-click", kClickTrackingModuleNameKey: "team photo", kClickTrackingModuleLocationKey:"team home", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:"add"]
            
            TrackingManager.trackEvent(featureName: "team-photo", cData: cData)
        }
    }
    
    @objc private func suggestButtonTouched(_ sender: UIButton)
    {
        self.showWebView(urlString: "https://support.maxpreps.com/hc/en-us/requests/new", title: "Support")
    }
    
    @objc private func copyFromLastSeasonButtonTouched(_ sender: UIButton)
    {
        MiscHelper.showAlert(in: self, withActionNames: ["Copy", "Cancel"], title: "Copy Roster", message: "Are you sure you want to copy last year's roster to this year?", lastItemCancelType: false) { (tag) in
            
            if (tag == 0)
            {
                //MBProgressHUD.showAdded(to: self.view, animated: true)
                if (self.progressOverlay == nil)
                {
                    self.progressOverlay = ProgressHUD()
                    self.progressOverlay.show(animated: false)
                }
                
                RosterFeeds.copyRosterSecure(schoolId: self.selectedTeam!.schoolId, ssid: self.ssid) { result, error in
                    
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
                        // Show an error if the roster is empty
                        if (result?.count == 0)
                        {
                            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "No roster for last season to copy.", lastItemCancelType: false) { tag in
                                
                            }
                            return
                        }
                        
                        print("Copy Roster Success")
                        
                        OverlayView.showPopupOverlay(withMessage: "Roster Copied")
                        {
                            self.getRosters(sort: "0")
                        }
                    }
                    else
                    {
                        print("Copy Roster Failed")
                        
                        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to copy the roster.", lastItemCancelType: false) { tag in
                            
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func inviteCoachButtonTouched(_ sender: UIButton)
    {
        // Change the webview title for previous seasons
        if (self.selectedYearIndex == 0)
        {
            self.showWebView(urlString: kInviteCoachUrl, title: "Invite Coach")
        }
        else
        {
            self.showWebView(urlString: kInviteCoachUrl, title: "Submit Coach Name")
        }
    }
    
    @IBAction func addCoachButtonTouched(_ sender: UIButton)
    {
        self.showWebView(urlString: kInviteCoachUrl, title: "Add Coach")
    }
    
    // MARK: - Amazon Banner Ad Methods
    
    private func requestAmazonBannerAd()
    {
        let adSize = DTBAdSize(bannerAdSizeWithWidth: 320, height: 50, andSlotUUID: kAmazonBannerAdSlotUUID)
        let adLoader = DTBAdLoader()
        adLoader.setAdSizes([adSize!])
        adLoader.loadAd(self)
    }
    
    func onSuccess(_ adResponse: DTBAdResponse!)
    {
        var adResponseDictionary = adResponse.customTargeting()
        
        adResponseDictionary!.updateValue(trackingGuid, forKey: "vguid")
        
        let ccpaString = kUserDefaults.string(forKey: "IABUSPrivacy_String") ?? ""
        adResponseDictionary!.updateValue(ccpaString, forKey: "us_privacy")
        
        // To be added in V6.2.8
        if (MiscHelper.isUserMinorAged() == true)
        {
            adResponseDictionary!.updateValue("1", forKey: "tfcd")
        }
        
        print("Received Amazon Banner Ad")
        
        let request = GAMRequest()
        request.customTargeting = adResponseDictionary
        /*
        // Add a location
        let location = ZipCodeHelper.locationForAd() as! Dictionary<String, String>
        let latitudeValue = Float(location[kLatitudeKey]!)
        let longitudeValue = Float(location[kLongitudeKey]!)
        
        if ((latitudeValue != 0) && (longitudeValue != 0))
        {
            request.setLocationWithLatitude(CGFloat(latitudeValue!), longitude: CGFloat(longitudeValue!), accuracy: 30)
        }
        */
        if (googleBannerAdView != nil)
        {
            googleBannerAdView.load(request)
        }
    }
    
    func onFailure(_ error: DTBAdError)
    {
        print("Amazon Banner Ad Failed")
        
        let request = GAMRequest()
        
        var customTargetDictionary = [:] as Dictionary<String, String>
        let idfaString = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        customTargetDictionary.updateValue(trackingGuid, forKey: "vguid")
        customTargetDictionary.updateValue(idfaString, forKey: "idtype")
        
        // Get the ATT type string to add to the custonTargetDictionary
        let trackingString = MiscHelper.trackingStatusForAds()
        customTargetDictionary.updateValue(trackingString, forKey: "attmas")
        
        let ccpaString = kUserDefaults.string(forKey: "IABUSPrivacy_String") ?? ""
        customTargetDictionary.updateValue(ccpaString, forKey: "us_privacy")
        
        // To be added in V6.2.8
        if (MiscHelper.isUserMinorAged() == true)
        {
            customTargetDictionary.updateValue("1", forKey: "tfcd")
        }
        
        request.customTargeting = customTargetDictionary
        /*
        // Add a location
        let location = ZipCodeHelper.locationForAd() as! Dictionary<String, String>
        let latitudeValue = Float(location[kLatitudeKey]!)
        let longitudeValue = Float(location[kLongitudeKey]!)
        
        if ((latitudeValue != 0) && (longitudeValue != 0))
        {
            request.setLocationWithLatitude(CGFloat(latitudeValue!), longitude: CGFloat(longitudeValue!), accuracy: 30)
        }
        */
        /*
        // Add MoPub
        let extras = GADMoPubNetworkExtras()
        extras.privacyIconSize = 20
        request.register(extras)
        */
        
        if (googleBannerAdView != nil)
        {
            googleBannerAdView.load(request)
        }
    }
    
    // MARK: - Google Ad Methods
    
    private func loadBannerViews()
    {
        // Removed for Nimbus
        /*
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
        */
        
        self.clearBannerAd()
        
        // Removed for Nimbus
        // Add a timer to request a new ad after 15 seconds
        //tickTimer = Timer.scheduledTimer(timeInterval: TimeInterval(kGoogleAdTimerValue), target: self, selector: #selector(adTimerExpired), userInfo: nil, repeats: true)
        
        //GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["ab075279b6aba4510e894e3563b029dc"]
        let adId = kUserDefaults.value(forKey: kTeamsBannerAdIdKey) as! String
        print("AdId: ", adId)
        
        googleBannerAdView = GAMBannerView(adSize: GADAdSizeBanner, origin: CGPoint(x: (kDeviceWidth - GADAdSizeBanner.size.width) / 2.0, y: 6.0))
        googleBannerAdView.delegate = self
        googleBannerAdView.adUnitID = adId
        googleBannerAdView.rootViewController = self
        
        // Removed for Nimbus
        //self.requestAmazonBannerAd()
        
        // Added for Nimbus
        // Starts a task to refresh every 30 seconds with proper foreground/background notifications
        //dynamicPriceManager.autoRefresh { [weak self] request in
        dynamicPriceManager.autoRefresh { request in
            
            request.customTargeting?.updateValue(self.trackingGuid, forKey: "vguid")
            
            // Get the ATT type string to add to the customTargetDictionary
            let trackingString = MiscHelper.trackingStatusForAds()
            request.customTargeting?.updateValue(trackingString, forKey: "attmas")
            
            let ccpaString = kUserDefaults.string(forKey: "IABUSPrivacy_String") ?? ""
            request.customTargeting?.updateValue(ccpaString, forKey: "us_privacy")
            
            let idfaString = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            request.customTargeting?.updateValue(idfaString, forKey: "idtype")
            
            let abTestString = MiscHelper.userABTestValue()
            if (abTestString != "")
            {
                request.customTargeting?.updateValue(abTestString, forKey: "test")
            }
            
            // To be added in V6.2.8
            if (MiscHelper.isUserMinorAged() == true)
            {
                request.customTargeting?.updateValue("1", forKey: "tfcd")
            }
            
            if (self.googleBannerAdView != nil)
            {
                self.googleBannerAdView.load(request)
            }
        }
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView)
    {
        print("Received Google Banner Ad")
        
        /* // MoPub is disabled
        if (bannerView.responseInfo?.adNetworkClassName != "GADMAdapterGoogleAdMobAds")
        {
            print("MoPub Ad Served")
         if (kUserDefaults.bool(forKey: kDebugDialogsKey) == true)
            {
                tickTimer.invalidate()
                tickTimer = nil
                
                MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "MoPub Ad", message: "", lastItemCancelType: false) { tag in
                    
                }
            }
        }
        */
        
        // Added for Nimbus
        if (bannerBackgroundView != nil)
        {
            bannerBackgroundView.removeFromSuperview()
            bannerBackgroundView = nil
        }
        
        // Delay added for Nimbus
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
        {
            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            self.bannerBackgroundView = UIVisualEffectView(effect: blurEffect)
            self.bannerBackgroundView.frame = CGRect(x: 0, y: Int(kDeviceHeight) - kTabBarHeight - SharedData.bottomSafeAreaHeight - Int(GADAdSizeBanner.size.height) - 12, width: Int(kDeviceWidth), height: Int(GADAdSizeBanner.size.height) + 12)
            
            // Add the background to the view and the banner ad to the background
            self.view.addSubview(self.bannerBackgroundView)
            self.bannerBackgroundView.contentView.addSubview(bannerView)
            
            // Move it down so it is hidden
            self.bannerBackgroundView.transform = CGAffineTransform(translationX: 0, y: self.bannerBackgroundView.frame.size.height + 5)
            
            // Animate the ad up
            UIView.animate(withDuration: 0.25, animations: {
                self.bannerBackgroundView.transform = CGAffineTransform(translationX: 0, y: 0)
                if (self.addButton != nil)
                {
                    self.addButton.transform = CGAffineTransform(translationX: 0, y: -62)
                }
            })
            { (finished) in
                
            }
        }
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error)
    {
        print("Google Banner Ad Failed")
        
        // Added for Nimbus
        if (bannerBackgroundView != nil)
        {
            bannerBackgroundView.removeFromSuperview()
            bannerBackgroundView = nil
        }
    }
    
    private func clearBannerAd()
    {
        // Added for Nimbus
        dynamicPriceManager.cancelRefresh()
        
        if (googleBannerAdView != nil)
        {
            googleBannerAdView.removeFromSuperview()
            googleBannerAdView = nil
            
            if (bannerBackgroundView != nil)
            {
                bannerBackgroundView.removeFromSuperview()
                bannerBackgroundView = nil
            }
            
            if (addButton != nil)
            {
                // Animate the addButtonDown
                UIView.animate(withDuration: 0.16, animations: {

                    if (self.addButton != nil)
                    {
                        self.addButton.transform = CGAffineTransform(translationX: 0, y: 0)
                    }
                })
                { (finished) in
                    
                }
            }
        }
    }

    // MARK: - Ad Timer
    
    @objc private func adTimerExpired()
    {
        self.loadBannerViews()
    }
    
    // MARK: - App Entered Background Notification
    
    @objc private func applicationDidEnterBackground()
    {
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
        
        self.clearBannerAd()
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        trackingGuid = NSUUID().uuidString
        
        userTeamRole = MiscHelper.userTeamRole(schoolId: self.selectedTeam!.schoolId, allSeasonId: self.selectedTeam!.allSeasonId)
        print(userTeamRole)
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        // Explicitly set the header view size. The items within the view are pinned to the bottom
        navView.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight + kNavBarHeight)
        rosterTableView.frame = CGRect(x: 0, y: Int(navView.frame.size.height), width: Int(kDeviceWidth), height: Int(kDeviceHeight) - Int(navView.frame.size.height) - SharedData.bottomSafeAreaHeight - kTabBarHeight)
        noRosterView.frame = CGRect(x: 0, y: Int(navView.frame.size.height), width: Int(kDeviceWidth), height: Int(kDeviceHeight) - Int(navView.frame.size.height) - SharedData.bottomSafeAreaHeight - kTabBarHeight)
        
        let hexColorString = self.selectedTeam?.teamColor
        
        let currentTeamColor = ColorHelper.color(fromHexString: hexColorString, colorCorrection: true)!
        navView.backgroundColor = currentTeamColor
        
        // Add the + button to the lower right corner if a team admin
        userIsAdmin = MiscHelper.isUserAnAdmin(schoolId: self.selectedTeam!.schoolId, allSeasonId: self.selectedTeam!.allSeasonId)

        if (userIsAdmin == true)
        {
            addButton = UIButton(type: .custom)
            addButton.frame = CGRect(x: Int(kDeviceWidth) - 76, y: Int(rosterTableView.frame.origin.y) + Int(rosterTableView.frame.size.height) - 76, width: 60, height: 60)
            addButton.layer.cornerRadius = addButton.frame.size.width / 2
            addButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.33).cgColor
            addButton.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
            addButton.layer.shadowOpacity = 1.0
            addButton.layer.shadowRadius = 4.0
            addButton.clipsToBounds = false
            addButton.backgroundColor = currentTeamColor
            addButton.setImage(UIImage(named: "WhitePlus"), for: .normal)
            addButton.addTarget(self, action: #selector(addButtonTouched), for: .touchUpInside)
            self.view.addSubview(addButton)
        }
        
        // Instantiate the three header views
        let topHeaderNib = Bundle.main.loadNibNamed("RosterTopHeaderTableViewCell", owner: self, options: nil)
        topHeaderView = topHeaderNib![0] as? RosterTopHeaderTableViewCell
        topHeaderView.rosterSortButton.menu = sortMenu
        topHeaderView.rosterSortButton.showsMenuAsPrimaryAction = true
        topHeaderView.rosterShowDeletedButton.addTarget(self, action: #selector(rosterShowDeletedButtonTouched), for: .touchUpInside)
        topHeaderView.editButton.addTarget(self, action: #selector(editPhotoButtonTouched), for: .touchUpInside)
        topHeaderView.seasonLabel.text = "20" + self.year + " " + selectedTeam!.teamLevel + " Team"
        
        let shortTopHeaderNib = Bundle.main.loadNibNamed("RosterShortTopHeaderTableViewCell", owner: self, options: nil)
        shortTopHeaderView = shortTopHeaderNib![0] as? RosterShortTopHeaderTableViewCell
        shortTopHeaderView.rosterSortButton.menu = sortMenu
        shortTopHeaderView.rosterSortButton.showsMenuAsPrimaryAction = true
        shortTopHeaderView.rosterShowDeletedButton.addTarget(self, action: #selector(rosterShowDeletedButtonTouched), for: .touchUpInside)
        shortTopHeaderView.addButton.addTarget(self, action: #selector(addPhotoButtonTouched), for: .touchUpInside)
        shortTopHeaderView.seasonLabel.text = "20" + self.year + " " + selectedTeam!.teamLevel + " Team"
        shortTopHeaderView.loadButtonTitleText()
        
        if (userIsAdmin == false)
        {
            topHeaderView.editButton.isHidden = true
            topHeaderView.rosterShowDeletedButton.isHidden = true
            shortTopHeaderView.rosterShowDeletedButton.isHidden = true
        }
        
        let staffHeaderNib = Bundle.main.loadNibNamed("RosterStaffHeaderTableViewCell", owner: self, options: nil)
        staffHeaderView = staffHeaderNib![0] as? RosterStaffHeaderTableViewCell
        staffHeaderView.seasonLabel.text = "20" + self.year + " " + " Staff"
        
        let staffFooterNib = Bundle.main.loadNibNamed("RosterStaffFooterTableViewCell", owner: self, options: nil)
        staffFooterView = staffFooterNib![0] as? RosterStaffFooterTableViewCell
        staffFooterView.containerView.layer.cornerRadius = 12
        staffFooterView.containerView.clipsToBounds = true
        staffFooterView.suggestButton.addTarget(self, action: #selector(suggestButtonTouched), for: .touchUpInside)
        
        // Load the best image into the noRosterBackground
        if (SharedData.deviceAspectRatio as! AspectRatio == AspectRatio.high)
        {
            noRosterBackgroundImageView.image = UIImage(named: "NoRosterBackgroundHighAspect")
        }
        else
        {
            noRosterBackgroundImageView.image = UIImage(named: "NoRosterBackgroundMedAspect")
        }
        
        noRosterInviteCoachButton.layer.cornerRadius = 8
        noRosterInviteCoachButton.clipsToBounds = true
        noRosterInviteCoachButton.backgroundColor = currentTeamColor
        
        // Change the button text, title text, and description text for previous seasons
        if (self.selectedYearIndex != 0)
        {
            noRosterInviteCoachButton.setTitle("SUBMIT HEAD COACH NAME", for: .normal)
            noRosterTitleLabel.text = "Who was the head coach?"
            noRosterDescriptionLabel.text = "If you know the head coach's name, send it to the MaxPreps team and they can make the update."
        }
        
        rosterTableView.isHidden = true
        noRosterView.isHidden = true
        
        self.deleteTeamPhoto(updateServer: false)
        
        self.getRosters(sort: "0")
        
        // Add an observer for the app going into the background
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mpBlackColor(), .font: UIFont.mpSemiBoldFontWith(size: kNavBarFontSize)]
        
        
        if ((addAthleteVC != nil) || (editAthleteVC != nil) || (addStaffVC != nil) || (editStaffVC != nil))
        {
            self.getRosters(sort: "0")
        }
        
        // Show the ad
        self.loadBannerViews()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
        
        self.clearBannerAd()
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
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
}
