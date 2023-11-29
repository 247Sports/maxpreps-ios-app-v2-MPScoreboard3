//
//  FilterStatsFaqFooterViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/29/23.
//

import UIKit

class FilterStatsFaqFooterViewCell: UITableViewCell
{
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var definitionButton: UIButton!
    @IBOutlet weak var faqButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
       
        innerContainerView.layer.cornerRadius = 12.0
        innerContainerView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
