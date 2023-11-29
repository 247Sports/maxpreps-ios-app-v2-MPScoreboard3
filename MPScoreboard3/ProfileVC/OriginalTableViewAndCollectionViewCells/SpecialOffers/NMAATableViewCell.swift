//
//  NMAATableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 12/2/22.
//

import UIKit

class NMAATableViewCell: UITableViewCell
{
    @IBOutlet weak var selectButton: UIButton!
    
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
