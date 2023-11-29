//
//  BasicScoresTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/18/21.
//

import UIKit

class BasicScoresTableViewCell: UITableViewCell
{
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var mascotContainerView: UIView!
    @IBOutlet weak var mascotImageView: UIImageView!
    @IBOutlet weak var initialLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var schoolANameLabel: UILabel!
    @IBOutlet weak var schoolBNameLabel: UILabel!
    @IBOutlet weak var schoolARecordLabel: UILabel!
    @IBOutlet weak var schoolBRecordLabel: UILabel!
    @IBOutlet weak var schoolAScoreLabel: UILabel!
    @IBOutlet weak var schoolBScoreLabel: UILabel!
    @IBOutlet weak var genderSportLabel: UILabel!
    @IBOutlet weak var sportIconImageView: UIImageView!
    @IBOutlet weak var inningArrowImageView: UIImageView!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    private var kCornerRadius = CGFloat(12)
    
    // MARK: - Load Data
    
    func loadData(_ data: Dictionary<String,Any>, teamInfo: TeamLight)
    {
        genderSportLabel.text = MiscHelper.genderSportLevelFrom(gender: teamInfo.gender, sport: teamInfo.sport, level: teamInfo.teamLevel)
        
        let sportImage = MiscHelper.getImageForSport(teamInfo.sport)
        sportIconImageView.image = sportImage
        
        let initial = teamInfo.schoolName.first?.uppercased()
        initialLabel.text = initial
        let color = ColorHelper.color(fromHexString: teamInfo.teamColor, colorCorrection: true)
        initialLabel.textColor = color
        initialLabel.isHidden = true
        
        if (teamInfo.mascotUrl.count > 0)
        {
            // Get the data and make an image
            let url = URL(string: teamInfo.mascotUrl)
            
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {                        
                        // Render the mascot using this helper
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.mascotImageView)!)
                    }
                    else
                    {
                        self.initialLabel.isHidden = false
                    }
                }
            }
        }
        else
        {
            initialLabel.isHidden = false
        }
        
        /*
         let teams = contest["teams"] as! Array<Dictionary<String,Any>>
         var teamA = teams[0]
         var teamB = teams[1]
         let haType = teamA["homeAwayType"] as! Int
         
         if (haType == 0) // Home is teamB
         {
             teamA = teams[1]
             teamB = teams[0]
         }
         */
        
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
        
        let teamAName = teamA["name"] as? String ?? "TBA"
        let teamBName = teamB["name"] as? String ?? "TBA"
        schoolANameLabel.text = teamAName
        schoolBNameLabel.text = teamBName
        
        // Load and shift the team record labels
        let teamARecord = teamA["standings"] as? String ?? ""
        let teamBRecord = teamB["standings"] as? String ?? ""
        
        schoolARecordLabel.text = teamARecord
        schoolBRecordLabel.text = teamBRecord
        
        let teamANameLength = teamAName.widthOfString(usingFont: schoolANameLabel.font)
        let teamBNameLength = teamBName.widthOfString(usingFont: schoolBNameLabel.font)
        let teamANameLabelMaxWidth = kDeviceWidth - schoolANameLabel.frame.origin.x - 125
        let teamBNameLabelMaxWidth = kDeviceWidth - schoolBNameLabel.frame.origin.x - 125
        
        if (teamANameLength < teamANameLabelMaxWidth)
        {
            schoolARecordLabel.frame = CGRect(x: schoolANameLabel.frame.origin.x + CGFloat(teamANameLength) + CGFloat(8), y: schoolARecordLabel.frame.origin.y, width: schoolARecordLabel.frame.size.width, height: schoolARecordLabel.frame.size.height)
        }
        else
        {
            schoolARecordLabel.frame = CGRect(x: schoolANameLabel.frame.origin.x + CGFloat(teamANameLabelMaxWidth) + CGFloat(8), y: schoolARecordLabel.frame.origin.y, width: schoolARecordLabel.frame.size.width, height: schoolARecordLabel.frame.size.height)
        }
        
        if (teamBNameLength < teamBNameLabelMaxWidth)
        {
            schoolBRecordLabel.frame = CGRect(x: schoolBNameLabel.frame.origin.x + CGFloat(teamBNameLength) + CGFloat(8), y: schoolBRecordLabel.frame.origin.y, width: schoolBRecordLabel.frame.size.width, height: schoolBRecordLabel.frame.size.height)
        }
        else
        {
            schoolBRecordLabel.frame = CGRect(x: schoolBNameLabel.frame.origin.x + CGFloat(teamBNameLabelMaxWidth) + CGFloat(8), y: schoolBRecordLabel.frame.origin.y, width: schoolBRecordLabel.frame.size.width, height: schoolBRecordLabel.frame.size.height)
        }
        
        // Clear out the scoresLabels
        schoolAScoreLabel.text = ""
        schoolBScoreLabel.text = ""
        
        // Reset the fonts and colors in case this cell is recycled
        dateLabel.font = UIFont.mpBoldFontWith(size: 12)
        dateLabel.textColor = UIColor.mpBlackColor()
        schoolANameLabel.textColor = UIColor.mpBlackColor()
        schoolAScoreLabel.textColor = UIColor.mpBlackColor()
        schoolBNameLabel.textColor = UIColor.mpBlackColor()
        schoolBScoreLabel.textColor = UIColor.mpBlackColor()
        inningArrowImageView.image = nil
        
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
                let title = currentLivePeriod + "  LIVE"
                let attributedString = NSMutableAttributedString(string: title)
                
                // Colorize the LIVE text in red
                let range = title.range(of: "LIVE")
                let convertedRange = NSRange(range!, in: title)
                
                attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 12), NSAttributedString.Key.foregroundColor: UIColor.mpRedColor()], range: convertedRange)
                
                dateLabel.attributedText = attributedString
                
                let currentLiveTime = calculatedFieldsObj["currentLiveTime"] as? String ?? ""
                if (currentLiveTime == "Top")
                {
                    inningArrowImageView.image = UIImage(named: "SmallUpArrowBlack")
                }
                else if (currentLiveTime == "Bottom")
                {
                    inningArrowImageView.image = UIImage(named: "SmallDownArrowBlack")
                }
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
                schoolAScoreLabel.text = String(scoreA)
            }

            if (scoreB != -1)
            {
                schoolBScoreLabel.text = String(scoreB)
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
                    schoolAScoreLabel.text = String(scoreA)
                }
                else
                {
                    schoolAScoreLabel.text = "(FF) " + String(scoreA)
                }
            }
            else
            {
                schoolAScoreLabel.text = "--"
            }
            
            if (scoreB != -1)
            {
                if (isForfeitB == false)
                {
                    schoolBScoreLabel.text = String(scoreB)
                }
                else
                {
                    schoolBScoreLabel.text = "(FF) " + String(scoreB)
                }
            }
            else
            {
                schoolBScoreLabel.text = "--"
            }
            
            let teamAResult = teamA["result"] as? String ?? ""
            let teamBResult = teamB["result"] as? String ?? ""
            
            if (teamBResult.uppercased() == "L")
            {
                // Change the color of the opponent's title and score
                schoolBNameLabel.textColor = UIColor.mpLightGrayColor()
                schoolBScoreLabel.textColor = UIColor.mpLightGrayColor()
            }
            
            if (teamAResult.uppercased() == "L")
            {
                // Change the color of the title and score
                schoolANameLabel.textColor = UIColor.mpLightGrayColor()
                schoolAScoreLabel.textColor = UIColor.mpLightGrayColor()
            }
            
        case 5:
            dateLabel.text = "FINAL"
            
        default:
            dateLabel.text = "Out of range"
        }
        
        weatherIconImageView.image = nil
        temperatureLabel.text = ""
        
        // Need to load the image and temp label for contest states 2 and 3
        if ((contestState == 2) || (contestState == 3))
        {
            if let weatherObj = data["weather"] as? Dictionary<String,Any>
            {
                let temp = weatherObj["temperatureFahrenheit"] as? Double ?? -200.0
                
                if (temp != -200.0)
                {
                    temperatureLabel.text = String(format: "%1.0f°F", temp.rounded())
                }
                
                let weatherCondition = weatherObj["weatherCondition"] as! Int
                let isDaylight = weatherObj["isDaylight"] as! Bool
                
                let weatherImage = WeatherHelper.weatherImageFor(condition: weatherCondition, isDaylight: isDaylight)
                weatherIconImageView.image = weatherImage
                
                if (weatherImage == nil)
                {
                    // Shift the temp label to the right
                    temperatureLabel.center = CGPoint(x: temperatureLabel.center.x + 20, y: temperatureLabel.center.y)
                }
            }
        }
    }
    
    // MARK: - Draw Shape Layers
    
    func addShapeLayers(color: UIColor)
    {
        // Create a new path for the rear light part
        let rearPath = UIBezierPath()

        // Starting point for the path
        rearPath.move(to: CGPoint(x: 0, y: 0))
        rearPath.addLine(to: CGPoint(x: 60, y: 0))
        rearPath.addLine(to: CGPoint(x: 30, y: topContainerView.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: topContainerView.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: 0))
        rearPath.close()
        
        // Create a CAShapeLayer
        //let lightColor = color.lighter(by: 70.0)
        let lightColor = color.withAlphaComponent(0.3)
        let rearShapeLayer = CAShapeLayer()
        rearShapeLayer.path = rearPath.cgPath
        rearShapeLayer.fillColor = lightColor.cgColor
        rearShapeLayer.position = CGPoint(x: 0, y: 0)

        self.topContainerView.layer.insertSublayer(rearShapeLayer, below: self.mascotContainerView.layer)
        
        
        // Create a new path for the dark front part
        let frontPath = UIBezierPath()

        // Starting point for the path
        frontPath.move(to: CGPoint(x: 0, y: 0))
        frontPath.addLine(to: CGPoint(x: 47, y: 0))
        frontPath.addLine(to: CGPoint(x: 26, y: topContainerView.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: topContainerView.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: 0))
        frontPath.close()
        
        // Create a CAShapeLayer
        let frontShapeLayer = CAShapeLayer()
        frontShapeLayer.path = frontPath.cgPath
        frontShapeLayer.fillColor = color.cgColor
        frontShapeLayer.position = CGPoint(x: 0, y: 0)

        self.topContainerView.layer.insertSublayer(frontShapeLayer, above: rearShapeLayer)
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        self.topContainerView.layer.cornerRadius = kCornerRadius
        self.topContainerView.clipsToBounds = true
        
        mascotContainerView.layer.cornerRadius = self.mascotContainerView.frame.size.width / 2.0
        mascotContainerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        mascotContainerView.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        mascotContainerView.layer.shadowOpacity = 1.0
        mascotContainerView.layer.shadowRadius = 4.0
        mascotContainerView.clipsToBounds = false
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
