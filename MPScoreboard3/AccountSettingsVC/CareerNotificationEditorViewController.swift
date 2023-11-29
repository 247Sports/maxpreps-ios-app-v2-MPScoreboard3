//
//  CareerNotificationEditorViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/22/23.
//

import UIKit

class CareerNotificationEditorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var notificationTableView: UITableView!
    
    var valueChanged = false
    
    private var favoriteAthletesArray = [] as Array
    private var systemNotificationsEnabled = false
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Update Database Method
    
    private func updateDatabase(careerId: String, isEnabled: Bool)
    {
        valueChanged = true

        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.updateCareerNotificationSetting(careerId: careerId, switchValue: isEnabled) { (error) in
            
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
            }
            else
            {
                print("Update Notification Failed")
            }
        }
    }
    
    // MARK: - Switch Changed Methods
    
    @objc private func switchChanged(_ sender: UISwitch)
    {
        let index = sender.tag - 100
        let favoriteAthlete = favoriteAthletesArray[index] as! Dictionary<String, Any>
        let careerId = favoriteAthlete[kCareerProfileIdKey] as! String
        let notifications = favoriteAthlete[kCareerProfileNotificationSettingsKey] as? Array<Dictionary<String,Any>> ?? []
        
        // This is added while the API is in development so it won't crash
        if (notifications.count > 0)
        {
            self.updateDatabase(careerId: careerId, isEnabled: sender.isOn)
        }
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return favoriteAthletesArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 34.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 10))
        headerView.backgroundColor = UIColor.mpWhiteColor()
        
        let horizLine = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 3))
        horizLine.backgroundColor = UIColor.mpHeaderBackgroundColor()
        headerView.addSubview(horizLine)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCareerTableViewCell") as? NotificationCareerTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("NotificationCareerTableViewCell", owner: self, options: nil)
            cell = nib![0] as? NotificationCareerTableViewCell
        }
        
        cell?.selectionStyle = .none
        cell?.teamMascotImageView.layer.cornerRadius = 0
        cell?.teamMascotImageView.clipsToBounds = true
        
        // Remove any switches and the info button in case the cell is recycled
        for view in cell!.contentView.subviews
        {
            if (view.tag >= 100)
            {
                view.removeFromSuperview()
            }
        }

        // Favorite athletes section
        let favoriteAthlete = favoriteAthletesArray[indexPath.row] as! Dictionary<String, Any>

        let firstName = favoriteAthlete[kCareerProfileFirstNameKey] as! String
        let lastName = favoriteAthlete[kCareerProfileLastNameKey] as! String
        let schoolName = favoriteAthlete[kCareerProfileSchoolNameKey] as! String
        let athletePhotoUrlString = favoriteAthlete[kCareerProfilePhotoUrlKey] as! String
        
        cell?.titleLabel.text = firstName + " " + lastName
        cell?.subtitleLabel.text = schoolName
        
        // Add a notification switch
        let notificationSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        notificationSwitch.center = CGPoint(x: tableView.frame.size.width - (notificationSwitch.bounds.size.width / 2.0) - 16, y: 28.0)
        notificationSwitch.backgroundColor = .clear
        notificationSwitch.onTintColor = UIColor.mpRedColor()
        notificationSwitch.tag = 100 + indexPath.row
        notificationSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell?.contentView.addSubview(notificationSwitch)
        
        let notifications = favoriteAthlete[kCareerProfileNotificationSettingsKey] as? Array<Dictionary<String,Any>> ?? []
        
        if (notifications.count > 0)
        {
            let notification = notifications[0]
            let switchEnabled = notification[kNewNotificationIsEnabledForAppKey] as! Bool
            
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
                obscuringView.tag = 200 + indexPath.row
                obscuringView.backgroundColor = UIColor(white: 1, alpha: 0.66)
                cell?.contentView.addSubview(obscuringView)
            }
        }
        
        cell?.teamFirstLetterLabel.isHidden = true
        cell?.teamMascotImageView.layer.cornerRadius = (cell?.teamMascotImageView.frame.size.width)! / 2.0
        
        cell?.teamMascotImageView.image = UIImage(named: "Avatar")
        
        if (athletePhotoUrlString.count > 0)
        {
            let url = URL(string: athletePhotoUrlString)
            
            SDWebImageManager.shared().downloadImage(with: url!, progress: { receivedSize, expectedSize in
                
            }, completed: { image, error, cacheType, finished, imageUrl in
                
                if (image != nil)
                {
                    cell?.teamMascotImageView.image = image
                }
            })
        }
        
        return cell!
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
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        notificationTableView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height)
        notificationTableView.contentInsetAdjustmentBehavior = .never
        
        favoriteAthletesArray = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)!
        
        // Tracking
        let trackingGuid = NSUUID().uuidString
        TrackingManager.trackState(featureName: "notifications-manage", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(returningFromBackground), name: Notification.Name(UIApplication.willEnterForegroundNotification.rawValue), object: nil)
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
                
                MiscHelper.showAlert(in: self, withActionNames: ["Cancel", "Settings"], title: "Notifications Disabled", message: "Enable notifications for MaxPreps in your device settings to receive the updates for your favorite athletes.", lastItemCancelType: false) { (tag) in
                    
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
