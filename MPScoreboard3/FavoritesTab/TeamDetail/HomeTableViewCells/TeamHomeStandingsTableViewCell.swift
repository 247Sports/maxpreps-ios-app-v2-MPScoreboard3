//
//  TeamHomeStandingsTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/2/22.
//

import UIKit

class TeamHomeStandingsTableViewCell: UITableViewCell
{
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var overallTitleLabel: UILabel!
    @IBOutlet weak var overallRecordLabel: UILabel!
    @IBOutlet weak var overallPercentLabel: UILabel!
    @IBOutlet weak var leagueTitleLabel: UILabel!
    @IBOutlet weak var leagueRecordLabel: UILabel!
    @IBOutlet weak var leagueStandingButton: UIButton!
    @IBOutlet weak var homeTitleLabel: UILabel!
    @IBOutlet weak var awayTitleLabel: UILabel!
    @IBOutlet weak var neutralTitleLabel: UILabel!
    @IBOutlet weak var streakTitleLabel: UILabel!
    @IBOutlet weak var homeRecordLabel: UILabel!
    @IBOutlet weak var awayRecordLabel: UILabel!
    @IBOutlet weak var neutralRecordLabel: UILabel!
    @IBOutlet weak var streakRecordLabel: UILabel!
    
    // MARK: - Load Data
    
    func loadData(overall: Dictionary<String,Any>, league: Dictionary<String,Any>)
    {
        /*
         Overall
         ▿ value : 9 elements
                 ▿ 0 : 2 elements
                   - key : overallWinLossTies
                   - value : 6-5
                 ▿ 1 : 2 elements
                   - key : points
                   - value : 455
                 ▿ 2 : 2 elements
                   - key : streak
                   - value : 1
                 ▿ 3 : 2 elements
                   - key : winningPercentage
                   - value : 0.545
                 ▿ 4 : 2 elements
                   - key : streakResult
                   - value : W
                 ▿ 5 : 2 elements
                   - key : pointsAgainst
                   - value : 395
                 ▿ 6 : 2 elements
                   - key : homeWinLossTies
                   - value : 4-3
                 ▿ 7 : 2 elements
                   - key : awayWinLossTies
                   - value : 1-1
                 ▿ 8 : 2 elements
                   - key : neutralWinLossTies
                   - value : 1-1
         */
        
        overallRecordLabel.text = ""
        overallPercentLabel.text = "0.0 Win %"
        
        let overallWinLossTies = overall["overallWinLossTies"] as? String ?? ""
        overallRecordLabel.text = overallWinLossTies
        
        let winningPercentage = overall["winningPercentage"] as? Double ?? 0.0
        if (winningPercentage > 0)
        {
            overallPercentLabel.text = String(format: "%1.2f Win", winningPercentage * 100) + " %"
        }
        
        let homeRecord = overall["homeWinLossTies"] as? String ?? ""
        homeRecordLabel.text = homeRecord
        
        let awayRecord = overall["awayWinLossTies"] as? String ?? ""
        awayRecordLabel.text = awayRecord
        
        let neutralRecord = overall["neutralWinLossTies"] as? String ?? ""
        neutralRecordLabel.text = neutralRecord
        
        let streak = overall["streak"] as? Int ?? 0
        streakRecordLabel.text = ""
        
        if (streak > 0)
        {
            let streakResult = overall["streakResult"] as? String ?? ""
            
            streakRecordLabel.text = String(format: "%d%@", streak, streakResult.uppercased())
            
            if (streakResult.uppercased() == "W")
            {
                streakRecordLabel.textColor = UIColor.mpGreenColor()
            }
            else if (streakResult.uppercased() == "L")
            {
                streakRecordLabel.textColor = UIColor.mpRedColor()
            }
            else
            {
                streakRecordLabel.textColor = UIColor.mpGrayColor()
            }
        }
        
        /*
         League
         ▿ value : 5 elements
                 ▿ 0 : 2 elements
                   - key : conferenceStandingPlacement
                   - value :
                 ▿ 1 : 2 elements
                   - key : conferenceWinningPercentage
                   - value : 0.75
                 ▿ 2 : 2 elements
                   - key : leagueName
                   - value :
                 ▿ 3 : 2 elements
                   - key : canonicalUrl
                   - value :
                 ▿ 4 : 2 elements
                   - key : conferenceWinLossTies
                   - value : 3-1
         */
        
        leagueRecordLabel.text = ""
        let emptyAttributedString = NSMutableAttributedString(string: "")
        leagueStandingButton.setAttributedTitle(emptyAttributedString, for: .normal)
        leagueStandingButton.isUserInteractionEnabled = false
        
        let conferenceRecord = league["conferenceWinLossTies"] as? String ?? ""
        leagueRecordLabel.text = conferenceRecord
        
        let leagueTitle = league["leagueAlias"] as? String ?? "LEAGUE"
        leagueTitleLabel.text = leagueTitle.uppercased()
        
        let leagueName = league["leagueName"] as? String ?? ""
        
        if (leagueName.count > 0)
        {
            let conferencePosition = league["conferenceStandingPlacement"] as? String ?? ""
            leagueStandingButton.isUserInteractionEnabled = true
            
            let title = String(format: "%@ %@", conferencePosition, leagueName)
            let attributedString = NSMutableAttributedString(string: title)
            
            // MP Blue
            let range1 = title.range(of: leagueName)
            let convertedRange1 = NSRange(range1!, in: title)

            attributedString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.mpBlueColor()], range: convertedRange1)
            
