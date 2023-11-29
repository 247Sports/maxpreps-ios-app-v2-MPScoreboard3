//
//  RosterNoStaffShortTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/3/22.
//

import UIKit

class RosterNoStaffShortTableViewCell: UITableViewCell
{
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var addCoachNameButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        innerContainerView.layer.cornerRadius = 12
        innerContainerView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
