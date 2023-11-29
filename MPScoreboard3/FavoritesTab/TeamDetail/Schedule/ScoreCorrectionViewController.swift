//
//  ScoreCorrectionViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/6/21.
//

import UIKit
import CoreMedia

class ScoreCorrectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var scheduleTableView: UITableView!
    
    var selectedTeam : Team?
    var ssid : String?
    var scoredGames : Array<Dictionary<String,Any>>?
    var gameTypeAliases : Array<String>?
    
    // MARK: - Show Web View
    
    private func showWebView(urlString: String, title: String, showShare: Bool)
    {
        // Color changed
        let webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC.titleString = title
        webVC.urlString = urlString
        //webVC.titleColor = UIColor.mpWhiteColor()
        //webVC.navColor = navView.backgroundColor!
        webVC.titleColor = UIColor.mpBlackColor()
        webVC.navColor = UIColor.mpWhiteColor()
        webVC.allowRotation = false
        webVC.showShareButton = showShare
        webVC.showScrollIndicators = true
        webVC.showLoadingOverlay = true
        webVC.showBannerAd = false
        webVC.tabBarVisible = true
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
        return scoredGames!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 68
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.01
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
        let colorString = selectedTeam?.teamColor
        let teamColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
        let item = scoredGames![indexPath.row]
                
        var cell = tableView.dequeueReusableCell(withIdentifier: "ScoreCorrectionTableViewCell") as? ScoreCorrectionTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("ScoreCorrectionTableViewCell", owner: self, options: nil)
            cell = nib![0] as? ScoreCorrectionTableViewCell
        }
        
        cell?.selectionStyle = .none

        cell?.loadData(item, teamColor: teamColor!, myTeamId: selectedTeam!.schoolId, gameTypeAliases: self.gameTypeAliases!)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = scoredGames![indexPath.row]
        let contest = item["contest"] as! Dictionary<String,Any>
        let contestId = contest["contestId"] as! String
        
        // Get the correct base URL
        var subDomain = ""
        
        // Build the subdomain
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            let branchValue = kUserDefaults.string(forKey: kBranchValue)
            subDomain = String(format: "branch-%@.fe", branchValue!.lowercased())
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            subDomain = "dev"
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            subDomain = "staging"
        }
        else
        {
            subDomain = "www"
        }
        
        let urlString = String(format: kReportScoresHostGeneric, subDomain, contestId, self.ssid!)
        
        self.showWebView(urlString: urlString, title: "Submit Correction", showShare: false)
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        // Explicitly set the header view size. The items within the view are pinned to the bottom
        navView.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight + 44)
        scheduleTableView.frame = CGRect(x: 0, y: Int(navView.frame.size.height), width: Int(kDeviceWidth), height: Int(kDeviceHeight) - Int(navView.frame.size.height) - kTabBarHeight - SharedData.bottomSafeAreaHeight)
                
        let hexColorString = self.selectedTeam?.teamColor
        let currentTeamColor = ColorHelper.color(fromHexString: hexColorString, colorCorrection: true)!
        navView.backgroundColor = currentTeamColor
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mpBlackColor(), .font: UIFont.mpSemiBoldFontWith(size: kNavBarFontSize)]

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
}
