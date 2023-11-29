//
//  NewsFilteredRankingsView.swift
//  MPScoreboard3
//
//  Created by David Smith on 1/12/22.
//

import UIKit

protocol NewsFilteredRankingsViewDelegate: AnyObject
{
    func newsFilteredRankingsViewFilterButtonTouched()
    func newsFilterRankingsViewFullRankingsButtonTouched(urlString: String)
    func newsFilterRankingsViewTeamSelected(selectedTeam: Team, ssid: String)
    func newsFilterRankingsViewLearnMoreButtonTouched()
}

class NewsFilteredRankingsView: UIView, UITableViewDelegate, UITableViewDataSource
{
    weak var delegate: NewsFilteredRankingsViewDelegate?
    
    private var rankingsTableView: UITableView!
    private var fixedHeaderView: FilterTeamRankingsFixedHeaderView!
    private var headerLastUpdatedLabel: UILabel!
    private var emptyRankingsLabel: UILabel!
    
    private var teamRankingsArray = [] as! Array<Dictionary<String,Any>>

    private var yearCopy = ""
    private var seasonCopy = ""
    private var contextCopy = ""
    private var allSeasonId = ""
    private var ssid = ""
    private var gender = ""
    private var sport = ""
    private var fullRankingsUrl = ""
    private var minimumGamesPlayed = ""
    private var trackingGuid = ""
    
    private var upperTitleLabel: UILabel!
    private var upperSubtitleLabel: UILabel!
    
    private var skeletonOverlay: SkeletonHUD!
    
    // MARK: - Get Team Rankings Leaders
    
    func getTeamRankingsLeaders(gender: String, sport: String, year: String, season: String, state: String, context: String, contextId: String, teamSize: String)
    {
        rankingsTableView.isHidden = true
        emptyRankingsLabel.isHidden = true
        teamRankingsArray.removeAll()
        
        yearCopy = year
        seasonCopy = season
        contextCopy = context
        
        headerLastUpdatedLabel.text = ""
        
        //MBProgressHUD.showAdded(to: self, animated: true)
        if (skeletonOverlay == nil)
        {
            skeletonOverlay = SkeletonHUD()            
            skeletonOverlay.show(skeletonFrame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: self.frame.size.height), imageType: .rankings, parentView: self)
        }
        
        NewFeeds.getTeamRankingsLeaders(gender: gender, sport: sport, year: year, season: season, context: context, contextId: contextId, state: state, teamSize: teamSize) { result, error in
            
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
                print("Get Team Rankings Leaders Success")
                self.teamRankingsArray = result!["rankingData"] as! Array<Dictionary<String,Any>>
                self.allSeasonId = result!["allSeasonId"] as! String
                self.gender = result!["gender"] as! String
                self.sport = result!["sport"] as! String
                self.ssid = result!["sportSeasonId"] as! String
                self.fullRankingsUrl = result!["canonicalUrl"] as? String ?? ""
                self.minimumGamesPlayed = result!["minimumGamesPlayed"] as? String ?? ""
                
                // Build the tracking context data object
                var cData = kEmptyTrackingContextData
            
                cData[kTrackingSportNameKey] = self.sport
                cData[kTrackingSportGenderKey] = self.gender
                cData[kTrackingSeasonKey] = self.seasonCopy
                cData[kTrackingSchoolYearKey] = self.yearCopy
                cData[kTrackingFiltersAppliedKey] = context
                
                TrackingManager.trackState(featureName: "team-rankings", trackingGuid: self.trackingGuid, cData: cData)
                
                if (self.teamRankingsArray.count > 0)
                {
                    self.rankingsTableView.isHidden = false
                }
                else
                {
                    self.emptyRankingsLabel.isHidden = false
                    
                    self.emptyRankingsLabel.text = String(format: "Rankings for the %@ %@ %@ season have not been released yet. Our rankings algorithm requires a minimum number of games played before we can accurately rank teams. Please check back soon.\n\nPrevious seasons are still available using the filter above.", self.gender, self.sport, year)
                }
                
                let updatedOnString = result!["updatedOn"] as? String ?? ""
                if (updatedOnString.count > 0)
                {
                    let dateFormatter = DateFormatter()
                    dateFormatter.isLenient = true
                    dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
                    let lastUpdate = dateFormatter.date(from: updatedOnString)
                    
                    if (lastUpdate != nil)
                    {
                        dateFormatter.dateFormat = "M/d/yyyy"
                        let dateString = dateFormatter.string(from: lastUpdate!)
                        self.headerLastUpdatedLabel.text = String(format: "Updated: %@", dateString)
                    }
                    else
                    {
                        self.headerLastUpdatedLabel.text = "Updated: N/A"
                    }
                }
                
                if (self.contextCopy == "National")
                {
                    if ((self.sport == "Football") || (self.sport == "Basketball") || (self.sport == "Baseball") || (self.sport == "Softball") || ((self.sport == "Volleyball") && (self.gender == "Girls")))
                    {
                        self.fixedHeaderView.strengthTitleLabel.isHidden = true
                    }
                    else
                    {
                        self.fixedHeaderView.strengthTitleLabel.isHidden = false
                    }
                }
                else
                {
                    self.fixedHeaderView.strengthTitleLabel.isHidden = false
                }
            }
            else
            {
                print("Get Team Rankings Leaders Failed")
            }
            
