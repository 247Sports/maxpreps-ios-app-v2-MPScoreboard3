//
//  SearchOpponentViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 9/25/21.
//

import UIKit

protocol SearchOpponentViewControllerDelegate: AnyObject
{
    func searchOpponentSelectSchoolTouched()
    func searchOpponentCancelButtonTouched()
}

class SearchOpponentViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate
{
    weak var delegate: SearchOpponentViewControllerDelegate?
    
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var searchContainerView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchTextFieldBackground: UIView!
    @IBOutlet weak var searchTableView: UITableView!
    
    var dimmedBackground = false
    var schoolId: String?
    var ssid: String?
    var teamLevel: String?
    var selectedSchool = School(fullName: "", name: "", schoolId: "", address: "", state: "", city: "", zip: "", searchDistance: 0.0, latitude: "", longitude: "")
    
    private var bottomTabBarPad = CGFloat(0)
    private var myTeamLatitude = ""
    private var myTeamLongitude = ""
    
    private var sortedSchools = Array<School>()
    private var specialSchools = Array<School>()
    private var filteredSchools = Array<School>()
    private var leagueSchools = Array<School>()
    
    // MARK: - Get League Schools
    
    private func getLeagueSchools()
    {
        // First get the leagueId for this team
        ScheduleFeeds.getLeaguesForTeam(schoolId: schoolId!, ssid: ssid!) { leagues, error in
            
            if (error == nil)
            {
                print("League Feed Success")
                
                /*
                 ▿ Optional<Array<Dictionary<String, Any>>>
                   ▿ some : 1 element
                     ▿ 0 : 4 elements
                       ▿ 0 : 2 elements
                         - key : "schoolId"
                         - value : c510b298-3a73-4bcf-8855-96c998d8e26e
                       ▿ 1 : 2 elements
                         - key : "leagueId"
                         - value : 9f8b6f72-a7fb-42d5-ac82-0a3d4adcd345
                       ▿ 2 : 2 elements
                         - key : "isSecondary"
                         - value : 0
                       ▿ 3 : 2 elements
                         - key : "sportSeasonId"
                         - value : 97e3f828-856d-419e-b94f-7f41319fe3d3
                 */
                
                if (leagues!.count > 0)
                {
                    var leagueId = ""
                    for item in leagues!
                    {
                        let league = item as Dictionary<String,Any>
                        let isSecondary = league["isSecondary"] as! Bool
                        
                        if (isSecondary == false)
                        {
                            leagueId = league["leagueId"] as! String
                            break
                        }
                    }
                    
                    if (leagueId.count > 0)
                    {
                        // Get the teams for this league
                        ScheduleFeeds.getTeamsForLeague(leagueId: leagueId, ssid: self.ssid!) { teams, error in
                            
                            if (error == nil)
                            {
                                print("Teams for League Feed Success")
                                
                                for team in teams!
                                {
                                    // Skip my Team
                                    let teamId = team["teamId"] as! String
                                    
                                    if (teamId == self.schoolId)
                                    {
                                        continue
                                    }
                                    
                                    let fullName = team["schoolFormattedName"] as! String
                                    let schoolName = team["schoolName"] as! String
                                    
                                    let leagueSchool = School(fullName: fullName, name: schoolName, schoolId: teamId, address: "", state: "", city: "", zip: "", searchDistance: 0.0, latitude: "", longitude: "")
                                    
                                    self.leagueSchools.append(leagueSchool)
                                }
                                
                                self.searchTableView.reloadData()
                                
                            }
                            else
                            {
                                print("Teams for League Feed Success")
                            }
                        }
                    }
                }
            }
            else
            {
                print("League Feed Failed")
            }
        }
        
        self.getMySchoolLocation()
    }
    
    // MARK: - Get My School Location
    
    private func getMySchoolLocation()
    {
        // Iterate through the allSchools to find a matching schoolId
        for school in SharedData.allSchools
        {
            if (schoolId == school.schoolId)
            {
                // Match is found
                myTeamLatitude = school.latitude
                myTeamLongitude = school.longitude
                break
            }
        }
        
        self.buildSpecialSchools()
    }
    
    // MARK: - Build Special Schools
    
