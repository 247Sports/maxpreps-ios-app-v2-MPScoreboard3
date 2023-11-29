//
//  NewADTeamsViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 7/19/23.
//

import UIKit

class NewADTeamsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ThreeSegmentControlViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var teamTableView: UITableView!
    @IBOutlet weak var mascotContainerView: UIView!
    @IBOutlet weak var teamLetterLabel: UILabel!
    @IBOutlet weak var mascotImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    private var threeSegmentControl : ThreeSegmentControlView?
    
    var selectedSchool = [:] as Dictionary<String,Any>
    var adTeams = [] as Array<Dictionary<String,Any>>
    
    private var varsityTeams = [] as Array<Dictionary<String,Any>>
    private var jvTeams = [] as Array<Dictionary<String,Any>>
    private var freshmanTeams = [] as Array<Dictionary<String,Any>>
    private var selectedTeamsArray = [] as Array<Dictionary<String,Any>>
    private var boysTeamsArray = [] as Array<Dictionary<String,Any>>
    private var girlsTeamsArray = [] as Array<Dictionary<String,Any>>
    private var favoriteTeamIdentifierArray = [] as Array
    
    private var teamDetailVC: TeamDetailViewController!
    
    // MARK: - Show Team Detail View Controller
    
    private func showTeamDetailViewController(team: Team)
    {
        self.tabBarController?.tabBar.isHidden = false
        
        // This is added to disable tha tabbar buttons
        let tabBarControllerItems = self.tabBarController?.tabBar.items

        if let tabArray = tabBarControllerItems
        {
            let tabBarItem1 = tabArray[0]
            let tabBarItem2 = tabArray[1]
            let tabBarItem3 = tabArray[2]

            tabBarItem1.isEnabled = false
            tabBarItem2.isEnabled = false
            tabBarItem3.isEnabled = false
        }
        
        if (teamDetailVC != nil)
        {
            teamDetailVC = nil
        }
        
        var showSaveFavoriteButton = false
        var showRemoveFavoriteButton = false
        
        // Check to see if the team is already a favorite
        let isFavoriteTeam = MiscHelper.isTeamMyFavoriteTeamWithId(schoolId: team.schoolId, gender: team.gender, sport: team.sport, teamLevel: team.teamLevel, season: team.season).isFavorite
        let teamId = MiscHelper.isTeamMyFavoriteTeamWithId(schoolId: team.schoolId, gender: team.gender, sport: team.sport, teamLevel: team.teamLevel, season: team.season).teamId
        
        let selectedTeamObj = Team(teamId: teamId, allSeasonId: team.allSeasonId, gender: team.gender, sport: team.sport, teamColor: team.teamColor, mascotUrl: team.mascotUrl, schoolName: team.schoolName, teamLevel: team.teamLevel, schoolId: team.schoolId, schoolState: team.schoolState, schoolCity: team.schoolCity, schoolFullName: team.schoolFullName, season: team.season, notifications: [])
        
        if (isFavoriteTeam == true)
        {
            showSaveFavoriteButton = false
            showRemoveFavoriteButton = true
        }
        else
        {
            showSaveFavoriteButton = true
            showRemoveFavoriteButton = false
        }
        
        teamDetailVC = TeamDetailViewController(nibName: "TeamDetailViewController", bundle: nil)
        teamDetailVC.selectedTeam = selectedTeamObj
        teamDetailVC.showSaveFavoriteButton = showSaveFavoriteButton
        teamDetailVC.showRemoveFavoriteButton = showRemoveFavoriteButton
        
        self.navigationController?.pushViewController(teamDetailVC, animated: true)
    }
    
    // MARK: - Filter and Sort Teams
    
    private func filterAndSortTeams()
    {
        // Remove the unwanted teams from other schools
        var filteredTeams = [] as Array<Dictionary<String,Any>>
        
        for adTeam in adTeams
        {
            let schoolId = adTeam["schoolId"] as! String
            let currentSchoolId = selectedSchool["schoolId"] as! String
            
            if (schoolId == currentSchoolId)
            {
                filteredTeams.append(adTeam)
            }
        }
        
        for team in filteredTeams
        {
            let teamLevel = team["teamLevel"] as! String
            
            if (teamLevel == "Varsity")
            {
                varsityTeams.append(team)
            }
            else if (teamLevel == "JV")
            {
                jvTeams.append(team)
            }
            else if (teamLevel == "Freshman")
            {
                freshmanTeams.append(team)
            }
        }
        
        // Pick which array to use
        switch threeSegmentControl?.selectedSegment
        {
        case 0:
            selectedTeamsArray = varsityTeams
        case 1:
            selectedTeamsArray = jvTeams
        case 2:
            selectedTeamsArray = freshmanTeams
        default:
            break
        }
        
        // Break the teams into boys and girls
        for team in selectedTeamsArray
        {
            let gender = team["gender"] as! String
            
            // Must be unique so go ahead and add the team
            if ((gender == "Boys") || (gender == "Co-ed"))
            {
                boysTeamsArray.append(team)
            }
            else
            {
                girlsTeamsArray.append(team)
            }
        }
        
        teamTableView.reloadData()
        
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
        return 44
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
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44))
        view.backgroundColor = UIColor.mpWhiteColor()
        
        let label = UILabel(frame: CGRect(x: 20, y: 12, width: tableView.frame.size.width - 40, height: 32))
        label.font = UIFont.mpBoldFontWith(size: 14)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.mpDarkGrayColor()
        label.text = title
        view.addSubview(label)
        
        if (section == 0)
        {
            let topLine = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 4))
            topLine.backgroundColor = UIColor.mpHeaderBackgroundColor()
            view.addSubview(topLine)
        }

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
        
        let colorString = selectedSchool["schoolColor1"] as! String
        let teamColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
        cell?.starImageView.tintColor = teamColor
        cell?.starImageView.isHidden = true

        
        let schoolId = selectedSchool["schoolId"] as! String
        
        if (boysTeamsArray.count > 0) && (girlsTeamsArray.count > 0)
        {
            if (indexPath.section == 0)
            {
                let item = boysTeamsArray[indexPath.row]
                
                let gender = item["gender"] as! String
                let sport = item["sport"] as! String
                let teamLevel = item["teamLevel"] as! String
                let season = item["season"] as! String
                
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
                let item = girlsTeamsArray[indexPath.row]
                
                let gender = item["gender"] as! String
                let sport = item["sport"] as! String
                let teamLevel = item["teamLevel"] as! String
                let season = item["season"] as! String
                
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
                let item = boysTeamsArray[indexPath.row]
                
                let gender = item["gender"] as! String
                let sport = item["sport"] as! String
                let teamLevel = item["teamLevel"] as! String
                let season = item["season"] as! String
                
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
                let item = girlsTeamsArray[indexPath.row]
                
                let gender = item["gender"] as! String
                let sport = item["sport"] as! String
                let teamLevel = item["teamLevel"] as! String
                let season = item["season"] as! String
                
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
            cell?.titleLabel?.text = "No Sports Found"
            cell?.seasonLabel?.text = ""
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: false)
        
        var team = [:] as Dictionary<String,Any>
        
        if (boysTeamsArray.count > 0) && (girlsTeamsArray.count > 0)
        {
            if (indexPath.section == 0)
            {
                team = boysTeamsArray[indexPath.row]
            }
            else
            {
                team = girlsTeamsArray[indexPath.row]
            }
        }
        else if (boysTeamsArray.count > 0) && (girlsTeamsArray.count == 0)
        {
            team = boysTeamsArray[indexPath.row]
        }
        else if (boysTeamsArray.count == 0) && (girlsTeamsArray.count > 0)
        {
            team = girlsTeamsArray[indexPath.row]
        }
        
        // Build a team object
        let schoolId = selectedSchool["schoolId"] as! String
        let schoolName = selectedSchool["schoolName"] as! String
        let teamColor = selectedSchool["schoolColor1"] as! String
        let mascotUrl = selectedSchool["schoolMascotUrl"] as? String ?? ""
        let schoolState = selectedSchool["schoolState"] as! String
        let schoolCity = selectedSchool["schoolCity"] as! String
        
        let allSeasonId = team["allSeasonId"] as! String
        let gender = team["gender"] as! String
        let sport = team["sport"] as! String
        let teamLevel = team["teamLevel"] as! String
        let season = team["season"] as! String
        
        // Create a selectedTeam object with just enough to display the team detail
        var selectedTeam = Team(teamId: 0, allSeasonId: allSeasonId, gender: gender, sport: sport, teamColor: teamColor, mascotUrl: mascotUrl, schoolName: schoolName, teamLevel: teamLevel, schoolId: schoolId, schoolState: schoolState, schoolCity: schoolCity, schoolFullName: "", season: season, notifications: [])

        // Check to see if the schoolId is not empty
        if (schoolId != "")
        {
            self.showTeamDetailViewController(team: selectedTeam)
        }

    }
    
    // MARK: - ThreeSegmentControl Delegate
    
    func segmentChanged()
    {
        // Pick which array to use
        switch threeSegmentControl?.selectedSegment
        {
        case 0:
            selectedTeamsArray = varsityTeams
        case 1:
            selectedTeamsArray = jvTeams
        case 2:
            selectedTeamsArray = freshmanTeams
        default:
            break
        }
        
        boysTeamsArray.removeAll()
        girlsTeamsArray.removeAll()
        
        // Break the teams into boys and girls
        for team in selectedTeamsArray
        {
            let gender = team["gender"] as! String
            
            // Must be unique so go ahead and add the team
            if ((gender == "Boys") || (gender == "Co-ed"))
            {
                boysTeamsArray.append(team)
            }
            else
            {
                girlsTeamsArray.append(team)
            }
        }
        
        teamTableView.reloadData()
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

        // Size the fakeStatusBar, navBar, and ScrollView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        teamTableView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: CGFloat(kDeviceHeight) - fakeStatusBar.frame.size.height - navView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight))
        
        // Add the ThreeSegmentControlView to the navView
        threeSegmentControl = ThreeSegmentControlView(frame: CGRect(x: 0, y: navView.frame.size.height - 41, width: navView.frame.size.width, height: 40), buttonOneTitle: "Varsity", buttonTwoTitle: "JV", buttonThreeTitle: "Freshman", lightTheme: false)
        threeSegmentControl?.delegate = self
        navView.addSubview(threeSegmentControl!)

        mascotContainerView.layer.cornerRadius = mascotContainerView.frame.size.width / 2
        mascotContainerView.clipsToBounds = true
        
        let schoolName = selectedSchool["schoolName"] as! String
        titleLabel.text = schoolName
        
        let state = selectedSchool["schoolState"] as! String
        subtitleLabel.text = state
        
        let schoolInitial = schoolName.first?.uppercased()
        teamLetterLabel.text = schoolInitial
        
        let colorString = selectedSchool["schoolColor1"] as! String
        let teamColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
        
        teamLetterLabel.textColor = teamColor
        fakeStatusBar.backgroundColor = teamColor
        navView.backgroundColor = teamColor
        
        let mascotUrl = selectedSchool["schoolMascotUrl"] as? String ?? ""
        
        if (mascotUrl.count > 0)
        {
            // Get the data and make an image
            let url = URL(string: mascotUrl)
            
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        self.teamLetterLabel.isHidden = true
                        
                        // Render the mascot using this helper
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.mascotImageView)!)
                    }
                }
            }
        }
        
        
        // Get the favorites
        let favorites = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)!
        
        // Build the favorite team identifier array so a star can be put next to each favorite team
        // Fill the favorite team identifier array
        
        favoriteTeamIdentifierArray.removeAll()
        
        for item in favorites
        {
            let favorite = item as! Dictionary<String,Any>
            let gender = favorite[kNewGenderKey] as! String
            let sport = favorite[kNewSportKey] as! String
            let teamLevel = favorite[kNewLevelKey] as! String
            let schoolId = favorite[kNewSchoolIdKey] as! String
            let season = favorite[kNewSeasonKey] as! String
                        
            let identifier = String(format: "%@_%@_%@_%@_%@", schoolId, gender, sport, teamLevel, season)
                        
            favoriteTeamIdentifierArray.append(identifier)
        }
        
        self.filterAndSortTeams()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        
        // This is added to enable the tabbar buttons when returning from the VCs
        let tabBarControllerItems = self.tabBarController?.tabBar.items
        
        if let tabArray = tabBarControllerItems
        {
            let tabBarItem1 = tabArray[0]
            let tabBarItem2 = tabArray[1]
            let tabBarItem3 = tabArray[2]
            
            tabBarItem1.isEnabled = true
            tabBarItem2.isEnabled = true
            tabBarItem3.isEnabled = true
        }
        
        // This is added to reset the background when returning from the VCs
        kAppKeyWindow.rootViewController!.view.backgroundColor = UIColor.mpWhiteColor()
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (teamDetailVC != nil)
        {
            teamDetailVC = nil
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
