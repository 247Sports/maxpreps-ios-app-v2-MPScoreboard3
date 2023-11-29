//
//  RestoreDeletedGameViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/4/21.
//

import UIKit

protocol RestoreDeletedGameViewControllerDelegate: AnyObject
{
    func restoreGameRestoreButtonTouched()
    func restoreGameCancelButtonTouched()
}

class RestoreDeletedGameViewController: UIViewController, UITextFieldDelegate
{
    weak var delegate: RestoreDeletedGameViewControllerDelegate?
    
    var selectedTeam : Team!
    var selectedGame : Dictionary<String,Any>!
    var ssid : String?
    var gameTypeAliases : Array<String>?
    var gameRestored = false
    
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var homeAwayTextField: UITextField!
    @IBOutlet weak var gameTypeTextField: UITextField!
    @IBOutlet weak var opponentTextField: UITextField!
    
    @IBOutlet weak var gameDetailsContainerView: UIView!
    @IBOutlet weak var gameDetailsTextView: UITextView!
    
    @IBOutlet weak var tabBarContainer: UIView!
    @IBOutlet weak var restoreButton: UIButton!

    private var teamColor = UIColor.mpRedColor()
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Load User Interface
    
    private func loadUserInterface()
    {
        let contest = selectedGame["contest"] as! Dictionary<String,Any>
        
        // Get the dateCode to decide how to set the dateLabel and timeLabel
        let dateCode = contest["dateCode"] as! Int
        /*
         Default = 0,
         DateTBA = 1,
         TimeTBA = 2,
         DateTimeTBA = 4
         */
        
        var contestDateString = contest["date"] as? String ?? "1901-01-01T00:00:00"
        contestDateString = contestDateString.replacingOccurrences(of: "Z", with: "")
        let dateFormatter = DateFormatter()
        dateFormatter.isLenient = true
        dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
        let contestDate = dateFormatter.date(from: contestDateString)
        
        switch dateCode
        {
        case 0: // Default
            dateFormatter.dateFormat = "EEEE, MMM d"
            let dateString = dateFormatter.string(from: contestDate!)
            let todayString = dateFormatter.string(from: Date())
            
            if (todayString == dateString)
            {
                dateTextField.text = "Today"
            }
            else
            {
                dateTextField.text = dateString
            }
            
            dateFormatter.dateFormat = "h:mm a"
            timeTextField.text = dateFormatter.string(from: contestDate!)
            
        case 1: // DateTBA
            dateTextField.text = "TBA"
            dateFormatter.dateFormat = "h:mm a"
            timeTextField.text = dateFormatter.string(from: contestDate!)
            
        case 2: // TimeTBA
            dateFormatter.dateFormat = "EEEE, MMM d"
            let dateString = dateFormatter.string(from: contestDate!)
            let todayString = dateFormatter.string(from: Date())
            
            if (todayString == dateString)
            {
                dateTextField.text = "Today"
            }
            else
            {
                dateTextField.text = dateString
            }
            
            timeTextField.text = "TBA"
            
        default:
            dateTextField.text = "TBA"
            timeTextField.text = "TBA"
        }
        
        // Find the opponent
        var opponentTeam: Dictionary<String,Any>
        let teams = contest["teams"] as! Array<Dictionary<String,Any>>
        let teamA = teams.first
        let teamB = teams.last
        let teamASchoolId = teamA!["teamId"] as? String ?? ""
        
        if (teamASchoolId == selectedTeam!.schoolId)
        {
            opponentTeam = teamB!
        }
        else
        {
            opponentTeam = teamA!
        }
        
        // Load the gameDetailLabel
        let haType = opponentTeam["homeAwayType"] as! Int
        var homeAwayString = ""
        
        switch haType
        {
        case 0:
            homeAwayString = "Away"
        case 1:
            homeAwayString = "Home"
        case 2:
            homeAwayString = "Neutral"
        default:
            homeAwayString = "Unknown"
        }
        
        homeAwayTextField.text = homeAwayString
        
        // Load the contest type
        let contestType = opponentTeam["contestType"] as! Int
        let contestTypeString = self.gameTypeAliases![contestType]
        /*
        switch contestType
        {
        case 0:
            contestTypeString = "Conference"
        case 1:
            contestTypeString = "Non-Conference"
        case 2:
            contestTypeString = "Tournament"
        case 3:
            contestTypeString = "Exhibition"
        case 4:
            contestTypeString = "Playoff"
        case 5:
            contestTypeString = "Conference Tournament"
        default:
            contestTypeString = "Unknown"
        }
        */
        
        gameTypeTextField.text = contestTypeString
        
        // Load the opponent's name
        let tbaTeam = opponentTeam["isTeamTBA"] as! Bool
        if (tbaTeam == true)
        {
            opponentTextField.text = "TBA"
        }
        else
        {
            // Load the initial text and color
            let opponentName = opponentTeam["name"] as! String
            opponentTextField.text = opponentName
        }
        
        // Set the game details text view
        if (contest["location"] is NSNull)
        {

        }
        else
        {
            let location = contest["location"] as! String
            gameDetailsTextView.text = location
        }

    }
    
