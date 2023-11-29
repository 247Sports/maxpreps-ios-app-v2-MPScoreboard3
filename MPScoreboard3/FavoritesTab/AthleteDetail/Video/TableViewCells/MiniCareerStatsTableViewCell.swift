//
//  MiniCareerStatsTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/19/22.
//

import UIKit

protocol MiniCareerStatsTableViewCellDelegate: AnyObject
{
    func miniCareerStatsButtonTouched(urlString: String, sport: String)
}

class MiniCareerStatsTableViewCell: UITableViewCell
{
    weak var delegate: MiniCareerStatsTableViewCellDelegate?
    private var careerStatsArray = [] as Array<Dictionary<String,Any>>
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sportImageView: UIImageView!
    @IBOutlet weak var sportLabel: UILabel!
    @IBOutlet weak var jerseyLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var captainLabel: UILabel!
    @IBOutlet weak var captainIconImageView: UIImageView!
    
    func loadData(quickStatsData: Dictionary<String,Any>)
    {
        print("Data Loaded")
        
        /*
         ▿ 23 elements
           ▿ 0 : 2 elements
             - key : "weight"
             - value : 175
           ▿ 1 : 2 elements
             - key : "heightWeightString"
             - value : 5'11'', 175lbs
           ▿ 2 : 2 elements
             - key : "positions"
             ▿ value : 1 element
               - 0 : QB
           ▿ 3 : 2 elements
             - key : "heightWeightLabel"
             - value : HT/WT
           ▿ 4 : 2 elements
             - key : "athleteId"
             - value : 0b872c1b-5958-4edd-98d6-7a20adc2351a
           ▿ 5 : 2 elements
             - key : "sportSeasonStatsUrl"
             - value : https://www.maxpreps.com/local/player/stats.aspx?athleteid=0b872c1b-5958-4edd-98d6-7a20adc2351a&ssid=8d610ab9-220b-465b-9cf0-9f417bce6c65
           ▿ 6 : 2 elements
             - key : "heightInches"
             - value : 11
           ▿ 7 : 2 elements
             - key : "stats"
             ▿ value : 7 elements
               ▿ 0 : 5 elements
                 ▿ 0 : 2 elements
                   - key : value
                   - value : 4,528
                 ▿ 1 : 2 elements
                   - key : displayName
                   - value : Passing Yards
                 ▿ 2 : 2 elements
                   - key : name
                   - value : PassingYards
                 ▿ 3 : 2 elements
                   - key : header
                   - value : Yds
                 ▿ 4 : 2 elements
                   - key : field
                   - value : s9
               ▿ 1 : 5 elements
                 ▿ 0 : 2 elements
                   - key : value
                   - value : 58
                 ▿ 1 : 2 elements
                   - key : displayName
                   - value : Passing TDs
                 ▿ 2 : 2 elements
                   - key : name
                   - value : PassingTD
                 ▿ 3 : 2 elements
                   - key : header
                   - value : TD
                 ▿ 4 : 2 elements
                   - key : field
                   - value : s49
               ▿ 2 : 5 elements
                 ▿ 0 : 2 elements
                   - key : value
                   - value : 348.3
                 ▿ 1 : 2 elements
                   - key : displayName
                   - value : Passing Yards Per Game
                 ▿ 2 : 2 elements
                   - key : name
                   - value : PassingYardsPerGame
                 ▿ 3 : 2 elements
                   - key : header
                   - value : Y/G
                 ▿ 4 : 2 elements
                   - key : field
                   - value : s64
               ▿ 3 : 5 elements
                 ▿ 0 : 2 elements
                   - key : value
                   - value : 294
                 ▿ 1 : 2 elements
                   - key : displayName
                   - value : Completions
                 ▿ 2 : 2 elements
                   - key : name
                   - value : PassingComp
                 ▿ 3 : 2 elements
                   - key : header
                   - value : Comp
                 ▿ 4 : 2 elements
                   - key : field
                   - value : s43
               ▿ 4 : 5 elements
                 ▿ 0 : 2 elements
                   - key : value
                   - value : 409
                 ▿ 1 : 2 elements
                   - key : displayName
                   - value : Passing Att
                 ▿ 2 : 2 elements
                   - key : name
                   - value : PassingAtt
                 ▿ 3 : 2 elements
                   - key : header
                   - value : Att
                 ▿ 4 : 2 elements
                   - key : field
                   - value : s35
               ▿ 5 : 5 elements
                 ▿ 0 : 2 elements
                   - key : value
                   - value : 6
                 ▿ 1 : 2 elements
                   - key : displayName
                   - value : Passing Int
                 ▿ 2 : 2 elements
                   - key : name
                   - value : PassingInt
                 ▿ 3 : 2 elements
                   - key : header
                   - value : Int
                 ▿ 4 : 2 elements
                   - key : field
                   - value : s6
               ▿ 6 : 5 elements
                 ▿ 0 : 2 elements
                   - key : value
                   - value : .719
                 ▿ 1 : 2 elements
                   - key : displayName
                   - value : Completion Percentage
                 ▿ 2 : 2 elements
                   - key : name
                   - value : CompletionPercentage
                 ▿ 3 : 2 elements
                   - key : header
                   - value : C %
                 ▿ 4 : 2 elements
                   - key : field
                   - value : s65
           ▿ 8 : 2 elements
             - key : "isCaptain"
             - value : 0
           ▿ 9 : 2 elements
             - key : "grade"
             - value : Senior
           ▿ 10 : 2 elements
             - key : "schoolColor"
             - value : CC0022
           ▿ 11 : 2 elements
             - key : "positionsLabel"
             - value : Positions
           ▿ 12 : 2 elements
             - key : "photoUrl"
             - value :
           ▿ 13 : 2 elements
             - key : "heightFeet"
             - value : 5
           ▿ 14 : 2 elements
             - key : "schoolId"
             - value : 2b6b45d3-4465-4750-ba48-a273b674e37c
           ▿ 15 : 2 elements
             - key : "level"
             - value : Varsity
           ▿ 16 : 2 elements
             - key : "schoolName"
             - value : Mater Dei
           ▿ 17 : 2 elements
             - key : "isFemale"
             - value : 0
           ▿ 18 : 2 elements
             - key : "jersey"
             - value : 9
           ▿ 19 : 2 elements
             - key : "positionsString"
             - value : QB
           ▿ 20 : 2 elements
             - key : "year"
             - value : 19-20
           ▿ 21 : 2 elements
             - key : "sport"
             - value : Football
           ▿ 22 : 2 elements
             - key : "sportSeasonId"
             - value : 8d610ab9-220b-465b-9cf0-9f417bce6c65
         */
        sportLabel.text = ""
        sportImageView.image = nil
        captainLabel.isHidden = true
        captainIconImageView.isHidden = true
        jerseyLabel.text = "--"
        positionLabel.text = "--"
        
        let sport = quickStatsData["sport"] as? String ?? ""
        let level = quickStatsData["level"] as? String ?? ""
        let year = quickStatsData["year"] as? String ?? ""
        let isCaptain = quickStatsData["isCaptain"] as? Bool ?? false
        let jersey = quickStatsData["jersey"] as? String ?? ""
        let positions = quickStatsData["positionsString"] as? String ?? ""
        
        if (sport.count > 0) && (level.count > 0) && (year.count > 0)
        {
            let genderSport = MiscHelper.sportShortLevelFrom(sport: sport, level: level)
            sportLabel.text = String(format: "%@ (%@)", genderSport, year)
        }
        
        if (sport.count > 0)
        {
            let sportImage = MiscHelper.getImageForSport(sport)
            sportImageView.image = sportImage
        }
        
        if (isCaptain == true)
        {
            captainLabel.isHidden = false
            captainIconImageView.isHidden = false
        }
        
        if (jersey.count > 0)
        {
            jerseyLabel.text = String(format: "#%@", jersey)
        }
        
        if (positions.count > 0)
        {
            positionLabel.text = positions
        }
    }
    
    // MARK: - Init Methods
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