            self.rankingsTableView.reloadData()
        }
    }
    
    // MARK: - Set Title Method
    
    func updateTitle(title: String, subtitle: String)
    {
        upperTitleLabel.text = title
        upperSubtitleLabel.text = subtitle
        
        if (subtitle == "")
        {
            // Resize the title label to be tall so the text is centered with the button
            upperTitleLabel.frame = CGRect(x: upperTitleLabel.frame.origin.x, y: upperTitleLabel.frame.origin.y, width: upperTitleLabel.frame.size.width, height: 36)
        }
        else
        {
            upperTitleLabel.frame = CGRect(x: upperTitleLabel.frame.origin.x, y: upperTitleLabel.frame.origin.y, width: upperTitleLabel.frame.size.width, height: 20)
        }
        
        // Refresh the emptyRankingsLabel text because the year may have changed
        emptyRankingsLabel.text = String(format: "Rankings for the %@ %@ %@ season have not been released yet. Our rankings algorithm requires a minimum number of games played before we can accurately rank teams. Please check back soon.\n\nPrevious seasons are still available using the filter above.", gender, sport, yearCopy)
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section == 0)
        {
            return teamRankingsArray.count
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (indexPath.section == 0)
        {
            return 64
        }
        else
        {
            return 56
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if (section == 0)
        {
            return headerLastUpdatedLabel.frame.size.height
        }
        else
        {
            return 0.01
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (section == 0)
        {
            return 52
        }
        else
        {
            return 8 + 62 // Ad pad
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (section == 0)
        {
            return headerLastUpdatedLabel
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        if (section == 0)
        {
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 52))
            footerView.backgroundColor = UIColor.mpHeaderBackgroundColor()
            
            let contentView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 44))
            contentView.backgroundColor = UIColor.mpWhiteColor()
            contentView.layer.cornerRadius = 12
            contentView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            contentView.clipsToBounds = true
            footerView.addSubview(contentView)
            
            let button = UIButton(type: .custom)
            button.frame = contentView.frame
            button.titleLabel!.font = UIFont.mpSemiBoldFontWith(size: 13)
            button.setTitleColor(UIColor.mpBlueColor(), for: .normal)
            button.setTitle("FULL RANKINGS", for: .normal)
            button.addTarget(self, action: #selector(fullRankingsButtonTouched), for: .touchUpInside)
            contentView.addSubview(button)
            
            return footerView
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (indexPath.section == 0)
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "FilterTeamRankingsTableViewCell") as? FilterTeamRankingsTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("FilterTeamRankingsTableViewCell", owner: self, options: nil)
                cell = nib![0] as? FilterTeamRankingsTableViewCell
            }
            
            cell?.selectionStyle = .none
            
            //var nationalMode = false
            //if (contextCopy == "National")
            //{
                //nationalMode = true
            //}
            
            let rankingsData = teamRankingsArray[indexPath.row]
            cell?.loadData(rankingsData, gender: gender, sport: sport, context: contextCopy)
            
            return cell!
        }
        else
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "FilterTeamRankingsAuxTableViewCell") as? FilterTeamRankingsAuxTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("FilterTeamRankingsAuxTableViewCell", owner: self, options: nil)
                cell = nib![0] as? FilterTeamRankingsAuxTableViewCell
            }
            
            cell?.selectionStyle = .none
            
            if (self.minimumGamesPlayed.count > 0)
            {
            if (MiscHelper.sportUsesMatchInsteadOfGame(sport: sport) == true)
            {
                cell?.gamesPlayedLabel.text = String(format: "Minimum matches played: %@", self.minimumGamesPlayed)
            }
            else
            {
                cell?.gamesPlayedLabel.text = String(format: "Minimum games played: %@", self.minimumGamesPlayed)
            }
            }
            else
            {
                cell?.gamesPlayedLabel.text = ""
                
                // Shift the learnMoreLabel and chevron up by 10 pixels
                cell?.learnMoreLabel.center = CGPoint(x: (cell?.learnMoreLabel.center.x)!, y: (cell?.learnMoreLabel.center.y)! - 12)
                
                cell?.learnMoreChevron.center = CGPoint(x: (cell?.learnMoreChevron.center.x)!, y: (cell?.learnMoreChevron.center.y)! - 12)
            }
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (indexPath.section == 0)
        {
            let rankingsData = teamRankingsArray[indexPath.row]
            
            let schoolId = rankingsData["teamId"] as! String
            let schoolName = rankingsData["schoolName"] as! String
            let schoolColor = rankingsData["schoolColor1"] as! String
            let schoolMascotUrl = rankingsData["schoolMascotUrl"] as! String
            let schoolCity = rankingsData["schoolCity"] as! String
            let schoolState = rankingsData["schoolState"] as! String
            
            let selectedTeam = Team(teamId: 0, allSeasonId: allSeasonId, gender: gender, sport: sport, teamColor: schoolColor, mascotUrl: schoolMascotUrl, schoolName: schoolName, teamLevel: "Varsity", schoolId: schoolId, schoolState: schoolState, schoolCity: schoolCity, schoolFullName: "", season: seasonCopy, notifications: [])
            
            self.delegate?.newsFilterRankingsViewTeamSelected(selectedTeam: selectedTeam, ssid: ssid)
        }
        else
        {
            self.delegate?.newsFilterRankingsViewLearnMoreButtonTouched()
        }
    }
    
    // MARK: - Button Methods
    
    @objc private func filterButtonTouched()
    {
        self.delegate?.newsFilteredRankingsViewFilterButtonTouched()
        
        // Click Tracking
        let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"rankings-filter-button-click", kClickTrackingModuleNameKey: "arena rankings filter", kClickTrackingModuleLocationKey:"arena rankings home", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:""]
        
        TrackingManager.trackEvent(featureName: "rankings-filter", cData: cData)
    }
    
    @objc private func fullRankingsButtonTouched()
    {
        self.delegate?.newsFilterRankingsViewFullRankingsButtonTouched(urlString: self.fullRankingsUrl)
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
        
        upperTitleLabel = UILabel(frame: CGRect(x: 16, y: 14, width: frame.size.width - 64, height: 36))
        upperTitleLabel.textColor = UIColor.mpBlackColor()
        upperTitleLabel.font = UIFont.mpSemiBoldFontWith(size: 17)
        upperTitleLabel.text = "National Rankings"
        self.addSubview(upperTitleLabel)
        
        upperSubtitleLabel = UILabel(frame: CGRect(x: 16, y: 34, width: frame.size.width - 64, height: 16))
        upperSubtitleLabel.textColor = UIColor.mpGrayColor()
        upperSubtitleLabel.font = UIFont.mpRegularFontWith(size: 13)
        upperSubtitleLabel.text = ""
        self.addSubview(upperSubtitleLabel)
                
        let filterButton = UIButton(type: .custom)
        filterButton.frame = CGRect(x: frame.size.width - 56, y: 12, width: 40, height: 40)
        //filterButton.setImage(UIImage(named: "SortIcon"), for: .normal)
        // Changed in V6.1.2
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .unspecified, scale: .large)
        let largeImage = UIImage(systemName: "slider.horizontal.3", withConfiguration: largeConfig)
        filterButton.tintColor = UIColor.mpBlackColor()
        filterButton.setImage(largeImage, for: .normal)
        filterButton.addTarget(self, action: #selector(filterButtonTouched), for: .touchUpInside)
        self.addSubview(filterButton)
        
        let fixedHeaderNib = Bundle.main.loadNibNamed("FilterTeamRankingsFixedHeaderView", owner: self, options: nil)
        fixedHeaderView = fixedHeaderNib![0] as? FilterTeamRankingsFixedHeaderView
        fixedHeaderView.frame = CGRect(x: 0, y: 60, width: Int(kDeviceWidth), height: 32)
        self.addSubview(fixedHeaderView)
        
        headerLastUpdatedLabel = UILabel(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 32))
        headerLastUpdatedLabel.backgroundColor = UIColor.mpOffWhiteNavColor()
        headerLastUpdatedLabel.textAlignment = .center
        headerLastUpdatedLabel.font = UIFont.mpRegularFontWith(size: 13)
        headerLastUpdatedLabel.textColor = UIColor.mpBlackColor()
        
        emptyRankingsLabel = UILabel(frame: CGRect(x: 16, y: fixedHeaderView.frame.origin.y + fixedHeaderView.frame.size.height + 5, width: kDeviceWidth - 32, height: 120))
        //emptyRankingsLabel.backgroundColor = .yellow
        emptyRankingsLabel.numberOfLines = 0
        emptyRankingsLabel.adjustsFontSizeToFitWidth = true
        emptyRankingsLabel.minimumScaleFactor = 0.8
        emptyRankingsLabel.font = UIFont.mpRegularFontWith(size: 13)
        emptyRankingsLabel.textColor = UIColor.mpBlackColor()
        self.addSubview(emptyRankingsLabel)
        emptyRankingsLabel.isHidden = true
        
        emptyRankingsLabel.text = String(format: "Rankings for the %@ %@ %@ season have not been released yet. Our rankings algorithm requires a minimum number of games played before we can accurately rank teams. Please check back soon.\n\nPrevious seasons are still available using the filter above.", gender, sport, year)
        
        rankingsTableView = UITableView(frame: CGRect(x: 0, y: fixedHeaderView.frame.origin.y + fixedHeaderView.frame.size.height, width: frame.size.width, height: frame.size.height - fixedHeaderView.frame.origin.y - fixedHeaderView.frame.size.height), style: .grouped)
        rankingsTableView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        rankingsTableView.separatorStyle = .none
        rankingsTableView.delegate = self
        rankingsTableView.dataSource = self
        self.addSubview(rankingsTableView)
        
        // Get the data for the table
        self.getTeamRankingsLeaders(gender: gender, sport: sport, year: year, season: season, state: "", context: "National", contextId: "", teamSize: "11")
        
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
