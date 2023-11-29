//
//  AltTeamSelectorTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/11/21.
//

import UIKit

class AltTeamSelectorTableViewCell: UITableViewCell
{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var sportImageView: UIImageView!
    @IBOutlet weak var varsityStarImageView: UIImageView!
    @IBOutlet weak var jvStarImageView: UIImageView!
    @IBOutlet weak var freshmanStarImageView: UIImageView!
    @IBOutlet weak var varsityLabel: UILabel!
    @IBOutlet weak var jvLabel: UILabel!
    @IBOutlet weak var freshmanLabel: UILabel!
    @IBOutlet weak var varsityChevronImageView: UIImageView!
    @IBOutlet weak var jvChevronImageView: UIImageView!
    @IBOutlet weak var freshmanChevronImageView: UIImageView!
    
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
