//
//  AthleteTimelineView.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/19/21.
//

import UIKit

protocol AthleteTimelineViewDelegate: AnyObject
{
    func athleteTimelineViewDidScroll(_ yScroll : Int)
    func athleteTimelineWebButtonTouched(urlString: String, title: String)
    func athleteTimelineVideoButtonTouched(videoId: String)
    func athleteTimelineShareButtonTouched(urlString: String)
    func athleteTimelineJumpToTab(named: String)
}

class AthleteTimelineView: UIView, UITableViewDelegate, UITableViewDataSource, TaggedPhotosTableViewCellDelegate
{
    weak var delegate: AthleteTimelineViewDelegate?
    
    private var timelineTableView: UITableView!
    private var itemArray = [] as Array<Dictionary<String,Any>>
    private var pageNumber = 1
    private let kMaxItems = 25
    private var showFooter = false
    private var footerView: UIView!
    private var teamColor: UIColor!
    private var getMoreButton: UIButton!
    
    var selectedAthlete : Athlete?
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Get Timeline Data
    
    func getCareerTimelineData()
    {
        // Update the getMoreButton's color
        let colorString = selectedAthlete?.schoolColor
        teamColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
        
        getMoreButton.backgroundColor = teamColor
        
        // Show the busy indicator
        //MBProgressHUD.showAdded(to: self, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        let careerId = self.selectedAthlete!.careerId
        
        CareerFeeds.getCareerTimeline(careerId, pageNumber: pageNumber, maxItems: kMaxItems) { [self] (result, error) in
            
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
                print("Get career timeline success.")
                let resultArray = result!["timelineItems"] as! Array<Dictionary<String,Any>>
                
                if (resultArray.count > 0)
                {
                    // Append the results so the array will grow with each request
                    itemArray.append(contentsOf:resultArray)
                    
                    /*
                    // Add the stats, and roster types for testing
                    if (self.selectedAthlete?.firstName == "Whitney") && (self.selectedAthlete?.lastName == "Montoya")
                    {
                        //let statsItem = ["type": 4]
                        //itemArray.append(statsItem)
                        
                        //let rosterItem = ["type": 5]
                        //itemArray.append(rosterItem)
                        
                        //let pogItem = ["type": 6]
                        //itemArray.append(pogItem)
                        
                        //let poyItem = ["type": 7]
                        //itemArray.append(poyItem)
                        
                        //let analystItem = ["type": 8]
                        //itemArray.append(analystItem)
                    }
                    */
                    /*
                    // Debug
                    for item in itemArray
                    {
                        let type = item["type"] as! Int
                        print("Type: " + String(type))
                    }
                    */
                }
                
                // Hide the button if the item count is less than the max value
                if (resultArray.count < kMaxItems)
                {
                    showFooter = false
                }
                else
                {
                    showFooter = true
                    pageNumber += 1
                }
            }
            else
            {
                print("Get career timeline failed.")
                
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "There was a problem getting the timeline from the server.", lastItemCancelType: false) { (tag) in
                    
                }
            }
            
