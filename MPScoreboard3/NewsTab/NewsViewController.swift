//
//  NewsViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/1/21.
//

import UIKit
//import SwiftUI
import GoogleMobileAds
//import MoPubAdapter
import DTBiOSSDK
import AdSupport
import AppTrackingTransparency
import Qualtrics
import OTPublishersHeadlessSDK

class NewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, NewsHeaderViewCellDelegate, NewsStandingsTableViewCellDelegate, SearchSportViewControllerDelegate, NewsPhotosTableViewCellDelegate, NewsTeamRankingsTableViewCellDelegate, NewsNationalRankingsTableViewCellDelegate, NewsStatsTableViewCellDelegate, DTBAdCallback, GADBannerViewDelegate, ToolTipOneDelegate, ToolTipFiveDelegate, ToolTipSixDelegate, ToolTipSevenDelegate, ToolTipEightDelegate, CareerUploadToolTipDelegate
{ 
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var newsTableView: UITableView!
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var largeTitleLabel: UILabel!
    @IBOutlet weak var filterContainerScrollView : UIScrollView!
    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var leftTestButton: UIButton!
    
    private var profileButton : UIButton?
    private var leftShadow : UIImageView!
    private var rightShadow : UIImageView!
    private var scoreboardHeaderView : UIView!
    private var newsRefreshControl = UIRefreshControl()
    private var userProfileState = ""
    private var useNationalRankingsCell = false
    
    private var videoHeaderView: NewsVideoHeaderViewCell!
    
    private var athleteProfileVC: NewAthleteProfileViewController!
    private var fanProfileVC: NewFanProfileViewController!
    private var parentProfileVC: NewParentProfileViewController!
    private var coachProfileVC: NewCoachProfileViewController!
    private var adProfileVC: NewADProfileViewController!
    private var guestProfileVC: NewGuestProfileViewController!
    private var searchVC: SearchViewController!
    private var webVC: WebViewController!
    private var videoCenterVC: NewsVideoCenterViewController!
    private var teamDetailVC: TeamDetailViewController!
    private var athleteDetailVC: NewAthleteDetailViewController!
    private var newsFilteredVC: NewsFilteredViewController!
    private var searchSportVC: SearchSportViewController!
    private var notificationsVC: NotificationsViewController!
    private var verticalVideoVC: VerticalVideoViewController!
    
    private var toolTipOneVC: ToolTipOneViewController!
    private var toolTipFiveVC: ToolTipFiveViewController!
    private var toolTipSixVC: ToolTipSixViewController!
    private var toolTipSevenVC: ToolTipSevenViewController!
    private var toolTipEightVC: ToolTipEightViewController!
    private var careerUploadToolTipVC: CareerUploadToolTipViewController!
    private var toolTipActive = false
    
    private var bottomTabBarPad = 0
    
    private var filterArray = [] as! Array<Dictionary<String,String>>
    private var videosArray = [] as! Array<Dictionary<String,Any>>
    private var articleArray = [] as! Array<Dictionary<String,Any>>
    private var standingsArray = [] as! Array<Dictionary<String,Any>>
    private var photosArray = [] as! Array<Dictionary<String,Any>>
    private var rankingsArray = [] as! Array<Dictionary<String,Any>>
    private var statsArray = [] as! Array<Dictionary<String,Any>>
    private var videoShortsArray = [] as! Array<Dictionary<String,Any>>
    
    private var googleBannerAdView: GAMBannerView!
    private var bannerBackgroundView: UIVisualEffectView! //UIImageView!
    
    private var tickTimer: Timer!
    private var trackingGuid = ""
        
