//
//  NewsFilteredViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 12/9/21.
//

import UIKit
import GoogleMobileAds
//import MoPubAdapter
import DTBiOSSDK
import AdSupport

class NewsFilteredViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FourSegmentControlViewDelegate, NewsHeaderViewCellDelegate, NewsStandingsTableViewCellDelegate, NewsPhotosTableViewCellDelegate, NewsNationalRankingsTableViewCellDelegate, NewsFilteredStatsViewDelegate, NewsFilteredRankingsViewDelegate, NewsFilteredPlayoffsViewDelegate, MetroFilterViewControllerDelegate, DTBAdCallback, GADBannerViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sportIconImageView: UIImageView!
    @IBOutlet weak var filteredNewsTableView: UITableView!
    
    var gender = ""
    var sport = ""
    var ftag = "" // Added for deep link attribution tracking (currently not connected)
    var tabName = "" // Added to switch tabs when the view is loaded
    
    // Used for the stats section
    private var selectedSeasonIndex = 0
    private var selectedState = "National"
    private var selectedEntityName = ""
    private var selectedEntityId = ""
    private var selectedDivisionType = ""
    private var selectedAliasName = ""
    
    // Used for the rankings section
    private var selectedSeasonIndex2 = 0
    private var selectedState2 = "National"
    private var selectedEntityName2 = ""
    private var selectedEntityId2 = ""
    private var selectedDivisionType2 = ""
    private var selectedAliasName2 = ""
    
    private var fourSegmentControl : FourSegmentControlView?
    
    private var allSeasonsArray = [] as! Array<Dictionary<String,Any>>
    private var stateSeasonsArray = [] as! Array<Dictionary<String,Any>>
    private var stateSeasonsArray2 = [] as! Array<Dictionary<String,Any>>
    private var defaultSeason = ""
    private var latestRankingsSeason = ""
    
    private var filterArray = [] as! Array<Dictionary<String,String>>
    private var videosArray = [] as! Array<Dictionary<String,Any>>
    private var articleArray = [] as! Array<Dictionary<String,Any>>
    private var standingsArray = [] as! Array<Dictionary<String,Any>>
    private var photosArray = [] as! Array<Dictionary<String,Any>>
    private var rankingsArray = [] as! Array<Dictionary<String,Any>>
    
    private var videoHeaderView: NewsVideoHeaderViewCell!
    private var newsFilteredStatsView: NewsFilteredStatsView!
    private var newsFilteredRankingsView: NewsFilteredRankingsView!
    private var newsFilteredPlayoffsView: NewsFilteredPlayoffsView!
    
    private var webVC: WebViewController!
    private var videoCenterVC: NewsVideoCenterViewController!
    private var teamDetailVC: TeamDetailViewController!
    private var metroFilterVC: MetroFilterViewController!
    private var metroFilterVC2: MetroFilterViewController!
    private var athleteDetailVC: NewAthleteDetailViewController!
    
    private var googleBannerAdView: GAMBannerView!
    private var bannerBackgroundView: UIVisualEffectView! //UIImageView!
    
    private var trackingGuid = ""
    private var tickTimer: Timer!
    
    private var skeletonOverlay: SkeletonHUD!
    private var toolTipTwoVC: ToolTipTwoViewController!
    
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
        NewFeeds.getLatestTabItems(favorites: favoriteTeams) { result, error in
            
            if (error == nil)
            {
                print("Get Latest Tab Items Success")
                self.videosArray = result!["videos"] as! Array<Dictionary<String,Any>>
                self.articleArray = result!["articles"] as! Array<Dictionary<String,Any>>
                self.standingsArray = result!["standings"] as! Array<Dictionary<String,Any>>
                self.photosArray = result!["photoGalleries"] as! Array<Dictionary<String,Any>>
                
                /*
                // Don't show the rankings
                if (result!["nationalRankings"] != nil)
                {
                    self.rankingsArray = result!["nationalRankings"] as! Array<Dictionary<String,Any>>
                }
                */
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
                        
                        self.videoHeaderView.loadVideoSize(videoSize)
                        self.videoHeaderView.loadData(self.videosArray, autoPlay:true)
                    }
                }
                
                // Build the tracking context data object
                var cData = kEmptyTrackingContextData
            
                cData[kTrackingSportNameKey] = self.sport
                cData[kTrackingSportGenderKey] = self.gender
                
                TrackingManager.trackState(featureName: "sport-home", trackingGuid: self.trackingGuid, cData: cData)
            }
            else
            {
                print("Get Latest Tab Items Failed")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "We couldn't retrieve the latest news due to a server error.", lastItemCancelType: false) { tag in
                    
                }
            }
            
            self.filteredNewsTableView.reloadData()
        }
    }
    
    // MARK: - Get National Competitive Seasons
    
    private func getNationalCompetitiveSeasons()
    {
        NewFeeds.getNationalCompetitiveSeasons(gender: self.gender, sport: self.sport) { result, error in
            
            if (error == nil)
            {
                print("Get National Competitive Seasons Success")
                self.allSeasonsArray = result!["competitiveSeasons"] as! Array<Dictionary<String,Any>>
                self.defaultSeason = result!["defaultSeason"] as! String
                self.latestRankingsSeason = result!["mostRecentVarsitySportSeasonWithRankings"] as! String
            }
            else
            {
                print("Get National Competitive Seasons Failed")
            }
        }
        
        /*
        NewFeeds.oldGetNationalCompetitiveSeasons(gender: self.gender, sport: self.sport) { result, error in
            
            if (error == nil)
            {
                print("Get National Competitive Seasons Success")
                self.allSeasonsArray = result!
                
                // Preload the state arrays with the national data. These will be updaed in the delegate callbacks from the metroFilterVC or metroFilterVC2 should a state be chosen.
                //self.stateSeasonsArray = result!
                //self.stateSeasonsArray2 = result!
            }
            else
            {
                print("Get National Competitive Seasons Failed")
            }
        }
        */
    }
    
    // MARK: - Show Web View Controller
    
    private func showWebViewController(urlString: String, title: String, showBannerAd: Bool)
    {
        if (videoHeaderView != nil)
        {
            videoHeaderView.stopVideo()
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
        
        // Build the tracking context data object
        var cData = kEmptyTrackingContextData
        cData[kTrackingSportNameKey] = self.sport
        cData[kTrackingSportGenderKey] = self.gender
        
        webVC?.trackingContextData = cData
        webVC?.trackingKey = "sport-home"

        self.navigationController?.pushViewController(webVC!, animated: true)
        //self.hidesBottomBarWhenPushed = false
    }
    
    // MARK: - NewsFilteredViewController Delegate
    
    func metroFilterViewControllerStateSeasonArrayChanged(stateSeasonArray: Array<Dictionary<String,Any>>, statsViewIsParent: Bool)
    {
        if (statsViewIsParent == true)
        {
            self.stateSeasonsArray = stateSeasonArray
        }
        else
        {
            self.stateSeasonsArray2 = stateSeasonArray
        }
    }
    
    // MARK: - NewFilteredPlayoffsViewDelegate
    
    func newsFilterPlayoffsViewBracketTouched(urlString: String)
    {
        self.showWebViewController(urlString: urlString, title: "Bracket", showBannerAd: true)
    }
    
    // MARK: - NewsFilteredRankingsView Delegate
    
    func newsFilteredRankingsViewFilterButtonTouched()
    {
        self.hidesBottomBarWhenPushed = true
        
        metroFilterVC2 = MetroFilterViewController(nibName: "MetroFilterViewController", bundle: nil)
        metroFilterVC2.delegate = self
        metroFilterVC2.allSeasons = allSeasonsArray
        metroFilterVC2.stateSeasons = stateSeasonsArray2
        metroFilterVC2.statsViewIsParent = false
        metroFilterVC2.selectedSeasonIndex = selectedSeasonIndex2
        metroFilterVC2.selectedGender = gender
        metroFilterVC2.selectedSport = sport
        metroFilterVC2.selectedState = selectedState2
        metroFilterVC2.selectedMetroAliasName = selectedAliasName2
        metroFilterVC2.selectedMetroEntityId = selectedEntityId2
        metroFilterVC2.selectedMetroEntityName = selectedEntityName2
        metroFilterVC2.selectedMetroEntityId = selectedEntityId2
        metroFilterVC2.showDma = true
        metroFilterVC2.showLeague = false
        metroFilterVC2.showTeamSize = true
        metroFilterVC2.titleString = "Rankings Filter"
        
        self.navigationController?.pushViewController(metroFilterVC2!, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    func newsFilterRankingsViewFullRankingsButtonTouched(urlString: String)
    {
        self.showWebViewController(urlString: urlString, title: "Rankings", showBannerAd: true)
    }
    
    func newsFilterRankingsViewTeamSelected(selectedTeam: Team, ssid: String)
    {
        var showSaveFavoriteButton = false
        var showRemoveFavoriteButton = false
        
        // Check to see if the team is already a favorite
        let isFavorite = MiscHelper.isTeamMyFavoriteTeam(schoolId: selectedTeam.schoolId, gender: selectedTeam.gender, sport: selectedTeam.sport, teamLevel: selectedTeam.teamLevel, season: selectedTeam.season)
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
        teamDetailVC.selectedTeam = selectedTeam
        teamDetailVC.showSaveFavoriteButton = showSaveFavoriteButton
        teamDetailVC.showRemoveFavoriteButton = showRemoveFavoriteButton
        teamDetailVC.selectedSSID = ssid
        
        self.navigationController?.pushViewController(teamDetailVC, animated: true)
    }
    
    func newsFilterRankingsViewLearnMoreButtonTouched()
    {
        let urlString = kAboutRankingsHost
        
        self.showWebViewController(urlString: urlString, title: "About Rankings", showBannerAd: true)
    }
    
    // MARK: - NewsFilteredStatsView Delegate
    
    func newsFilteredStatsViewFilterButtonTouched()
    {
        self.hidesBottomBarWhenPushed = true
        
        metroFilterVC = MetroFilterViewController(nibName: "MetroFilterViewController", bundle: nil)
        metroFilterVC.delegate = self
        metroFilterVC.allSeasons = allSeasonsArray
        metroFilterVC.stateSeasons = stateSeasonsArray
        metroFilterVC.statsViewIsParent = true
        metroFilterVC.selectedSeasonIndex = selectedSeasonIndex
        metroFilterVC.selectedGender = gender
        metroFilterVC.selectedSport = sport
        metroFilterVC.selectedState = selectedState
        metroFilterVC.selectedMetroAliasName = selectedAliasName
        metroFilterVC.selectedMetroEntityId = selectedEntityId
        metroFilterVC.selectedMetroEntityName = selectedEntityName
        metroFilterVC.selectedMetroEntityId = selectedEntityId
        metroFilterVC.showDma = false
        metroFilterVC.showLeague = true
        metroFilterVC.showTeamSize = false
        metroFilterVC.titleString = "Stats Filter"
        
        self.navigationController?.pushViewController(metroFilterVC!, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    func newsFilterStatsViewFullStatsButtonTouched(urlString: String)
    {
        self.showWebViewController(urlString: urlString, title: "Full Stats", showBannerAd: true)
    }
    
    func newsFilterStatsViewAthleteSelected(selectedAthlete: Athlete)
    {
        athleteDetailVC = NewAthleteDetailViewController(nibName: "NewAthleteDetailViewController", bundle: nil)
        athleteDetailVC.selectedAthlete = selectedAthlete
        
        // Check to see if the athlete is already a favorite
        let isFavorite = MiscHelper.isAthleteMyFavoriteAthlete(careerId: selectedAthlete.careerId)
        
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
        
        athleteDetailVC.showSaveFavoriteButton = showSaveFavoriteButton
        athleteDetailVC.showRemoveFavoriteButton = showRemoveFavoriteButton
        
        self.navigationController?.pushViewController(athleteDetailVC, animated: true)
    }
    
    func newsFilterStatsViewTeamSelected(selectedTeam: Team, ssid: String)
    {
        var showSaveFavoriteButton = false
        var showRemoveFavoriteButton = false
        
        // Check to see if the team is already a favorite
        let isFavorite = MiscHelper.isTeamMyFavoriteTeam(schoolId: selectedTeam.schoolId, gender: selectedTeam.gender, sport: selectedTeam.sport, teamLevel: selectedTeam.teamLevel, season: selectedTeam.season)
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
        teamDetailVC.selectedTeam = selectedTeam
        teamDetailVC.showSaveFavoriteButton = showSaveFavoriteButton
        teamDetailVC.showRemoveFavoriteButton = showRemoveFavoriteButton
        teamDetailVC.selectedSSID = ssid
        
        self.navigationController?.pushViewController(teamDetailVC, animated: true)
    }
    
    func newsFilterStatsViewDefinitionsButtonTouched(urlString: String)
    {
        self.showWebViewController(urlString: urlString, title: "Stat Definitions", showBannerAd: true)
    }
    
    func newsFilterStatsViewFaqButtonTouched()
    {
        let urlString = kStatFaqHost
        self.showWebViewController(urlString: urlString, title: "Support", showBannerAd: true)
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
        self.showWebViewController(urlString: urlString, title: "Rankings", showBannerAd: true)
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
            self.showWebViewController(urlString: urlString, title: title, showBannerAd: true)
        }
    }
    
    // MARK: - NewsPhotosTableViewCell Delegate
    
    func newsPhotosTableViewCellDidSelectPhoto(urlString: String)
    {
        self.showWebViewController(urlString: urlString, title: "Gallery", showBannerAd: true)
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
        
        // Build the tracking context data object
        var cData = kEmptyTrackingContextData
    
        cData[kTrackingSportNameKey] = self.sport
        cData[kTrackingSportGenderKey] = self.gender
        
        TrackingManager.trackState(featureName: "video-watch", trackingGuid: self.trackingGuid, cData: cData)
        
        self.hidesBottomBarWhenPushed = true
        
        videoCenterVC = NewsVideoCenterViewController(nibName: "NewsVideoCenterViewController", bundle: nil)
        videoCenterVC.videosArray = filteredVideos
        videoCenterVC.selectedIndex = index
        videoCenterVC.trackingKey = "video-watch"
        videoCenterVC.trackingContextData = cData
        
        self.navigationController?.pushViewController(videoCenterVC, animated: true)
        self.hidesBottomBarWhenPushed = false
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 4
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
                return 516 // NewsNationalRankingsTableViewCell
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
                if ((self.standingsArray.count > 0) || (self.photosArray.count > 0) || (self.rankingsArray.count > 0))
                {
                    return 16
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
        else if (section == 1)
        {
            if (self.standingsArray.count > 0)
            {
                if ((self.photosArray.count > 0) || (self.rankingsArray.count > 0))
                {
                    return 16
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
        else if (section == 2)
        {
            if (self.photosArray.count > 0)
            {
                if (self.rankingsArray.count > 0)
                {
                    return 16
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
        else
        {
            if (self.rankingsArray.count > 0)
            {
                return 16 + 62 // Ad pad
            }
            else
            {
                return 0.01
            }
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
            
            self.showWebViewController(urlString: urlString, title: "Article", showBannerAd: true)
        }
    }
    
    // MARK: - Tab Bar Changed Notification
    
    @objc private func tabBarChanged() // Added in V6.3.1
    {
        if (self.tabBarController?.selectedIndex != 0)
        {
            if (videoHeaderView != nil)
            {
                videoHeaderView.stopVideo()
            }
        }
        else
        {
            if (fourSegmentControl?.selectedSegment == 0)
            {
                self.restartVideo()
            }
        }
    }
    
    // MARK: - FourSegmentControl Delegate
    
    func segmentChanged()
    {
        if (fourSegmentControl?.selectedSegment == 0)
        {
            filteredNewsTableView.isHidden = false
            
            if (newsFilteredStatsView != nil)
            {
                newsFilteredStatsView.isHidden = true
            }
            
            if (newsFilteredRankingsView != nil)
            {
                newsFilteredRankingsView.isHidden = true
            }
            
            if (newsFilteredPlayoffsView != nil)
            {
                newsFilteredPlayoffsView.isHidden = true
            }
            
            self.restartVideo()
        }
        else if (fourSegmentControl?.selectedSegment == 1)
        {
            if (videoHeaderView != nil)
            {
                videoHeaderView.stopVideo()
            }
            
            filteredNewsTableView.isHidden = true
            
            if (newsFilteredRankingsView != nil)
            {
                newsFilteredRankingsView.isHidden = true
            }
            
            if (newsFilteredPlayoffsView != nil)
            {
                newsFilteredPlayoffsView.isHidden = true
            }
            
            if (newsFilteredStatsView == nil)
            {
                if (self.allSeasonsArray.count > 0)
                {
                    // Add code here to set the selectedSeasonIndex to the defaultSeason provided by the API instead of index zero
                    selectedSeasonIndex = 0
                    for item in self.allSeasonsArray
                    {
                        let testSeason = item["season"] as! String
                        if (testSeason == self.defaultSeason)
                        {
                            break
                        }
                        else
                        {
                            selectedSeasonIndex += 1
                        }
                    }
                    
                    // Reset the index if we didn't finda a match
                    if (selectedSeasonIndex == self.allSeasonsArray.count)
                    {
                        selectedSeasonIndex = 0
                    }
                    
                    let currentSeason = self.allSeasonsArray[selectedSeasonIndex]
                    let season = currentSeason["season"] as! String
                    let year = currentSeason["year"] as! String

                    newsFilteredStatsView = NewsFilteredStatsView(frame: filteredNewsTableView.frame, gender: self.gender, sport: self.sport, year: year, season: season)
                    newsFilteredStatsView.delegate = self
                    self.view.insertSubview(newsFilteredStatsView, aboveSubview: filteredNewsTableView)
                    
                    // Show the tool tip after a small delay if not seen before
                    if (kUserDefaults.bool(forKey: kToolTipTwoShownKey) == false)
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5)
                        {
                            self.toolTipTwoVC = ToolTipTwoViewController(nibName: "ToolTipTwoViewController", bundle: nil)
                            self.toolTipTwoVC.rankingsView = false
                            self.toolTipTwoVC.modalPresentationStyle = .overFullScreen
                            self.present(self.toolTipTwoVC, animated: false)
                        }
                    }
                }
                else
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "We couldn't retrieve the available seasons due to a server error.", lastItemCancelType: false) { tag in
                        
                    }
                }
            }
            else
            {
                newsFilteredStatsView.isHidden = false
            }
        }
        else if (fourSegmentControl?.selectedSegment == 2)
        {
            if (videoHeaderView != nil)
            {
                videoHeaderView.stopVideo()
            }
            
            filteredNewsTableView.isHidden = true
            
            if (newsFilteredStatsView != nil)
            {
                newsFilteredStatsView.isHidden = true
            }
            
            if (newsFilteredPlayoffsView != nil)
            {
                newsFilteredPlayoffsView.isHidden = true
            }
            
            if (newsFilteredRankingsView == nil)
            {
                if (self.allSeasonsArray.count > 0)
                {
                    // Add code here to set the selectedSeasonIndex to the defaultSeason provided by the API instead of index zero
                    selectedSeasonIndex2 = 0
                    for item in self.allSeasonsArray
                    {
                        let testSeasonName = item["name"] as! String
                        if (testSeasonName == self.latestRankingsSeason)
                        {
                            break
                        }
                        else
                        {
                            selectedSeasonIndex2 += 1
                        }
                    }
                    
                    // Reset the index if we didn't finda a match
                    if (selectedSeasonIndex2 == self.allSeasonsArray.count)
                    {
                        selectedSeasonIndex2 = 0
                    }
                    
                    let currentSeason = self.allSeasonsArray[selectedSeasonIndex2]
                    let season = currentSeason["season"] as! String
                    let year = currentSeason["year"] as! String

                    newsFilteredRankingsView = NewsFilteredRankingsView(frame: filteredNewsTableView.frame, gender: self.gender, sport: self.sport, year: year, season: season)
                    newsFilteredRankingsView.delegate = self
                    self.view.insertSubview(newsFilteredRankingsView, aboveSubview: filteredNewsTableView)
                    
                    // Show the tool tip after a small delay if not seen before
                    if (kUserDefaults.bool(forKey: kToolTipTwoShownKey) == false)
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5)
                        {
                            self.toolTipTwoVC = ToolTipTwoViewController(nibName: "ToolTipTwoViewController", bundle: nil)
                            self.toolTipTwoVC.rankingsView = true
                            self.toolTipTwoVC.modalPresentationStyle = .overFullScreen
                            self.present(self.toolTipTwoVC, animated: false)
                        }
                    }
                }
                else
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "We couldn't retrieve the available seasons due to a server error.", lastItemCancelType: false) { tag in
                        
                    }
                }
            }
            else
            {
                newsFilteredRankingsView.isHidden = false
            }
        }
        else
        {
            /*
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Coming Soon...", message: "This shows the playoffs view.", lastItemCancelType: false) { tag in
                
            }
            */
            if (videoHeaderView != nil)
            {
                videoHeaderView.stopVideo()
            }
            
            filteredNewsTableView.isHidden = true
            
            if (newsFilteredStatsView != nil)
            {
                newsFilteredStatsView.isHidden = true
            }
            
            if (newsFilteredRankingsView != nil)
            {
                newsFilteredRankingsView.isHidden = true
            }
            
            if (newsFilteredPlayoffsView == nil)
            {
                newsFilteredPlayoffsView = NewsFilteredPlayoffsView(frame: filteredNewsTableView.frame, gender: self.gender, sport: self.sport, ftag: self.ftag)
                newsFilteredPlayoffsView.delegate = self
                self.view.insertSubview(newsFilteredPlayoffsView, aboveSubview: filteredNewsTableView)
                
                // Show the tool tip after a small delay if not seen before
                if (kUserDefaults.bool(forKey: kToolTipTwoShownKey) == false)
                {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5)
                    {
                        self.toolTipTwoVC = ToolTipTwoViewController(nibName: "ToolTipTwoViewController", bundle: nil)
                        self.toolTipTwoVC.rankingsView = true
                        self.toolTipTwoVC.modalPresentationStyle = .overFullScreen
                        self.present(self.toolTipTwoVC, animated: false)
                    }
                }
                
                /*
                if (self.allSeasonsArray.count > 0)
                {
                    // Add code here to set the selectedSeasonIndex to the defaultSeason provided by the API instead of index zero
                    selectedSeasonIndex2 = 0
                    for item in self.allSeasonsArray
                    {
                        let testSeasonName = item["name"] as! String
                        if (testSeasonName == self.latestRankingsSeason)
                        {
                            break
                        }
                        else
                        {
                            selectedSeasonIndex2 += 1
                        }
                    }
                    
                    // Reset the index if we didn't finda a match
                    if (selectedSeasonIndex2 == self.allSeasonsArray.count)
                    {
                        selectedSeasonIndex2 = 0
                    }
                    
                    let currentSeason = self.allSeasonsArray[selectedSeasonIndex2]
                    let season = currentSeason["season"] as! String
                    let year = currentSeason["year"] as! String
                    
                    newsFilteredRankingsView = NewsFilteredRankingsView(frame: filteredNewsTableView.frame, gender: self.gender, sport: self.sport, year: year, season: season)
                    newsFilteredRankingsView.delegate = self
                    self.view.insertSubview(newsFilteredRankingsView, aboveSubview: filteredNewsTableView)
                    
                    // Show the tool tip after a small delay if not seen before
                    if (kUserDefaults.bool(forKey: kToolTipTwoShownKey) == false)
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5)
                        {
                            self.toolTipTwoVC = ToolTipTwoViewController(nibName: "ToolTipTwoViewController", bundle: nil)
                            self.toolTipTwoVC.rankingsView = true
                            self.toolTipTwoVC.modalPresentationStyle = .overFullScreen
                            self.present(self.toolTipTwoVC, animated: false)
                        }
                    }
                }
                else
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "We couldn't retrieve the available seasons due to a server error.", lastItemCancelType: false) { tag in
                        
                    }
                }
                */
            }
            else
            {
                newsFilteredPlayoffsView.isHidden = false
            }
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
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
        let adId = kUserDefaults.value(forKey: kNewsBannerAdIdKey) as! String
        print("AdId: ", adId)
        
        googleBannerAdView = GAMBannerView(adSize:GADAdSizeBanner, origin: CGPoint(x: (kDeviceWidth - GADAdSizeBanner.size.width) / 2.0, y: 6.0))
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
    
    // MARK: - Notification Dispatcher
    
    private func notificationDispatcher(tabName: String)
    {
        // Switch tabs by simulating a button push
        switch tabName
        {
        case "playoffs":
            fourSegmentControl?.setSegment(index: 3)
            self.segmentChanged()
            
        default: // Handles all of the other notification types
            return
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
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, videoContainer, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        filteredNewsTableView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height - CGFloat(kTabBarHeight) - CGFloat(SharedData.bottomSafeAreaHeight))
        
        // Add the FourSegmentControlView to the navView
        fourSegmentControl = FourSegmentControlView(frame: CGRect(x: 0, y: navView.frame.size.height - 40, width: navView.frame.size.width, height: 40), buttonOneTitle: "Latest", buttonTwoTitle: "Stats", buttonThreeTitle: "Rankings", buttonFourTitle: "Playoffs", lightTheme: false)
        fourSegmentControl?.delegate = self
        navView.addSubview(fourSegmentControl!)
        
        titleLabel.text = MiscHelper.genderSportFrom(gender: gender, sport: sport)
        
        fakeStatusBar.backgroundColor = MiscHelper.getColorForSport(sport)
        navView.backgroundColor = fakeStatusBar.backgroundColor
        
        // Get the national competitive seasons for the stats and rankings views
        self.getNationalCompetitiveSeasons()
        
        // Get the latest tab items using the selected team
        let favoriteTeam = [kLatestTabFilterSportKey:sport, kLatestTabFilterGenderKey:gender, kLatestTabFilterLevelKey:"Varsity", kLatestTabFilterTeamIdKey:kEmptyGuid, kLatestTabFilterStateKey:""]
        
        self.getLatestTabItems(favoriteTeams: [favoriteTeam])
        
        // Add an observer for the app going into the background
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // Add a notification handler that the tab bar changed
        NotificationCenter.default.addObserver(self, selector: #selector(tabBarChanged), name: Notification.Name("TabBarChanged"), object: nil)
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
        
        // Show the ad
        self.loadBannerViews()
        
        // Returning from the stats filter
        if (metroFilterVC != nil)
        {
            selectedSeasonIndex = metroFilterVC.selectedSeasonIndex
            selectedState = metroFilterVC.selectedState
            selectedAliasName = metroFilterVC.selectedMetroAliasName
            //print("SelectedIndex: " + String(selectedSeasonIndex))
            //print("SelectedState: " + selectedState)
            
            
            /*
             // This is what the feed requires
             <param name="context">Context to get athlete stat leader data. Acceptable values are: National = 1, State = 2, Section = 3, StateDivision = 5, SectionDivision = 6, League = 7</param>
             <param name="id">Context id or value</param>
             <param name="genderSport">Gender Sport</param>
             <param name="year">Sport season year in XX-XX format</param>
             <param name="season">Season. Acceptable values are: Fall, Spring, Winter</param>
             <param name="level">(Optional) Team Level. Default is Varsity.</param>
             */
            
            if (newsFilteredStatsView != nil)
            {
                let teamSize = metroFilterVC.selectedTeamSize
                
                var currentSeason = [:] as Dictionary<String,Any>
                
                if (selectedState == "National")
                {
                    currentSeason = self.allSeasonsArray[selectedSeasonIndex]
                }
                else
                {
                    currentSeason = self.stateSeasonsArray[selectedSeasonIndex]
                }
                
                let season = currentSeason["season"] as! String
                let year = currentSeason["year"] as! String
                
                var title = ""
                var subtitle = ""
                if (selectedState == "National")
                {
                    //title = "National Stat Leaders"
                    title = String(format: "National Stat Leaders (%@)", year)
                    
                    newsFilteredStatsView.getPlayerAndTeamStatLeaders(gender: gender, sport: sport, year: year, season: season, state: "", context: "National", contextId: "", teamSize: teamSize)
                }
                else
                {
                    if (selectedAliasName == "")
                    {
                        // State
                        //title = String(format: "%@ Stat Leaders", selectedState)
                        title = String(format: "%@ Stat Leaders (%@)", selectedState, year)
                        
                        newsFilteredStatsView.getPlayerAndTeamStatLeaders(gender: gender, sport: sport, year: year, season: season, state: selectedState, context: "State", contextId: "", teamSize: teamSize)
                    }
                    else
                    {
                        // Metro
                        selectedEntityName = metroFilterVC.selectedMetroEntityName
                        selectedEntityId = metroFilterVC.selectedMetroEntityId
                        
                        //title = String(format: "%@ Stat Leaders", selectedAliasName)
                        title = String(format: "%@ Stat Leaders (%@)", selectedAliasName, year)
                        subtitle = selectedEntityName
                        
                        // Refactor the Entity name to match the feed's requirements
                        if ((selectedAliasName2 == "Division") || (selectedAliasName2 == "Class") || (selectedAliasName2 == "Region"))
                        {
                            selectedDivisionType = metroFilterVC.selectedMetroDivisionType
                            
                            newsFilteredStatsView.getPlayerAndTeamStatLeaders(gender: gender, sport: sport, year: year, season: season, state: selectedState, context: selectedDivisionType, contextId: selectedEntityId, teamSize: teamSize)
                        }
                        else
                        {
                            newsFilteredStatsView.getPlayerAndTeamStatLeaders(gender: gender, sport: sport, year: year, season: season, state: selectedState, context: selectedAliasName, contextId: selectedEntityId, teamSize: teamSize)
                        }
                        
                        /*
                         AliasName: Section, EntityName: Central Coast Section, DivisionType:
                         AliasName: League, EntityName: Academic 1, DivisionType:
                         AliasName: Division, EntityName: Division 1, DivisionType: SectionDivision
                         
                         <param name="context">Context to get athlete stat leader data. Acceptable values are: National = 1, State = 2, Section = 3, StateDivision = 5, SectionDivision = 6, League = 7</param>
                         */
                    }
                }
                
                // Update the title and subtitle on the Stats View
                newsFilteredStatsView.updateTitle(title: title, subtitle: subtitle)
            }
        }
        
        // Returning from the rankings filter
        if (metroFilterVC2 != nil)
        {
            selectedSeasonIndex2 = metroFilterVC2.selectedSeasonIndex
            selectedState2 = metroFilterVC2.selectedState
            selectedAliasName2 = metroFilterVC2.selectedMetroAliasName
            print("SelectedIndex: " + String(selectedSeasonIndex2))
            //print("SelectedState: " + selectedState2)
            
            /*
             // This is what the feed requires
             <param name="context">Context to get ranking data. Acceptable values are: National = 0, State = 1, Section = 2, SectionDivision = 3, StateDivision = 4, DMA = 6, Xcellent = 7</param>
             <param name="id">Context id or value</param>
             <param name="genderSport">Gender Sport</param>
             <param name="year">Sport season year in XX-XX format</param>
             <param name="season">Season. Acceptable values are: Fall, Spring, Winter</param>
             <param name="teamSize">Team Size. Acceptable values are: 8 or 11</param>
             <param name="level">(Optional) Team Level. Default is Varsity.</param>
             */
            
            if (newsFilteredRankingsView != nil)
            {
                var currentSeason = [:] as Dictionary<String,Any>
                
                let teamSize = metroFilterVC2.selectedTeamSize
                
                if (selectedState2 == "National")
                {
                    currentSeason = self.allSeasonsArray[selectedSeasonIndex2]
                }
                else
                {
                    currentSeason = self.stateSeasonsArray2[selectedSeasonIndex2]
                }
                
                let season = currentSeason["season"] as! String
                let year = currentSeason["year"] as! String
                
                var title = ""
                var subtitle = ""
                if (selectedState2 == "National")
                {
                    title = "National Rankings"
                    
                    newsFilteredRankingsView.getTeamRankingsLeaders(gender: gender, sport: sport, year: year, season: season, state: "", context: "National", contextId: "", teamSize: teamSize)
                }
                else
                {
                    if (selectedAliasName2 == "")
                    {
                        // State
                        title = String(format: "%@ Rankings", selectedState2)
                        
                        newsFilteredRankingsView.getTeamRankingsLeaders(gender: gender, sport: sport, year: year, season: season, state: selectedState2, context: "State", contextId: "", teamSize: teamSize)
                    }
                    else
                    {
                        // Metro
                        selectedEntityName2 = metroFilterVC2.selectedMetroEntityName
                        selectedEntityId2 = metroFilterVC2.selectedMetroEntityId
                        
                        title = String(format: "%@ Rankings", selectedAliasName2)
                        subtitle = selectedEntityName2
                        
                        // Refactor the Entity name to match the feed's requirements
                        if ((selectedAliasName2 == "Division") || (selectedAliasName2 == "Class") || (selectedAliasName2 == "Region"))
                        {
                            selectedDivisionType2 = metroFilterVC2.selectedMetroDivisionType
                            
                            newsFilteredRankingsView.getTeamRankingsLeaders(gender: gender, sport: sport, year: year, season: season, state: selectedState2, context: selectedDivisionType2, contextId: selectedEntityId2, teamSize: teamSize)
                        }
                        else if (selectedAliasName2 == "Metro")
                        {
                            newsFilteredRankingsView.getTeamRankingsLeaders(gender: gender, sport: sport, year: year, season: season, state: selectedState2, context: "DMA", contextId: selectedEntityId2, teamSize: teamSize)
                        }
                        else if (selectedAliasName2 == "Association")
                        {
                            newsFilteredRankingsView.getTeamRankingsLeaders(gender: gender, sport: sport, year: year, season: season, state: selectedState2, context: "Association", contextId: selectedEntityId2, teamSize: teamSize)
                        }
                        else
                        {
                            newsFilteredRankingsView.getTeamRankingsLeaders(gender: gender, sport: sport, year: year, season: season, state: selectedState2, context: selectedAliasName2, contextId: selectedEntityId2, teamSize: teamSize)
                        }
                        
                        /*
                         AliasName: Section, EntityName: Central Coast Section, DivisionType:
                         AliasName: League, EntityName: Academic 1, DivisionType:
                         AliasName: Division, EntityName: Division 1, DivisionType: SectionDivision
                         
                         <param name="context">Context to get athlete stat leader data. Acceptable values are: National = 1, State = 2, Section = 3, StateDivision = 5, SectionDivision = 6, League = 7</param>
                         */
                    }
                }
                
                // Update the title and subtitle on the Stats View
                newsFilteredRankingsView.updateTitle(title: title, subtitle: subtitle)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
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
        
        if (metroFilterVC != nil)
        {
            self.restartVideo()
            metroFilterVC = nil
        }
        
        if (metroFilterVC2 != nil)
        {
            self.restartVideo()
            metroFilterVC2 = nil
        }
        
        if (athleteDetailVC != nil)
        {
            self.restartVideo()
            athleteDetailVC = nil
        }
        
        if (toolTipTwoVC != nil)
        {
            toolTipTwoVC = nil
        }
        
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
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("TabBarChanged"), object: nil)
    }
}
