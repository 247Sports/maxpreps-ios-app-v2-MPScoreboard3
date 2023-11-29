//
//  TeamSelectorTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/11/21.
//

import UIKit

class TeamSelectorTableViewCell: UITableViewCell
{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var sportImageView: UIImageView!
    @IBOutlet weak var starImageView: UIImageView!
    
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
