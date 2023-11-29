//
//  MyTeamsViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/13/23.
//

import UIKit

class MyTeamsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewProfileMyTeamsTableViewCellDelegate, NewProfileMyTeamsFooterViewCellDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var teamsTableView: UITableView!
    
    var sportTeams: Array<Dictionary<String,Any>> = []
    var athleteName = ""
    
    private var myTeamsHeaderView: NewProfileMyTeamsHeaderViewCell!
    private var myTeamsFooterView: NewProfileMyTeamsFooterViewCell!
    
    private var webVC: WebViewController!
    private var teamDetailVC: TeamDetailViewController!
    
    // MARK: - NewProfileMyTeamsTableViewCellDelegate
    
    func myTeamsTableViewCellTouched(selectedTeam: Dictionary<String,Any>)
    {
        let schoolId = selectedTeam["schoolId"] as! String
        let name = selectedTeam["schoolName"] as! String
        let city = selectedTeam["schoolCity"] as! String
        let state = selectedTeam["schoolState"] as! String
        let fullName = String(format: "%@ (%@, %@)", name, city, state)
        let gender = selectedTeam["gender"] as? String ?? ""
        let sport = selectedTeam["sport"] as! String
        let level = selectedTeam["level"] as! String
        let season = selectedTeam["season"] as? String ?? ""
        let allSeasonId = selectedTeam["allSeasonId"] as? String ?? ""
        let mascotUrlString = selectedTeam["schoolMascotUrl"] as! String
        let hexColorString = selectedTeam["schoolColor1"] as! String
        let ssid = selectedTeam["sportSeasonId"] as! String
        
        // Temp code
        if (gender == "")
        {
            return
        }
        
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
        teamDetailVC.selectedSSID = ssid
        teamDetailVC.showSaveFavoriteButton = showSaveFavoriteButton
        teamDetailVC.showRemoveFavoriteButton = showRemoveFavoriteButton
        self.navigationController?.pushViewController(teamDetailVC, animated: true)
        
    }
    
    // MARK: - NewProfileMyTeamsFooterViewCell Delegate
    
    func myTeamsFooterViewCellTouched()
    {
        self.hidesBottomBarWhenPushed = true
        
        webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC.titleString = "Support"
        webVC.urlString = kTechSupportUrl
        webVC.titleColor = UIColor.mpBlackColor()
        webVC.navColor = UIColor.mpWhiteColor()
        webVC.allowRotation = false
        webVC.showShareButton = false
        webVC.showScrollIndicators = false
        webVC.showLoadingOverlay = true
        webVC.showBannerAd = false
        webVC.tabBarVisible = false
        webVC.enableAdobeQueryParameter = true

        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return sportTeams.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 226.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 72.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let view = UIView()
        view.addSubview(myTeamsHeaderView!)
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let view = UIView()
        view.addSubview(myTeamsFooterView!)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "NewProfileMyTeamsTableViewCell") as? NewProfileMyTeamsTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("NewProfileMyTeamsTableViewCell", owner: self, options: nil)
            cell = nib![0] as? NewProfileMyTeamsTableViewCell
        }
        
        cell?.selectionStyle = .none
        cell?.delegate = self
        let sportTeam = sportTeams[indexPath.row]
        
        cell?.loadData(data: sportTeam)

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
        teamsTableView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height)
        teamsTableView.contentInsetAdjustmentBehavior = .never
        teamsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -20.0, right: 0)

        let myTeamsHeaderNib = Bundle.main.loadNibNamed("NewProfileMyTeamsHeaderViewCell", owner: self, options: nil)
        myTeamsHeaderView = myTeamsHeaderNib![0] as? NewProfileMyTeamsHeaderViewCell
        myTeamsHeaderView?.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 72)
        myTeamsHeaderView?.titleLabel.text = athleteName
        
        let myTeamsFooterNib = Bundle.main.loadNibNamed("NewProfileMyTeamsFooterViewCell", owner: self, options: nil)
        myTeamsFooterView = myTeamsFooterNib![0] as? NewProfileMyTeamsFooterViewCell
        myTeamsFooterView?.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 120)
        myTeamsFooterView?.delegate = self
        
        let contactString = "Do you see a missing season or is this not you? Contact Us"
        let attributedString = NSMutableAttributedString(string: contactString)
                
        let range = contactString.range(of: "Contact Us")
        let convertedRange = NSRange(range!, in: contactString)
        
        attributedString.addAttributes([NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,  NSAttributedString.Key.foregroundColor: UIColor.mpBlackColor(), NSAttributedString.Key.font: UIFont.mpItalicFontWith(size: 12)], range: convertedRange)
        
        myTeamsFooterView?.footerLabel.attributedText = attributedString
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
 
        if (webVC != nil)
        {
            webVC = nil
        }
        
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
