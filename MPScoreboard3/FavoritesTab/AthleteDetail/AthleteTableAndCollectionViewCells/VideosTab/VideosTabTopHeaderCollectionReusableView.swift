//
//  VideosTabTopHeaderCollectionReusableView.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/16/21.
//

import UIKit

class VideosTabTopHeaderCollectionReusableView: UICollectionReusableView
{
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var videoThumbnailImageView: UIImageView!
    @IBOutlet weak var videoPlayButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

    }
    
}
