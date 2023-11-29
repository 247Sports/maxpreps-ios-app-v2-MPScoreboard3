//
//  ProfileHeaderViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 9/5/23.
//

import UIKit

class ProfileHeaderViewCell: UITableViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 12
        containerView.layer.maskedCorners =  [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
