//
//  FavoriteViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/19/21.
//

import UIKit
import AVFoundation
import GoogleMobileAds
//import MoPubAdapter
import DTBiOSSDK
import AdSupport
import AppTrackingTransparency

class FavoriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, FavoritesListViewDelegate, TallFavoriteTeamTableViewCellDelegate, DTBAdCallback, GADBannerViewDelegate, ToolTipThreeDelegate, ToolTipNineDelegate, TeamUploadToolTipDelegate

{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var favoritesTableView: UITableView!
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var editFavoritesButton: UIButton!
    @IBOutlet weak var largeTitleLabel: UILabel!
    @IBOutlet weak var noFavoriteContainerView: UIView!
    @IBOutlet weak var noFavoritesImageView: UIImageView!
    @IBOutlet weak var noFavoriteInnerContainerView: UIView!
    @IBOutlet weak var noFavoriteGetStartedButton: UIButton!
    @IBOutlet weak var noFavoriteTitleLabel: UILabel!
    @IBOutlet weak var noFavoriteMessageLabel: UILabel!
    @IBOutlet weak var athleteContainerScrollView : UIScrollView!
    
    private var profileButton : UIButton?
    private var leftShadow : UIImageView!
    private var rightShadow : UIImageView!
    
    private var favoriteTeamsArray = [] as Array
    private var favoriteAthletesArray = [] as Array
    private var detailedFavoritesArray = [] as Array
    private var bottomTabBarPad = 0
    private var lastCellPadValue = CGFloat(0)
    private var favoritesRefreshControl = UIRefreshControl()
    
    private var searchVC: SearchViewController!
    private var webVC: WebViewController!
    private var teamDetailVC: TeamDetailViewController!
    private var athleteDetailVC: NewAthleteDetailViewController!
    private var athleteProfileVC: NewAthleteProfileViewController!
    private var fanProfileVC: NewFanProfileViewController!
    private var parentProfileVC: NewParentProfileViewController!
    private var coachProfileVC: NewCoachProfileViewController!
    private var adProfileVC: NewADProfileViewController!
    private var guestProfileVC: NewGuestProfileViewController!
    private var favoritesListView: FavoritesListView!
    private var roleSelectorVC: JoinTeamRoleSelectorViewController!
    private var videoPlayerVC: VideoPlayerViewController!
    
    private let kMaxDetailedFavorites = 3
    private let kLastCellExtraPad = 160
    
    private var googleBannerAdView: GAMBannerView!
    private var bannerBackgroundView: UIVisualEffectView! //UIImageView!
    
    private var trackingGuid = ""
    private var tickTimer: Timer!
    
