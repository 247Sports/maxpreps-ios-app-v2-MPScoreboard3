//
//  ClaimAthleteSuccessViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/25/22.
//

import UIKit

class ClaimAthleteSuccessViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var teamTableView: UITableView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var claimAnotherButton: UIButton!
    
    var userIsAthlete = false
    //var searchVC = UIViewController()
    var athleteFirstName = ""
    var athleteLastName = ""
    var schoolColor = UIColor.mpRedColor()
    
    private var favoriteTeamsArray = [] as Array
    private var trackingGuid = ""
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return favoriteTeamsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 66
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
        var cell = tableView.dequeueReusableCell(withIdentifier: "ClaimAthleteTeamTableViewCell") as? ClaimAthleteTeamTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("ClaimAthleteTeamTableViewCell", owner: self, options: nil)
            cell = nib![0] as? ClaimAthleteTeamTableViewCell
        }
        
        cell?.selectionStyle = .none
        
        let favoriteTeam = favoriteTeamsArray[indexPath.row] as! Dictionary<String,Any>
        let schoolName = favoriteTeam[kNewSchoolNameKey] as! String
        let gender = favoriteTeam[kNewGenderKey] as! String
        let sport = favoriteTeam[kNewSportKey] as! String
        let level = favoriteTeam[kNewLevelKey] as! String
        
        cell?.schoolNameLabel.text = schoolName
        cell?.sportLabel.text = MiscHelper.genderSportLevelFrom(gender: gender, sport: sport, level: level)
        
        let colorString = favoriteTeam[kNewSchoolColor1Key] as! String
        cell?.initialLabel.textColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
        cell?.initialLabel.text = schoolName.first?.uppercased()
        
        let mascotUrlString = favoriteTeam[kNewSchoolMascotUrlKey] as! String
        
        if (mascotUrlString.count > 0)
        {
            // Get the data and make an image
            let url = URL(string: mascotUrlString)
            
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        cell?.initialLabel.isHidden = true
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (cell?.mascotImageView)!)
                    }
                }
            }
        }
        
        // Hide the last horiz line
        if (indexPath.row == (favoriteTeamsArray.count - 1))
        {
            cell?.horizLine.isHidden = true
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Button Methods
    
    @IBAction func continueButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popToRootViewController(animated: true)
    }
        
    @IBAction func claimAnotherButtonTouched(_ sender: UIButton)
    {
        // Tracking with the clickText property set
        TrackingManager.trackState(featureName: "claim-home", trackingGuid: trackingGuid, cData: [kTrackingClickTextKey:"claim another profile"])
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        trackingGuid = NSUUID().uuidString

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, etc.
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        
        continueButton.frame = CGRect(x: 20, y: kDeviceHeight - 101 - CGFloat(SharedData.bottomSafeAreaHeight), width: kDeviceWidth - 40, height: 42)
        claimAnotherButton.frame = CGRect(x: 20, y: kDeviceHeight - 48 - CGFloat(SharedData.bottomSafeAreaHeight), width: kDeviceWidth - 40, height: 42)
        
        if (self.userIsAthlete == true)
        {
            claimAnotherButton.isHidden = true
            
            // Shift the continue button down
            continueButton.frame = CGRect(x: 20, y: kDeviceHeight - 64 - CGFloat(SharedData.bottomSafeAreaHeight), width: kDeviceWidth - 40, height: 42)
        }
        
        continueButton.layer.cornerRadius = continueButton.frame.size.height / 2.0
        continueButton.clipsToBounds = true
        
        teamTableView.layer.cornerRadius = 12
        teamTableView.clipsToBounds = true
        
        // Load the labels na the nav color
        fakeStatusBar.backgroundColor = self.schoolColor
        navView.backgroundColor = self.schoolColor
        continueButton.backgroundColor = self.schoolColor
        
        if (self.userIsAthlete == true)
        {
            titleLabel.text = String(format: "Welcome, %@!", self.athleteFirstName)
            subtitleLabel.text = "Your career profile has been claimed and your team(s) have been added to your favorites."
        }
        else
        {
            let userFirstName = kUserDefaults.string(forKey: kUserFirstNameKey)
            titleLabel.text = String(format: "You're All Set, %@!", userFirstName!)
            subtitleLabel.text = String(format: "Your profile has been linked to %@ %@ and their team(s) have been added to your favorites.", self.athleteFirstName, self.athleteLastName)
        }
        
        favoriteTeamsArray = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)!
        
        // Set the table height to a maximum of 4 cells
        if (favoriteTeamsArray.count > 4)
        {
            teamTableView.frame = CGRect(x: 16, y: fakeStatusBar.frame.size.height + navView.frame.size.height - 33, width: kDeviceWidth - 32, height: 264)
        }
        else
        {
            let height = CGFloat(favoriteTeamsArray.count * 66)
            teamTableView.frame = CGRect(x: 16, y: fakeStatusBar.frame.size.height + navView.frame.size.height - 33, width: kDeviceWidth - 32, height: height)
        }
        
        TrackingManager.trackState(featureName: "claim-success", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
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
