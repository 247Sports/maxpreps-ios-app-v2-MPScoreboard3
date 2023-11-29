//
//  TeamVideosTopHeaderCollectionReusableView.swift
//  MPScoreboard3
//
//  Created by David Smith on 7/12/22.
//

import UIKit

class TeamVideosTopHeaderCollectionReusableView: UICollectionReusableView
{
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var videoThumbnailImageView: UIImageView!
    @IBOutlet weak var videoPlayButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

    }
    
}
