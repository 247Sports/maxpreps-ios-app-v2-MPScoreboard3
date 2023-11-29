//
//  AwardsTabCollectionViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/14/21.
//

import UIKit

class AwardsTabCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        
        titleLabel.text = ""
        dateLabel.text = ""
        iconImageView.image = nil
    }

}
