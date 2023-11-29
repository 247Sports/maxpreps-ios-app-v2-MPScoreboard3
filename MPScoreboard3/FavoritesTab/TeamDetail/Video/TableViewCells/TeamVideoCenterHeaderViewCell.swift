//
//  TeamVideoCenterHeaderViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 9/9/22.
//

import UIKit

class TeamVideoCenterHeaderViewCell: UITableViewCell
{
    @IBOutlet weak var sortButtonContainerView: UIView!
    @IBOutlet weak var sortLabel: UILabel!
    @IBOutlet weak var sortButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        sortButtonContainerView.layer.cornerRadius = 8
        sortButtonContainerView.layer.borderColor = UIColor(white: 0.30, alpha: 1).cgColor
        sortButtonContainerView.layer.borderWidth = 1
        sortButtonContainerView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
