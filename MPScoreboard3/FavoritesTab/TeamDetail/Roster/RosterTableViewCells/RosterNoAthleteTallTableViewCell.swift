//
//  RosterNoAthleteTallTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/11/21.
//

import UIKit

class RosterNoAthleteTallTableViewCell: UITableViewCell
{
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var copyFromLastSeasonButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        innerContainerView.layer.cornerRadius = 12
        innerContainerView.clipsToBounds = true
        
        copyFromLastSeasonButton.layer.cornerRadius = 8
        copyFromLastSeasonButton.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
