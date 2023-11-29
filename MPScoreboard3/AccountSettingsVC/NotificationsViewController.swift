//
//  NotificationsViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/15/22.
//

import UIKit

class NotificationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var favoritesTableView: UITableView!
    
    var ftag = ""
    
    private var systemNotificationsEnabled = false
    private var favoriteTeamsArray = [] as Array
    private var favoriteAthletesArray = [] as Array
    private var subscriptionsArray = [] as! Array<Dictionary<String,Any>>
    private var subscriptionTopicArray = [] as! Array<String>
    private var subscriptionsSubtitleLabel: UILabel!
    
    private var teamNotificationEditorVC : TeamNotificationEditorViewController?
    private var careerNotificationEditorVC : CareerNotificationEditorViewController?
    private var subscriptionsVC: SubscriptionsViewController!
    private var webVC: WebViewController!
    
    // MARK: - Get User Favorites
    
    private func getUserFavoriteTeamsFromDatabase()
    {
        // Airship gets updated whenever favorites are downloaded
        
        NewFeeds.getUserFavoriteTeams(completionHandler: { error in
        
            // Filter out teams that don't have any notifications
            let unfilteredFavoriteTeams = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)!
            
            self.favoriteTeamsArray.removeAll()
            
            for item in unfilteredFavoriteTeams
            {
                let favorite = item as! Dictionary<String,Any>
                let notifications = favorite[kNewNotificationSettingsKey] as! Array<Dictionary<String,Any>>
                
                if (notifications.count > 0)
                {
                    self.favoriteTeamsArray.append(favorite)
                }
            }
            
            // Get the favorite athletes
            NewFeeds.getUserFavoriteAthletes { error in
                
                self.favoriteAthletesArray = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)!
                
                self.favoritesTableView.reloadData()
            }

        })
    }
    
    // MARK: - Get Subscriptions Label Count
    
    private func getSubscriptionsCount()
    {
        subscriptionsArray.removeAll()
        subscriptionTopicArray.removeAll()
        
        // Need to call two APIs to get all of the data
        NewFeeds.getUserEligibleSubscriptionCategories { categories, error in
            
            if (error == nil)
            {
                print("Get User Eligible Subscription Categories Success")
                let sortedArray = categories!.sorted(by: {(int1, int2)  -> Bool in
                    return ((int1 as NSDictionary).value(forKey: "displayOrder") as! Int) < ((int2 as NSDictionary).value(forKey: "displayOrder") as! Int)
                  })
                
                // Now unravel the "subscriptionTopics" array to fill the subscriptionsArray. Some subscription categories may have multiple items in the subscriptionTopics array.

                for item in sortedArray
                {
                    let subscriptionTopics = item["subscriptionTopics"] as! Array<Dictionary<String,Any>>
                    //let description = item["description"] as! String
                    let frequency = item["frequency"] as! String
                    
                    for topic in subscriptionTopics
                    {
                        var modifiedTopic = topic
                        //modifiedTopic["description"] = description
                        modifiedTopic["frequency"] = frequency
                        self.subscriptionsArray.append(modifiedTopic)
                    }
                }
                
                // Populate the subscription topic array to get the switch settings
                NewFeeds.getUserSubscriptionTopics { topics, error in
                    
                    if (error == nil)
                    {
                        print("Get User Subscription Topics Success")
                        
                        for topic in topics!
                        {
                            let subscriptionTopicId = topic["subscriptionTopicId"] as! String
                            
                            // Check to see it the topicId exists in the subscriptionArray before adding it.
                            var matchFound = false
                            for subscriptionCategory in self.subscriptionsArray
                            {
                                let topicId = subscriptionCategory["subscriptionTopicId"] as! String
                                if (topicId == subscriptionTopicId)
                                {
                                    matchFound = true
                                    break
                                }
                            }
                            
                            if (matchFound == true)
                            {
                                self.subscriptionTopicArray.append(subscriptionTopicId)
                            }
                        }
                        
                        self.subscriptionsSubtitleLabel.text = String(format: "%d of %d active", self.subscriptionTopicArray.count, self.subscriptionsArray.count)
                    }
                    else
                    {
                        print("Get User Subscriptions Topics Failed")
                    }
                }
            }
            else
            {
                print("Get User Eligible Subscription Categories Failed")
            }
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
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 306.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 34.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let compositeHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 306))
        compositeHeaderView.backgroundColor = UIColor.mpWhiteColor()
        
        // Top Group
        let headerView1 = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 118))
        headerView1.backgroundColor = UIColor.mpWhiteColor()
        
        let horizLine1 = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 3))
        horizLine1.backgroundColor = UIColor.mpHeaderBackgroundColor()
        headerView1.addSubview(horizLine1)
        
        let sectionLabel1 = UILabel(frame: CGRect(x: 16, y: 20, width: kDeviceWidth - 32, height: 20))
        sectionLabel1.text = "General"
        sectionLabel1.font = UIFont.mpBoldFontWith(size: 16)
        sectionLabel1.textColor = UIColor.mpBlackColor()
        headerView1.addSubview(sectionLabel1)
        
        let titleLabel1 = UILabel(frame: CGRect(x: 16, y: 56, width: kDeviceWidth - 32, height: 20))
        titleLabel1.text = "Subscriptions"
        titleLabel1.font = UIFont.mpRegularFontWith(size: 16)
        titleLabel1.textColor = UIColor.mpBlackColor()
        headerView1.addSubview(titleLabel1)
        
        subscriptionsSubtitleLabel = UILabel(frame: CGRect(x: 16, y: 80, width: kDeviceWidth - 32, height: 16))
        subscriptionsSubtitleLabel.font = UIFont.mpRegularFontWith(size: 13)
        subscriptionsSubtitleLabel.textColor = UIColor.mpGrayColor()
        headerView1.addSubview(subscriptionsSubtitleLabel)
        
        // Load the text here in case the cell was recycled
        if (subscriptionsArray.count > 0)
        {
            subscriptionsSubtitleLabel.text = String(format: "%d of %d active", subscriptionTopicArray.count, subscriptionsArray.count)
        }
        
        let chevron1 = UIImageView(frame: CGRect(x: kDeviceWidth - 29, y: 58, width: 9, height: 14))
        chevron1.image = UIImage(named: "ChevronDark")
        headerView1.addSubview(chevron1)
        
        let button1 = UIButton(type: .system)
        button1.frame = CGRect(x: 0, y: 0, width: kDeviceWidth, height: 104)
        button1.addTarget(self, action: #selector(subscriptionsButtonTouched(_ :)), for: .touchUpInside)
        headerView1.addSubview(button1)
        
        // Middle Group
        let headerView2 = UIView(frame: CGRect(x: 0, y: 118, width: kDeviceWidth, height: 122))
        headerView2.backgroundColor = UIColor.mpWhiteColor()
        
        let horizLine2 = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 4))
        horizLine2.backgroundColor = UIColor.mpHeaderBackgroundColor()
        headerView2.addSubview(horizLine2)
        
        let sectionLabel2 = UILabel(frame: CGRect(x: 16, y: 20, width: kDeviceWidth - 32, height: 20))
        sectionLabel2.text = "Following"
        sectionLabel2.font = UIFont.mpBoldFontWith(size: 16)
        sectionLabel2.textColor = UIColor.mpBlackColor()
        headerView2.addSubview(sectionLabel2)
        
        let titleLabel2 = UILabel(frame: CGRect(x: 16, y: 56, width: kDeviceWidth - 32, height: 20))
        titleLabel2.text = "Athletes"
        titleLabel2.font = UIFont.mpRegularFontWith(size: 16)
        titleLabel2.textColor = UIColor.mpBlackColor()
        headerView2.addSubview(titleLabel2)
        
        let subtitleLabel2 = UILabel(frame: CGRect(x: 16, y: 80, width: kDeviceWidth - 32, height: 16))
        subtitleLabel2.font = UIFont.mpRegularFontWith(size: 13)
        subtitleLabel2.textColor = UIColor.mpGrayColor()
        //subtitleLabel2.numberOfLines = 0
        //subtitleLabel2.sizeToFit()
        headerView2.addSubview(subtitleLabel2)
        
        let chevron2 = UIImageView(frame: CGRect(x: kDeviceWidth - 29, y: 58, width: 9, height: 14))
        chevron2.image = UIImage(named: "ChevronDark")
        headerView2.addSubview(chevron2)
        chevron2.isHidden = true
        
        let button2 = UIButton(type: .system)
        button2.frame = CGRect(x: 0, y: 0, width: kDeviceWidth, height: 122)
        button2.addTarget(self, action: #selector(athleteButtonTouched(_ :)), for: .touchUpInside)
        headerView2.addSubview(button2)
        button2.isEnabled = false
        
        if (favoriteAthletesArray.count > 0)
        {
            // Show the chevron and enable the button
            chevron2.isHidden = false
            button2.isEnabled = true
            
            // Get the notification count for each athlete
            var enabledCount = 0
            
            for item in favoriteAthletesArray
            {
                let favorite = item as! Dictionary<String,Any>
                let notifications = favorite[kCareerProfileNotificationSettingsKey] as? Array<Dictionary<String,Any>> ?? []
                
                for notification in notifications
                {
                    let pushEnabled = notification[kNewNotificationIsEnabledForAppKey] as! Bool
                    
                    if (pushEnabled == true)
                    {
                        enabledCount += 1
                    }
                }
            }
            
            if (systemNotificationsEnabled == true)
            {
                if (favoriteAthletesArray.count > 1)
                {
                    subtitleLabel2.text = String(format: "%d favorites, %d with notifications", favoriteAthletesArray.count, enabledCount)
                }
                else
                {
                    subtitleLabel2.text = String(format: "%d favorite, %d with notifications", favoriteAthletesArray.count, enabledCount)
                }
            }
            else
            {
                if (favoriteAthletesArray.count > 1)
                {
                    subtitleLabel2.text = String(format: "%d favorites, 0 with notifications", favoriteAthletesArray.count)
                }
                else
                {
                    subtitleLabel2.text = String(format: "%d favorite, 0 with notifications", favoriteAthletesArray.count)
                }
            }
        }
        else
        {
            subtitleLabel2.text = "Follow athletes to get latest updates and highlights"
        }
        
        // Bottom Group
        let headerView3 = UIView(frame: CGRect(x: 0, y: 236, width: kDeviceWidth, height: 70))
        headerView3.backgroundColor = UIColor.mpWhiteColor()
        
        let horizLine3 = UIView(frame: CGRect(x: 16, y: 0, width: kDeviceWidth - 32, height: 1))
        horizLine3.backgroundColor = UIColor.mpHeaderBackgroundColor()
        headerView3.addSubview(horizLine3)
        
        let titleLabel3 = UILabel(frame: CGRect(x: 16, y: 16, width: kDeviceWidth - 32, height: 20))
        titleLabel3.text = "Teams"
        titleLabel3.font = UIFont.mpRegularFontWith(size: 16)
        titleLabel3.textColor = UIColor.mpBlackColor()
        headerView3.addSubview(titleLabel3)
        
        let subtitleLabel3 = UILabel(frame: CGRect(x: 16, y: 40, width: kDeviceWidth - 32, height: 40))
        if (favoriteTeamsArray.count > 0)
        {
            subtitleLabel3.text = "Latest updates, highlights, game alerts, and more"
        }
        else
        {
            subtitleLabel3.text = "Follow teams to get latest updates, game alerts, and more"
        }
        subtitleLabel3.font = UIFont.mpRegularFontWith(size: 13)
        subtitleLabel3.textColor = UIColor.mpGrayColor()
        subtitleLabel3.numberOfLines = 0
        subtitleLabel3.sizeToFit()
        headerView3.addSubview(subtitleLabel3)
            
        compositeHeaderView.addSubview(headerView1)
        compositeHeaderView.addSubview(headerView2)
        compositeHeaderView.addSubview(headerView3)
        
        return compositeHeaderView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "NotificationSchoolTableViewCell") as? NotificationSchoolTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("NotificationSchoolTableViewCell", owner: self, options: nil)
            cell = nib![0] as? NotificationSchoolTableViewCell
        }
        
        cell?.selectionStyle = .none
        
        let favorite = favoriteTeamsArray[indexPath.row] as! Dictionary<String, Any>
        let name = favorite[kNewSchoolNameKey] as! String
        let gender = favorite[kNewGenderKey] as! String
        let sport = favorite[kNewSportKey] as! String
        let level = favorite[kNewLevelKey] as!String
        //let season = favorite[kNewSeasonKey] as! String
        
        cell?.schoolNameLabel.text = name
        cell?.sportLabel.text = MiscHelper.genderSportLevelFrom(gender: gender, sport: sport, level: level)
        //cell?.sportLabel.text = String(format: "%@ %@ %@ (%@)", gender, level, sport, season)
        
        let schoolInitial = name.first?.uppercased()
        cell?.initialLabel.text = schoolInitial
        let colorString = favorite[kNewSchoolColor1Key] as! String
        cell?.initialLabel.textColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
        
        cell?.initialLabel.isHidden = false
        cell?.mascotImageView.image = nil
        
        let mascotUrl = favorite[kNewSchoolMascotUrlKey] as? String ?? ""
        
        if (mascotUrl.count > 0)
        {
            // Get the data and make an image
            let url = URL(string: mascotUrl)
            
            SDWebImageManager.shared().downloadImage(with: url!, progress: { receivedSize, expectedSize in
                
            }, completed: { image, error, cacheType, finished, imageUrl in
                
                if (image != nil)
                {
                    cell?.initialLabel.isHidden = true
                    
                    // Render the mascot using this helper
                    MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (cell?.mascotImageView)!)
                }
            })
        }
        
        // Get the notification count for each cell
        let notifications = favorite[kNewNotificationSettingsKey] as! Array<Dictionary<String,Any>>
        var enabledCount = 0
        
        for notification in notifications
        {
            let pushEnabled = notification[kNewNotificationIsEnabledForAppKey] as! Bool
            
            if (pushEnabled == true)
            {
                enabledCount += 1
            }
        }
        if (systemNotificationsEnabled == true)
        {
            cell?.notificationCountLabel.text = String(format: "%d/%d", enabledCount, notifications.count)
        }
        else
        {
            cell?.notificationCountLabel.text = String(format: "0/%d", notifications.count)
        }
            
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (favoriteTeamsArray.count > 0)
        {
            let favorite = favoriteTeamsArray[indexPath.row] as! Dictionary<String, Any>
            
            // Open the Notification Editor
            teamNotificationEditorVC = TeamNotificationEditorViewController(nibName: "TeamNotificationEditorViewController", bundle: nil)
            teamNotificationEditorVC?.favorite = favorite
            self.navigationController?.pushViewController(teamNotificationEditorVC!, animated: true)
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func subscriptionsButtonTouched(_ sender: UIButton)
    {
        subscriptionsVC = SubscriptionsViewController(nibName: "SubscriptionsViewController", bundle: nil)
        self.navigationController?.pushViewController(subscriptionsVC, animated: true)
    }
    
    @objc private func athleteButtonTouched(_ sender: UIButton)
    {
        //MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Coming Soon", message: "This opens the athlete notification editor.", lastItemCancelType: false) { tag in
            
        //}
        
        if (favoriteAthletesArray.count > 0)
        {            
            // Open the Career Notification Editor
            careerNotificationEditorVC = CareerNotificationEditorViewController(nibName: "CareerNotificationEditorViewController", bundle: nil)
            self.navigationController?.pushViewController(careerNotificationEditorVC!, animated: true)
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        favoritesTableView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height)
        favoritesTableView.contentInsetAdjustmentBehavior = .never
        
        // Tracking
        let trackingGuid = NSUUID().uuidString
        
        // Build the tracking context data object
        var cData = kEmptyTrackingContextData
        cData[kTrackingFtagKey] = self.ftag
        
        TrackingManager.trackState(featureName: "notifications-home", trackingGuid: trackingGuid, cData: cData)
    
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        
        setNeedsStatusBarAppearanceUpdate()
        
        // This is added to reset the background when returning from the VCs
        kAppKeyWindow.rootViewController!.view.backgroundColor = UIColor.mpWhiteColor()
        
        favoriteAthletesArray = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)!
        
        // Filter out teams that don't have any notifications
        let unfilteredFavoriteTeams = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)!
        
        favoriteTeamsArray.removeAll()
        
        for item in unfilteredFavoriteTeams
        {
            let favorite = item as! Dictionary<String,Any>
            let notifications = favorite[kNewNotificationSettingsKey] as! Array<Dictionary<String,Any>>
            
            if (notifications.count > 0)
            {
                favoriteTeamsArray.append(favorite)
            }
        }
        
        // Update the table
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings(completionHandler: { settings in
          
            if (settings.authorizationStatus == .authorized)
            {
                self.systemNotificationsEnabled = true
            }
            else
            {
                self.systemNotificationsEnabled = false
            }
            
            DispatchQueue.main.async
            {
                self.favoritesTableView.reloadData()
            }
            
        })
        
        // Update the notifications DB if something changed in the notification editor
        if let value = teamNotificationEditorVC?.valueChanged
        {
            if (value == true)
            {
                self.getUserFavoriteTeamsFromDatabase()
            }
        }
        
        if let value = careerNotificationEditorVC?.valueChanged
        {
            if (value == true)
            {
                self.getUserFavoriteTeamsFromDatabase()
            }
        }
        
        self.getSubscriptionsCount()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (teamNotificationEditorVC != nil)
        {
            teamNotificationEditorVC = nil
        }
        
        if (careerNotificationEditorVC != nil)
        {
            careerNotificationEditorVC = nil
        }
        
        if (subscriptionsVC != nil)
        {
            subscriptionsVC = nil
        }
        
        if (webVC != nil)
        {
            webVC = nil
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

}
