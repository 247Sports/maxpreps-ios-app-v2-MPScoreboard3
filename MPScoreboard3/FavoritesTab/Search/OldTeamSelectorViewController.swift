//
//  OldTeamSelectorViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/10/21.
//

// This code is being keeped because it has expandable cell code to use as a sample for other needs

import UIKit

class OldTeamSelectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ThreeSegmentControlViewDelegate
{
    var selectedSchool : School?
    var selectedTeam : Team?
    var favoriteSaved = false
    
    private var teamDetailVC: TeamDetailViewController!
    
    private var favorites = [] as Array
    private var varsityTeams = [] as Array
    private var jvTeams = [] as Array
    private var freshmanTeams = [] as Array
    private var selectedTeamsArray = [] as Array
    private var boysTeamsArray = [] as Array
    private var girlsTeamsArray = [] as Array
    private var favoriteTeamIdentifierArray = [] as Array
    
    private var threeSegmentControl : ThreeSegmentControlView?
    
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var teamTableView: UITableView!
    @IBOutlet weak var teamLetterLabel: UILabel!
    @IBOutlet weak var mascotImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Get School Info
    
    private func getNewSchoolInfo(_ teams : Array<Any>)
    {
        // Build an array of schoolIds
        var schoolIds = [] as Array<String>
        
        for team in teams
        {
            let item = team  as! Dictionary<String, Any>
            let schoolId  = item[kNewSchoolIdKey] as! String
            
            schoolIds.append(schoolId)
        }

        NewFeeds.getSchoolInfoForSchoolIds(schoolIds) { error in
            if error == nil
            {
                print("Download school info success")
            }
            else
            {
                print("Download school info error")
            }
        }
    }
    
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
                
