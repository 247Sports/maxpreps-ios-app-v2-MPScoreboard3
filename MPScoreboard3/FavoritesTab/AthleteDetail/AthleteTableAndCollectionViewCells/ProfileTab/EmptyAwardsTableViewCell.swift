//
//  EmptyAwardsTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/21/23.
//

import UIKit

class EmptyAwardsTableViewCell: UITableViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var addNewButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
