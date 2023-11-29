//
//  StaffInfoBioTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/1/23.
//

import UIKit

class StaffInfoBioTableViewCell: UITableViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bioLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        
        bioLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
