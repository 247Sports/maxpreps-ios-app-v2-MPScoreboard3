//
//  PreGameWithLiveTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/18/21.
//

import UIKit

class PreGameWithLiveTableViewCell: UITableViewCell
{
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var mascotContainerView: UIView!
    @IBOutlet weak var mascotImageView: UIImageView!
    @IBOutlet weak var initialLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var viewLiveButton: UIButton!
    @IBOutlet weak var schoolANameLabel: UILabel!
    @IBOutlet weak var schoolBNameLabel: UILabel!
    @IBOutlet weak var schoolARecordLabel: UILabel!
    @IBOutlet weak var schoolBRecordLabel: UILabel!
    @IBOutlet weak var genderSportLabel: UILabel!
    @IBOutlet weak var sportIconImageView: UIImageView!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var bottomContainerView: UIView!
    
    @IBOutlet weak var bottomLeftInnerContainerView: UIView!
    @IBOutlet weak var bottomLeftSchoolNameLabel: UILabel!
    @IBOutlet weak var bottomLeftTitleLabel: UILabel!
    @IBOutlet weak var bottomLeftSubtitleLabel: UILabel!
    @IBOutlet weak var bottomLeftImageView: UIImageView!
    @IBOutlet weak var bottomLeftButton: UIButton!
    
    @IBOutlet weak var bottomRightInnerContainerView: UIView!
    @IBOutlet weak var bottomRightSchoolNameLabel: UILabel!
    @IBOutlet weak var bottomRightTitleLabel: UILabel!
    @IBOutlet weak var bottomRightSubtitleLabel: UILabel!
    @IBOutlet weak var bottomRightImageView: UIImageView!
    @IBOutlet weak var bottomRightButton: UIButton!
    
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
        
        let teams = data["teams"] as! Array<Dictionary<String,Any>>
        var teamA = teams[0]
        var teamB = teams[1]
        let haType = teamA["homeAwayType"] as! Int
        
        if (haType == 0) // Home is teamB
        {
            teamA = teams[1]
            teamB = teams[0]
        }
                
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
        let teamANameLabelMaxWidth = kDeviceWidth - schoolANameLabel.frame.origin.x - 60
        let teamBNameLabelMaxWidth = kDeviceWidth - schoolBNameLabel.frame.origin.x - 60
        
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
        
        let dateCode = data["dateCode"] as? Int ?? 0
        if (dateCode == 0)
        {
            var contestDateString = data["date"] as! String
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
        
        // Load the bottom left and right sections with the scorer info
        
        //let calculatedFieldsObj = data["calculatedFields"] as! Dictionary<String,Any>
        //let contestState = calculatedFieldsObj["contestState"] as! Int
        
        /*

        - key : scorerName
        - value : String
        - key : hasAssignedScorer
        - value : 0 (Bool)
        - key : acceptedScoreCount
        - value : 0 (Int)
        - key : calculatedScoreRating
        - value : 0 (Int, not used)
        - key : scorerPhotoUrl
        - value : String
         */
        
        // Reset the bottom cells in case they are recycled
        bottomLeftTitleLabel.textColor = UIColor.mpBlackColor()
        bottomRightTitleLabel.textColor = UIColor.mpBlackColor()
        bottomLeftTitleLabel.text = ""
        bottomRightTitleLabel.text = ""
        bottomLeftSubtitleLabel.textColor = UIColor.mpGrayColor()
        bottomRightSubtitleLabel.textColor = UIColor.mpGrayColor()
        
        bottomLeftSchoolNameLabel.text = teamAName
        bottomRightSchoolNameLabel.text = teamBName
        
        let teamAHasScorer = teamA["hasAssignedScorer"] as! Bool
        let teamBHasScorer = teamB["hasAssignedScorer"] as! Bool
        
        if (teamAHasScorer == true)
        {
            let scorerName = teamA["scorerName"] as! String
            bottomLeftTitleLabel.text = scorerName
            
            let acceptedScoreCount = teamA["qualityGames"] as! Int
            let acceptedScoreCountString = String(acceptedScoreCount)
            
            let subtitle = "Games Scored: " + acceptedScoreCountString
            let attributedString = NSMutableAttributedString(string: subtitle)
            
            // Bold and Blacken the scoreCount
            let range = subtitle.range(of: acceptedScoreCountString)
            let convertedRange = NSRange(range!, in: subtitle)
            
            attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpBoldFontWith(size: 11), NSAttributedString.Key.foregroundColor: UIColor.mpBlackColor()], range: convertedRange)
            
