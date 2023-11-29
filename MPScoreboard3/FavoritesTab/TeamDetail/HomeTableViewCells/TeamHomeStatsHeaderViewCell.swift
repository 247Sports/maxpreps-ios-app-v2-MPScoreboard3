//
//  TeamHomeStatsHeaderViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/16/22.
//

import UIKit

class TeamHomeStatsHeaderViewCell: UITableViewCell
{
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var yearLabel: UILabel!

    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        innerContainerView.layer.cornerRadius = 12
        innerContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        innerContainerView.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