            // MP Gray
            let range2 = title.range(of: conferencePosition)
            let convertedRange2 = NSRange(range2!, in: title)

            attributedString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.mpGrayColor()], range: convertedRange2)
            
            leagueStandingButton.setAttributedTitle(attributedString, for: .normal)
        }
        /*
         let title = "No standings available for Section or Division. If this is incorrect, please contact support with the correction."
         
         let attributedString = NSMutableAttributedString(string: title)
         
         // MP Blue
         let range1 = title.range(of: "support")
         let convertedRange1 = NSRange(range1!, in: title)

         attributedString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.mpBlueColor()], range: convertedRange1)
         
         bottomContainerOverlayLabel.attributedText = attributedString
         */
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        innerContainerView.layer.cornerRadius = 12
        innerContainerView.clipsToBounds = true
        
        // Center the labels in the container
        overallTitleLabel.center = CGPoint(x: kDeviceWidth * 0.25, y: overallTitleLabel.center.y)
        leagueTitleLabel.center = CGPoint(x: kDeviceWidth * 0.75, y: leagueTitleLabel.center.y)
        
        overallRecordLabel.center = CGPoint(x: kDeviceWidth * 0.25, y: overallRecordLabel.center.y)
        leagueRecordLabel.center = CGPoint(x: kDeviceWidth * 0.75, y: leagueRecordLabel.center.y)
        
        overallPercentLabel.center = CGPoint(x: kDeviceWidth * 0.25, y: overallPercentLabel.center.y)
        leagueStandingButton.center = CGPoint(x: kDeviceWidth * 0.75, y: leagueStandingButton.center.y)
        
        // Adjust the labels relative to the center
        neutralTitleLabel.frame = CGRect(x: (kDeviceWidth / 2.0) + 24, y: neutralTitleLabel.frame.origin.y, width: neutralTitleLabel.frame.size.width, height: neutralTitleLabel.frame.size.height)
        streakTitleLabel.frame = CGRect(x: (kDeviceWidth / 2.0) + 24, y: streakTitleLabel.frame.origin.y, width: streakTitleLabel.frame.size.width, height: streakTitleLabel.frame.size.height)
        
        neutralRecordLabel.frame = CGRect(x: (kDeviceWidth / 2.0) + 78, y: neutralRecordLabel.frame.origin.y, width: neutralRecordLabel.frame.size.width, height: neutralRecordLabel.frame.size.height)
        streakRecordLabel.frame = CGRect(x: (kDeviceWidth / 2.0) + 72, y: streakRecordLabel.frame.origin.y, width: streakRecordLabel.frame.size.width, height: streakRecordLabel.frame.size.height)
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
