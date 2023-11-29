//
//  PlayerInfoBioTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/9/23.
//

import UIKit

class PlayerInfoBioTableViewCell: UITableViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var addNewButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        
        addNewButton.isHidden = true
        bioLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
