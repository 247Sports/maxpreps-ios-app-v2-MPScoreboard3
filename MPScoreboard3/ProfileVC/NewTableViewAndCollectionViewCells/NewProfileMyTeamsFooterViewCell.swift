//
//  NewProfileMyTeamsFooterViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/13/23.
//

import UIKit

protocol NewProfileMyTeamsFooterViewCellDelegate: AnyObject
{
    func myTeamsFooterViewCellTouched()
}

class NewProfileMyTeamsFooterViewCell: UITableViewCell
{
    @IBOutlet weak var footerLabel: UILabel!
    
    weak var delegate: NewProfileMyTeamsFooterViewCellDelegate?
    
    @IBAction func contactUsButtonTouched()
    {
        self.delegate?.myTeamsFooterViewCellTouched()
    }
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
