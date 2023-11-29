//
//  NotificationSchoolTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/15/22.
//

import UIKit

class NotificationSchoolTableViewCell: UITableViewCell
{
    @IBOutlet weak var mascotImageView: UIImageView!
    @IBOutlet weak var initialLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var sportLabel: UILabel!
    @IBOutlet weak var notificationCountLabel: UILabel!
    
    // MARK: - Init
    
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
