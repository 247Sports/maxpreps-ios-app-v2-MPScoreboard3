//
//  FilterPlayoffsTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/11/23.
//

import UIKit

class FilterPlayoffsTableViewCell: UITableViewCell
{
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        innerContainerView.layer.cornerRadius = 8
        innerContainerView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