            bottomLeftSubtitleLabel.attributedText = attributedString
            
            bottomLeftImageView.image = UIImage(named: "Avatar")
            
            // Load the photo
            let photoUrl = teamA["scorerPhotoUrl"] as! String
            if (photoUrl.count > 0)
            {
                // Get the data and make an image
                let url = URL(string: photoUrl)
                
                MiscHelper.getData(from: url!) { data, response, error in
                    guard let data = data, error == nil else { return }

                    DispatchQueue.main.async()
                    {
                        let image = UIImage(data: data)
                        
                        if (image != nil)
                        {
                            self.bottomLeftImageView.image = image
                        }
                    }
                }
            }
        }
        else
        {
            bottomLeftImageView.image = UIImage(named: "AddScorerIcon")
            bottomLeftTitleLabel.text = "Sign up"
            bottomLeftTitleLabel.textColor = UIColor.mpBlueColor()
            bottomLeftSubtitleLabel.text = "Become a Live Scorer"
            bottomLeftSubtitleLabel.textColor = UIColor.mpBlueColor()
        }
        
        if (teamBHasScorer == true)
        {
            let scorerName = teamB["scorerName"] as! String
            bottomRightTitleLabel.text = scorerName
            
            let acceptedScoreCount = teamB["qualityGames"] as! Int
            let acceptedScoreCountString = String(acceptedScoreCount)
            
            let subtitle = "Games Scored: " + acceptedScoreCountString
            let attributedString = NSMutableAttributedString(string: subtitle)
            
            // Bold and Blacken the scoreCount
            let range = subtitle.range(of: acceptedScoreCountString)
            let convertedRange = NSRange(range!, in: subtitle)
            
            attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpBoldFontWith(size: 11), NSAttributedString.Key.foregroundColor: UIColor.mpBlackColor()], range: convertedRange)
            
            bottomRightSubtitleLabel.attributedText = attributedString
            
            bottomRightImageView.image = UIImage(named: "Avatar")
            
            // Load the photo
            let photoUrl = teamB["scorerPhotoUrl"] as! String
            if (photoUrl.count > 0)
            {
                // Get the data and make an image
                let url = URL(string: photoUrl)
                
                MiscHelper.getData(from: url!) { data, response, error in
                    guard let data = data, error == nil else { return }

                    DispatchQueue.main.async()
                    {
                        let image = UIImage(data: data)
                        
                        if (image != nil)
                        {
                            self.bottomRightImageView.image = image
                        }
                    }
                }
            }
        }
        else
        {
            bottomRightImageView.image = UIImage(named: "AddScorerIcon")
            bottomRightTitleLabel.text = "Sign up"
            bottomRightTitleLabel.textColor = UIColor.mpBlueColor()
            bottomRightSubtitleLabel.text = "Become a Live Scorer"
            bottomRightSubtitleLabel.textColor = UIColor.mpBlueColor()
        }
        
        // Show the live link button
        viewLiveButton.isHidden = true
        let nfhsStreamUrl = data["nfhsStreamUrl"] as! String
        
        if (nfhsStreamUrl.count > 0)
        {
            viewLiveButton.isHidden = false
        }
        
        weatherIconImageView.image = nil
        temperatureLabel.text = ""
        
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
        self.topContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.topContainerView.clipsToBounds = true
        
        self.bottomContainerView.layer.cornerRadius = kCornerRadius
        self.bottomContainerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.bottomContainerView.clipsToBounds = true
        
        // Resize the bottom inner containers
        self.bottomLeftInnerContainerView.frame = CGRect(x: 0, y: 0, width: kDeviceWidth / 2, height: bottomLeftInnerContainerView.frame.size.height)
        self.bottomRightInnerContainerView.frame = CGRect(x: kDeviceWidth / 2, y: 0, width: kDeviceWidth / 2, height: bottomRightInnerContainerView.frame.size.height)
        
        self.bottomLeftImageView.layer.cornerRadius = bottomLeftImageView.frame.size.width / 2.0
        self.bottomLeftImageView.clipsToBounds = true
        
        self.bottomRightImageView.layer.cornerRadius = bottomRightImageView.frame.size.width / 2.0
        self.bottomRightImageView.clipsToBounds = true
        
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
