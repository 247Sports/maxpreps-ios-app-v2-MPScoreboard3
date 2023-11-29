//
//  SubscriptionsTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/1/22.
//

import UIKit

class SubscriptionsTableViewCell: UITableViewCell
{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    
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
