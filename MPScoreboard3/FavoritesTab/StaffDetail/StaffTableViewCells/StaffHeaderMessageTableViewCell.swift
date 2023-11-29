//
//  StaffHeaderMessageTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/31/23.
//

import UIKit

class StaffHeaderMessageTableViewCell: UITableViewCell
{
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
