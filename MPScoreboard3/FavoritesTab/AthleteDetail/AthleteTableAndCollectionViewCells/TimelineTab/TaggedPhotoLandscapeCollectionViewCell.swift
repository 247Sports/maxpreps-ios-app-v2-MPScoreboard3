//
//  TaggedPhotoLandscapeCollectionViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/2/21.
//

import UIKit

class TaggedPhotoLandscapeCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        photoImageView.layer.cornerRadius = 12
        photoImageView.clipsToBounds = true
    }

}
