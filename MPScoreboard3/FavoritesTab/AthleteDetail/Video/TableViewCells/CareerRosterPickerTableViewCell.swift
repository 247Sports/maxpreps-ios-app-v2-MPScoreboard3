//
//  CareerRosterPickerTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 11/9/22.
//

import UIKit

class CareerRosterPickerTableViewCell: UITableViewCell
{
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var genderSportLabel: UILabel!
    @IBOutlet weak var sportIconImageView: UIImageView!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    @IBOutlet weak var horizLine: UIView!

    override func awakeFromNib()
    {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
