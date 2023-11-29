//
//  ScheduleFooterViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 9/22/21.
//

import UIKit

class ScheduleFooterViewCell: UITableViewCell
{
    @IBOutlet weak var scheduleCorrectionButton: UIButton!
    @IBOutlet weak var scoreCorrectionButton: UIButton!
    @IBOutlet weak var separatorLine: UIView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 12
        self.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.contentView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