            self.timelineTableView.reloadData()
        }
    }
    
    // MARK: - TaggedPhotosDelegate
    
    func collectionViewDidSelectItem(urlString: String)
    {
        self.delegate?.athleteTimelineWebButtonTouched(urlString: urlString, title: "Photo")
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return itemArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let item = itemArray[indexPath.row]
        let type = item["type"] as! Int
        
        switch type
        {
        case TimelineItemType.article.rawValue:
            // Article
            return 281.0
            
        case TimelineItemType.photos.rawValue:
            // Photos
            return 394.0
            
        case TimelineItemType.videos.rawValue:
            // Videos are calculated based upon cell width
            let newInnerContainerHeight = (kDeviceWidth - 40) * (9/16)
            let heightDifference = newInnerContainerHeight - 180
            let newHeight = 372 + heightDifference
            
            return newHeight
            
        case TimelineItemType.statsUpdated.rawValue:
            // Stats Updated
            return 267.0
            
        case TimelineItemType.rosterAdded.rawValue:
            // Roster Added
            return 350.0
            
        case TimelineItemType.pogAward.rawValue:
            // POG Award
            return 600.0
            
        case TimelineItemType.poyAward.rawValue:
            // POY Award
            return 580.0
            
        case TimelineItemType.analystAward.rawValue:
            // Analyst Award
            return 422.0
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 188.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (showFooter == true)
        {
            return footerView.frame.size.height + 62 // Ad pad
        }
        else
        {
            return 62.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 188))
        view.backgroundColor = UIColor.mpWhiteColor()
        
        let grayView = UIView(frame: CGRect(x: 0, y: 180, width: tableView.frame.size.width, height: 8))
        grayView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        view.addSubview(grayView)

        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        if (showFooter == true)
        {
            return footerView
        }
        else
        {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let item = itemArray[indexPath.row]
        let type = item["type"] as! Int
        
        switch type
        {
        case TimelineItemType.article.rawValue:
            var cell = tableView.dequeueReusableCell(withIdentifier: "TaggedArticleTableViewCell") as? TaggedArticleTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("TaggedArticleTableViewCell", owner: self, options: nil)
                cell = nib![0] as? TaggedArticleTableViewCell
            }
            
            cell?.selectionStyle = .none
            
            cell?.viewMoreButton.tag = 100 + indexPath.row
            cell?.viewMoreButton.addTarget(self, action: #selector(viewMoreArticlesButtonTouched), for: .touchUpInside)
            
            cell?.shareButton.tag = 100 + indexPath.row
            cell?.shareButton.addTarget(self, action: #selector(shareArticlesButtonTouched), for: .touchUpInside)
            
            cell?.loadData(itemData: item)

            return cell!
            
        case TimelineItemType.photos.rawValue:
            var cell = tableView.dequeueReusableCell(withIdentifier: "TaggedPhotosTableViewCell") as? TaggedPhotosTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("TaggedPhotosTableViewCell", owner: self, options: nil)
                cell = nib![0] as? TaggedPhotosTableViewCell
            }
            
            cell?.selectionStyle = .none
            cell?.delegate = self
            
            cell?.viewMoreButton.tag = 100 + indexPath.row
            cell?.viewMoreButton.addTarget(self, action: #selector(viewPhotoGalleryButtonTouched), for: .touchUpInside)
            
            cell?.shareButton.tag = 100 + indexPath.row
            cell?.shareButton.addTarget(self, action: #selector(sharePhotosButtonTouched), for: .touchUpInside)
            
            cell?.loadData(itemData: item)
            
            return cell!
            
        case TimelineItemType.videos.rawValue:
            var cell = tableView.dequeueReusableCell(withIdentifier: "TaggedVideoTableViewCell") as? TaggedVideoTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("TaggedVideoTableViewCell", owner: self, options: nil)
                cell = nib![0] as? TaggedVideoTableViewCell
            }
            
            cell?.selectionStyle = .none
            
            cell?.viewMoreButton.tag = 100 + indexPath.row
            cell?.viewMoreButton.addTarget(self, action: #selector(viewMoreVideosButtonTouched), for: .touchUpInside)
            
            cell?.shareButton.tag = 100 + indexPath.row
            cell?.shareButton.addTarget(self, action: #selector(shareVideosButtonTouched), for: .touchUpInside)
            
            cell?.setCellHeight()
            cell?.loadData(itemData: item)

            return cell!
            
        case TimelineItemType.statsUpdated.rawValue:
            var cell = tableView.dequeueReusableCell(withIdentifier: "StatsUpdatedTableViewCell") as? StatsUpdatedTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("StatsUpdatedTableViewCell", owner: self, options: nil)
                cell = nib![0] as? StatsUpdatedTableViewCell
            }
            
            cell?.selectionStyle = .none
            
            cell?.boxScoreButton.tag = 100 + indexPath.row
            cell?.boxScoreButton.addTarget(self, action: #selector(boxScoreButtonTouched), for: .touchUpInside)
            
            cell?.fullStatsButton.tag = 100 + indexPath.row
            cell?.fullStatsButton.addTarget(self, action: #selector(fullStatsButtonTouched), for: .touchUpInside)
            
            cell?.shareButton.tag = 100 + indexPath.row
            cell?.shareButton.addTarget(self, action: #selector(shareStatsButtonTouched), for: .touchUpInside)
            
            cell?.loadData(itemData: item, teamColor: teamColor)
            
            return cell!
            
        case TimelineItemType.rosterAdded.rawValue:
            var cell = tableView.dequeueReusableCell(withIdentifier: "AddedToRosterTableViewCell") as? AddedToRosterTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("AddedToRosterTableViewCell", owner: self, options: nil)
                cell = nib![0] as? AddedToRosterTableViewCell
            }
            
            cell?.selectionStyle = .none
            
            cell?.shareButton.tag = 100 + indexPath.row
            cell?.shareButton.addTarget(self, action: #selector(shareRosterButtonTouched), for: .touchUpInside)
            
            cell?.loadData(rosterData: item, selectedAthlete: self.selectedAthlete!)
  
            return cell!
            
        case TimelineItemType.pogAward.rawValue:
            var cell = tableView.dequeueReusableCell(withIdentifier: "PlayerOfTheGameTableViewCell") as? PlayerOfTheGameTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("PlayerOfTheGameTableViewCell", owner: self, options: nil)
                cell = nib![0] as? PlayerOfTheGameTableViewCell
            }
            
            cell?.selectionStyle = .none
            
            cell?.gameRecapButton.tag = 100 + indexPath.row
            cell?.gameRecapButton.addTarget(self, action: #selector(pogGameRecapButtonTouched), for: .touchUpInside)
            
            cell?.awardsButton.tag = 100 + indexPath.row
            cell?.awardsButton.addTarget(self, action: #selector(pogAwardsButtonTouched), for: .touchUpInside)
            
            cell?.shareButton.tag = 100 + indexPath.row
            cell?.shareButton.addTarget(self, action: #selector(sharePOGButtonTouched), for: .touchUpInside)
            
            //let item = ["year": "2011"]
            cell?.loadData(awardsData: item, selectedAthlete: self.selectedAthlete!)
  
            return cell!
            
        case TimelineItemType.poyAward.rawValue:
            var cell = tableView.dequeueReusableCell(withIdentifier: "PlayerOfTheYearTableViewCell") as? PlayerOfTheYearTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("PlayerOfTheYearTableViewCell", owner: self, options: nil)
                cell = nib![0] as? PlayerOfTheYearTableViewCell
            }
            
            cell?.selectionStyle = .none
            
            cell?.awardsButton.tag = 100 + indexPath.row
            cell?.awardsButton.addTarget(self, action: #selector(poyAwardsButtonTouched), for: .touchUpInside)
            
            cell?.shareButton.tag = 100 + indexPath.row
            cell?.shareButton.addTarget(self, action: #selector(sharePOYButtonTouched), for: .touchUpInside)
            
            //let item = ["year": "2011"]
            cell?.loadData(awardsData: item, selectedAthlete: self.selectedAthlete!)
  
            return cell!
            
        case TimelineItemType.analystAward.rawValue:
            var cell = tableView.dequeueReusableCell(withIdentifier: "AnalystAwardTableViewCell") as? AnalystAwardTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("AnalystAwardTableViewCell", owner: self, options: nil)
                cell = nib![0] as? AnalystAwardTableViewCell
            }
            
            cell?.selectionStyle = .none
            
            cell?.viewStoryButton.tag = 100 + indexPath.row
            cell?.viewStoryButton.addTarget(self, action: #selector(analystViewStoryButtonTouched), for: .touchUpInside)
            
            cell?.awardsButton.tag = 100 + indexPath.row
            cell?.awardsButton.addTarget(self, action: #selector(analystAwardsButtonTouched), for: .touchUpInside)
            
            cell?.shareButton.tag = 100 + indexPath.row
            cell?.shareButton.addTarget(self, action: #selector(shareAnalystAwardButtonTouched), for: .touchUpInside)
            
            cell?.loadData(awardsData: item, selectedAthlete: self.selectedAthlete!)
  
            return cell!
        
        default:
            // This shouldn't happen
            var cell = tableView.dequeueReusableCell(withIdentifier: "TaggedArticleTableViewCell") as? TaggedArticleTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("TaggedArticleTableViewCell", owner: self, options: nil)
                cell = nib![0] as? TaggedArticleTableViewCell
            }
            
            cell?.selectionStyle = .none

            return cell!
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = itemArray[indexPath.row]
        let type = item["type"] as! Int
        
        switch type
        {
        case TimelineItemType.article.rawValue:
            let data = item["data"] as! Dictionary<String,Any>
            let urlString = data["articleUrl"] as! String
            self.delegate?.athleteTimelineWebButtonTouched(urlString: urlString, title: "Article")
            
        case TimelineItemType.photos.rawValue:
            return
            
        case TimelineItemType.videos.rawValue:
            let data = item["data"] as! Dictionary<String,Any>
            let videoId = data["videoId"] as! String
            self.delegate?.athleteTimelineVideoButtonTouched(videoId: videoId)
            
        case TimelineItemType.statsUpdated.rawValue:
            return
            
        case TimelineItemType.rosterAdded.rawValue:
            return
            
        case TimelineItemType.pogAward.rawValue:
            return
            
        case TimelineItemType.poyAward.rawValue:
            return
            
        default:
            return
        }
    
    }
    
    // MARK: - Button Methods
    
    @objc private func viewMoreArticlesButtonTouched(_ sender: UIButton)
    {
        self.delegate!.athleteTimelineJumpToTab(named: "News")
        /*
        let index = sender.tag - 100
        let item = itemArray[index]
        let links = item["links"] as! Array<Dictionary<String,String>>
        let link = links.first
        let urlString = link!["url"]!
        
        self.delegate?.athleteTimelineWebButtonTouched(urlString: urlString, title: "More Articles")
        */
    }
    
    @objc private func viewMoreVideosButtonTouched(_ sender: UIButton)
    {
        self.delegate!.athleteTimelineJumpToTab(named: "Videos")
        /*
        let index = sender.tag - 100
        let item = itemArray[index]
        let links = item["links"] as! Array<Dictionary<String,String>>
        let link = links.first
        let urlString = link!["url"]!
        
        self.delegate?.athleteTimelineWebButtonTouched(urlString: urlString, title: "Videos")
        */
    }
    
    @objc private func viewPhotoGalleryButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let item = itemArray[index]
        let links = item["links"] as! Array<Dictionary<String,String>>
        let link = links.first
        let urlString = link!["url"]!
        
        self.delegate?.athleteTimelineWebButtonTouched(urlString: urlString, title: "Photo Gallery")
    }
    
    @objc private func shareArticlesButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let item = itemArray[index]
        let urlString = item["shareLink"] as! String
        
        self.delegate?.athleteTimelineShareButtonTouched(urlString: urlString)
    }
    
    @objc private func shareVideosButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let item = itemArray[index]
        let urlString = item["shareLink"] as! String
        
        self.delegate?.athleteTimelineShareButtonTouched(urlString: urlString)
    }
    
    @objc private func sharePhotosButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let item = itemArray[index]
        let urlString = item["shareLink"] as! String
        
        self.delegate?.athleteTimelineShareButtonTouched(urlString: urlString)
    }
    
    @objc private func boxScoreButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let item = itemArray[index]
        let links = item["links"] as! Array<Dictionary<String,String>>
        let link = links.first
        let urlString = link!["url"]!
        
        self.delegate?.athleteTimelineWebButtonTouched(urlString: urlString, title: "Box Score")
    }
    
    @objc private func fullStatsButtonTouched(_ sender: UIButton)
    {
        /*
        let index = sender.tag - 100
        let item = itemArray[index]
        let links = item["links"] as! Array<Dictionary<String,String>>
        let link = links.last
        let urlString = link!["url"]!
        
        self.delegate?.athleteTimelineWebButtonTouched(urlString: urlString, title: "Full Stats")
        */
        
        self.delegate?.athleteTimelineJumpToTab(named: "Stats")
    }
    
    @objc private func shareStatsButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let item = itemArray[index]
        let urlString = item["shareLink"] as! String
        
        self.delegate?.athleteTimelineShareButtonTouched(urlString: urlString)
    }
    
    @objc private func shareRosterButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let item = itemArray[index]
        let urlString = item["shareLink"] as! String
        
        self.delegate?.athleteTimelineShareButtonTouched(urlString: urlString)
    }
    
    @objc private func pogGameRecapButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let item = itemArray[index]
        let links = item["links"] as! Array<Dictionary<String,String>>
        let link = links.first
        let urlString = link!["url"]!
        
        self.delegate?.athleteTimelineWebButtonTouched(urlString: urlString, title: "Game Recap")
    }
    
    @objc private func pogAwardsButtonTouched(_ sender: UIButton)
    {
        self.delegate!.athleteTimelineJumpToTab(named: "Awards")
        /*
        let index = sender.tag - 100
        let item = itemArray[index]
        let links = item["links"] as! Array<Dictionary<String,String>>
        let link = links.last
        let urlString = link!["url"]!
        
        self.delegate?.athleteTimelineWebButtonTouched(urlString: urlString, title: "Awards")
        */
    }
    
    @objc private func sharePOGButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let item = itemArray[index]
        let urlString = item["shareLink"] as! String
        
        self.delegate?.athleteTimelineShareButtonTouched(urlString: urlString)
    }
    
    @objc private func poyAwardsButtonTouched(_ sender: UIButton)
    {
        self.delegate!.athleteTimelineJumpToTab(named: "Awards")
        /*
        let index = sender.tag - 100
        let item = itemArray[index]
        let links = item["links"] as! Array<Dictionary<String,String>>
        let link = links.first
        let urlString = link!["url"]!
        
        self.delegate?.athleteTimelineWebButtonTouched(urlString: urlString, title: "Awards")
        */
    }
    
    @objc private func sharePOYButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let item = itemArray[index]
        let urlString = item["shareLink"] as! String
        
        self.delegate?.athleteTimelineShareButtonTouched(urlString: urlString)
    }
    
    @objc private func analystViewStoryButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let item = itemArray[index]
        let dataObj = item["data"] as! Dictionary<String,String>
        let urlString = dataObj["storyLinkUrl"]
        
        self.delegate?.athleteTimelineWebButtonTouched(urlString: urlString!, title: "Analyst Award")
    }
    
    @objc private func analystAwardsButtonTouched(_ sender: UIButton)
    {
        self.delegate!.athleteTimelineJumpToTab(named: "Awards")
        /*
        let index = sender.tag - 100
        let item = itemArray[index]
        let dataObj = item["data"] as! Dictionary<String,String>
        let urlString = dataObj["storyLinkUrl"]
        
        self.delegate?.athleteTimelineWebButtonTouched(urlString: urlString!, title: "Analyst Award")
        */
    }
    
    @objc private func shareAnalystAwardButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let item = itemArray[index]
        let urlString = item["shareLink"] as! String
        
        self.delegate?.athleteTimelineShareButtonTouched(urlString: urlString)
    }
    
    // MARK: - Button Method
    
    @objc private func getMoreButtonTouched()
    {
        self.getCareerTimelineData()
    }
    
    // MARK: - Set TableView Scroll Location
    
    func setTableViewScrollLocation(yScroll: Int)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
        {
            self.timelineTableView.contentOffset = CGPoint(x: 0, y: yScroll)
        }
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        self.delegate?.athleteTimelineViewDidScroll(Int(scrollView.contentOffset.y))
    }
    
    // MARK: - Init Method
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        // Add the tableView
        timelineTableView = UITableView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), style: .grouped)
        timelineTableView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        timelineTableView.separatorStyle = .none
        self.addSubview(timelineTableView)
        
        footerView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 60))
        footerView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        
        getMoreButton = UIButton(type: .custom)
        getMoreButton.frame = CGRect(x: (frame.size.width - 160) / 2, y: 15, width: 160, height: 30)
        getMoreButton.backgroundColor = UIColor.mpBlueColor()
        getMoreButton.layer.cornerRadius = 8
        getMoreButton.clipsToBounds = true
        getMoreButton.setTitle("MORE ITEMS", for: .normal)
        getMoreButton.setTitleColor(UIColor.mpWhiteColor(), for: .normal)
        getMoreButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 14)
        getMoreButton.addTarget(self, action: #selector(getMoreButtonTouched), for: .touchUpInside)
        footerView.addSubview(getMoreButton)
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
