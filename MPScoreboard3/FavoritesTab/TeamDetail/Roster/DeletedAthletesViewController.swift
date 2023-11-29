//
//  DeletedAthletesViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/12/21.
//

import UIKit

protocol DeletedAthletesViewControllerDelegate: AnyObject
{
    func deletedAthleteWasRestored()
}

class DeletedAthletesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, RestoreDeletedAthleteViewControllerDelegate
{
    weak var delegate: DeletedAthletesViewControllerDelegate?
    
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var rosterTableView: UITableView!
    
    var selectedTeam : Team?
    var deletedAthletes: Array<RosterAthlete> = []
    var ssid : String?
    var year = ""
    
    private var restoreDeletedAthleteVC: RestoreDeletedAthleteViewController!
    
    // MARK: - TableView Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return deletedAthletes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 64
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

        // RosterAthleteTableViewCell
        var cell = tableView.dequeueReusableCell(withIdentifier: "RosterAthleteTableViewCell") as? RosterAthleteTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("RosterAthleteTableViewCell", owner: self, options: nil)
            cell = nib![0] as? RosterAthleteTableViewCell
        }
        
        cell?.selectionStyle = .none
        cell?.editButton.isHidden = true
        cell?.chevronImageView.isHidden = false
        
        let athlete = deletedAthletes[indexPath.row]
        
        // Load the data into the cell
        cell?.loadData(athlete: athlete)
        
        return cell!
            
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (restoreDeletedAthleteVC != nil)
        {
            restoreDeletedAthleteVC = nil
        }
        
        restoreDeletedAthleteVC = RestoreDeletedAthleteViewController(nibName: "RestoreDeletedAthleteViewController", bundle: nil)
        restoreDeletedAthleteVC.delegate = self
        restoreDeletedAthleteVC.selectedTeam = self.selectedTeam
        restoreDeletedAthleteVC.ssid = self.ssid
        
        let athlete = deletedAthletes[indexPath.row]
        restoreDeletedAthleteVC.currentAthlete = athlete
        
        restoreDeletedAthleteVC.modalPresentationStyle = .overCurrentContext
        self.tabBarController?.tabBar.isHidden = true
        self.present(restoreDeletedAthleteVC, animated: true) {
            
        }
    }
    
    // MARK: - RestoreDeletedAthleteViewController Delegates
    
    func restoreDeletedAthleteCancelButtonTouched()
    {
        self.tabBarController?.tabBar.isHidden = false
        self.dismiss(animated: true)
        {
            
        }
    }
    
    func restoreDeletedAthleteRestoreButtonTouched()
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
        
        TrackingManager.trackState(featureName: "athlete-manage", trackingGuid: trackingGuid, cData: cData)
        
        self.tabBarController?.tabBar.isHidden = false
        self.dismiss(animated: true)
        {
            // This causes the rosterVC to reload the roster from the server
            self.delegate?.deletedAthleteWasRestored()
            self.navigationController?.popViewController(animated: true)
        }
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

        // Explicitly set the header view size. The items within the view are pinned to the bottom
        navView.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight + kNavBarHeight)
        rosterTableView.frame = CGRect(x: 0, y: Int(navView.frame.size.height), width: Int(kDeviceWidth), height: Int(kDeviceHeight) - Int(navView.frame.size.height) - SharedData.bottomSafeAreaHeight - kTabBarHeight)
        
        let hexColorString = self.selectedTeam?.teamColor
        navView.backgroundColor = ColorHelper.color(fromHexString: hexColorString, colorCorrection: true)!
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
