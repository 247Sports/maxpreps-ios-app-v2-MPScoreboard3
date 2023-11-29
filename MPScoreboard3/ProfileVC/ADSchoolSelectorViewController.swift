//
//  ADSchoolSelectorViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 7/19/23.
//

import UIKit

class ADSchoolSelectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var schoolsTableView: UITableView!
    
    var adTeams = [] as Array<Dictionary<String,Any>>
    var adSchools = [] as Array<Dictionary<String,Any>>
    
    private var adTeamsVC: NewADTeamsViewController!
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return adSchools.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 154.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 20.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 20.0))
        footerView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "NewADSchoolTableViewCell") as? NewADSchoolTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("NewADSchoolTableViewCell", owner: self, options: nil)
            cell = nib![0] as? NewADSchoolTableViewCell
        }
        
        cell?.selectionStyle = .none
        
        cell?.teamButton.tag = 100 + indexPath.row
        cell?.teamButton.addTarget(self, action: #selector(teamButtonTouched(_:)), for: .touchUpInside)
        
        let schoolData = adSchools[indexPath.row]
        cell?.loadData(schoolData)

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func teamButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let selectedSchool = adSchools[index]
        
        // Show the ADTeamsVC
        if (adTeamsVC != nil)
        {
            adTeamsVC = nil
        }
        
        self.hidesBottomBarWhenPushed = true
        adTeamsVC = NewADTeamsViewController(nibName: "NewADTeamsViewController", bundle: nil)
        adTeamsVC.selectedSchool = selectedSchool
        adTeamsVC.adTeams = self.adTeams
        self.navigationController?.pushViewController(adTeamsVC, animated: true)
        
        // Tracking
        let schoolId = selectedSchool["schoolId"] as! String
        let schoolName = selectedSchool["schoolName"] as! String
        let schoolState = selectedSchool["schoolState"] as! String
        let cData = [kTrackingTeamIdKey:schoolId, kTrackingSchoolNameKey:schoolName, kTrackingSchoolStateKey:schoolState]
        let trackingGuid = NSUUID().uuidString
        
        TrackingManager.trackState(featureName: "school-home", trackingGuid: trackingGuid, cData: cData as Dictionary<String, Any>)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
                
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        schoolsTableView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height - 1.0, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height + 1.0)
        schoolsTableView.contentInsetAdjustmentBehavior = .never
        schoolsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -20.0, right: 0)
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        
        // This is added to enable the tabbar buttons when returning from the VCs
        let tabBarControllerItems = self.tabBarController?.tabBar.items
        
        if let tabArray = tabBarControllerItems
        {
            let tabBarItem1 = tabArray[0]
            let tabBarItem2 = tabArray[1]
            let tabBarItem3 = tabArray[2]
            
            tabBarItem1.isEnabled = true
            tabBarItem2.isEnabled = true
            tabBarItem3.isEnabled = true
        }
        
        // This is added to reset the background when returning from the VCs
        kAppKeyWindow.rootViewController!.view.backgroundColor = UIColor.mpWhiteColor()
        
        setNeedsStatusBarAppearanceUpdate()
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

        if (adTeamsVC != nil)
        {
            adTeamsVC = nil
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
