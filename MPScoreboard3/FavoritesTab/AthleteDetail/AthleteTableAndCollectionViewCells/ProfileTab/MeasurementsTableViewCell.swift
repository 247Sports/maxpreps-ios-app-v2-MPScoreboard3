//
//  MeasurementsTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/23/23.
//

import UIKit

class MeasurementsTableViewCell: UITableViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var addNewButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        titleLabel.text = ""
        valueLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
