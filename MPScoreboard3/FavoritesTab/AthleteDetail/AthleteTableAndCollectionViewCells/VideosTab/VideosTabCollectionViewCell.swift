//
//  VideosTabCollectionViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/4/21.
//

import UIKit

class VideosTabCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var articleTitleLabel: UILabel!
    @IBOutlet weak var videoPlayIconImageView: UIImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        thumbnailImageView.layer.cornerRadius = 8
        thumbnailImageView.clipsToBounds = true
    }

}
