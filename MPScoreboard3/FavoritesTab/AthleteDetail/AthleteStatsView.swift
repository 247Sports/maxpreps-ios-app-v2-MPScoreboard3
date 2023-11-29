//
//  AthleteStatsView.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/20/21.
//

import UIKit

protocol AthleteStatsViewDelegate: AnyObject
{
    func athleteStatsViewDidScroll(_ yScroll : Int)
    func athleteStatsWebButtonTouched(urlString: String, title: String, showLoading: Bool, whiteHeader: Bool)
    func athleteStatsSportOrSeasonChanged()
}

class AthleteStatsView: UIView, UITableViewDelegate, UITableViewDataSource, IQActionSheetPickerViewDelegate, UIScrollViewDelegate
{
    weak var delegate: AthleteStatsViewDelegate?
    
    var selectedAthlete : Athlete?
    
    private var statsTableView: UITableView!
    private var careerFeedArray = [] as! Array<Dictionary<String,Any>>
    private var seasonFeedArray = [] as! Array<Dictionary<String,Any>>
    private var headerObj = [:] as Dictionary<String,Any>
    private var menusArray = [] as! Array<Dictionary<String,Any>>

    private var activeSportIndex = 0
    //private var activeSeasonIndex = 0
    private var activeSeasonObj = [:] as Dictionary<String,Any>
    private var selectedStatCategoryIndex = 0
    
    private var headerContainerView: UIView!
    private var headerTopContainerView: UIView!
    private var headerBottomContainerView: UIView!
    private var statHeaderContainerView: AthleteStatsHeaderViewCell!
    private var careerStatFooterContainerView: AthleteStatsCareerFooterViewCell!
    private var seasonStatFooterContainerView: AthleteStatsFooterViewCell!
    private var seasonButton: UIButton!
    private var itemScrollView: UIScrollView!
    private var leftShadow : UIImageView!
    private var rightShadow : UIImageView!
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Deep Linking
    
