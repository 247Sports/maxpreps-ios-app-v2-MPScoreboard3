//
//  NewClaimedAthletesTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/29/23.
//

import UIKit

class NewClaimedAthletesTableViewCell: UITableViewCell
{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var classYearLabel: UILabel!
    @IBOutlet weak var athleteImageView: UIImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        athleteImageView.layer.cornerRadius = athleteImageView.frame.size.width / 2.0
        athleteImageView.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
