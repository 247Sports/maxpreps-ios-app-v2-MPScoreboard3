//
//  TeamNotificationEditorViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 7/29/22.
//

import UIKit

class TeamNotificationEditorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ThreeSegmentControlViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var genderSportLabel: UILabel!
    @IBOutlet weak var notificationTableView: UITableView!
    
    var favorite = [:] as Dictionary<String, Any>
    var valueChanged = false
    
    private var topSectionPushNotifications = [] as Array
    private var bottomSectionPushNotifications = [] as Array
    private var emailNotifications = [] as Array
    private var systemNotificationsEnabled = false
    private var progressOverlay: ProgressHUD!
    private var threeSegmentControl : ThreeSegmentControlView?
    
    // MARK: - Update Database Method
    
    private func updateDatabase(alert: Dictionary<String,Any>)
    {
        valueChanged = true
        
        let alertId = alert[kNewNotificationUserFavoriteTeamNotificationSettingIdKey] as! Int
        var isEnabled = false
        var isEmail = false
        
        if (threeSegmentControl?.selectedSegment == 0)
        {
            isEnabled = alert[kNewNotificationIsEnabledForAppKey] as! Bool
        }
        else
        {
            isEnabled = alert[kNewNotificationIsEnabledForEmailKey] as! Bool
            isEmail = true
        }
        
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.updateTeamNotificationSetting(alertId, switchValue: isEnabled, isEmail: isEmail) { (error) in
            
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
                print("Update Notification Success")
                
                //self.valueChanged = true
            }
            else
            {
                print("Update Notification Failed")
            }
        }
    }
    
    // MARK: - Switch Changed Method
    
    @objc private func switchChanged(_ sender: UISwitch)
    {
        var notification = [:] as! Dictionary<String,Any>
        
        if (threeSegmentControl?.selectedSegment == 0)
        {
            if (sender.tag >= 200)
            {
                let index = sender.tag - 200
                notification = bottomSectionPushNotifications[index] as! Dictionary<String, Any>
                notification.updateValue(NSNumber(booleanLiteral: sender.isOn), forKey: kNewNotificationIsEnabledForAppKey)
                bottomSectionPushNotifications[index] = notification
            }
            else
            {
                let index = sender.tag - 100
                notification = topSectionPushNotifications[index] as! Dictionary<String, Any>
                notification.updateValue(NSNumber(booleanLiteral: sender.isOn), forKey: kNewNotificationIsEnabledForAppKey)
                topSectionPushNotifications[index] = notification
            }
        }
        else
        {
            let index = sender.tag - 100
            notification = emailNotifications[index] as! Dictionary<String, Any>
            notification.updateValue(NSNumber(booleanLiteral: sender.isOn), forKey: kNewNotificationIsEnabledForEmailKey)
            emailNotifications[index] = notification
        }
        
        self.updateDatabase(alert: notification)

    }
    
    /*
    @objc private func masterEnableSwitchChanged(_ sender: UISwitch)
    {
        // Let the user know that the system notifications are disabled
        if (systemNotificationsEnabled == false)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["Cancel", "Settings"], title: "Notifications Disabled", message: "Enable notifications for MaxPreps in your device settings to receive the latest news and updates for your favorite teams.", lastItemCancelType: false) { (tag) in
                
                // This dims the table
                kUserDefaults.setValue(NSNumber(booleanLiteral: false), forKey: kNotificationMasterEnableKey)
                
                self.notificationTableView.reloadData()
                
                if (tag == 1)
                {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else
                    {
                        return
                    }

                    if UIApplication.shared.canOpenURL(settingsUrl)
                    {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            
                        })
                    }
                }
                
                return
            }
        }
        
        if (sender.isOn)
        {
            kUserDefaults.setValue(NSNumber(booleanLiteral: true), forKey: kNotificationMasterEnableKey)
        }
        else
        {
            kUserDefaults.setValue(NSNumber(booleanLiteral: false), forKey: kNotificationMasterEnableKey)
        }
        
        // This dims the table
        notificationTableView.reloadData()
    }
    */
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if (threeSegmentControl?.selectedSegment == 0)
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
        if (threeSegmentControl?.selectedSegment == 0)
        {
            if (section == 0)
            {
                return topSectionPushNotifications.count
            }
            else
            {
                return bottomSectionPushNotifications.count
            }
        }
        else
        {
            return emailNotifications.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if (threeSegmentControl?.selectedSegment == 0)
        {
            return 56.0
        }
        else
        {
            return 3.0 // This truncates the lower part of the header
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (threeSegmentControl?.selectedSegment == 0)
        {
            if (section == 0)
            {
                return 10.0
            }
        }
        
        return 34.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (threeSegmentControl?.selectedSegment == 0)
        {
            if (section == 0)
            {
                let headerView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 56))
                headerView.backgroundColor = UIColor.mpWhiteColor()
                
                let horizLine = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 3))
                horizLine.backgroundColor = UIColor.mpHeaderBackgroundColor()
                headerView.addSubview(horizLine)
                
                let sectionLabel = UILabel(frame: CGRect(x: 16, y: 24, width: kDeviceWidth - 32, height: 20))
                sectionLabel.text = "Games"
                sectionLabel.font = UIFont.mpBoldFontWith(size: 16)
                sectionLabel.textColor = UIColor.mpBlackColor()
                headerView.addSubview(sectionLabel)
                
                return headerView
            }
            else
            {
                let headerView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 56))
                headerView.backgroundColor = UIColor.mpWhiteColor()
                
                let horizLine = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 4))
                horizLine.backgroundColor = UIColor.mpHeaderBackgroundColor()
                headerView.addSubview(horizLine)
                
                let sectionLabel = UILabel(frame: CGRect(x: 16, y: 24, width: kDeviceWidth - 32, height: 20))
                sectionLabel.text = "News and Updates"
                sectionLabel.font = UIFont.mpBoldFontWith(size: 16)
                sectionLabel.textColor = UIColor.mpBlackColor()
                headerView.addSubview(sectionLabel)
                
                return headerView
            }
        }
        else
        {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 3))
            headerView.backgroundColor = UIColor.mpHeaderBackgroundColor()
            
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (indexPath.section == 0)
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            
            if (cell == nil)
            {
                cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
            }
            cell?.selectionStyle = .none
            cell?.contentView.backgroundColor = UIColor.mpWhiteColor()
            cell?.textLabel?.font = UIFont.mpRegularFontWith(size: 16)
            cell?.textLabel?.textColor = UIColor.mpBlackColor()
            
            // Remove any switches and the info button in case the cell is recycled
            for view in cell!.contentView.subviews
            {
                if (view.tag >= 100)
                {
                    view.removeFromSuperview()
                }
            }
            var alert = [:] as! Dictionary<String, Any>
            
            if (threeSegmentControl?.selectedSegment == 0)
            {
                alert = topSectionPushNotifications[indexPath.row] as! Dictionary<String, Any>
            }
            else
            {
                alert = emailNotifications[indexPath.row] as! Dictionary<String, Any>
            }
            
            var title = alert[kNewNotificationNameKey] as! String
            
            if (title == "Game Scorer Status")
            {
                title = "Game Reporter Status"
            }
            
            cell?.textLabel?.text = title
            
            // Add an info button next to "Game Reporter Status"
            if (title == "Game Reporter Status")
            {
                let infoButton = UIButton(type: .infoDark)
                infoButton.tintColor = UIColor.mpRedColor()
                infoButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
                infoButton.center = CGPoint(x: 205.0, y: 28.0)
                infoButton.tag = 200
                infoButton.addTarget(self, action: #selector(infoButtonTouched), for: .touchUpInside)
                cell?.contentView.addSubview(infoButton)
            }
            
            // Add a notification switch
            let notificationSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            notificationSwitch.center = CGPoint(x: tableView.frame.size.width - (notificationSwitch.bounds.size.width / 2.0) - 16, y: 28.0)
            notificationSwitch.backgroundColor = .clear
            notificationSwitch.onTintColor = UIColor.mpRedColor()
            notificationSwitch.tag = 100 + indexPath.row
            notificationSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
            cell?.contentView.addSubview(notificationSwitch)
            
            if (threeSegmentControl?.selectedSegment == 0)
            {
                let switchEnabled = alert[kNewNotificationIsEnabledForAppKey] as! Bool
                if (switchEnabled == true)
                {
                    notificationSwitch.isOn = true
                }
                
                // Master switch
                let switchStatus = (kUserDefaults.value(forKey: kNotificationMasterEnableKey)) as! Bool
                if ((switchStatus == false) || (self.systemNotificationsEnabled == false))
                {
                    notificationSwitch.isOn = false
                    
                    let obscuringView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 56.0))
                    obscuringView.tag = 400 + indexPath.row
                    obscuringView.backgroundColor = UIColor(white: 1, alpha: 0.66)
                    cell?.contentView.addSubview(obscuringView)
                }
            }
            else
            {
                let switchEnabled = alert[kNewNotificationIsEnabledForEmailKey] as! Bool
                if (switchEnabled == true)
                {
                    notificationSwitch.isOn = true
                }
            }
            
            /*
            // Disable the "Rankings" switch if not Varsity, set the valueChanged flag to YES
            let teamLevel = self.favorite[kNewLevelKey] as! String
            
            if ((teamLevel != "Varsity") && (title == "Rankings"))
            {
                notificationSwitch.isOn = false
                notificationSwitch.isEnabled = false
                cell?.textLabel?.alpha = 0.4
                cell?.textLabel?.text = "Rankings (Varsity Only)"
                self.valueChanged = true
            }
            */
            return cell!
        }
        else
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cell2")
            
            if (cell == nil)
            {
                cell = UITableViewCell(style: .default, reuseIdentifier: "Cell2")
            }
            cell?.selectionStyle = .none
            cell?.contentView.backgroundColor = UIColor.mpWhiteColor()
            cell?.textLabel?.font = UIFont.mpRegularFontWith(size: 16)
            cell?.textLabel?.textColor = UIColor.mpBlackColor()
            
            // Remove any switches and the info button in case the cell is recycled
            for view in cell!.contentView.subviews
            {
                if (view.tag >= 200)
                {
                    view.removeFromSuperview()
                }
            }
            
            let alert = bottomSectionPushNotifications[indexPath.row] as! Dictionary<String, Any>
            
            let title = alert[kNewNotificationNameKey] as! String
            cell?.textLabel?.text = title
            
            // Add a notification switch
            let notificationSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            notificationSwitch.center = CGPoint(x: tableView.frame.size.width - (notificationSwitch.bounds.size.width / 2.0) - 16, y: 28.0)
            notificationSwitch.backgroundColor = .clear
            notificationSwitch.onTintColor = UIColor.mpRedColor()
            notificationSwitch.tag = 200 + indexPath.row
            notificationSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
            cell?.contentView.addSubview(notificationSwitch)
 
            
            let switchEnabled = alert[kNewNotificationIsEnabledForAppKey] as! Bool
            if (switchEnabled == true)
            {
                notificationSwitch.isOn = true
            }
            
            // Master switch
            let switchStatus = (kUserDefaults.value(forKey: kNotificationMasterEnableKey)) as! Bool
            if ((switchStatus == false) || (self.systemNotificationsEnabled == false))
            {
                notificationSwitch.isOn = false
                
                let obscuringView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 56.0))
                obscuringView.tag = 400 + indexPath.row
                obscuringView.backgroundColor = UIColor(white: 1, alpha: 0.66)
                cell?.contentView.addSubview(obscuringView)
            }

            
            /*
            // Disable the "Rankings" switch if not Varsity, set the valueChanged flag to YES
            let teamLevel = self.favorite[kNewLevelKey] as! String
            
            if ((teamLevel != "Varsity") && (title == "Rankings"))
            {
                notificationSwitch.isOn = false
                notificationSwitch.isEnabled = false
                cell?.textLabel?.alpha = 0.4
                cell?.textLabel?.text = "Rankings (Varsity Only)"
                self.valueChanged = true
            }
            */
            return cell!
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Return from Background Notification
    
    @objc private func returningFromBackground()
    {
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
            
            // Reload the table
            DispatchQueue.main.async
            {
                self.notificationTableView.reloadData()
            }
        })
    }
    
    // MARK: - ThreeSegmentControl Delegate
    
    func segmentChanged()
    {
        notificationTableView.reloadData()
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func infoButtonTouched()
    {
        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Game Reporter Status", message: "This will send you a notification when the game has a Reporter, when the Reporter has checked-in at the game, or if the Reporter cancels.", lastItemCancelType: false) { (tag) in
            
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
        
        // Add the ThreeSegmentControlView to the navView
        threeSegmentControl = ThreeSegmentControlView(frame: CGRect(x: 0, y: navView.frame.size.height - 40, width: navView.frame.size.width, height: 40), buttonOneTitle: "Push Notifications", buttonTwoTitle: "Email Notifications", buttonThreeTitle: "", lightTheme: true)
        threeSegmentControl?.delegate = self
        navView.addSubview(threeSegmentControl!)
        
        notificationTableView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height)
        notificationTableView.contentInsetAdjustmentBehavior = .never
        
        let allNotifications = self.favorite[kNewNotificationSettingsKey] as! Array<Dictionary<String,Any>>
        
        // Iterate through the notifications to split them into three arrays
        for notification in allNotifications
        {
            let name = notification["name"] as! String
            let shortName = notification["shortName"] as! String
            print(name + ", " + shortName)
            
            // Split the push notifications into two arrays based on the short name
            // RNK, TS, TM
            if ((shortName == "RNK") || (shortName == "TS") || (shortName == "TM"))
            {
                bottomSectionPushNotifications.append(notification)
            }
            else
            {
                topSectionPushNotifications.append(notification)
            }
            
            let isVisibleForEmail = notification["isVisibleForEmail"] as! Bool
            if (isVisibleForEmail == true)
            {
                emailNotifications.append(notification)
            }
        }
        /*
         0 : 2 elements
               - key : isVisibleForEmail
               - value : 1
             ▿ 1 : 2 elements
               - key : sortOrder
               - value : 0
             ▿ 2 : 2 elements
               - key : isEnabledForWeb
               - value : 0
             ▿ 3 : 2 elements
               - key : shortName
               - value : FS
             ▿ 4 : 2 elements
               - key : userFavoriteTeamId
               - value : 17169150
             ▿ 5 : 2 elements
               - key : isEnabledForSms
               - value : 0
             ▿ 6 : 2 elements
               - key : isEnabledForEmail
               - value : 0
             ▿ 7 : 2 elements
               - key : userFavoriteTeamNotificationSettingId
               - value : 125371440
             ▿ 8 : 2 elements
               - key : name
               - value : Final Score
             ▿ 9 : 2 elements
               - key : isEnabledForApp
               - value : 1
         */
        
        let schoolName = self.favorite[kNewSchoolNameKey] as! String
        let gender = self.favorite[kNewGenderKey] as! String
        let sport = self.favorite[kNewSportKey] as! String
        let level = self.favorite[kNewLevelKey] as! String
        
        schoolNameLabel.text = schoolName
        genderSportLabel.text = MiscHelper.genderSportLevelFrom(gender: gender, sport: sport, level: level)
        
        // Tracking
        let trackingGuid = NSUUID().uuidString
        TrackingManager.trackState(featureName: "notifications-manage", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
        
        NotificationCenter.default.addObserver(self, selector: #selector(returningFromBackground), name: Notification.Name(UIApplication.willEnterForegroundNotification.rawValue), object: nil)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        
        setNeedsStatusBarAppearanceUpdate()
        
        // This is added to reset the background when returning from the VCs
        kAppKeyWindow.rootViewController!.view.backgroundColor = UIColor.mpWhiteColor()
        
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings(completionHandler: { settings in
          
            if (settings.authorizationStatus == .authorized)
            {
                self.systemNotificationsEnabled = true
            }
            else
            {
                self.systemNotificationsEnabled = false
                
                MiscHelper.showAlert(in: self, withActionNames: ["Cancel", "Settings"], title: "Notifications Disabled", message: "Enable notifications for MaxPreps in your device settings to receive the latest news and updates for your favorite teams.", lastItemCancelType: false) { (tag) in
                    
                    // This dims the table
                    //kUserDefaults.setValue(NSNumber(booleanLiteral: false), forKey: kNotificationMasterEnableKey)
                    
                    //self.notificationTableView.reloadData()
                    
                    if (tag == 1)
                    {
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else
                        {
                            return
                        }

                        if UIApplication.shared.canOpenURL(settingsUrl)
                        {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                
                            })
                        }
                    }
                }
            }
            
            DispatchQueue.main.async
            {
                self.notificationTableView.reloadData()
            }
            
        })
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
        NotificationCenter.default.removeObserver(self, name: Notification.Name(UIApplication.willEnterForegroundNotification.rawValue), object: nil)
    }
}
