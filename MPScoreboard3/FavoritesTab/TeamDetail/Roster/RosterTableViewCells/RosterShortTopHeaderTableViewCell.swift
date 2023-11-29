//
//  RosterShortTopHeaderTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/10/21.
//

import UIKit

class RosterShortTopHeaderTableViewCell: UITableViewCell
{
    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var rosterSortButton: UIButton!
    @IBOutlet weak var rosterShowDeletedButton: UIButton!
    
    // MARK: - Load button title text
    
    func loadButtonTitleText()
    {
        // Build attributed text
        let title = "Do you have a team photo? Upload it here."
        
        let attributedString = NSMutableAttributedString(string: title)
        
        // Bold
        let range1 = title.range(of: "Do you have a team photo?")
        let convertedRange1 = NSRange(range1!, in: title)
        
        // MP Blue
        let range2 = title.range(of: "here")
        let convertedRange2 = NSRange(range2!, in: title)
        
        attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpBoldFontWith(size: 15)], range: convertedRange1)
        attributedString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.mpBlueColor()], range: convertedRange2)
        
        addButton.setAttributedTitle(attributedString, for: .normal)
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

    }
    
}
