//
//  TeamHomePBPTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 7/25/23.
//

import UIKit

class TeamHomePBPTableViewCell: UITableViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageContainerView: UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        
        imageContainerView.layer.cornerRadius = 2
        imageContainerView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
