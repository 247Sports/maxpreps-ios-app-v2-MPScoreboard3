//
//  NewAthleteDetailViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/3/23.
//

import UIKit
import AVFoundation
import GoogleMobileAds
//import MoPubAdapter
import DTBiOSSDK
import AdSupport
import AppTrackingTransparency

class NewAthleteDetailViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, AthleteTimelineViewDelegate, AthleteAwardsViewDelegate, AthletePhotosViewDelegate, AthleteVideosViewDelegate, AthleteNewsViewDelegate, AthleteStatsViewDelegate, CareerHistoryTableViewCellDelegate, ClaimProfileAlertViewDelegate, DTBAdCallback, GADBannerViewDelegate, AthleteDetailsMoreSelectorViewDelegate, PlayerInfoSocialTableViewCellDelegate, EditPlayerInfoViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var saveFavoriteButton: UIButton!
    @IBOutlet weak var removeFavoriteButton: UIButton!
    @IBOutlet weak var claimCareerButton: UIButton!
    @IBOutlet weak var extrasButton: UIButton!
    
    @IBOutlet weak var floatingContainerView: UIView!
    @IBOutlet weak var athleteContainerView: UIView!
    @IBOutlet weak var athleteImageContainerView: UIView!
    @IBOutlet weak var athleteImageView: UIImageView!
    @IBOutlet weak var floatingTitleLabel: UILabel!
    @IBOutlet weak var floatingSubtitleLabel: UILabel!
    @IBOutlet weak var floatingFollowersLabel: UILabel!
    @IBOutlet weak var claimedProfileImageView: UIImageView!
    @IBOutlet weak var horizontalLine: UIView!
    @IBOutlet weak var editPhotoButton: UIButton!
    
    @IBOutlet weak var itemScrollView: UIScrollView!
    private var leftShadow : UIImageView!
    private var rightShadow : UIImageView!
    
    @IBOutlet weak var careerItemsTableView: UITableView!
    
    var selectedAthlete : Athlete?
    var showSaveFavoriteButton = false
    var showRemoveFavoriteButton = false
    var athleteChanged = false
    var ftag = "" // Added for deep link attribution tracking
    var tabName = "" // Added to switch tabs when the view is loaded
    
    private var bottomTabBarPad = 0
    private var selectedItemIndex = 0
    
    private var filteredItems = [] as Array<String>
    private var playerInfoDictionary = [:] as Dictionary<String,Any>
    private var dataAvailabilityDictionary = [:] as Dictionary<String,Any>
    private var quickStatsArray = [] as Array<Dictionary<String,Any>>
    private var careerStatsArray = [] as Array<Dictionary<String,Any>>
    private var profileIsMineToEdit = false
    private var canonicalUrl = ""
    private var firstName = ""
    private var lastName = ""
    private var graduatingClass = 0
    private var gpa = -1.0
    private var satScore = -1
    private var actScore = -1
    
    private var kAllItems = ["Home", "Profile", "Timeline","Awards","Photos","Videos","News","Stats"]
    
    private var timelineView: AthleteTimelineView!
    private var awardsView: AthleteAwardsView!
    private var photosView: AthletePhotosView!
    private var videosView: AthleteVideosView!
    private var newsView: AthleteNewsView!
    private var statsView: AthleteStatsView!
    private var claimProfileAlertView: ClaimProfileAlertView!
    private var editAthleteProfileVC: EditAthleteProfileViewController!
    private var careerVideoCenterVC: CareerVideoCenterViewController!
    private var editPlayerInfoVC: EditPlayerInfoViewController!
    private var homeButton: UIButton!
    private var moreSelectorView: AthleteDetailsMoreSelectorView!
    private var profileVC: ProfileViewController!
    
    private var currentScrollValue = 0
    
    private var googleBannerAdView: GAMBannerView!
    private var bannerBackgroundView: UIVisualEffectView! //UIImageView!
    
    private var trackingGuid = ""
    private var tickTimer: Timer!
    private var progressOverlay: ProgressHUD!
    
    private var photoPicker : UIImagePickerController?
    private var cameraPicker : UIImagePickerController?
    
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
        NimbusBidder(request: .forBannerAd(position: "career")),
        APSBidder(adLoader: apsLoader)
    ]
    
    lazy var dynamicPriceManager = DynamicPriceManager(bidders: bidders, refreshInterval: TimeInterval(kNimbusAdTimerValue))
    
    // MARK: - Show Video Player
    
    private func showVideoPlayer(videoId: String, trackingKey: String, trackingContextData: Dictionary<String,Any>)
    {
        let videoPlayerVC = VideoPlayerViewController(nibName: "VideoPlayerViewController", bundle: nil)
        videoPlayerVC.videoIdString = videoId
        videoPlayerVC.trackingKey = trackingKey
        videoPlayerVC.trackingContextData = trackingContextData
        videoPlayerVC.modalPresentationStyle = .fullScreen
        self.present(videoPlayerVC, animated: true)
        {
            
        }
    }
    
    // MARK: - Show Web Browser
    
    func showWebBrowser(urlString: String, title: String, showShareButton: Bool, showLoading: Bool, whiteHeader: Bool, trackingKey: String, trackingContextData: Dictionary<String,Any>)
    {
        // Color changed
        let webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC.titleString = title
        webVC.urlString = urlString
        /*
        if (whiteHeader == false)
        {
            webVC.titleColor = UIColor.mpWhiteColor()
            webVC.navColor = self.navView.backgroundColor!
        }
        else
        {
            webVC.titleColor = UIColor.mpBlackColor()
            webVC.navColor = UIColor.mpWhiteColor()
        }
        */
        let tabBarVisible = true
        //if (self.tabBarController?.tabBar.isHidden == false)
        //{
            //tabBarVisible = true
        //}
        webVC.titleColor = UIColor.mpBlackColor()
        webVC.navColor = UIColor.mpWhiteColor()
        webVC.allowRotation = false
        webVC.showShareButton = showShareButton
        webVC.showScrollIndicators = false
        webVC.showLoadingOverlay = showLoading
        webVC.showBannerAd = false
        webVC.adId = ""
        webVC.tabBarVisible = tabBarVisible
        webVC.enableAdobeQueryParameter = true
        webVC.trackingKey = trackingKey
        webVC.trackingContextData = trackingContextData
        
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    // MARK: - Show Social Web Browser
    
    func showSocialWebBrowser(urlString: String, title: String, showShareButton: Bool, showLoading: Bool, trackingKey: String, trackingContextData: Dictionary<String,Any>)
    {
        // The only difference is the new enableMaxPrepsQueryParameters is set to false
        let webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC.titleString = title
        webVC.urlString = urlString
        webVC.titleColor = UIColor.mpBlackColor()
        webVC.navColor = UIColor.mpWhiteColor()
        webVC.allowRotation = false
        webVC.showShareButton = showShareButton
        webVC.showScrollIndicators = false
        webVC.showLoadingOverlay = showLoading
        webVC.showBannerAd = false
        webVC.adId = ""
        webVC.tabBarVisible = true
        webVC.enableAdobeQueryParameter = false
        webVC.enableMaxPrepsQueryParameters = false
        webVC.trackingKey = trackingKey
        webVC.trackingContextData = trackingContextData
        
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    // MARK: - Show Video Center
    
    private func showVideoCenter(autoOpenUpload: Bool)
    {
        // Tracking
        let firstName = self.selectedAthlete?.firstName
        let lastName = self.selectedAthlete?.lastName
        let fullName = firstName! + " " + lastName!
        let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId, kTrackingCareerIdKey:selectedAthlete?.careerId] // Added careerId in V6.3.2
                    
        //TrackingManager.trackState(featureName: "video-home", trackingGuid: trackingGuid, cData: cData as Dictionary<String, Any>)
        TrackingManager.trackState(featureName: "career-video-watch", trackingGuid: trackingGuid, cData: cData as Dictionary<String, Any>)
        
        careerVideoCenterVC = CareerVideoCenterViewController(nibName: "CareerVideoCenterViewController", bundle: nil)
        careerVideoCenterVC.selectedAthlete = self.selectedAthlete
        careerVideoCenterVC.profileIsMineToEdit = self.profileIsMineToEdit
        careerVideoCenterVC.autoOpenUpload = autoOpenUpload
        careerVideoCenterVC.trackingContextData = cData as [String : Any]
        careerVideoCenterVC.trackingKey = "videos-home"
        
        self.navigationController?.pushViewController(careerVideoCenterVC, animated: true)
    }
    
    // MARK: - Show Profile View Controller
    
    private func showProfileViewController()
    {
        profileVC = ProfileViewController(nibName: "ProfileViewController", bundle: nil)
        profileVC.selectedAthlete = self.selectedAthlete!
        profileVC.ftag = self.ftag
        self.navigationController?.pushViewController(profileVC, animated: true)
        
        /*
        // Tracking
        let firstName = self.selectedAthlete?.firstName
        let lastName = self.selectedAthlete?.lastName
        let fullName = firstName! + " " + lastName!
        let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId, kTrackingCareerIdKey:selectedAthlete?.careerId]
                    
        //TrackingManager.trackState(featureName: "video-home", trackingGuid: trackingGuid, cData: cData as Dictionary<String, Any>)
        TrackingManager.trackState(featureName: "career-video-watch", trackingGuid: trackingGuid, cData: cData as Dictionary<String, Any>)
        
        careerVideoCenterVC = CareerVideoCenterViewController(nibName: "CareerVideoCenterViewController", bundle: nil)
        careerVideoCenterVC.selectedAthlete = self.selectedAthlete
        careerVideoCenterVC.profileIsMineToEdit = self.profileIsMineToEdit
        careerVideoCenterVC.autoOpenUpload = autoOpenUpload
        careerVideoCenterVC.trackingContextData = cData as [String : Any]
        careerVideoCenterVC.trackingKey = "videos-home"
        
        self.navigationController?.pushViewController(careerVideoCenterVC, animated: true)
        */
    }
    
    // MARK: - Load Favorite Count Label
    
    private func loadFavoriteCountLabel(_ favoriteCount32: Int32)
    {
        // Unhide the followers label and load it up if the favorite count > 0
        if (favoriteCount32 > 0)
        {
            floatingFollowersLabel.isHidden = false
            
            var favoriteCountString = ""
            if (favoriteCount32 < 1000)
            {
                favoriteCountString = String(favoriteCount32)
            }
            else
            {
                let favoriteCountFloat = Float(favoriteCount32)
                let scaledFavoriteCount = favoriteCountFloat / 1000.0
                let scaledFavoriteCountString = String(format: "%1.2f", scaledFavoriteCount)
                favoriteCountString = String(format: "%@k", scaledFavoriteCountString)
            }
            var title = ""
            if (favoriteCount32 == 1)
            {
                title = String(format: "%@ Follower", favoriteCountString)
            }
            else
            {
                title = String(format: "%@ Followers", favoriteCountString)
            }
            let attributedString = NSMutableAttributedString(string: title)
            
            // Bold
            let range = title.range(of: favoriteCountString)
            let convertedRange = NSRange(range!, in: title)

            attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpBoldFontWith(size: 14), NSAttributedString.Key.foregroundColor: UIColor.mpBlackColor()], range: convertedRange)
            floatingFollowersLabel.attributedText = attributedString
        }
        else
        {
            floatingFollowersLabel.isHidden = true
        }
    }
    
    // MARK: - Get Career Profile Data
    
    private func getCareerProfileData()
    {
        let careerId = self.selectedAthlete?.careerId
        
        // Show the busy indicator
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        CareerFeeds.getCareerHome(careerId!) { (result, error) in
            
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
            
            if error == nil
            {
                print("Get career profile success.")
                
                // Load the dictionaries and arrays
                self.playerInfoDictionary = result!["playerInfo"] as! Dictionary<String,Any>
                self.dataAvailabilityDictionary = result!["dataAvailability"] as! Dictionary<String,Any>
                self.quickStatsArray = result!["quickStats"] as! Array<Dictionary<String,Any>>
                self.careerStatsArray = result!["careerStats"] as! Array<Dictionary<String,Any>>
                self.canonicalUrl = result!["canonicalUrl"] as? String ?? ""
                
                // Update the first and last name
                self.firstName = result!["firstName"] as? String ?? ""
                self.lastName = result!["lastName"] as? String ?? ""
                self.titleLabel.text = self.firstName + " " + self.lastName
                self.floatingTitleLabel.text = self.firstName + " " + self.lastName
                
                // Move the claimedProfileImageView to the right of the floatingTitleLabel text
                let font = self.floatingTitleLabel.font
                let textWidth = self.floatingTitleLabel.text!.widthOfString(usingFont: font!)
                
                if (textWidth <= self.floatingTitleLabel.frame.size.width)
                {
                    let newCenter = CGPoint(x: (kDeviceWidth / 2) + (textWidth / 2) + 13, y: self.claimedProfileImageView.center.y)
                    self.claimedProfileImageView.center = newCenter
                }
                else
                {
                    // Just put the icon to the far right
                    let newCenter = CGPoint(x: kDeviceWidth - 25, y: self.claimedProfileImageView.center.y)
                    self.claimedProfileImageView.center = newCenter
                }
                
                // Get the graduating class value (-1 if Null)
                self.graduatingClass = self.playerInfoDictionary["graduatingClass"] as? Int ?? -1
                
                // Hide the claimedProfileImageVew is needed
                let isClaimed = result!["isClaimed"] as! Bool
                
                if (isClaimed == true)
                {
                    self.claimedProfileImageView.isHidden = false
                }
                
                let favoriteCount = result!["favoriteCount"] as? NSNumber ?? NSNumber.init(integerLiteral: 0)
                let favoriteCount32 = favoriteCount.int32Value
                self.loadFavoriteCountLabel(favoriteCount32)
    
                // Add the photo if it is available
                let photoUrl = result!["photoUrl"] as! String
                
                if (photoUrl.count > 0)
                {
                    // Update the photoUrl in the selectedAthlete object so it can be used in the upload video tagged athlete screen. The user favorite athlete object doesn't have this property
                    self.selectedAthlete?.photoUrl = photoUrl
                    
                    // Get the data and make an image
                    let url = URL(string: photoUrl)
                    
                    MiscHelper.getData(from: url!) { data, response, error in
                        guard let data = data, error == nil else { return }

                        DispatchQueue.main.async()
                        {
                            let image = UIImage(data: data)
                            
                            if (image != nil)
                            {
                                self.athleteImageView.image = image
                            }
                        }
                    }
                }
                
                // Load the item selector
                self.loadItemSelector()
                
                // Reload the table so the data is inserted
                self.careerItemsTableView.reloadData()
            }
            else
            {
                print("Get career profile failed.")
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This career could not be found.", lastItemCancelType: false) { (tag) in
                }
                self.claimCareerButton.isHidden = true
                self.extrasButton.isHidden = true
                self.saveFavoriteButton.isHidden = true
                self.removeFavoriteButton.isHidden = true
            }
        }
    }
    
    // MARK: - Get Athlete Claim Eligibilty
    
    private func canAthleteBeClaimed(relationship: String)
    {
        let careerId = self.selectedAthlete?.careerId
        
        NewFeeds.getAthleteClaimEligibility(careerId: careerId!) { (result, error) in
            
            if error == nil
            {
                print("Get athlete claim eligibility success.")
                var athleteIsEligible = false
                if (relationship == "Athlete")
                {
                    athleteIsEligible = result!["isEligibleForAthleteClaim"] as! Bool
                }
                else
                {
                    athleteIsEligible = result!["isEligibleForParentClaim"] as! Bool
                }
                
                if (athleteIsEligible == true)
                {
                    self.claimCareerProfile(relationship: relationship)
                }
                else
                {
                    if (relationship == "Athlete")
                    {
                        let reason = result!["ineligibleForAthleteClaimReason"] as! String
                        print(reason)
                        
                        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: reason, lastItemCancelType: false) { (tag) in
                        }
                    }
                    else
                    {
                        let reason = result!["ineligibleForParentClaimReason"] as! String
                        let reasonType = result!["parentClaimIneligibilityType"] as? Int ?? -1 // Newer version of the feed
                        print(reason)
                        
                        if (reasonType != -1)
                        {
                            if (reasonType == 3)
                            {
                                // Point the user to the app settings to change his role to parent
                                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Update Your Role", message: "Go to Account Info in your user profile to select the correct role for yourself.", lastItemCancelType: false) { (tag) in
                                }
                            }
                            else
                            {
                                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: reason, lastItemCancelType: false) { (tag) in
                                }
                            }
                        }
                        else
                        {
                            if (reason == "User type is athlete.")
                            {
                                // Point the user to the app settings to change his role to parent
                                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Update Your Role", message: "Go to Account Info in your user profile to select the correct role for yourself.", lastItemCancelType: false) { (tag) in
                                }
                            }
                            else
                            {
                                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: reason, lastItemCancelType: false) { (tag) in
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                print("Get athlete claim eligibility failed.")
            }
        }
    }
        
    // MARK: - Get Career Contacts
    
    private func getCareerContacts()
    {
        let careerId = self.selectedAthlete?.careerId
        
        NewFeeds.getCareerContacts(careerId: careerId!) { (result, error) in
            
            if error == nil
            {
                print("Get career contacts success.")
                
                // Iterate through the results to see if any of the contacts match the userId. If none, then show the claimCareerButton
                let userId = kUserDefaults.string(forKey: kUserIdKey)!
                var matchFound = false
                for contact in result!
                {
                    let contactUserId = contact["userId"] as! String
                    
                    if (contactUserId == userId)
                    {
                        matchFound = true
                        break
                    }
                }
                // Check for other things if no match exists
                if (matchFound == false)
                {
                    self.claimCareerButton.isHidden = false
                    self.extrasButton.isHidden = true
                }
                else
                {
                    self.profileIsMineToEdit = true
                    self.extrasButton.isHidden = false
                }
            }
            else
            {
                print("Get career contacts failed.")
            }
            
            self.getCareerProfileData()
        }
    }
    
    // MARK: - Claim Career Profile
    
    private func claimCareerProfile(relationship: String)
    {
        let careerId = self.selectedAthlete?.careerId
        
        // Show the busy indicator
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.claimCareerProfile(careerId: careerId!, relationship: relationship) { error in
            
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
                print("Claim career profile success.")
                
                // Add some delay so the ClaimProfileAlertView can dismiss
                DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                { [self] in
                    
                    OverlayView.showPopupOverlay(withMessage: "Athlete Claimed")
                    {
                        // Update the page
                        self.getCareerProfileData()
                        self.claimCareerButton.isHidden = true
                        self.extrasButton.isHidden = false
                        
                        // Refresh the user permissions
                        let tabController = self.tabBarController as! TabBarController
                        tabController.getUserInfo()
                    }
                }
            }
            else
            {
                print("Claim career profile failed.")
                
                //let errorMessage = error?.localizedDescription
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to claim this athlete.", lastItemCancelType: false) { tag in
                    
                }
                
                if (relationship == "Parent")
                {
                    // Click Tracking
                    let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"claim-athlete", kClickTrackingModuleNameKey: "user preferences", kClickTrackingModuleLocationKey:"claim athlete error", kClickTrackingModuleActionKey: "impression", kClickTrackingClickTextKey:"parent claim error"]
                    
                    TrackingManager.trackEvent(featureName: "claim-pop-up-error", cData: cData)
                }
                else
                {
                    // Click Tracking
                    let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"claim-athlete", kClickTrackingModuleNameKey: "user preferences", kClickTrackingModuleLocationKey:"claim athlete error", kClickTrackingModuleActionKey: "impression", kClickTrackingClickTextKey:"athlete claim error"]
                    
                    TrackingManager.trackEvent(featureName: "claim-pop-up-error", cData: cData)
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
    
    // MARK: - Edit Profile
    
    private func editProfile()
    {
        self.hidesBottomBarWhenPushed = true
        
        editAthleteProfileVC = EditAthleteProfileViewController(nibName: "EditAthleteProfileViewController", bundle: nil)
        editAthleteProfileVC.careerId = self.selectedAthlete!.careerId
        self.navigationController?.pushViewController(editAthleteProfileVC, animated: true)
         
        self.hidesBottomBarWhenPushed = false
        
        // Tracking
        let firstName = self.selectedAthlete?.firstName
        let lastName = self.selectedAthlete?.lastName
        let fullName = firstName! + " " + lastName!
        let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId]
                    
        TrackingManager.trackState(featureName: "career-manage", trackingGuid: trackingGuid, cData: cData as Dictionary<String, Any>)
    }
    
    // MARK: - Delete Photo
    
    private func deleteCareerImage()
    {
        NewFeeds.deleteCareerImage(careerId: self.selectedAthlete!.careerId, completionHandler: { (error) in
            
            self.athleteImageView.image = UIImage(named: "Avatar")
            
            //self.updateUserInfoCareerPhotoUrl("")
            
            if (error == nil)
            {
                print("Delete User Image Success")
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
            athleteImageView.image = scaledImage
            
            guard let data = scaledImage!.jpegData(compressionQuality: 1.0) else { return }
            
            NewFeeds.saveCareerImage(careerId: self.selectedAthlete!.careerId, imageData: data) { error in
                
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
            athleteImageView.image = scaledImage
            
            guard let data = scaledImage!.jpegData(compressionQuality: 1.0) else { return }

            NewFeeds.saveCareerImage(careerId: self.selectedAthlete!.careerId, imageData: data) { error in
                
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section == 0)
        {
            return 3
        }
        else if (section == 1)
        {
            return 1
        }
        else
        {
            return self.careerStatsArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        var canEditCareer = false
        if (userId != kTestDriveUserId)
        {
            canEditCareer = MiscHelper.userCanEditSpecificCareer(careerId: self.selectedAthlete!.careerId).canEdit
        }
        
        if (indexPath.section == 0)
        {
            if (indexPath.row == 0)
            {
                // Calculate the height of the cell based upon the bio text height
                let bio = playerInfoDictionary["bio"] as? String ?? ""
                //let bio = "I keep it at 100% like I'm running a fever. I might take a break, but I won't ever need it #jamfam"
                var bioTextHeight = 0.0
                
                if (bio.count > 0)
                {
                    bioTextHeight = bio.height(withConstrainedWidth: (kDeviceWidth - 64), font: UIFont.mpRegularFontWith(size: 15))
                    return 74.0 + bioTextHeight
                }
                else
                {
                    if (canEditCareer == true)
                    {
                        return 100.0
                    }
                    else
                    {
                        return 0.0
                    }
                }
            }
            else if (indexPath.row == 1)
            {
                return 84.0
            }
            else
            {
                // Hide the cell if there are no social items and the profile can not be edited
                let twitter = playerInfoDictionary["twitterHandle"] as? String ?? ""
                let instagram = playerInfoDictionary["instagram"] as? String ?? ""
                let snapchat = playerInfoDictionary["snapchat"] as? String ?? ""
                let tikTok = playerInfoDictionary["tikTok"] as? String ?? ""
                let facebook = playerInfoDictionary["facebookProfile"] as? String ?? ""
                let gameChanger = playerInfoDictionary["gameChanger"] as? String ?? ""
                let hudl = playerInfoDictionary["hudl"] as? String ?? ""
                
                if ((twitter == "") && (instagram == "") && (snapchat == "") && (tikTok == "") && (facebook == "") && (gameChanger == "") && (hudl == "") && (canEditCareer == false))
                {
                    return 0.0
                }
                else
                {
                    return 100.0
                }
            }
        }
        else if (indexPath.section == 1)
        {
            return 423.0
        }
        else
        {
            return 160
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if (section == 0)
        {
            return athleteContainerView.frame.size.height + 64.0
        }
        else if (section == 2)
        {
            if (careerStatsArray.count > 0)
            {
                return 64.0
            }
            else
            {
                return 0.01
            }
        }
        else
        {
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (section == 0)
        {
            return 12
        }
        else if (section == 1)
        {
            return 0.01
        }
        else
        {
            // Add pad for the banner ad
            return 12 + 62
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (section == 0)
        {
            // The top header is the same size as the athleteContainerView
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: athleteContainerView.frame.size.height - 12 + 64))
            view.backgroundColor = UIColor.mpWhiteColor()
            
            // Instantiate the header view
            let headerNib = Bundle.main.loadNibNamed("PlayerInfoHeaderViewCell", owner: self, options: nil)
            let headerView = headerNib![0] as? PlayerInfoHeaderViewCell
            headerView!.frame = CGRect(x: 0, y: Int(athleteContainerView.frame.size.height), width: Int(kDeviceWidth), height: 64)
            headerView!.playerInfoEditButton.addTarget(self, action: #selector(editPlayerInfoTouched), for: .touchUpInside)
            view.addSubview(headerView!)
            
            // Show the pencil if allowed to edit this profile
            let userId = kUserDefaults.string(forKey: kUserIdKey)
            var canEditCareer = false
            if (userId != kTestDriveUserId)
            {
                canEditCareer = MiscHelper.userCanEditSpecificCareer(careerId: self.selectedAthlete!.careerId).canEdit
            }
            
            if (canEditCareer == true)
            {
                headerView!.playerInfoEditButton.isHidden = false
            }
            else
            {
                headerView!.playerInfoEditButton.isHidden = true
            }
            
            return view
        }
        else if (section == 2)
        {
            // Instantiate the header view
            let headerNib = Bundle.main.loadNibNamed("CareerStatsHeaderViewCell", owner: self, options: nil)
            let headerView = headerNib![0] as? CareerStatsHeaderViewCell
            headerView!.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 64)

            return headerView!
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        if (section == 0)
        {
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 12))
            footerView.backgroundColor = UIColor.mpHeaderBackgroundColor()
            
            let footerInnerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 12))
            footerInnerView.backgroundColor = UIColor.mpWhiteColor()
            footerInnerView.layer.cornerRadius = 12
            footerInnerView.layer.maskedCorners =  [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            footerInnerView.clipsToBounds = true
            footerView.addSubview(footerInnerView)
            return footerView
        }
        if (section == 2)
        {
            if (careerStatsArray.count > 0)
            {
                let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 12))
                footerView.backgroundColor = UIColor.mpHeaderBackgroundColor()
                
                let footerInnerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 12))
                footerInnerView.backgroundColor = UIColor.mpWhiteColor()
                footerInnerView.layer.cornerRadius = 12
                footerInnerView.layer.maskedCorners =  [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                footerInnerView.clipsToBounds = true
                footerView.addSubview(footerInnerView)
                return footerView
            }
            else
            {
                return nil
            }
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        var canEditCareer = false
        if (userId != kTestDriveUserId)
        {
            canEditCareer = MiscHelper.userCanEditSpecificCareer(careerId: self.selectedAthlete!.careerId).canEdit
        }
        
        if (indexPath.section == 0)
        {
            if (indexPath.row == 0)
            {
                // Player Info Bio Cell (Includes the bio label)
                var cell = tableView.dequeueReusableCell(withIdentifier: "PlayerInfoBioTableViewCell") as? PlayerInfoBioTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("PlayerInfoBioTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? PlayerInfoBioTableViewCell
                }
                
                cell?.selectionStyle = .none
                
                cell?.addNewButton.addTarget(self, action: #selector(editPlayerInfoTouched), for: .touchUpInside)
                cell?.addNewButton.isHidden = true
                
                let bio = playerInfoDictionary["bio"] as? String ?? ""
                //let bio = "I keep it at 100% like I'm running a fever. I might take a break, but I won't ever need it #jamfam"
                cell?.bioLabel.text = bio
                
                var bioTextHeight = 0.0
                if (bio.count > 0)
                {
                    bioTextHeight = bio.height(withConstrainedWidth: (kDeviceWidth - 64), font: (cell?.bioLabel.font)!)
                    cell?.bioLabel.frame.size = CGSize(width: kDeviceWidth - 64.0, height: bioTextHeight + 5.0)
                }
                else
                {
                    if (canEditCareer == true)
                    {
                        cell?.addNewButton.isHidden = false
                    }
                }
                
                return cell!
            }
            else if (indexPath.row == 1)
            {
                // Player Info Class Cell
                var cell = tableView.dequeueReusableCell(withIdentifier: "PlayerInfoClassTableViewCell") as? PlayerInfoClassTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("PlayerInfoClassTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? PlayerInfoClassTableViewCell
                }
                
                cell?.selectionStyle = .none
                
                let sportsPlayedString = playerInfoDictionary["sportsPlayedString"] as? String ?? ""
                cell?.sportLabel.text = sportsPlayedString
                
                let grade = playerInfoDictionary["gradeClass"] as? String ?? ""
                cell?.classLabel.text = grade
                
                return cell!
            }
            else
            {
                // Player Info Social Cell
                var cell = tableView.dequeueReusableCell(withIdentifier: "PlayerInfoSocialTableViewCell") as? PlayerInfoSocialTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("PlayerInfoSocialTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? PlayerInfoSocialTableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.delegate = self
                cell?.loadData(playerInfoDictionary, canEdit: canEditCareer)
                
                return cell!
            }
        }
        else if (indexPath.section == 1)
        {
            // Career History Cell
            var cell = tableView.dequeueReusableCell(withIdentifier: "CareerHistoryTableViewCell") as? CareerHistoryTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("CareerHistoryTableViewCell", owner: self, options: nil)
                cell = nib![0] as? CareerHistoryTableViewCell
            }
            
            cell?.selectionStyle = .none
            cell?.delegate = self

            // Load the data
            cell?.loadData(quickStatsData: quickStatsArray)
            
            return cell!
        }
        else
        {
            // New Career Stats Cell
            var cell = tableView.dequeueReusableCell(withIdentifier: "CareerStatsTableViewCell") as? CareerStatsTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("CareerStatsTableViewCell", owner: self, options: nil)
                cell = nib![0] as? CareerStatsTableViewCell
            }
            
            cell?.selectionStyle = .none
            
            let careerStat = careerStatsArray[indexPath.row]
            let sport = careerStat["sport"] as! String
            
            cell?.statsButton.setTitle(String(format: "Full %@ Stats", sport), for: .normal)
            cell?.statsButton.tag = 100 + indexPath.row
            cell?.statsButton.addTarget(self, action: #selector(careerStatsButtonTouched(_:)), for: .touchUpInside)
            
            // Load the data
            cell?.loadData(careerStatsData: careerStat)
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - CareerHistoryTableViewCell Delegate
    
    func collectionViewDidSelectItem(urlString: String, sport: String, schoolId: String, ssid: String)
    {
        // The View Full Stats button was touched
        //self.showWebBrowser(urlString: urlString, title: "Season Stats", showShareButton: true, showLoading: true)
        
        // Temporarily switch to the stats tab
        //self.athleteTimelineJumpToTab(named: "Stats")
        
        let linkInfo = ["sport":sport, "schoolId":schoolId, "ssid": ssid, "careerMode" : false] as [String : Any]
        self.deepLinkIntoStatsTab(linkInfo: linkInfo)
    }
    
    // MARK: - Deep Linking into Stats Tab
    
    private func deepLinkIntoStatsTab(linkInfo: Dictionary<String,Any>)
    {
        // Check to see if this athlete has stats
        if (filteredItems.contains("Stats") == false)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "No Stats", message: "There are no stats entered for this athlete.", lastItemCancelType: false) { (tag) in
            }
            
            return
        }
        
        // Change the font of the all of the buttons to regular, hide the underline view
        for subview in itemScrollView.subviews as Array<UIView>
        {
            if (subview is UIButton)
            {
                let button = subview as! UIButton
                button.titleLabel?.font = UIFont.mpRegularFontWith(size: 13)
                button.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
                
                let horizLine = button.subviews[0]
                horizLine.isHidden = true
                
                // Highlight the Stats button
                if (button.titleLabel?.text == "Stats")
                {
                    selectedItemIndex = button.tag - 100
                    button.titleLabel?.font = UIFont.mpBoldFontWith(size: 13)
                    button.setTitleColor(UIColor.mpBlackColor(), for: .normal)
                    
                    // Show the underline on the button
                    let horizLine = button.subviews[0]
                    horizLine.isHidden = false
                }
            }
        }
        
        
        let viewHeight = Int(kDeviceHeight) - Int(fakeStatusBar.frame.size.height) - Int(navView.frame.size.height) - Int(itemScrollView.frame.size.height) - SharedData.bottomSafeAreaHeight - bottomTabBarPad + 12
        
        careerItemsTableView.isHidden = true
        
        if (timelineView != nil)
        {
            timelineView.isHidden = true
        }
        if (awardsView != nil)
        {
            awardsView.isHidden = true
        }
        if (photosView != nil)
        {
            photosView.isHidden = true
        }
        if (videosView != nil)
        {
            videosView.isHidden = true
        }
        if (newsView != nil)
        {
            newsView.isHidden = true
        }
        // Instantiate the StatsView if needed
        if (statsView == nil)
        {
            statsView = AthleteStatsView(frame: CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height + itemScrollView.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: CGFloat(viewHeight)))
            statsView.delegate = self
            self.view.insertSubview(statsView, belowSubview: careerItemsTableView)
            
            statsView.selectedAthlete = self.selectedAthlete
            statsView.loadStatsFromLink(linkData: linkInfo)
            statsView.setTableViewScrollLocation(yScroll: 0)
            self.scrollItemSelectorToLastButton()
        }
        else
        {
            statsView.isHidden = false
            statsView.loadStatsFromLink(linkData: linkInfo)
            statsView.setTableViewScrollLocation(yScroll: 0)
            self.scrollItemSelectorToLastButton()
        }
    }
    
    // MARK: - Load Item Selector
    
    private func loadItemSelector()
    {
        selectedItemIndex = 0
        filteredItems.removeAll()
                
        // Filter out the items that are not available
        for item in kAllItems
        {
            switch item
            {
            case "Home":
                filteredItems.append(item)
            case "Profile":
                filteredItems.append(item)
            case "Timeline":
                filteredItems.append(item)
            case "Awards":
                let available = dataAvailabilityDictionary["hasAwards"] as! Bool
                if (available == true)
                {
                    filteredItems.append(item)
                }
            case "Photos":
                let available = dataAvailabilityDictionary["hasPhotos"] as! Bool
                if (available == true)
                {
                    filteredItems.append(item)
                }
            case "Videos":
                /*
                // No upload version
                let videoAvailable = dataAvailabilityDictionary["hasVideos"] as! Bool
                let hudlAvailable = dataAvailabilityDictionary["hasHudlVideos"] as! Bool
                if (videoAvailable == true) || (hudlAvailable == true)
                {
                    filteredItems.append(item)
                }
                */
                
                // Force enable the video item when the athlete is claimed by the user or the user is a std. admin
                let userIsAdmin = MiscHelper.isUserAnAdmin(schoolId: kEmptyGuid, allSeasonId: kEmptyGuid)
                if ((profileIsMineToEdit == true) || (userIsAdmin == true))
                {
                    filteredItems.append(item)
                }
                else
                {
                    let videoAvailable = dataAvailabilityDictionary["hasVideos"] as! Bool
                    let hudlAvailable = dataAvailabilityDictionary["hasHudlVideos"] as! Bool
                    if (videoAvailable == true) || (hudlAvailable == true)
                    {
                        filteredItems.append(item)
                    }
                }
                
            case "News":
                let available = dataAvailabilityDictionary["hasArticles"] as! Bool
                if (available == true)
                {
                    filteredItems.append(item)
                }
            case "Stats":
                // Added optional support since the property is not yet available in the feed  
                if let available = dataAvailabilityDictionary["hasStats"] as? Bool
                {
                    if (available == true)
                    {
                        filteredItems.append(item)
                    }
                }
            default:
                print("Default")
            }
        }
        
        // Remove existing buttons
        let itemScrollViewSubviews = itemScrollView.subviews
        for subview in itemScrollViewSubviews
        {
            subview.removeFromSuperview()
        }
        
        /*
        // Remove the shadows from to top view
        let mainSubviews = self.view.subviews
        for subview in mainSubviews
        {
            if (subview.tag == 200) || (subview.tag == 201)
            {
                subview.removeFromSuperview()
            }
        }
        */
        var overallWidth = 0
        let pad = 10
        var leftPad = 0
        let rightPad = 10
        var index = 0
        
        for item in filteredItems
        {
            let itemWidth = Int(item.widthOfString(usingFont: UIFont.mpSemiBoldFontWith(size: 13))) + (2 * pad)
            let tag = filteredItems.firstIndex(of: item)! + 100
            
            // Add the left pad to the first cell
            if (index == 0)
            {
                leftPad = 10
            }
            else
            {
                leftPad = 0
            }
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: overallWidth + leftPad, y: 0, width: itemWidth, height: Int(itemScrollView.frame.size.height))
            button.backgroundColor = .clear
            button.setTitle(item, for: .normal)
            button.tag = tag
            button.addTarget(self, action: #selector(self.itemTouched), for: .touchUpInside)
            
            if (item == "Home")
            {
                homeButton = button
            }
            
            // Add a line at the bottom of each button
            let textWidth = itemWidth - (2 * pad)
            let line = UIView(frame: CGRect(x: (button.frame.size.width - CGFloat(textWidth)) / 2.0, y: button.frame.size.height - 4, width: CGFloat(textWidth), height: 4))
            line.backgroundColor = fakeStatusBar.backgroundColor

            // Round the top corners
            line.clipsToBounds = true
            line.layer.cornerRadius = 4
            line.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            
            button.addSubview(line)
            
            if (index == 0)
            {
                button.titleLabel?.font = UIFont.mpBoldFontWith(size: 13)
                button.setTitleColor(UIColor.mpBlackColor(), for: .normal)
            }
            else
            {
                button.titleLabel?.font = UIFont.mpRegularFontWith(size: 13)
                button.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
                
                // Hide the inactive horiz line
                let horizLine = button.subviews[0]
                horizLine.isHidden = true
            }
            
            itemScrollView.addSubview(button)
            
            index += 1
            overallWidth += (itemWidth + leftPad)
        }
        
        itemScrollView.contentSize = CGSize(width: overallWidth + rightPad, height: Int(itemScrollView.frame.size.height))
        
        // Add the left and right shadows
        leftShadow = UIImageView(frame: CGRect(x: 0, y: Int(itemScrollView.frame.origin.y), width: 70, height: Int(itemScrollView.frame.size.height)))
        leftShadow.image = UIImage(named: "LeftShadowWhite")
        leftShadow.clipsToBounds = true
        leftShadow.tag = 200
        self.view.addSubview(leftShadow)
        leftShadow.isHidden = true
        
        rightShadow = UIImageView(frame: CGRect(x: Int(kDeviceWidth) - 70, y: Int(itemScrollView.frame.origin.y), width: 70, height: Int(itemScrollView.frame.size.height)))
        rightShadow.image = UIImage(named: "RightShadowWhite")
        rightShadow.clipsToBounds = true
        rightShadow.tag = 201
        self.view.addSubview(rightShadow)
        
        if (itemScrollView.contentSize.width <= itemScrollView.frame.size.width)
        {
            rightShadow.isHidden = true
        }
    }
    
    // MARK: - Scroll Item Selector to End
    
    private func scrollItemSelectorToLastButton()
    {
        // Find the location of the last button and scroll to it
        let buttons = itemScrollView.subviews
        let button = buttons.last
        
        // Add 10 pixels to the width of the last button to handle the end pad
        let buttonRect = CGRect(x: Int((button?.frame.origin.x)!) , y: 0, width: Int((button?.frame.size.width)!) + 10, height: Int((button?.frame.size.height)!))
        itemScrollView.scrollRectToVisible(buttonRect, animated: true)
    }
    
    // MARK: - ClaimProfileAlertView Delegate
    
    func closeClaimProfileAlertAfterAthleteSelectButtonTouched()
    {
        claimProfileAlertView.removeFromSuperview()
        claimProfileAlertView = nil
                
        // Check if athlete can be claimed by this user
        self.canAthleteBeClaimed(relationship: "Athlete")
        
        // Click Tracking
        let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"claim-athlete", kClickTrackingModuleNameKey: "user preferences", kClickTrackingModuleLocationKey:"claim athlete prompt", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:"Yes this is me"]
        
        TrackingManager.trackEvent(featureName: "claim-pop-up", cData: cData)
    }
    
    func closeClaimProfileAlertAfterParentSelectButtonTouched()
    {
        claimProfileAlertView.removeFromSuperview()
        claimProfileAlertView = nil
        
        // Check if athlete can be claimed by this user
        self.canAthleteBeClaimed(relationship: "Parent")
        
        // Click Tracking
        let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"claim-athlete", kClickTrackingModuleNameKey: "user preferences", kClickTrackingModuleLocationKey:"claim athlete prompt", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:"This is my child"]
        
        TrackingManager.trackEvent(featureName: "claim-pop-up", cData: cData)
    }
    
    func closeClaimProfileAlertAfterCancelButtonTouched()
    {
        claimProfileAlertView.removeFromSuperview()
        claimProfileAlertView = nil
    }
    
    // MARK: - AthleteDetailsMoreSelectorViewDelegate
    
    func athleteDetailsMoreSelectorViewDidSelectItem(index: Int)
    {
        moreSelectorView.removeFromSuperview()
        moreSelectorView = nil
        
        switch index
        {
        case 0: // Post Video
            self.showVideoCenter(autoOpenUpload: true)
            
        case 1: // Edit Profile // No longer called by the MoreSelectorViewDelegate
            self.editProfile()
            
        case 2: // Share Profile
            if (canonicalUrl.count > 0)
            {
                // Call the Bitly feed to compress the URL
                NewFeeds.getBitlyUrl(canonicalUrl) { (dictionary, error) in
          
                    var dataToShare = [kShareMessageText + self.canonicalUrl]
                    
                    if (error == nil)
                    {
                        print("Done")
                        if let shortUrl = dictionary!["data"] as? String
                        {
                            if (shortUrl.count > 0)
                            {
                                dataToShare = [kShareMessageText + shortUrl]
                            }
                        }
                    }
                    
                    let activityVC = UIActivityViewController(activityItems: dataToShare, applicationActivities: nil)
                    activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
                    activityVC.modalPresentationStyle = .fullScreen
                    self.present(activityVC, animated: true)
                }
            }
            else
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This career can not be shared.", lastItemCancelType: false) { tag in
                    
                }
            }
            
            
        default:
            return
        }
    }
    
    func athleteDetailsMoreSelectorViewDidCancel()
    {
        moreSelectorView.removeFromSuperview()
        moreSelectorView = nil
    }
    
    
    
    // MARK: - Notification Dispatcher
    
    private func notificationDispatcher(tabName: String)
    {
        // Switch tabs by simulating a button push
        switch tabName
        {
        case "Roster":
            for subview in itemScrollView.subviews as Array<UIView>
            {
                if (subview is UIButton)
                {
                    let button = subview as! UIButton
                    if (button.titleLabel?.text == "Timeline")
                    {
                        self.itemTouched(button)
                        break
                    }
                }
            }
        case "Award":
            for subview in itemScrollView.subviews as Array<UIView>
            {
                if (subview is UIButton)
                {
                    let button = subview as! UIButton
                    if (button.titleLabel?.text == "Awards")
                    {
                        self.itemTouched(button)
                        break
                    }
                }
            }
            
        case "Photogallery":
            for subview in itemScrollView.subviews as Array<UIView>
            {
                if (subview is UIButton)
                {
                    let button = subview as! UIButton
                    if (button.titleLabel?.text == "Photos")
                    {
                        self.itemTouched(button)
                        break
                    }
                }
            }
            
        case "Video", "videos":
            self.showVideoCenter(autoOpenUpload: false)
            
        case "Article":
            for subview in itemScrollView.subviews as Array<UIView>
            {
                if (subview is UIButton)
                {
                    let button = subview as! UIButton
                    if (button.titleLabel?.text == "News")
                    {
                        self.itemTouched(button)
                        break
                    }
                }
            }
            
        case "Stats":
            for subview in itemScrollView.subviews as Array<UIView>
            {
                if (subview is UIButton)
                {
                    let button = subview as! UIButton
                    if (button.titleLabel?.text == "Stats")
                    {
                        self.itemTouched(button)
                        break
                    }
                }
            }
        
        case "Academics", "Measurements", "AchievementAward", "Extracurricular":
            for subview in itemScrollView.subviews as Array<UIView>
            {
                if (subview is UIButton)
                {
                    let button = subview as! UIButton
                    if (button.titleLabel?.text == "Profile")
                    {
                        self.itemTouched(button)
                        break
                    }
                }
            }
            
        default: // Handles all of the other notification types
            return
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveFavoriteButtonTouched(_ sender: UIButton)
    {
        let favoriteAthletes = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
        
        if (favoriteAthletes != nil) && (favoriteAthletes!.count >= kMaxFavoriteAthletesCount)
        {
            let messageTitle = String(kMaxFavoriteTeamsCount) + " Athlete Limit"
            let messageText = "The maximum number of followed athletes is " + String(kMaxFavoriteAthletesCount) + ".  You must remove an athlete in order to add another."
            
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: messageTitle, message: messageText, lastItemCancelType: false) { (tag) in
                
            }
            return
        }
        
        MiscHelper.showAlert(in: self, withActionNames: ["Cancel", "Follow"], title: "Follow Athlete", message: "Do you want to follow this athlete?", lastItemCancelType: false) { (tag) in
            
            if (tag == 1)
            {
                // Click Tracking
                let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"career-follow-button-click", kClickTrackingModuleNameKey: "user preferences", kClickTrackingModuleLocationKey:"follow career prompt", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:""]
                
                TrackingManager.trackEvent(featureName: "career-follow/unfollow", cData: cData)
                
                // Save athlete code goes here
                let careerProfileId = self.selectedAthlete?.careerId
                
                //MBProgressHUD.showAdded(to: self.view, animated: true)
                if (self.progressOverlay == nil)
                {
                    self.progressOverlay = ProgressHUD()
                    self.progressOverlay.show(animated: false)
                }
                
                NewFeeds.saveUserFavoriteAthlete(careerProfileId!) { (error) in
                    
                    if error == nil
                    {
                        self.athleteChanged = true
                        
                        // Get the user favorites so the prefs get updated
                        NewFeeds.getUserFavoriteAthletes(completionHandler: { error in
                            
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
                                OverlayView.showPopupOverlay(withMessage: "Athlete Saved")
                                {
                                    
                                }
                                print("Download user favorite athletes success")
                                
                                self.saveFavoriteButton.isHidden = true
                                self.removeFavoriteButton.isHidden = false
                                self.showSaveFavoriteButton = false
                                self.showRemoveFavoriteButton = true
                            }
                            else
                            {
                                print("Download user favorite athletes error")
                            }
                        })
                        
                        //self.navigationController?.popViewController(animated: true)
                    }
                    else
                    {
                        print("Save user favorite athletes error")
                        
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
                        
                        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "There was a server error when following this athlete.", lastItemCancelType: false) { (tag) in
                            
                        }
                    }
                }
            }
        }
        
    }
    
    @IBAction func removeFavoriteButtonTouched(_ sender: UIButton)
    {
        MiscHelper.showAlert(in: self, withActionNames: ["Cancel", "Unfollow"], title: "Unfollow Athlete", message: "Do you want to unfollow this athlete?", lastItemCancelType: false) { (tag) in
            
            if (tag == 1)
            {
                // Click Tracking
                let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"career-unfollow-button-click", kClickTrackingModuleNameKey: "user preferences", kClickTrackingModuleLocationKey:"unfollow career prompt", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:""]
                
                TrackingManager.trackEvent(featureName: "career-follow/unfollow", cData: cData)
                
                // Show the busy indicator
                DispatchQueue.main.async
                {
                    //MBProgressHUD.showAdded(to: self.view, animated: true)
                    if (self.progressOverlay == nil)
                    {
                        self.progressOverlay = ProgressHUD()
                        self.progressOverlay.show(animated: false)
                    }
                }
                
                let careerProfileId = self.selectedAthlete?.careerId
                
                NewFeeds.deleteUserFavoriteAthlete(careerProfileId!) { (error) in
                    
                    if error == nil
                    {       
                        self.athleteChanged = true
                        
                        // Get the user favorites so the prefs get updated
                        NewFeeds.getUserFavoriteAthletes(completionHandler: { error in
                            
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
                                //self.navigationController?.popViewController(animated: true)
                                print("Download user favorite athletes success")
                                
                                self.saveFavoriteButton.isHidden = false
                                self.removeFavoriteButton.isHidden = true
                                self.showSaveFavoriteButton = true
                                self.showRemoveFavoriteButton = false
                            }
                            else
                            {
                                print("Download user favorite athletes error")
                            }
                        })
                    }
                    else
                    {
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
                                                
                        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "There was a server problem when unfollowing this athlete.", lastItemCancelType: false) { (tag) in
                            
                        }
                    }
                }
            }
        }
    }
    
    @objc private func itemTouched(_ sender: UIButton)
    {
        // Change the font of the all of the buttons to regular, hide the underline view
        for subview in itemScrollView.subviews as Array<UIView>
        {
            if (subview is UIButton)
            {
                let button = subview as! UIButton
                button.titleLabel?.font = UIFont.mpRegularFontWith(size: 13)
                button.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
                
                let horizLine = button.subviews[0]
                horizLine.isHidden = true
            }
        }
        
        // Set the selected item's font to bold
        selectedItemIndex = sender.tag - 100
        sender.titleLabel?.font = UIFont.mpBoldFontWith(size: 13)
        sender.setTitleColor(UIColor.mpBlackColor(), for: .normal)
        
        // Show the underline on the button
        let horizLine = sender.subviews[0]
        horizLine.isHidden = false
        
        // Instantiate the views as they are needed
        let activeItem = filteredItems[selectedItemIndex] as String
        
        let viewHeight = Int(kDeviceHeight) - Int(fakeStatusBar.frame.size.height) - Int(navView.frame.size.height) - Int(itemScrollView.frame.size.height) - SharedData.bottomSafeAreaHeight - bottomTabBarPad + 12
                 
        // Display the appropriate view
        switch activeItem
        {
        case "Home":
            careerItemsTableView.isHidden = false
            if (timelineView != nil)
            {
                timelineView.isHidden = true
            }
            if (awardsView != nil)
            {
                awardsView.isHidden = true
            }
            if (photosView != nil)
            {
                photosView.isHidden = true
            }
            if (videosView != nil)
            {
                videosView.isHidden = true
            }
            if (newsView != nil)
            {
                newsView.isHidden = true
            }
            if (statsView != nil)
            {
                statsView.isHidden = true
            }
            
        case "Profile":
            self.showProfileViewController()
            
        case "Timeline":
            careerItemsTableView.isHidden = true
            if (awardsView != nil)
            {
                awardsView.isHidden = true
            }
            if (photosView != nil)
            {
                photosView.isHidden = true
            }
            if (videosView != nil)
            {
                videosView.isHidden = true
            }
            if (newsView != nil)
            {
                newsView.isHidden = true
            }
            if (statsView != nil)
            {
                statsView.isHidden = true
            }
            if (timelineView == nil)
            {
                timelineView = AthleteTimelineView(frame: CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height + itemScrollView.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: CGFloat(viewHeight)))
                timelineView.delegate = self
                self.view.insertSubview(timelineView, belowSubview: careerItemsTableView)
                
                timelineView.selectedAthlete = self.selectedAthlete
                timelineView.getCareerTimelineData()
                
                timelineView.setTableViewScrollLocation(yScroll: currentScrollValue)
            }
            else
            {
                timelineView.isHidden = false
                timelineView.setTableViewScrollLocation(yScroll: currentScrollValue)
            }
            
            // Tracking
            let firstName = self.selectedAthlete?.firstName
            let lastName = self.selectedAthlete?.lastName
            let fullName = firstName! + " " + lastName!
            let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId]
                        
            TrackingManager.trackState(featureName: "timeline-home", trackingGuid: trackingGuid, cData: cData as Dictionary<String, Any>)
            
        case "Awards":
            careerItemsTableView.isHidden = true
            if (timelineView != nil)
            {
                timelineView.isHidden = true
            }
            if (photosView != nil)
            {
                photosView.isHidden = true
            }
            if (videosView != nil)
            {
                videosView.isHidden = true
            }
            if (newsView != nil)
            {
                newsView.isHidden = true
            }
            if (statsView != nil)
            {
                statsView.isHidden = true
            }
            if (awardsView == nil)
            {
                awardsView = AthleteAwardsView(frame: CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height + itemScrollView.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: CGFloat(viewHeight)))
                awardsView.delegate = self
                self.view.insertSubview(awardsView, belowSubview: careerItemsTableView)
                
                awardsView.selectedAthlete = self.selectedAthlete
                awardsView.getCareerAwardsData()
                
                awardsView.setCollectionViewScrollLocation(yScroll: currentScrollValue)
            }
            else
            {
                awardsView.isHidden = false
                awardsView.setCollectionViewScrollLocation(yScroll: currentScrollValue)
            }
            
            // Tracking
            let firstName = self.selectedAthlete?.firstName
            let lastName = self.selectedAthlete?.lastName
            let fullName = firstName! + " " + lastName!
            let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId]
                        
            TrackingManager.trackState(featureName: "awards-home", trackingGuid: trackingGuid, cData: cData as Dictionary<String, Any>)
            
        case "Photos":
            careerItemsTableView.isHidden = true
            if (timelineView != nil)
            {
                timelineView.isHidden = true
            }
            if (awardsView != nil)
            {
                awardsView.isHidden = true
            }
            if (videosView != nil)
            {
                videosView.isHidden = true
            }
            if (newsView != nil)
            {
                newsView.isHidden = true
            }
            if (statsView != nil)
            {
                statsView.isHidden = true
            }
            if (photosView == nil)
            {
                photosView = AthletePhotosView(frame: CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height + itemScrollView.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: CGFloat(viewHeight)))
                photosView.delegate = self
                self.view.insertSubview(photosView, belowSubview: careerItemsTableView)
                
                photosView.selectedAthlete = self.selectedAthlete
                photosView.getCareerPhotos()
                
                photosView.setCollectionViewScrollLocation(yScroll: currentScrollValue)
            }
            else
            {
                photosView.isHidden = false
                photosView.setCollectionViewScrollLocation(yScroll: currentScrollValue)
            }
            
            // Tracking
            let firstName = self.selectedAthlete?.firstName
            let lastName = self.selectedAthlete?.lastName
            let fullName = firstName! + " " + lastName!
            let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId]
                        
            TrackingManager.trackState(featureName: "photos-home", trackingGuid: trackingGuid, cData: cData as Dictionary<String, Any>)
            
        case "Videos":
            /*
            careerItemsTableView.isHidden = true
            if (timelineView != nil)
            {
                timelineView.isHidden = true
            }
            if (awardsView != nil)
            {
                awardsView.isHidden = true
            }
            if (photosView != nil)
            {
                photosView.isHidden = true
            }
            if (newsView != nil)
            {
                newsView.isHidden = true
            }
            if (statsView != nil)
            {
                statsView.isHidden = true
            }
            if (videosView == nil)
            {
                videosView = AthleteVideosView(frame: CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height + itemScrollView.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: CGFloat(viewHeight)))
                videosView.delegate = self
                self.view.insertSubview(videosView, belowSubview: careerItemsTableView)
                
                videosView.selectedAthlete = self.selectedAthlete
                videosView.getCareerVideos()
                
                videosView.setCollectionViewScrollLocation(yScroll: currentScrollValue)
            }
            else
            {
                videosView.isHidden = false
                videosView.setCollectionViewScrollLocation(yScroll: currentScrollValue)
            }
            */
            
            self.showVideoCenter(autoOpenUpload: false)
            
        case "News":
            careerItemsTableView.isHidden = true
            if (timelineView != nil)
            {
                timelineView.isHidden = true
            }
            if (awardsView != nil)
            {
                awardsView.isHidden = true
            }
            if (photosView != nil)
            {
                photosView.isHidden = true
            }
            if (videosView != nil)
            {
                videosView.isHidden = true
            }
            if (statsView != nil)
            {
                statsView.isHidden = true
            }
            if (newsView == nil)
            {
                newsView = AthleteNewsView(frame: CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height + itemScrollView.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: CGFloat(viewHeight)))
                newsView.delegate = self
                self.view.insertSubview(newsView, belowSubview: careerItemsTableView)
                
                newsView.selectedAthlete = self.selectedAthlete
                newsView.getCareerNews()
                
                newsView.setTableViewScrollLocation(yScroll: currentScrollValue)
            }
            else
            {
                newsView.isHidden = false
                newsView.setTableViewScrollLocation(yScroll: currentScrollValue)
            }
            
            // Tracking
            let firstName = self.selectedAthlete?.firstName
            let lastName = self.selectedAthlete?.lastName
            let fullName = firstName! + " " + lastName!
            let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId]
                        
            TrackingManager.trackState(featureName: "news-home", trackingGuid: trackingGuid, cData: cData as Dictionary<String, Any>)
            
        case "Stats":
            careerItemsTableView.isHidden = true
            if (timelineView != nil)
            {
                timelineView.isHidden = true
            }
            if (awardsView != nil)
            {
                awardsView.isHidden = true
            }
            if (photosView != nil)
            {
                photosView.isHidden = true
            }
            if (videosView != nil)
            {
                videosView.isHidden = true
            }
            if (newsView != nil)
            {
                newsView.isHidden = true
            }
            if (statsView == nil)
            {
                statsView = AthleteStatsView(frame: CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height + itemScrollView.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: CGFloat(viewHeight)))
                statsView.delegate = self
                self.view.insertSubview(statsView, belowSubview: careerItemsTableView)
                
                statsView.selectedAthlete = self.selectedAthlete
                statsView.getStatsNavigationHeader()
                
                statsView.setTableViewScrollLocation(yScroll: 0)
            }
            else
            {
                statsView.isHidden = false
                statsView.setTableViewScrollLocation(yScroll: 0)
            }
            
            // Tracking
            let firstName = self.selectedAthlete?.firstName
            let lastName = self.selectedAthlete?.lastName
            let fullName = firstName! + " " + lastName!
            let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId]
                        
            TrackingManager.trackState(featureName: "stats-home", trackingGuid: trackingGuid, cData: cData as Dictionary<String, Any>)
            
        default:
            print("Default")
        }
        
        /*
        // Reset the careerItemsTableView scroll position to the top and reset the transforms
        careerItemsTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        floatingContainerView.transform = CGAffineTransform.identity
        itemScrollView.transform = CGAffineTransform.identity
        leftShadow.transform = CGAffineTransform.identity
        rightShadow.transform = CGAffineTransform.identity

        titleLabel.alpha = 0
        subtitleLabel.alpha = 0
        floatingContainerView.alpha = 1
        floatingContainerView.isHidden = false
 */
    }
    /*
    @objc private func facebookButtonTouched(_ sender: UIButton)
    {
        let facebookProfile = playerInfoDictionary["facebookProfile"] as! String
        let urlString = String(format: "https://facebook.com/%@", facebookProfile)
        
        self.showWebBrowser(urlString: urlString, title: "Facebook", showShareButton: true, showLoading: true, whiteHeader: false, trackingKey: "", trackingContextData: kEmptyTrackingContextData)
    }
    
    @objc private func twitterButtonTouched(_ sender: UIButton)
    {
        let twitterHandle = playerInfoDictionary["twitterHandle"] as! String
        let urlString = String(format: "https://twitter.com/%@", twitterHandle)
        
        self.showWebBrowser(urlString: urlString, title: "Twitter", showShareButton: true, showLoading: true, whiteHeader: false, trackingKey: "", trackingContextData: kEmptyTrackingContextData)
    }
    */
    @IBAction func claimCareerButtonTouched()
    {
        if (claimProfileAlertView != nil)
        {
            claimProfileAlertView.removeFromSuperview()
            claimProfileAlertView = nil
        }
        
        claimProfileAlertView = ClaimProfileAlertView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight), color: UIColor.mpRedColor(), name: titleLabel.text, parentOnly: false)
        claimProfileAlertView.delegate = self
        
        kAppKeyWindow.rootViewController!.view.addSubview(claimProfileAlertView)
        
        // Click Tracking
        let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"claim-athlete", kClickTrackingModuleNameKey: "user preferences", kClickTrackingModuleLocationKey:"claim athlete prompt", kClickTrackingModuleActionKey: "impression", kClickTrackingClickTextKey:""]
        
        TrackingManager.trackEvent(featureName: "claim-pop-up", cData: cData)
    }
    
    /*
    @objc private func editPencilButtonTouched(_ sender: UIButton)
    {
        self.editProfile()
    }
    */
    
    @IBAction func extrasButtonTouched()
    {
        let buttonFrame = CGRect(x: kDeviceWidth - 48.0, y: navView.frame.origin.y + 20.0, width: 32.0, height: 32.0)
        
        moreSelectorView = AthleteDetailsMoreSelectorView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight), buttonFrame: buttonFrame)
        moreSelectorView.delegate = self
        
        self.view.addSubview(moreSelectorView)
    }
    
    @IBAction func editPhotoButtonTouched()
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
                self.deleteCareerImage()
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
    
    @objc private func editPlayerInfoTouched()
    {
        editPlayerInfoVC = EditPlayerInfoViewController(nibName: "EditPlayerInfoViewController", bundle: nil)
        editPlayerInfoVC.modalPresentationStyle = .overCurrentContext
        editPlayerInfoVC.delegate = self
        editPlayerInfoVC.playerInfoDictionary = self.playerInfoDictionary
        editPlayerInfoVC.firstName = self.firstName
        editPlayerInfoVC.lastName = self.lastName
        editPlayerInfoVC.careerId = self.selectedAthlete!.careerId
        editPlayerInfoVC.graduatingClass = self.graduatingClass
        self.tabBarController?.tabBar.isHidden = true
        
        self.present(editPlayerInfoVC, animated: true)
        {
            
        }
        
        // Tracking
        let firstName = self.selectedAthlete?.firstName
        let lastName = self.selectedAthlete?.lastName
        let fullName = firstName! + " " + lastName!
        let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId]
                    
        TrackingManager.trackState(featureName: "career-manage", trackingGuid: trackingGuid, cData: cData as Dictionary<String, Any>)
    }
    
    @objc private func careerStatsButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let careerStat = careerStatsArray[index]
        let sport = careerStat["sport"] as! String
        
        let linkInfo = ["sport" : sport, "careerMode" : true] as [String : Any]
        self.deepLinkIntoStatsTab(linkInfo: linkInfo)
    }
    
    // MARK: - PlayerInfoSocialDelegate Methods
    
    func socialCellDidSelectTwitter(handle: String)
    {
        print(handle)
        let urlString = String(format: "https://www.twitter.com/%@", handle)
        self.showSocialWebBrowser(urlString: urlString, title: "X", showShareButton: true, showLoading: true, trackingKey: "", trackingContextData: kEmptyTrackingContextData)
    }
    
    func socialCellDidSelectInstagram(username: String)
    {
        print(username)
        var fixedUserName = username
        
        // Remove the first occurance of @ if it exists
        if let range = username.range(of: "@")
        {
            fixedUserName = username.replacingCharacters(in: range, with: "")
        }
        let urlString = String(format: "https://www.instagram.com/%@", fixedUserName)
        self.showSocialWebBrowser(urlString: urlString, title: "Instagram", showShareButton: true, showLoading: true, trackingKey: "", trackingContextData: kEmptyTrackingContextData)
    }
    
    func socialCellDidSelectSnapchat(urlString: String)
    {
        print(urlString)
        self.showSocialWebBrowser(urlString: urlString, title: "Snapchat", showShareButton: true, showLoading: true, trackingKey: "", trackingContextData: kEmptyTrackingContextData)
    }
    
    func socialCellDidSelectTikTok(handle: String)
    {
        print(handle)
        let urlString = String(format: "https://www.tiktok.com/%@", handle)
        self.showSocialWebBrowser(urlString: urlString, title: "TikTok", showShareButton: true, showLoading: true, trackingKey: "", trackingContextData: kEmptyTrackingContextData)
    }
    
    func socialCellDidSelectFacebook(urlString: String)
    {
        print(urlString)
        self.showSocialWebBrowser(urlString: urlString, title: "Facebook", showShareButton: true, showLoading: true, trackingKey: "", trackingContextData: kEmptyTrackingContextData)
    }
    
    func socialCellDidSelectGameChanger(urlString: String)
    {
        print(urlString)
        self.showSocialWebBrowser(urlString: urlString, title: "GameChanger", showShareButton: true, showLoading: true, trackingKey: "", trackingContextData: kEmptyTrackingContextData)
    }
    
    func socialCellDidSelectHudl(urlString: String)
    {
        print(urlString)
        self.showSocialWebBrowser(urlString: urlString, title: "Hudl", showShareButton: true, showLoading: true, trackingKey: "", trackingContextData: kEmptyTrackingContextData)
    }
    
    func socialCellDidSelectItem(urlString: String, title: String)
    {
        print(urlString)
        self.showSocialWebBrowser(urlString: urlString, title: title, showShareButton: true, showLoading: true, trackingKey: "", trackingContextData: kEmptyTrackingContextData)
    }
    
    func socialCellAddNewButtonTouched()
    {
        self.editPlayerInfoTouched()
    }
    
    // MARK: - EditPlayerInfoViewController Delegate Methods
    
    func editPlayerInfoViewControllerDidSave()
    {
        self.dismiss(animated: true)
        {
            self.editPlayerInfoVC = nil
            self.tabBarController?.tabBar.isHidden = false
            
            // Refresh the career profile data
            self.getCareerProfileData()
        }
    }
    
    func editPlayerInfoViewControllerDidCancel()
    {
        self.dismiss(animated: true)
        {
            self.editPlayerInfoVC = nil
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    
    // MARK: - Subview Web, Video, and Share Delegate Methods
    
    func athleteTimelineWebButtonTouched(urlString: String, title: String)
    {
        // Tracking
        let firstName = self.selectedAthlete?.firstName
        let lastName = self.selectedAthlete?.lastName
        let fullName = firstName! + " " + lastName!
        let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId] as! Dictionary<String,String>
        
        self.showWebBrowser(urlString: urlString, title: title, showShareButton: false, showLoading: true, whiteHeader: false, trackingKey: "timeline-home", trackingContextData: cData)
    }
    
    func athleteTimelineVideoButtonTouched(videoId: String)
    {
        // Tracking
        let firstName = self.selectedAthlete?.firstName
        let lastName = self.selectedAthlete?.lastName
        let fullName = firstName! + " " + lastName!
        let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId] as! Dictionary<String,String>
        
        self.showVideoPlayer(videoId: videoId, trackingKey: "timeline-home", trackingContextData: cData)
    }
    
    func athleteTimelineShareButtonTouched(urlString: String)
    {
        // Call the Bitly feed to compress the URL
        NewFeeds.getBitlyUrl(urlString) { (dictionary, error) in
  
            var dataToShare = [kShareMessageText + urlString]
            
            if (error == nil)
            {
                print("Done")
                if let shortUrl = dictionary!["data"] as? String
                {
                    if (shortUrl.count > 0)
                    {
                        dataToShare = [kShareMessageText + shortUrl]
                    }
                }
            }
            
            let activityVC = UIActivityViewController(activityItems: dataToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
            activityVC.modalPresentationStyle = .fullScreen
            self.present(activityVC, animated: true)
        }
    }
    
    func athleteTimelineJumpToTab(named: String)
    {
        // Find the button with the provided title
        for subview in itemScrollView.subviews as Array<UIView>
        {
            if (subview is UIButton)
            {
                let button = subview as! UIButton
                
                if (button.titleLabel?.text == named)
                {
                    self.perform(#selector(itemTouched(_:)), with: button)
                    
                    if (named == "Stats")
                    {
                        self.scrollItemSelectorToLastButton()
                    }
                }
            }
        }
    }
    
    func athletePhotosWebButtonTouched(urlString: String)
    {
        // Tracking
        let firstName = self.selectedAthlete?.firstName
        let lastName = self.selectedAthlete?.lastName
        let fullName = firstName! + " " + lastName!
        let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId] as! Dictionary<String,String>
        
        self.showWebBrowser(urlString: urlString, title: "Photo Gallery", showShareButton: false, showLoading: true, whiteHeader: false, trackingKey: "photos-home", trackingContextData: cData)
    }
    
    func athleteVideosPlayButtonTouched(videoId: String)
    {
        // Tracking
        let firstName = self.selectedAthlete?.firstName
        let lastName = self.selectedAthlete?.lastName
        let fullName = firstName! + " " + lastName!
        let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId] as! Dictionary<String,String>
        
        self.showVideoPlayer(videoId: videoId, trackingKey: "video-home", trackingContextData: cData)
    }
    
    func athleteNewsWebButtonTouched(urlString: String, title: String)
    {
        // Tracking
        let firstName = self.selectedAthlete?.firstName
        let lastName = self.selectedAthlete?.lastName
        let fullName = firstName! + " " + lastName!
        let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId] as! Dictionary<String,String>
        
        self.showWebBrowser(urlString: urlString, title: title, showShareButton: false, showLoading: true, whiteHeader: false, trackingKey: "news-home", trackingContextData: cData)
    }
    
    func athleteStatsWebButtonTouched(urlString: String, title: String, showLoading: Bool, whiteHeader: Bool)
    {
        // Tracking
        let firstName = self.selectedAthlete?.firstName
        let lastName = self.selectedAthlete?.lastName
        let fullName = firstName! + " " + lastName!
        let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId] as! Dictionary<String,String>
        
        self.showWebBrowser(urlString: urlString, title: title, showShareButton: false, showLoading: showLoading, whiteHeader: whiteHeader, trackingKey: "stats-home", trackingContextData: cData)
    }
    
    func athleteStatsSportOrSeasonChanged()
    {
        // Tracking
        let firstName = self.selectedAthlete?.firstName
        let lastName = self.selectedAthlete?.lastName
        let fullName = firstName! + " " + lastName!
        let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId]
                    
        TrackingManager.trackState(featureName: "stats-home", trackingGuid: trackingGuid, cData: cData as Dictionary<String, Any>)
    }
    
    // MARK: - Subview ScrollView Delegates
    
    private func subViewDidScroll(_ yScroll: Int)
    {
        if (yScroll <= 0)
        {
            floatingContainerView.transform = CGAffineTransform.identity
            itemScrollView.transform = CGAffineTransform.identity
            leftShadow.transform = CGAffineTransform.identity
            rightShadow.transform = CGAffineTransform.identity
            saveFavoriteButton.transform = CGAffineTransform.identity
            removeFavoriteButton.transform = CGAffineTransform.identity
            //claimCareerButton.transform = CGAffineTransform.identity
            horizontalLine.transform = CGAffineTransform.identity
            editPhotoButton.transform = CGAffineTransform.identity
    
            titleLabel.alpha = 0
            subtitleLabel.alpha = 0
            floatingContainerView.alpha = 1
            floatingContainerView.isHidden = false
            saveFavoriteButton.alpha = 1
            removeFavoriteButton.alpha = 1
            //claimCareerButton.alpha = 1
            editPhotoButton.alpha = 1
            
            currentScrollValue = 0
        }
        else if ((yScroll > 0) && (yScroll < Int(floatingContainerView.frame.size.height - itemScrollView.frame.size.height - 12)))
        {
            floatingContainerView.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
            itemScrollView.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
            leftShadow.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
            rightShadow.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
            saveFavoriteButton.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
            removeFavoriteButton.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
            //claimCareerButton.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
            horizontalLine.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
            editPhotoButton.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
            
            // Fade the bottom text at double the scroll rate
            let bottomFadeOut = 1.0 - (CGFloat(2 * yScroll) / CGFloat(floatingContainerView.frame.size.height - navView.frame.size.height))
            let topFadeIn = (CGFloat(1 * yScroll) / CGFloat(floatingContainerView.frame.size.height - navView.frame.size.height))
            titleLabel.alpha = topFadeIn
            subtitleLabel.alpha = topFadeIn
            floatingContainerView.alpha = bottomFadeOut
            saveFavoriteButton.alpha = bottomFadeOut
            removeFavoriteButton.alpha = bottomFadeOut
            //claimCareerButton.alpha = bottomFadeOut
            editPhotoButton.alpha = bottomFadeOut
            floatingContainerView.isHidden = false
            
            currentScrollValue = yScroll
        }
        else
        {
            floatingContainerView.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
            itemScrollView.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
            leftShadow.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
            rightShadow.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
            saveFavoriteButton.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
            removeFavoriteButton.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
            //claimCareerButton.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
            horizontalLine.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
            editPhotoButton.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
            
            titleLabel.alpha = 1
            subtitleLabel.alpha = 1
            floatingContainerView.alpha = 0
            floatingContainerView.isHidden = true
            saveFavoriteButton.alpha = 0
            removeFavoriteButton.alpha = 0
            //claimCareerButton.alpha = 0
            editPhotoButton.alpha = 0
            
            currentScrollValue = Int(athleteContainerView.frame.size.height)
        }
        
        // Scroll the careerItemsTableView so it matches the other tables
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
        {
            self.careerItemsTableView.contentOffset = CGPoint(x: 0, y: self.currentScrollValue)
        }
    }
    
    func athleteTimelineViewDidScroll(_ yScroll: Int)
    {
        self.subViewDidScroll(yScroll)
    }
    
    func athleteAwardsViewDidScroll(_ yScroll: Int)
    {
        self.subViewDidScroll(yScroll)
    }
    
    func athletePhotosViewDidScroll(_ yScroll: Int)
    {
        self.subViewDidScroll(yScroll)
    }
    
    func athleteVideosViewDidScroll(_ yScroll: Int)
    {
        self.subViewDidScroll(yScroll)
    }
    
    func athleteNewsViewDidScroll(_ yScroll: Int)
    {
        self.subViewDidScroll(yScroll)
    }
    
    func athleteStatsViewDidScroll(_ yScroll: Int)
    {
        self.subViewDidScroll(yScroll)
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
        let adId = kUserDefaults.value(forKey: kAthleteBannerAdIdKey) as! String
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
        }
    }

    // MARK: - Ad Timer
    
    @objc private func adTimerExpired()
    {
        self.loadBannerViews()
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if (scrollView == careerItemsTableView)
        {
            // Added this to prevent a crash if the careerData feed failed
            if (filteredItems.count == 0)
            {
                return
            }
            
            let yScroll = Int(scrollView.contentOffset.y)
            
            if (yScroll <= 0)
            {
                floatingContainerView.transform = CGAffineTransform.identity
                itemScrollView.transform = CGAffineTransform.identity
                leftShadow.transform = CGAffineTransform.identity
                rightShadow.transform = CGAffineTransform.identity
                saveFavoriteButton.transform = CGAffineTransform.identity
                removeFavoriteButton.transform = CGAffineTransform.identity
                //claimCareerButton.transform = CGAffineTransform.identity
                horizontalLine.transform = CGAffineTransform.identity
                editPhotoButton.transform = CGAffineTransform.identity
        
                titleLabel.alpha = 0
                subtitleLabel.alpha = 0
                floatingContainerView.alpha = 1
                floatingContainerView.isHidden = false
                saveFavoriteButton.alpha = 1
                removeFavoriteButton.alpha = 1
                //claimCareerButton.alpha = 1
                editPhotoButton.alpha = 1
                
                currentScrollValue = 0
            }
            else if ((yScroll > 0) && (yScroll < Int(floatingContainerView.frame.size.height - itemScrollView.frame.size.height - 12)))
            {
                floatingContainerView.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
                itemScrollView.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
                leftShadow.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
                rightShadow.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
                saveFavoriteButton.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
                removeFavoriteButton.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
                //claimCareerButton.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
                horizontalLine.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
                editPhotoButton.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
                
                // Fade the bottom text at double the scroll rate
                let bottomFadeOut = 1.0 - (CGFloat(2 * yScroll) / CGFloat(floatingContainerView.frame.size.height - navView.frame.size.height))
                let topFadeIn = (CGFloat(1 * yScroll) / CGFloat(floatingContainerView.frame.size.height - navView.frame.size.height))
                titleLabel.alpha = topFadeIn
                subtitleLabel.alpha = topFadeIn
                floatingContainerView.alpha = bottomFadeOut
                saveFavoriteButton.alpha = bottomFadeOut
                removeFavoriteButton.alpha = bottomFadeOut
                //claimCareerButton.alpha = bottomFadeOut
                editPhotoButton.alpha = bottomFadeOut
                floatingContainerView.isHidden = false
                
                currentScrollValue = yScroll
            }
            else
            {
                floatingContainerView.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
                itemScrollView.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
                leftShadow.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
                rightShadow.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
                saveFavoriteButton.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
                removeFavoriteButton.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
                //claimCareerButton.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
                horizontalLine.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
                editPhotoButton.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + itemScrollView.frame.size.height + 12)
                
                titleLabel.alpha = 1
                subtitleLabel.alpha = 1
                floatingContainerView.alpha = 0
                floatingContainerView.isHidden = true
                saveFavoriteButton.alpha = 0
                removeFavoriteButton.alpha = 0
                //claimCareerButton.alpha = 0
                editPhotoButton.alpha = 0
                
                currentScrollValue = Int(athleteContainerView.frame.size.height)
            }
        }
        
        if (scrollView == itemScrollView)
        {
            let xScroll = scrollView.contentOffset.x
            
            if (xScroll > 0)
            {
                leftShadow.isHidden = false
            }
            else
            {
                leftShadow.isHidden = true
            }
            
            if (xScroll >= scrollView.contentSize.width - scrollView.frame.size.width)
            {
                rightShadow.isHidden = true
            }
            else
            {
                rightShadow.isHidden = false
            }
        }
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
        
        // This VC uses it's own Navigation bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        bottomTabBarPad = 0
        //if (self.tabBarController?.tabBar.isHidden == false)
        //{
            bottomTabBarPad = kTabBarHeight
        //}

        // Explicitly set the nav and statusBar sizes.
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: Int(fakeStatusBar.frame.size.height), width: Int(kDeviceWidth), height: Int(navView.frame.size.height))
                
        floatingContainerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: floatingContainerView.frame.size.height)
        floatingContainerView.isUserInteractionEnabled = false
        
        athleteContainerView.layer.cornerRadius = 12
        athleteContainerView.clipsToBounds = true
        athleteContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        athleteImageContainerView.layer.cornerRadius = athleteImageContainerView.frame.size.width / 2
        athleteImageContainerView.clipsToBounds = true
        
        athleteImageView.layer.cornerRadius = athleteImageView.frame.size.width / 2
        athleteImageView.clipsToBounds = true
        
        itemScrollView.frame = CGRect(x: 0, y: Int(fakeStatusBar.frame.size.height + floatingContainerView.frame.size.height), width: Int(kDeviceWidth), height: Int(itemScrollView.frame.size.height))
        
        horizontalLine.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + floatingContainerView.frame.size.height + itemScrollView.frame.size.height, width: kDeviceWidth, height: 1.0)
        
        let tableViewHeight = Int(kDeviceHeight) - Int(fakeStatusBar.frame.size.height) - Int(navView.frame.size.height) - Int(itemScrollView.frame.size.height) - SharedData.bottomSafeAreaHeight - bottomTabBarPad + 12
         
        careerItemsTableView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height + itemScrollView.frame.size.height - 12 + 1, width: CGFloat(kDeviceWidth), height: CGFloat(tableViewHeight))
        
        self.view.bringSubviewToFront(floatingContainerView)
        self.view.bringSubviewToFront(itemScrollView)
        self.view.bringSubviewToFront(horizontalLine)
        self.view.bringSubviewToFront(saveFavoriteButton)
        self.view.bringSubviewToFront(removeFavoriteButton)
        self.view.bringSubviewToFront(claimCareerButton)
        self.view.bringSubviewToFront(editPhotoButton)
        
        titleLabel.alpha = 0
        subtitleLabel.alpha = 0
        
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        if (userId != kTestDriveUserId)
        {
            if (self.showSaveFavoriteButton == false)
            {
                saveFavoriteButton.isHidden = true
            }
            
            if (self.showRemoveFavoriteButton == false)
            {
                removeFavoriteButton.isHidden = true
            }
        }
        else
        {
            saveFavoriteButton.isHidden = true
            removeFavoriteButton.isHidden = true
        }
        
        let schoolColorString = self.selectedAthlete?.schoolColor
        let schoolColor = ColorHelper.color(fromHexString: schoolColorString, colorCorrection: true)!
        
        fakeStatusBar.backgroundColor = schoolColor
        navView.backgroundColor = schoolColor
        
        // Tint the save and remove buttons
        saveFavoriteButton.frame.origin = CGPoint(x: kDeviceWidth - 50.0, y: fakeStatusBar.frame.size.height + 58.0)
        let saveImage = UIImage(named: "SaveFavoriteIcon")?.withRenderingMode(.alwaysTemplate)
        saveFavoriteButton.tintColor = schoolColor
        saveFavoriteButton.setImage(saveImage, for: .normal)
        
        removeFavoriteButton.frame.origin = CGPoint(x: kDeviceWidth - 50.0, y: fakeStatusBar.frame.size.height + 58.0)
        let removeImage = UIImage(named: "RemoveFavoriteIcon")?.withRenderingMode(.alwaysTemplate)
        removeFavoriteButton.tintColor = schoolColor
        removeFavoriteButton.setImage(removeImage, for: .normal)

        editPhotoButton.frame.origin = CGPoint(x: (kDeviceWidth / 2.0) + 20.0, y: fakeStatusBar.frame.size.height + 90.0)

        firstName = self.selectedAthlete!.firstName
        lastName = self.selectedAthlete!.lastName
        titleLabel.text = firstName + " " + lastName
        floatingTitleLabel.text = firstName + " " + lastName //"Klem Kadiddlehopper"
        
        let schoolName = self.selectedAthlete!.schoolName
        let schoolCity = self.selectedAthlete!.schoolCity
        let schoolState = self.selectedAthlete!.schoolState
        
        subtitleLabel.text = schoolName
        
        if (schoolName == schoolCity)
        {
            let title = String(format: "%@ (%@)", schoolName, schoolState)
            let attributedString = NSMutableAttributedString(string: title)
            
            // Bold
            let range = title.range(of: schoolName)
            if (range != nil)
            {
                let convertedRange = NSRange(range!, in: title)
                
                attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpBoldFontWith(size: 14)], range: convertedRange)
                floatingSubtitleLabel.attributedText = attributedString
            }
            else
            {
                floatingSubtitleLabel.text = ""
            }
            
            //floatingSubtitleLabel.text = String(format: "%@ (%@)", schoolName, schoolState)
        }
        else
        {
            let title = String(format: "%@ (%@, %@)", schoolName, schoolCity, schoolState)
            let attributedString = NSMutableAttributedString(string: title)
            
            // Bold
            let range = title.range(of: schoolName)
            if (range != nil)
            {
                let convertedRange = NSRange(range!, in: title)
                
                attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpBoldFontWith(size: 14)], range: convertedRange)
                floatingSubtitleLabel.attributedText = attributedString
            }
            else
            {
                floatingSubtitleLabel.text = ""
            }
            //floatingSubtitleLabel.text = String(format: "%@ (%@, %@)", schoolName, schoolCity, schoolState)
        }

        claimedProfileImageView.isHidden = true
        floatingFollowersLabel.isHidden = true
        
        // Move the claimedProfileImageView to the right of the floatingTitleLabel text
        let font = floatingTitleLabel.font
        let textWidth = floatingTitleLabel.text!.widthOfString(usingFont: font!)
        
        if (textWidth <= floatingTitleLabel.frame.size.width)
        {
            let newCenter = CGPoint(x: (kDeviceWidth / 2) + (textWidth / 2) + 13, y: claimedProfileImageView.center.y)
            claimedProfileImageView.center = newCenter
        }
        else
        {
            // Just put the icon to the far right
            let newCenter = CGPoint(x: kDeviceWidth - 25, y: claimedProfileImageView.center.y)
            claimedProfileImageView.center = newCenter
        }
        
        // Get the career profile data
        //self.getCareerProfileData()
        
        // Setup the claimCareerButton
        //claimCareerButton.frame.origin = CGPoint(x: 18.0, y: fakeStatusBar.frame.size.height + 66.0)
        //claimCareerButton.setTitleColor(schoolColor, for: .normal)
        claimCareerButton.layer.cornerRadius = 8
        claimCareerButton.layer.borderWidth = 1
        claimCareerButton.layer.borderColor = UIColor.init(white: 1.0, alpha: 0.3).cgColor //schoolColor.cgColor
        claimCareerButton.clipsToBounds = true
        claimCareerButton.isHidden = true
        
        extrasButton.layer.cornerRadius = 8
        extrasButton.layer.borderWidth = 1
        extrasButton.layer.borderColor = UIColor.init(white: 1.0, alpha: 0.3).cgColor
        extrasButton.clipsToBounds = true
        extrasButton.isHidden = true
        
        // See if the "Claim" button can be shown, logged-in users only.
        if (userId != kTestDriveUserId)
        {
            self.getCareerContacts() // The getCareerProfileData API will be called in this method
        }
        else
        {
            // Added to remind guest users that they can not save the athlete
            MiscHelper.showAlert(in: self, withActionNames: ["Join", "Later"], title: "Guest Login", message: "You must be a member to add or edit your favorite teams and athletes.", lastItemCancelType: false) { tag in
                
                if (tag == 0)
                {
                    self.logoutUser()
                }
                
            }
            
            // Get the career profile data
            self.getCareerProfileData()
        }
        
        // Show/Hide the edit photo button
        var canEditCareer = false
        if (userId != kTestDriveUserId)
        {
            canEditCareer = MiscHelper.userCanEditSpecificCareer(careerId: self.selectedAthlete!.careerId).canEdit
        }
        
        editPhotoButton.isHidden = !canEditCareer
        
        
        // Tracking
        let fullName = firstName + " " + lastName
        let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId, kTrackingFtagKey: self.ftag]
                    
        TrackingManager.trackState(featureName: "career-home", trackingGuid: trackingGuid, cData: cData as Dictionary<String, Any>)
        
        // Add an observer for the app going into the background
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)

    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = false
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mpBlackColor(), .font: UIFont.mpSemiBoldFontWith(size: kNavBarFontSize)]
        
        // Show the ad
        self.loadBannerViews()

    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (tabName != "")
        {
            // Call the notification dispatcher to change tabs
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                self.notificationDispatcher(tabName: self.tabName)
                
                // Clear the tabName
                self.tabName = ""
            }
        }
        
        if (editAthleteProfileVC != nil)
        {
            editAthleteProfileVC = nil
        }
        
        if (careerVideoCenterVC != nil)
        {
            careerVideoCenterVC = nil
            
            // Reset to the home tab
            self.itemTouched(homeButton)
        }
        
        if (profileVC != nil)
        {
            profileVC = nil
            
            // Reset to the home tab
            self.itemTouched(homeButton)
        }
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