    private var toolTipThreeVC: ToolTipThreeViewController!
    private var toolTipNineVC: ToolTipNineViewController!
    private var teamUploadToolTipVC: TeamUploadToolTipViewController!
    private var toolTipActive = false
    
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
        NimbusBidder(request: .forBannerAd(position: "following")),
        APSBidder(adLoader: apsLoader)
    ]
    
    lazy var dynamicPriceManager = DynamicPriceManager(bidders: bidders, refreshInterval: TimeInterval(kNimbusAdTimerValue))
    
    // MARK: - Get User Favorites from Database
    
    private func getUserFavoriteTeamsFromDatabase()
    {
        NewFeeds.getUserFavoriteTeams(completionHandler: { error in
            
            if error == nil
            {
                print("Download user favorite teams success")
                self.getUserFavoriteAthletesFromDatabase()
            }
            else
            {
                self.favoritesRefreshControl.endRefreshing()
                print("Download user favorite teams error")
            }
        })
    }
    
    private func getUserFavoriteAthletesFromDatabase()
    {
        NewFeeds.getUserFavoriteAthletes(completionHandler: { error in
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            {
                self.favoritesRefreshControl.endRefreshing()
            }
            
            if error == nil
            {
                self.initializeData()
            }
            else
            {
                print("Download user favorite athletes error")
            }
        })
    }
    
    // MARK: - Get Team Detail Card Data
    
    private func getTeamDetailCardData()
    {
        // Extract the schoolId and allSeasonId from the favorites
        detailedFavoritesArray.removeAll()
        
        var postData = [] as Array<Dictionary<String,String>>
        
        for favorite in favoriteTeamsArray
        {
            let item = favorite  as! Dictionary<String, Any>
            let schoolId = item[kNewSchoolIdKey] as! String
            let allSeasonId = item[kNewAllSeasonIdKey] as! String
            let postDictionary = ["teamId": schoolId, "allSeasonId": allSeasonId]
            postData.append(postDictionary)
        }
        
        NewFeeds.getDetailCardDataForTeams(postData) { [self] resultData, error in
            
            if (error == nil)
            {
                print("Team Detail Success")
                
                // Refactor the feed if it doesn't match the favorites
                if (resultData!.count == favoriteTeamsArray.count)
                {
                    detailedFavoritesArray = resultData!
                    //print("Done")
                }
                else
                {
                    for favorite in favoriteTeamsArray
                    {
                        let item = favorite  as! Dictionary<String, Any>
                        let schoolId = item[kNewSchoolIdKey] as! String
                        let allSeasonId = item[kNewAllSeasonIdKey] as! String
                        
                        var noMatch = false
                        for resultObj in resultData!
                        {
                            let obj = resultObj as Dictionary<String,Any>
                            let resultSchoolId = obj["teamId"] as! String
                            let resultAllSeasonId = obj["allSeasonId"] as! String
                            
                            if (resultSchoolId == schoolId) && (resultAllSeasonId == allSeasonId)
                            {
                                // Match is found so add the resultObj to the detailedFavoritesArray
                                detailedFavoritesArray.append(resultObj)
                                noMatch = false
                                break
                            }
                            else
                            {
                                noMatch = true
                            }
                        }
                        
                        if (noMatch == true)
                        {
                            // Add a dummy object
                            let dummyObj = ["record":[:], "schedules":[], "latestItems":[]] as [String : Any]
                            detailedFavoritesArray.append(dummyObj)
                        }
                    }
                }
                
                /*
                 {
                     "status": 200,
                     "message": "Success",
                     "cacheResult": "Unknown",
                     "data": [
                         {
                             "teamId": "d9622df1-9a90-49e7-b219-d6c380c566fe",
                             "allSeasonId": "22e2b335-334e-4d4d-9f67-a0f716bb1ccd",
                             "cardItems": [
                                 {
                                     "record": {
                                         "overallStanding": {
                                             "winningPercentage": 0.000,
                                             "overallWinLossTies": "0-0",
                                             "homeWinLossTies": "0-0",
                                             "awayWinLossTies": "0-0",
                                             "neutralWinLossTies": "0-0",
                                             "points": 0,
                                             "pointsAgainst": 0,
                                             "streak": 0,
                                             "streakResult": "0"
                                         },
                                         "leagueStanding": {
                                             "leagueName": "Foothill Valley",
                                             "canonicalUrl": "https://z.maxpreps.com/league/vIKP_ANcBEeRvG9E5Ztn4Q/standings-foothill-valley.htm",
                                             "conferenceWinningPercentage": 0.000,
                                             "conferenceWinLossTies": "0-0",
                                             "conferenceStandingPlacement": "1st"
                                         }
                                     }
                                 },
                                 {
                                     "schedules": [
                                         {
                                             "hasResult": false,
                                             "resultString": "",
                                             "dateString": "3/19",
                                             "timeString": "7:00 PM",
                                             "opponentMascotUrl": "https://d1yf833igi2o06.cloudfront.net/fit-in/1024x1024/school-mascot/6/1/5/61563c75-3efb-427f-8329-767978b469df.gif?version=636520747200000000",
                                             "opponentName": "Rio Linda",
                                             "opponentNameAcronym": "RLHS",
                                             "opponentUrl": "https://dev.maxpreps.com/high-schools/rio-linda-knights-(rio-linda,ca)/football/home.htm",
                                "opponentColor1": "000080",
                                             "homeAwayType": "Home",
                                             "contestIsLive": false,
                                             "canonicalUrl": "https://dev.maxpreps.com/games/3-19-21/football-fall-20/ponderosa-vs-rio-linda.htm?c=OIRYlXxgWEaHfK7OipEITQ"
                                         },
                                         {
                                             "hasResult": false,
                                             "resultString": "",
                                             "dateString": "3/25",
                                             "timeString": "12:00 PM",
                                             "opponentMascotUrl": "https://d1yf833igi2o06.cloudfront.net/fit-in/1024x1024/school-mascot/6/1/5/61563c75-3efb-427f-8329-767978b469df.gif?version=636520747200000000",
                                             "opponentName": "Rio Linda",
                                             "opponentNameAcronym": "RLHS",
                                             "opponentUrl": "https://dev.maxpreps.com/high-schools/rio-linda-knights-(rio-linda,ca)/football/home.htm",
                                "opponentColor1": "000080",
                                             "homeAwayType": "Neutral",
                                             "contestIsLive": false,
                                             "canonicalUrl": "https://dev.maxpreps.com/games/3-25-21/football-fall-20/ponderosa-vs-rio-linda.htm?c=ZLpSnJTDFUSEscaGO3BsYQ"
                                         }
                                     ]
                                 },
                                 {
                                     "latestItems": [
                                         {
                                             "type": "Article",
                                             "title": "State officials, CIF, coaches meet",
                                             "text": "Dr. Mark Ghaly enters discussion; California coaches group calls meeting 'cooperative,  positive, and open,' but student-athletes are running out of time. ",
                                             "thumbnailUrl": "https://images.maxpreps.com/editorial/article/c/b/8/cb8ee48f-fe58-44dc-baec-f00d7ccf7692/3a4ed84d-c366-eb11-80ce-a444a33a3a97_original.jpg?version=637481180400000000",
                                             "thumbnailWidth": null,
                                             "thumbnailHeight": null,
                                             "canonicalUrl": "https://dev.maxpreps.com/news/j-SOy1j-3ES67PANfM92kg/california-high-school-sports--state-officials,-cif,-coaches-find-common-ground,-talks-to-resume-next-week.htm"
                                         },
                                         {
                                             "type": "Article",
                                             "title": "New hope for California sports",
                                             "text": "Teams slotted in purple tier now allowed to compete; four Sac-Joaquin Section cross country teams ran in Monday meet.",
                                             "thumbnailUrl": "https://images.maxpreps.com/editorial/article/5/0/7/507b80b1-d75a-4909-b52c-474eef259269/e618f53f-745f-eb11-80ce-a444a33a3a97_original.jpg?version=637471932600000000",
                                             "thumbnailWidth": null,
                                             "thumbnailHeight": null,
                                             "canonicalUrl": "https://dev.maxpreps.com/news/sYB7UFrXCUm1LEdO7yWSaQ/new-hope-for-california-high-school-sports-after-stay-home-orders-lifted.htm"
                                         },
                                         {
                                             "type": "Article",
                                             "title": "SJS releases new play for Season 1 in 2021",
                                             "text": "State's second-largest section will forego traditional postseason to allow schools chance to participate in more games. ",
                                             "thumbnailUrl": "https://images.maxpreps.com/editorial/article/d/2/9/d298908e-0c1c-46aa-861c-96e4fa76ffad/07b358d0-8941-eb11-80ce-a444a33a3a97_original.jpg?version=637439061000000000",
                                             "thumbnailWidth": null,
                                             "thumbnailHeight": null,
                                             "canonicalUrl": "https://dev.maxpreps.com/news/jpCY0hwMqkaGHJbk-nb_rQ/sac-joaquin-section-releases-new-plan-for-season-1-in-2021.htm"
                                         },
                                         {
                                             "type": "Article",
                                             "title": "Video: When will California sports return?",
                                             "text": "Health and Human Services agency provides an update as state grapples with COVID-19 guidelines, tiers.",
                                             "thumbnailUrl": "https://images.maxpreps.com/editorial/article/a/9/a/a9a554a4-6e1b-4835-828a-4b989d7a79a9/2cf9a134-d723-eb11-80ce-a444a33a3a97_original.jpg?version=637409524200000000",
                                             "thumbnailWidth": null,
                                             "thumbnailHeight": null,
                                             "canonicalUrl": "https://dev.maxpreps.com/news/pFSlqRtuNUiCikuYnXp5qQ/video--when-will-california-high-school-and-youth-sports-return.htm"
                                         },
                                         {
                                             "type": "Article",
                                             "title": "Map: Where NFL QBs went to high school",
                                             "text": "Patrick Mahomes, Kyler Murray join 18 other quarterbacks who played high school football in Texas.",
                                             "thumbnailUrl": "https://images.maxpreps.com/editorial/article/a/e/0/ae0a7fa5-86bc-4082-91e3-4cf67d094940/29d89c6e-d17d-ea11-80ce-a444a33a3a97_original.jpg?version=637223926200000000",
                                             "thumbnailWidth": null,
                                             "thumbnailHeight": null,
                                             "canonicalUrl": "https://dev.maxpreps.com/news/pX8KrryGgkCR40z2fQlJQA/map--where-every-nfl-quarterback-drafted-in-the-past-10-years-played-high-school-football.htm"
                                         }
                                     ]
                                 }
                             ]
                         }
                     ],
                     "warnings": [],
                     "errors": []
                 }
                 */
            }
            else
            {
                print("Team Detail Fail")
            }
            
            // Enable or disable scrolling
            var contentHeight = 0
            
            // The header and record subview has a height of 112 which is added to the other views
            // Each contest subview is 46
            // The latestItems subview is 152
            
            for item in detailedFavoritesArray
            {
                let cardObject = item as! Dictionary<String,Any>
                
                let schedules = cardObject["schedules"] as! Array<Dictionary<String,Any>>
                let latestItems = cardObject["latestItems"] as! Array<Dictionary<String,Any>>
                
                // Set the display mode
                if ((schedules.count > 0) && (latestItems.count > 0))
                {
                    if (schedules.count == 1)
                    {
                        // One Contest
                        contentHeight += 120 + 46 + 152
                    }
                    else
                    {
                        // Both contests
                        contentHeight += 120 + 46 + 46 + 152
                    }
                }
                else if ((schedules.count > 0) && (latestItems.count == 0))
                {
                    if (schedules.count == 1)
                    {
                        // No Articles, one contest
                        contentHeight += 120 + 46
                    }
                    else
                    {
                        // No Articles, both contests
                        contentHeight += 120 + 46 + 46
                    }
                }
                else if ((schedules.count == 0) && (latestItems.count > 0))
                {
                    // No Contests
                    contentHeight += 120 + 152
                }
                else
                {
                    // Just the record field is displayed
                    contentHeight += 120
                }
            }
            
            // Add the header height
            var headerHeight = 0
            lastCellPadValue = 0
            
            if (favoriteAthletesArray.count > 0)
            {
                headerHeight = 50
            }
            
            contentHeight += headerHeight
                        
            // Table Height = 679
            // Content Height = 672
            
            // Disable scrolling if the content height is less than the tableView's frame
            if (contentHeight <= Int(favoritesTableView.frame.size.height))
            {
                favoritesTableView.isScrollEnabled = false
            }
            else
            {
                favoritesTableView.isScrollEnabled = true
                
                // Add some extra pad to the last cell to handle the bounce effect
                let heightDifference = contentHeight - Int(favoritesTableView.frame.size.height)
                
                if (heightDifference < Int(titleContainerView.frame.size.height) + kLastCellExtraPad)
                {
                    lastCellPadValue = CGFloat(heightDifference + kLastCellExtraPad)
                    //print("Footer Pad Value: " + String(lastCellPadValue))
                }
            }
            
            self.favoritesTableView.reloadData()
        }
    }
    
    // MARK: - Favorites List View Methods
    
    private func showFavoritesListView()
    {
        // Kill the ad timer so a new ad won't be shown on top of this view
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
        
        // Remove the ad so it doesn't self refresh
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
        
        self.tabBarController?.tabBar.isHidden = true
        
        favoritesListView = FavoritesListView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight))
        favoritesListView.delegate = self
        self.view.addSubview(favoritesListView)
        
        TrackingManager.trackState(featureName: "following-manage", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData as Dictionary<String, Any>)
    }
    
    func closeFavoritesListViewAfterChange()
    {
        favoritesListView.removeFromSuperview()
        favoritesListView = nil
        self.tabBarController?.tabBar.isHidden = false
        
        // Refresh the screen
        if let favTeams = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
        {
            favoriteTeamsArray = favTeams
        }
        
        if let favAthletes = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
        {
            favoriteAthletesArray = favAthletes
        }
        
        // Update the athlete buttons
        self.addAthleteButtons()
        
        // Show the empty favorites overlay
        if (favoriteTeamsArray.count == 0)
        {
            noFavoriteContainerView.isHidden = false
            editFavoritesButton.isHidden = true
        }
        else
        {
            noFavoriteContainerView.isHidden = true
            editFavoritesButton.isHidden = false
                 
            // Disable scrolling if the content height is less than the tableView's frame
            let headerHeight = 50
            lastCellPadValue = 0
            
            let contentHeight = (favoriteTeamsArray.count * 60) + headerHeight
            
            if (contentHeight < Int(favoritesTableView.frame.size.height))
            {
                favoritesTableView.isScrollEnabled = false
            }
            else
            {
                favoritesTableView.isScrollEnabled = true
                
                // Add some extra pad to the last cell to handle the bounce effect
                let heightDifference = contentHeight - Int(favoritesTableView.frame.size.height)
                
                if (heightDifference < Int(titleContainerView.frame.size.height) + kLastCellExtraPad)
                {
                    lastCellPadValue = CGFloat(heightDifference + kLastCellExtraPad)
                    //print("Footer Pad Value: " + String(lastCellPadValue))
                }
            }
            
            favoritesTableView.reloadData()
        }
        
        // Get card details if the favorite team count is within the maximum detailed favorites count
        if (favoriteTeamsArray.count > 0) && (favoriteTeamsArray.count <= kMaxDetailedFavorites)
        {
            self.getTeamDetailCardData()
        }
        
        // Show the ad
        self.loadBannerViews()
    }
    
    func closeFavoritesListView()
    {
        favoritesListView.removeFromSuperview()
        favoritesListView = nil
        self.tabBarController?.tabBar.isHidden = false
        
        // Show the ad
        self.loadBannerViews()
    }
    
    func joinButtonTouched(index: Int)
    {
        favoritesListView.removeFromSuperview()
        self.tabBarController?.tabBar.isHidden = false
        
        let selectedTeam = favoriteTeamsArray[index] as! Dictionary<String,Any>
        
        // Refactor the selected team into a Team object that is used by the TeamDetailVC
        let schoolId = selectedTeam[kNewSchoolIdKey] as! String
        let name = selectedTeam[kNewSchoolNameKey] as! String
        let fullName = selectedTeam[kNewSchoolFormattedNameKey] as! String
        let city = selectedTeam[kNewSchoolCityKey] as! String
        let state = selectedTeam[kNewSchoolStateKey] as! String
        let gender = selectedTeam[kNewGenderKey] as! String
        let sport = selectedTeam[kNewSportKey] as! String
        let level = selectedTeam[kNewLevelKey] as!String
        let season = selectedTeam[kNewSeasonKey] as!String
        let allSeasonId = selectedTeam[kNewAllSeasonIdKey] as! String
        var mascotUrlString = ""
        var hexColorString = ""
        
        // Make sure that the school info exists
        let schoolInfos = kUserDefaults.dictionary(forKey: kNewSchoolInfoDictionaryKey)

        if schoolInfos![schoolId] != nil
        {
            let schoolInfo = schoolInfos![schoolId] as! Dictionary<String, String>
            hexColorString = schoolInfo[kNewSchoolInfoColor1Key]!
            mascotUrlString = schoolInfo[kNewSchoolInfoMascotUrlKey]!
        }
        
        let selectedTeamObj = Team(teamId: 0, allSeasonId: allSeasonId, gender: gender, sport: sport, teamColor: hexColorString, mascotUrl: mascotUrlString, schoolName: name, teamLevel: level, schoolId: schoolId, schoolState: state, schoolCity: city, schoolFullName: fullName, season: season, notifications: [])
        
        /*
         Team Object
         var teamId: Double
         var allSeasonId: String
         var gender: String
         var sport: String
         var teamColor: String
         var mascotUrl: String
         var schoolName: String
         var teamLevel: String
         var schoolId: String
         var schoolState: String
         var schoolCity: String
         var schoolFullName: String
         var season: String
         var notifications: Array<Any>
         */
        
        roleSelectorVC = JoinTeamRoleSelectorViewController(nibName: "JoinTeamRoleSelectorViewController", bundle: nil)
        roleSelectorVC.selectedTeam = selectedTeamObj
        
        let roleSelectorNav = TopNavigationController()
        roleSelectorNav.viewControllers = [roleSelectorVC]
        roleSelectorNav.modalPresentationStyle = .fullScreen
                
        self.present(roleSelectorNav, animated: true)
        {
            
        }
    }
    
    // MARK: - Logout User
    
    private func logoutUser()
    {
        // Clear out the user's prefs
        MiscHelper.logoutUser()
        
        // Show the login landing page from the tabBarController
        let tabBarController = self.tabBarController as! TabBarController
        tabBarController.showLoginHomeVC()
        
    }
    
    // MARK: - Show Video Player
    
    private func showVideoPlayer(videoId: String, trackingKey: String, trackingContextData: Dictionary<String,Any>)
    {
        if (videoPlayerVC != nil)
        {
            videoPlayerVC = nil
        }
        
        videoPlayerVC = VideoPlayerViewController(nibName: "VideoPlayerViewController", bundle: nil)
        videoPlayerVC.videoIdString = videoId
        videoPlayerVC.trackingContextData = trackingContextData
        videoPlayerVC.trackingKey = trackingKey
        videoPlayerVC.modalPresentationStyle = .fullScreen
        self.present(videoPlayerVC, animated: true)
        {
            
        }
    }
    
    // MARK: - Show Web VC
    
    private func showWebViewController(urlString: String, title: String, showBannerAd: Bool, ftag: String, contestId: String)
    {
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
        webVC?.adId = kUserDefaults.value(forKey: kTeamsBannerAdIdKey) as! String
        webVC?.tabBarVisible = true
        webVC?.enableAdobeQueryParameter = true
        webVC?.trackingContextData = kEmptyTrackingContextData
        webVC?.trackingKey = "following-home"
        webVC?.contestId = contestId
        webVC?.ftag = ftag

        self.navigationController?.pushViewController(webVC!, animated: true)
        //self.hidesBottomBarWhenPushed = false
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
    
    // MARK: - Notification and Deep Link Handlers
    
    @objc private func showFollowingWebBrowser(notification: Notification)
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
                self.showWebViewController(urlString: fixedUrlString, title: "", showBannerAd: true, ftag: ftag, contestId: "")
            }
        }
    }
    
    @objc private func showCareerDeepLink(notification: Notification)
    {
        let careerId = notification.userInfo!["careerId"] as! String
        let ftag = notification.userInfo!["ftag"] as! String
        let tabName = notification.userInfo!["tabName"] as? String ?? ""
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
                self.athleteDetailVC.tabName = tabName
                
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
                self.teamDetailVC.showSaveFavoriteButton = showSaveFavoriteButton
                self.teamDetailVC.showRemoveFavoriteButton = showRemoveFavoriteButton
                self.teamDetailVC.ftag = ftag
                self.teamDetailVC.tabName = tabName
                self.navigationController?.pushViewController(self.teamDetailVC, animated: true)
            }
        }
    }
    
    // MARK: - Load User Image
    
    @objc private func loadUserImage()
    {
        // Get the user image
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        if (userId == kTestDriveUserId)
        {
            let image = UIImage.init(named: "EmptyProfileButton")
            profileButton?.setImage(image, for: .normal)
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
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return favoriteTeamsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (favoriteTeamsArray.count > 3)
        {
            // Add pad to the last cell to handle the in between case that causes jitter
            if (favoriteTeamsArray.count - 1 == indexPath.row)
            {
                return 60 + lastCellPadValue
            }
            else
            {
                return 60.0
            }
        }
        else
        {
            var height = CGFloat(0)
            
            // Need to make sure that this array has data because the table could be loaded before the feed finishes
            if (detailedFavoritesArray.count > indexPath.row)
            {
                let cardObject = detailedFavoritesArray[indexPath.row] as! Dictionary<String,Any>

                let schedules = cardObject["schedules"] as! Array<Dictionary<String,Any>>
                let latestItems = cardObject["latestItems"] as! Array<Dictionary<String,Any>>
                
                // Set the display mode
                if ((schedules.count > 0) && (latestItems.count > 0))
                {
                    if (schedules.count == 1)
                    {
                        height = 364.0 - 46.0 // One Contest
                    }
                    else
                    {
                        height = 364.0 // Both contests
                    }
                }
                else if ((schedules.count > 0) && (latestItems.count == 0))
                {
                    if (schedules.count == 1)
                    {
                        height = 364.0 - 152.0 - 46.0 // No Articles, one contest
                    }
                    else
                    {
                        height = 364.0 - 152.0 // No Articles, both contests
                    }
                }
                else if ((schedules.count == 0) && (latestItems.count > 0))
                {
                    height = 364.0 - 92.0 // No Contests
                }
                else
                {
                    height = 364.0 - 152.0 - 92.0 // Just the record field is displayed
                }
                
                // Add pad to the last cell to handle the in between case that causes jitter
                if (detailedFavoritesArray.count - 1 == indexPath.row)
                {
                    return height + lastCellPadValue
                }
                else
                {
                    return height
                }
            }
            else
            {
                return 0 // Everything is hidden
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 62 //0.01 // Ad pad
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
        let favorite = favoriteTeamsArray[indexPath.row] as! Dictionary<String, Any>
        
        let name = favorite[kNewSchoolNameKey] as! String
        let initial = String(name.prefix(1))
        
        let gender = favorite[kNewGenderKey] as! String
        let sport = favorite[kNewSportKey] as! String
        let level = favorite[kNewLevelKey] as!String
        let schoolId = favorite[kNewSchoolIdKey] as!String
        let allSeasonId = favorite[kNewAllSeasonIdKey] as! String
        
        let levelGenderSport = MiscHelper.genderSportLevelFrom(gender: gender, sport: sport, level: level)
        
        // Different cells depending on the favorites count
        if (favoriteTeamsArray.count > 3)
        {
            // Short Cell
            var cell = tableView.dequeueReusableCell(withIdentifier: "ShortFavoriteTeamTableViewCell") as? ShortFavoriteTeamTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("ShortFavoriteTeamTableViewCell", owner: self, options: nil)
                cell = nib![0] as? ShortFavoriteTeamTableViewCell
            }
            
            cell?.selectionStyle = .none
            
            cell?.teamFirstLetterLabel.isHidden = false
            cell?.adminContainerView.isHidden = true
            cell?.joinButton.isHidden = true

            cell?.subtitleLabel.text =  levelGenderSport
            cell?.titleLabel.text = name
            cell?.teamFirstLetterLabel.text = initial
            
            // Look at the roles dictionary for a match if a logged in user
            let userId = kUserDefaults.string(forKey: kUserIdKey)
            
            if (userId != kTestDriveUserId)
            {
                let userIsAdmin = MiscHelper.isUserAnAdmin(schoolId: schoolId, allSeasonId: allSeasonId)
                
                if (userIsAdmin == true)
                {
                    cell?.adminContainerView.isHidden = false
                }
            }
            
            // Look for a mascot
            if let schoolsInfo = kUserDefaults.dictionary(forKey: kNewSchoolInfoDictionaryKey)
            {
                if let schoolInfo = schoolsInfo[schoolId] as? Dictionary<String, String>
                {
                    // Set the first letter color
                    let hexColorString = schoolInfo[kNewSchoolInfoColor1Key]!
                    let color = ColorHelper.color(fromHexString: hexColorString, colorCorrection: true)
                    
                    cell?.teamFirstLetterLabel.textColor = color
                    cell?.teamFirstLetterLabel.isHidden = true
                    
                    let mascotUrl = schoolInfo[kNewSchoolInfoMascotUrlKey]
                    let url = URL(string: mascotUrl!)

                    if (mascotUrl!.count > 0)
                    {
                        /*
                        // Get the data and make an image
                        MiscHelper.getData(from: url!) { data, response, error in
                            guard let data = data, error == nil else { return }

                            DispatchQueue.main.async()
                            {
                                let image = UIImage(data: data)
                                
                                if (image != nil)
                                {
                                    // Render the mascot using this helper
                                    MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (cell?.teamMascotImageView)!)
                                }
                                else
                                {
                                    cell?.teamFirstLetterLabel.isHidden = false
                                }
                            }
                        }
                        */
                        SDWebImageManager.shared().downloadImage(with: url!, progress: { receivedSize, expectedSize in
                            
                        }, completed: { image, error, cacheType, finished, imageUrl in
                            
                            if (image != nil)
                            {
                                // Render the mascot using this helper
                                MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (cell?.teamMascotImageView)!)
                            }
                            else
                            {
                                cell?.teamFirstLetterLabel.isHidden = false
                            }
                        })
                    }
                    else
                    {
                        cell?.teamFirstLetterLabel.isHidden = false
                    }
                }
            }
            
            return cell!
    
        }
        else
        {
            // Tall Cell
            var cell = tableView.dequeueReusableCell(withIdentifier: "TallFavoriteTeamTableViewCell") as? TallFavoriteTeamTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("TallFavoriteTeamTableViewCell", owner: self, options: nil)
                cell = nib![0] as? TallFavoriteTeamTableViewCell
            }
            
            cell?.delegate = self
            cell?.selectionStyle = .none
            
            // Need to make sure that this array has data because the table could be loaded before the feed finishes
            if (detailedFavoritesArray.count > indexPath.row)
            {
                let cardObject = detailedFavoritesArray[indexPath.row] as! Dictionary<String,Any>
                let record = cardObject["record"] as! Dictionary<String,Any>
                let schedules = cardObject["schedules"] as! Array<Dictionary<String,Any>>
                let latestItems = cardObject["latestItems"] as! Array<Dictionary<String,String>>
                
                // Set the display mode
                if ((schedules.count > 0) && (latestItems.count > 0))
                {
                    cell?.loadTeamRecordData(record)
                    cell?.loadArticleData(latestItems)
                    
                    if (schedules.count == 1)
                    {
                        cell?.setDisplayMode(mode: FavoriteDetailCellMode.allCellsOneContest)
                        let contest = schedules.first
                        cell?.loadTopContestData(contest!)
                    }
                    else
                    {
                        cell?.setDisplayMode(mode: FavoriteDetailCellMode.allCells)
                        let contest1 = schedules.first
                        cell?.loadTopContestData(contest1!)
                        
                        let contest2 = schedules.last
                        cell?.loadBottomContestData(contest2!)
                    }
                }
                else if ((schedules.count > 0) && (latestItems.count == 0))
                {
                    cell?.loadTeamRecordData(record)
                    
                    if (schedules.count == 1)
                    {
                        cell?.setDisplayMode(mode: FavoriteDetailCellMode.noArticlesOneContest)
                        let contest = schedules.first
                        cell?.loadTopContestData(contest!)
                    }
                    else
                    {
                        cell?.setDisplayMode(mode: FavoriteDetailCellMode.noArticlesAllContests)
                        let contest1 = schedules.first
                        cell?.loadTopContestData(contest1!)
                        
                        let contest2 = schedules.last
                        cell?.loadBottomContestData(contest2!)
                    }
                }
                else if ((schedules.count == 0) && (latestItems.count > 0))
                {
                    cell?.setDisplayMode(mode: FavoriteDetailCellMode.noContests)
                    cell?.loadTeamRecordData(record)
                    cell?.loadArticleData(latestItems)
                }
                else
                {
                    cell?.setDisplayMode(mode: FavoriteDetailCellMode.noContestsOrArticles)
                    cell?.loadTeamRecordData(record)
                }
            }
            
            cell?.teamFirstLetterLabel.isHidden = false
            cell?.adminContainerView.isHidden = true
            cell?.memberContainerView.isHidden = true

            cell?.subtitleLabel.text =  levelGenderSport
            cell?.titleLabel.text = name
            cell?.teamFirstLetterLabel.text = initial
            cell?.sportIconImageView.image = MiscHelper.getImageForSport(sport)
            
            // Look at the roles dictionary for a match if a logged in user
            let userId = kUserDefaults.string(forKey: kUserIdKey)
            
            if (userId != kTestDriveUserId)
            {
                let userIsAdmin = MiscHelper.isUserAnAdmin(schoolId: schoolId, allSeasonId: allSeasonId)
                
                if (userIsAdmin == true)
                {
                    cell?.adminContainerView.isHidden = false
                }
            }
            
            // Look for a mascot
            if let schoolsInfo = kUserDefaults.dictionary(forKey: kNewSchoolInfoDictionaryKey)
            {
                if let schoolInfo = schoolsInfo[schoolId] as? Dictionary<String, String>
                {
                    // Set the cell's fill color
                    let hexColorString = schoolInfo[kNewSchoolInfoColor1Key]!
                    let color = ColorHelper.color(fromHexString: hexColorString, colorCorrection: true)
                    cell?.addShapeLayers(color: color!)
                    
                    // Set the first letter color
                    cell?.teamFirstLetterLabel.textColor = color
                    cell?.teamFirstLetterLabel.isHidden = true
                    
                    let mascotUrl = schoolInfo[kNewSchoolInfoMascotUrlKey]
                    let url = URL(string: mascotUrl!)

                    if (mascotUrl!.count > 0)
                    {
                        /*
                        // Get the data and make an image
                        MiscHelper.getData(from: url!) { data, response, error in
                            guard let data = data, error == nil else { return }
                            //print("Download Finished")
                            DispatchQueue.main.async()
                            {
                                let image = UIImage(data: data)
                                
                                if (image != nil)
                                {
                                    cell?.teamFirstLetterLabel.isHidden = true
                                    
                                    // Render the mascot using this helper
                                    MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (cell?.teamMascotImageView)!)
                                }
                                else
                                {
                                    cell?.teamFirstLetterLabel.isHidden = false
                                }
                            }
                        }
                        */
                        SDWebImageManager.shared().downloadImage(with: url!, progress: { receivedSize, expectedSize in
                            
                        }, completed: { image, error, cacheType, finished, imageUrl in
                            
                            if (image != nil)
                            {
                                // Render the mascot using this helper
                                MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (cell?.teamMascotImageView)!)
                            }
                            else
                            {
                                cell?.teamFirstLetterLabel.isHidden = false
                            }
                        })
                    }
                    else
                    {
                        cell?.teamFirstLetterLabel.isHidden = false
                    }
                }
            }
            
            return cell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedTeam = favoriteTeamsArray[indexPath.row] as! Dictionary<String,Any>
        
        // Refactor the selected team into a Team object that is used by the TeamDetailVC
        let schoolId = selectedTeam[kNewSchoolIdKey] as! String
        let name = selectedTeam[kNewSchoolNameKey] as! String
        let fullName = selectedTeam[kNewSchoolFormattedNameKey] as! String
        let city = selectedTeam[kNewSchoolCityKey] as! String
        let state = selectedTeam[kNewSchoolStateKey] as! String
        let gender = selectedTeam[kNewGenderKey] as! String
        let sport = selectedTeam[kNewSportKey] as! String
        let level = selectedTeam[kNewLevelKey] as!String
        let season = selectedTeam[kNewSeasonKey] as!String
        let allSeasonId = selectedTeam[kNewAllSeasonIdKey] as! String
        var mascotUrlString = ""
        var hexColorString = ""
        
        // Get the teamId if it exists
        var teamId = 0
        
        if (selectedTeam[kNewUserfavoriteTeamIdKey] != nil)
        {
            teamId = selectedTeam[kNewUserfavoriteTeamIdKey] as! Int
        }
        
        // Make sure that the school info exists
        let schoolInfos = kUserDefaults.dictionary(forKey: kNewSchoolInfoDictionaryKey)

        if schoolInfos![schoolId] != nil
        {
            let schoolInfo = schoolInfos![schoolId] as! Dictionary<String, String>
            hexColorString = schoolInfo[kNewSchoolInfoColor1Key]!
            mascotUrlString = schoolInfo[kNewSchoolInfoMascotUrlKey]!
        }
        
        let selectedTeamObj = Team(teamId: teamId, allSeasonId: allSeasonId, gender: gender, sport: sport, teamColor: hexColorString, mascotUrl: mascotUrlString, schoolName: name, teamLevel: level, schoolId: schoolId, schoolState: state, schoolCity: city, schoolFullName: fullName, season: season, notifications: [])
        
        /*
         Team Object
         var teamId: Int
         var allSeasonId: String
         var gender: String
         var sport: String
         var teamColor: String
         var mascotUrl: String
         var schoolName: String
         var teamLevel: String
         var schoolId: String
         var schoolState: String
         var schoolCity: String
         var schoolFullName: String
         var season: String
         var notifications: Array<Any>
         */
        
        teamDetailVC = TeamDetailViewController(nibName: "TeamDetailViewController", bundle: nil)
        teamDetailVC.selectedTeam = selectedTeamObj
        teamDetailVC.showSaveFavoriteButton = false
        teamDetailVC.showRemoveFavoriteButton = true
        self.navigationController?.pushViewController(teamDetailVC, animated: true)
        
    }
    
    // MARK: - TallTableViewCell Delegate Methods
    
    func collectionViewDidSelectWebItem(urlString: String, title: String)
    {
        self.showWebViewController(urlString: urlString, title: title, showBannerAd: true, ftag: "", contestId: "")
    }
    
    func collectionViewDidSelectVideoItem(videoId: String)
    {
        self.showVideoPlayer(videoId: videoId, trackingKey: "following-home", trackingContextData: kEmptyTrackingContextData)
    }
    
    func topContestTouched(urlString: String, contestId: String)
    {
        if (urlString.count > 0)
        {
            self.showWebViewController(urlString: urlString, title: "Box Score", showBannerAd: true, ftag: "", contestId: contestId)
        }
        else
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Not Available", message: "The contest page for this game is not available.", lastItemCancelType: false) { tag in
                
            }
        }
    }
    
    func bottomContestTouched(urlString: String, contestId: String)
    {
        if (urlString.count > 0)
        {
            self.showWebViewController(urlString: urlString, title: "Box Score", showBannerAd: true, ftag: "", contestId: contestId)
        }
        else
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Not Available", message: "The contest page for this game is not available.", lastItemCancelType: false) { tag in
                
            }
        }
    }
    
    // MARK: - Build Athlete Buttons
    
    private func addAthleteButtons()
    {
        // Remove existing buttons
        let scrollViewSubviews = athleteContainerScrollView.subviews
        for subview in scrollViewSubviews
        {
            subview.removeFromSuperview()
        }
        
        // Remove the shadows from the titleContainerView
        let subviews = titleContainerView.subviews
        for subview in subviews
        {
            if (subview.tag == 200) || (subview.tag == 201)
            {
                subview.removeFromSuperview()
            }
        }
        
        // Fill the scrollView with buttons
        var count = 0
        var overallWidth = 0
        let textPad = 12
        let buttonSpace = 12
        var leftPad = 0
        let rightPad = 16
        let imagePad = 20
        
        for athlete in favoriteAthletesArray as! Array<Dictionary<String,Any>>
        {
            let firstName = athlete[kCareerProfileFirstNameKey] as! String
            let lastName = athlete[kCareerProfileLastNameKey] as! String
            let fullName = firstName + " " + lastName
            //let schoolName = athlete[kCareerProfileSchoolNameKey] as! String
            //let initial = String(schoolName.prefix(1))
            //let schoolColor = athlete[kCareerProfileSchoolColor1Key] as! String
            //let mascotUrl = athlete[kCareerProfileSchoolMascotUrlKey] as! String
            let photoUrlString = athlete[kCareerProfilePhotoUrlKey] as! String
            
            let textWidth = Int(fullName.widthOfString(usingFont: UIFont.mpSemiBoldFontWith(size: 14))) + (2 * textPad)
            let tag = 100 + count
            
            // Add the left pad to the first cell
            if (count == 0)
            {
                leftPad = 16
            }
            else
            {
                leftPad = 0
            }
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: overallWidth + leftPad, y: 9, width: textWidth + imagePad, height: 32)
            button.tag = tag
            button.backgroundColor = UIColor.mpOffWhiteNavColor()
            button.layer.cornerRadius = button.frame.size.height / 2.0
            //button.layer.borderWidth = 1
            //button.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
            //button.clipsToBounds = true
            button.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 14)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
            button.setTitle(fullName, for: .normal)
            button.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
            button.addTarget(self, action: #selector(self.athleteButtonTouched), for: .touchUpInside)
            
            // Add a shadow to the button
            button.layer.masksToBounds = false
            button.layer.shadowColor = UIColor(white: 0.7, alpha: 1.0).cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 2.0)
            button.layer.shadowRadius = 2
            button.layer.shadowOpacity = 0.5
            
            // Add the athlete's image (if it's available)
            let imageView = UIImageView(frame: CGRect(x: 7, y: 6, width: 20, height: 20))
            imageView.contentMode = .scaleAspectFill
            imageView.image = UIImage(named: "Avatar")
            imageView.isUserInteractionEnabled = true
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            button.addSubview(imageView)
            
            if (photoUrlString.count > 0)
            {
                let url = URL(string: photoUrlString)
                
                /*
                // Get the data and make an image
                MiscHelper.getData(from: url!) { data, response, error in
                    guard let data = data, error == nil else { return }

                    DispatchQueue.main.async()
                    {
                        let image = UIImage(data: data)
                        
                        if (image != nil)
                        {
                            imageView.image = image
                        }
                    }
                }
                */
                SDWebImageManager.shared().downloadImage(with: url!, progress: { receivedSize, expectedSize in
                    
                }, completed: { image, error, cacheType, finished, imageUrl in
                    
                    if (image != nil)
                    {
                        imageView.image = image
                    }
                })
            }
            
            athleteContainerScrollView!.addSubview(button)
            
            count += 1
            overallWidth += (textWidth + imagePad + leftPad + buttonSpace)
        }
        
        var addAthletePad = 0
        if (favoriteAthletesArray.count == 0)
        {
            addAthletePad = 16
        }
        
        let addAthleteButton = UIButton(type: .custom)
        addAthleteButton.frame = CGRect(x: overallWidth + addAthletePad, y: 9, width: 130, height: 32)
        addAthleteButton.backgroundColor = UIColor.mpOffWhiteNavColor()
        addAthleteButton.setTitle("Add Athlete", for: .normal)
        addAthleteButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 14)
        addAthleteButton.setTitleColor(UIColor.mpBlueColor(), for: .normal)
        addAthleteButton.setImage(UIImage(named: "RoundBluePlus"), for: .normal)
        addAthleteButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: -3)
        addAthleteButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 5)
        addAthleteButton.layer.cornerRadius = 16
        //addAthleteButton.clipsToBounds = true
        
        // Add a shadow to the button
        addAthleteButton.layer.masksToBounds = false
        addAthleteButton.layer.shadowColor = UIColor(white: 0.7, alpha: 1.0).cgColor
        addAthleteButton.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        addAthleteButton.layer.shadowRadius = 2
        addAthleteButton.layer.shadowOpacity = 0.5
        
        addAthleteButton.addTarget(self, action: #selector(addAthleteButtonTouched), for: .touchUpInside)
        athleteContainerScrollView.addSubview(addAthleteButton)
        
        overallWidth += (130 + leftPad + buttonSpace)
        
        athleteContainerScrollView!.contentSize = CGSize(width: overallWidth + rightPad + buttonSpace, height: Int(athleteContainerScrollView!.frame.size.height))
        
        // Add the left and right shadows
        leftShadow = UIImageView(frame: CGRect(x: 0, y: Int(athleteContainerScrollView.frame.origin.y) + 9, width: 70, height: Int(athleteContainerScrollView!.frame.size.height) - 10))
        leftShadow.image = UIImage(named: "LeftShadowWhite")
        leftShadow.clipsToBounds = true
        leftShadow.tag = 200
        titleContainerView.addSubview(leftShadow)
        leftShadow.isHidden = true
        
        rightShadow = UIImageView(frame: CGRect(x: Int(kDeviceWidth) - 70, y: Int(athleteContainerScrollView.frame.origin.y) + 9, width: 70, height: Int(athleteContainerScrollView!.frame.size.height) - 10))
        rightShadow.image = UIImage(named: "RightShadowWhite")
        rightShadow.clipsToBounds = true
        rightShadow.tag = 201
        titleContainerView.addSubview(rightShadow)
        
        // Hide the rightShadow if the scrollView contentSize.x is smaller than the width
        if (athleteContainerScrollView!.contentSize.width <= kDeviceWidth)
        {
            rightShadow.isHidden = true
        }
    }
    
    // MARK: - Button Methods
    
    @objc private func profileButtonTouched()
    {
        if (toolTipActive == true)
        {
            return
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
        
        searchVC = SearchViewController(nibName: "SearchViewController", bundle: nil)
        self.navigationController?.pushViewController(searchVC!, animated: true)
    }
    
    @objc private func athleteButtonTouched(_ sender: UIButton)
    {
        if (toolTipActive == true)
        {
            return
        }
        
        let index = sender.tag - 100
        
        // Favorite Athlete
        let favoriteAthletes = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
        
        if (favoriteAthletes != nil) && (favoriteAthletes!.count > 0)
        {
            let favoriteAthlete = favoriteAthletes?[index] as! Dictionary<String, Any>
            
            /*
             let kCareerProfileFirstNameKey = "careerProfileFirstName"        // String
             let kCareerProfileLastNameKey = "careerProfileLastName"          // String
             let kCareerProfileSchoolNameKey = "schoolName"                   // String
             let kCareerProfileSchoolIdKey = "schoolId"                       // String
             let kCareerProfileSchoolColor1Key = "schoolColor1"               // String
             let kCareerProfileSchoolMascotUrlKey = "schoolMascotUrl"         // String
             let kCareerProfileSchoolCityKey = "schoolCity"                   // String
             let kCareerProfileSchoolStateKey = "schoolState"                 // String
             let kCareerProfileIdKey = "careerProfileId"                      // String
             let kCareerProfilePhotoUrlKey = "photoUrl"                       // String
             */
            
            let schoolId = favoriteAthlete[kCareerProfileSchoolIdKey] as? String ?? ""
            
            // Added this to block the athleteDetailVC from opening if the school is missing
            if (schoolId.count == 0)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "We are unable to find this athlete's school information.", lastItemCancelType: false) { tag in
                    
                }
                
                return
            }
            
            let firstName = favoriteAthlete[kCareerProfileFirstNameKey] as! String
            let lastName = favoriteAthlete[kCareerProfileLastNameKey] as! String
            let schoolName = favoriteAthlete[kCareerProfileSchoolNameKey] as! String
            let schoolColor1 = favoriteAthlete[kCareerProfileSchoolColor1Key] as! String
            let schoolMascotUrl = favoriteAthlete[kCareerProfileSchoolMascotUrlKey] as! String
            let schoolCity = favoriteAthlete[kCareerProfileSchoolCityKey] as! String
            let schoolState = favoriteAthlete[kCareerProfileSchoolStateKey] as! String
            let careerProfileId = favoriteAthlete[kCareerProfileIdKey] as! String
            let photoUrl = ""
            
            let selectedAthlete = Athlete(firstName: firstName, lastName: lastName, schoolName: schoolName, schoolState: schoolState, schoolCity: schoolCity, schoolId: schoolId, schoolColor: schoolColor1, schoolMascotUrl: schoolMascotUrl, careerId: careerProfileId, photoUrl: photoUrl)
            
            let athleteDetailVC = NewAthleteDetailViewController(nibName: "NewAthleteDetailViewController", bundle: nil)
            athleteDetailVC.selectedAthlete = selectedAthlete
            athleteDetailVC.showSaveFavoriteButton = false
            
            if (kUserDefaults.object(forKey: kUserIdKey) as! String == kTestDriveUserId)
            {
                athleteDetailVC.showRemoveFavoriteButton = false
            }
            else
            {
                athleteDetailVC.showRemoveFavoriteButton = true
            }
            
            self.navigationController?.pushViewController(athleteDetailVC, animated: true)
        }
    }
    
    @IBAction func favoritesButtonTouched(_ sender: UIButton)
    {
        if (toolTipActive == true)
        {
            return
        }
        
        self.showFavoritesListView()
    }
    
    @objc private func addAthleteButtonTouched()
    {
        if (toolTipActive == true)
        {
            return
        }
        
        searchVC = SearchViewController(nibName: "SearchViewController", bundle: nil)
        searchVC.athleteMode = true
        self.navigationController?.pushViewController(searchVC!, animated: true)
    }
    
    @IBAction func searchOrSignUpButtonTouched()
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        if (userId == kTestDriveUserId)
        {
            self.logoutUser()
        }
        else
        {
            searchVC = SearchViewController(nibName: "SearchViewController", bundle: nil)
            self.navigationController?.pushViewController(searchVC!, animated: true)
        }
    }
    
    @IBAction func testButtonTouched()
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
        {
            self.showTeamVideoUploadToolTip()
        }
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
        // Skip if the user doesn't have any favorites
        let favTeams = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
        if (favTeams?.count == 0)
        {
            return
        }
        
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
        self.requestAmazonBannerAd()
        
        // Added for Nimbus
        // Starts a task to refresh every 30 seconds with proper foreground/background notifications
        //dynamicPriceManager.autoRefresh { [weak self] request in
        dynamicPriceManager.autoRefresh { request in
            
            request.customTargeting?.updateValue(SharedData.followingTabBaseGuid, forKey: "vguid")
            
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
    
    // MARK: - Initialize Data Method
    
    @objc private func initializeData()
    {        
        // Set the image to the settings icon if a Test Drive user right away
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        if (userId == kTestDriveUserId)
        {
            //profileButton?.setImage(UIImage.init(named: "SettingsButton"), for: .normal)
            profileButton?.setImage(UIImage.init(named: "EmptyProfileButton"), for: .normal)
            
            noFavoriteGetStartedButton.setTitle("SIGN UP", for: .normal)
            noFavoriteTitleLabel.text = "Become a Member"
            noFavoriteMessageLabel.text = "Members can customize the app with your favorite teams and athletes."
        }
        else
        {
            // Load the user image or the career image
            self.loadUserImage()
            
            noFavoriteGetStartedButton.setTitle("GET STARTED", for: .normal)
            noFavoriteTitleLabel.text = "Follow Teams and Players"
            noFavoriteMessageLabel.text = "Follow your favorites to receive the latest news, scores, rankings and more."
        }
        
        // Load the favorites
        favoriteTeamsArray.removeAll()
        favoriteAthletesArray.removeAll()
        
        if let favTeams = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
        {
            favoriteTeamsArray = favTeams
        }
        
        if let favAthletes = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
        {
            favoriteAthletesArray = favAthletes
        }
        
        favoritesTableView.reloadData()
        
        // Build the athlete pills
        self.addAthleteButtons()
        
        // Hide the table if the teams count is zero
        if (favoriteTeamsArray.count == 0)
        {
            noFavoriteContainerView.isHidden = false
            
            if (favoriteAthletesArray.count == 0)
            {
                editFavoritesButton.isHidden = true
            }
            else
            {
                editFavoritesButton.isHidden = false
            }
        }
        else
        {
            noFavoriteContainerView.isHidden = true
            editFavoritesButton.isHidden = false
            
            var contentHeight = 0
            lastCellPadValue = 0
            
            // Disable scrolling if the content height is less than the tableView's frame
            // If the favorites count is less, then this is calculated in the getTeamDetailCardData() method
            if (favoriteTeamsArray.count > 3)
            {
                var headerHeight = 0
                if (favoriteAthletesArray.count > 0)
                {
                    headerHeight = 50
                }
                
                contentHeight = headerHeight + (favoriteTeamsArray.count * 60)
            }
            
            if (contentHeight <= Int(favoritesTableView.frame.size.height))
            {
                favoritesTableView.isScrollEnabled = true //false
            }
            else
            {
                favoritesTableView.isScrollEnabled = true
                
                // Add some extra pad to the last cell to handle the bounce effect
                let heightDifference = contentHeight - Int(favoritesTableView.frame.size.height)
                
                if (heightDifference < Int(titleContainerView.frame.size.height) + kLastCellExtraPad)
                {
                    lastCellPadValue = CGFloat(heightDifference + kLastCellExtraPad)
                    //print("Footer Pad Value: " + String(lastCellPadValue))
                }
            }
        }
        
        // Get card details if the favorite team count is within the maximum detailed favorites count
        if (favoriteTeamsArray.count > 0) && (favoriteTeamsArray.count <= kMaxDetailedFavorites)
        {
            self.getTeamDetailCardData()
        }
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if (scrollView == athleteContainerScrollView)
        {
            let xScroll = Int(scrollView.contentOffset.x)
            
            if (xScroll <= 0)
            {
                leftShadow.isHidden = true
                rightShadow.isHidden = false
            }
            else if ((xScroll > 0) && (xScroll < (Int(athleteContainerScrollView!.contentSize.width) - Int(kDeviceWidth) - 40)))
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
        else
        {
            // TableView is scrolling
            let yScroll = Int(scrollView.contentOffset.y)
            let fakeStatusBarHeight = Int(fakeStatusBar.frame.size.height)
            let navViewHeight =  Int(navView.frame.size.height)
            let titleContainerViewHeight = Int(titleContainerView.frame.size.height)
            let headerHeight = fakeStatusBarHeight + navViewHeight + titleContainerViewHeight
            
            if (yScroll <= 0)
            {
                titleContainerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: titleContainerView.frame.size.height)

                favoritesTableView.frame = CGRect(x: 0, y: fakeStatusBarHeight + navViewHeight + titleContainerViewHeight, width: Int(kDeviceWidth), height: Int(kDeviceHeight) - headerHeight - bottomTabBarPad - Int(SharedData.bottomSafeAreaHeight))
                
                // This prevents the table from scrolling down
                //favoritesTableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                
                largeTitleLabel.alpha = 1
                navTitleLabel.alpha = 0
            }
            else if ((yScroll > 0) && (yScroll < titleContainerViewHeight - Int(athleteContainerScrollView.frame.size.height)))
            {
                titleContainerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height - CGFloat(yScroll), width: kDeviceWidth, height: titleContainerView.frame.size.height)
                            
                //favoritesTableView.frame = CGRect(x: 0, y: fakeStatusBarHeight + navViewHeight + titleContainerViewHeight - yScroll, width: Int(kDeviceWidth), height: Int(kDeviceHeight) - headerHeight - bottomTabBarPad - Int(SharedData.bottomSafeAreaHeight) + yScroll - Int(athleteContainerScrollView.frame.size.height))
                favoritesTableView.frame = CGRect(x: 0, y: fakeStatusBarHeight + navViewHeight + titleContainerViewHeight - yScroll, width: Int(kDeviceWidth), height: Int(kDeviceHeight) - headerHeight - bottomTabBarPad - Int(SharedData.bottomSafeAreaHeight) + yScroll)
                
                // Fade at twice the scroll rate
                let fade = 1.0 - (CGFloat(2 * yScroll) / CGFloat(titleContainerViewHeight))
                largeTitleLabel.alpha = fade
                navTitleLabel.alpha = 1 - fade
            }
            else
            {
                titleContainerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height - CGFloat(titleContainerViewHeight) + athleteContainerScrollView.frame.size.height, width: kDeviceWidth, height: CGFloat(titleContainerViewHeight))
                            
                favoritesTableView.frame = CGRect(x: 0, y: fakeStatusBarHeight + navViewHeight + Int(athleteContainerScrollView.frame.size.height), width: Int(kDeviceWidth), height: Int(kDeviceHeight) - headerHeight - bottomTabBarPad - Int(SharedData.bottomSafeAreaHeight) + titleContainerViewHeight - Int(athleteContainerScrollView.frame.size.height))
                
                largeTitleLabel.alpha = 0
                navTitleLabel.alpha = 1
            }
        }
    }
    
    // MARK: - Tool Tip Delegates
    
    func toolTipThreeClosed()
    {
        toolTipActive = false
    }
    
    func toolTipNineClosed()
    {
        toolTipActive = false
    }
    
    func teamUploadToolTipClosed()
    {
        toolTipActive = false
    }
    
    // MARK: - Show Tool Tips
    
    private func showToolTips()
    {
        let currentLaunchCount = kUserDefaults.object(forKey: kAppLaunchCountKey) as! Int
        
        // Show the tool tip after a small delay if not seen before
        if (kUserDefaults.bool(forKey: kToolTipThreeShownKey) == false)
        {
            if (currentLaunchCount >= 2)
            {
                // Scroll the table to the top
                favoritesTableView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
                
                toolTipActive = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
                {
                    self.toolTipThreeVC = ToolTipThreeViewController(nibName: "ToolTipThreeViewController", bundle: nil)
                    self.toolTipThreeVC.delegate = self
                    self.toolTipThreeVC.modalPresentationStyle = .overFullScreen
                    self.self.present(self.toolTipThreeVC, animated: false)
                }
            }
        }
        else
        {
            // Show tool tip nine if logged in, user does not have admin access, launch >= 4, and userType == High School Coach or Statistician
            
            if (kUserDefaults.string(forKey: kUserIdKey) != kTestDriveUserId)
            {
                if (MiscHelper.userIsCoach().isCoach == false)
                {
                    // Show tool tip nine on launch 4 if the edit button is visible
                    if (currentLaunchCount >= 4)
                    {
                        if ((kUserDefaults.string(forKey: kUserTypeKey) == "High School Coach") || (kUserDefaults.string(forKey: kUserTypeKey) == "Statistician"))
                        {
                            if ((kUserDefaults.bool(forKey: kToolTipNineShownKey) == false) && (self.editFavoritesButton.isHidden == false))
                            {
                                // Scroll the table to the top
                                favoritesTableView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
                                
                                toolTipActive = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
                                {
                                    self.toolTipNineVC = ToolTipNineViewController(nibName: "ToolTipNineViewController", bundle: nil)
                                    self.toolTipNineVC.delegate = self
                                    self.toolTipNineVC.modalPresentationStyle = .overFullScreen
                                    self.self.present(self.toolTipNineVC, animated: false)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func showTeamVideoUploadToolTip()
    {
        // Make sure the tab didn't change
        if (self.tabBarController?.selectedIndex != 1)
        {
            return
        }
        
        // Scroll the table to the top
        favoritesTableView.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)

        teamUploadToolTipVC = TeamUploadToolTipViewController(nibName: "TeamUploadToolTipViewController", bundle: nil)
        teamUploadToolTipVC.modalPresentationStyle = .overFullScreen
        teamUploadToolTipVC.delegate = self
        self.present(teamUploadToolTipVC, animated: false)
        
        toolTipActive = true
    }
    
    // MARK: - Pull to Refresh
    
    @objc private func pullToRefresh()
    {
        if (favoritesRefreshControl.isRefreshing == true)
        {
            self.getUserFavoriteTeamsFromDatabase()
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
    
    // MARK: - App Will Enter Foreground Notification
    
    @objc private func applicationWillEnterForeground()
    {
        // Refresh the ad if this VC is the active one
        if (self.tabBarController?.selectedIndex == 1)
        {
            self.loadBannerViews()
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        trackingGuid = SharedData.followingTabBaseGuid
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.view.backgroundColor = UIColor.mpWhiteColor()
        
        if (self.tabBarController?.tabBar.isHidden == false)
        {
            bottomTabBarPad = kTabBarHeight
        }

        // Explicitly set the header view sizes
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        titleContainerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: titleContainerView.frame.size.height)
        
        let fakeStatusBarHeight = Int(fakeStatusBar.frame.size.height)
        let navViewHeight =  Int(navView.frame.size.height)
        let titleContainerViewHeight = Int(titleContainerView.frame.size.height)
        
        let headerHeight = fakeStatusBarHeight + navViewHeight + titleContainerViewHeight
        
        favoritesTableView.frame = CGRect(x: 0, y: headerHeight, width: Int(kDeviceWidth), height: Int(kDeviceHeight) - headerHeight - bottomTabBarPad - Int(SharedData.bottomSafeAreaHeight))
        favoritesTableView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        print("Table Height: " + String(Int(favoritesTableView.frame.size.height)))
        
        let userId = kUserDefaults.object(forKey: kUserIdKey) as! String
        
        if (userId != kTestDriveUserId)
        {
            // Add refresh control to the browser if a real user
            favoritesRefreshControl.tintColor = UIColor.mpLightGrayColor()
            //let attributedString = NSMutableAttributedString(string: "Refreshing Favorites", attributes: [NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 14), NSAttributedString.Key.foregroundColor: UIColor.mpLightGrayColor()])
            //favoritesRefreshControl.attributedTitle = attributedString
            favoritesRefreshControl.addTarget(self, action: #selector(pullToRefresh), for: UIControl.Event.valueChanged)
            favoritesTableView.addSubview(favoritesRefreshControl)
        }
                
        // Resize the noFavoritesContainer, imageView, and move the innerContainer
        noFavoriteContainerView.frame = CGRect(x: 0, y: fakeStatusBarHeight + navViewHeight + titleContainerViewHeight, width: Int(kDeviceWidth), height: Int(kDeviceHeight) - headerHeight - bottomTabBarPad - Int(SharedData.bottomSafeAreaHeight))
        
        let initialImageWidth = noFavoritesImageView.frame.size.width
        let initialImageHeight = noFavoritesImageView.frame.size.height
        let scale = CGFloat(kDeviceWidth / 414)
        let aspectRatio = initialImageWidth / initialImageHeight
        let newImageWidth = initialImageWidth * scale
        let newImageHeight = newImageWidth / aspectRatio
        
        noFavoritesImageView.frame = CGRect(x: noFavoritesImageView.frame.origin.x, y: noFavoritesImageView.frame.origin.y, width: newImageWidth, height: newImageHeight)
        
        noFavoriteInnerContainerView.frame = CGRect(x: 0, y: noFavoritesImageView.frame.origin.y + noFavoritesImageView.frame.size.height, width: CGFloat(kDeviceWidth), height: noFavoriteInnerContainerView.frame.size.height)
        
        noFavoriteGetStartedButton.layer.cornerRadius = 8
        noFavoriteGetStartedButton.layer.borderWidth = 1
        noFavoriteGetStartedButton.layer.borderColor = UIColor.mpRedColor().cgColor
        noFavoriteGetStartedButton.clipsToBounds = true
        
        noFavoriteContainerView.isHidden = true
        
        // Add the profile button. The image will be updated later
        profileButton = UIButton(type: .custom)
        profileButton?.frame = CGRect(x: 20, y: 4, width: 34, height: 34)
        profileButton?.layer.cornerRadius = (profileButton?.frame.size.width)! / 2.0
        profileButton?.clipsToBounds = true
        //profileButton?.setImage(UIImage.init(named: "EmptyProfileButton"), for: .normal)
        profileButton?.addTarget(self, action: #selector(self.profileButtonTouched), for: .touchUpInside)
        navView?.addSubview(profileButton!)
        
        navTitleLabel.alpha = 0
        
        // Add a notification handler that login has finished forcing the data to reload
        NotificationCenter.default.addObserver(self, selector: #selector(initializeData), name: Notification.Name("LoginFinished"), object: nil)
        
        // Add a notification handler that validate user is finished
        NotificationCenter.default.addObserver(self, selector: #selector(loadUserImage), name: Notification.Name("GetUserInfoFinished"), object: nil)
        
        // Add a notification handler for web deep linking
        NotificationCenter.default.addObserver(self, selector: #selector(showFollowingWebBrowser), name: Notification.Name("OpenFollowingWebBrowser"), object: nil)
        
        // Add a notification handler for career deep linking
        NotificationCenter.default.addObserver(self, selector: #selector(showCareerDeepLink), name: Notification.Name("OpenFollowingCareerDeepLink"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showTeamDeepLink), name: Notification.Name("OpenFollowingTeamDeepLink"), object: nil)
        
        // Add an observer for the app going into the background
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // Add an observer for the app returning to the foreground
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        self.initializeData()
        
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
        
        
        // Skip loading the user image and the table if coming back from these VC's since nothing can change
        if (webVC != nil) || (videoPlayerVC != nil)
        {
            return
        }
        
        //self.initializeData()
        
        // Get the user favorites if a real user
        let userId = kUserDefaults.object(forKey: kUserIdKey) as! String
        
        if (userId != kTestDriveUserId)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2)
            {
                self.getUserFavoriteTeamsFromDatabase()
            }
        }
        
        
        // Show the ad
        self.loadBannerViews()
        
        // Show the tool tips
        self.showToolTips()
        
        // Show the team video upload tooltip
        if ((kUserDefaults.string(forKey: kUserIdKey) != kEmptyGuid) && (kUserDefaults.string(forKey: kUserIdKey) != kTestDriveUserId))
        {
            let currentLaunchCount = kUserDefaults.object(forKey: kAppLaunchCountKey) as! Int
            
            if (currentLaunchCount > 5)
            {
                if (kUserDefaults.bool(forKey: kVideoUploadToolTipShownKey) == false)
                {
                    let userIsParentOrAthlete = MiscHelper.userCanEditCareer().canEdit
                    let userType = kUserDefaults.string(forKey: kUserTypeKey)
                    
                    // Show the tooltip for non-athletes or parents
                    if ((userIsParentOrAthlete == false) && (userType != "Athlete"))
                    {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
                        {
                            self.showTeamVideoUploadToolTip()
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (teamDetailVC != nil)
        {
            teamDetailVC = nil
        }
        
        if (roleSelectorVC != nil)
        {
            roleSelectorVC = nil
        }
        
        if (guestProfileVC != nil)
        {
            guestProfileVC = nil
        }
        
        if (athleteProfileVC != nil)
        {
            athleteProfileVC = nil
        }
        
        if (parentProfileVC != nil)
        {
            parentProfileVC = nil
        }
        
        if (coachProfileVC != nil)
        {
            coachProfileVC = nil
        }
        
        if (fanProfileVC != nil)
        {
            fanProfileVC = nil
        }
        
        if (adProfileVC != nil)
        {
            adProfileVC = nil
        }
        
        if (toolTipThreeVC != nil)
        {
            toolTipThreeVC = nil
        }
        
        if (toolTipNineVC != nil)
        {
            toolTipNineVC = nil
        }
        
        if (teamDetailVC != nil)
        {
            teamDetailVC = nil
        }
        
        if (athleteDetailVC != nil)
        {
            athleteDetailVC = nil
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
        return UIStatusBarStyle.darkContent
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
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("OpenFollowingWebBrowser"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("OpenFollowingCareerDeepLink"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("OpenFollowingTeamDeepLink"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("LoadUserImage"), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
}
