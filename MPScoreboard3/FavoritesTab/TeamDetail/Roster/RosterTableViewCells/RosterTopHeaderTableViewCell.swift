//
//  RosterTopHeaderTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 7/30/21.
//

import UIKit

class RosterTopHeaderTableViewCell: UITableViewCell
{
    @IBOutlet weak var teamPhotoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var rosterSortButton: UIButton!
    @IBOutlet weak var rosterShowDeletedButton: UIButton!
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        editButton.layer.cornerRadius = 8
        editButton.layer.borderWidth = 1
        editButton.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        editButton.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

    }
    
}
