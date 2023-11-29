//
//  ScoreboardContestRankingTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/19/23.
//

import UIKit

class ScoreboardContestRankingTableViewCell: UITableViewCell
{
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var teamANameLabel: UILabel!
    @IBOutlet weak var teamBNameLabel: UILabel!
    @IBOutlet weak var teamAInitialLabel: UILabel!
    @IBOutlet weak var teamBInitialLabel: UILabel!
    @IBOutlet weak var teamAImageView: UIImageView!
    @IBOutlet weak var teamBImageView: UIImageView!
    @IBOutlet weak var teamARecordLabel: UILabel!
    @IBOutlet weak var teamBRecordLabel: UILabel!
    @IBOutlet weak var teamAScoreLabel: UILabel!
    @IBOutlet weak var teamBScoreLabel: UILabel!
    @IBOutlet weak var teamARankingsLabel: UILabel!
    @IBOutlet weak var teamBRankingsLabel: UILabel!
    @IBOutlet weak var bellIconImageView: UIImageView!
    
    // MARK: - Load Data
    
    func loadData(_ data: Dictionary<String,Any>)
    {
        //print("load")
        let teams = data["teams"] as! Array<Dictionary<String,Any>>
        var teamA = teams[0]
        var teamB = teams[1]
        
        let haType = teamA["homeAwayType"] as! Int
        
        if (haType == 0) // Home is teamB
        {
            teamA = teams[1]
            teamB = teams[0]
        }
        
        let schoolIdA = teamA["teamId"] as? String ?? "" // Might be NULL
        
        var teamAName = teamA["name"] as? String ?? "TBA"
        var teamBName = teamB["name"] as? String ?? "TBA"
        
        if (teamAName.count == 0) // Empty string can occur
        {
            teamAName = "TBA"
        }
        
        if (teamBName.count == 0)
        {
            teamBName = "TBA"
        }
        
        teamANameLabel.text = teamAName
        teamBNameLabel.text = teamBName
        
        // Set the rankings if not null
        let teamANationalRankValue = teamA["nationalRank"] as? Int ?? -1
        let teamBNationalRankValue = teamB["nationalRank"] as? Int ?? -1
        
        if (teamANationalRankValue != -1)
        {
            teamARankingsLabel.text = String(teamANationalRankValue)
        }
        else
        {
            teamARankingsLabel.text = ""
        }
        
        if (teamBNationalRankValue != -1)
        {
            teamBRankingsLabel.text = String(teamBNationalRankValue)
        }
        else
        {
            teamBRankingsLabel.text = ""
        }
        
        let teamAMascotUrl = teamA["mascotUrl"] as? String ?? ""
        let teamBMascotUrl = teamB["mascotUrl"] as? String ?? ""
        let teamAInitial = teamAName.first?.uppercased()
        let teamBInitial = teamBName.first?.uppercased()
        let teamAColorString = teamA["color1"] as? String ?? kMissingSchoolColor
        let teamBColorString = teamB["color1"] as? String ?? kMissingSchoolColor
        
        teamAInitialLabel.text = teamAInitial
        teamBInitialLabel.text = teamBInitial
        teamAInitialLabel.textColor = ColorHelper.color(fromHexString: teamAColorString, colorCorrection: true)
        teamBInitialLabel.textColor = ColorHelper.color(fromHexString: teamBColorString, colorCorrection: true)
        teamAInitialLabel.isHidden = true
        teamBInitialLabel.isHidden = true
        
        if (teamAMascotUrl.count > 0)
        {
            // Get the data and make an image
            let url = URL(string: teamAMascotUrl)
            
            /*
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        // Render the mascot using this helper
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.teamAImageView)!)
                    }
                    else
                    {
                        self.teamAInitialLabel.isHidden = false
                    }
                }
            }
            */
            SDWebImageManager.shared().downloadImage(with: url!, progress: { receivedSize, expectedSize in
                
            }, completed: { image, error, cacheType, finished, imageUrl in
                
                if (image != nil)
                {
                    // Render the mascot using this helper
                    MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.teamAImageView)!)
                }
                else
                {
                    self.teamAInitialLabel.isHidden = false
                }
            })
        }
        else
        {
           teamAInitialLabel.isHidden = false
        }
        
        if (teamBMascotUrl.count > 0)
        {
            // Get the data and make an image
            let url = URL(string: teamBMascotUrl)
            
            /*
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        // Render the mascot using this helper
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.teamBImageView)!)
                    }
                    else
                    {
                        self.teamBInitialLabel.isHidden = false
                    }
                }
            }
            */
             SDWebImageManager.shared().downloadImage(with: url!, progress: { receivedSize, expectedSize in
                 
             }, completed: { image, error, cacheType, finished, imageUrl in
                 
                 if (image != nil)
                 {
                     // Render the mascot using this helper
                     MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.teamBImageView)!)
                 }
                 else
                 {
                     self.teamBInitialLabel.isHidden = false
                 }
             })
        }
        else
        {
            teamBInitialLabel.isHidden = false
        }
        
        // Load and shift the team record labels
        let teamARecord = teamA["standings"] as! String
        let teamBRecord = teamB["standings"] as! String
        
        teamARecordLabel.text = teamARecord
        teamBRecordLabel.text = teamBRecord
        
        let teamANameLength = teamAName.widthOfString(usingFont: teamANameLabel.font)
        let teamBNameLength = teamBName.widthOfString(usingFont: teamBNameLabel.font)
        let teamANameLabelMaxWidth = kDeviceWidth - teamANameLabel.frame.origin.x - 120
        let teamBNameLabelMaxWidth = kDeviceWidth - teamBNameLabel.frame.origin.x - 120
        
        if (teamANameLength < teamANameLabelMaxWidth)
        {
            teamARecordLabel.frame = CGRect(x: teamANameLabel.frame.origin.x + CGFloat(teamANameLength) + CGFloat(8), y: teamARecordLabel.frame.origin.y, width: teamARecordLabel.frame.size.width, height: teamARecordLabel.frame.size.height)
        }
        else
        {
            teamARecordLabel.frame = CGRect(x: teamANameLabel.frame.origin.x + CGFloat(teamANameLabelMaxWidth) + CGFloat(8), y: teamARecordLabel.frame.origin.y, width: teamARecordLabel.frame.size.width, height: teamARecordLabel.frame.size.height)
        }
        
        if (teamBNameLength < teamBNameLabelMaxWidth)
        {
            teamBRecordLabel.frame = CGRect(x: teamBNameLabel.frame.origin.x + CGFloat(teamBNameLength) + CGFloat(8), y: teamBRecordLabel.frame.origin.y, width: teamBRecordLabel.frame.size.width, height: teamBRecordLabel.frame.size.height)
        }
        else
        {
            teamBRecordLabel.frame = CGRect(x: teamBNameLabel.frame.origin.x + CGFloat(teamBNameLabelMaxWidth) + CGFloat(8), y: teamBRecordLabel.frame.origin.y, width: teamBRecordLabel.frame.size.width, height: teamBRecordLabel.frame.size.height)
        }
        
        // Clear out the scoresLabels
        teamAScoreLabel.text = ""
        teamBScoreLabel.text = ""
        
        // Reset the fonts and colors in case this cell is recycled
        dateLabel.font = UIFont.mpBoldFontWith(size: 12)
        dateLabel.textColor = UIColor.mpBlackColor()
        teamANameLabel.textColor = UIColor.mpBlackColor()
        teamAScoreLabel.textColor = UIColor.mpBlackColor()
        teamBNameLabel.textColor = UIColor.mpBlackColor()
        teamBScoreLabel.textColor = UIColor.mpBlackColor()
        
        // Contest state enums
        // 0: Unknown
        // 1: Deleted
        // 2: Pregame
        // 3: In Progress
        // 4: Boxscore
        // 5: Score not Reported (Won't happen for this cell type)
        
        let calculatedFieldsObj = data["calculatedFields"] as! Dictionary<String,Any>
        let contestState = calculatedFieldsObj["contestState"] as! Int
        
        
        // Load the scoreLabels, dateLabel, and show/hide the reportScoreButton based upon contest state
        switch contestState
        {
        case 0:
            dateLabel.text = "Uknown"
        case 1:
            dateLabel.text = "Deleted"
        case 2:
            var contestDateString = data["date"] as! String
            let dateCode = data["dateCode"] as? Int ?? 0
            
            if (dateCode == 0)
            {
                contestDateString = contestDateString.replacingOccurrences(of: "Z", with: "")
                let dateFormatter = DateFormatter()
                dateFormatter.isLenient = true
                dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
                let contestDate = dateFormatter.date(from: contestDateString)
                if (contestDate != nil)
                {
                    dateFormatter.dateFormat = "h:mm a"
                    let formattedDateString = dateFormatter.string(from: contestDate!)
                    dateLabel.text = formattedDateString
                }
                else
                {
                    dateLabel.text = ""
                }
            }
            else
            {
                dateLabel.text = "TBA"
            }
            
        case 3:
            // Set the dateLabel
            let currentLivePeriod = calculatedFieldsObj["currentLivePeriod"] as! String
            if (currentLivePeriod.count > 0)
            {
                let title = currentLivePeriod + " LIVE"
                let attributedString = NSMutableAttributedString(string: title)
                
                // Colorize the LIVE text in red
                let range = title.range(of: "LIVE")
                let convertedRange = NSRange(range!, in: title)
                
                attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 12), NSAttributedString.Key.foregroundColor: UIColor.mpRedColor()], range: convertedRange)
                
                dateLabel.attributedText = attributedString
            }
            else
            {
                dateLabel.text = "LIVE"
                dateLabel.font = UIFont.mpSemiBoldFontWith(size: 12)
                dateLabel.textColor = UIColor.mpRedColor()
            }
            
            // Set the scores
            let teamsCalculated = calculatedFieldsObj["teamsCalculated"] as! Array<Dictionary<String,Any>>
            
            // Determine which teamCalculated teamId matches teamA or teamB
            var calculatedTeamA = teamsCalculated[0]
            var calculatedTeamB = teamsCalculated[1]

            let teamCalculatedSchoolIdA = calculatedTeamA["teamId"] as? String ?? "" // Might be NULL
            if (schoolIdA != teamCalculatedSchoolIdA)
            {
                calculatedTeamA = teamsCalculated[1]
                calculatedTeamB = teamsCalculated[0]
            }
            
            // Set the scores (checking for nulls)
            let scoreA = calculatedTeamA["currentLiveScore"] as? Int ?? -1
            let scoreB = calculatedTeamB["currentLiveScore"] as? Int ?? -1
            if (scoreA != -1)
            {
                teamAScoreLabel.text = String(scoreA)
            }

            if (scoreB != -1)
            {
                teamBScoreLabel.text = String(scoreB)
            }
            
        case 4:
            let isForfeitA = teamA["isForfeit"] as! Bool
            let isForfeitB = teamB["isForfeit"] as! Bool
            
            if (isForfeitA == true) || (isForfeitB == true)
            {
                if (isForfeitA == true) && (isForfeitB == true)
                {
                    dateLabel.text = "FINAL/DFF"
                }
                else
                {
                    dateLabel.text = "FINAL/FF"
                }
            }
            else
            {
                dateLabel.text = "FINAL"
            }
            
            // Set the scores (checking for nulls)
            let scoreA = teamA["score"] as? Int ?? -1
            let scoreB = teamB["score"] as? Int ?? -1
            
            if (scoreA != -1)
            {
                if (isForfeitA == false)
                {
                    teamAScoreLabel.text = String(scoreA)
                }
                else
                {
                    teamAScoreLabel.text = "(FF) " + String(scoreA)
                }
            }
            else
            {
                teamAScoreLabel.text = "--"
            }
            if (scoreB != -1)
            {
                if (isForfeitB == false)
                {
                    teamBScoreLabel.text = String(scoreB)
                }
                else
                {
                    teamBScoreLabel.text = "(FF) " + String(scoreB)
                }
            }
            else
            {
                teamBScoreLabel.text = "--"
            }
            
            let teamAResult = teamA["result"] as? String ?? ""
            let teamBResult = teamB["result"] as? String ?? ""
            
            if (teamBResult.uppercased() == "L")
            {
                // Change the color of the title and score
                teamBNameLabel.textColor = UIColor.mpLightGrayColor()
                teamBScoreLabel.textColor = UIColor.mpLightGrayColor()
            }
            
            if (teamAResult.uppercased() == "L")
            {
                // Change the color of the title and score
                teamANameLabel.textColor = UIColor.mpLightGrayColor()
                teamAScoreLabel.textColor = UIColor.mpLightGrayColor()
            }
            
        case 5:
            dateLabel.text = "No Score"
            
        default:
            dateLabel.text = "Out of range"
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