    private func buildSpecialSchools()
    {
        // Build the Special Opponents
        let freshmanOpponent = School(fullName: "Freshman Opponent", name: "Freshman Opponent", schoolId: "B51244AB-A965-47E5-ADDB-4F44F26C49ED", address: "", state: "", city: "", zip: "", searchDistance: 0.0, latitude: "", longitude: "")
        
        let jvOpponent = School(fullName: "JV Opponent", name: "JV Opponent", schoolId: "73C7D62C-910C-4AB7-BDC6-ECBEB8CB3398", address: "", state: "", city: "", zip: "", searchDistance: 0.0, latitude: "", longitude: "")
        
        let varsityOpponent = School(fullName: "Varsity Opponent", name: "Varsity Opponent", schoolId: "23bae8a4-95f3-4f43-99bb-9c0a28566b66", address: "", state: "", city: "", zip: "", searchDistance: 0.0, latitude: "", longitude: "")
        
        let nonFreshmanOpponent = School(fullName: "Non Freshman Opponent", name: "Non Freshman Opponent", schoolId: "505c1a99-e49f-4daa-8ec8-355baf311697", address: "", state: "", city: "", zip: "", searchDistance: 0.0, latitude: "", longitude: "")
        
        let nonJVOpponent = School(fullName: "Non JV Opponent", name: "Non JV Opponent", schoolId: "d1bd084e-1f5b-4e7c-8f99-6c63e0e9e855", address: "", state: "", city: "", zip: "", searchDistance: 0.0, latitude: "", longitude: "")
        
        let nonVarsityOpponent = School(fullName: "Non Varsity Opponent", name: "Non Varsity Opponent", schoolId: "4fc9dcd1-3d2c-4d0a-998e-4340bac0ac02", address: "", state: "", city: "", zip: "", searchDistance: 0.0, latitude: "", longitude: "")
                
        let tournamentOpponent = School(fullName: "Tournament Opponent", name: "Tournament Opponent", schoolId: "b6e1f3f8-f345-4829-80a4-0653a9a36a1d", address: "", state: "", city: "", zip: "", searchDistance: 0.0, latitude: "", longitude: "")
        
        let nonVarsityTournamentOpponent = School(fullName: "Non Varsity Tournament Opponent", name: "Non Varsity Tournament Opponent", schoolId: "001393ea-2648-404b-8205-6e19ac70a214", address: "", state: "", city: "", zip: "", searchDistance: 0.0, latitude: "", longitude: "")
        
        let tournamentTeam = School(fullName: "Tournament Team", name: "Tournament Team", schoolId: "82f0f6a8-1232-4b30-a5a7-8cc4f32359e4", address: "", state: "", city: "", zip: "", searchDistance: 0.0, latitude: "", longitude: "")
        
        // The special schools vary with team level
        if (teamLevel == "Varsity")
        {
            specialSchools.append(varsityOpponent)
            specialSchools.append(nonVarsityOpponent)
            specialSchools.append(tournamentOpponent)
            specialSchools.append(nonVarsityTournamentOpponent)
            specialSchools.append(tournamentTeam)
        }
        else if (teamLevel == "JV")
        {
            specialSchools.append(jvOpponent)
            specialSchools.append(nonJVOpponent)
            specialSchools.append(tournamentOpponent)
            specialSchools.append(tournamentTeam)
        }
        else
        {
            specialSchools.append(freshmanOpponent)
            specialSchools.append(nonFreshmanOpponent)
            specialSchools.append(tournamentOpponent)
            specialSchools.append(tournamentTeam)
        }
        
        // The old way
        /*
        specialSchools.append(nonFreshmanOpponent)
        specialSchools.append(nonJVOpponent)
        specialSchools.append(nonVarsityOpponent)
        specialSchools.append(nonVarsityTournamentOpponent)
        specialSchools.append(tournamentOpponent)
        specialSchools.append(tournamentTeam)
        specialSchools.append(varsityOpponent)
        */
        
        sortSchoolsByDistanceFromMySchool()
    }
    
    // MARK: - Sort Schools
    
