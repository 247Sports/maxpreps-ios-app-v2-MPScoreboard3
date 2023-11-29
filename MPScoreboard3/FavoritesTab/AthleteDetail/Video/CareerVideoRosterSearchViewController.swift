//
//  CareerVideoRosterSearchViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 11/8/22.
//

import UIKit

class CareerVideoRosterSearchViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, CareerVideoTeamPickerViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchBackgroundView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var rosterTableView: UITableView!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var genderSportLabel: UILabel!
    @IBOutlet weak var teamSelectorButton: UIButton!
    @IBOutlet weak var noRosterView: UIView!
    @IBOutlet weak var noRosterMessageLabel: UILabel!
    @IBOutlet weak var changeSeasonsButton: UIButton!
    
    var selectedAthlete : Athlete?
    var taggedAthletes = [] as! Array<Any>
    
    private var careerTeams = [] as Array<Dictionary<String,Any>>
    private var allRosterAthletes = [] as Array<RosterAthlete>
    private var filteredRosterAthletes = [] as Array<RosterAthlete>
    private var selectedTeamIndex = 0
    private var teamPickerViewVisible = false
    
    private var progressOverlay: ProgressHUD!
    private var teamPickerView: CareerVideoTeamPickerView!
    
    // MARK: - Get Career Teams
    
    private func getCareerTeams()
    {
        NewFeeds.getCareerTeams(careerId: selectedAthlete!.careerId) { teams, error in
            
            if (error == nil)
            {
                if (teams!.count == 0)
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "We couldn't find any teams for this career.", lastItemCancelType: false) { tag in
                        
                    }
                }
                else
                {
                    self.careerTeams = teams!
                    self.getRoster()
                    
                    let careerTeam = self.careerTeams[0]
                    let schoolName = careerTeam["schoolName"] as? String ?? ""
                    let gender = careerTeam["gender"] as? String ?? ""
                    let sport = careerTeam["sport"] as? String ?? ""
                    let level = careerTeam["level"] as? String ?? ""
                    let year = careerTeam["year"] as? String ?? ""
                    let season = careerTeam["season"] as? String ?? ""
                    
                    self.schoolNameLabel.text = schoolName
                    
                    let genderSportLevel = MiscHelper.genderSportLevelFrom(gender: gender, sport: sport, level: level)
                    
                    if (sport.lowercased() == "soccer")
                    {
                        self.genderSportLabel.text = String(format: "%@ (%@ %@)", genderSportLevel, season, year)
                    }
                    else
                    {
                        self.genderSportLabel.text = String(format: "%@ (%@)", genderSportLevel, year)
                    }
                    
                    if (self.careerTeams.count > 1)
                    {
                        self.teamSelectorButton.isHidden = false
                    }
                }
            }
            else
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "There seems to be a problem locating the teams for this career.", lastItemCancelType: false) { tag in
                    
                }
            }
        } 
    }
    
    // MARK: - Get Roster
    
    private func getRoster()
    {
        let careerTeam = careerTeams[selectedTeamIndex]
        
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        let schoolId = careerTeam["teamId"] as! String
        let ssid = careerTeam["sportSeasonId"] as! String
        
        RosterFeeds.getPublicRosters(teamId: schoolId, ssid: ssid, sort: "0") { athletes, deletedAthletes, staff, teamPhotoUrl, error in
            
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                //MBProgressHUD.hide(for: self, animated: true)
                if (self.progressOverlay != nil)
                {
                    self.progressOverlay.hide(animated: false)
                    self.progressOverlay = nil
                }
            }
            
            if (error == nil)
            {
                self.allRosterAthletes = athletes!
                self.filteredRosterAthletes = athletes!
                
                if (self.allRosterAthletes.count == 0)
                {
                    // Show the empty roster overlay
                    self.noRosterView.isHidden = false
                    
                    let year = careerTeam["year"] as! String
                    self.noRosterMessageLabel.text = String(format: "The 20%@ roster has not been entered. Try changing seasons.", year)
                }
                else
                {
                    // Hide the empty roster overlay
                    self.noRosterView.isHidden = true
                }
            }
            else
            {
                /*
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "There seems to be a problem locating the roster for this year.", lastItemCancelType: false) { tag in
                    
                }
                */
                // Show the empty roster overlay
                self.noRosterView.isHidden = false
                
                let year = careerTeam["year"] as! String
                self.noRosterMessageLabel.text = String(format: "The 20%@ roster has not been entered. Try changing seasons.", year)
                
                self.allRosterAthletes = []
                self.filteredRosterAthletes = []
            }
            
            self.rosterTableView.reloadData()
        }
    }
    
    // MARK: - Add/Remove Tagged Athletes
    
    private func addAthlete(_ athlete: RosterAthlete, selectedIndexPath: IndexPath)
    {
        // Refactor the RosterAthlete object into an Athlete object
        // The school info comes from the careerTeams array
        let careerTeam = careerTeams[selectedTeamIndex]
        let schoolName = careerTeam["schoolName"] as? String ?? ""
        let schoolState = careerTeam["schoolState"] as? String ?? ""
        let schoolCity = careerTeam["schoolCity"] as? String ?? ""
        let schoolId = careerTeam["teamId"] as? String ?? ""
        let schoolColor = careerTeam["schoolColor"] as? String ?? ""
        let schoolMascotUrl = careerTeam["schoolMascotUrl"] as? String ?? ""
        
        let selectedAthlete = Athlete(firstName: athlete.firstName, lastName: athlete.lastName, schoolName: schoolName, schoolState: schoolState, schoolCity: schoolCity, schoolId: schoolId, schoolColor: schoolColor, schoolMascotUrl: schoolMascotUrl, careerId: athlete.careerId, photoUrl: athlete.photoUrl)
        
        taggedAthletes.append(selectedAthlete)
        
        // Reload the tableView Cell
        rosterTableView.reloadRows(at: [selectedIndexPath], with: .automatic)
    }
    
    private func removeAthlete(_ careerId: String, selectedIndexPath: IndexPath)
    {
        // Find the athlete in the taggedAthlete array so it can be removed
        var index = 0
        var matchFound = false
        for item in taggedAthletes
        {
            let taggedAthlete = item as! Athlete
            if (taggedAthlete.careerId == careerId)
            {
                matchFound = true
                break
            }
            index += 1
        }
        
        if (matchFound == true)
        {
            taggedAthletes.remove(at: index)
        }
        
        // Reload the tableView Cell
        rosterTableView.reloadRows(at: [selectedIndexPath], with: .automatic)
    }
    
    // MARK: - Filter Roster Method
    
    private func filterRoster()
    {
        if (searchTextField.text!.count > 0)
        {
            // Filter by name
            filteredRosterAthletes.removeAll()
                        
            for rosterAthlete in allRosterAthletes
            {
                let fullName = String(format: "%@ %@", rosterAthlete.firstName.lowercased(), rosterAthlete.lastName.lowercased())
                
                if (fullName.count >= searchTextField.text!.count)
                {
                    //if (fullName.starts(with: searchTextField.text!.lowercased()))
                    if (fullName.contains(searchTextField.text!.lowercased()))
                    {
                        filteredRosterAthletes.append(rosterAthlete)
                    }
                }
            }

            print("Filtered Roster Count: " + String(filteredRosterAthletes.count))
        }
        else
        {
            filteredRosterAthletes = allRosterAthletes
        }
        
        rosterTableView.reloadData()
    }
    
    // MARK: - TextField Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
        {
            self.filterRoster()
        }

        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
        {
            self.filterRoster()
        }
        
        return true
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return filteredRosterAthletes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 58.0
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
        var cell = tableView.dequeueReusableCell(withIdentifier: "TaggedRosterAthleteTableViewCell") as? TaggedRosterAthleteTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("TaggedRosterAthleteTableViewCell", owner: self, options: nil)
            cell = nib![0] as? TaggedRosterAthleteTableViewCell
        }
        
        cell?.selectionStyle = .none
        
        cell?.athleteImageView.image = UIImage(named: "Avatar")
        cell?.selectedAthleteImageView.image = UIImage(named: "RadioButtonOff")
        cell?.obscuredView.isHidden = true
        
        let athlete = filteredRosterAthletes[indexPath.row]
        cell?.nameLabel.text = String(format: "%@ %@", athlete.firstName, athlete.lastName)
        cell?.jerseyLabel.text = athlete.jersey
        
        let careerId = athlete.careerId
        
        if (careerId == selectedAthlete?.careerId)
        {
            cell?.obscuredView.isHidden = false
        }
        
        // Iterate through the taggedAthletes array to set the radio button image
        var matchFound = false
        
        for item in taggedAthletes
        {
            let taggedAthlete = item as! Athlete
            
            if (taggedAthlete.careerId == careerId)
            {
                matchFound = true
                break
            }
        }
        
        if (matchFound == true)
        {
            cell?.selectedAthleteImageView.image = UIImage(named: "RadioButtonOn")
        }
        
        // Load the photo
        let photoUrl = athlete.photoUrl
        print(photoUrl)
        print("Done")
        
        // Load the photo
        if (photoUrl.count > 0)
        {
            let url = URL(string: athlete.photoUrl)
            
            // Get the data and make an image
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        cell?.athleteImageView.image = image
                    }
                }
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let athlete = filteredRosterAthletes[indexPath.row]
        
        // Don't allow the selectedAthlete to be deselected
        if (athlete.careerId == selectedAthlete?.careerId)
        {
            return
        }
                
        // Iterate through the taggedAthletes array to determine if the athlete should be added or removed
        var matchFound = false
        
        for item in taggedAthletes
        {
            let taggedAthlete = item as! Athlete
            
            if (taggedAthlete.careerId == athlete.careerId)
            {
                matchFound = true
                break
            }
        }
        
        if (matchFound == true)
        {
            // Remove this athlete from the taggedAthletes array
            self.removeAthlete(athlete.careerId, selectedIndexPath: indexPath)
        }
        else
        {
            // Add this athlete to the taggedAthletes array
            self.addAthlete(athlete, selectedIndexPath: indexPath)
        }
    }
    
    // MARK: - CareerVideoTeamPickerView Delegate
    
    func careerVideoTeamPickerViewDidSelectItem(index: Int)
    {
        if (teamPickerView != nil)
        {
            teamPickerView.removeFromSuperview()
            teamPickerView = nil
        }
        
        // Don't do anything if the selected team didn't change
        if (selectedTeamIndex != index)
        {
            selectedTeamIndex = index
            self.getRoster()
            
            let careerTeam = self.careerTeams[index]
            let schoolName = careerTeam["schoolName"] as? String ?? ""
            let gender = careerTeam["gender"] as? String ?? ""
            let sport = careerTeam["sport"] as? String ?? ""
            let level = careerTeam["level"] as? String ?? ""
            let year = careerTeam["year"] as? String ?? ""
            let season = careerTeam["season"] as? String ?? ""
            
            schoolNameLabel.text = schoolName
            
            let genderSportLevel = MiscHelper.genderSportLevelFrom(gender: gender, sport: sport, level: level)
            
            if (sport.lowercased() == "soccer")
            {
                genderSportLabel.text = String(format: "%@ (%@ %@)", genderSportLevel, season, year)
            }
            else
            {
                genderSportLabel.text = String(format: "%@ (%@)", genderSportLevel, year)
            }
        }
        
        UIView.animate(withDuration: 0.33, animations: {
            
            // Rotate the button back
            self.teamSelectorButton.transform = CGAffineTransform(rotationAngle: 0)
        })
        { (finished) in
            
            self.teamPickerViewVisible = false
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func doneButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func teamSelectorButtonTouched(_ sender: UIButton)
    {
        if (teamPickerViewVisible == true)
        {
            return
        }
        
        searchTextField.text = ""
        
        let buttonFrame = CGRect(x: teamSelectorButton.frame.origin.x, y: navView.frame.origin.y + teamSelectorButton.frame.origin.y, width: teamSelectorButton.frame.size.width, height: teamSelectorButton.frame.size.height)
        
        teamPickerView = CareerVideoTeamPickerView(frame: CGRect(x: 0, y: 00, width: kDeviceWidth, height: kDeviceHeight), careerTeams: careerTeams, index: selectedTeamIndex, buttonFrame: buttonFrame)
        teamPickerView.delegate = self
        
        self.view.addSubview(teamPickerView)
        teamPickerViewVisible = true
        
        // Rotate the button
        UIView.animate(withDuration: 0.33, animations: {

            self.teamSelectorButton.transform = CGAffineTransform(rotationAngle: .pi * 0.999)
        })
        { (finished) in
            
        }
    }
    
    // MARK: - Keyboard Notifications
    
    @objc private func keyboardDidShow(notification: Notification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            //print("Keyboard Height: " + String(Int(keyboardSize.size.height)))
            containerView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height - keyboardSize.size.height)
        }
    }
    
    @objc private func keyboardDidHide(notification: Notification)
    {
        //print("Keyboard will hide")
        containerView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight))
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Size the fakeStatusBar, navBar, and containerView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        containerView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight))
        
        searchBackgroundView.layer.cornerRadius = 8
        searchBackgroundView.clipsToBounds = true
        
        schoolNameLabel.text = ""
        genderSportLabel.text = ""
        teamSelectorButton.isHidden = true
        
        changeSeasonsButton.layer.cornerRadius = 8
        changeSeasonsButton.layer.borderWidth = 1
        changeSeasonsButton.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        changeSeasonsButton.clipsToBounds = true
        
        noRosterView.isHidden = true
        
        // Add the keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.getCareerTeams()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
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

    deinit
    {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
