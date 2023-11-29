//
//  OldStaffDetailViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 11/17/21.
//

import UIKit
import AVFoundation
import GoogleMobileAds
//import MoPubAdapter
import DTBiOSSDK
import AdSupport
import AppTrackingTransparency

class OldStaffDetailViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, StaffStatsTableViewCellDelegate, DTBAdCallback, GADBannerViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var floatingContainerView: UIView!
    @IBOutlet weak var staffContainerView: UIView!
    @IBOutlet weak var staffImageContainerView: UIView!
    @IBOutlet weak var staffImageView: UIImageView!
    @IBOutlet weak var floatingTitleLabel: UILabel!
    @IBOutlet weak var floatingSubtitleLabel: UILabel!
    
    @IBOutlet weak var staffTableView: UITableView!
    
    var teamColor = ""
    var selectedStaff : RosterStaff?
    
    private var bottomTabBarPad = 0
    private var tableHasTwoSections = false
    private var profileData = [:] as Dictionary<String,Any>
    
    private var googleBannerAdView: GAMBannerView!
    private var bannerBackgroundView: UIVisualEffectView! //UIImageView!
    
    private var trackingGuid = ""
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
        NimbusBidder(request: .forBannerAd(position: "career")),
        APSBidder(adLoader: apsLoader)
    ]
    
    lazy var dynamicPriceManager = DynamicPriceManager(bidders: bidders, refreshInterval: TimeInterval(kNimbusAdTimerValue))
    
    // MARK: - Get Staff Details
    
    private func getStaffDetails()
    {
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
                
        RosterFeeds.getStaffDetails(staffUserId: self.selectedStaff!.userId) { result, error in
            
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
                print("Get Staff Details Success")
                
                self.profileData = result!
                
                if (self.profileData.count > 0)
                {
                    let myTeams = self.profileData["quickStats"] as! Array<Dictionary<String,Any>>
                    if (myTeams.count > 0)
                    {
                        self.tableHasTwoSections = true
                    }
                    else
                    {
                        self.staffTableView.isScrollEnabled = false
                    }
                }
                    
                self.staffTableView.reloadData()
            }
            else
            {
                print("Get Details Failed")
            }
        }
    }
    
    // MARK: - Show Web Browser
    
    func showWebBrowser(urlString: String, title: String, showShareButton: Bool, showLoading: Bool, whiteHeader: Bool)
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
        var tabBarVisible = false
        if (self.tabBarController?.tabBar.isHidden == false)
        {
            tabBarVisible = true
        }
        webVC.titleColor = UIColor.mpBlackColor()
        webVC.navColor = UIColor.mpWhiteColor()
        webVC.allowRotation = false
        webVC.showShareButton = showShareButton
        webVC.showScrollIndicators = false
        webVC.showLoadingOverlay = showLoading
        webVC.showBannerAd = false
        webVC.tabBarVisible = tabBarVisible
        webVC.enableAdobeQueryParameter = true
        
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if (self.tableHasTwoSections == true)
        {
            return 2
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (indexPath.section == 0)
        {
            // Calculate the height of the cell based upon the bio text height
            let bio = self.profileData["bio"] as? String ?? ""
            var bioTextHeight = 0.0
            
            if (bio.count > 0)
            {
                bioTextHeight = bio.height(withConstrainedWidth: (kDeviceWidth - 40), font: UIFont.mpRegularFontWith(size: 15))
                
            }
            
            let cellHeight = 57.0 + bioTextHeight + 17.0 + 165.0
            
            // Reduce the height if the Twitter and Facebook links are empty
            var facebookProfile = ""
            var twitterHandle = ""
            
            if (self.profileData["twitterHandle"] != nil)
            {
                twitterHandle = self.profileData["twitterHandle"] as! String
            }
            
            if (self.profileData["facebookUrl"] != nil)
            {
                facebookProfile = self.profileData["facebookUrl"] as! String
            }
            
            if (facebookProfile.count > 0) || (twitterHandle.count > 0)
            {
                return cellHeight
            }
            else
            {
                return cellHeight - 30.0
            }
        }
        else
        {
            return 464
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if (section == 0)
        {
            return staffContainerView.frame.size.height// - 12
        }
        else
        {
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (section == 1)
        {
            return 16 + 62 // Ad pad
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
            // The top header is the same size as the athleteContainerView
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: staffContainerView.frame.size.height - 12))
            view.backgroundColor = UIColor.mpHeaderBackgroundColor()
            
            return view
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        if (section == 1)
        {
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 16))
            footerView.backgroundColor = UIColor.mpHeaderBackgroundColor()
            return footerView
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
            // Player Info Tall Cell (Includes the bio label)
            var cell = tableView.dequeueReusableCell(withIdentifier: "StaffInfoTableViewCell") as? StaffInfoTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("StaffInfoTableViewCell", owner: self, options: nil)
                cell = nib![0] as? StaffInfoTableViewCell
            }
            
            // Resize the bioLabel and move the lower container accordingly
            cell?.bioLabel.text = ""
            let bio = self.profileData["bio"] as? String ?? ""
            var bioTextHeight = 0.0
            if (bio.count > 0)
            {
                bioTextHeight = bio.height(withConstrainedWidth: (kDeviceWidth - 40), font: (cell?.bioLabel.font)!)
                
                cell?.bioLabel.text = bio
            }
            
            cell?.bioLabel.frame = CGRect(x: 20.0, y: 57, width: kDeviceWidth - 40.0, height: bioTextHeight)
            
            print("Text Height: " + String(bioTextHeight))
            cell?.lowerContainerView.frame = CGRect(x: 0.0, y: 57.0 + bioTextHeight + 17.0, width: kDeviceWidth, height: 165.0)
            
            cell?.selectionStyle = .none
            
            //cell?.delegate = self
            cell?.loadData(data: self.profileData)
    
            cell?.elsewhereTitleLabel.isHidden = true
            cell?.facebookButton.isHidden = true
            cell?.twitterButton.isHidden = true
            
            // Add the facebook and twitter button targets
            cell?.facebookButton.addTarget(self, action: #selector(facebookButtonTouched), for: .touchUpInside)
            cell?.twitterButton.addTarget(self, action: #selector(twitterButtonTouched), for: .touchUpInside)
            
            
            // Show the twitter or facebook icons if available
            var facebookProfile = ""
            var twitterHandle = ""
            if (self.profileData["twitterHandle"] != nil)
            {
                twitterHandle = self.profileData["twitterHandle"] as! String
            }
            
            if (self.profileData["facebookUrl"] != nil)
            {
                facebookProfile = self.profileData["facebookUrl"] as! String
            }
            
            if (facebookProfile.count > 0) || (twitterHandle.count > 0)
            {
                cell?.elsewhereTitleLabel.isHidden = false
                
                if (facebookProfile.count > 0)
                {
                    cell?.facebookButton.isHidden = false
                    
                    // Move the button if no twitter
                    if (twitterHandle.count == 0)
                    {
                        cell?.facebookButton.center = (cell?.twitterButton.center)!
                    }
                }
                
                if (twitterHandle.count > 0)
                {
                    cell?.twitterButton.isHidden = false
                }
            }
            
            return cell!
        }
        else
        {
            // Use the StaffStatsTableView Cell
            var cell = tableView.dequeueReusableCell(withIdentifier: "StaffStatsTableViewCell") as? StaffStatsTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("StaffStatsTableViewCell", owner: self, options: nil)
                cell = nib![0] as? StaffStatsTableViewCell
            }
            
            cell?.selectionStyle = .none
            cell?.delegate = self
                        
            // Load the data
            let quickStats = self.profileData["quickStats"] as! Array<Dictionary<String,Any>>
            let careerInfo = self.profileData["careerInfo"] as! Dictionary<String,Any>
            cell?.loadData(staffStatsData: quickStats, info:careerInfo)
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // MARK: - StaffStatsTableViewCell Delegate
    
    func staffCollectionViewDidSelectCareer(selectedAthlete: Athlete)
    {
        let athleteDetailVC = NewAthleteDetailViewController(nibName: "NewAthleteDetailViewController", bundle: nil)
        athleteDetailVC.selectedAthlete = selectedAthlete
        
        var showSaveFavoriteButton = false
        var showRemoveFavoriteButton = false
        
        let careerInfo = self.profileData["careerInfo"] as! Dictionary<String,Any>
        let careerProfileId = careerInfo["careerId"] as! String
        
        // Check to see if the athlete is already a favorite
        let isFavorite = MiscHelper.isAthleteMyFavoriteAthlete(careerId: careerProfileId)
        
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
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func facebookButtonTouched(_ sender: UIButton)
    {
        let facebookProfile = self.profileData["facebookUrl"] as! String
        let urlString = String(format: "https://facebook.com/%@", facebookProfile)
        
        self.showWebBrowser(urlString: urlString, title: "Facebook", showShareButton: true, showLoading: true, whiteHeader: false)
    }
    
    @objc private func twitterButtonTouched(_ sender: UIButton)
    {
        let twitterHandle = self.profileData["twitterHandle"] as! String
        let urlString = String(format: "https://twitter.com/%@", twitterHandle)
        
        self.showWebBrowser(urlString: urlString, title: "Twitter", showShareButton: true, showLoading: true, whiteHeader: false)
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
        let yScroll = Int(scrollView.contentOffset.y)
        
        if (yScroll <= 0)
        {
            floatingContainerView.transform = CGAffineTransform.identity
            
            titleLabel.alpha = 0
            subtitleLabel.alpha = 0
            floatingContainerView.alpha = 1
            floatingContainerView.isHidden = false
        }
        else if ((yScroll > 0) && (yScroll < Int(floatingContainerView.frame.size.height - 12)))
        {
            floatingContainerView.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
            
            // Fade the bottom text at double the scroll rate
            let bottomFadeOut = 1.0 - (CGFloat(2 * yScroll) / CGFloat(floatingContainerView.frame.size.height - navView.frame.size.height))
            let topFadeIn = (CGFloat(1 * yScroll) / CGFloat(floatingContainerView.frame.size.height - navView.frame.size.height))
            titleLabel.alpha = topFadeIn
            subtitleLabel.alpha = topFadeIn
            floatingContainerView.alpha = bottomFadeOut
            floatingContainerView.isHidden = false
        }
        else
        {
            floatingContainerView.transform = CGAffineTransform.init(translationX: 0, y: -floatingContainerView.frame.size.height + 12)
            
            titleLabel.alpha = 1
            subtitleLabel.alpha = 1
            floatingContainerView.alpha = 0
            floatingContainerView.isHidden = true
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
        
        let guid = NSUUID()
        trackingGuid = guid.uuidString

        // This VC uses it's own Navigation bar
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        bottomTabBarPad = 0
        if (self.tabBarController?.tabBar.isHidden == false)
        {
            bottomTabBarPad = kTabBarHeight
        }

        // Explicitly set the nav and statusBar sizes.
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: Int(fakeStatusBar.frame.size.height), width: Int(kDeviceWidth), height: Int(navView.frame.size.height))
                
        floatingContainerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: floatingContainerView.frame.size.height)
        floatingContainerView.isUserInteractionEnabled = false
        
        staffContainerView.layer.cornerRadius = 12
        staffContainerView.clipsToBounds = true
        staffContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        staffImageContainerView.layer.cornerRadius = staffImageContainerView.frame.size.width / 2
        staffImageContainerView.clipsToBounds = true
        
        staffImageView.layer.cornerRadius = staffImageView.frame.size.width / 2
        staffImageView.clipsToBounds = true
        
        //itemScrollView.frame = CGRect(x: 0, y: Int(fakeStatusBar.frame.size.height + floatingContainerView.frame.size.height), width: Int(kDeviceWidth), height: Int(itemScrollView.frame.size.height))
        
        let tableViewHeight = Int(kDeviceHeight) - Int(fakeStatusBar.frame.size.height) - Int(navView.frame.size.height) - SharedData.bottomSafeAreaHeight - bottomTabBarPad + 12
         
        staffTableView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: CGFloat(tableViewHeight))
        
        self.view.bringSubviewToFront(floatingContainerView)
        
        titleLabel.alpha = 0
        subtitleLabel.alpha = 0
        
        let schoolColor = ColorHelper.color(fromHexString: self.teamColor, colorCorrection: true)!
        
        fakeStatusBar.backgroundColor = schoolColor
        navView.backgroundColor = schoolColor

        let firstName = self.selectedStaff?.userFirstName
        let lastName = self.selectedStaff?.userLastName
        titleLabel.text = firstName! + " " + lastName!
        floatingTitleLabel.text = firstName! + " " + lastName! //"Klem Kadiddlehopper"
        
        subtitleLabel.text = self.selectedStaff?.position
        floatingSubtitleLabel.text = self.selectedStaff?.position
        
        // Add the photo if it is available
        let photoUrl = selectedStaff?.photoUrl ?? ""
        
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
                        self.staffImageView.image = image
                    }
                }
            }
        }
        
        // Get the staff data
        self.getStaffDetails()
        
        // Tracking
        let trackingGuid = NSUUID().uuidString
        TrackingManager.trackState(featureName: "profile-home", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
        
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
        
        // Show the ad
        self.loadBannerViews()
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
