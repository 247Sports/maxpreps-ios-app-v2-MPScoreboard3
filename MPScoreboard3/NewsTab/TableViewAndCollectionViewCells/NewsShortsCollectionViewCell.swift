//
//  NewsShortsCollectionViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 11/21/23.
//

import UIKit

class NewsShortsCollectionViewCell: UICollectionViewCell 
{
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    // MARK: - Load Data
    
    func loadData(data: Dictionary<String,Any>)
    {
        
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
    }

}
