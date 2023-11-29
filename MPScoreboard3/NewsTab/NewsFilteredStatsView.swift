//
//  NewsFilteredStatsView.swift
//  MPScoreboard3
//
//  Created by David Smith on 1/12/22.
//

import UIKit

protocol NewsFilteredStatsViewDelegate: AnyObject
{
    func newsFilteredStatsViewFilterButtonTouched()
    func newsFilterStatsViewFullStatsButtonTouched(urlString: String)
    func newsFilterStatsViewAthleteSelected(selectedAthlete: Athlete)
    func newsFilterStatsViewTeamSelected(selectedTeam: Team, ssid: String)
    func newsFilterStatsViewDefinitionsButtonTouched(urlString: String)
    func newsFilterStatsViewFaqButtonTouched()
}

class NewsFilteredStatsView: UIView, RoundSegmentControlViewDelegate, UITableViewDelegate, UITableViewDataSource
{
    weak var delegate: NewsFilteredStatsViewDelegate!
    
    private var roundSegmentControl: RoundSegmentControlView!
    private var statsTableView: UITableView!
    private var faqFooterView: FilterStatsFaqFooterViewCell!
    
    private var playerStatsArray = [] as! Array<Dictionary<String,Any>>
    private var teamStatsArray = [] as! Array<Dictionary<String,Any>>
    private var teamMode = false

    private var yearCopy = ""
    private var seasonCopy = ""
    private var allSeasonId = ""
    private var gender = ""
    private var sport = ""
    private var trackingGuid = ""
    private var contextCopy = ""
    
    private var titleLabel: UILabel!
    private var subtitleLabel: UILabel!
    
    private var skeletonOverlay: SkeletonHUD!
    
    // MARK: - Get Player and Team Stat Leaders
    
    func getPlayerAndTeamStatLeaders(gender: String, sport: String, year: String, season: String, state: String, context: String, contextId: String, teamSize: String)
    {
        //teamMode = false
        //roundSegmentControl.setSegment(index: 0)
        statsTableView.isHidden = true
        playerStatsArray.removeAll()
        teamStatsArray.removeAll()
        
        yearCopy = year
        seasonCopy = season
        contextCopy = context
        
        //MBProgressHUD.showAdded(to: self, animated: true)
        if (skeletonOverlay == nil)
        {
            skeletonOverlay = SkeletonHUD()            
            skeletonOverlay.show(skeletonFrame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: self.frame.size.height), imageType: .stats, parentView: self)
        }
        
