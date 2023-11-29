//
//  PlayerInfoClassTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/9/23.
//

import UIKit

class PlayerInfoClassTableViewCell: UITableViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sportLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        
        sportLabel.text = ""
        classLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
