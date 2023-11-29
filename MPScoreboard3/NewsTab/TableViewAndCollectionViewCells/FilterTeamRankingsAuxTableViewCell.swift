//
//  FilterTeamRankingsAuxTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/1/22.
//

import UIKit

class FilterTeamRankingsAuxTableViewCell: UITableViewCell
{
    @IBOutlet weak var gamesPlayedLabel: UILabel!
    @IBOutlet weak var learnMoreLabel: UILabel!
    @IBOutlet weak var learnMoreChevron: UIImageView!
    
    // MARK: Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 12
        self.contentView.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
