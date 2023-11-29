//
//  NewProfileSocialTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/9/23.
//

import UIKit

class NewProfileSocialTableViewCell: UITableViewCell
{
    @IBOutlet weak var signoutButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var youTubeButton: UIButton!
    @IBOutlet weak var tikTokButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
