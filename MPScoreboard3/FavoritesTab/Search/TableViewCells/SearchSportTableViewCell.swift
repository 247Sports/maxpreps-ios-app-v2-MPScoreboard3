//
//  SearchSportTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/2/21.
//

import UIKit

class SearchSportTableViewCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sportIconImageView: UIImageView!
    
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
