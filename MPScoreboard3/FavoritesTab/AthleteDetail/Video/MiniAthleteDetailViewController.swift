//
//  MiniAthleteDetailViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/4/22.
//

import UIKit

class MiniAthleteDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MiniPlayerInfoTableViewCellDelegate
{
    @IBOutlet weak var tapBackgroundView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var athleteImageView: UIImageView!
    @IBOutlet weak var imageViewBackground: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var saveFavoriteButton: UIButton!
    @IBOutlet weak var removeFavoriteButton: UIButton!
    @IBOutlet weak var athleteDetailTableView: UITableView!
    
    var taggedAthlete: AthleteWithProfile!
    var showSaveFavoriteButton = false
    var showRemoveFavoriteButton = false
    
    private var quickStatsArray = [] as Array<Dictionary<String,Any>>
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Show Web Browser
    
    func showWebBrowser(urlString: String, title: String, showShareButton: Bool, showLoading: Bool, whiteHeader: Bool, trackingKey: String, trackingContextData: Dictionary<String,Any>)
    {
        // Color changed
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
        webVC.tabBarVisible = false
        webVC.enableAdobeQueryParameter = true
        webVC.trackingKey = trackingKey
        webVC.trackingContextData = trackingContextData
        
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    // MARK: - Get Career Profile Data
    
    private func getCareerProfileData()
    {
        // Show the busy indicator
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        CareerFeeds.getCareerHome(taggedAthlete!.careerId) { (result, error) in
            
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                if (self.progressOverlay != nil)
                {
                    self.progressOverlay.hide(animated: false)
                    self.progressOverlay = nil
                }
            }
            
            if error == nil
            {
                print("Get career profile success.")
                
                // Load the quickStats array
                self.quickStatsArray = result!["quickStats"] as! Array<Dictionary<String,Any>>
                
                // Reload the table so the data is inserted
                self.athleteDetailTableView.reloadData()
            }
            else
            {
                print("Get career profile failed.")
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This career could not be found.", lastItemCancelType: false) { (tag) in
                }
            }
        }
    }
    
    // MARK: - MiniPlayerInfoTableViewCell Delegate
    
    func socialCellDidSelectItem(urlString: String, title: String)
    {
        self.showWebBrowser(urlString: urlString, title: title, showShareButton: true, showLoading: true, whiteHeader: false, trackingKey: "", trackingContextData: kEmptyTrackingContextData)
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return quickStatsArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (indexPath.row == 0)
        {
            // This code reduces the height of the cell based upon the text
            //let bioText = "This is a very long bio that takes more than one line. This is a very long bio that takes more than one line. This is a very long bio that takes more than one line."
            let bioText = taggedAthlete!.bio
            let originalLabelHeight = 80.0
            var labelHeight = 0.0
            var heightDifference = 0.0
            
            if (bioText.count > 0)
            {
                labelHeight = (bioText.size(font: UIFont.mpRegularFontWith(size: 15), width: kDeviceWidth - 96)).height
                
                // Cap the height to no more than the original size
                if (labelHeight > originalLabelHeight)
                {
                    labelHeight = originalLabelHeight
                }
                
                heightDifference = originalLabelHeight - labelHeight - 8
            }
            else
            {
                heightDifference = originalLabelHeight - 8
            }
                                
            if ((taggedAthlete!.twitterUrl != "") ||
                (taggedAthlete!.instagramUrl != "") ||
                (taggedAthlete!.snapchatUrl != "") ||
                (taggedAthlete!.tikTokUrl != "") ||
                (taggedAthlete!.facebookUrl != "") ||
                (taggedAthlete!.gameChangerUrl != "") ||
                (taggedAthlete!.hudlUrl != ""))
            {
                return (258.0 - heightDifference)
            }
            else
            {
                return (258.0 - 40.0 - heightDifference)
            }
        }
        else
        {
            return 126.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (indexPath.row == 0)
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "MiniPlayerInfoTableViewCell") as? MiniPlayerInfoTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("MiniPlayerInfoTableViewCell", owner: self, options: nil)
                cell = nib![0] as? MiniPlayerInfoTableViewCell
            }
            cell?.selectionStyle = .none
            cell?.delegate = self
            cell?.loadData(taggedAthlete!)
            
            return cell!
        }
        else
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "MiniCareerStatsTableViewCell") as? MiniCareerStatsTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("MiniCareerStatsTableViewCell", owner: self, options: nil)
                cell = nib![0] as? MiniCareerStatsTableViewCell
            }
            cell?.selectionStyle = .none
            
            // Load the data
            let quickStatsData = quickStatsArray[indexPath.row - 1]
            cell?.loadData(quickStatsData: quickStatsData)
            
            return cell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Button Methods
    
    @IBAction func closeButtonTouched(_ sender: UIButton)
    {
        self.dismiss(animated: true)
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
                let careerProfileId = self.taggedAthlete!.careerId
                
                //MBProgressHUD.showAdded(to: self.view, animated: true)
                if (self.progressOverlay == nil)
                {
                    self.progressOverlay = ProgressHUD()
                    self.progressOverlay.show(animated: false)
                }
                
                NewFeeds.saveUserFavoriteAthlete(careerProfileId) { (error) in
                    
                    if error == nil
                    {
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
                
                let careerProfileId = self.taggedAthlete!.careerId
                
                NewFeeds.deleteUserFavoriteAthlete(careerProfileId) { (error) in
                    
                    if error == nil
                    {
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
    
    // MARK: - Handle Tap
    
    @objc func handleTap(sender: UITapGestureRecognizer)
    {
        self.dismiss(animated: true)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Add a tap gesture recognizer to the tapBackgroundView
        tapBackgroundView.frame = CGRect(x: 0.0, y: 0.0, width: kDeviceWidth, height: kDeviceHeight)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tapBackgroundView.addGestureRecognizer(tapGesture)
        
        containerView.frame = CGRect(x: 16, y: (kDeviceHeight - containerView.frame.size.height) / 2.0, width: kDeviceWidth - 32, height: containerView.frame.size.height)
        
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        
        imageViewBackground.layer.cornerRadius = imageViewBackground.frame.size.height / 2.0
        imageViewBackground.clipsToBounds = true
        
        athleteImageView.layer.cornerRadius = athleteImageView.frame.size.width / 2.0
        athleteImageView.clipsToBounds = true
        
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
        
        let schoolColorString = self.taggedAthlete?.schoolColor
        let schoolColor = ColorHelper.color(fromHexString: schoolColorString, colorCorrection: true)!
        
        navView.backgroundColor = schoolColor

        let firstName = self.taggedAthlete?.firstName
        let lastName = self.taggedAthlete?.lastName
        titleLabel.text = firstName! + " " + lastName!
        
        let schoolName = self.taggedAthlete!.schoolName
        let schoolCity = self.taggedAthlete!.schoolCity
        let schoolState = self.taggedAthlete!.schoolState
                
        if (schoolName == schoolCity)
        {
            subtitleLabel.text = String(format: "%@ (%@)", schoolName, schoolState)
        }
        else
        {
            subtitleLabel.text = String(format: "%@ (%@, %@)", schoolName, schoolCity, schoolState)
        }
        
        // Add the photo if it is available
        let photoUrl = taggedAthlete!.photoUrl
        
        if (photoUrl.count > 0)
        {
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
        
        self.getCareerProfileData()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        setNeedsStatusBarAppearanceUpdate()
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

}
