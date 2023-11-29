//
//  SubscriptionsViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/1/22.
//

import UIKit

class SubscriptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var subscriptionsTableView: UITableView!
    
    private var subscriptionsArray = [] as! Array<Dictionary<String,Any>>
    private var subscriptionTopicArray = [] as! Array<String>
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Get User Subscriptions
    
    private func getUserSubscriptions()
    {
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.getUserEligibleSubscriptionCategories { categories, error in
            
            if (error == nil)
            {
                print("Get User Eligible Subscription Categories Success")
                let sortedArray = categories!.sorted(by: {(int1, int2)  -> Bool in
                    return ((int1 as NSDictionary).value(forKey: "displayOrder") as! Int) < ((int2 as NSDictionary).value(forKey: "displayOrder") as! Int)
                  })
                
                // Now unravel the "subscriptionTopics" array to fill the subscriptionsArray used by the tableView. Some subscription categories may have multiple items in the subscriptionTopics array.

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
                
                // Populate the subscription topic dictionary to get the switch settings
                NewFeeds.getUserSubscriptionTopics { topics, error in
                    
                    // Hide the busy indicator
                    DispatchQueue.main.async
                    {
                        if (self.progressOverlay != nil)
                        {
                            self.progressOverlay.hide(animated: false)
                            self.progressOverlay = nil
                        }
                    }
                    
                    if (error == nil)
                    {
                        print("Get User Subscription Topics Success")
                        
                        for topic in topics!
                        {
                            let subscriptionTopicId = topic["subscriptionTopicId"] as! String
                            self.subscriptionTopicArray.append(subscriptionTopicId)
                        }
                        
                        self.subscriptionsTableView.reloadData()
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
                
                // Hide the busy indicator
                DispatchQueue.main.async
                {
                    if (self.progressOverlay != nil)
                    {
                        self.progressOverlay.hide(animated: false)
                        self.progressOverlay = nil
                    }
                }
            }
        }
    }
    
    // MARK: - Update User Subscriptions
    
    private func updateUserSubscription(topicId: String, enabled: Bool )
    {
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.updateUserSubscription(topicId: topicId, enabled: enabled) { error in
            
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                if (self.progressOverlay != nil)
                {
                    self.progressOverlay.hide(animated: false)
                    self.progressOverlay = nil
                }
            }
            
            if (error == nil)
            {
                print("Update User Subscription Success")
            }
            else
            {
                print("Update User Subscription Failed")
            }
        }
    }
    
    // MARK: - TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return subscriptionsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        // Adjust the cell height based upon the description text
        let subscription = subscriptionsArray[indexPath.row]
        let description = subscription["description"] as! String
        let textHeight = description.height(withConstrainedWidth: (kDeviceWidth - 85), font: UIFont.mpRegularFontWith(size: 13))
        return textHeight + 72
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 3.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 3))
            headerView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionsTableViewCell") as? SubscriptionsTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("SubscriptionsTableViewCell", owner: self, options: nil)
            cell = nib![0] as? SubscriptionsTableViewCell
        }
        
        cell?.selectionStyle = .none
        
        // Remove any switches and the info button in case the cell is recycled
        for view in cell!.contentView.subviews
        {
            if (view.tag >= 100)
            {
                view.removeFromSuperview()
            }
        }
        
        let subscription = subscriptionsArray[indexPath.row]
        let name = subscription["displayName"] as? String ?? ""
        let description = subscription["description"] as? String ?? ""
        let frequency = subscription["frequency"] as? String ?? ""
        
        cell?.nameLabel.text = name
        cell?.subtitleLabel.text = description
        cell?.frequencyLabel.text = String(format: "(%@)", frequency.lowercased())
        
        // Add a subscription switch
        let subscriptionSwitch = UISwitch(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        subscriptionSwitch.center = CGPoint(x: tableView.frame.size.width - (subscriptionSwitch.bounds.size.width / 2.0) - 16, y: 30.0)
        subscriptionSwitch.backgroundColor = .clear
        subscriptionSwitch.onTintColor = UIColor.mpRedColor()
        subscriptionSwitch.tag = 100 + indexPath.row
        subscriptionSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell?.contentView.addSubview(subscriptionSwitch)
        subscriptionSwitch.isOn = false
        
        // Determine if the switch should be on by looking for a match with the subscriptionTopicArray (filled in the API)
        let subscriptionTopicId = subscription["subscriptionTopicId"] as! String
        if subscriptionTopicArray.contains(subscriptionTopicId)
        {
            subscriptionSwitch.isOn = true
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Switch Changed Method
    
    @objc private func switchChanged(_ sender: UISwitch)
    {
        let index = sender.tag - 100
        let subscription = subscriptionsArray[index]
        let subscriptionTopicId = subscription["subscriptionTopicId"] as! String
        
        self.updateUserSubscription(topicId: subscriptionTopicId, enabled: sender.isOn)
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
        subscriptionsTableView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight))
        
        self.getUserSubscriptions()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        
        setNeedsStatusBarAppearanceUpdate()
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
