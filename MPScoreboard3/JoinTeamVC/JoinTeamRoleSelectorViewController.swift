//
//  JoinTeamRoleSelectorViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/28/22.
//

import UIKit

class JoinTeamRoleSelectorViewController: UIViewController
{
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headCoachButton: UIButton!
    @IBOutlet weak var assistantCoachButton: UIButton!
    @IBOutlet weak var statisticianButton: UIButton!
    @IBOutlet weak var athleticDirectorButton: UIButton!
    @IBOutlet weak var schoolAdministratorButton: UIButton!
    @IBOutlet weak var coachMessageLabel: UILabel!
    @IBOutlet weak var coachRequestButton: UIButton!
    @IBOutlet weak var statisticianMessageLabel: UILabel!
    @IBOutlet weak var statisticianRequestButton: UIButton!
    
    var selectedTeam : Team?
    
    private var trackingGuid = ""
    private var selectedButton = -1
    private var redButtonColor = UIColor(red: 192.0/255.0, green: 4.0/255.0, blue: 0, alpha: 1)
    private var darkRedButtonColor = UIColor(red: 164.0/255.0, green: 4.0/255.0, blue: 0, alpha: 1)
    
    private var coachRequestVC: JoinTeamCoachRequestViewController!
    private var statisticianCoachVC: JoinTeamStatisticianCoachInputViewController!
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Update User Info
    
