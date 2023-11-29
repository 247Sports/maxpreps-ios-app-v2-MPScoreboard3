//
//  TallContestTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 9/21/21.
//

import UIKit

class TallContestTableViewCell: UITableViewCell
{
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var gameDetailLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var reportScoreButton: UIButton!
    @IBOutlet weak var initialLabel: UILabel!
    @IBOutlet weak var mascotImageView: UIImageView!
    @IBOutlet weak var liveLabel: UILabel!
    @IBOutlet weak var liveImageView: UIImageView!
    @IBOutlet weak var leftBarView: UIView!
    @IBOutlet weak var tournamentIconImageView: UIImageView!
    @IBOutlet weak var tournamentLinkbutton: UIButton!
    
    private var animationIconNames = ["Live1", "Live2", "Live3", "Live4", "Live5", "Live6", "Live7", "Live8", "Live9", "Live10", "Live11", "Live12", "Live13"]
    
    // MARK: - Animate Live Icon
    
    private func animateLiveIcon()
    {
        var animationImages = [] as! Array<UIImage>
        
        for name in animationIconNames
        {
            let image = UIImage(named: name)
            animationImages.append(image!)
        }
        
        liveImageView.animationImages = animationImages
        liveImageView.animationDuration = 2.0
        liveImageView.animationRepeatCount = 0
        liveImageView.startAnimating()
    }
    
    // MARK: - Load Data
    
