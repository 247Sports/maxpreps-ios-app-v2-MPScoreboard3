//
//  StatsUpdatedTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/2/21.
//

import UIKit

class StatsUpdatedTableViewCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var boxScoreButton: UIButton!
    @IBOutlet weak var fullStatsButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    // MARK: - Load Data
    
    func loadData(itemData: Dictionary<String,Any>, teamColor: UIColor)
    {
        let title = itemData["title"] as! String
        titleLabel.text = title
        
        let subtitle = itemData["text"] as! String
        subtitleLabel.text = subtitle
        
        let timeText = itemData["timeStampString"] as! String
        dateLabel.text = timeText
        
        let links = itemData["links"] as! Array<Dictionary<String,String>>
        let link0 = links.first
        let link1 = links.last
        let boxScoreButtonTitle = link0!["text"]
        let fullStatsButtonTitle = link1!["text"]
        boxScoreButton.setTitle(boxScoreButtonTitle, for: .normal)
        fullStatsButton.setTitle(fullStatsButtonTitle, for: .normal)
        
        // Resize the fullStatsButton to fit the text
        let textWidth = fullStatsButtonTitle?.widthOfString(usingFont: (fullStatsButton.titleLabel?.font)!)
        fullStatsButton.frame = CGRect(x: fullStatsButton.frame.origin.x, y: fullStatsButton.frame.origin.y, width: CGFloat(textWidth! + 10), height: fullStatsButton.frame.size.height)
        
        let data = itemData["data"] as! Dictionary<String,Any>
        var stats = data["stats"] as! Array<Dictionary<String,Any>>
        
        // Get rid of the trailing stats that don't have a value
        if (stats.count == 3)
        {
            let stat1 = stats[1]
            let value1 = stat1["value"] as! String
        
            let stat2 = stats[2]
            let value2 = stat2["value"] as! String
            
            if (value2.count == 0)
            {
                // Remove item at index 2
                stats.remove(at: 2)
            }
            
            if (value1.count == 0)
            {
                // Remove item at index 1
                stats.remove(at: 1)
            }
        }
        
        self.buildStatContainers(stats: stats, teamColor: teamColor)

        /*
         ▿ 8 elements
           ▿ 0 : 2 elements
             - key : "type"
             - value : 4
           ▿ 1 : 2 elements
             - key : "timeStamp"
             - value : 2020-11-21T10:20:00
           ▿ 2 : 2 elements
             - key : "shareLink"
             - value : https://dev.maxpreps.com/games/11-20-2020/football-fall-20/corner-canyon-vs-lone-peak.htm?c=YTDkkHo_3ESnT1COVcFYnw
           ▿ 3 : 2 elements
             - key : "links"
             ▿ value : 2 elements
               ▿ 0 : 2 elements
                 ▿ 0 : 2 elements
                   - key : url
                   - value : https://dev.maxpreps.com/games/11-20-2020/football-fall-20/corner-canyon-vs-lone-peak.htm?c=YTDkkHo_3ESnT1COVcFYnw
                 ▿ 1 : 2 elements
                   - key : text
                   - value : Box Score
               ▿ 1 : 2 elements
                 ▿ 0 : 2 elements
                   - key : url
                   - value : https://dev.maxpreps.com/local/player/stats.aspx?athleteid=cbde04ce-7989-483c-96ca-09ee29ce4143&ssid=a9cbf684-16ef-4997-9539-15fefe9df410
                 ▿ 1 : 2 elements
                   - key : text
                   - value : Jaxson's Full Stats
           ▿ 4 : 2 elements
             - key : "text"
             - value : Jaxson's stats have been updated for the win vs. Lone Peak.
           ▿ 5 : 2 elements
             - key : "data"
             ▿ value : 2 elements
               ▿ 0 : 2 elements
                 - key : contestId
                 - value : 90e43061-3f7a-44dc-a74f-508e55c1589f
               ▿ 1 : 2 elements
                 - key : stats
                 ▿ value : 3 elements
                   ▿ 0 : 4 elements
                     ▿ 0 : 2 elements
                       - key : value
                       - value : 329
                     ▿ 1 : 2 elements
                       - key : displayName
                       - value : Passing Yards
                     ▿ 2 : 2 elements
                       - key : name
                       - value : PassingYards
                     ▿ 3 : 2 elements
                       - key : header
                       - value : Yds
                   ▿ 1 : 4 elements
                     ▿ 0 : 2 elements
                       - key : value
                       - value : 4
                     ▿ 1 : 2 elements
                       - key : displayName
                       - value : Passing TDs
                     ▿ 2 : 2 elements
                       - key : name
                       - value : PassingTD
                     ▿ 3 : 2 elements
                       - key : header
                       - value : TD Passes
                   ▿ 2 : 4 elements
                     ▿ 0 : 2 elements
                       - key : value
                       - value : 25
                     ▿ 1 : 2 elements
                       - key : displayName
                       - value : Completions
                     ▿ 2 : 2 elements
                       - key : name
                       - value : PassingComp
                     ▿ 3 : 2 elements
                       - key : header
                       - value : Cmp
           ▿ 6 : 2 elements
             - key : "title"
             - value : Stats Updated
           ▿ 7 : 2 elements
             - key : "timeStampString"
             - value : Saturday, Nov 21, 2020
         */
        
    }
    
    // MARK: - Build Stat Containers
    
    private func buildStatContainers(stats: Array<Dictionary<String,Any>>, teamColor: UIColor)
    {
        // Build the container views
        let edgePad = CGFloat(20)
        let spacing = CGFloat(8)
        let itemCount = CGFloat(stats.count)
        
        // This handles the case where there are no items
        var containerWidth = kDeviceWidth - (2 * edgePad)
 
        if (itemCount > 0)
        {
            containerWidth = (kDeviceWidth - (2 * edgePad) - ((itemCount - 1) * spacing)) / itemCount
        }
        
        // Left Container
        let leftContainerView = UIView(frame: CGRect(x: edgePad, y: 99, width: containerWidth, height: 78))
        leftContainerView.backgroundColor = .clear
        leftContainerView.layer.cornerRadius = 12
        leftContainerView.clipsToBounds = true
        contentView.addSubview(leftContainerView)
        
        // Add a gradient layer to the left container
        let topColor = teamColor//UIColor(red: 32.0/255.0, green: 106.0/255.0, blue: 240.0/255.0, alpha: 1)
        let bottomColor = teamColor.darker(by: 15) //UIColor(red: 0.0, green: 47.0/255.0, blue: 132.0/255.0, alpha: 1)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: leftContainerView.frame.size.width, height: leftContainerView.frame.size.height)
        gradientLayer.colors = [topColor.cgColor, bottomColor!.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        leftContainerView.layer.insertSublayer(gradientLayer, at: 0)
        
        let leftTitleLabel = UILabel(frame: CGRect(x: 10, y: 9, width: containerWidth - 20, height: 29))
        leftTitleLabel.font = UIFont.mpBoldFontWith(size: 20)
        leftTitleLabel.textAlignment = .center
        leftTitleLabel.textColor = UIColor.mpWhiteColor()
        leftContainerView.addSubview(leftTitleLabel)
        
        let leftSubtitleLabel = UILabel(frame: CGRect(x: 10, y: 39, width: containerWidth - 20, height: 30))
        leftSubtitleLabel.font = UIFont.mpRegularFontWith(size: 12)
        leftSubtitleLabel.textAlignment = .center
        leftSubtitleLabel.textColor = UIColor.mpWhiteColor()
        leftSubtitleLabel.numberOfLines = 2
        leftContainerView.addSubview(leftSubtitleLabel)
        
        if (itemCount > 0)
        {
            let stat = stats[0]
            let title = stat["displayName"] as! String
            let value = stat["value"] as! String
            leftTitleLabel.text = value
            leftSubtitleLabel.text = title
        }
        else
        {
            leftTitleLabel.text = "--"
            leftSubtitleLabel.text = "--"
        }
        
        // Center Container
        if (itemCount > 1)
        {
            let centerContainerView = UIView(frame: CGRect(x: edgePad + containerWidth + spacing, y: 99, width: containerWidth, height: 78))
            centerContainerView.backgroundColor = UIColor.mpHeaderBackgroundColor()
            centerContainerView.layer.cornerRadius = 12
            centerContainerView.clipsToBounds = true
            contentView.addSubview(centerContainerView)
            
            let centerTitleLabel = UILabel(frame: CGRect(x: 10, y: 9, width: containerWidth - 20, height: 29))
            centerTitleLabel.font = UIFont.mpBoldFontWith(size: 20)
            centerTitleLabel.textAlignment = .center
            centerTitleLabel.textColor = UIColor.mpBlackColor()
            centerContainerView.addSubview(centerTitleLabel)
            
            let centerSubtitleLabel = UILabel(frame: CGRect(x: 10, y: 39, width: containerWidth - 20, height: 30))
            centerSubtitleLabel.font = UIFont.mpRegularFontWith(size: 12)
            centerSubtitleLabel.textAlignment = .center
            centerSubtitleLabel.textColor = UIColor.mpDarkGrayColor()
            centerSubtitleLabel.numberOfLines = 2
            centerContainerView.addSubview(centerSubtitleLabel)
            
            let stat = stats[1]
            let title = stat["displayName"] as! String
            let value = stat["value"] as! String
            centerTitleLabel.text = value
            centerSubtitleLabel.text = title
        }
        
        // Right Container
        if (itemCount > 2)
        {
            let rightContainerView = UIView(frame: CGRect(x: edgePad + (2 * containerWidth) + (2 * spacing), y: 99, width: containerWidth, height: 78))
            rightContainerView.backgroundColor = UIColor.mpHeaderBackgroundColor()
            rightContainerView.layer.cornerRadius = 12
            rightContainerView.clipsToBounds = true
            contentView.addSubview(rightContainerView)
            
            let rightTitleLabel = UILabel(frame: CGRect(x: 10, y: 9, width: containerWidth - 20, height: 29))
            rightTitleLabel.font = UIFont.mpBoldFontWith(size: 20)
            rightTitleLabel.textAlignment = .center
            rightTitleLabel.textColor = UIColor.mpBlackColor()
            rightContainerView.addSubview(rightTitleLabel)
            
            let rightSubtitleLabel = UILabel(frame: CGRect(x: 10, y: 39, width: containerWidth - 20, height: 30))
            rightSubtitleLabel.font = UIFont.mpRegularFontWith(size: 12)
            rightSubtitleLabel.textAlignment = .center
            rightSubtitleLabel.textColor = UIColor.mpDarkGrayColor()
            rightSubtitleLabel.numberOfLines = 2
            rightContainerView.addSubview(rightSubtitleLabel)
            
            let stat = stats[2]
            let title = stat["displayName"] as! String
            let value = stat["value"] as! String
            rightTitleLabel.text = value
            rightSubtitleLabel.text = title
        }
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
