//
//  DeletedGamesViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/4/21.
//

import UIKit
import CoreMedia

class DeletedGamesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RestoreDeletedGameViewControllerDelegate
{
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var scheduleTableView: UITableView!
    
    var selectedTeam : Team?
    var ssid : String?
    var deletedGames : Array<Dictionary<String,Any>>?
    var gameTypeAliases : Array<String>?
    var year = ""
    var gameRestored = false
    
    private var restoreDeletedGameVC : RestoreDeletedGameViewController!
    
    // MARK: - RestoreDeletedGameViewController Delegate
    
    func restoreGameCancelButtonTouched()
    {
        self.dismiss(animated: true)
        {
            self.restoreDeletedGameVC = nil
        }
    }
    
    func restoreGameRestoreButtonTouched()
    {
        // Build the tracking context data object
        var cData = kEmptyTrackingContextData
        let trackingGuid = NSUUID().uuidString
        let userTeamRole = MiscHelper.userTeamRole(schoolId: self.selectedTeam!.schoolId, allSeasonId: self.selectedTeam!.allSeasonId)
        print(userTeamRole)
        
        let schoolName = self.selectedTeam?.schoolName
        let schoolState = self.selectedTeam?.schoolState
        let schoolId = self.selectedTeam?.schoolId
        let sport = self.selectedTeam?.sport
        let level = self.selectedTeam?.teamLevel
        let gender = self.selectedTeam?.gender
        let season = self.selectedTeam?.season
        
        cData[kTrackingSchoolNameKey] = schoolName
        cData[kTrackingSchoolStateKey] = schoolState
        cData[kTrackingTeamIdKey] = schoolId
        cData[kTrackingSportNameKey] = sport
        cData[kTrackingSportLevelKey] = level
        cData[kTrackingSportGenderKey] = gender
        cData[kTrackingSeasonKey] = season
        cData[kTrackingSchoolYearKey] = self.year
        cData[kTrackingUserTeamRoleKey] = userTeamRole
        
        TrackingManager.trackState(featureName: "schedule-manage", trackingGuid: trackingGuid, cData: cData)
        
        self.gameRestored = restoreDeletedGameVC.gameRestored
        
        self.dismiss(animated: true)
        {
            self.restoreDeletedGameVC = nil
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return deletedGames!.count
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
        let item = deletedGames![indexPath.row]
                
        var cell = tableView.dequeueReusableCell(withIdentifier: "DeletedGameTableViewCell") as? DeletedGameTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("DeletedGameTableViewCell", owner: self, options: nil)
            cell = nib![0] as? DeletedGameTableViewCell
        }
        
        cell?.selectionStyle = .none

        cell?.loadData(item, teamColor: teamColor!, myTeamId: selectedTeam!.schoolId, gameTypeAliases: self.gameTypeAliases!)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (restoreDeletedGameVC != nil)
        {
            restoreDeletedGameVC = nil
        }
        
        let selectedGame = deletedGames![indexPath.row]
        
        restoreDeletedGameVC = RestoreDeletedGameViewController(nibName: "RestoreDeletedGameViewController", bundle: nil)
        restoreDeletedGameVC.delegate = self
        restoreDeletedGameVC.selectedGame = selectedGame
        restoreDeletedGameVC.selectedTeam = self.selectedTeam
        restoreDeletedGameVC.ssid = self.ssid
        restoreDeletedGameVC.gameTypeAliases = self.gameTypeAliases!
        restoreDeletedGameVC.modalPresentationStyle = .overCurrentContext
        
        self.present(restoreDeletedGameVC, animated: true) {
            
        }
        
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
        scheduleTableView.frame = CGRect(x: 0, y: Int(navView.frame.size.height), width: Int(kDeviceWidth), height: Int(kDeviceHeight) - Int(navView.frame.size.height) - SharedData.bottomSafeAreaHeight)
                
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
