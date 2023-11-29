//
//  ScoreboardTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/19/21.
//

import UIKit

class ScoreboardTableViewCell: UITableViewCell
{
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var genderSportLabel: UILabel!
    @IBOutlet weak var sportIconImageView: UIImageView!
    @IBOutlet weak var horizLine: UIView!
    
    // MARK: - Load Data
    
    func loadData(_ scoreboard: Dictionary<String,String>)
    {
        let defaultName = scoreboard[kScoreboardDefaultNameKey]
        
        if (defaultName == "national") || (defaultName == "state")
        {
            titleLabel.text = scoreboard[kScoreboardAliasNameKey]
        }
        else
        {
            titleLabel.text = scoreboard[kScoreboardEntityNameKey]
        }
                
        let gender = scoreboard[kScoreboardGenderKey]
        let sport = scoreboard[kScoreboardSportKey]
        genderSportLabel.text = MiscHelper.genderSportFrom(gender: gender!, sport: sport!)
        
        let sportImage = MiscHelper.getImageForSport(sport!)
        sportIconImageView.image = sportImage
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