    private var skeletonOverlay: SkeletonHUD!
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
        NimbusBidder(request: .forBannerAd(position: "latest")),
        APSBidder(adLoader: apsLoader)
    ]
    
    lazy var dynamicPriceManager = DynamicPriceManager(bidders: bidders, refreshInterval: TimeInterval(kNimbusAdTimerValue))
    
    // MARK: - Get Latest Tab Items
    
    private func getLatestTabItems(favoriteTeams: Array<Dictionary<String,String>>)
    {
        if (newsRefreshControl.isRefreshing == false)
        {
            //MBProgressHUD.showAdded(to: self.view, animated: true)
            
            if (skeletonOverlay == nil)
            {
                skeletonOverlay = SkeletonHUD()
                let height = kDeviceHeight - titleContainerView.frame.origin.y - titleContainerView.frame.size.height - CGFloat(kTabBarHeight) - CGFloat(SharedData.bottomSafeAreaHeight)
                
                skeletonOverlay.show(skeletonFrame: CGRect(x: 0, y: titleContainerView.frame.origin.y + titleContainerView.frame.size.height, width: kDeviceWidth, height: height), imageType: .latest, parentView: self.view)
            }
        }
        
        NewFeeds.getLatestTabItems(favorites: favoriteTeams) { result, error in
            
            if (self.newsRefreshControl.isRefreshing == true)
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                {
                    self.newsRefreshControl.endRefreshing()
                }
            }
            else
            {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                {
                    if (self.skeletonOverlay != nil)
                    {
                        self.skeletonOverlay.hide()
                        self.skeletonOverlay = nil
                    }
                }
            }
            
            if (error == nil)
            {
                print("Get Latest Tab Items Success")
                self.videosArray = result!["videos"] as! Array<Dictionary<String,Any>>
                self.articleArray = result!["articles"] as! Array<Dictionary<String,Any>>
                self.standingsArray = result!["standings"] as! Array<Dictionary<String,Any>>
                self.photosArray = result!["photoGalleries"] as! Array<Dictionary<String,Any>>
                self.videoShortsArray = result!["videoShorts"] as! Array<Dictionary<String,Any>>
                
                print("Videos: " + String(self.videosArray.count))
                print("Articles: " + String(self.articleArray.count))
                
                //self.statsArray = [["key":"value"], ["key":"value"], ["key":"value"]]
                
                if (self.useNationalRankingsCell == false)
                {
                    if (result!["teamRankings"] != nil)
                    {
                        self.rankingsArray = result!["teamRankings"] as! Array<Dictionary<String,Any>>
                    }
                }
                else
                {
                    if (self.userProfileState == "")
                    {
                        if (result!["nationalRankings"] != nil)
                        {
                            self.rankingsArray = result!["nationalRankings"] as! Array<Dictionary<String,Any>>
                        }
                    }
                    else
                    {
                        if (result!["stateRankings"] != nil)
                        {
                            self.rankingsArray = result!["stateRankings"] as! Array<Dictionary<String,Any>>
                        }
                    }
                }
                
                // Only take the first 4 articles
                if (self.articleArray.count > 4)
                {
                    let range = 4...self.articleArray.count - 1
                    self.articleArray.removeSubrange(range)
                }
                
                // Add the VideoHeaderView once
                if (self.videoHeaderView == nil)
                {
                    if (self.videosArray.count > 0)
                    {
                        // The height is variable
                        let videoHeight = ((kDeviceWidth * 9) / 16)
                        let videoSize = CGSize(width: kDeviceWidth, height: videoHeight)
                        let videoHeaderNib = Bundle.main.loadNibNamed("NewsVideoHeaderViewCell", owner: self, options: nil)
                        self.videoHeaderView = videoHeaderNib![0] as? NewsVideoHeaderViewCell
                        self.videoHeaderView.parentVC = self
                        self.videoHeaderView.delegate = self
                        self.videoHeaderView.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: Int(videoSize.height) + 153)
                        self.videoHeaderView.trackingKey = "latest-home"
                        
                        self.videoHeaderView.loadVideoSize(videoSize)
                        self.videoHeaderView.loadData(self.videosArray, autoPlay:true)
                    }
                }
                else
                {
                    // This handles a reload after login
                    let videoHeight = ((kDeviceWidth * 9) / 16)
                    let videoSize = CGSize(width: kDeviceWidth, height: videoHeight)
                    
                    self.videoHeaderView.loadVideoSize(videoSize)
                    self.videoHeaderView.loadData(self.videosArray, autoPlay:true)
                }
            }
            else
            {
                print("Get Latest Tab Items Failed")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "We couldn't retrieve the latest news due to a server error.", lastItemCancelType: false) { tag in
                    
                }
            }
            
            self.newsTableView.reloadData()
        }
    }
    
    /*
    // MARK: - Show Tracking Dialog (test)
    
    @objc func showTrackingDialog()
    {
        // Show the tracking dialog if it has not been set
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
        {
            let status = ATTrackingManager.trackingAuthorizationStatus
            
            if (status == .notDetermined)
            {
                // Call tracking authorization
                ATTrackingManager.requestTrackingAuthorization { status in
                    
                }
            }
        }
    }
    */
    
    // MARK: - Login Finished Notification
    
    @objc func loginFinished()
    {
        self.buildSportFilters()
        self.loadUserImage()
    }
    
    // MARK: - Load User Image
    
    @objc func loadUserImage()
    {
        // Set the image to the settings icon if a Test Drive user right away
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        if (userId == kTestDriveUserId)
        {
            profileButton?.setImage(UIImage.init(named: "EmptyProfileButton"), for: .normal)
            return
        }
        
        if ((MiscHelper.userIsCoach().isCoach == false) && (MiscHelper.userIsAnAD().isAD == false))
        {
            // Load the user image or the career image
            let canEditCareer = MiscHelper.userCanEditCareer().canEdit
            
            if (canEditCareer == true)
            {
                let isAthlete = MiscHelper.userCanEditCareer().isAthlete
                let isParent = MiscHelper.userCanEditCareer().isParent
                if ((isAthlete == true) && (isParent == false))
                {
                    self.loadCareerImage()
                    return
                }
            }
        }
        
        // Get the user image
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
                        self.profileButton?.setImage(image, for: .normal)
                    }
                    else
                    {
                        let image = UIImage.init(named: "EmptyProfileButton")
                        self.profileButton?.setImage(image, for: .normal)
                    }
                }
            }
        }
        else
        {
            let image = UIImage.init(named: "EmptyProfileButton")
            self.profileButton?.setImage(image, for: .normal)
        }
    }
    
    // MARK: - Load Career Image
    
    private func loadCareerImage()
    {
        let careerPhotoUrlString = kUserDefaults.string(forKey: kUserCareerPhotoUrlKey)
        
        if (careerPhotoUrlString!.count > 0)
        {
            let url = URL(string: careerPhotoUrlString!)
            
            // Get the data and make an image
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        self.profileButton?.setImage(image, for: .normal)
                    }
                    else
                    {
                        let image = UIImage.init(named: "EmptyProfileButton")
                        self.profileButton?.setImage(image, for: .normal)
                    }
                }
            }
        }
        else
        {
            let image = UIImage.init(named: "EmptyProfileButton")
            self.profileButton?.setImage(image, for: .normal)
        }
    }
    
    // MARK: - Show Guest Profile VC
    
    private func showGuestProfileVC()
    {       
        guestProfileVC = NewGuestProfileViewController(nibName: "NewGuestProfileViewController", bundle: nil)
        let guestProfileNav = TopNavigationController()
        guestProfileNav.viewControllers = [guestProfileVC] as Array
        guestProfileNav.modalPresentationStyle = .fullScreen
        self.present(guestProfileNav, animated: true)
        {
            
        }
    }
    
    // MARK: - Show Web View Controller
    
    private func showWebViewController(urlString: String, title: String, showBannerAd: Bool, ftag: String, autoPopAfterVideoPlayerCloses: Bool)
    {
        if (videoHeaderView != nil)
        {
            videoHeaderView.stopVideo()
        }
        
        if (webVC != nil)
        {
            webVC = nil
        }
        
        //self.hidesBottomBarWhenPushed = true
        
        webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC?.titleString = title
        webVC?.urlString = urlString
        webVC?.titleColor = UIColor.mpBlackColor()
        webVC?.navColor = UIColor.mpWhiteColor()
        webVC?.allowRotation = false
        webVC?.showShareButton = true
        webVC?.showScrollIndicators = false
        webVC?.showLoadingOverlay = true
        webVC?.showBannerAd = showBannerAd
        webVC?.adId = kUserDefaults.value(forKey: kNewsBannerAdIdKey) as! String
        webVC?.tabBarVisible = true
        webVC?.enableAdobeQueryParameter = true
        webVC?.trackingContextData = kEmptyTrackingContextData
        webVC?.trackingKey = "latest-home"
        webVC?.ftag = ftag
        webVC?.autoPopAfterVideoPlayerCloses = autoPopAfterVideoPlayerCloses

        self.navigationController?.pushViewController(webVC!, animated: true)
        //self.hidesBottomBarWhenPushed = false
    }
    
    // MARK: - Show NewsFilteredVC
    
    private func showNewsFilterViewController(gender: String, sport: String, ftag: String, tabName: String)
    {
        if (videoHeaderView != nil)
        {
            videoHeaderView.stopVideo()
        }
        
        newsFilteredVC = NewsFilteredViewController(nibName: "NewsFilteredViewController", bundle: nil)
        newsFilteredVC.gender = gender
        newsFilteredVC.sport = sport
        newsFilteredVC.ftag = ftag
        newsFilteredVC.tabName = tabName

        self.navigationController?.pushViewController(newsFilteredVC, animated: true)
    }
    
    // MARK: - Show Notifications View Controller
    
    private func showNotificationsViewController(ftag: String)
    {
        notificationsVC = NotificationsViewController(nibName: "NotificationsViewController", bundle: nil)
        notificationsVC.ftag = ftag
        self.navigationController?.pushViewController(notificationsVC, animated: true)
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
            return articleArray.count
        }
        else if (section == 1)
        {
            if (self.standingsArray.count > 0)
            {
                return 1
            }
            else
            {
                return 0
            }
        }
        else if (section == 2)
        {
            if (self.photosArray.count > 0)
            {
                return 1
            }
            else
            {
                return 0
            }
        }
        else if (section == 3)
        {
            if (self.rankingsArray.count > 0)
            {
                return 1
            }
            else
            {
                return 0
            }
        }
        else if (section == 4)
        {
            if (self.statsArray.count > 0)
            {
                return 1
            }
            else
            {
                return 0
            }
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (indexPath.section == 0)
        {
            if (articleArray.count > 0)
            {
                return 132
            }
            else
            {
                return 0
            }
        }
        else if (indexPath.section == 1)
        {
            if (self.standingsArray.count > 0)
            {
                return 628
            }
            else
            {
                return 0
            }
        }
        else if (indexPath.section == 2)
        {
            if (self.photosArray.count > 0)
            {
                return 520
            }
            else
            {
                return 0
            }
        }
        else if (indexPath.section == 3)
        {
            if (self.rankingsArray.count > 0)
            {
                if (userProfileState.count == 0)
                {
                    return 516 // NewsNationalRankingsTableViewCell
                }
                else
                {
                    return 519 // NewsTeamRankingsTableViewCell
                }
            }
            else
            {
                return 0
            }
        }
        else if (indexPath.section == 4)
        {
            if (self.statsArray.count > 0)
            {
                return 560
            }
            else
            {
                return 0
            }
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if (section == 0)
        {
            if (videosArray.count > 0)
            {
                return videoHeaderView.frame.size.height
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
            if (articleArray.count > 0)
            {
                return 8
            }
            else
            {
                return 0.01
            }
        }
        else if (section == 1)
        {
            if (self.standingsArray.count > 0)
            {
                return 8
            }
            else
            {
                return 0.01
            }
        }
        else if (section == 2)
        {
            if (self.photosArray.count > 0)
            {
                return 8
            }
            else
            {
                return 0.01
            }
        }
        else if (section == 3)
        {
            if (self.rankingsArray.count > 0)
            {
                if (self.statsArray.count > 0)
                {
                    return 8
                }
                else
                {
                    return 16 + 62 // Ad pad
                }
            }
            else
            {
                return 0.01
            }
        }
        else if (section == 4)
        {
            if (self.statsArray.count > 0)
            {
                return 16 + 62 // Ad pad
            }
            else
            {
                return 0.01
            }
        }
        else
        {
            return 16 + 62 // Ad pad
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (section == 0)
        {
            if (videosArray.count > 0)
            {
                let view = UIView()
                view.addSubview(videoHeaderView)
                return view
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
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (indexPath.section == 0)
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "NewsArticleTableViewCell") as? NewsArticleTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("NewsArticleTableViewCell", owner: self, options: nil)
                cell = nib![0] as? NewsArticleTableViewCell
            }
            cell?.horizLine.isHidden = false
            cell?.selectionStyle = .none
            
            //print("Article Count: " + String(self.articleArray.count))
            //print ("Index Path: " + String(indexPath.row))
            let article = articleArray[indexPath.row]
            cell?.loadData(article)
            
            if ((indexPath.row) == (articleArray.count - 1))
            {
                cell?.horizLine.isHidden = true
                cell?.contentView.layer.cornerRadius = 12
                cell?.contentView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
                cell?.contentView.clipsToBounds = true
            }
            
            return cell!
        }
        else if (indexPath.section == 1)
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "NewsStandingsTableViewCell") as? NewsStandingsTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("NewsStandingsTableViewCell", owner: self, options: nil)
                cell = nib![0] as? NewsStandingsTableViewCell
            }

            cell?.selectionStyle = .none
            cell?.delegate = self
            
            // Get the favorites
            if let favorites = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
            {
                // Build the favorite team identifier array so a team can be quickly matched for highlighting
                
                var favoriteTeamIdentifierArray = [] as Array<String>
                
                for item in favorites
                {
                    let favorite = item as! Dictionary<String, Any>
                    
                    let gender = favorite[kNewGenderKey] as! String
                    let sport = favorite[kNewSportKey] as! String
                    let schoolId = favorite[kNewSchoolIdKey] as! String
                    let identifier = String(format: "%@_%@,%@", schoolId, gender, sport)
                                
                    favoriteTeamIdentifierArray.append(identifier)
                }
                
                cell?.favoriteTeamIdentifierArray = favoriteTeamIdentifierArray
            }

            cell?.loadData(standingsArray)
            
            return cell!
        }
        else if (indexPath.section == 2)
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "NewsPhotosTableViewCell") as? NewsPhotosTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("NewsPhotosTableViewCell", owner: self, options: nil)
                cell = nib![0] as? NewsPhotosTableViewCell
            }

            cell?.selectionStyle = .none
            cell?.delegate = self
            cell?.loadData(photosArray)
            
            return cell!
        }
        else if (indexPath.section == 3)
        {
            if (useNationalRankingsCell == true)
            {
                // Use the NewsTeamRankingsTableViewCell
                var cell = tableView.dequeueReusableCell(withIdentifier: "NewsNationalRankingsTableViewCell") as? NewsNationalRankingsTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("NewsNationalRankingsTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? NewsNationalRankingsTableViewCell
                }

                cell?.selectionStyle = .none
                cell?.delegate = self
                
                cell?.loadData(rankingsArray)
                
                return cell!
            }
            else
            {
                // Use the NewsNationalRankingsTableViewCell
                var cell = tableView.dequeueReusableCell(withIdentifier: "NewsTeamRankingsTableViewCell") as? NewsTeamRankingsTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("NewsTeamRankingsTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? NewsTeamRankingsTableViewCell
                }

                cell?.selectionStyle = .none
                cell?.delegate = self
                
                cell?.loadData(rankingsArray)
                
                return cell!
            }
        }
        else if (indexPath.section == 4)
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "NewsStatsTableViewCell") as? NewsStatsTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("NewsStatsTableViewCell", owner: self, options: nil)
                cell = nib![0] as? NewsStatsTableViewCell
            }

            cell?.selectionStyle = .none
            cell?.delegate = self
            cell?.loadData(statsArray)
            
            return cell!
        }
        else
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            
            if (cell == nil)
            {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
            }
            cell?.selectionStyle = .none
            cell?.textLabel?.text = "Cell " + String(indexPath.row)
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.section == 0)
        {
            let article = articleArray[indexPath.row]
            let urlString = article["canonicalUrl"] as! String
            
            self.showWebViewController(urlString: urlString, title: "Article", showBannerAd: true, ftag: "", autoPopAfterVideoPlayerCloses: false)
        }
    }
    
    // MARK: - Build Sport Filter Array
    
    @objc private func buildSportFilters()
    {
        // This blocks the screen from rebuilding if returning from a tool tip.
        if (toolTipActive == true)
        {
            return
        }
        
        // Block rebuilding the sport filters (preventing a video restart) if the videoPlayer was maximized (this blocks the tabBarController notification)
        // The playerIsMaximized flag extends for 1 second after the player is minimized
        if (videoHeaderView != nil)
        {
            if (videoHeaderView.playerIsMaximized == true)
            {
                return
            }
        }
        
        let allFavorites = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
        
        // Remove any favorite team that is not on the reduced sport list
        var reducedFavorites: Array<Dictionary<String,Any>> = []
        
        for item in allFavorites!
        {
            let favorite = item as! Dictionary<String,Any>
            let sport = favorite[kNewSportKey] as! String
            
            if (kLatestTabReducedSportsArray.contains(sport) == true)
            {
                reducedFavorites.append(favorite)
            }
        }
        
        // Remove duplicate lower level teams
        var uniqueFavoritesArray = [] as! Array<Dictionary<String,Any>>
        var uniqueTeams = [] as! Array<String>
        
        for reducedFavorite in reducedFavorites
        {
            let schoolId = reducedFavorite[kNewSchoolIdKey] as! String
            let gender = reducedFavorite[kNewGenderKey] as! String
            let sport = reducedFavorite[kNewSportKey] as! String
            
            let key = schoolId + "_" + gender + "_" + sport
            if (uniqueTeams.contains(key) == false)
            {
                uniqueTeams.append(key)
                uniqueFavoritesArray.append(reducedFavorite)
            }
        }
        
        filterArray.removeAll()
        
        if (uniqueFavoritesArray.count > 0)
        {
            var filterFavoriteTeams = [] as! Array<Dictionary<String,String>>
            var uniqueGenderSportArray = [] as! Array<String>
            
            // Use the user's zip code to determine which state they are in
            let userZipCode = kUserDefaults.string(forKey: kUserZipKey)
            let state = ZipCodeHelper.state(forZipCode: userZipCode) ?? ""
            
            // Refactor the reducedFavorites for the feed
            for favorite in uniqueFavoritesArray
            {
                let gender = favorite[kNewGenderKey] as! String
                let sport = favorite[kNewSportKey] as! String
                //let level = favorite[kNewLevelKey] as! String
                let schoolId = favorite[kNewSchoolIdKey] as!String
                
                let favoriteTeam = [kLatestTabFilterSportKey:sport, kLatestTabFilterGenderKey:gender, kLatestTabFilterLevelKey:"Varsity", kLatestTabFilterTeamIdKey:schoolId, kLatestTabFilterStateKey:""]
                
                filterFavoriteTeams.append(favoriteTeam)
                
                // Fill the unique sport dictionary for the buttons
                let key = gender + "_" + sport //+ "_" + level
                if (uniqueGenderSportArray.contains(key) == false)
                {
                    let filterFavorite = [kLatestTabFilterSportKey:sport, kLatestTabFilterGenderKey:gender, kLatestTabFilterLevelKey:"Varsity", kLatestTabFilterTeamIdKey:kEmptyGuid, kLatestTabFilterStateKey:state]
                    
                    filterArray.append(filterFavorite)
                    uniqueGenderSportArray.append(key)
                }
            }
            
            useNationalRankingsCell = false
            userProfileState = ""
            
            // Get the latest tab items using the favorite teams
            self.getLatestTabItems(favoriteTeams: filterFavoriteTeams)
            
            // Build the buttons
            self.addFilterButtons()
            
        }
        else
        {
            // Just make a list of teams (football, boys basketball, baseball, etc.)
            // Use the user's zip code to determine which state they are in
            let userZipCode = kUserDefaults.string(forKey: kUserZipKey)
            userProfileState = ZipCodeHelper.state(forZipCode: userZipCode) ?? ""

            useNationalRankingsCell = true
            
            let staticFavorite1 = [kLatestTabFilterSportKey:"Football", kLatestTabFilterGenderKey:"Boys", kLatestTabFilterLevelKey:"Varsity", kLatestTabFilterTeamIdKey:kEmptyGuid, kLatestTabFilterStateKey:userProfileState]
            let staticFavorite2 = [kLatestTabFilterSportKey:"Basketball", kLatestTabFilterGenderKey:"Boys", kLatestTabFilterLevelKey:"Varsity", kLatestTabFilterTeamIdKey:kEmptyGuid, kLatestTabFilterStateKey:userProfileState]
            let staticFavorite3 = [kLatestTabFilterSportKey:"Baseball", kLatestTabFilterGenderKey:"Boys", kLatestTabFilterLevelKey:"Varsity", kLatestTabFilterTeamIdKey:kEmptyGuid, kLatestTabFilterStateKey:userProfileState]
            let staticFavorite4 = [kLatestTabFilterSportKey:"Volleyball", kLatestTabFilterGenderKey:"Girls", kLatestTabFilterLevelKey:"Varsity", kLatestTabFilterTeamIdKey:kEmptyGuid, kLatestTabFilterStateKey:userProfileState]
            let staticFavorite5 = [kLatestTabFilterSportKey:"Basketball", kLatestTabFilterGenderKey:"Girls", kLatestTabFilterLevelKey:"Varsity", kLatestTabFilterTeamIdKey:kEmptyGuid, kLatestTabFilterStateKey:userProfileState]
            let staticFavorite6 = [kLatestTabFilterSportKey:"Softball", kLatestTabFilterGenderKey:"Girls", kLatestTabFilterLevelKey:"Varsity", kLatestTabFilterTeamIdKey:kEmptyGuid, kLatestTabFilterStateKey:userProfileState]

            // Get the latest tab items using the static favorite teams
            let staticFavoriteTeams = [staticFavorite1, staticFavorite2, staticFavorite3, staticFavorite4, staticFavorite5, staticFavorite6]
            self.getLatestTabItems(favoriteTeams: staticFavoriteTeams)
            
            filterArray = staticFavoriteTeams
            
            // Build the buttons
            self.addFilterButtons()
        }
    }
    
    // MARK: - Add Filter Buttons
    
    private func addFilterButtons()
    {
        // Remove existing buttons
        let filterScrollViewSubviews = filterContainerScrollView.subviews
        for subview in filterScrollViewSubviews
        {
            subview.removeFromSuperview()
        }
        
        var overallWidth = 0
        let textLeadingPad = 26
        let textTrailingPad = 16
        let leftPad = 10
        let rightPad = 10
        var index = 0
        var itemWidth = 0
        
        // Add the More button before the other buttons
        let addFilterButton = UIButton(type: .custom)
        addFilterButton.frame = CGRect(x: leftPad, y: 2, width: 80, height: 30)
        addFilterButton.backgroundColor = UIColor.mpOffWhiteNavColor()
        addFilterButton.setTitle("More", for: .normal)
        addFilterButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 14)
        addFilterButton.setTitleColor(UIColor.mpBlueColor(), for: .normal)
        addFilterButton.setImage(UIImage(named: "RoundBluePlus"), for: .normal)
        addFilterButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
        addFilterButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: -3)
        addFilterButton.layer.cornerRadius = 15
        //addFilterButton.clipsToBounds = true
        
        // Add a shadow to the button
        addFilterButton.layer.masksToBounds = false
        addFilterButton.layer.shadowColor = UIColor(white: 0.7, alpha: 1.0).cgColor
        addFilterButton.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        addFilterButton.layer.shadowRadius = 2
        addFilterButton.layer.shadowOpacity = 0.5
        
        addFilterButton.addTarget(self, action: #selector(addFilterButtonTouched), for: .touchUpInside)
        filterContainerScrollView.addSubview(addFilterButton)
        
        overallWidth += (80 + leftPad)
                
        // Iterate through the scoreboards so a button can be added for each
        for filter in filterArray
        {
            let sport = filter[kLatestTabFilterSportKey]
            let gender = filter[kLatestTabFilterGenderKey]
            let level = filter[kLatestTabFilterLevelKey]
            
            var title = ""
            
            if (level == "Varsity")
            {
                title = MiscHelper.shortGenderSportFrom(gender: gender!, sport: sport!)
            }
            else
            {
                title = MiscHelper.shortGenderSportLevelFrom(gender: gender!, sport: sport!, level: level!)
            }
            
            // Limit the title to 25 characters
            if (title.count > 25)
            {
                let substring = title.prefix(25)
                title = substring + "..."
            }
            
            itemWidth = Int(title.widthOfString(usingFont: UIFont.mpSemiBoldFontWith(size: 14))) + textLeadingPad + textTrailingPad
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: overallWidth + leftPad, y: 2, width: itemWidth, height: 30)
            button.backgroundColor = UIColor.mpOffWhiteNavColor()
            button.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 14)
            button.setTitle(title, for: .normal)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 7, bottom: 0, right: -7)
            button.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
            button.tag = 100 + index
            button.layer.cornerRadius = 15
            //button.clipsToBounds = true
                        
            // Add a shadow to the button
            button.layer.masksToBounds = false
            button.layer.shadowColor = UIColor(white: 0.7, alpha: 1.0).cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 2.0)
            button.layer.shadowRadius = 2
            button.layer.shadowOpacity = 0.5
            
            button.addTarget(self, action: #selector(self.filterButtonTouched), for: .touchUpInside)
            filterContainerScrollView.addSubview(button)
            
            // Add the sport icon on top of the button
            let sportIconImageView = UIImageView(frame: CGRect(x: 10, y: 9, width: 12, height: 12))
            sportIconImageView.isUserInteractionEnabled = true
            let image = MiscHelper.getImageForSport(sport!)
            sportIconImageView.image = image
            button.addSubview(sportIconImageView)
            
            index += 1
            overallWidth += (itemWidth + leftPad)
        }
        
        /*
        let addFilterButton = UIButton(type: .custom)
        addFilterButton.frame = CGRect(x: overallWidth + leftPad, y: 2, width: 80, height: 30)
        addFilterButton.backgroundColor = UIColor.mpOffWhiteNavColor()
        addFilterButton.setTitle("MORE", for: .normal)
        addFilterButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 12)
        addFilterButton.setTitleColor(UIColor.mpBlueColor(), for: .normal)
        addFilterButton.setImage(UIImage(named: "RoundBluePlus"), for: .normal)
        addFilterButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
        addFilterButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: -3)
        addFilterButton.layer.cornerRadius = 15
        //addFilterButton.clipsToBounds = true
        
        // Add a shadow to the button
        addFilterButton.layer.masksToBounds = false
        addFilterButton.layer.shadowColor = UIColor(white: 0.7, alpha: 1.0).cgColor
        addFilterButton.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        addFilterButton.layer.shadowRadius = 2
        addFilterButton.layer.shadowOpacity = 0.5
        
        addFilterButton.addTarget(self, action: #selector(addFilterButtonTouched), for: .touchUpInside)
        filterContainerScrollView.addSubview(addFilterButton)
         
        overallWidth += (80 + leftPad)
        */
        // Add the left and right shadows
        if (leftShadow == nil)
        {
            leftShadow = UIImageView(frame: CGRect(x: 0, y: Int(filterContainerScrollView.frame.origin.y), width: 70, height: Int(filterContainerScrollView.frame.size.height) - 1))
            leftShadow.image = UIImage(named: "LeftShadowWhite")
            leftShadow.clipsToBounds = true
            leftShadow.tag = 200
            titleContainerView.addSubview(leftShadow)
        }
                
        if (rightShadow == nil)
        {
            rightShadow = UIImageView(frame: CGRect(x: Int(kDeviceWidth) - 70, y: Int(filterContainerScrollView.frame.origin.y), width: 70, height: Int(filterContainerScrollView.frame.size.height) - 1))
            rightShadow.image = UIImage(named: "RightShadowWhite")
            rightShadow.clipsToBounds = true
            rightShadow.tag = 201
            titleContainerView.addSubview(rightShadow)
        }
        
        leftShadow.isHidden = true
        
        filterContainerScrollView.contentSize = CGSize(width: overallWidth + rightPad, height: Int(filterContainerScrollView.frame.size.height))
        
        if (filterContainerScrollView.contentSize.width <= filterContainerScrollView.frame.size.width)
        {
            rightShadow.isHidden = true
        }
    
    }
    
    // MARK: - SearchSportViewController Delegates
    
    func searchSportCancelButtonTouched()
    {
        self.dismiss(animated: true)
        {
            
        }
    }
    
    func searchSportSelectButtonTouched()
    {
        let sport = searchSportVC.selectedSport
        let gender = searchSportVC.selectedGender
        
        self.dismiss(animated: true)
        {
            self.showNewsFilterViewController(gender: gender, sport: sport, ftag: "", tabName: "")
        }
    }
    
    // MARK: - NewsStatsTableViewCell Delegate
    
    func newsStatsTableViewCellDidSelectTeam(team: Team)
    {
        
    }
    
    func newsStatsTableViewCellDidSelectAthlete(athlete: Athlete)
    {
        
    }
    
    func newsStatsTableViewCellFullStatsTouched(urlString: String)
    {
        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Coming Soon", message: "This will open the team or player stats page.", lastItemCancelType: false) { (tag) in
        }
    }
    
    // MARK: - NewsTeamRankingsTableViewCell Delegate
    
    func newsTeamRankingsTableViewCellDidSelectTeam(team: Team)
    {
        if (videoHeaderView != nil)
        {
            videoHeaderView.stopVideo()
        }
        
        var showSaveFavoriteButton = false
        var showRemoveFavoriteButton = false
        
        // Check to see if the team is already a favorite
        let isFavorite = MiscHelper.isTeamMyFavoriteTeam(schoolId: team.schoolId, gender: team.gender, sport: team.sport, teamLevel: team.teamLevel, season: team.season)
        let userId = kUserDefaults.value(forKey: kUserIdKey) as! String
        
        if (isFavorite == true)
        {
            if (userId != kTestDriveUserId)
            {
                showSaveFavoriteButton = false
                showRemoveFavoriteButton = true
            }
        }
        else
        {
            if (userId != kTestDriveUserId)
            {
                showSaveFavoriteButton = true
                showRemoveFavoriteButton = false
            }
        }
        
        teamDetailVC = TeamDetailViewController(nibName: "TeamDetailViewController", bundle: nil)
        teamDetailVC.selectedTeam = team
        teamDetailVC.showSaveFavoriteButton = showSaveFavoriteButton
        teamDetailVC.showRemoveFavoriteButton = showRemoveFavoriteButton
        
        self.navigationController?.pushViewController(teamDetailVC, animated: true)
    }
    
    func newsTeamRankingsTableViewCellFullRankingsTouched(urlString: String)
    {
        self.showWebViewController(urlString: urlString, title: "Rankings", showBannerAd: true, ftag: "", autoPopAfterVideoPlayerCloses: false)
    }
    
    // MARK: - NewsNationalRankingsTableViewCell Delegate
    
    func newsNationalRankingsTableViewCellDidSelectTeam(team: Team)
    {
        if (videoHeaderView != nil)
        {
            videoHeaderView.stopVideo()
        }
        
        var showSaveFavoriteButton = false
        var showRemoveFavoriteButton = false
        
        // Check to see if the team is already a favorite
        let isFavorite = MiscHelper.isTeamMyFavoriteTeam(schoolId: team.schoolId, gender: team.gender, sport: team.sport, teamLevel: team.teamLevel, season: team.season)
        let userId = kUserDefaults.value(forKey: kUserIdKey) as! String
        
        if (isFavorite == true)
        {
            if (userId != kTestDriveUserId)
            {
                showSaveFavoriteButton = false
                showRemoveFavoriteButton = true
            }
        }
        else
        {
            if (userId != kTestDriveUserId)
            {
                showSaveFavoriteButton = true
                showRemoveFavoriteButton = false
            }
        }
        
        teamDetailVC = TeamDetailViewController(nibName: "TeamDetailViewController", bundle: nil)
        teamDetailVC.selectedTeam = team
        teamDetailVC.showSaveFavoriteButton = showSaveFavoriteButton
        teamDetailVC.showRemoveFavoriteButton = showRemoveFavoriteButton
        
        self.navigationController?.pushViewController(teamDetailVC, animated: true)
    }
    
    func newsNationalRankingsTableViewCellFullRankingsTouched(urlString: String)
    {
        self.showWebViewController(urlString: urlString, title: "Rankings", showBannerAd: true, ftag: "", autoPopAfterVideoPlayerCloses: false)
    }
    
    // MARK: - NewsStandingsTableViewCell Delegate
    
    func newsStandingsTableViewCellDidSelectTeam(team: Team)
    {
        if (videoHeaderView != nil)
        {
            videoHeaderView.stopVideo()
        }
        
        if (team.allSeasonId.count == 0)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Coming Soon", message: "This opens the native team page when the feed modifications are available.", lastItemCancelType: false) { (tag) in
            }
            return
        }
        
        var showSaveFavoriteButton = false
        var showRemoveFavoriteButton = false
        
        // Check to see if the team is already a favorite
        let isFavorite = MiscHelper.isTeamMyFavoriteTeam(schoolId: team.schoolId, gender: team.gender, sport: team.sport, teamLevel: team.teamLevel, season: team.season)
        let userId = kUserDefaults.value(forKey: kUserIdKey) as! String
        
        if (isFavorite == true)
        {
            if (userId != kTestDriveUserId)
            {
                showSaveFavoriteButton = false
                showRemoveFavoriteButton = true
            }
        }
        else
        {
            if (userId != kTestDriveUserId)
            {
                showSaveFavoriteButton = true
                showRemoveFavoriteButton = false
            }
        }
        
        teamDetailVC = TeamDetailViewController(nibName: "TeamDetailViewController", bundle: nil)
        teamDetailVC.selectedTeam = team
        teamDetailVC.showSaveFavoriteButton = showSaveFavoriteButton
        teamDetailVC.showRemoveFavoriteButton = showRemoveFavoriteButton
        
        self.navigationController?.pushViewController(teamDetailVC, animated: true)
        
    }
    
    func newsStandingsTableViewCellDidSelectStandings(urlString: String, title: String)
    {
        if (urlString.count == 0)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Coming Soon", message: "This will open the team's overall standings page after the feed is modified.", lastItemCancelType: false) { (tag) in
            }
        }
        else
        {
            self.showWebViewController(urlString: urlString, title: title, showBannerAd: true, ftag: "", autoPopAfterVideoPlayerCloses: false)
        }
    }
    
    // MARK: - NewsPhotosTableViewCell Delegate
    
    func newsPhotosTableViewCellDidSelectPhoto(urlString: String)
    {
        self.showWebViewController(urlString: urlString, title: "Gallery", showBannerAd: true, ftag: "", autoPopAfterVideoPlayerCloses: false)
    }
    
    // MARK: - NewsHeaderView Delegate
    
    func newsHeaderViewCellDidSelectVideo(index: Int)
    {
        if (videoHeaderView != nil)
        {
            videoHeaderView.stopVideo()
        }

        //  Remove the first video from the videosArray
        var filteredVideos = [] as! Array<Dictionary<String,Any>>
        filteredVideos = videosArray
        filteredVideos.remove(at: 0)
        
        // Track the video
        TrackingManager.trackState(featureName: "video-watch", trackingGuid: SharedData.newsTabBaseGuid, cData: kEmptyTrackingContextData)
        
        self.hidesBottomBarWhenPushed = true
        
        videoCenterVC = NewsVideoCenterViewController(nibName: "NewsVideoCenterViewController", bundle: nil)
        videoCenterVC.videosArray = filteredVideos
        videoCenterVC.selectedIndex = index
        videoCenterVC.trackingKey = "video-watch"
        videoCenterVC.trackingContextData = kEmptyTrackingContextData
        
        self.navigationController?.pushViewController(videoCenterVC, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    // MARK: - Tab Bar Changed Notification
    
    @objc private func tabBarChanged()
    {
        if (self.tabBarController?.selectedIndex != 0)
        {
            if (videoHeaderView != nil)
            {
                videoHeaderView.stopVideo()
            }
        }
        else // Added in V6.3.1
        {
            self.restartVideo()
        }
    }
    
    // MARK: - Notification and Deep Link Handlers
    
    @objc private func showLatestWebBrowser(notification: Notification)
    {
        if let urlString = notification.userInfo?["url"] as? String
        {
            print(urlString)
            
            if (urlString.count > 0)
            {
                var fixedUrlString = ""
                
                if ((urlString.contains("http://") == true) || (urlString.contains("https://") == true))
                {
                    fixedUrlString = urlString
                }
                else
                {
                    fixedUrlString = String(format: "https://%@", urlString)
                }
                
                let ftag = notification.userInfo!["ftag"] as! String
                let itemType = notification.userInfo!["itemType"] as? String ?? ""
                
                // Added in V6.2.8 to allow video banner ads to be displayed
                if (itemType.lowercased() == "contest")
                {
                    self.showWebViewController(urlString: fixedUrlString, title: "Contest Update", showBannerAd: true, ftag: ftag, autoPopAfterVideoPlayerCloses: false)
                }
                else
                {
                    // Added in V6.3.2 to auto-pop the webVC to the root when the video player has closed
                    if (itemType.lowercased() == "video")
                    {
                        self.showWebViewController(urlString: fixedUrlString, title: "", showBannerAd: true, ftag: ftag, autoPopAfterVideoPlayerCloses: true)
                    }
                    else
                    {
                        self.showWebViewController(urlString: fixedUrlString, title: "", showBannerAd: true, ftag: ftag, autoPopAfterVideoPlayerCloses: false)
                    }
                }
            }
        }
    }
    
    @objc private func showCareerDeepLink(notification: Notification)
    {
        let careerId = notification.userInfo!["careerId"] as! String
        let ftag = notification.userInfo!["ftag"] as! String
        //print(careerId)
        
        NewFeeds.getCareerDeepLinkInfo(careerId: careerId) { careerInfo, error in
            
            if (error == nil)
            {
                let firstName = careerInfo!["firstName"] as? String ?? ""
                let lastName = careerInfo!["lastName"] as? String ?? ""
                let careerProfileId = careerInfo!["careerId"] as! String
                let schoolName = careerInfo!["schoolName"] as! String
                let schoolState = careerInfo!["schoolState"] as! String
                let schoolCity = careerInfo!["schoolCity"] as! String
                let schoolId = careerInfo!["schoolId"] as! String
                let schoolColor = careerInfo!["schoolColor"] as! String
                let schoolMascotUrl = careerInfo!["schoolMascotUrl"] as! String
                let photoUrl = careerInfo!["photoUrl"] as! String
                
                let selectedAthlete = Athlete(firstName: firstName, lastName: lastName, schoolName: schoolName, schoolState: schoolState, schoolCity: schoolCity, schoolId: schoolId, schoolColor: schoolColor, schoolMascotUrl: schoolMascotUrl, careerId: careerProfileId, photoUrl: photoUrl)
                
                if (self.athleteDetailVC != nil)
                {
                    self.athleteDetailVC = nil
                }
                
                self.athleteDetailVC = NewAthleteDetailViewController(nibName: "NewAthleteDetailViewController", bundle: nil)
                self.athleteDetailVC.selectedAthlete = selectedAthlete
                self.athleteDetailVC.ftag = ftag
                
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
                    showSaveFavoriteButton = true
                    showRemoveFavoriteButton = false
                }
                
                self.athleteDetailVC.showSaveFavoriteButton = showSaveFavoriteButton
                self.athleteDetailVC.showRemoveFavoriteButton = showRemoveFavoriteButton

                self.navigationController?.pushViewController(self.athleteDetailVC, animated: true)
            }
        }
    }
    
    @objc private func showTeamDeepLink(notification: Notification)
    {
        /*
        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Deep Link", message: "Team deep link.", lastItemCancelType: false) { tag in
            
        }
        */
        let schoolId = notification.userInfo!["schoolId"] as! String
        let ssid = notification.userInfo!["ssid"] as! String
        let ftag = notification.userInfo!["ftag"] as! String
        let tabName = notification.userInfo!["tabName"] as? String ?? ""
        
        NewFeeds.getTeamDeepLinkInfo(schoolId: schoolId, ssid: ssid) { teamInfo, error in
            
            if (error == nil)
            {
                /*
                 "teamId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                     "sportSeasonId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                     "allSeasonId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                     "gender": "string",
                     "sport": "string",
                     "level": "string",
                     "season": "string",
                     "year": "string",
                     "schoolName": "string",
                     "schoolFormattedName": "string",
                     "schoolCity": "string",
                     "schoolState": "string",
                     "schoolMascot": "string",
                     "schoolMascotUrl": "string",
                     "schoolColor": "string"
                 */
                let schoolId = teamInfo!["teamId"] as! String
                let name = teamInfo!["schoolName"] as! String
                let city = teamInfo!["schoolCity"] as! String
                let state = teamInfo!["schoolState"] as! String
                let fullName = String(format: "%@ (%@, %@)", name, city, state)
                let gender = teamInfo!["gender"] as! String
                let sport = teamInfo!["sport"] as! String
                let level = teamInfo!["level"] as! String
                let season = teamInfo!["season"] as! String
                let allSeasonId = teamInfo!["allSeasonId"] as! String
                let sportSeasonId = teamInfo!["sportSeasonId"] as! String
                let mascotUrlString = teamInfo!["schoolMascotUrl"] as! String
                let hexColorString = teamInfo!["schoolColor"] as! String
                
                if (self.teamDetailVC != nil)
                {
                    self.teamDetailVC = nil
                }
                
                var showSaveFavoriteButton = false
                var showRemoveFavoriteButton = false
                
                // Check to see if the team is already a favorite
                let isFavoriteTeam = MiscHelper.isTeamMyFavoriteTeamWithId(schoolId: schoolId, gender: gender, sport: sport, teamLevel: level, season: season).isFavorite
                let teamId = MiscHelper.isTeamMyFavoriteTeamWithId(schoolId: schoolId, gender: gender, sport: sport, teamLevel: level, season: season).teamId
                
                let selectedTeamObj = Team(teamId: teamId, allSeasonId: allSeasonId, gender: gender, sport: sport, teamColor: hexColorString, mascotUrl: mascotUrlString, schoolName: name, teamLevel: level, schoolId: schoolId, schoolState: state, schoolCity: city, schoolFullName: fullName, season: season, notifications: [])
                
                if (isFavoriteTeam == true)
                {
                    showSaveFavoriteButton = false
                    showRemoveFavoriteButton = true
                }
                else
                {
                    showSaveFavoriteButton = true
                    showRemoveFavoriteButton = false
                }
                
                self.teamDetailVC = TeamDetailViewController(nibName: "TeamDetailViewController", bundle: nil)
                self.teamDetailVC.selectedTeam = selectedTeamObj
                self.teamDetailVC.selectedSSID = sportSeasonId
                self.teamDetailVC.ftag = ftag
                self.teamDetailVC.tabName = tabName
                self.teamDetailVC.showSaveFavoriteButton = showSaveFavoriteButton
                self.teamDetailVC.showRemoveFavoriteButton = showRemoveFavoriteButton
                self.navigationController?.pushViewController(self.teamDetailVC, animated: true)
            }
        }
    }
    
    @objc private func showUserDeepLink(notification: Notification)
    {
        let tabName = notification.userInfo!["tabName"] as? String ?? ""
        let ftag = notification.userInfo!["ftag"] as? String ?? ""
        
        if (tabName == "notifications")
        {
            self.showNotificationsViewController(ftag: ftag)
        }
    }
    
    @objc private func showArenaDeepLink(notification: Notification)
    {
        let tabName = notification.userInfo!["tabName"] as? String ?? ""
        let ftag = notification.userInfo!["ftag"] as? String ?? ""
        let gender = notification.userInfo!["gender"] as? String ?? ""
        let sport = notification.userInfo!["sport"] as? String ?? ""
        
        if (tabName == "playoffs")
        {
            self.showNewsFilterViewController(gender: gender, sport: sport, ftag: ftag, tabName: tabName)
        }
    }
    
    // MARK: - Button Methods
    
    @objc private func profileButtonTouched()
    {
        if (toolTipActive == true)
        {
            return
        }
        
        if (videoHeaderView != nil)
        {
            videoHeaderView.stopVideo()
        }
        
        // Show the SettingsVC is a test drive user
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        if (userId == kTestDriveUserId)
        {
            self.showGuestProfileVC()
        }
        else
        {
            if (MiscHelper.userIsAnAD().isAD == true)
            {
                print("User is an AD")
                
                self.hidesBottomBarWhenPushed = true
                
                adProfileVC = NewADProfileViewController(nibName: "NewADProfileViewController", bundle: nil)
                adProfileVC.schoolId = MiscHelper.userIsAnAD().schoolId
                self.navigationController?.pushViewController(adProfileVC, animated: true)
                
                self.hidesBottomBarWhenPushed = false
            }
            else
            {
                if (MiscHelper.userIsCoach().isCoach == true)
                {
                    print("User is a coach")
                    
                    self.hidesBottomBarWhenPushed = true
                    
                    coachProfileVC = NewCoachProfileViewController(nibName: "NewCoachProfileViewController", bundle: nil)
                    coachProfileVC.schoolId = MiscHelper.userIsCoach().schoolId
                    coachProfileVC.ssid = MiscHelper.userIsCoach().ssid
                    self.navigationController?.pushViewController(coachProfileVC, animated: true)
                    
                    self.hidesBottomBarWhenPushed = false
                }
                else
                {
                    print("User is not a coach")
                    
                    let canEditCareer = MiscHelper.userCanEditCareer().canEdit
                    
                    if (canEditCareer == true)
                    {
                        let isAthlete = MiscHelper.userCanEditCareer().isAthlete
                        let isParent = MiscHelper.userCanEditCareer().isParent
                        let isOther = MiscHelper.userCanEditCareer().isOther
                        
                        if (isOther == false)
                        {
                            let careerId = MiscHelper.userCanEditCareer().careerId
                            
                            if (isAthlete == true) && (isParent == false)
                            {
                                self.hidesBottomBarWhenPushed = true
                                
                                athleteProfileVC = NewAthleteProfileViewController(nibName: "NewAthleteProfileViewController", bundle: nil)
                                athleteProfileVC.careerId = careerId
                                self.navigationController?.pushViewController(athleteProfileVC, animated: true)
                                
                                self.hidesBottomBarWhenPushed = false
                                return
                            }
                            
                            if (isAthlete == false) && (isParent == true)
                            {
                                self.hidesBottomBarWhenPushed = true
                                
                                parentProfileVC = NewParentProfileViewController(nibName: "NewParentProfileViewController", bundle: nil)
                                parentProfileVC.careerId = careerId
                                self.navigationController?.pushViewController(parentProfileVC, animated: true)
                                
                                self.hidesBottomBarWhenPushed = false
                                return
                            }
                            
                            if (isAthlete == true) && (isParent == true)
                            {
                                self.hidesBottomBarWhenPushed = true
                                
                                parentProfileVC = NewParentProfileViewController(nibName: "NewParentProfileViewController", bundle: nil)
                                parentProfileVC.careerId = careerId
                                self.navigationController?.pushViewController(parentProfileVC, animated: true)
                                
                                self.hidesBottomBarWhenPushed = false
                                return
                            }
                        }
                    }
                    
                    // Fallback case is the Fan
                    self.hidesBottomBarWhenPushed = true
                    
                    fanProfileVC = NewFanProfileViewController(nibName: "NewFanProfileViewController", bundle: nil)
                    self.navigationController?.pushViewController(fanProfileVC, animated: true)
                    
                    self.hidesBottomBarWhenPushed = false
                }
            }
        }
    }
    
    @IBAction func searchButtonTouched(_ sender: UIButton)
    {
        if (toolTipActive == true)
        {
            return
        }
        
        if (videoHeaderView != nil)
        {
            videoHeaderView.stopVideo()
        }
        
        searchVC = SearchViewController(nibName: "SearchViewController", bundle: nil)
        self.navigationController?.pushViewController(searchVC!, animated: true)
    }
    
    @objc private func filterButtonTouched(_ sender: UIButton)
    {
        if (toolTipActive == true)
        {
            return
        }
        
        let index = sender.tag - 100
        let filter = filterArray[index]
        
        let sport = filter[kLatestTabFilterSportKey]
        let gender = filter[kLatestTabFilterGenderKey]
        
        self.showNewsFilterViewController(gender: gender!, sport: sport!, ftag: "", tabName: "")
    }
    
    @objc private func addFilterButtonTouched(_ sender: UIButton)
    {
        if (toolTipActive == true)
        {
            return
        }
        
        if (videoHeaderView != nil)
        {
            videoHeaderView.stopVideo()
        }
        
        searchSportVC = SearchSportViewController(nibName: "SearchSportViewController", bundle: nil)
        searchSportVC.delegate = self
        searchSportVC.showReducedSports = true
        searchSportVC.modalPresentationStyle = .overCurrentContext
        
        self.present(searchSportVC, animated: true)
        {
            
        }
    }
    
    @IBAction func testButtonTouched()
    {
        kUserDefaults.setValue(NSNumber.init(integerLiteral: 0), forKey: kAppLaunchCountKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipOneShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipTwoShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipThreeShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipFourShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipFiveShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipSixShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipSevenShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipEightShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipNineShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kVideoUploadToolTipShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kTeamVideoToolTipShownKey)
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kCareerVideoToolTipShownKey)
        
        testButton.setTitle("0", for: .normal)
        
        
        /*
        var message = ""
        let batteryGood = MiscHelper.hasGoodBatteryLevel()
        let wifiOnly = MiscHelper.isConnectedToWiFi()
        
        if (batteryGood == false) && (wifiOnly == false)
        {
            message = "Battery: Low\nWiFi: No"
        }
        else if (batteryGood == true) && (wifiOnly == false)
        {
            message = "Battery: Good\nWiFi: No"
        }
        else if (batteryGood == false) && (wifiOnly == true)
        {
            message = "Battery: Low\nWiFi: Yes"
        }
        if (batteryGood == true) && (wifiOnly == true)
        {
            message = "Battery: Good\nWiFi: Yes"
        }
        
        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Autoplay Test", message: message, lastItemCancelType: false) { (tag) in
        }
        */
    }
    
    @IBAction func leftTestButtonTouched()
    {
        if (self.videoShortsArray.count == 0)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "No Videos", message: "There are no video shorts available.", lastItemCancelType: false) { tag in
                
            }
            return
        }
        
        if (videoHeaderView != nil)
        {
            videoHeaderView.stopVideo()
        }
        
        verticalVideoVC = VerticalVideoViewController(nibName: "VerticalVideoViewController", bundle: nil)
        verticalVideoVC.videoShortsArray = self.videoShortsArray
        verticalVideoVC.initialVideoIndex = 0
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.pushViewController(verticalVideoVC, animated: true)
        
        
        /*
        // Initialize the OneTrust Banner
        OTPublishersHeadlessSDK.shared.setupUI(kAppKeyWindow.rootViewController!, UIType: .preferenceCenter)
        OTPublishersHeadlessSDK.shared.showPreferenceCenterUI()
        let consentStatus4 = OTPublishersHeadlessSDK.shared.getConsentStatus(forCategory: "4")
        let consentStatus2 = OTPublishersHeadlessSDK.shared.getConsentStatus(forCategory: "2")
        print(String(consentStatus4)) // 0 = disallow, 1 = allow
        print(String(consentStatus2)) // 0 = disallow, 1 = allow, -1 = not collected
        */
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
        {
            self.showCareerVideoUploadToolTip()
        }
        */
        
        /*
        if (self.tabBarController?.viewControllers?.count == 3)
        {
            let tabBarController = self.tabBarController as! TabBarController
            tabBarController.showPlayByPlay()
            self.leftTestButton.setTitle("Stop", for: .normal)
        }
        else
        {
            let tabBarController = self.tabBarController as! TabBarController
            tabBarController.hidePlayByPlay()
            self.leftTestButton.setTitle("PBP", for: .normal)
        }
        */
        
        
    }
    
    // MARK: - Amazon Banner Ad Methods
    
    private func requestAmazonBannerAd()
    {
        // Not called for Nimbus
        let adSize = DTBAdSize(bannerAdSizeWithWidth: 320, height: 50, andSlotUUID: kAmazonBannerAdSlotUUID)
        let adLoader = DTBAdLoader()
        adLoader.setAdSizes([adSize!])
        adLoader.loadAd(self)
    }
    
    func onSuccess(_ adResponse: DTBAdResponse!)
    {
        var adResponseDictionary = adResponse.customTargeting()
        
        adResponseDictionary!.updateValue(SharedData.newsTabBaseGuid, forKey: "vguid")
        
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
        
        customTargetDictionary.updateValue(SharedData.newsTabBaseGuid, forKey: "vguid")
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
        let adId = kUserDefaults.value(forKey: kNewsBannerAdIdKey) as! String
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
            
            request.customTargeting?.updateValue(SharedData.newsTabBaseGuid, forKey: "vguid")
            
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
            UIView.animate(withDuration: 0.25, animations: {self.bannerBackgroundView.transform = CGAffineTransform(translationX: 0, y: 0)})
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
    
    // MARK: - Pull to Refresh
    
    @objc private func pullToRefresh()
    {
        self.buildSportFilters()
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if (scrollView == filterContainerScrollView)
        {
            let xScroll = Int(scrollView.contentOffset.x)
            
            if (xScroll <= 0)
            {
                leftShadow.isHidden = true
                rightShadow.isHidden = false
            }
            else if ((xScroll > 0) && (xScroll < (Int(filterContainerScrollView!.contentSize.width) - Int(kDeviceWidth))))
            {
                leftShadow.isHidden = false
                rightShadow.isHidden = false
            }
            else
            {
                leftShadow.isHidden = false
                rightShadow.isHidden = true
            }
        }
        else if (scrollView == newsTableView)
        {
            let yScroll = Int(scrollView.contentOffset.y)
            let headerHeight = Int(fakeStatusBar.frame.size.height) + Int(navView.frame.size.height) + Int(titleContainerView.frame.size.height)
            
            //print("Scroll = " + String(yScroll))
            
            if (yScroll <= 0)
            {
                titleContainerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: titleContainerView.frame.size.height)

                newsTableView.frame = CGRect(x: 0, y: Int(fakeStatusBar.frame.size.height) + Int(navView.frame.size.height) + Int(titleContainerView.frame.size.height), width: Int(kDeviceWidth), height: Int(kDeviceHeight) - headerHeight - bottomTabBarPad - Int(SharedData.bottomSafeAreaHeight))
                
                largeTitleLabel.alpha = 1
                navTitleLabel.alpha = 0
                
                // This handles a condition where the last scroll event never gets executed because the previous one is still being drawn
                if (yScroll == 0)
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01)
                    { [self] in
                        self.largeTitleLabel.alpha = 1
                        self.navTitleLabel.alpha = 0
                    }
                }
            }
            else if ((yScroll > 0) && (yScroll < 50))
            {
                titleContainerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height - CGFloat(yScroll), width: kDeviceWidth, height: titleContainerView.frame.size.height)
                            
                newsTableView.frame = CGRect(x: 0, y: Int(fakeStatusBar.frame.size.height) + Int(navView.frame.size.height) + Int(titleContainerView.frame.size.height) - yScroll, width: Int(kDeviceWidth), height: Int(kDeviceHeight) - headerHeight - bottomTabBarPad - Int(SharedData.bottomSafeAreaHeight) + yScroll)
                
                // Fade at twice the scroll rate
                let fade = 1.0 - (CGFloat(2 * yScroll) / titleContainerView.frame.size.height)
                largeTitleLabel.alpha = fade
                navTitleLabel.alpha = 1 - fade
            }
            else
            {
                titleContainerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height - CGFloat(50), width: kDeviceWidth, height: titleContainerView.frame.size.height)
                            
                newsTableView.frame = CGRect(x: 0, y: Int(fakeStatusBar.frame.size.height) + Int(navView.frame.size.height) + Int(titleContainerView.frame.size.height) - 50, width: Int(kDeviceWidth), height: Int(kDeviceHeight) - headerHeight - bottomTabBarPad - Int(SharedData.bottomSafeAreaHeight) + 50)
                
                largeTitleLabel.alpha = 0
                navTitleLabel.alpha = 1
            }
        }
    }
    
    // MARK: - Tool Tip Delegates
    
    func toolTipOneClosed()
    {
        toolTipActive = false
    }
    
    func toolTipFiveClosed()
    {
        toolTipActive = false
    }
    
    func toolTipSixClosed()
    {
        toolTipActive = false
    }
    
    func toolTipSevenClosed()
    {
        toolTipActive = false
    }
    
    func toolTipEightClosed()
    {
        toolTipActive = false
    }
    
    func careerUploadToolTipClosed()
    {
        toolTipActive = false
    }
    
    // MARK: - Show Tool Tips
    
    private func showToolTips()
    {
        if (self.tabBarController?.selectedIndex != 0)
        {
            return
        }
        
        // No tool tips if OneTrust hasn't be shown yet
        if (kUserDefaults.bool(forKey: kOneTrustShownKey) == false)
        {
            return
        }
        
        let currentLaunchCount = kUserDefaults.object(forKey: kAppLaunchCountKey) as! Int
        
        // Show the tool tip after a small delay if not seen before
        if (kUserDefaults.bool(forKey: kToolTipOneShownKey) == false)
        {
            // Added to prevent the toolTip from firing on the first launch
            if (currentLaunchCount <= 1)
            {
                return
            }
            
            toolTipActive = true
            
            // Dismiss any childVCs
            self.dismissChild()
            
            // Scroll the table to the top
            newsTableView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
            {
                self.toolTipOneVC = ToolTipOneViewController(nibName: "ToolTipOneViewController", bundle: nil)
                self.toolTipOneVC.delegate = self
                self.toolTipOneVC.modalPresentationStyle = .overFullScreen
                self.present(self.toolTipOneVC, animated: false)
            }
        }
        else
        {
            // Skip tool tips 5-8 if just a visitor
            if (kUserDefaults.string(forKey: kUserIdKey) != kTestDriveUserId)
            {
                let userCanEditCareer = MiscHelper.userCanEditCareer().canEdit
                let userCanEditAndIsAthlete = MiscHelper.userCanEditCareer().isAthlete
                
                if (userCanEditCareer == false)
                {
                    // Show tool tip five or six on launch 4
                    if (currentLaunchCount == 4)
                    {
                        // The userType is needed when an athlete is not claimed
                        if (kUserDefaults.string(forKey: kUserTypeKey) == "Athlete")
                        {
                            if (kUserDefaults.bool(forKey: kToolTipFiveShownKey) == false)
                            {
                                // Dismiss any childVCs
                                self.dismissChild()
                                
                                // Scroll the table to the top
                                newsTableView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
                                
                                toolTipActive = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
                                {
                                    self.toolTipFiveVC = ToolTipFiveViewController(nibName: "ToolTipFiveViewController", bundle: nil)
                                    self.toolTipFiveVC.delegate = self
                                    self.toolTipFiveVC.modalPresentationStyle = .overFullScreen
                                    self.present(self.toolTipFiveVC, animated: false)
                                }
                            }
                        }
                        else
                        {
                            if (kUserDefaults.bool(forKey: kToolTipSixShownKey) == false)
                            {
                                // Dismiss any childVCs
                                self.dismissChild()
                                
                                // Scroll the table to the top
                                newsTableView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
                                
                                toolTipActive = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
                                {
                                    self.toolTipSixVC = ToolTipSixViewController(nibName: "ToolTipSixViewController", bundle: nil)
                                    self.toolTipSixVC.delegate = self
                                    self.toolTipSixVC.modalPresentationStyle = .overFullScreen
                                    self.present(self.toolTipSixVC, animated: false)
                                }
                            }
                        }
                    }
                }
                else
                {
                    // Show tool tip seven or eight on launch 5
                    if (currentLaunchCount == 5)
                    {
                        if (userCanEditAndIsAthlete == true)
                        {
                            if (kUserDefaults.bool(forKey: kToolTipSevenShownKey) == false)
                            {
                                // Dismiss any childVCs
                                self.dismissChild()
                                
                                // Scroll the table to the top
                                newsTableView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
                                
                                toolTipActive = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
                                {
                                    self.toolTipSevenVC = ToolTipSevenViewController(nibName: "ToolTipSevenViewController", bundle: nil)
                                    self.toolTipSevenVC.delegate = self
                                    self.toolTipSevenVC.modalPresentationStyle = .overFullScreen
                                    self.present(self.toolTipSevenVC, animated: false)
                                    
                                }
                            }
                        }
                        else
                        {
                            if (kUserDefaults.bool(forKey: kToolTipEightShownKey) == false)
                            {
                                // Dismiss any childVCs
                                self.dismissChild()
                                
                                // Scroll the table to the top
                                newsTableView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
                                
                                toolTipActive = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
                                {
                                    self.toolTipEightVC = ToolTipEightViewController(nibName: "ToolTipEightViewController", bundle: nil)
                                    self.toolTipEightVC.delegate = self
                                    self.toolTipEightVC.modalPresentationStyle = .overFullScreen
                                    self.present(self.toolTipEightVC, animated: false)
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func showCareerVideoUploadToolTip()
    {
        // Make sure the tab didn't change
        if (self.tabBarController?.selectedIndex != 0)
        {
            return
        }
        
        // No tool tips if OneTrust hasn't be shown yet
        if (kUserDefaults.bool(forKey: kOneTrustShownKey) == false)
        {
            return
        }
        
        // Dismiss any childVCs
        self.dismissChild()
        
        // Scroll the table to the top
        newsTableView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)

        careerUploadToolTipVC = CareerUploadToolTipViewController(nibName: "CareerUploadToolTipViewController", bundle: nil)
        careerUploadToolTipVC.modalPresentationStyle = .overFullScreen
        careerUploadToolTipVC.delegate = self
        self.present(careerUploadToolTipVC, animated: false)
        
        toolTipActive = true
    }
    
    // MARK: - Dismiss Child Helper Method
    
    private func dismissChild()
    {
        if ((searchVC != nil) || (webVC != nil) || (videoCenterVC != nil) || (teamDetailVC != nil) || (newsFilteredVC != nil) || (searchSportVC != nil) || (guestProfileVC != nil) || (athleteProfileVC != nil) || (parentProfileVC != nil) || (coachProfileVC != nil) || (fanProfileVC != nil) || (adProfileVC != nil) || (verticalVideoVC != nil))
        {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Show Qualtrics Survey
    
    private func showQualtricsSurvey()
    {
        // Changed in V6.3.1
        if (MiscHelper.privacyStatusForUser(consentCategory: "4") == 0)
        {
            return
        }
        
        Qualtrics.shared.properties.setString(string: "MPAppiOS", for: "appName")
        Qualtrics.shared.properties.setString(string: "Home", for: "pageName")
        
        Qualtrics.shared.evaluateProject { (targetingResults) in
            
            for (interceptID, result) in targetingResults
            {
                if result.passed()
                {
                    print("Qualtrics Targeting Result Passed")
                    print(interceptID)
                    
                    let displayed = Qualtrics.shared.display(viewController: self)
                    
                    if (displayed == true)
                    {
                        print("Qualtrics Success")
                    }
                    else
                    {
                        print("Qualtrics Failed")
                    }
                }
                else
                {
                    print("Qualtrics Targeting Result Failed")
                }
            }
        }
        
        /*
        Qualtrics.shared.evaluateTargetingLogic { targetingResult in
            
            if (targetingResult.passed() == true)
            {
                print("Qualtrics Targeting Result Passed")
                
                let result = Qualtrics.shared.display(viewController: self)
                
                if (result == true)
                {
                    print("Qualtrics Success")
                }
                else
                {
                    print("Qualtrics Failed")
                }
            }
            else
            {
                print("Qualtrics Targeting Result Failed")
            }
        }
        */
    }
    
    // MARK: - Restart Video Method
    
    private func restartVideo()
    {
        // Make sure auto play was enabled
        if (MiscHelper.videoAutoplayIsOk() == true)
        {
            if (videoHeaderView != nil)
            {
                videoHeaderView.stopVideo()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                {
                    self.videoHeaderView.getVideoInfo(hideError: true)
                }
            }
        }
    }
    
    // MARK: - App is Active Notification Handler
    
    @objc private func appActiveNotification()
    {
        let currentLaunchCount = kUserDefaults.object(forKey: kAppLaunchCountKey) as! Int
        if (currentLaunchCount > 9)
        {
            testButton.setTitle(">9", for: .normal)
        }
        else
        {
            testButton.setTitle(String(currentLaunchCount), for: .normal)
        }
        
        // Show the tool tips
        self.showToolTips()

        
        // // The video upload tooltip takes priority over the Qualtrics survey. Show either of these after 5 seconds if the user is real and the launch count is greater than 4 (all of the latest tab tooltips have been shown).
        if ((kUserDefaults.string(forKey: kUserIdKey) != kTestDriveUserId) && (kUserDefaults.string(forKey: kUserIdKey) != kEmptyGuid))
        {
            if (currentLaunchCount > 5)
            {
                // Show the career upload tooltip if the user is a parent, athlete, or athlete type
                if (kUserDefaults.bool(forKey: kVideoUploadToolTipShownKey) == false)
                {
                    let userIsParentOrAthlete = MiscHelper.userCanEditCareer().canEdit
                    let userType = kUserDefaults.string(forKey: kUserTypeKey)
                    
                    // Show the tooltip for non-athletes or parents
                    if ((userIsParentOrAthlete == true) || (userType == "Athlete"))
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
                        {
                            self.showCareerVideoUploadToolTip()
                        }
                    }
                }
                else
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0)
                    {
                        self.showQualtricsSurvey()
                    }
                }
            }
        }
    }
    
    // MARK: - Orientation Changed Method
    
    @objc private func orientationChanged()
    {
        if (videoHeaderView != nil)
        {
            if UIDevice.current.orientation.isLandscape
            {
                print("Landscape")
                videoHeaderView.maximizeVideoPlayer()
            }
            else
            {
                print("Portrait")
                videoHeaderView.minimizeVideoPlayer()
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
        
        if (videoHeaderView != nil)
        {
            videoHeaderView.stopVideo()
        }
    }
    
    // MARK: - App Will Enter Foreground Notification
    
    @objc private func applicationWillEnterForeground()
    {
        // Refresh the ad if this VC is the active one
        if (self.tabBarController?.selectedIndex == 0)
        {
            self.loadBannerViews()
            
            self.restartVideo()
        }
    }
    
    // MARK: - View Methods

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Call Tracking
        //print(SharedData.newsTabBaseGuid)
        TrackingManager.trackState(featureName: "latest-home", trackingGuid: SharedData.newsTabBaseGuid, cData: kEmptyTrackingContextData)

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                
        if (self.tabBarController?.tabBar.isHidden == false)
        {
            bottomTabBarPad = kTabBarHeight
        }
        
        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        titleContainerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: titleContainerView.frame.size.height)
        
        let headerHeight = Int(fakeStatusBar.frame.size.height) + Int(navView.frame.size.height) + Int(titleContainerView.frame.size.height)
        
        newsTableView.frame = CGRect(x: 0, y: headerHeight, width: Int(kDeviceWidth), height: Int(kDeviceHeight) - headerHeight - bottomTabBarPad - Int(SharedData.bottomSafeAreaHeight))
        
        // Add refresh control to the table view
        newsRefreshControl.tintColor = UIColor.mpLightGrayColor()
        //let attributedString = NSMutableAttributedString(string: "Refreshing Latest", attributes: [NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 14), NSAttributedString.Key.foregroundColor: UIColor.mpLightGrayColor()])
        //newsRefreshControl.attributedTitle = attributedString
        newsRefreshControl.addTarget(self, action: #selector(pullToRefresh), for: UIControl.Event.valueChanged)
        newsTableView.addSubview(newsRefreshControl)

        // Add the profile button. The image will be updated later
        profileButton = UIButton(type: .custom)
        profileButton?.frame = CGRect(x: 20, y: 4, width: 34, height: 34)
        profileButton?.layer.cornerRadius = (profileButton?.frame.size.width)! / 2.0
        profileButton?.clipsToBounds = true
        //profileButton?.setImage(UIImage.init(named: "EmptyProfileButton"), for: .normal)
        profileButton?.addTarget(self, action: #selector(self.profileButtonTouched), for: .touchUpInside)
        navView?.addSubview(profileButton!)
        
        navTitleLabel.alpha = 0
        
        filterContainerScrollView.backgroundColor = UIColor.mpWhiteColor()
        
        testButton.layer.cornerRadius = 5
        testButton.layer.borderWidth = 1
        testButton.layer.borderColor = UIColor.mpRedColor().cgColor
        testButton.clipsToBounds = true
        testButton.isHidden = true
        
        leftTestButton.setTitle("Shorts", for: .normal)
        leftTestButton.isHidden = true
        
        //if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        //{
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0)
            {
                self.leftTestButton.isHidden = false
            }
        //}
        
        /*
        #if DEBUG
        leftTestButton.isHidden = false
        #else
        leftTestButton.isHidden = true
        #endif
        */
        
        // Add a notification handler that validate user is finished
        NotificationCenter.default.addObserver(self, selector: #selector(loadUserImage), name: Notification.Name("GetUserInfoFinished"), object: nil)
        
        // Add a notification handler that login finished
        NotificationCenter.default.addObserver(self, selector: #selector(loginFinished), name: Notification.Name("LoginFinished"), object: nil)
        
        // Add a notification handler that user favorites were updated
        NotificationCenter.default.addObserver(self, selector: #selector(buildSportFilters), name: Notification.Name("FavoriteTeamsUpdated"), object: nil)
        
        // Add a notification handler that the tab bar changed
        NotificationCenter.default.addObserver(self, selector: #selector(tabBarChanged), name: Notification.Name("TabBarChanged"), object: nil)
        
        // Add a notification handler to show the tracking dialog after login finishes
        //NotificationCenter.default.addObserver(self, selector: #selector(showTrackingDialog), name: Notification.Name("ShowTrackingDialog"), object: nil)
        
        // Add a notification handler for push notifications
        NotificationCenter.default.addObserver(self, selector: #selector(showLatestWebBrowser), name: Notification.Name("OpenLatestWebBrowser"), object: nil)
        
        // Add a notification handler for career deep linking
        NotificationCenter.default.addObserver(self, selector: #selector(showCareerDeepLink), name: Notification.Name("OpenLatestCareerDeepLink"), object: nil)
        
        // Add a notification handler for team deep linking
        NotificationCenter.default.addObserver(self, selector: #selector(showTeamDeepLink), name: Notification.Name("OpenLatestTeamDeepLink"), object: nil)
        
        // Add a notification handler for user deep linking
        NotificationCenter.default.addObserver(self, selector: #selector(showUserDeepLink), name: Notification.Name("OpenLatestUserDeepLink"), object: nil)
        
        // Add a notification handler for arena deep linking
        NotificationCenter.default.addObserver(self, selector: #selector(showArenaDeepLink), name: Notification.Name("OpenLatestArenaDeepLink"), object: nil)
        
        // Add a temporary notification handler for the tool tip reset button
        NotificationCenter.default.addObserver(self, selector: #selector(appActiveNotification), name: Notification.Name("AppActiveNotification"), object: nil)

        // Add an observer for the app going into the background
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // Add an observer for the app returning to the foreground
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        /*
        // Add a device orientation handler if on an iPhone
        if (SharedData.deviceType as! DeviceType == DeviceType.iphone)
        {
            NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        }
        */
        self.buildSportFilters()
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
                
        // Set the image to the settings icon if a Test Drive user right away
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        if (userId == kTestDriveUserId)
        {
            //profileButton?.setImage(UIImage.init(named: "SettingsButton"), for: .normal)
            profileButton?.setImage(UIImage.init(named: "EmptyProfileButton"), for: .normal)
        }
        else
        {
            self.loadUserImage()
        }
        
        if (searchVC != nil)
        {
            self.buildSportFilters()
        }
        
        if (videoCenterVC != nil)
        {
            videoCenterVC.stopVideo()
        }
        
        // Show the ad
        self.loadBannerViews()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
                
        if (searchVC != nil)
        {
            self.buildSportFilters()
            searchVC = nil
        }
        
        if (webVC != nil)
        {
            self.restartVideo()
            webVC = nil
        }
        
        if (videoCenterVC != nil)
        {
            self.restartVideo()
            videoCenterVC = nil
        }
        
        if (teamDetailVC != nil)
        {
            self.restartVideo()
            teamDetailVC = nil
        }
        
        if (newsFilteredVC != nil)
        {
            self.restartVideo()
            newsFilteredVC = nil
        }
        
        if (searchSportVC != nil)
        {
            self.restartVideo()
            searchSportVC = nil
        }
        
        if (guestProfileVC != nil)
        {
            self.restartVideo()
            guestProfileVC = nil
        }
        
        if (athleteProfileVC != nil)
        {
            self.restartVideo()
            athleteProfileVC = nil
        }
        
        if (parentProfileVC != nil)
        {
            self.restartVideo()
            parentProfileVC = nil
        }
        
        if (coachProfileVC != nil)
        {
            self.restartVideo()
            coachProfileVC = nil
        }
        
        if (fanProfileVC != nil)
        {
            self.restartVideo()
            fanProfileVC = nil
        }
        
        if (adProfileVC != nil)
        {
            self.restartVideo()
            adProfileVC = nil
        }
        
        if (verticalVideoVC != nil)
        {
            self.restartVideo()
            verticalVideoVC = nil
        }
        
        if (toolTipOneVC != nil)
        {
            toolTipOneVC = nil
        }
        
        if (toolTipFiveVC != nil)
        {
            toolTipFiveVC = nil
        }
        
        if (toolTipSixVC != nil)
        {
            toolTipSixVC = nil
        }
        
        if (toolTipSevenVC != nil)
        {
            toolTipSevenVC = nil
        }
        
        if (toolTipEightVC != nil)
        {
            toolTipEightVC = nil
        }
        
        if (athleteDetailVC != nil)
        {
            athleteDetailVC = nil
        }
        
        if (careerUploadToolTipVC != nil)
        {
            careerUploadToolTipVC = nil
        }
        
        if (notificationsVC != nil)
        {
            self.restartVideo()
            notificationsVC = nil
        }
        
        if (verticalVideoVC != nil)
        {
            self.restartVideo()
            verticalVideoVC = nil
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
        
        // Clear the ad if going to another tab
        if (self.tabBarController?.selectedIndex != 0)
        {
            self.clearBannerAd()
        }
        else
        {
            // Clear if going to another screen
            if ((searchVC != nil) || (webVC != nil) || (videoCenterVC != nil) || (teamDetailVC != nil) || (newsFilteredVC != nil) || (searchSportVC != nil) || (guestProfileVC != nil) || (athleteProfileVC != nil) || (parentProfileVC != nil) || (coachProfileVC != nil) || (fanProfileVC != nil) || (adProfileVC != nil) || (verticalVideoVC != nil))
            {
                self.clearBannerAd()
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.default
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
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("GetUserInfoFinished"), object: nil)
                
        NotificationCenter.default.removeObserver(self, name: Notification.Name("LoginFinished"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("FavoriteTeamsUpdated"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("TabBarChanged"), object: nil)
        
        //NotificationCenter.default.removeObserver(self, name: Notification.Name("ShowTrackingDialog"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("OpenLatestWebBrowser"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("OpenLatestCareerDeepLink"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("OpenLatestTeamDeepLink"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("OpenLatestUserDeepLink"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("OpenLatestArenaDeepLink"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("AppActiveNotification"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }
}
