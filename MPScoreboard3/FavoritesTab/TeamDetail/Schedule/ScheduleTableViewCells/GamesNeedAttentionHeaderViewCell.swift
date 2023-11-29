//
//  GamesNeedAttentionHeaderViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 9/20/21.
//

import UIKit

class GamesNeedAttentionHeaderViewCell: UITableViewCell
{
    @IBOutlet weak var innerBackgroundView: UIView!
    @IBOutlet weak var gameCountLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var downArrowImageView: UIImageView!
    @IBOutlet weak var gamesNeedAttentionButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        innerBackgroundView.layer.cornerRadius = 12
        innerBackgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        innerBackgroundView.clipsToBounds = true
        
        gameCountLabel.layer.cornerRadius = gameCountLabel.frame.size.width / 2
        gameCountLabel.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
