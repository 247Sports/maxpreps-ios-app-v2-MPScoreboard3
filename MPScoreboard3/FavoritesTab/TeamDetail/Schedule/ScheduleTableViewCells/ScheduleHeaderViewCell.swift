//
//  ScheduleHeaderViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 9/20/21.
//

import UIKit

class ScheduleHeaderViewCell: UITableViewCell
{
    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var scheduleSortButton: UIButton!
    @IBOutlet weak var scheduleShowDeletedButton: UIButton!
    
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
