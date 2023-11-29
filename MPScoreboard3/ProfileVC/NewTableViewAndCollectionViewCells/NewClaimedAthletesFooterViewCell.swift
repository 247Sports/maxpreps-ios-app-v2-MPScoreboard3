//
//  NewClaimedAthletesFooterViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/29/23.
//

import UIKit

class NewClaimedAthletesFooterViewCell: UITableViewCell {

    @IBOutlet weak var supportLabel: UILabel!
    @IBOutlet weak var supportButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        let contactString = "If you need to remove a claimed profile, please contact: Support"
        let attributedString = NSMutableAttributedString(string: contactString)
                
        let range = contactString.range(of: "Support")
        let convertedRange = NSRange(range!, in: contactString)
        
        attributedString.addAttributes([NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,  NSAttributedString.Key.foregroundColor: UIColor.mpBlackColor()], range: convertedRange)
        
        supportLabel.attributedText = attributedString
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
