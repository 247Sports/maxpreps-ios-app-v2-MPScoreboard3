//
//  VideoContributionsListTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 1/6/23.
//

import UIKit

class VideoContributionsListTableViewCell: UITableViewCell
{
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var durationBackgroundView: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var obscuringView: UIView!
    
    // MARK: - Cell Highlight/Restore
    
    func highlightCell()
    {
        obscuringView.isHidden = false
        moreButton.setImage(UIImage(named: "EllipsisSelected"), for: .normal)
    }
    
    func restoreCell()
    {
        obscuringView.isHidden = true
        moreButton.setImage(UIImage(named: "Ellipsis"), for: .normal)
    }
    
    // MARK: - Load Cell
    
    func loadData(_ data: Dictionary<String,Any>)
    {
        let time = data["durationString"] as! String
        let title = data["title"] as! String
        let publishDate = data["formattedPublishedOn"] as! String
        let viewCount = data["viewCount"] as? Int ?? 0
        let thumbnailUrl = data["thumbnailUrl"] as? String ?? ""
        
        titleLabel.text = title
        durationLabel.text = time
        dateLabel.text = publishDate
        
        if (viewCount >= 1000000)
        {
            let viewCountFloat = Float(viewCount) / 1000000.0
            viewCountLabel.text = String(format: "%1.1fm views", viewCountFloat)
        }
        else
        {
            if (viewCount >= 1000)
            {
                let viewCountFloat = Float(viewCount) / 1000.0
                viewCountLabel.text = String(format: "%1.1fk views", viewCountFloat)
            }
            else
            {
                viewCountLabel.text = String(format: "%d views", viewCount)
            }
        }
          
        if (thumbnailUrl.count > 0)
        {
            // Get the data and make an image
            let url = URL(string: thumbnailUrl)
            
            SDWebImageManager.shared().downloadImage(with: url!, progress: { receivedSize, expectedSize in
                
            }, completed: { image, error, cacheType, finished, imageUrl in
                
                if (image != nil)
                {
                    self.thumbnailImageView.image = image!
                }
                else
                {
                    self.thumbnailImageView.image = UIImage(named: "EmptyVideoScores")
                }
            })
        }
        else
        {
            thumbnailImageView.image = UIImage(named: "EmptyVideoScores")
        }
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        thumbnailImageView.layer.cornerRadius = 8
        thumbnailImageView.clipsToBounds = true
        
        durationBackgroundView.layer.cornerRadius = 4
        durationBackgroundView.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
