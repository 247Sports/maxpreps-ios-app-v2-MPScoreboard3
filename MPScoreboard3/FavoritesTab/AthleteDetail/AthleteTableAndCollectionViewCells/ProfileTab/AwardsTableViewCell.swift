//
//  AwardsTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/21/23.
//

import UIKit

class AwardsTableViewCell: UITableViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var horizLine: UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        titleLabel.text = ""
        subtitleLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