    func loadStatsFromLink(linkData:Dictionary<String,Any>)
    {
        // The linkData object contains the sport property for careerMode = true, or
        // contains the sport, athleteId, schoolId, and ssid for careerMode = false
        
        //MBProgressHUD.showAdded(to: self, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        let careerId = self.selectedAthlete!.careerId
                
        CareerFeeds.getCareerStatsHeader(careerId) { [self] (result, error) in
            
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
            
            if error == nil
            {
                print("Get career stats header success.")
                let menus = result!["menus"] as! Array<Dictionary<String,Any>>
                self.menusArray = menus
                
                if (menus.count == 0)
                {
                    headerContainerView.isHidden = true
                    statsTableView.isHidden = true
                    return
                }
                
                headerContainerView.isHidden = false
                statsTableView.isHidden = false
                    
                let sport = linkData["sport"] as! String
                let careerMode = linkData["careerMode"] as! Bool
                SharedData.statsHorizontalScrollValue = 0
                
                // Set the activeSportIndex
                var index = 0
                for menus in menusArray
                {
                    let sportTitle = menus["sport"] as! String
                    if (sport == sportTitle)
                    {
                        break
                    }
                    index += 1
                }
                
                activeSportIndex = index
                
                // Call the stats feeds
                if (careerMode == true)
                {
                    // Set the active season
                    let menuItem = menusArray[activeSportIndex]
                    let seasons = menuItem["items"] as! Array<Dictionary<String,Any>>
                    
                    // Career is always at 0
                    let season = seasons[0]
                    
                    activeSeasonObj = season
                    
                    self.buildHeaderView()
                    
                    // Wait a bit to update the sport and season buttons in case they haven't finished being initialized in the buildHeaderView method called above
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                    { [self] in
                        
                        // Find the button by matching the title with the sport
                        for subview in headerTopContainerView.subviews as Array<UIView>
                        {
                            if (subview is UIButton)
                            {
                                let button = subview as! UIButton
                                button.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
                                button.backgroundColor = UIColor.mpWhiteColor()
                                
                                if (button.titleLabel?.text == sport)
                                {
                                    let colorString = self.selectedAthlete?.schoolColor
                                    let schoolColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
                                    button.backgroundColor = schoolColor
                                    button.setTitleColor(UIColor.mpWhiteColor(), for: .normal)
                                }
                            }
                        }
                        
                        // Update the season button
                        let seasonButtonWidth = "Career".widthOfString(usingFont: UIFont.mpSemiBoldFontWith(size: 13)) + 38
                        seasonButton.setTitle("Career", for: .normal)
                        seasonButton.frame = CGRect(x: headerBottomContainerView.frame.size.width - 20 - seasonButtonWidth, y: 30, width: seasonButtonWidth , height: 30)
                        
                        self.getCareerStats()
                    }
                }
                else
                {
                    // Set the activeSeasonObj by iterating though the menus array and matching the schoolId and ssid
                                    
                    let schoolId = linkData["schoolId"] as! String
                    let ssid = linkData["ssid"] as! String
                    
                    let menuItem = menusArray[activeSportIndex]
                    let seasons = menuItem["items"] as! Array<Dictionary<String,Any>>
                    
                    // Make sure there are stats
                    if (seasons.count == 0)
                    {
                        headerContainerView.isHidden = true
                        statsTableView.isHidden = true
                        
                        MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "No Stats", message: "There are no stats entered for this season.", lastItemCancelType: false) { (tag) in
                        }
                        
                        return
                    }

                    for season in seasons
                    {
                        let testSSID = season["sportSeasonId"] as! String
                        let testSchoolId = season["schoolId"] as! String
                        
                        if ((testSchoolId == schoolId) && (testSSID == ssid))
                        {
                            //activeSeasonIndex = index
                            activeSeasonObj = season
                            
                            self.buildHeaderView()
                            
                            // Wait a bit to update the sport and season buttons in case they haven't finished being initialized in the buildHeaderView method called above
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                            { [self] in
                                
                                // Find the button by matching the title with the sport
                                for subview in headerTopContainerView.subviews as Array<UIView>
                                {
                                    if (subview is UIButton)
                                    {
                                        let button = subview as! UIButton
                                        button.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
                                        button.backgroundColor = UIColor.mpWhiteColor()
                                        
                                        if (button.titleLabel?.text == sport)
                                        {
                                            let colorString = self.selectedAthlete?.schoolColor
                                            let schoolColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
                                            button.backgroundColor = schoolColor
                                            button.setTitleColor(UIColor.mpWhiteColor(), for: .normal)
                                        }
                                    }
                                }
                                
                                // Update the season button's text and width
                                let title = season["text"] as! String
                                let seasonButtonWidth = title.widthOfString(usingFont: UIFont.mpSemiBoldFontWith(size: 13)) + 38
                                
                                seasonButton.frame = CGRect(x: headerBottomContainerView.frame.size.width - 20 - seasonButtonWidth, y: 30, width: seasonButtonWidth , height: 28)
                                seasonButton.setTitle(title, for: .normal)
                                
                                self.getSeasonStats()
                            }
                            break
                        }
                    }
                }
            }
            else
            {
                print("Get career stats header failed.")
                
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "There was a problem getting the stats header from the server.", lastItemCancelType: false) { (tag) in
                }
            }
        }
 
    }
    
    // MARK: - Get Stats Navigation Header
    
    func getStatsNavigationHeader()
    {
        // Show the busy indicator
        //MBProgressHUD.showAdded(to: self, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        let careerId = self.selectedAthlete!.careerId
        
        CareerFeeds.getCareerStatsHeader(careerId) { [self] (result, error) in
            
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
            
            if error == nil
            {
                print("Get career stats header success.")
                let menus = result!["menus"] as! Array<Dictionary<String,Any>>
                self.menusArray = menus
                
                headerContainerView.isHidden = false
                statsTableView.isHidden = false
                
                // Get the first item and either call getCaareerStats or getSeasonStats
                let menuItem = self.menusArray[activeSportIndex]
                let seasons = menuItem["items"] as! Array<Dictionary<String,Any>>
                let season = seasons[0]
                
                // Set the activeSeasonObj
                activeSeasonObj = season
                
                self.buildHeaderView()
                
                let text = season["text"] as! String
                
                if (text == "Career")
                {
                    self.getCareerStats()
                }
                else
                {
                    self.getSeasonStats()
                }
                
                
            }
            else
            {
                print("Get career stats header failed.")
                
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "There was a problem getting the stats header from the server.", lastItemCancelType: false) { (tag) in
                }
            }
        }
    }
    
    // MARK: - Get Career Stats
    
    func getCareerStats()
    {
        // Show the busy indicator
        //MBProgressHUD.showAdded(to: self, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        let careerId = self.selectedAthlete!.careerId
        //let menuItem = menusArray[activeSportIndex]
        //let seasons = menuItem["items"] as! Array<Dictionary<String,Any>>
        //let season = seasons[activeSeasonIndex]
        let genderSport = activeSeasonObj["genderSportId"] as! String
        
        CareerFeeds.getCareerStats(careerId, genderSport:genderSport.lowercased()) { [self] (result, error) in
            
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
            
            if error == nil
            {
                print("Get career stats success.")
                self.careerFeedArray = result!
               
                // Added to prevent a crash if no career data is returned (shouldn't happen, but it has on occasion)
                if (self.careerFeedArray.count > 0)
                {
                    self.buildStatCategoryButtons()
                    self.loadStatsHeaderAndFooter()
                    self.statsTableView.reloadData()
                }
            }
            else
            {
                print("Get career stats failed.")
               
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "There was a problem getting career stats for this sport.", lastItemCancelType: false) { (tag) in
                }
            }
        }
    }
    
    // MARK: - Get Season Stats
    
    func getSeasonStats()
    {
        // Show the busy indicator
        //MBProgressHUD.showAdded(to: self, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        //let menuItem = menusArray[activeSportIndex]
        //let seasons = menuItem["items"] as! Array<Dictionary<String,Any>>
        //let season = seasons[activeSeasonIndex]
        let athleteId = activeSeasonObj["athleteId"] as! String
        let schoolId = activeSeasonObj["schoolId"] as! String
        let ssid = activeSeasonObj["sportSeasonId"] as! String
        
        CareerFeeds.getSeasonStats(athleteId, teamId:schoolId, ssid:ssid) { [self] (result, error) in
            
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
            
            if error == nil
            {
                print("Get season stats success.")
                self.seasonFeedArray = result!
                
                self.buildStatCategoryButtons()
                
                self.loadStatsHeaderAndFooter()
                
                self.statsTableView.reloadData()
            }
            else
            {
                print("Get season stats failed.")
                
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "There was a problem getting season stats for this sport.", lastItemCancelType: false) { (tag) in
                }
            }
        }
    }
    
    // MARK: - Header View Methods
    
    private func buildHeaderView()
    {
        // Remove any existing subviews in the headerTopContainerView
        for subview in headerTopContainerView.subviews
        {
            subview.removeFromSuperview()
        }
        
        // Get rid of everything but the itemScrollView and statHeaderContainerView in the headerBottomContainerView
        for subview in headerBottomContainerView.subviews
        {
            if ((subview != itemScrollView) && (subview != statHeaderContainerView))
            {
                subview.removeFromSuperview()
            }
        }
        
        // Add the sport buttons
        var index = 0
        var xStart = 10
        let spacing = 10
        let pad = 12
        
        for menu in menusArray
        {
            // Skip sports that have no data
            let items = menu["items"] as! Array<Any>
            if (items.count == 0)
            {
                continue
            }
            
            let buttonTitle = menu["sport"] as! String
            let buttonWidth = buttonTitle.widthOfString(usingFont: UIFont.mpSemiBoldFontWith(size: 12)) + CGFloat(2 * pad)
            let button = UIButton(frame: CGRect(x:xStart, y: 8, width: Int(buttonWidth), height: 28))
            button.titleLabel!.font = UIFont.mpSemiBoldFontWith(size: 12)
            button.setTitle(buttonTitle, for: .normal)
            button.layer.cornerRadius = 14
            //button.clipsToBounds = true
            button.tag = 100 + index
            
            // Add a shadow to the button
            button.layer.masksToBounds = false
            button.layer.shadowColor = UIColor(white: 0.6, alpha: 1.0).cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 2.0)
            button.layer.shadowRadius = 2
            button.layer.shadowOpacity = 0.5
            
            button.addTarget(self, action: #selector(sportButtonTouched(_:)), for: .touchUpInside)
            headerTopContainerView.addSubview(button)
            
            if (index == 0)
            {
                let colorString = self.selectedAthlete?.schoolColor
                let schoolColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
                button.backgroundColor = schoolColor
                button.setTitleColor(UIColor.mpWhiteColor(), for: .normal)
            }
            else
            {
                button.backgroundColor = UIColor.mpWhiteColor()
                button.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
            }
            index += 1
            xStart = xStart + Int(buttonWidth) + spacing
        }
        
        // Add the title label
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 18, width: 100, height: 22))
        titleLabel.font = UIFont.mpBoldFontWith(size: 19)
        titleLabel.textColor = UIColor.mpBlackColor()
        titleLabel.text = "Stats"
        headerBottomContainerView.addSubview(titleLabel)
        
        // Add the stat definition button
        let statDefinitionButton = UIButton(frame: CGRect(x: 20, y: 40, width: 140, height: 30))
        statDefinitionButton.titleLabel!.font = UIFont.mpRegularFontWith(size: 13)
        statDefinitionButton.contentHorizontalAlignment = .left
        statDefinitionButton.setTitle("View Stat Definitions", for: .normal)
        statDefinitionButton.setTitleColor(UIColor.mpBlueColor(), for: .normal)
        statDefinitionButton.addTarget(self, action: #selector(statDefinitionButtonTouched(_:)), for: .touchUpInside)
        headerBottomContainerView.addSubview(statDefinitionButton)
        
        // Add the season selector button
        //let menuItem = menusArray[activeSportIndex]
        //let seasons = menuItem["items"] as! Array<Dictionary<String,Any>>
        //let season = seasons[activeSeasonIndex]
        let seasonTitle = activeSeasonObj["text"] as! String
        let seasonButtonWidth = seasonTitle.widthOfString(usingFont: UIFont.mpSemiBoldFontWith(size: 13)) + 38
        
        seasonButton = UIButton(frame: CGRect(x: headerBottomContainerView.frame.size.width - 20 - seasonButtonWidth, y: 30, width: seasonButtonWidth , height: 28))
        seasonButton.titleLabel!.font = UIFont.mpRegularFontWith(size: 13)
        seasonButton.contentHorizontalAlignment = .left
        seasonButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 11, bottom: 0, right: -11)
        seasonButton.setTitle(seasonTitle, for: .normal)
        seasonButton.setTitleColor(UIColor.mpBlackColor(), for: .normal)
        seasonButton.layer.cornerRadius = 8
        seasonButton.layer.borderWidth = 1
        seasonButton.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        seasonButton.clipsToBounds = true
        seasonButton.addTarget(self, action: #selector(seasonButtonTouched(_:)), for: .touchUpInside)
        headerBottomContainerView.addSubview(seasonButton)
        
        // Add a down chevron onto the button
        let chevron = UIImageView(frame: CGRect(x: seasonButton.frame.size.width - 20, y: 12, width: 12, height: 6))
        chevron.contentMode = .scaleAspectFit
        chevron.autoresizingMask = .flexibleLeftMargin // Anchor to the right edge
        chevron.image = UIImage(named: "SmallDownArrowGray")
        chevron.isUserInteractionEnabled = true
        seasonButton.addSubview(chevron)
        
    }
    
    private func buildStatCategoryButtons()
    {
        selectedStatCategoryIndex = 0
        
        // Remove the subviews from the itemScrollView
        for subview in itemScrollView.subviews
        {
            subview.removeFromSuperview()
        }
        
        // Build the buttons
        var overallWidth = 0
        let pad = 10
        var leftPad = 0
        let rightPad = 10
        var index = 0
        
        // Pick from either the career or seasaon arrays
        var categories = [] as! Array<Dictionary<String,Any>>
        
        //if (activeSeasonIndex == 0)
        let text = activeSeasonObj["text"] as! String
        if (text == "Career")
        {
            categories = careerFeedArray
        }
        else
        {
            categories = seasonFeedArray
        }
        
        for category in categories
        {
            var title = category["groupName"] as! String
            
            if (title.count == 0)
            {
                title = "Unknown"
            }
            
            let itemWidth = Int(title.widthOfString(usingFont: UIFont.mpSemiBoldFontWith(size: 13))) + (2 * pad)
            let tag = index + 100
            
            // Add the left pad to the first cell
            if (index == 0)
            {
                leftPad = 10
            }
            else
            {
                leftPad = 0
            }
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: overallWidth + leftPad, y: 0, width: itemWidth, height: Int(itemScrollView.frame.size.height))
            button.backgroundColor = .clear
            button.setTitle(title, for: .normal)
            button.tag = tag
            button.addTarget(self, action: #selector(self.statCategoryItemTouched), for: .touchUpInside)
            
            // Add a line at the bottom of each button
            let textWidth = itemWidth - (2 * pad)
            let line = UIView(frame: CGRect(x: (button.frame.size.width - CGFloat(textWidth)) / 2.0, y: button.frame.size.height - 4, width: CGFloat(textWidth), height: 4))
            
            let colorString = self.selectedAthlete?.schoolColor
            let schoolColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
            line.backgroundColor = schoolColor

            // Round the top corners
            line.clipsToBounds = true
            line.layer.cornerRadius = 4
            line.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            
            button.addSubview(line)
            
            if (index == 0)
            {
                button.titleLabel?.font = UIFont.mpBoldFontWith(size: 13)
                button.setTitleColor(UIColor.mpBlackColor(), for: .normal)
            }
            else
            {
                button.titleLabel?.font = UIFont.mpRegularFontWith(size: 13)
                button.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
                
                // Hide the inactive horiz line
                let horizLine = button.subviews[0]
                horizLine.isHidden = true
            }
            
            itemScrollView.addSubview(button)
            
            index += 1
            overallWidth += (itemWidth + leftPad)
        }
        
        itemScrollView.contentSize = CGSize(width: overallWidth + rightPad, height: Int(itemScrollView.frame.size.height))
        
        // Delete any existing shadows
        if (leftShadow != nil)
        {
            leftShadow.removeFromSuperview()
        }
        
        if (rightShadow != nil)
        {
            rightShadow.removeFromSuperview()
        }
        
        // Add the left and right shadows
        leftShadow = UIImageView(frame: CGRect(x: 0, y: Int(itemScrollView.frame.origin.y), width: 70, height: Int(itemScrollView.frame.size.height)))
        leftShadow.image = UIImage(named: "LeftShadowWhite")
        leftShadow.clipsToBounds = true
        leftShadow.tag = 200
        headerBottomContainerView.addSubview(leftShadow)
        leftShadow.isHidden = true
        
        rightShadow = UIImageView(frame: CGRect(x: Int(kDeviceWidth) - 70, y: Int(itemScrollView.frame.origin.y), width: 70, height: Int(itemScrollView.frame.size.height)))
        rightShadow.image = UIImage(named: "RightShadowWhite")
        rightShadow.clipsToBounds = true
        rightShadow.tag = 201
        headerBottomContainerView.addSubview(rightShadow)
        
        if (itemScrollView.contentSize.width <= itemScrollView.frame.size.width)
        {
            rightShadow.isHidden = true
        }
    }
    
    private func loadStatsHeaderAndFooter()
    {
        // Use different data stores for career and season stats
        //if (activeSeasonIndex == 0) // Career
        let text = activeSeasonObj["text"] as! String
        if (text == "Career")
        {
            // Load the titles using the active stat category from the first group
            let activeGroup = careerFeedArray[selectedStatCategoryIndex]
            let careerSeasonStats = activeGroup["careerSeasonStats"] as! Array<Dictionary<String,Any>>
            let careerSeasonStat = careerSeasonStats[0]
            let stats = careerSeasonStat["stats"] as! Array<Dictionary<String,Any>>
            
            var statTitles = [] as! Array<String>
            for stat in stats
            {
                let title = stat["header"] as! String
                statTitles.append(title)
            }
            
            let statHeaderObj = ["leftText":"YEAR", "centerText":"GD", "rightText":"TEAM", "titles":statTitles] as [String : Any]
            
            statHeaderContainerView.loadData(statsData: statHeaderObj)
            
            // Footer
            let careerSeasonTotals = activeGroup["careerTotalStats"] as! Dictionary<String,Any>
            let footerData = careerSeasonTotals["stats"] as! Array<Dictionary<String,Any>>
            
            careerStatFooterContainerView.loadData(statTotalsArray: footerData)
        }
        else // Season
        {
            // Load the titles using the active stat category from the first group
            if (seasonFeedArray.count > 0)
            {
                let activeGroup = seasonFeedArray[selectedStatCategoryIndex]
                let seasonContestStats = activeGroup["seasonContestStats"] as! Array<Dictionary<String,Any>>
                let seasonContestStat = seasonContestStats[0]
                let stats = seasonContestStat["stats"] as! Array<Dictionary<String,Any>>
                
                var statTitles = [] as! Array<String>
                for stat in stats
                {
                    let title = stat["header"] as! String
                    statTitles.append(title)
                }
                
                let statHeaderObj = ["leftText":"DATE", "centerText":"RESULT", "rightText":"OPP", "titles":statTitles] as [String : Any]
                
                statHeaderContainerView.loadData(statsData: statHeaderObj)
                
                // Footer
                let seasonTotals = activeGroup["seasonTotalStats"] as! Dictionary<String,Any>
                let footerData = seasonTotals["stats"] as! Array<Dictionary<String,Any>>
                
                seasonStatFooterContainerView.loadData(statTotalsArray: footerData)
            }
            else
            {
                let statHeaderObj = ["leftText":"--", "centerText":"--", "rightText":"--", "titles":["--"]] as [String : Any]
                
                statHeaderContainerView.loadData(statsData: statHeaderObj)
                seasonStatFooterContainerView.loadData(statTotalsArray: [["value":""]])
                
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "No Stats", message: "There are no stats available for this sport.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - Button Methods
    
    @objc private func sportButtonTouched(_ button: UIButton)
    {
        // Skip touches to the same button
        if (activeSportIndex == button.tag - 100)
        {
            return
        }
        
        activeSportIndex = button.tag - 100
        
        // Change the color and background of all buttons
        for subview in headerTopContainerView.subviews as Array<UIView>
        {
            if (subview is UIButton)
            {
                let button = subview as! UIButton
                button.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
                button.backgroundColor = UIColor.mpWhiteColor()
            }
        }
        
        let colorString = self.selectedAthlete?.schoolColor
        let schoolColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
        button.backgroundColor = schoolColor
        button.setTitleColor(UIColor.mpWhiteColor(), for: .normal)
        
        // Reset the season button
        //activeSeasonIndex = 0
        let menuItem = menusArray[activeSportIndex]
        let seasons = menuItem["items"] as! Array<Dictionary<String,Any>>
        let season = seasons[0]
        let seasonTitle = season["text"] as! String
        let seasonButtonWidth = seasonTitle.widthOfString(usingFont: UIFont.mpSemiBoldFontWith(size: 13)) + 38
        seasonButton.setTitle(seasonTitle, for: .normal)
        seasonButton.frame = CGRect(x: headerBottomContainerView.frame.size.width - 20 - seasonButtonWidth, y: 30, width: seasonButtonWidth , height: 30)
        
        SharedData.statsHorizontalScrollValue = 0
        
        activeSeasonObj = season
        let text = season["text"] as! String
        
        if (text == "Career")
        {
            self.getCareerStats()
        }
        else
        {
            self.getSeasonStats()
        }
        
        // Call the delegate when the sport changes, so it can be tracked
        self.delegate?.athleteStatsSportOrSeasonChanged()
        
    }
    
    @objc private func statDefinitionButtonTouched(_ button: UIButton)
    {
        let menuItem = menusArray[activeSportIndex]
        let urlString = menuItem["statDefinitionsUrl"] as! String
        
        if (urlString.count > 0)
        {
            self.delegate?.athleteStatsWebButtonTouched(urlString: urlString, title: "Stat Definitions", showLoading: false, whiteHeader: false)
        }
        else
        {
            MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "Stat definitions are not avaiable for this sport.", lastItemCancelType: false) { (tag) in
            }
        }
    }
    
    @objc private func seasonButtonTouched(_ button: UIButton)
    {
        // Gather the season titles for the current sport
        var titles = [] as! Array<String>
        let menuItem = menusArray[activeSportIndex]
        let seasons = menuItem["items"] as! Array<Dictionary<String,Any>>
        
        for season in seasons
        {
            let title = season["text"] as! String
            titles.append(title)
        }
        
        let picker = IQActionSheetPickerView(title: "", delegate: self)
        picker.toolbarButtonColor = UIColor.mpWhiteColor()
        picker.toolbarTintColor = UIColor.mpPickerToolbarColor()
        picker.titlesForComponents = [titles]
        picker.show()
    }
    
    @objc private func statCategoryItemTouched(_ button: UIButton)
    {
        // Change the font of the all of the buttons to regular, hide the underline view
        for subview in itemScrollView.subviews as Array<UIView>
        {
            if (subview is UIButton)
            {
                let button = subview as! UIButton
                button.titleLabel?.font = UIFont.mpRegularFontWith(size: 13)
                button.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
                
                let horizLine = button.subviews[0]
                horizLine.isHidden = true
            }
        }
        
        // Set the selected item's font to bold
        selectedStatCategoryIndex = button.tag - 100
        button.titleLabel?.font = UIFont.mpBoldFontWith(size: 13)
        button.setTitleColor(UIColor.mpBlackColor(), for: .normal)
        
        // Show the underline on the button
        let horizLine = button.subviews[0]
        horizLine.isHidden = false
        
        SharedData.statsHorizontalScrollValue = 0
        statsTableView.reloadData()
        self.loadStatsHeaderAndFooter()
    }
    
    @objc private func opponentButtonTouched(_ button: UIButton)
    {
        let index = button.tag - 100
        
        let activeGroup = seasonFeedArray[selectedStatCategoryIndex]
        let seasonContestStats = activeGroup["seasonContestStats"] as! Array<Dictionary<String,Any>>
        
        let seasonContestStat = seasonContestStats[index]
        let urlString = seasonContestStat["opponentUrl"] as! String
        
        self.delegate?.athleteStatsWebButtonTouched(urlString: urlString, title: "Schedule", showLoading: true, whiteHeader: false)
    }
    
    @objc private func contestButtonTouched(_ button: UIButton)
    {
        let index = button.tag - 100
        
        let activeGroup = seasonFeedArray[selectedStatCategoryIndex]
        let seasonContestStats = activeGroup["seasonContestStats"] as! Array<Dictionary<String,Any>>
        
        let seasonContestStat = seasonContestStats[index]
        if let urlString = seasonContestStat["contestUrl"] as? String
        {
            self.delegate?.athleteStatsWebButtonTouched(urlString: urlString, title: "Box Score", showLoading: true, whiteHeader: true)
        }
    }
    
    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelectTitles titles: [String])
    {
        let seasonTitle = titles.first
        
        // Skip if nothing changed
        if (seasonTitle == seasonButton.titleLabel?.text)
        {
            return
        }
        
        // Update the season button
        let seasonButtonWidth = seasonTitle!.widthOfString(usingFont: UIFont.mpSemiBoldFontWith(size: 13)) + 38
        seasonButton.setTitle(seasonTitle, for: .normal)
        seasonButton.frame = CGRect(x: headerBottomContainerView.frame.size.width - 20 - seasonButtonWidth, y: 30, width: seasonButtonWidth , height: 30)
        
        // Update the selectedSeasonIndex
        //var titles = [] as! Array<String>
        let menuItem = menusArray[activeSportIndex]
        let seasons = menuItem["items"] as! Array<Dictionary<String,Any>>
        
        for season in seasons
        {
            let title = season["text"] as! String
            //titles.append(title)
            if (seasonTitle == title)
            {
                activeSeasonObj = season
                break
            }
        }
        
        //activeSeasonIndex = titles.firstIndex(of: seasonTitle!)!
        
        SharedData.statsHorizontalScrollValue = 0
        
        if (seasonTitle == "Career")
        {
            self.getCareerStats()
        }
        else
        {
            self.getSeasonStats()
        }
        
        // Tracking
        self.delegate?.athleteStatsSportOrSeasonChanged()
    }
    
    func actionSheetPickerViewDidCancel(_ pickerView: IQActionSheetPickerView)
    {
        
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Use different data stores for career and season stats
        //if (activeSeasonIndex == 0) // Career
        
        // Make sure the activeSeasonObj has been loaded
        if let text = activeSeasonObj["text"] as? String
        {
            if (text == "Career")
            {
                if (careerFeedArray.count > 0)
                {
                    let activeGroup = careerFeedArray[selectedStatCategoryIndex]
                    let careerSeasonStats = activeGroup["careerSeasonStats"] as! Array<Dictionary<String,Any>>
                    
                    return careerSeasonStats.count
                }
                else
                {
                    return 0
                }
            }
            else // Season
            {
                if (seasonFeedArray.count > 0)
                {
                    let activeGroup = seasonFeedArray[selectedStatCategoryIndex]
                    let seasonStats = activeGroup["seasonContestStats"] as! Array<Dictionary<String,Any>>
                    
                    return seasonStats.count
                }
                else
                {
                    return 0
                }
            }
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 32.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 366 //180.0 + 44 + 110 + 32
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        //if (activeSeasonIndex == 0)
        if let text = activeSeasonObj["text"] as? String
        {
            if (text == "Career")
            {
                // Career Mode
                if (careerFeedArray.count > 0)
                {
                    let activeGroup = careerFeedArray[selectedStatCategoryIndex]
                    let careerSeasonStats = activeGroup["careerSeasonStats"] as! Array<Dictionary<String,Any>>
                    let tableHeight = Int((careerSeasonStats.count + 1) * 32) + 92
                    
                    let footerPad = Int(self.frame.size.height) - tableHeight - 186
                    
                    if (footerPad > 0)
                    {
                        return CGFloat(92 + footerPad + 28)
                    }
                    else
                    {
                        return 92
                    }
                }
                else
                {
                    return 92
                }
            }
            else
            {
                // Season Mode
                if (seasonFeedArray.count > 0)
                {
                    let activeGroup = seasonFeedArray[selectedStatCategoryIndex]
                    let seasonContestStats = activeGroup["seasonContestStats"] as! Array<Dictionary<String,Any>>
                    let tableHeight = Int((seasonContestStats.count + 1) * 32) + 48
                    
                    let footerPad = Int(self.frame.size.height) - tableHeight - 186
                    
                    if (footerPad > 0)
                    {
                        return CGFloat(48 + footerPad + 28)
                    }
                    else
                    {
                        return 48 + 62 // Ad pad
                    }
                }
                else
                {
                    return 48 + 62 // Ad pad
                }
            }
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 366))
        view.backgroundColor = UIColor.mpWhiteColor()
        
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        //if (activeSeasonIndex == 0)
        if let text = activeSeasonObj["text"] as? String
        {
            if (text == "Career")
            {
                // Career Mode
                return careerStatFooterContainerView
            }
            else
            {
                return seasonStatFooterContainerView
            }
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // Stats cells
        var cell = tableView.dequeueReusableCell(withIdentifier: "AthleteStatsTableViewCell") as? AthleteStatsTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("AthleteStatsTableViewCell", owner: self, options: nil)
            cell = nib![0] as? AthleteStatsTableViewCell
        }
        
        cell?.selectionStyle = .none
                
        if ((indexPath.row % 2) == 1)
        {
            cell?.contentView.backgroundColor = UIColor.mpOffWhiteNavColor()
        }
        else
        {
            cell?.contentView.backgroundColor = UIColor.mpWhiteColor()
        }
        
        // Use different data stores for career and season stats
        //if (activeSeasonIndex == 0) // Career
        if let text = activeSeasonObj["text"] as? String
        {
            if (text == "Career")
            {
                let activeGroup = careerFeedArray[selectedStatCategoryIndex]
                let careerSeasonStats = activeGroup["careerSeasonStats"] as! Array<Dictionary<String,Any>>
                
                let careerSeasonStat = careerSeasonStats[indexPath.row]
                let leftTitle = careerSeasonStat["year"] as! String
                let centerTitle = careerSeasonStat["grade"] as! String
                let rightTitle = careerSeasonStat["team"] as! String
                let stats = careerSeasonStat["stats"] as! Array<Dictionary<String,Any>>
                
                let data = ["leftTitle":leftTitle, "centerTitle":centerTitle, "rightTitle":rightTitle, "stats":stats] as [String : Any]
                
                cell?.loadData(statsData: data, careerMode: true)
            }
            else // Season
            {
                let activeGroup = seasonFeedArray[selectedStatCategoryIndex]
                let seasonContestStats = activeGroup["seasonContestStats"] as! Array<Dictionary<String,Any>>
                
                let seasonContestStat = seasonContestStats[indexPath.row]
                let leftTitle = seasonContestStat["date"] as! String
                var centerTitle = ""
                
                // This is added to handle the feed update that separated the score from the result
                if let score =  seasonContestStat["score"] as? String
                {
                    let result = seasonContestStat["result"] as! String
                    centerTitle = result + " " + score
                }
                else
                {
                    centerTitle = seasonContestStat["result"] as! String
                }
                
                let rightTitle = seasonContestStat["opponent"] as! String
                let stats = seasonContestStat["stats"] as! Array<Dictionary<String,Any>>
                
                let data = ["leftTitle":leftTitle, "centerTitle":centerTitle, "rightTitle":rightTitle, "stats":stats] as [String : Any]
                
                cell?.loadData(statsData: data, careerMode: false)
                
                // Add a target for the rightButton
                cell?.rightButton.tag = 100 + indexPath.row
                cell?.rightButton.addTarget(self, action: #selector(opponentButtonTouched), for: .touchUpInside)
                
                // Add a target for the centerOvelayButton
                cell?.centerOverlayButton.tag = 100 + indexPath.row
                cell?.centerOverlayButton.addTarget(self, action: #selector(contestButtonTouched), for: .touchUpInside)
            }
        }

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Set TableView Scroll Location
    
    func setTableViewScrollLocation(yScroll: Int)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
        {
            self.statsTableView.contentOffset = CGPoint(x: 0, y: yScroll)
            self.headerContainerView.transform = CGAffineTransform(translationX: 0, y: -CGFloat(yScroll))
            
            self.delegate?.athleteStatsViewDidScroll(yScroll)
        }
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if (scrollView == itemScrollView)
        {
            let xScroll = scrollView.contentOffset.x
            
            if (xScroll > 0)
            {
                leftShadow.isHidden = false
            }
            else
            {
                leftShadow.isHidden = true
            }
            
            if (xScroll >= scrollView.contentSize.width - scrollView.frame.size.width)
            {
                rightShadow.isHidden = true
            }
            else
            {
                rightShadow.isHidden = false
            }
        }
        else
        {
            let yScroll = Int(scrollView.contentOffset.y)
            
            if (yScroll <= 0)
            {
                headerContainerView.transform = CGAffineTransform.identity
            }
            else if ((yScroll > 0) && (yScroll < 180))
            {
                headerContainerView.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(yScroll))
            }
            else
            {
                headerContainerView.transform = CGAffineTransform.init(translationX: 0, y: -CGFloat(180))
            }
           
            self.delegate?.athleteStatsViewDidScroll(Int(scrollView.contentOffset.y))
        }
    }
    
    // MARK: - Init Method
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)

        // Add the tableView
        statsTableView = UITableView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), style: .grouped)
        statsTableView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        statsTableView.delegate = self
        statsTableView.dataSource = self
        statsTableView.separatorStyle = .none
        statsTableView.showsVerticalScrollIndicator = false
        //statsTableView.bounces = false
        self.addSubview(statsTableView)
        
        headerContainerView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 366))
        headerContainerView.backgroundColor = .clear
        self.addSubview(headerContainerView)
        
        headerContainerView.isHidden = true
        statsTableView.isHidden = true
        
        headerTopContainerView = UIView(frame: CGRect(x: 0, y: 180, width: kDeviceWidth, height: 56))
        headerTopContainerView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        headerContainerView.addSubview(headerTopContainerView)
        
        headerBottomContainerView = UIView(frame: CGRect(x: 0, y: 224, width: kDeviceWidth, height: 142))
        headerBottomContainerView.backgroundColor = UIColor.mpWhiteColor()
        headerBottomContainerView.layer.cornerRadius = 12
        headerBottomContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        headerBottomContainerView.clipsToBounds = true
        headerContainerView.addSubview(headerBottomContainerView)
        
        itemScrollView = UIScrollView(frame: CGRect(x: 0, y: 66, width: kDeviceWidth, height: 44))
        itemScrollView.delegate = self
        headerBottomContainerView.addSubview(itemScrollView)
        
        // Add the stats header view
        let headerNib = Bundle.main.loadNibNamed("AthleteStatsHeaderViewCell", owner: self, options: nil)
        statHeaderContainerView = headerNib![0] as? AthleteStatsHeaderViewCell
        statHeaderContainerView.frame = CGRect(x: 0, y: 110, width: kDeviceWidth, height: 32)
        headerBottomContainerView.addSubview(statHeaderContainerView)
        
        // initialize the two stats footer views
        let footerNib1 = Bundle.main.loadNibNamed("AthleteStatsCareerFooterViewCell", owner: self, options: nil)
        careerStatFooterContainerView = footerNib1![0] as? AthleteStatsCareerFooterViewCell
        careerStatFooterContainerView.frame = CGRect(x: 0, y: 0, width: kDeviceWidth, height: 92)
        
        let footerNib2 = Bundle.main.loadNibNamed("AthleteStatsFooterViewCell", owner: self, options: nil)
        seasonStatFooterContainerView = footerNib2![0] as? AthleteStatsFooterViewCell
        seasonStatFooterContainerView.frame = CGRect(x: 0, y: 0, width: kDeviceWidth, height: 48)
        
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
