//
//  CopyScheduleViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/5/21.
//

import UIKit

protocol CopyScheduleViewControllerDelegate: AnyObject
{
    func copyScheduleSucceeded()
    func copyScheduleCancelButtonTouched()
}

class CopyScheduleViewController: UIViewController, UITextFieldDelegate, IQActionSheetPickerViewDelegate
{
    weak var delegate: CopyScheduleViewControllerDelegate?
    
    var selectedTeam : Team!
    var ssid : String?
    var year : String?
    
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var topButton: UIButton!
    @IBOutlet weak var bottomButton: UIButton!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var noGameOverlayView: UIView!
    @IBOutlet weak var noGameLabel: UILabel!
    
    @IBOutlet weak var tabBarContainer: UIView!
    @IBOutlet weak var copyButton: UIButton!

    private var teamColor = UIColor.mpRedColor()
    private var matchingTeams = [] as Array
    private var selectedButtonIndex = -1
    private var selectedDate = Date()
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelect date: Date)
    {
        selectedDate = date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        
        timeTextField.text = dateFormatter.string(from: date)
    }
    
    func actionSheetPickerViewDidCancel(_ pickerView: IQActionSheetPickerView)
    {
        
    }
    
    // MARK: - TextField Delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        let picker = IQActionSheetPickerView(title: "Select Time", delegate: self)
        picker.backgroundColor = UIColor.mpWhiteColor()
        picker.toolbarButtonColor = UIColor.mpWhiteColor()
        picker.toolbarTintColor = UIColor.mpPickerToolbarColor()
        picker.actionSheetPickerStyle = IQActionSheetPickerStyle.timePicker
        picker.minuteInterval = 5
        picker.show()
        
        return false
    }
    
    // MARK: - Get Available Teams
    
    private func getAvailableTeams()
    {
        // Call the feed
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.getAvailableTeamsForSchool(schoolId: selectedTeam!.schoolId) { availableTeams, error in
            
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
                print("Get Available Teams Successful")
                
                /*
                  {
                  "teamId": "cbd85b5c-91e4-46cf-9849-b1cd0b78972c",
                  "sportSeasonId": "b2e164af-cc17-44b1-a3f3-c4798695f001",
                  "hasTeamRoster": false,
                  "hasContests": true,
                  "hasLeagueStandings": false,
                  "hasStats": false,
                  "hasRankings": false,
                  "hasVideos": false,
                  "hasProPhotos": true,
                  "hasArticles": false,
                  "isPrepsSportsEnabled": false,
                  "updatedOn": "2020-12-10T22:16:38.1823174Z"
                  }
                 */
                
                let teams = availableTeams!["teams"] as! Array<Dictionary<String,Any>>
                
                // Iterate through the teams and save only those that are the same gender-sport at a different level
                
                for teamLevel in teams
                {
                    let level = teamLevel["level"] as! String
                    
                    // Skip the selected teamLevel
                    if (level == self.selectedTeam.teamLevel)
                    {
                        continue
                    }
                    else
                    {
                        let teams = teamLevel["allSeasonSports"] as! Array<Dictionary<String,Any>>
                        
                        for team in teams
                        {
                            let gender = team["gender"] as! String
                            let sport = team["sport"] as! String
                            let season = team["season"] as! String
                            let allSeasonId = team["allSeasonId"] as! String
                            
                            if ((gender == self.selectedTeam.gender) && (sport == self.selectedTeam.sport) && (season == self.selectedTeam.season))
                            {
                                let teamObj = ["level":level, "gender":gender, "sport":sport, "season":season, "allSeasonId": allSeasonId]
                                self.matchingTeams.append(teamObj)
                            }
                        }
                    }
                }
                
                print("Matched Teams: " + String(self.matchingTeams.count))
                                
                if (self.matchingTeams.count == 0)
                {
                    self.copyButton.isEnabled = false
                    self.copyButton.backgroundColor = UIColor.mpLightGrayColor()
                    
                    self.noGameLabel.isHidden = false
                }
                else if (self.matchingTeams.count == 1)
                {
                    // Populate the UI
                    self.noGameOverlayView.isHidden = true
                    
                    let teamA = self.matchingTeams.first as! Dictionary<String,String>
                    let genderA = teamA["gender"]
                    let levelA = teamA["level"]
                    let sportA = teamA["sport"]
                    let seasonA = teamA["season"]
                    self.topLabel.text = String(format: "%@ %@ %@ (%@ %@)", genderA!, levelA!, sportA!, seasonA!, self.year!)
                    
                    self.topButtonTouched()
                }
                else
                {
                    self.noGameOverlayView.isHidden = true
                    self.bottomLabel.isHidden = false
                    self.bottomButton.isHidden = false
                    
                    let teamA = self.matchingTeams.first as! Dictionary<String,String>
                    let genderA = teamA["gender"]
                    let levelA = teamA["level"]
                    let sportA = teamA["sport"]
                    let seasonA = teamA["season"]
                    self.topLabel.text = String(format: "%@ %@ %@ (%@ %@)", genderA!, levelA!, sportA!, seasonA!, self.year!)
                    
                    let teamB = self.matchingTeams.last as! Dictionary<String,String>
                    let genderB = teamB["gender"]
                    let levelB = teamB["level"]
                    let sportB = teamB["sport"]
                    let seasonB = teamB["season"]
                    self.bottomLabel.text = String(format: "%@ %@ %@ (%@ %@)", genderB!, levelB!, sportB!, seasonB!, self.year!)
                    
                    self.topButtonTouched()
                }
            }
            else
            {
                print("Get Available Teams Failed")
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to find other schedules.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func cancelButtonTouched(_ sender: UIButton)
    {
        fakeStatusBar.backgroundColor = .clear
        
        self.delegate?.copyScheduleCancelButtonTouched()
    }
    
    @IBAction func topButtonTouched()
    {
        selectedButtonIndex = 0
        
        topButton.setImage(UIImage(named: "RadioButtonOn"), for: .normal)
        bottomButton.setImage(UIImage(named: "RadioButtonOff"), for: .normal)
        
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
        { [self] in
            topButton.imageView?.setImageColor(color: teamColor)
            bottomButton.imageView?.setImageColor(color: teamColor)
        }
        */
    }
    
    @IBAction func bottomButtonTouched()
    {
        selectedButtonIndex = 1
        
        topButton.setImage(UIImage(named: "RadioButtonOff"), for: .normal)
        bottomButton.setImage(UIImage(named: "RadioButtonOn"), for: .normal)
        
        /*
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
        { [self] in
            topButton.imageView?.setImageColor(color: teamColor)
            bottomButton.imageView?.setImageColor(color: teamColor)
        }
        */
    }

    @IBAction func copyButtonTouched(_ sender: UIButton)
    {
        if (timeTextField.text == "")
        {
            var message = "You need to enter the starting time for the games. You can change the starting time for individual games later."
            
            if (MiscHelper.sportUsesMatchInsteadOfGame(sport: self.selectedTeam!.sport) == true)
            {
                message = "You need to enter the starting time for the matches. You can change the starting time for individual matches later."
            }
            
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Missing Time", message: message, lastItemCancelType: false) { tag in
                
            }
            
            return
        }
        
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        let matchingTeam = matchingTeams[selectedButtonIndex] as! Dictionary<String,Any>
        let fromAllSeasonId = matchingTeam["allSeasonId"] as! String
        
        // Get the sportSeasonId from the allSeasonId
        NewFeeds.getSSIDsForTeam(fromAllSeasonId, schoolId: selectedTeam!.schoolId) { (result, error) in
            
            if error == nil
            {                
                print("Get SSID's success")
                
                if (result!.count > 0)
                {
                    let latestTeam = result?.first
                    let fromSSID = latestTeam!["sportSeasonId"] as! String
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm"
                    let timeString = dateFormatter.string(from: self.selectedDate)
                    
                    ScheduleFeeds.copyTeamSchedule(schoolId: self.selectedTeam!.schoolId, fromSSID: fromSSID, toSSID: self.ssid!, time: timeString) { result, message, error in
                        
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
                            print("Copy Schedule Successful")
                            
                            OverlayView.showPopupOverlay(withMessage: "Schedule Copied")
                            {
                                self.fakeStatusBar.backgroundColor = .clear
                                self.delegate?.copyScheduleSucceeded()
                            }
                        }
                        else
                        {
                            print("Copy Schedule Failed")
                            
                            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: message, lastItemCancelType: false) { tag in
                                
                            }
                            /*
                            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to copy the schedule. It's possible that one or more of the games could not be copied.", lastItemCancelType: false) { tag in
                                
                            }
                            */
                        }
                    }
                }
                else
                {
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
                    
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to copy the schedule.", lastItemCancelType: false) { tag in
                        
                    }
                }
            }
            else
            {
                print("Get SSID's error")
                
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
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to copy the schedule.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        fakeStatusBar.backgroundColor = .clear
        
        let hexColorString = self.selectedTeam?.teamColor
        teamColor = ColorHelper.color(fromHexString: hexColorString, colorCorrection: true)!
 
        // Size and locate the fakeStatusBar, navBar, containerView, and tabBarContainer
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: Int(kDeviceHeight))
        navView.frame = CGRect(x: 0, y: kDeviceHeight - CGFloat(SharedData.bottomSafeAreaHeight) - 80 - 246, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        containerView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: CGFloat(kDeviceWidth), height: CGFloat(kDeviceHeight) - navView.frame.origin.y - navView.frame.size.height - 80 - CGFloat(SharedData.bottomSafeAreaHeight))
        
        tabBarContainer.frame = CGRect(x: 0, y: Int(kDeviceHeight) - 80 - SharedData.bottomSafeAreaHeight, width: Int(kDeviceWidth), height: 80 + SharedData.bottomSafeAreaHeight)
        
        navView.layer.cornerRadius = 12
        navView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        navView.clipsToBounds = true
        
        copyButton.layer.cornerRadius = 8
        copyButton.clipsToBounds = true
        copyButton.backgroundColor = teamColor
        
        // Add a shadow to the tabBarContainer
        let shadowPath = UIBezierPath(rect: tabBarContainer.bounds)
        tabBarContainer.layer.masksToBounds = false
        tabBarContainer.layer.shadowColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        tabBarContainer.layer.shadowOffset = CGSize(width: 0, height: -3)
        tabBarContainer.layer.shadowOpacity = 0.5
        tabBarContainer.layer.shadowPath = shadowPath.cgPath
        
        noGameLabel.isHidden = true
        bottomLabel.isHidden = true
        bottomButton.isHidden = true

        self.getAvailableTeams()
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
                
        setNeedsStatusBarAppearanceUpdate()
        
        // Add some delay so the view is partially showing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
        {
            UIView.animate(withDuration: 0.3)
            { [self] in
                fakeStatusBar.backgroundColor = UIColor(white: 0, alpha: 0.6)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
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