    func loadData(_ data: Dictionary<String,Any>, teamColor: UIColor, myTeamId: String, showBar: Bool, gameTypeAliases: Array<String>)
    {
        leftBarView.backgroundColor = teamColor
        
        if (showBar == true)
        {
            leftBarView.isHidden = false
        }
        else
        {
            leftBarView.isHidden = true
        }
        
        dateLabel.isHidden = false
        timeLabel.isHidden = false
        liveImageView.isHidden = true
        liveLabel.isHidden = true
        liveLabel.text = ""
        reportScoreButton.isHidden = true
        locationLabel.text = ""
        tournamentLinkbutton.isHidden = true
        tournamentIconImageView.isHidden = true
        liveImageView.stopAnimating()
                
        // Get the game result
        let contest = data["contest"] as! Dictionary<String,Any>
        
        // Set the location label
        if (contest["location"] is NSNull)
        {
            
        }
        else
        {
            let location = contest["location"] as! String
            locationLabel.text = location
        }
        
        // Set the tournament label
        if (data["tournamentInfo"] is NSNull)
        {
            
        }
        else
        {
            let tournamentInfo = data["tournamentInfo"] as! Dictionary<String,Any>
            let tournamentName = tournamentInfo["name"] as! String
            tournamentLinkbutton.setTitle(tournamentName, for: .normal)
            tournamentLinkbutton.isHidden = false
            tournamentIconImageView.isHidden = false
        }
        
        // Get the dateCode to decide how to set the dateLabel and timeLabel
        let dateCode = contest["dateCode"] as! Int
        /*
         Default = 0,
         DateTBA = 1,
         TimeTBA = 2,
         DateTimeTBA = 4
         */
        
        var contestDateString = contest["date"] as? String ?? "1901-01-01T00:00:00"
        contestDateString = contestDateString.replacingOccurrences(of: "Z", with: "")
        let dateFormatter = DateFormatter()
        dateFormatter.isLenient = true
        dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
        let contestDate = dateFormatter.date(from: contestDateString)
        
        switch dateCode
        {
        case 0: // Default
            if (contestDate != nil)
            {
                dateFormatter.dateFormat = "EEE M/d"
                let dateString = dateFormatter.string(from: contestDate!)
                let todayString = dateFormatter.string(from: Date())
                
                if (todayString == dateString)
                {
                    dateLabel.text = "Today"
                }
                else
                {
                    dateLabel.text = dateString
                }
                
                dateFormatter.dateFormat = "h:mm a"
                timeLabel.text = dateFormatter.string(from: contestDate!)
            }
            else
            {
                dateLabel.text = ""
                timeLabel.text = ""
            }
            
        case 1: // DateTBA
            dateLabel.text = "TBA"
            if (contestDate != nil)
            {
                dateFormatter.dateFormat = "h:mm a"
                timeLabel.text = dateFormatter.string(from: contestDate!)
            }
            else
            {
                timeLabel.text = ""
            }
            
        case 2: // TimeTBA
            if (contestDate != nil)
            {
                dateFormatter.dateFormat = "EEE M/d"
                let dateString = dateFormatter.string(from: contestDate!)
                let todayString = dateFormatter.string(from: Date())
                
                if (todayString == dateString)
                {
                    dateLabel.text = "Today"
                }
                else
                {
                    dateLabel.text = dateString
                }
            }
            else
            {
                dateLabel.text = ""
            }
            
            timeLabel.text = "TBA"
            
        default:
            dateLabel.text = "TBA"
            timeLabel.text = "TBA"
        }
        
        // Find myTeam and the opponent
        var myTeam: Dictionary<String,Any>
        var opponentTeam: Dictionary<String,Any>
        let teams = contest["teams"] as! Array<Dictionary<String,Any>>
        let teamA = teams.first
        let teamB = teams.last
        let teamASchoolId = teamA!["teamId"] as? String ?? ""
        
        if (teamASchoolId == myTeamId)
        {
            myTeam = teamA!
            opponentTeam = teamB!
        }
        else
        {
            myTeam = teamB!
            opponentTeam = teamA!
        }
        
        // Look for TBA team
        let tbaTeam = opponentTeam["isTeamTBA"] as! Bool
        if (tbaTeam == true)
        {
            initialLabel.text = "T"
            initialLabel.textColor = UIColor.mpRedColor()
        }
        else
        {
            // Load the initial text and color
            let opponentName = opponentTeam["name"] as! String
            initialLabel.text = opponentName.first?.uppercased()
            let opponentColorString = opponentTeam["color1"] as? String ?? kMissingSchoolColor
            let opponentColor = ColorHelper.color(fromHexString: opponentColorString, colorCorrection: true)
            initialLabel.textColor = opponentColor!
            
            let mascotUrl = opponentTeam["mascotUrl"] as! String
            if (mascotUrl.count > 0)
            {
                // Get the data and make an image
                let url = URL(string: mascotUrl)
                /*
                MiscHelper.getData(from: url!) { data, response, error in
                    guard let data = data, error == nil else { return }

                    DispatchQueue.main.async()
                    {
                        let image = UIImage(data: data)
                        
                        if (image != nil)
                        {
                            self.initialLabel.isHidden = true
                            
                            // Render the mascot using this helper
                            MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.mascotImageView)!)
                        }
                    }
                }
                */
                SDWebImageManager.shared().downloadImage(with: url!, progress: { receivedSize, expectedSize in
                    
                }, completed: { image, error, cacheType, finished, imageUrl in
                    
                    if (image != nil)
                    {
                        self.initialLabel.isHidden = true
                        
                        // Render the mascot using this helper
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.mascotImageView)!)
                    }
                })
            }
        }
        
        // Load the gameDetailLabel
        let haType = opponentTeam["homeAwayType"] as! Int
        var homeAwayString = ""
        
        switch haType
        {
        case 0:
            homeAwayString = "Away"
        case 1:
            homeAwayString = "Home"
        case 2:
            homeAwayString = "Neutral"
        default:
            homeAwayString = "Unknown"
        }
        
        let contestType = opponentTeam["contestType"] as! Int
        let contestTypeString = gameTypeAliases[contestType]
        /*
        switch contestType
        {
        case 0:
            contestTypeString = "Conference"
        case 1:
            contestTypeString = "Non-Conference"
        case 2:
            contestTypeString = "Tournament"
        case 3:
            contestTypeString = "Exhibition"
        case 4:
            contestTypeString = "Playoff"
        case 5:
            contestTypeString = "Conference Tournament"
        default:
            contestTypeString = "Unknown"
        }
        */
        
        gameDetailLabel.text = homeAwayString + " • " + contestTypeString
        
        // Reset the schoolNameLabel
        schoolNameLabel.textColor = UIColor.mpGrayColor()
        schoolNameLabel.text = ""
        schoolNameLabel.font = UIFont.mpRegularFontWith(size: 11)
        
        // Load the schoolNameLabel
        if (tbaTeam == false)
        {
            let schoolName = opponentTeam["name"] as! String
            let formattedNameWithoutState = opponentTeam["formattedNameWithoutState"] as! String
            let schoolNameLength = formattedNameWithoutState.widthOfString(usingFont: schoolNameLabel.font)
            let schoolNameLabelMaxWidth = kDeviceWidth - schoolNameLabel.frame.origin.x - 95
            
            if (schoolNameLength > schoolNameLabelMaxWidth)
            {
                // Use the schoolNameAcronym merged with the city
                let city = formattedNameWithoutState.replacingOccurrences(of: schoolName, with: "")
                let schoolNameAcronym = opponentTeam["schoolNameAcronym"] as! String
                let combinedName = schoolNameAcronym + city
                
                // Make the name bold and black
                let attributedString = NSMutableAttributedString(string: combinedName)
                let range = combinedName.range(of: schoolNameAcronym)
                let convertedRange = NSRange(range!, in: combinedName)
                
                attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpBoldFontWith(size: 11), NSAttributedString.Key.foregroundColor: UIColor.mpBlackColor()], range: convertedRange)
                schoolNameLabel.attributedText = attributedString
            }
            else
            {
                // Make the name bold and black
                let attributedString = NSMutableAttributedString(string: formattedNameWithoutState)
                let range = formattedNameWithoutState.range(of: schoolName)
                let convertedRange = NSRange(range!, in: formattedNameWithoutState)
                
                attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpBoldFontWith(size: 11), NSAttributedString.Key.foregroundColor: UIColor.mpBlackColor()], range: convertedRange)
                schoolNameLabel.attributedText = attributedString
            }
        }
        else
        {
            schoolNameLabel.textColor = UIColor.mpBlackColor()
            schoolNameLabel.font = UIFont.mpBoldFontWith(size: 11)
            schoolNameLabel.text = "TBA"
        }
        
        // Clear out the scoresLabel
        scoreLabel.text = ""
        scoreLabel.textColor = UIColor.mpBlackColor()
        scoreLabel.font = UIFont.mpRegularFontWith(size: 11)
        
        let calculatedFieldsObj = data["calculatedFields"] as! Dictionary<String,Any>
        let contestState = calculatedFieldsObj["contestState"] as! Int
        
        // Contest state enums
        // 0: Unknown (TBA Date)
        // 1: Deleted
        // 2: Pregame
        // 3: In Progress
        // 4: Boxscore
        // 5: Score not Reported
        
        switch contestState
        {
        case 2:
            scoreLabel.text = ""
        case 3:
            dateLabel.isHidden = true
            timeLabel.isHidden = true
            leftBarView.isHidden = true
            liveLabel.isHidden = false
            liveImageView.isHidden = false
            self.animateLiveIcon()
            
            let currentLivePeriod = calculatedFieldsObj["currentLivePeriod"] as! String
            //if (currentLivePeriod.count > 0)
            //{
                let title = "LIVE " + currentLivePeriod
                let attributedString = NSMutableAttributedString(string: title)
                
                // Colorize the LIVE text in red
                let range = title.range(of: "LIVE")
                let convertedRange = NSRange(range!, in: title)
                
                attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 12), NSAttributedString.Key.foregroundColor: UIColor.mpRedColor()], range: convertedRange)
                
                liveLabel.attributedText = attributedString
            //}
            
            // Set the scores
            let teamsCalculated = calculatedFieldsObj["teamsCalculated"] as! Array<Dictionary<String,Any>>
            let calculatedTeamA = teamsCalculated.first!
            let calculatedTeamB = teamsCalculated.last!
            
            // Set the scores (checking for nulls)
            let scoreA = calculatedTeamA["currentLiveScore"] as? Int ?? -1
            let scoreB = calculatedTeamB["currentLiveScore"] as? Int ?? -1
            
            if (scoreA != -1) && (scoreB != -1)
            {
                scoreLabel.text = String(scoreA) + "-" + String(scoreB)
            }
            
        case 4:
            let myTeamForfeit = myTeam["isForfeit"] as! Bool
            let opponentForfeit = opponentTeam["isForfeit"] as! Bool
            
            if (myTeamForfeit == true) || (opponentForfeit == true)
            {
                if (myTeamForfeit == true) && (opponentForfeit == true)
                {
                    let scoreText = "L (DFF)"
                    
                    // Colorize the text
                    let attributedString = NSMutableAttributedString(string: scoreText)
                    let range = scoreText.range(of: "L")
                    let convertedRange = NSRange(range!, in: scoreText)
                    
                    attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 11), NSAttributedString.Key.foregroundColor: UIColor.mpRedColor()], range: convertedRange)
                    
                    scoreLabel.attributedText = attributedString
                }
                else if (myTeamForfeit == true) && (opponentForfeit == false)
                {
                    let scoreText = "L (FF)"
                    
                    // Colorize the text
                    let attributedString = NSMutableAttributedString(string: scoreText)
                    let range = scoreText.range(of: "L")
                    let convertedRange = NSRange(range!, in: scoreText)
                    
                    attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 11), NSAttributedString.Key.foregroundColor: UIColor.mpRedColor()], range: convertedRange)
                    
                    scoreLabel.attributedText = attributedString
                }
                else
                {
                    let scoreText = "W (FF)"
                    
                    // Colorize the text
                    let attributedString = NSMutableAttributedString(string: scoreText)
                    let range = scoreText.range(of: "W")
                    let convertedRange = NSRange(range!, in: scoreText)
                    
                    attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 11), NSAttributedString.Key.foregroundColor: UIColor.mpGreenColor()], range: convertedRange)
                    
                    scoreLabel.attributedText = attributedString
                }
            }
            else
            {
                // Set the scores (checking for nulls)
                let myScore = myTeam["score"] as? Int ?? -1
                let opponentScore = opponentTeam["score"] as? Int ?? -1
                
                if (myScore != -1) && (opponentScore != -1)
                {
                    let myResult = myTeam["result"] as? String ?? ""
                    
                    if (myResult.lowercased() == "w")
                    {
                        let scoreText = "W " + String(myScore) + "-" + String(opponentScore)
                        
                        // Colorize the text
                        let attributedString = NSMutableAttributedString(string: scoreText)
                        let range = scoreText.range(of: "W")
                        let convertedRange = NSRange(range!, in: scoreText)
                        
                        attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 11), NSAttributedString.Key.foregroundColor: UIColor.mpGreenColor()], range: convertedRange)
                        
                        scoreLabel.attributedText = attributedString
                    }
                    else if (myResult.lowercased() == "l")
                    {
                        let scoreText = "L " + String(myScore) + "-" + String(opponentScore)
                        
                        // Colorize the text
                        let attributedString = NSMutableAttributedString(string: scoreText)
                        let range = scoreText.range(of: "L")
                        let convertedRange = NSRange(range!, in: scoreText)
                        
                        attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 11), NSAttributedString.Key.foregroundColor: UIColor.mpRedColor()], range: convertedRange)
                        
                        scoreLabel.attributedText = attributedString
                    }
                    else
                    {
                        let scoreText = "T " + String(myScore) + "-" + String(opponentScore)
                        
                        // Colorize the text
                        let attributedString = NSMutableAttributedString(string: scoreText)
                        let range = scoreText.range(of: "T")
                        let convertedRange = NSRange(range!, in: scoreText)
                        
                        attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 11), NSAttributedString.Key.foregroundColor: UIColor.mpGrayColor()], range: convertedRange)
                        
                        scoreLabel.attributedText = attributedString
                    }
                }
                else
                {
                    scoreLabel.text = "--"
                }
            }
        case 5:
            scoreLabel.text = ""
            if (tbaTeam == false)
            {
                reportScoreButton.isHidden = false
            }
            
        default:
            scoreLabel.text = ""
        }
        
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
