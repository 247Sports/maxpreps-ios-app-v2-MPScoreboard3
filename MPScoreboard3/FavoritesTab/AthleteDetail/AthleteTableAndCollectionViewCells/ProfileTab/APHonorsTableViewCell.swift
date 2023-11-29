//
//  APHonorsTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/8/23.
//

import UIKit

class APHonorsTableViewCell: UITableViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var horizLine: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
