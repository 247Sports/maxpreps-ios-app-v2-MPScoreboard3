//
//  TeamSelectorViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/10/21.
//

import UIKit

class TeamSelectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ThreeSegmentControlViewDelegate
{
    var selectedSchool : School?
    var selectedTeam : Team?
    var favoriteSaved = false
    var teamDetailViewControllerIsParent = false
    var teamDetailCurrentSport = ""
    var teamDetailCurrentGender = ""
    var teamDetailCurrentTeamLevel = ""
    var teamDetailCurrentSeason = ""
    
    private var cellFullSize = false
    private var selectedCellIndex = -1
    
    private var favorites = [] as Array
    private var varsityTeams = [] as Array
    private var jvTeams = [] as Array
    private var freshmanTeams = [] as Array
    private var selectedTeamsArray = [] as Array
    private var boysTeamsArray = [] as Array
    private var girlsTeamsArray = [] as Array
    private var favoriteTeamIdentifierArray = [] as Array
    
    private var threeSegmentControl : ThreeSegmentControlView?
    private var teamDetailVC: TeamDetailViewController!
    
    private var trackingGuid = ""
    
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var teamTableView: UITableView!
    @IBOutlet weak var mascotContainerView: UIView!
    @IBOutlet weak var teamLetterLabel: UILabel!
    @IBOutlet weak var mascotImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    // MARK: - Get Available Teams
    
