//
//  ClaimAthleteTeamTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/28/22.
//

import UIKit

class ClaimAthleteTeamTableViewCell: UITableViewCell
{
    @IBOutlet weak var mascotContainerView: UIView!
    @IBOutlet weak var mascotImageView: UIImageView!
    @IBOutlet weak var initialLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var sportLabel: UILabel!
    @IBOutlet weak var horizLine: UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        mascotContainerView.layer.cornerRadius = mascotContainerView.frame.size.height / 2.0
        mascotContainerView.layer.borderWidth = 1
        mascotContainerView.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        mascotContainerView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