    private func updateUserInfo()
    {
        // Add some delay here so the server has some time to clear out the caches
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            // Validate user to update the roles throughout the app
            NotificationCenter.default.post(name: Notification.Name("GetUserInfo"), object: nil)
            
            //let tabController = self.tabBarController as! TabBarController
            //tabController.getUserInfo()
        }
    }
    
    // MARK: - Request Coach Access
    
    private func requestCoachAccess(position: String)
    {
        // Show the busy indicator
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.requestCoachAccess(schoolId: selectedTeam!.schoolId, allSeasonId: selectedTeam!.allSeasonId, position: position) { (result, error) in
            
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
                print("Request Coach Access Success")
                
                /*
                 ▿ 0 : 2 elements
                   - key : "message"
                   - value : To obtain Admin Access, please reach out to one of the following active coaches: J. Justin, B. Bill.
                 ▿ 1 : 2 elements
                   - key : "status"
                   - value : 3
                 */
                
                /*
                 Unknown = 0,
                 AutoAccepted = 1,
                 TicketCreated = 2,
                 TooManyCoaches = 3,
                 Failed = 4
                 */
                let status = result!["status"] as! Int
                var message = ""
                
                // Build the tracking context data object
                var cData = kEmptyTrackingContextData
                
                let schoolId = self.selectedTeam?.schoolId
                let schoolName = self.selectedTeam?.schoolName
                let schoolState = self.selectedTeam?.schoolState
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
                
                switch status
                {
                case 1:
                    // Auto Accepted
                    self.updateUserInfo()

                    TrackingManager.trackState(featureName: "auto-access", trackingGuid: self.trackingGuid, cData: cData)
                case 2:
                    // Pending
                    message = "Pending"
                    
                    TrackingManager.trackState(featureName: "coach-request-sent", trackingGuid: self.trackingGuid, cData: cData)
                case 3:
                    message = result!["message"] as! String
                default:
                    message = "Error"
                }
                
                if (message == "Error")
                {
                    OverlayView.showPopdownOverlay(withMessage: "Something went wrong when requesting coach access.", title: "Oops!", overlayColor: UIColor.mpWhiteColor()) {
                    }
                }
                else
                {
                    self.coachRequestVC = JoinTeamCoachRequestViewController(nibName: "JoinTeamCoachRequestViewController", bundle: nil)
                    self.coachRequestVC.selectedTeam = self.selectedTeam
                    self.coachRequestVC.status = status
                    self.coachRequestVC.message = message
                    
                    self.navigationController?.pushViewController(self.coachRequestVC, animated: true)
                    
                    TrackingManager.trackState(featureName: "no-access", trackingGuid: self.trackingGuid, cData: cData)
                }
            }
            else
            {
                print("Request Coach Access Failed")
                
                OverlayView.showPopdownOverlay(withMessage: "Something went wrong when requesting coach access.", title: "Oops!", overlayColor: UIColor.mpWhiteColor()) {
                    
                }
            }
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func closeButtonTouched(_ sender: UIButton)
    {
        self.dismiss(animated: true)
        {
            
        }
    }
    
    @IBAction func headCoachButtonTouched()
    {
        selectedButton = 0
        
        headCoachButton.layer.borderWidth = 1
        assistantCoachButton.layer.borderWidth = 0
        statisticianButton.layer.borderWidth = 0
        headCoachButton.backgroundColor = darkRedButtonColor
        assistantCoachButton.backgroundColor = redButtonColor
        statisticianButton.backgroundColor = redButtonColor
        
        coachMessageLabel.isHidden = false
        coachRequestButton.isHidden = false
        statisticianMessageLabel.isHidden = true
        statisticianRequestButton.isHidden = true
    }
    
    @IBAction func assistantCoachButtonTouched()
    {
        selectedButton = 1
        
        headCoachButton.layer.borderWidth = 0
        assistantCoachButton.layer.borderWidth = 1
        statisticianButton.layer.borderWidth = 0
        headCoachButton.backgroundColor = redButtonColor
        assistantCoachButton.backgroundColor = darkRedButtonColor
        statisticianButton.backgroundColor = redButtonColor
        
        coachMessageLabel.isHidden = false
        coachRequestButton.isHidden = false
        statisticianMessageLabel.isHidden = true
        statisticianRequestButton.isHidden = true
    }
    
    @IBAction func statisticianButtonTouched()
    {
        selectedButton = 2
        
        headCoachButton.layer.borderWidth = 0
        assistantCoachButton.layer.borderWidth = 0
        statisticianButton.layer.borderWidth = 1
        headCoachButton.backgroundColor = redButtonColor
        assistantCoachButton.backgroundColor = redButtonColor
        statisticianButton.backgroundColor = darkRedButtonColor
        
        coachMessageLabel.isHidden = true
        coachRequestButton.isHidden = true
        statisticianMessageLabel.isHidden = false
        statisticianRequestButton.isHidden = false
    }
    
    @IBAction func coachRequestButtonTouched()
    {
        if (selectedButton == 0)
        {
            self.requestCoachAccess(position: "Head Coach")
        }
        else if (selectedButton == 1)
        {
            self.requestCoachAccess(position: "Assistant Coach")
        }
        
    }
    
    @IBAction func statisticianRequestButtonTouched()
    {
        if (statisticianCoachVC != nil)
        {
            statisticianCoachVC = nil
        }
        
        statisticianCoachVC = JoinTeamStatisticianCoachInputViewController(nibName: "JoinTeamStatisticianCoachInputViewController", bundle: nil)
        statisticianCoachVC.selectedTeam = self.selectedTeam
        
        self.navigationController?.pushViewController(statisticianCoachVC, animated: true)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        trackingGuid = NSUUID().uuidString

        navView.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight + 44)
        containerView.frame = CGRect(x: 0, y: navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.size.height)
        
        headCoachButton.layer.cornerRadius = 8
        assistantCoachButton.layer.cornerRadius = 8
        statisticianButton.layer.cornerRadius = 8
        athleticDirectorButton.layer.cornerRadius = 8
        schoolAdministratorButton.layer.cornerRadius = 8
        
        headCoachButton.layer.borderWidth = 0
        assistantCoachButton.layer.borderWidth = 0
        statisticianButton.layer.borderWidth = 0
        
        headCoachButton.layer.borderColor = UIColor.mpWhiteColor().cgColor
        assistantCoachButton.layer.borderColor = UIColor.mpWhiteColor().cgColor
        statisticianButton.layer.borderColor = UIColor.mpWhiteColor().cgColor
        
        headCoachButton.clipsToBounds = true
        assistantCoachButton.clipsToBounds = true
        statisticianButton.clipsToBounds = true
        athleticDirectorButton.clipsToBounds = true
        schoolAdministratorButton.clipsToBounds = true
        
        coachRequestButton.layer.cornerRadius = coachRequestButton.frame.size.height / 2.0
        statisticianRequestButton.layer.cornerRadius = statisticianButton.frame.size.height / 2.0
        coachRequestButton.clipsToBounds = true
        statisticianRequestButton.clipsToBounds = true
        
        coachMessageLabel.isHidden = true
        coachRequestButton.isHidden = true
        statisticianMessageLabel.isHidden = true
        statisticianRequestButton.isHidden = true
        
        let genderSportLevel = MiscHelper.genderSportLevelFrom(gender: selectedTeam!.gender, sport: selectedTeam!.sport, level: selectedTeam!.teamLevel)
        
        coachMessageLabel.text = String(format: "Request Coach Admin Access for %@.", genderSportLevel)
        statisticianMessageLabel.text = String(format: "Statisticians must be approved by a coach. Would you like to send a Volunteer request for %@?", genderSportLevel)
        
        
        // Build the tracking context data object
        var cData = kEmptyTrackingContextData
        
        let schoolId = self.selectedTeam?.schoolId
        let schoolName = self.selectedTeam?.schoolName
        let schoolState = self.selectedTeam?.schoolState
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

        TrackingManager.trackState(featureName: "select-role", trackingGuid: trackingGuid, cData: cData)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (coachRequestVC != nil)
        {
            self.dismiss(animated: true)
            coachRequestVC = nil
        }
        
        if (statisticianCoachVC != nil)
        {
            if (statisticianCoachVC.requestSent == true)
            {
                self.dismiss(animated: true)
            }
            statisticianCoachVC = nil
        }
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
