//
//  PlayerInfoHeaderViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/9/23.
//

import UIKit

class PlayerInfoHeaderViewCell: UITableViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var playerInfoEditButton: UIButton!
    
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