        NewFeeds.getPlayerStatLeaders(gender: gender, sport: sport, year: year, season: season, context: context, contextId:contextId, state: state) { result, error in
            
            if (error == nil)
            {
                print("Get Player Stat Leaders Success")
                self.playerStatsArray = result!["groupStats"] as! Array<Dictionary<String,Any>>
            }
            else
            {
                print("Get Player Stat Leaders Failed")
            }
            
            NewFeeds.getTeamStatLeaders(gender: gender, sport: sport, year: year, season: season, context: context, contextId: contextId, state: state) { result, error in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1)
                {
                    //MBProgressHUD.hide(for: self, animated: true)
                    if (self.skeletonOverlay != nil)
                    {
                        self.skeletonOverlay.hide()
                        self.skeletonOverlay = nil
                    }
                }
       
                if (error == nil)
                {
                    print("Get Team Stat Leaders Success")
                    self.teamStatsArray = result!["groupStats"] as! Array<Dictionary<String,Any>>
                    self.allSeasonId = result!["allSeasonId"] as! String
                    self.gender = result!["gender"] as! String
                    self.sport = result!["sport"] as! String
                    
                    // Build the tracking context data object
                    var cData = kEmptyTrackingContextData
                
                    cData[kTrackingSportNameKey] = self.sport
                    cData[kTrackingSportGenderKey] = self.gender
                    cData[kTrackingSeasonKey] = self.seasonCopy
                    cData[kTrackingSchoolYearKey] = self.yearCopy
                    cData[kTrackingFiltersAppliedKey] = context
                    
                    TrackingManager.trackState(featureName: "player-stat", trackingGuid: self.trackingGuid, cData: cData)
                    
                    TrackingManager.trackState(featureName: "team-stat", trackingGuid: self.trackingGuid, cData: cData)
                }
                else
                {
                    print("Get Team Stat Leaders Failed")
                }
                
                self.statsTableView.isHidden = false
                self.statsTableView.reloadData()
            }
        }
    }
    
    // MARK: - Set Title Method
    
    func updateTitle(title: String, subtitle: String)
    {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        if (subtitle == "")
        {
            // Resize the title label to be tall so the text is centered with the button
            titleLabel.frame = CGRect(x: titleLabel.frame.origin.x, y: titleLabel.frame.origin.y, width: titleLabel.frame.size.width, height: 36)
        }
        else
        {
            titleLabel.frame = CGRect(x: titleLabel.frame.origin.x, y: titleLabel.frame.origin.y, width: titleLabel.frame.size.width, height: 20)
        }
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if (teamMode == false)
        {
            if (playerStatsArray.count > 0)
            {
                return playerStatsArray.count
            }
            else
            {
                return 1
            }
        }
        else
        {
            if (teamStatsArray.count > 0)
            {
                return teamStatsArray.count
            }
            else
            {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (teamMode == false)
        {
            if (playerStatsArray.count > 0)
            {
                return 448
            }
            else
            {
                return 48
            }
        }
        else
        {
            if (teamStatsArray.count > 0)
            {
                return 448 - 45 // Temporarily shorter until the button is visible
            }
            else
            {
                return 48
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if (section == 0)
        {
            return 8
        }
        else
        {
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (teamMode == false)
        {
            if (playerStatsArray.count > 0)
            {
                if (section == (playerStatsArray.count - 1))
                {
                    //return 8 + 62 // Ad pad
                    return 64 + 62 // Ad Pad
                }
                else
                {
                    return 8
                }
            }
            else
            {
                return 0.01
            }
        }
        else
        {
            if (teamStatsArray.count > 0)
            {
                if (section == (teamStatsArray.count - 1))
                {
                    //return 8  + 62 // Ad pad
                    return 64 + 62 // Ad Pad
                }
                else
                {
                    return 8
                }
            }
            else
            {
                return 0.01
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        if (teamMode == false)
        {
            if (playerStatsArray.count > 0)
            {
                if (section == (playerStatsArray.count - 1))
                {
                    let view = UIView()
                    view.addSubview(faqFooterView)
                    return view
                }
                else
                {
                    return nil
                }
            }
            else
            {
                return nil
            }
        }
        else
        {
            if (teamStatsArray.count > 0)
            {
                if (section == (teamStatsArray.count - 1))
                {
                    let view = UIView()
                    view.addSubview(faqFooterView)
                    return view
                }
                else
                {
                    return nil
                }
            }
            else
            {
                return nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (teamMode == false)
        {
            if (playerStatsArray.count > 0)
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "FilterPlayerStatsTableViewCell") as? FilterPlayerStatsTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("FilterPlayerStatsTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? FilterPlayerStatsTableViewCell
                }
                
                cell?.selectionStyle = .none
                
                let statsData = playerStatsArray[indexPath.section]
                cell?.loadData(statsData)
                
                //let athletes = statsData["athletes"] as! Array<Dictionary<String,Any>>
                //let athlete = athletes[0]
                //let stats = athlete["stats"] as! Array<Dictionary<String,Any>>
                //let stat = stats[0]
                //let header = stat["header"] as! String
                //let buttonTitle = String(format: "FULL %@ LEADERS", header.uppercased())
                let title = statsData["statDisplayName"] as! String
                let buttonTitle = String(format: "FULL %@ LEADERS", title.uppercased())
                cell?.fullPlayerStatLeadersButton.setTitle(buttonTitle, for: .normal)
                cell?.fullPlayerStatLeadersButton.tag = 100 + indexPath.section
                cell?.fullPlayerStatLeadersButton.addTarget(self, action: #selector(fullPlayerStatsButtonTouched(_:)), for: .touchUpInside)
                
                cell?.innerButton1.tag = 100 + indexPath.section
                cell?.innerButton1.addTarget(self, action: #selector(innerPlayerStatsButton1Touched(_:)), for: .touchUpInside)
                
                cell?.innerButton2.tag = 100 + indexPath.section
                cell?.innerButton2.addTarget(self, action: #selector(innerPlayerStatsButton2Touched(_:)), for: .touchUpInside)
                
                cell?.innerButton3.tag = 100 + indexPath.section
                cell?.innerButton3.addTarget(self, action: #selector(innerPlayerStatsButton3Touched(_:)), for: .touchUpInside)
                
                cell?.innerButton4.tag = 100 + indexPath.section
                cell?.innerButton4.addTarget(self, action: #selector(innerPlayerStatsButton4Touched(_:)), for: .touchUpInside)
                
                cell?.innerButton5.tag = 100 + indexPath.section
                cell?.innerButton5.addTarget(self, action: #selector(innerPlayerStatsButton5Touched(_:)), for: .touchUpInside)

                return cell!
            }
            else
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "Cell1")
                
                if (cell == nil)
                {
                    cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell1")
                }
                
                cell?.selectionStyle = .none
                
                cell?.contentView.backgroundColor = UIColor.mpWhiteColor()
                cell?.textLabel?.textColor = UIColor.mpBlackColor()
                cell?.textLabel?.font = UIFont.mpRegularFontWith(size: 16)
                
                cell?.textLabel?.text = String(format: "No Player Stats for %@ %@", seasonCopy, yearCopy)
                
                let label = UILabel(frame:CGRect(x: kDeviceWidth - 90, y: 12, width: 74, height: 24))
                label.backgroundColor = UIColor.mpHeaderBackgroundColor()
                label.font = UIFont.mpSemiBoldFontWith(size: 12)
                label.textColor = UIColor.mpDarkGrayColor()
                label.textAlignment = .center
                label.layer.cornerRadius = 8
                label.clipsToBounds = true
                label.text = "CHANGE"
                cell?.contentView.addSubview(label)
                
                return cell!
            }
        }
        else
        {
            if (teamStatsArray.count > 0)
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "FilterTeamStatsTableViewCell") as? FilterTeamStatsTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("FilterTeamStatsTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? FilterTeamStatsTableViewCell
                }
                
                cell?.selectionStyle = .none
                
                let statsData = teamStatsArray[indexPath.section]
                cell?.loadData(statsData)
                
                //let teams = statsData["teams"] as! Array<Dictionary<String,Any>>
                //let team = teams[0]
                //let stats = team["stats"] as! Array<Dictionary<String,Any>>
                //let stat = stats[0]
                //let header = stat["header"] as! String
                //let buttonTitle = String(format: "FULL %@ LEADERS", header.uppercased())
                let title = statsData["statDisplayName"] as! String
                let buttonTitle = String(format: "FULL %@ LEADERS", title.uppercased())
                cell?.fullTeamStatLeadersButton.setTitle(buttonTitle, for: .normal)
                cell?.fullTeamStatLeadersButton.tag = 100 + indexPath.section
                cell?.fullTeamStatLeadersButton.addTarget(self, action: #selector(fullTeamStatsButtonTouched(_:)), for: .touchUpInside)
                
                // Hide this button until the web page is done
                cell?.fullTeamStatLeadersButton.isHidden = true
                
                cell?.innerButton1.tag = 100 + indexPath.section
                cell?.innerButton1.addTarget(self, action: #selector(innerTeamStatsButton1Touched(_:)), for: .touchUpInside)
                
                cell?.innerButton2.tag = 100 + indexPath.section
                cell?.innerButton2.addTarget(self, action: #selector(innerTeamStatsButton2Touched(_:)), for: .touchUpInside)
                
                cell?.innerButton3.tag = 100 + indexPath.section
                cell?.innerButton3.addTarget(self, action: #selector(innerTeamStatsButton3Touched(_:)), for: .touchUpInside)
                
                cell?.innerButton4.tag = 100 + indexPath.section
                cell?.innerButton4.addTarget(self, action: #selector(innerTeamStatsButton4Touched(_:)), for: .touchUpInside)
                
                cell?.innerButton5.tag = 100 + indexPath.section
                cell?.innerButton5.addTarget(self, action: #selector(innerTeamStatsButton5Touched(_:)), for: .touchUpInside)
                
                return cell!
            }
            else
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "Cell2")
                
                if (cell == nil)
                {
                    cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell2")
                }
                
                cell?.selectionStyle = .none
                
                cell?.contentView.backgroundColor = UIColor.mpWhiteColor()
                cell?.textLabel?.textColor = UIColor.mpBlackColor()
                cell?.textLabel?.font = UIFont.mpRegularFontWith(size: 16)
                
                cell?.textLabel?.text = String(format: "No Team Stats for %@ %@", seasonCopy, yearCopy)
                
                let label = UILabel(frame:CGRect(x: kDeviceWidth - 90, y: 12, width: 74, height: 24))
                label.backgroundColor = UIColor.mpHeaderBackgroundColor()
                label.font = UIFont.mpSemiBoldFontWith(size: 12)
                label.textColor = UIColor.mpDarkGrayColor()
                label.textAlignment = .center
                label.layer.cornerRadius = 8
                label.clipsToBounds = true
                label.text = "CHANGE"
                cell?.contentView.addSubview(label)
                
                return cell!
            }
        } 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (teamMode == false)
        {
            if (playerStatsArray.count == 0)
            {
                self.delegate?.newsFilteredStatsViewFilterButtonTouched()
            }
        }
        else
        {
            if (teamStatsArray.count == 0)
            {
                self.delegate?.newsFilteredStatsViewFilterButtonTouched()
            }
        }
    }
    
    // MARK: - RoundSegmentControlView Delegate
    
    func segmentChanged()
    {
        if ((roundSegmentControl.selectedSegment == 0) && (teamMode == true))
        {
            teamMode = false
            statsTableView.reloadData()
        }
        else if ((roundSegmentControl.selectedSegment == 1) && (teamMode == false))
        {
            teamMode = true
            statsTableView.reloadData()
        }
        
        // Build the tracking context data object
        var cData = kEmptyTrackingContextData
    
        cData[kTrackingSportNameKey] = self.sport
        cData[kTrackingSportGenderKey] = self.gender
        cData[kTrackingSeasonKey] = self.seasonCopy
        cData[kTrackingSchoolYearKey] = self.yearCopy
        cData[kTrackingFiltersAppliedKey] = self.contextCopy
        
        if (teamMode == false)
        {
            TrackingManager.trackState(featureName: "player-stat", trackingGuid: self.trackingGuid, cData: cData)
        }
        else
        {
            TrackingManager.trackState(featureName: "team-stat", trackingGuid: self.trackingGuid, cData: cData)
        }
    }
    
    // MARK: - Open Career View Controller
    
    private func openCareerViewController(athlete: Dictionary<String,Any>)
    {
        let schoolId = athlete["teamId"] as? String ?? kEmptyGuid
        let schoolName = athlete["schoolName"] as? String ?? "Unknown School"
        let schoolState = athlete["schoolState"] as? String ?? ""
        let schoolCity = athlete["schoolCity"] as? String ?? ""
        let schoolColor = athlete["schoolColor1"] as? String ?? "808080"
        
        let firstName = athlete["athleteFirstName"] as? String ?? ""
        let lastName = athlete["athleteLastName"] as? String ?? ""
        let careerId = athlete["careerId"] as! String
        
        let selectedAthlete = Athlete(firstName: firstName, lastName: lastName, schoolName: schoolName, schoolState: schoolState, schoolCity: schoolCity, schoolId: schoolId, schoolColor: schoolColor, schoolMascotUrl: "", careerId: careerId, photoUrl: "")
        
        self.delegate.newsFilterStatsViewAthleteSelected(selectedAthlete: selectedAthlete)
    }
    
    // MARK: - Open Team Detail View Controller
    
    private func openTeamDetailViewController(team: Dictionary<String,Any>)
    {
        let ssid = team["sportSeasonId"] as! String
        let schoolId = team["teamId"] as! String
        let schoolName = team["schoolName"] as! String
        let schoolColor = team["schoolColor1"] as! String
        let schoolMascotUrl = team["schoolMascotUrl"] as! String
        let schoolCity = team["schoolCity"] as! String
        let schoolState = team["schoolState"] as! String
         
        let selectedTeam = Team(teamId: 0, allSeasonId: self.allSeasonId, gender: self.gender, sport: self.sport, teamColor: schoolColor, mascotUrl: schoolMascotUrl, schoolName: schoolName, teamLevel: "Varsity", schoolId: schoolId, schoolState: schoolState, schoolCity: schoolCity, schoolFullName: "", season: seasonCopy, notifications: [])
        
        self.delegate.newsFilterStatsViewTeamSelected(selectedTeam: selectedTeam, ssid: ssid)
         
    }
    
    // MARK: - Button Methods
    
    @objc private func filterButtonTouched()
    {
        self.delegate?.newsFilteredStatsViewFilterButtonTouched()
        
        // Click Tracking
        let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"leaderboard-filter-button-click", kClickTrackingModuleNameKey: "arena leaderboard filter", kClickTrackingModuleLocationKey:"arena stats home", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:""]
        
        TrackingManager.trackEvent(featureName: "leaderboard-filter", cData: cData)
    }
    
    @objc private func fullPlayerStatsButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let statsData = playerStatsArray[index]
        let urlString = statsData["fullStatLeadersUrl"] as! String
        
        self.delegate.newsFilterStatsViewFullStatsButtonTouched(urlString: urlString)
    }
    
    @objc private func fullTeamStatsButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let statsData = teamStatsArray[index]
        let urlString = statsData["fullStatLeadersUrl"] as! String
        
        self.delegate.newsFilterStatsViewFullStatsButtonTouched(urlString: urlString)
    }
    
    @objc private func innerPlayerStatsButton1Touched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let statsData = playerStatsArray[index]
        let athletes = statsData["athletes"] as! Array<Dictionary<String,Any>>
        let athlete = athletes[0]

        self.openCareerViewController(athlete: athlete)
    }
    
    @objc private func innerPlayerStatsButton2Touched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let statsData = playerStatsArray[index]
        let athletes = statsData["athletes"] as! Array<Dictionary<String,Any>>
        let athlete = athletes[1]

        self.openCareerViewController(athlete: athlete)
    }
    
    @objc private func innerPlayerStatsButton3Touched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let statsData = playerStatsArray[index]
        let athletes = statsData["athletes"] as! Array<Dictionary<String,Any>>
        let athlete = athletes[2]

        self.openCareerViewController(athlete: athlete)
    }
    
    @objc private func innerPlayerStatsButton4Touched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let statsData = playerStatsArray[index]
        let athletes = statsData["athletes"] as! Array<Dictionary<String,Any>>
        let athlete = athletes[3]

        self.openCareerViewController(athlete: athlete)
    }
    
    @objc private func innerPlayerStatsButton5Touched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let statsData = playerStatsArray[index]
        let athletes = statsData["athletes"] as! Array<Dictionary<String,Any>>
        let athlete = athletes[4]

        self.openCareerViewController(athlete: athlete)
    }
    
    @objc private func innerTeamStatsButton1Touched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let statsData = teamStatsArray[index]
        let teams = statsData["teams"] as! Array<Dictionary<String,Any>>
        let team = teams[0]

        self.openTeamDetailViewController(team: team)
    }
    
    @objc private func innerTeamStatsButton2Touched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let statsData = teamStatsArray[index]
        let teams = statsData["teams"] as! Array<Dictionary<String,Any>>
        let team = teams[1]
        
        self.openTeamDetailViewController(team: team)
    }
    
    @objc private func innerTeamStatsButton3Touched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let statsData = teamStatsArray[index]
        let teams = statsData["teams"] as! Array<Dictionary<String,Any>>
        let team = teams[2]
        
        self.openTeamDetailViewController(team: team)
    }
    
    @objc private func innerTeamStatsButton4Touched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let statsData = teamStatsArray[index]
        let teams = statsData["teams"] as! Array<Dictionary<String,Any>>
        let team = teams[3]
        
        self.openTeamDetailViewController(team: team)
    }
    
    @objc private func innerTeamStatsButton5Touched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let statsData = teamStatsArray[index]
        let teams = statsData["teams"] as! Array<Dictionary<String,Any>>
        let team = teams[4]
        
        self.openTeamDetailViewController(team: team)
    }
    
    @objc private func definitionsButtonTouched()
    {
        let fixedSport = sport.replacingOccurrences(of: " ", with: "")
        let genderSport = String(format: "%@,%@", gender, fixedSport)
        let urlString = String(format: kStatDefinitionsHost, genderSport)
        
        self.delegate?.newsFilterStatsViewDefinitionsButtonTouched(urlString: urlString)
    }
    
    @objc private func faqButtonTouched()
    {
        self.delegate?.newsFilterStatsViewFaqButtonTouched()
    }
    
    // MARK: - Init Method
    
    required init(frame: CGRect, gender: String, sport: String, year: String, season: String)
    {
        super.init(frame: frame)
        
        trackingGuid = NSUUID().uuidString
        
        self.backgroundColor = UIColor.mpWhiteColor()
        
        let horizLine = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 1))
        horizLine.backgroundColor = UIColor.mpOffWhiteNavColor()
        self.addSubview(horizLine)
        
        titleLabel = UILabel(frame: CGRect(x: 16, y: 64, width: frame.size.width - 64, height: 36))
        titleLabel.textColor = UIColor.mpBlackColor()
        titleLabel.font = UIFont.mpSemiBoldFontWith(size: 17)
        //titleLabel.text = "National Stat Leaders"
        titleLabel.text = String(format: "National Stat Leaders (%@)", year)
        self.addSubview(titleLabel)
        
        subtitleLabel = UILabel(frame: CGRect(x: 16, y: 84, width: frame.size.width - 64, height: 16))
        subtitleLabel.textColor = UIColor.mpGrayColor()
        subtitleLabel.font = UIFont.mpRegularFontWith(size: 13)
        subtitleLabel.text = ""
        self.addSubview(subtitleLabel)
                
        let filterButton = UIButton(type: .custom)
        filterButton.frame = CGRect(x: frame.size.width - 56, y: 64, width: 40, height: 40)
        //filterButton.setImage(UIImage(named: "SortIcon"), for: .normal)
        // Changed in V6.1.2
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .unspecified, scale: .large)
        let largeImage = UIImage(systemName: "slider.horizontal.3", withConfiguration: largeConfig)
        filterButton.tintColor = UIColor.mpBlackColor()
        filterButton.setImage(largeImage, for: .normal)
        filterButton.addTarget(self, action: #selector(filterButtonTouched), for: .touchUpInside)
        self.addSubview(filterButton)
        
        roundSegmentControl = RoundSegmentControlView(frame: CGRect(x: 24, y: 20, width: kDeviceWidth - 48, height: 32), buttonOneTitle: "PLAYER", buttonTwoTitle: "TEAM")
        roundSegmentControl.delegate = self
        self.addSubview(roundSegmentControl)
        
        let horizLine2 = UIView(frame: CGRect(x: 0, y: 103, width: frame.size.width, height: 1))
        horizLine2.backgroundColor = UIColor.mpHeaderBackgroundColor()
        self.addSubview(horizLine2)
        
        let faqFooterNib = Bundle.main.loadNibNamed("FilterStatsFaqFooterViewCell", owner: self, options: nil)
        faqFooterView = faqFooterNib![0] as? FilterStatsFaqFooterViewCell
        faqFooterView.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 64)
        faqFooterView.definitionButton.addTarget(self, action: #selector(definitionsButtonTouched), for: .touchUpInside)
        faqFooterView.faqButton.addTarget(self, action: #selector(faqButtonTouched), for: .touchUpInside)
        
        statsTableView = UITableView(frame: CGRect(x: 0, y: 104, width: frame.size.width, height: frame.size.height - 104), style: .grouped)
        statsTableView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        statsTableView.separatorStyle = .none
        statsTableView.delegate = self
        statsTableView.dataSource = self
        self.addSubview(statsTableView)
        
        // Get the data for the table
        self.getPlayerAndTeamStatLeaders(gender: gender, sport: sport, year: year, season: season, state: "", context: "National", contextId: "", teamSize: "11")
        
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