    private func getAvailableTeams(schoolId : String)
    {
        NewFeeds.getAvailableTeamsForSchool(schoolId: schoolId) { (availableTeams, error) in

            if error == nil
            {
                print("Download available teams success")
                
                let colorString = availableTeams![kNewSchoolInfoColor1Key] as! String
                let mascotUrl = availableTeams![kNewSchoolInfoMascotUrlKey] as! String
                let schoolId = self.selectedSchool?.schoolId
                let schoolName = self.selectedSchool?.name
                let schoolFullName = self.selectedSchool?.fullName
                let schoolState = self.selectedSchool?.state
                
                // Add the team color and mascotUrl to the selectedTeam object
                self.selectedTeam?.teamColor = colorString
                self.selectedTeam?.mascotUrl = mascotUrl
                
                let teamColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
                
                self.fakeStatusBar.backgroundColor = teamColor
                self.navView.backgroundColor = teamColor
                
                // Tracking
                var cData = kEmptyTrackingContextData
                
                cData[kTrackingSchoolNameKey] = schoolName
                cData[kTrackingTeamIdKey] = schoolId
                cData[kTrackingSchoolStateKey] = schoolState
                
                TrackingManager.trackState(featureName: "search-teams-results", trackingGuid: self.trackingGuid, cData: cData)
                
                
                // Add this team to the SchoolInfoDictionary in prefs
                var schoolInfo = kUserDefaults.dictionary(forKey: kNewSchoolInfoDictionaryKey)
                
                let newSchoolData = [kNewSchoolInfoMascotUrlKey:mascotUrl, kNewSchoolInfoColor1Key:colorString, kNewSchoolInfoSchoolIdKey:schoolId, kNewSchoolInfoNameKey:schoolName, kNewSchoolInfoFullNameKey:schoolFullName]
                
                schoolInfo?.updateValue(newSchoolData, forKey: schoolId!)
                
                // Update prefs with the data
                kUserDefaults.setValue(schoolInfo, forKey: kNewSchoolInfoDictionaryKey)
                
                if (mascotUrl.count > 0)
                {
                    let url = URL(string: mascotUrl)
                    
                    MiscHelper.getData(from: url!) { data, response, error in
                        guard let data = data, error == nil else { return }
                        
                        DispatchQueue.main.async()
                        {
                            //self.mascotImageView.image = UIImage(data: data)
                            self.teamLetterLabel.isHidden = true
                            self.mascotImageView.isHidden = false
                            
                            let image = UIImage(data: data)
                                                        
                            if (image != nil)
                            {
                                // Render the mascot using this helper
                                MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: self.mascotImageView)
                            }
                            else
                            {
                                // Show the first letter instead
                                let name = self.selectedSchool!.name
                                let initial = String(name.prefix(1))
                                self.teamLetterLabel.text = initial;
                                
                                //let color = UIColor.init(hexString: colorString, alpha: 1)
                                let color = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
                                self.teamLetterLabel.textColor = color
                                self.teamLetterLabel.isHidden = false
                                self.mascotImageView.isHidden = true
                            }
                        }
                    }
                }
                else
                {
                    // Show the first letter instead
                    let name = self.selectedSchool!.name
                    let initial = String(name.prefix(1))
                    self.teamLetterLabel.text = initial;
                    
                    //let color = UIColor.init(hexString: colorString, alpha: 1)
                    let color = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
                    self.teamLetterLabel.textColor = color
                    self.teamLetterLabel.isHidden = false
                    self.mascotImageView.isHidden = true
                }
                
                // Fill the team sport arrays
                let teams = availableTeams!["teams"] as! Array<Dictionary<String,Any>>
                
                for teamLevel in teams
                {
                    let level = teamLevel["level"] as! String
                    
                    if (level == "Varsity")
                    {
                        self.varsityTeams = teamLevel["allSeasonSports"] as! Array<Dictionary<String,Any>>
                    }
                    
                    if (level == "JV")
                    {
                        self.jvTeams = teamLevel["allSeasonSports"] as! Array<Dictionary<String,Any>>
                    }
                    
                    if (level == "Freshman")
                    {
                        self.freshmanTeams = teamLevel["allSeasonSports"] as! Array<Dictionary<String,Any>>
                    }
                }
                
                // Pick which array to use
                switch self.threeSegmentControl?.selectedSegment
                {
                case 0:
                    self.selectedTeamsArray = self.varsityTeams
                case 1:
                    self.selectedTeamsArray = self.jvTeams
                case 2:
                    self.selectedTeamsArray = self.freshmanTeams
                default:
                    break
                }
                
                self.boysTeamsArray.removeAll()
                self.girlsTeamsArray.removeAll()
                
                // Break the teams into boys and girls
                for team in self.selectedTeamsArray
                {
                    let item = team  as! Dictionary<String, Any>
                    let gender = item[kNewGenderKey] as! String
                    let sport = item[kNewSportKey] as! String
                    let teamLevel = item[kNewLevelKey] as! String
                    let season = item[kNewSeasonKey] as! String
                    
                    // Must be unique so go ahead and add the team
                    if (gender == "Boys")
                    {
                        // Skip the team that matches the initial team (if it was set)
                        if ((self.teamDetailCurrentGender == gender) && (self.teamDetailCurrentSport == sport) && (self.teamDetailCurrentTeamLevel == teamLevel) && (self.teamDetailCurrentSeason == season))
                        {
                            continue
                        }
                        self.boysTeamsArray.append(item)
                    }
                    else
                    {
                        // Skip the team that matches the initial team (if it was set)
                        if ((self.teamDetailCurrentGender == gender) && (self.teamDetailCurrentSport == sport) && (self.teamDetailCurrentTeamLevel == teamLevel) && (self.teamDetailCurrentSeason == season))
                        {
                            continue
                        }
                        self.girlsTeamsArray.append(item)
                    }
                }
                
                self.teamTableView.reloadData()
            }
            else
            {
                print("Download available teams error")
                
                self.fakeStatusBar.backgroundColor = UIColor.mpLightGrayColor()
                self.navView.backgroundColor = UIColor.mpLightGrayColor()
                
                let name = self.selectedSchool!.name
                let initial = String(name.prefix(1))
                self.teamLetterLabel.text = initial;
                self.teamLetterLabel.isHidden = false
                self.mascotImageView.isHidden = true
            }
        }
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if (boysTeamsArray.count > 0) && (girlsTeamsArray.count > 0)
        {
            return 2
        }
        else if (boysTeamsArray.count > 0) && (girlsTeamsArray.count == 0)
        {
            return 1
        }
        else if (boysTeamsArray.count == 0) && (girlsTeamsArray.count > 0)
        {
            return 1
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (boysTeamsArray.count > 0) && (girlsTeamsArray.count > 0)
        {
            if (section == 0)
            {
                return boysTeamsArray.count
            }
            else
            {
                return girlsTeamsArray.count
            }
        }
        else if (boysTeamsArray.count > 0) && (girlsTeamsArray.count == 0)
        {
            return boysTeamsArray.count
        }
        else if (boysTeamsArray.count == 0) && (girlsTeamsArray.count > 0)
        {
            return girlsTeamsArray.count
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 44
        
        /*
        if ((selectedCellIndex == indexPath.row) && cellFullSize == true)
        {
            return 170.0
        }
        else
        {
            return 44.0
        }
        */
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        var title = ""
        
        if (boysTeamsArray.count > 0) && (girlsTeamsArray.count > 0)
        {
            if (section == 0)
            {
                title = "BOYS"
            }
            else
            {
                title = "GIRLS"
            }
        }
        else if (boysTeamsArray.count > 0) && (girlsTeamsArray.count == 0)
        {
            title = "BOYS";
        }
        else if (boysTeamsArray.count == 0) && (girlsTeamsArray.count > 0)
        {
            title = "GIRLS"
        }
        else
        {
            return nil
        }
        
        let label = UILabel(frame: CGRect(x: 20, y: 12, width: tableView.frame.size.width - 40, height: 32))
        label.font = UIFont.mpRegularFontWith(size: 14)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.mpLightGrayColor()
        label.text = title
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44))
        view.backgroundColor = UIColor.mpWhiteColor()
        view.addSubview(label)

        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "TeamSelectorTableViewCell") as? TeamSelectorTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("TeamSelectorTableViewCell", owner: self, options: nil)
            cell = nib![0] as? TeamSelectorTableViewCell
        }

        cell?.selectionStyle = .none
        cell?.titleLabel.text = ""
        cell?.seasonLabel.text = ""
        cell?.sportImageView.image = nil
        
        let teamColor = ColorHelper.color(fromHexString: self.selectedTeam?.teamColor, colorCorrection: true)
        cell?.starImageView.tintColor = teamColor
        cell?.starImageView.isHidden = true

        
        let schoolId = (self.selectedTeam?.schoolId)!
        
        if (boysTeamsArray.count > 0) && (girlsTeamsArray.count > 0)
        {
            if (indexPath.section == 0)
            {
                let item = boysTeamsArray[indexPath.row] as! Dictionary<String, Any>
                
                let gender = item[kNewGenderKey] as! String
                let sport = item[kNewSportKey] as! String
                let teamLevel = item[kNewLevelKey] as! String
                let season = item[kNewSeasonKey] as! String
                
                cell?.titleLabel?.text = sport
                cell?.seasonLabel.text = season
                cell?.sportImageView.image = MiscHelper.getImageForSport(sport)
                
                // Shift the star to the right of the title text
                let font = cell?.titleLabel.font
                let textWidth = sport.widthOfString(usingFont: font!)
                
                cell?.starImageView.frame = CGRect(x: (cell?.titleLabel.frame.origin.x)! + textWidth + 10, y: (cell?.starImageView.frame.origin.y)!, width: (cell?.starImageView.frame.size.width)!, height: (cell?.starImageView.frame.size.height)!)
                
                let identifier = String(format: "%@_%@_%@_%@_%@", schoolId, gender, sport, teamLevel, season)
                
                let result = favoriteTeamIdentifierArray.filter { $0 as! String == identifier }
                if (!result.isEmpty)
                {
                    cell?.starImageView.isHidden = false
                }
            }
            else
            {
                let item = girlsTeamsArray[indexPath.row] as! Dictionary<String, Any>
                
                let gender = item[kNewGenderKey] as! String
                let sport = item[kNewSportKey] as! String
                let teamLevel = item[kNewLevelKey] as! String
                let season = item[kNewSeasonKey] as! String
                
                cell?.titleLabel?.text = sport
                cell?.seasonLabel.text = season
                cell?.sportImageView.image = MiscHelper.getImageForSport(sport)
                
                // Shift the star to the right of the title text
                let font = cell?.titleLabel.font
                let textWidth = sport.widthOfString(usingFont: font!)
                
                cell?.starImageView.frame = CGRect(x: (cell?.titleLabel.frame.origin.x)! + textWidth + 10, y: (cell?.starImageView.frame.origin.y)!, width: (cell?.starImageView.frame.size.width)!, height: (cell?.starImageView.frame.size.height)!)
                
                let identifier = String(format: "%@_%@_%@_%@_%@", schoolId, gender, sport, teamLevel, season)
                
                let result = favoriteTeamIdentifierArray.filter { $0 as! String == identifier }
                if (!result.isEmpty)
                {
                    cell?.starImageView.isHidden = false
                }
            }
        }
        else if (boysTeamsArray.count > 0) && (girlsTeamsArray.count == 0)
        {
            if (indexPath.section == 0)
            {
                let item = boysTeamsArray[indexPath.row] as! Dictionary<String, Any>
                
                let gender = item[kNewGenderKey] as! String
                let sport = item[kNewSportKey] as! String
                let teamLevel = item[kNewLevelKey] as! String
                let season = item[kNewSeasonKey] as! String
                
                cell?.titleLabel?.text = sport
                cell?.seasonLabel.text = season
                cell?.sportImageView.image = MiscHelper.getImageForSport(sport)
                
                // Shift the star to the right of the title text
                let font = cell?.titleLabel.font
                let textWidth = sport.widthOfString(usingFont: font!)
                
                cell?.starImageView.frame = CGRect(x: (cell?.titleLabel.frame.origin.x)! + textWidth + 10, y: (cell?.starImageView.frame.origin.y)!, width: (cell?.starImageView.frame.size.width)!, height: (cell?.starImageView.frame.size.height)!)
                
                let identifier = String(format: "%@_%@_%@_%@_%@", schoolId, gender, sport, teamLevel, season)
                
                let result = favoriteTeamIdentifierArray.filter { $0 as! String == identifier }
                if (!result.isEmpty)
                {
                    cell?.starImageView.isHidden = false
                }
            }
        }
        else if (boysTeamsArray.count == 0) && (girlsTeamsArray.count > 0)
        {
            if (indexPath.section == 0)
            {
                let item = girlsTeamsArray[indexPath.row] as! Dictionary<String, Any>
                
                let gender = item[kNewGenderKey] as! String
                let sport = item[kNewSportKey] as! String
                let teamLevel = item[kNewLevelKey] as! String
                let season = item[kNewSeasonKey] as! String
                
                cell?.titleLabel?.text = sport
                cell?.seasonLabel.text = season
                cell?.sportImageView.image = MiscHelper.getImageForSport(sport)
                
                // Shift the star to the right of the title text
                let font = cell?.titleLabel.font
                let textWidth = sport.widthOfString(usingFont: font!)
                
                cell?.starImageView.frame = CGRect(x: (cell?.titleLabel.frame.origin.x)! + textWidth + 10, y: (cell?.starImageView.frame.origin.y)!, width: (cell?.starImageView.frame.size.width)!, height: (cell?.starImageView.frame.size.height)!)
                
                let identifier = String(format: "%@_%@_%@_%@_%@", schoolId, gender, sport, teamLevel, season)
                
                let result = favoriteTeamIdentifierArray.filter { $0 as! String == identifier }
                if (!result.isEmpty)
                {
                    cell?.starImageView.isHidden = false
                }
            }
        }
        else
        {
            // Change the titleLabel text and location
            cell?.titleLabel?.frame = CGRect(x: 16, y: 0, width: 200, height: 24)
            cell?.titleLabel?.font = UIFont.mpItalicFontWith(size: 19)
            
            cell?.titleLabel?.text = "No Sports Found"
            cell?.seasonLabel?.text = ""
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if (boysTeamsArray.count == 0) && (girlsTeamsArray.count == 0)
        {
            return
        }
        
        var team = [:] as Dictionary<String, Any>
        
        if (boysTeamsArray.count > 0) && (girlsTeamsArray.count > 0)
        {
            if (indexPath.section == 0)
            {
                team = boysTeamsArray[indexPath.row] as! [String : Any]
            }
            else
            {
                team = girlsTeamsArray[indexPath.row] as! [String : Any]
            }
        }
        else if (boysTeamsArray.count > 0) && (girlsTeamsArray.count == 0)
        {
            team = boysTeamsArray[indexPath.row] as! [String : Any]
        }
        else if (boysTeamsArray.count == 0) && (girlsTeamsArray.count > 0)
        {
            team = girlsTeamsArray[indexPath.row] as! [String : Any]
        }
        
        // Refactor the team object so it matches a user's favorite team object
        let schoolId = (self.selectedTeam?.schoolId)!
        
        let gender = team[kNewGenderKey] as! String
        let sport = team[kNewSportKey] as! String
        let allSeasonId = team[kNewAllSeasonIdKey] as! String
        let teamLevel = team[kNewLevelKey] as! String
        let season = team[kNewSeasonKey] as! String
        
        // Update the selectedTeam object with just enough to display the team detail
        //let notifications = [] as Array
        //self.selectedTeam?.notifications = notifications
        self.selectedTeam?.teamId = 0
        self.selectedTeam?.allSeasonId = allSeasonId
        self.selectedTeam?.teamLevel = teamLevel
        self.selectedTeam?.season = season
        self.selectedTeam?.gender = gender
        self.selectedTeam?.sport = sport
        
        var showSaveFavoriteButton = false
        var showRemoveFavoriteButton = false
        
        // Check to see if the team is already a favorite
        let identifier = String(format: "%@_%@_%@_%@_%@", schoolId, gender, sport, teamLevel, season)
        let result = favoriteTeamIdentifierArray.filter { $0 as! String == identifier }
        let userId = kUserDefaults.value(forKey: kUserIdKey) as! String
        
        if (result.isEmpty == false)
        {
            if (userId != kTestDriveUserId)
            {
                showSaveFavoriteButton = false
                showRemoveFavoriteButton = true
            }
        }
        else
        {
            if (userId != kTestDriveUserId)
            {
                showSaveFavoriteButton = true
                showRemoveFavoriteButton = false
            }
        }
        
        // This property is set when this class is called from the TeamDetailVC's school info cell
        if (self.teamDetailViewControllerIsParent == false)
        {
            // Just open the TeamDetailVC for Test Drive users (hiding the saveFavoriteButton
            teamDetailVC = TeamDetailViewController(nibName: "TeamDetailViewController", bundle: nil)
            teamDetailVC.selectedTeam = self.selectedTeam
            teamDetailVC.showSaveFavoriteButton = showSaveFavoriteButton
            teamDetailVC.showRemoveFavoriteButton = showRemoveFavoriteButton
            
            self.navigationController?.pushViewController(teamDetailVC, animated: true)
        }
        else
        {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    // MARK: - ThreeSegmentControl Delegate
    
    func segmentChanged()
    {
        // Pick which array to use
        switch self.threeSegmentControl?.selectedSegment
        {
        case 0:
            self.selectedTeamsArray = self.varsityTeams
        case 1:
            self.selectedTeamsArray = self.jvTeams
        case 2:
            self.selectedTeamsArray = self.freshmanTeams
        default:
            break
        }
        
        self.boysTeamsArray.removeAll()
        self.girlsTeamsArray.removeAll()
        
        // Break the teams into boys and girls
        for team in self.selectedTeamsArray
        {
            let item = team  as! Dictionary<String, Any>
            let gender = item[kNewGenderKey] as! String
            let sport = item[kNewSportKey] as! String
            let teamLevel = item[kNewLevelKey] as! String
            let season = item[kNewSeasonKey] as! String
            
            // Must be unique so go ahead and add the team
            if (gender == "Boys")
            {
                // Skip the team that matches the initial team (if it was set)
                if ((teamDetailCurrentGender == gender) && (teamDetailCurrentSport == sport) && (teamDetailCurrentTeamLevel == teamLevel) && (teamDetailCurrentSeason == season))
                {
                    continue
                }
                self.boysTeamsArray.append(item)
            }
            else
            {
                // Skip the team that matches the initial team (if it was set)
                if ((teamDetailCurrentGender == gender) && (teamDetailCurrentSport == sport) && (teamDetailCurrentTeamLevel == teamLevel) && (teamDetailCurrentSeason == season))
                {
                    continue
                }
                self.girlsTeamsArray.append(item)
            }
        }
        
        self.teamTableView.reloadData()
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
        
        trackingGuid = NSUUID().uuidString
                
        // This VC uses it's own Navigation bar
        var bottomTabBarPad = CGFloat(0)
        
        if (self.tabBarController?.tabBar.isHidden == false)
        {
            bottomTabBarPad = CGFloat(kTabBarHeight)
        }
        
        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        
        // Add the ThreeSegmentControlView to the navView
        threeSegmentControl = ThreeSegmentControlView(frame: CGRect(x: 0, y: navView.frame.size.height - 41, width: navView.frame.size.width, height: 40), buttonOneTitle: "Varsity", buttonTwoTitle: "JV", buttonThreeTitle: "Freshman", lightTheme: false)
        threeSegmentControl?.delegate = self
        navView.addSubview(threeSegmentControl!)
        
        teamTableView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: CGFloat(kDeviceHeight) - fakeStatusBar.frame.size.height - navView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight) - bottomTabBarPad)

        mascotContainerView.layer.cornerRadius = mascotContainerView.frame.size.width / 2
        mascotContainerView.clipsToBounds = true
        
        // School structure (selectedSchool)
        /*
         var fullName: String
         var name: String
         var schoolId: String
         var address: String
         var state: String
         var zip: String
         var searchDistance: Float
         var latitude: String
         var longitude: String
         var city: String
         */
                
        // Initialize a team object with some of the selectedSchool properties
        // This will get updated when a team is selected
        selectedTeam = Team(teamId: 0, allSeasonId: "", gender: "", sport: "", teamColor: "", mascotUrl: "", schoolName: selectedSchool!.name, teamLevel: "", schoolId: selectedSchool!.schoolId, schoolState: selectedSchool!.state, schoolCity: selectedSchool!.city, schoolFullName: selectedSchool!.fullName, season: "", notifications: [])

        teamLetterLabel.isHidden = true
        mascotImageView.isHidden = true
        
        titleLabel.text = selectedSchool!.name
        subtitleLabel.text = selectedSchool!.state
        
        // Check if the school already exists in the SchoolInfoDIctionary to load the colors.
        // If the school doesn't exist, the color will be loaded later in the getAvailableTeams method
        let schoolInfos = kUserDefaults.dictionary(forKey: kNewSchoolInfoDictionaryKey)
        
        if (schoolInfos![selectedSchool!.schoolId] != nil)
        {
            let schoolInfo = schoolInfos![selectedSchool!.schoolId] as! Dictionary<String,String>
            let colorString = schoolInfo[kNewSchoolInfoColor1Key]
            let teamColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
            
            fakeStatusBar.backgroundColor = teamColor
            navView.backgroundColor = teamColor
        }

        /*
        if (selectedSchool!.city.count > 0)
        {
            subtitleLabel.text = String(format: "%@, %@", selectedSchool!.city, selectedSchool!.state)
        }
        else
        {
            subtitleLabel.text = selectedSchool!.state
        }
        */
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
                
        // Get the favorites
        if let favs = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
        {
            favorites = favs
        }
        
        // Build the favorite team identifier array so a star can be put next to each favorite team
        // Fill the favorite team identifier array
        
        favoriteTeamIdentifierArray.removeAll()
        
        for favorite in favorites
        {
            let item = favorite  as! Dictionary<String, Any>
            
            let gender = item[kNewGenderKey] as! String
            let sport = item[kNewSportKey] as! String
            let teamLevel = item[kNewLevelKey] as! String
            let schoolId = item[kNewSchoolIdKey] as! String
            let season = item[kNewSeasonKey] as! String
                        
            let identifier = String(format: "%@_%@_%@_%@_%@", schoolId, gender, sport, teamLevel, season)
                        
            favoriteTeamIdentifierArray.append(identifier)
        }
        
        self.getAvailableTeams(schoolId: selectedSchool!.schoolId)
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