    // MARK: - TextField Delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        return false
    }
    
    // MARK: - Button Methods
    
    @IBAction func cancelButtonTouched(_ sender: UIButton)
    {
        self.delegate?.restoreGameCancelButtonTouched()
    }

    @IBAction func restoreButtonTouched(_ sender: UIButton)
    {
        // Call the feed
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        let contest = selectedGame["contest"] as! Dictionary<String,Any>
        let contestId = contest["contestId"] as! String
        
        ScheduleFeeds.restoreSecureContest(schoolId: selectedTeam!.schoolId, ssid: self.ssid!, contestId: contestId) { result, error in
            
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
                print("Restore Contest Successful")
                
                var message = "Game Restored"
                
                if (MiscHelper.sportUsesMatchInsteadOfGame(sport: self.selectedTeam!.sport) == true)
                {
                    message = "Match Restored"
                }
                
                OverlayView.showPopupOverlay(withMessage: message)
                {
                    self.gameRestored = true
                    self.delegate?.restoreGameRestoreButtonTouched()
                }
            }
            else
            {
                print("Restore Contest Failed")
                
                var message = "Something went wrong when trying to restore this game."
                
                if (MiscHelper.sportUsesMatchInsteadOfGame(sport: self.selectedTeam!.sport) == true)
                {
                    message = "Something went wrong when trying to restore this match."
                }
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: message, lastItemCancelType: false) { tag in
                    
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
 
        // Size and locate the fakeStatusBar, navBar, containerScrollView, and tabBarContainer
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 76 + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        
        let scrollViewHeight = Int(kDeviceHeight) - Int(fakeStatusBar.frame.size.height) - Int(navView.frame.size.height) + 12 - 80 - Int(SharedData.bottomSafeAreaHeight)
        
        containerScrollView.frame = CGRect(x: 0, y: Int(fakeStatusBar.frame.size.height) + Int(navView.frame.size.height) - 12, width: Int(kDeviceWidth), height: scrollViewHeight)
        tabBarContainer.frame = CGRect(x: 0, y: Int(kDeviceHeight) - 80 - SharedData.bottomSafeAreaHeight, width: Int(kDeviceWidth), height: 80 + SharedData.bottomSafeAreaHeight)
        
        containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: gameDetailsContainerView.frame.origin.y + gameDetailsContainerView.frame.size.height)
        
        navView.layer.cornerRadius = 12
        navView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        navView.clipsToBounds = true
        
        gameDetailsTextView.layer.cornerRadius = 6
        gameDetailsTextView.layer.borderWidth = 0.5
        gameDetailsTextView.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        gameDetailsTextView.clipsToBounds = true
        
        restoreButton.layer.cornerRadius = 8
        restoreButton.clipsToBounds = true
        restoreButton.backgroundColor = teamColor
        
        // Add a shadow to the tabBarContainer
        let shadowPath = UIBezierPath(rect: tabBarContainer.bounds)
        tabBarContainer.layer.masksToBounds = false
        tabBarContainer.layer.shadowColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        tabBarContainer.layer.shadowOffset = CGSize(width: 0, height: -3)
        tabBarContainer.layer.shadowOpacity = 0.5
        tabBarContainer.layer.shadowPath = shadowPath.cgPath
        
        self.loadUserInterface()
        
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
