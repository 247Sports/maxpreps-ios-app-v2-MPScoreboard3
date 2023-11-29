//
//  TaggedAthleteTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/25/22.
//

import UIKit

class TaggedAthleteTableViewCell: UITableViewCell
{
    @IBOutlet weak var athleteImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var deleteAthleteButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        athleteImageView.layer.cornerRadius = athleteImageView.frame.size.height / 2.0
        athleteImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
