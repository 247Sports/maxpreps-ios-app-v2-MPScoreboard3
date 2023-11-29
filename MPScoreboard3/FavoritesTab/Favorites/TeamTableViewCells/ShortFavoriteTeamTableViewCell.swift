//
//  ShortFavoriteTeamTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/11/21.
//

import UIKit

class ShortFavoriteTeamTableViewCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var teamMascotImageView: UIImageView!
    @IBOutlet weak var teamFirstLetterLabel: UILabel!
    @IBOutlet weak var adminContainerView: UIView!
    @IBOutlet weak var joinButton: UIButton!
    
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
