//
//  TeamVideoDarkCareerHeaderViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/31/22.
//

import UIKit

class TeamVideoDarkCareerHeaderViewCell: UITableViewCell
{
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var taggedLabel: UILabel!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
