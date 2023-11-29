//  POGRosterViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/11/21.
//

import UIKit

protocol POGRosterViewControllerDelegate: AnyObject
{
    func pogRosterAthleteSelected()
    func pogRosterCancelButtonTouched()
}

class POGRosterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    weak var delegate: POGRosterViewControllerDelegate?
    
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var rosterTableView: UITableView!

    var ssid: String?
    var selectedTeam: Team!
    var selectedAthelete = RosterAthlete(athleteId: "", firstName: "", lastName: "", classYear: "", jersey: "", heightInches: "", heightFeet: "", weight: "", position1: "", position2: "", position3: "", hasStats: false, isCaptain: false, isDeleted: false, photoUrl: "", weightClass: "", isPlayerOfTheGame: false, isFemale: false, bio: "", hasPhoto: false, rosterId: "", careerId: "")
    
    private var athleteItems: Array<RosterAthlete> = []
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Get Roster
    
    private func getPublicRosters()
    {
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        // Call the feed
        RosterFeeds.getPublicRosters(teamId: self.selectedTeam!.schoolId, ssid: self.ssid!, sort: "0") { athletes, deletedAthletes, staff, photoUrl, error in
            
            // Hide the busy indicator
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
                print("Get Roster Success")
                
                if (athletes!.count > 0)
                {
                    self.athleteItems = athletes!
                    
                    self.rosterTableView.reloadData()
                }
                else
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "No Roster", message: "This team does not have a roster.", lastItemCancelType: false) { tag in
                        
                    }
                }
            }
            else
            {
                print("Get Roster Failed")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to get the roster.", lastItemCancelType: false) { tag in
                    
                }
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
        athleteItems.count
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
        return CGFloat(SharedData.bottomSafeAreaHeight)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: CGFloat(SharedData.bottomSafeAreaHeight)))
        view.backgroundColor = UIColor.mpWhiteColor()
        return view
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
        cell?.chevronImageView.isHidden = true
        
        let athlete = athleteItems[indexPath.row]
        
        // Load the data into the cell
        cell?.loadData(athlete: athlete)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedAthelete = athleteItems[indexPath.row]
        
        self.delegate?.pogRosterAthleteSelected()
    }
    
    // MARK: - Button Methods
    
    @IBAction func cancelButtonTouched(_ sender: UIButton)
    {
        self.delegate?.pogRosterCancelButtonTouched()
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Size and locate the fakeStatusBar, navBar, containerScrollView, and tabBarContainer
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 76 + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        rosterTableView.frame = CGRect(x: 0.0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height)
         
        navView.layer.cornerRadius = 12
        navView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        navView.clipsToBounds = true
        
        self.getPublicRosters()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        /*
        // Add some delay so the view is partially showing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
        {
            UIView.animate(withDuration: 0.3)
            { [self] in
                fakeStatusBar.backgroundColor = UIColor(white: 0, alpha: 0.6)
            }
        }
        */
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
