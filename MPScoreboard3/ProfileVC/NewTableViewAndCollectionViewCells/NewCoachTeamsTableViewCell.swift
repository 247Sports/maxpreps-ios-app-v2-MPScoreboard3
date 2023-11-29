//
//  NewCoachTeamsTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 7/12/23.
//

import UIKit

class NewCoachTeamsTableViewCell: UITableViewCell
{
    @IBOutlet weak var upperContainerView: UIView!
    @IBOutlet weak var mascotContainerView: UIView!
    @IBOutlet weak var teamLetterLabel: UILabel!
    @IBOutlet weak var mascotImageView: UIImageView!
    @IBOutlet weak var manageTeamButton: UIButton!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var genderSportYearLabel: UILabel!
    
    @IBOutlet weak var middleLeftContainerView: UIView!
    @IBOutlet weak var gameCountLabel: UILabel!
    
    @IBOutlet weak var middleRightContainerView: UIView!
    @IBOutlet weak var rosterCountLabel: UILabel!
    
    @IBOutlet weak var lowerContainerView: UIView!
    @IBOutlet weak var gamesPlayedLabel: UILabel!
    @IBOutlet weak var gamesWithFinalScoresLabel: UILabel!
    @IBOutlet weak var gamesWithStatsLabel: UILabel!
    @IBOutlet weak var playerOfTheGameAwardsLabel: UILabel!
    
    @IBOutlet weak var gameChangerBackgroundView: UIView!
    @IBOutlet weak var hudlBackgroundView: UIView!
    
    // MARK: - Load Data
    
    func loadData(_ data: Dictionary<String,Any>)
    {
        mascotImageView.image = nil
        teamLetterLabel.isHidden = true
        
        let schoolName = data["schoolName"] as! String
        schoolNameLabel.text = schoolName
        
        let adminRoleTitle = data["adminRoleTitle"] as! String
        positionLabel.text = adminRoleTitle
        
        let gender = data["gender"] as! String
        let sport = data["sport"] as! String
        let level = data["teamLevel"] as! String
        let year = data["year"] as! String
        let season = data["season"] as! String
        
        let genderSportLevel = MiscHelper.genderSportLevelFrom(gender: gender, sport: sport, level: level)
        genderSportYearLabel.text = String(format: "%@ | 20%@ %@", genderSportLevel, year, season)
        
        let schoolInitial = schoolName.first?.uppercased()
        teamLetterLabel.text = schoolInitial
        
        let colorString = data["schoolColor1"] as! String
        teamLetterLabel.textColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
        upperContainerView.backgroundColor = teamLetterLabel.textColor
        
        let contestCount = data["contestCount"] as! Int
        gameCountLabel.text = String(contestCount)
        
        let athleteCount = data["athleteCount"] as! Int
        rosterCountLabel.text = String(athleteCount)
        
        let contestPlayedCount = data["contestPlayedCount"] as! Int
        gamesPlayedLabel.text = String(format: "%d/%d", contestPlayedCount, contestCount)
        
        let contestFinalCount = data["contestFinalCount"] as! Int
        gamesWithFinalScoresLabel.text = String(format: "%d/%d", contestFinalCount, contestPlayedCount)
        
        if (contestFinalCount == contestPlayedCount)
        {
            gamesWithFinalScoresLabel.textColor = UIColor.mpBlackColor()
        }
        else
        {
            gamesWithFinalScoresLabel.textColor = UIColor.mpRedColor()
        }
        
        let contestStatsCount = data["contestStatsCount"] as! Int
        gamesWithStatsLabel.text = String(format: "%d/%d", contestStatsCount, contestPlayedCount)
        
        if (contestStatsCount == contestPlayedCount)
        {
            gamesWithStatsLabel.textColor = UIColor.mpBlackColor()
        }
        else
        {
            gamesWithStatsLabel.textColor = UIColor.mpRedColor()
        }
        
        let potgCount = data["potgCount"] as! Int
        playerOfTheGameAwardsLabel.text = String(potgCount)
        
        // Show the HUDL or gameChanger views
        hudlBackgroundView.isHidden = true
        gameChangerBackgroundView.isHidden = true
        
        let hudlCount = data["hudlContestCount"] as! Int
        let gameChangerConnected = data["isGameChangerConnected"] as! Bool
        
        if (hudlCount > 0)
        {
            hudlBackgroundView.isHidden = false
        }
        
        if (gameChangerConnected == true)
        {
            gameChangerBackgroundView.isHidden = false
        }
        
        let mascotUrl = data["schoolMascotUrl"] as? String ?? ""
        
        if (mascotUrl.count > 0)
        {
            // Get the data and make an image
            let url = URL(string: mascotUrl)
            
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
                        self.teamLetterLabel.isHidden = false
                    }
                }
            }
        }
        else
        {
            self.teamLetterLabel.isHidden = false
            
        }
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        upperContainerView.layer.cornerRadius = 12.0
        upperContainerView.clipsToBounds = true
        
        mascotContainerView.layer.cornerRadius = mascotContainerView.frame.size.width / 2.0
        mascotContainerView.clipsToBounds = true
        
        middleLeftContainerView.layer.cornerRadius = 12.0
        middleLeftContainerView.clipsToBounds = true
        
        middleRightContainerView.layer.cornerRadius = 12.0
        middleRightContainerView.clipsToBounds = true
        
        lowerContainerView.layer.cornerRadius = 8.0
        lowerContainerView.clipsToBounds = true
        
        gameChangerBackgroundView.layer.cornerRadius = 12.0
        gameChangerBackgroundView.clipsToBounds = true
        
        hudlBackgroundView.layer.cornerRadius = 12.0
        hudlBackgroundView.clipsToBounds = true
        
        // Resize the middle containers to fit the width
        let middleWidth = (kDeviceWidth - 40.0) / 2.0
        middleLeftContainerView.frame = CGRect(x: 16.0, y: middleLeftContainerView.frame.origin.y, width: middleWidth, height: middleLeftContainerView.frame.size.height)
        middleRightContainerView.frame = CGRect(x: kDeviceWidth - middleWidth - 16.0, y: middleRightContainerView.frame.origin.y, width: middleWidth, height: middleRightContainerView.frame.size.height)
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