    private func sortSchoolsByDistanceFromMySchool()
    {
        sortedSchools.removeAll()
        
        let currentLocation = kUserDefaults.object(forKey: kCurrentLocationKey) as! Dictionary<String,String>
        
        // Use the user's location if a matching team couldn't be found in getMySchoolLocation()
        var centerLatitudeString = currentLocation[kLatitudeKey]
        var centerLongitudeString = currentLocation[kLongitudeKey]
        
        if (myTeamLatitude.count > 0) && (myTeamLongitude.count > 0)
        {
            centerLatitudeString = myTeamLatitude
            centerLongitudeString = myTeamLongitude
        }
        
        let centerLatitude = Float(centerLatitudeString!) ?? 0.0
        let centerLongitude = Float(centerLongitudeString!) ?? 0.0
        
        var tempSchoolsArray = [] as! Array<School>
        
        for school in SharedData.allSchools
        {
            // Skip adding MySchool
            if (school.schoolId == self.schoolId)
            {
                continue
            }
            
            let schoolLatitude = Float(school.latitude) ?? 0.0
            let schoolLongitude = Float(school.longitude) ?? 0.0
            
            let deltaLatitude = centerLatitude - schoolLatitude
            let deltaLongitude = centerLongitude - schoolLongitude
            let distanceSquared = (deltaLatitude * deltaLatitude) + (deltaLongitude * deltaLongitude)
            
            // Build new school objects with a new search distance
            let replacementSchool = School(fullName: school.fullName, name: school.name, schoolId: school.schoolId, address: school.address, state: school.state, city: school.city, zip: school.zip, searchDistance: distanceSquared, latitude: school.latitude, longitude: school.longitude)
            
            tempSchoolsArray.append(replacementSchool)
        }
        
        sortedSchools = tempSchoolsArray.sorted(by: { $0.searchDistance < $1.searchDistance })
        
        // Add the TBA school at the top
        let tbaSchool = School(fullName: "TBA", name: "TBA", schoolId: kEmptyGuid, address: "", state: "", city: "", zip: "", searchDistance: 0.0, latitude: "", longitude: "")
        
        sortedSchools.insert(tbaSchool, at: 0)
        
        searchTableView.reloadData()
    }

    // MARK: - Filter Schools
    
    private func updateTableUsingSearchFilter()
    {
        if (searchTextField.text!.count > 0)
        {
            // Filter by name
            filteredSchools.removeAll()
            
            var unsortedFilteredSchools = Array<School>()
            
            for school in SharedData.allSchools
            {
                let name = school.name.lowercased()
                
                if (name.count >= searchTextField.text!.count)
                {
                    if (name.starts(with: searchTextField.text!.lowercased()))
                    {
                        // Don't include your team
                        if (school.schoolId != self.schoolId)
                        {
                            unsortedFilteredSchools.append(school)
                        }
                    }
                }
            }
            
            // Sort
            filteredSchools = unsortedFilteredSchools.sorted(by: { $0.searchDistance < $1.searchDistance })
            
            searchTableView.reloadData()
            
            print("Filtered School Count: " + String(filteredSchools.count))
        }
        else
        {
            self.sortSchoolsByDistanceFromMySchool()
        }
    }
    
    // MARK: - TextField Delegates
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
        {
            self.updateTableUsingSearchFilter()
        }

        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
        {
            self.updateTableUsingSearchFilter()
        }
        
