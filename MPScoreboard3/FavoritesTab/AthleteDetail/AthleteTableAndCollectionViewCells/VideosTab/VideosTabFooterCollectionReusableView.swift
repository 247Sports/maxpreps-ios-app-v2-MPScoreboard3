//
//  VideosTabFooterCollectionReusableView.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/16/21.
//

import UIKit

class VideosTabFooterCollectionReusableView: UICollectionReusableView
{
    @IBOutlet weak var getMoreButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        getMoreButton.layer.cornerRadius = 8
        getMoreButton.clipsToBounds = true

    }
    
}
