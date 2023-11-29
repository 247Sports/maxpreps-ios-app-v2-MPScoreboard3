//
//  RosterStaffFooterTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/2/21.
//

import UIKit

class RosterStaffFooterTableViewCell: UITableViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var suggestButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        // Build attributed text
        let title = "Our data is publicly sourced. Something look off or incomplete? Suggest an edit."
        
        let attributedString = NSMutableAttributedString(string: title)
        
        // Bold
        let range1 = title.range(of: "publicly sourced")
        let convertedRange1 = NSRange(range1!, in: title)
        
        // MP Blue
        let range2 = title.range(of: "Suggest an edit")
        let convertedRange2 = NSRange(range2!, in: title)
        
        attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpBoldFontWith(size: 15)], range: convertedRange1)
        //attributedString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.mpBlueColor(), NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.underlineColor: UIColor.mpBlueColor()], range: convertedRange2)
        attributedString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.mpBlueColor()], range: convertedRange2)
        
        titleLabel.attributedText = attributedString
        
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