        return true
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if (searchTextField.text!.count > 0)
        {
            return 2
        }
        else
        {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (searchTextField.text!.count > 0)
        {
            if (section == 0)
            {
                return filteredSchools.count
            }
            else
            {
                return specialSchools.count
            }
        }
        else
        {
            if (section == 0)
            {
                return leagueSchools.count
            }
            else if (section == 1)
            {
                return sortedSchools.count
            }
            else
            {
                return specialSchools.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if (searchTextField.text?.count == 0)
        {
            if (section == 0) && (leagueSchools.count == 0)
            {
                return 0.01
            }
        }
        
        return 32.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.size.width - 40, height: 32))
        label.font = UIFont.mpSemiBoldFontWith(size: 14)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.mpLightGrayColor()
        
        if (searchTextField.text!.count > 0)
        {
            if (section == 0)
            {
                label.text = String(format: "SEARCH RESULTS (%ld)", filteredSchools.count)   //"LOCAL"
            }
            else
            {
                label.text = "SPECIAL OPPONENTS"
            }
        }
        else
        {
            if (section == 0)
            {
                // Return nil if league schools is empty since the height is 0.1
                if (leagueSchools.count > 0)
                {
                    label.text = "LEAGUE SCHOOLS"
                }
                else
                {
                    return nil
                }
            }
            else if (section == 1)
            {
                label.text = "ALL SCHOOLS"
            }
            else
            {
                label.text = "SPECIAL OPPONENTS"
            }
        }
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 32))
        view.backgroundColor = UIColor.mpHeaderBackgroundColor()
        view.addSubview(label)
        
        return view

    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if (cell == nil)
        {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        
        cell?.contentView.backgroundColor = UIColor.mpWhiteColor()
        cell?.selectionStyle = .none
        cell?.textLabel?.text = ""
        cell?.textLabel?.textColor = UIColor.mpGrayColor()
        cell?.selectionStyle = .none
        cell?.textLabel?.font = UIFont.mpRegularFontWith(size: 16)
        
        var sectionSchoolsArray = [] as! Array<School>
        
        if (searchTextField.text!.count > 0)
        {
            if (indexPath.section == 0)
            {
                sectionSchoolsArray = filteredSchools
            }
            else
            {
                sectionSchoolsArray = specialSchools
            }
        }
        else
        {
            if (indexPath.section == 0)
            {
                sectionSchoolsArray = leagueSchools
            }
            else if (indexPath.section == 1)
            {
                sectionSchoolsArray = sortedSchools
            }
            else
            {
                sectionSchoolsArray = specialSchools
            }
        }
        
        let school = sectionSchoolsArray[indexPath.row]
        
        //cell?.textLabel?.text = school.fullName
        
        let attributedString = NSMutableAttributedString(string: school.fullName)
        let range = school.fullName.range(of: school.name)
        let convertedRange = NSRange(range!, in: school.fullName)
        
        attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpBoldFontWith(size: 16), NSAttributedString.Key.foregroundColor: UIColor.mpBlackColor()], range: convertedRange)
        
        cell?.textLabel?.attributedText = attributedString
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (searchTextField.text!.count > 0)
        {
            if (indexPath.section == 0)
            {
                selectedSchool = filteredSchools[indexPath.row]
            }
            else
            {
                selectedSchool = specialSchools[indexPath.row]
            }
        }
        else
        {
            if (indexPath.section == 0)
            {
                selectedSchool = leagueSchools[indexPath.row]
            }
            else if (indexPath.section == 1)
            {
                selectedSchool = sortedSchools[indexPath.row]
            }
            else
            {
                selectedSchool = specialSchools[indexPath.row]
            }
        }
        
        self.delegate?.searchOpponentSelectSchoolTouched()
        
        //self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Button Methods
    
    @IBAction func cancelButtonTouched(_ sender: UIButton)
    {
        self.delegate?.searchOpponentCancelButtonTouched()
    }
    
    @objc func keyboardCancelButtonTouched(_ sender: UIButton)
    {
        searchTextField.resignFirstResponder()
    }
    
    // MARK: - Keyboard Notifications
    
    @objc private func keyboardDidShow(notification: Notification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            //print("Keyboard will show")
            
            // Need to subtract the tab bar height from the keyboard height
            searchTableView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height + searchContainerView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.size.height - fakeStatusBar.frame.size.height - searchContainerView.frame.size.height - keyboardSize.height)
        }
    }
    
    @objc private func keyboardDidHide(notification: Notification)
    {
        //print("Keyboard will hide")
        searchTableView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height + searchContainerView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.size.height - fakeStatusBar.frame.size.height - searchContainerView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight) - bottomTabBarPad)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if (self.tabBarController?.tabBar.isHidden == false)
        {
            bottomTabBarPad = CGFloat(kTabBarHeight)
        }

        // Size and locate the fakeStatusBar, navBar, containerScrollView, and tabBarContainer
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 76 + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        
        searchContainerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: searchContainerView.frame.size.height)
        searchTableView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height + searchContainerView.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: CGFloat(kDeviceHeight) - navView.frame.size.height - searchContainerView.frame.size.height - fakeStatusBar.frame.size.height - 12 - CGFloat(SharedData.bottomSafeAreaHeight) - bottomTabBarPad)
        
        navView.layer.cornerRadius = 12
        navView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        navView.clipsToBounds = true
        
        searchTextFieldBackground.layer.cornerRadius = 8
        searchTextFieldBackground.layer.borderWidth = 1
        searchTextFieldBackground.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        searchTextFieldBackground.clipsToBounds = true
        
        self.getLeagueSchools()
        
        // Add the keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        if (dimmedBackground == true)
        {
            // Add some delay so the view is partially showing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
            {
                UIView.animate(withDuration: 0.3)
                { [self] in
                    fakeStatusBar.backgroundColor = UIColor(white: 0, alpha: 0.6)
                }
            }
        }
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