                // Add the team color and mascotUrl to the selectedTeam object
                self.selectedTeam?.teamColor = colorString
                self.selectedTeam?.mascotUrl = mascotUrl
                
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
                                MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.mascotImageView)!)
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
                    
                    // Must be unique so go ahead and add the team
                    if (gender == "Boys")
                    {
                        self.boysTeamsArray.append(item)
                    }
                    else
                    {
                        self.girlsTeamsArray.append(item)
                    }
                }
                
                self.teamTableView.reloadData()
            }
            else
            {
                print("Download available teams error")
            }
        }
    }
    
    // MARK: - Save User Favorite
    
    private func saveUserFavoriteTeam(_ favorite: Dictionary<String,Any>)
    {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        NewFeeds.saveUserFavoriteTeam(favorite){ (result, error) in
 
            if error == nil
            {
                // Get the user favorites so the prefs get updated
                NewFeeds.getUserFavoriteTeams(completionHandler: { error in
                    
                    // Hide the busy indicator
                    DispatchQueue.main.async
                    {
                        MBProgressHUD.hide(for: self.view, animated: true)
                    }
                    
                    if (error == nil)
                    {
                        self.navigationController?.popViewController(animated: true)
                    }
                    else
                    {
                        print("Download user favorites error")
                    }
                })
                
                self.navigationController?.popViewController(animated: true)
            }
            else
            {
                print("Download user favorites error")
                
                // Hide the busy indicator
                DispatchQueue.main.async
                {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
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
            return 0
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
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 32.0
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
                title = "BOYS SPORTS"
            }
            else
            {
                title = "GIRLS SPORTS"
            }
        }
        else if (boysTeamsArray.count > 0) && (girlsTeamsArray.count == 0)
        {
            title = "BOYS SPORTS";
        }
        else if (boysTeamsArray.count == 0) && (girlsTeamsArray.count > 0)
        {
            title = "GIRLS SPORTS"
        }
        else
        {
            return nil
        }
        
        let label = UILabel(frame: CGRect(x: 16, y: 0, width: tableView.frame.size.width - 40, height: 32))
        label.font = UIFont.mpBoldFontWith(size: 14)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.mpDarkGrayColor()
        label.text = title
        
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
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        }
        
        cell?.contentView.backgroundColor = UIColor.mpWhiteColor()
        cell?.accessoryType = .none
        cell?.textLabel?.font = UIFont.mpSemiBoldFontWith(size: 17)
        cell?.textLabel?.adjustsFontSizeToFitWidth = true
        cell?.textLabel?.minimumScaleFactor = 0.9
        cell?.textLabel?.textColor = UIColor.mpBlackColor()
        cell?.detailTextLabel?.font = UIFont.mpRegularFontWith(size: 14)
        cell?.detailTextLabel?.textColor = UIColor.mpGrayColor()
        cell?.selectionStyle = .gray
        
        // Remove the star image
        for view in cell!.contentView.subviews
        {
            if (view.tag >= 100)
            {
                view.removeFromSuperview()
            }
        }
        
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
                
                cell?.textLabel?.text = sport
                cell?.detailTextLabel?.text = season
                
                let identifier = String(format: "%@_%@_%@_%@_%@", schoolId, gender, sport, teamLevel, season)
                
                let result = favoriteTeamIdentifierArray.filter { $0 as! String == identifier }
                if (!result.isEmpty)
                {
                    let star = UIImageView(frame: CGRect(x: tableView.frame.size.width - 36, y: 14, width: 20, height: 20))
                    star.tag = 100 + indexPath.row
                    star.image = UIImage(named: "ActiveFavorites")
                    cell?.contentView.addSubview(star)
                    cell?.selectionStyle = .none
                }
            }
            else
            {
                let item = girlsTeamsArray[indexPath.row] as! Dictionary<String, Any>
                
                let gender = item[kNewGenderKey] as! String
                let sport = item[kNewSportKey] as! String
                let teamLevel = item[kNewLevelKey] as! String
                let season = item[kNewSeasonKey] as! String
                
                cell?.textLabel?.text = sport
                cell?.detailTextLabel?.text = season
                
                let identifier = String(format: "%@_%@_%@_%@_%@", schoolId, gender, sport, teamLevel, season)
                
                let result = favoriteTeamIdentifierArray.filter { $0 as! String == identifier }
                if (!result.isEmpty)
                {
                    let star = UIImageView(frame: CGRect(x: tableView.frame.size.width - 36, y: 17, width: 20, height: 20))
                    star.tag = 200 + indexPath.row
                    star.image = UIImage(named: "ActiveFavorites")
                    cell?.contentView.addSubview(star)
                    cell?.selectionStyle = .none
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
                
                cell?.textLabel?.text = sport
                cell?.detailTextLabel?.text = season
                
                let identifier = String(format: "%@_%@_%@_%@_%@", schoolId, gender, sport, teamLevel, season)
                
                let result = favoriteTeamIdentifierArray.filter { $0 as! String == identifier }
                if (!result.isEmpty)
                {
                    let star = UIImageView(frame: CGRect(x: tableView.frame.size.width - 36, y: 17, width: 20, height: 20))
                    star.tag = 100 + indexPath.row
                    star.image = UIImage(named: "ActiveFavorites")
                    cell?.contentView.addSubview(star)
                    cell?.selectionStyle = .none
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
                
                cell?.textLabel?.text = sport
                cell?.detailTextLabel?.text = season
                
                let identifier = String(format: "%@_%@_%@_%@_%@", schoolId, gender, sport, teamLevel, season)
                
                let result = favoriteTeamIdentifierArray.filter { $0 as! String == identifier }
                if (!result.isEmpty)
                {
                    let star = UIImageView(frame: CGRect(x: tableView.frame.size.width - 36, y: 17, width: 20, height: 20))
                    star.tag = 100 + indexPath.row
                    star.image = UIImage(named: "ActiveFavorites")
                    cell?.contentView.addSubview(star)
                    cell?.selectionStyle = .none
                }
            }
        }
        else
        {
            cell?.textLabel?.text = "No Sports Found"
            cell?.textLabel?.font = UIFont.italicSystemFont(ofSize: 19)
            cell?.selectionStyle = .none
            cell?.detailTextLabel?.text = ""
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        /*
        let schoolId = (self.selectedTeam?.schoolId)!
        let schoolState = (self.selectedTeam?.schoolState)!
        let schoolName = (self.selectedTeam?.schoolName)!
        let schoolFullName = (self.selectedTeam?.schoolFullName)!
        let schoolCity = (self.selectedTeam?.schoolCity)!
        let schoolColor = (self.selectedTeam?.teamColor)!
        let mascotUrlString = (self.selectedTeam?.mascotUrl)!
        */
        
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
        //self.selectedTeam?.teamId = 0
        self.selectedTeam?.allSeasonId = allSeasonId
        self.selectedTeam?.teamLevel = teamLevel
        self.selectedTeam?.season = season
        self.selectedTeam?.gender = gender
        self.selectedTeam?.sport = sport
        //self.selectedTeam?.mascotUrl = // This was set during getAvailableTeams
        //self.selectedTeam?.teamColor = // This was set during getAvailableTeams
        //self.selectedTeam?.schoolState = schoolState
        //self.selectedTeam?.schoolId = schoolId
        //self.selectedTeam?.schoolName = schoolName
        //self.selectedTeam?.schoolFullName = schoolFullName
        //self.selectedTeam?.schoolCity = schoolCity
        
        var showFavoriteButton = false
        
        // Check to see if the team is already a favorite
        let identifier = String(format: "%@_%@_%@_%@_%@", schoolId, gender, sport, teamLevel, season)
        let result = favoriteTeamIdentifierArray.filter { $0 as! String == identifier }
        
        if (result.isEmpty == false)
        {
            showFavoriteButton = false
        }
        else
        {
            // Two paths depending on wheteher the user is logged in or not
            let userId = kUserDefaults.value(forKey: kUserIdKey) as! String
            
            if (userId != kTestDriveUserId)
            {
                showFavoriteButton = true
            }
            else
            {
                showFavoriteButton = false
            }
        }
        
        // Just open the TeamDetailVC for Test Drive users (hiding the saveFavoriteButton
        teamDetailVC = TeamDetailViewController(nibName: "TeamDetailViewController", bundle: nil)
        teamDetailVC.selectedTeam = self.selectedTeam
        teamDetailVC.showSaveFavoriteButton = showFavoriteButton
        
        self.navigationController?.pushViewController(teamDetailVC, animated: true)
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
            
            // Must be unique so go ahead and add the team
            if (gender == "Boys")
            {
                self.boysTeamsArray.append(item)
            }
            else
            {
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
        threeSegmentControl = ThreeSegmentControlView(frame: CGRect(x: 0, y: navView.frame.size.height - 40, width: navView.frame.size.width, height: 40), buttonOneTitle: "Varsity", buttonTwoTitle: "JV", buttonThreeTitle: "Freshman", lightTheme: true)
        threeSegmentControl?.delegate = self
        navView.addSubview(threeSegmentControl!)
        
        teamTableView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: CGFloat(kDeviceHeight) - fakeStatusBar.frame.size.height - navView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight) - bottomTabBarPad)

        
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
         
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
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
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
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
