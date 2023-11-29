//
//  NotificationCareerTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/23/23.
//

import UIKit

class NotificationCareerTableViewCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var teamMascotImageView: UIImageView!
    @IBOutlet weak var teamFirstLetterLabel: UILabel!
    
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
