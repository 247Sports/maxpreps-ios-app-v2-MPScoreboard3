//
//  CoachTeamsViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 7/12/23.
//

import UIKit

class CoachTeamsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var teamsTableView: UITableView!
    
    //var adminTeamsArray: Array<Dictionary<String,Any>> = []
    
    private var teamSummaries: Array<Dictionary<String,Any>> = []
    private var progressOverlay: ProgressHUD!
    private var teamDetailVC: TeamDetailViewController!
    
    // MARK: - Get Coach Team Summaries
    
    private func getCoachTeamSummaries()
    {
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }

        NewFeeds.getCoachUserProfileTeamSummaries() { results, error in
            
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
                print("Get Coach Team Summaries Success")
                
                self.teamSummaries = results!
            }
            else
            {
                print("Get Coach Team Summaries Failed")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "A server error occured.", lastItemCancelType: false) { tag in
                    
                }
            }
            
            self.teamsTableView.reloadData()
        }
    }
    
    // MARK: - Show Team Detail View Controller
    
    private func showTeamDetailViewController(selectedTeam: Dictionary<String,Any>)
    {
        let schoolId = selectedTeam["teamId"] as! String
        let name = selectedTeam["schoolName"] as! String
        let city = selectedTeam["schoolCity"] as! String
        let state = selectedTeam["schoolState"] as! String
        let fullName = String(format: "%@ (%@, %@)", name, city, state)
        let gender = selectedTeam["gender"] as! String
        let sport = selectedTeam["sport"] as! String
        let level = selectedTeam["teamLevel"] as! String
        let season = selectedTeam["season"] as! String
        let allSeasonId = selectedTeam["allSeasonId"] as! String
        let mascotUrlString = selectedTeam["schoolMascotUrl"] as! String
        let hexColorString = selectedTeam["schoolColor1"] as! String
        
        self.tabBarController?.tabBar.isHidden = false
        
        // This is added to disable tha tabbar buttons
        let tabBarControllerItems = self.tabBarController?.tabBar.items

        if let tabArray = tabBarControllerItems
        {
            let tabBarItem1 = tabArray[0]
            let tabBarItem2 = tabArray[1]
            let tabBarItem3 = tabArray[2]

            tabBarItem1.isEnabled = false
            tabBarItem2.isEnabled = false
            tabBarItem3.isEnabled = false
        }
        
        if (teamDetailVC != nil)
        {
            teamDetailVC = nil
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
        
        teamDetailVC = TeamDetailViewController(nibName: "TeamDetailViewController", bundle: nil)
        teamDetailVC.selectedTeam = selectedTeamObj
        teamDetailVC.showSaveFavoriteButton = showSaveFavoriteButton
        teamDetailVC.showRemoveFavoriteButton = showRemoveFavoriteButton
        self.navigationController?.pushViewController(teamDetailVC, animated: true)
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return teamSummaries.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        // Reduce the heigh if the hudl and gameChanger
        if (teamSummaries.count > 0)
        {
            let teamSummary = teamSummaries[indexPath.row]
            let hudlCount = teamSummary["hudlContestCount"] as! Int
            let gameChangerConnected = teamSummary["isGameChangerConnected"] as! Bool
            
            if ((hudlCount > 0) || (gameChangerConnected == true))
            {
                return 504.0
            }
            else
            {
                return 464.0
            }
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (teamSummaries.count > 0)
        {
            return 20.0
        }
        else
        {
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 20.0))
        footerView.backgroundColor = UIColor.mpWhiteColor()
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "NewCoachTeamsTableViewCell") as? NewCoachTeamsTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("NewCoachTeamsTableViewCell", owner: self, options: nil)
            cell = nib![0] as? NewCoachTeamsTableViewCell
        }
        
        cell?.selectionStyle = .none
        
        cell?.manageTeamButton.tag = 100 + indexPath.row
        cell?.manageTeamButton.addTarget(self, action: #selector(teamButtonTouched(_:)), for: .touchUpInside)
        
        if (teamSummaries.count > 0)
        {
            let teamData = teamSummaries[indexPath.row]
            cell?.loadData(teamData)
        }

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
        let selectedTeam = teamSummaries[index]
        
        self.showTeamDetailViewController(selectedTeam: selectedTeam)
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
        teamsTableView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height - 1.0, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height + 1.0)
        teamsTableView.contentInsetAdjustmentBehavior = .never
        teamsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -20.0, right: 0)
        
        self.getCoachTeamSummaries()
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
 
        if (teamDetailVC != nil)
        {
            teamDetailVC = nil
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
