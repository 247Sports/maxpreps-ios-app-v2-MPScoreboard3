//
//  TeamVideoDarkCareerTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/31/22.
//

import UIKit

class TeamVideoDarkCareerTableViewCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var athletePhotoImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        athletePhotoImageView.layer.cornerRadius = athletePhotoImageView.frame.size.width / 2.0
        athletePhotoImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
