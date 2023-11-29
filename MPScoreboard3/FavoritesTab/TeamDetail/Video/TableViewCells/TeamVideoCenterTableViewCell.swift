//
//  TeamVideoCenterTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/31/22.
//

import UIKit

class TeamVideoCenterTableViewCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var videoThumbnailImageView: UIImageView!
    @IBOutlet weak var videoDurationBackground: UIView!
    @IBOutlet weak var videoDurationLabel: UILabel!
    @IBOutlet weak var nowPlayingLabel: UILabel!
    @IBOutlet weak var nowPlayingBackgroundView: UIView!
    
    let nowPlayingColor = UIColor.orange
    
    // MARK: - Load Now Playing Text
    
    func loadNowPlaying(_ text: String)
    {
        nowPlayingLabel.text = text
    }
    
    // MARK: - Load Data
    
    func loadData(data: Dictionary<String,Any>, isHighlighted: Bool)
    {
        nowPlayingLabel.text = "Now Playing"
        
        let time = data["durationString"] as! String
        let title = data["title"] as! String
        let publishDate = data["formattedPublishedOn"] as! String
        let viewCount = data["viewCount"] as? Int ?? 0
        let thumbnailUrl = data["thumbnailUrl"] as? String ?? ""
        
        titleLabel.text = title
        videoDurationLabel.text = time
        subtitleLabel.text = publishDate
        
        if (viewCount >= 1000000)
        {
            let viewCountFloat = Float(viewCount) / 1000000.0
            frequencyLabel.text = String(format: "%1.1fm views", viewCountFloat)
        }
        else
        {
            if (viewCount >= 1000)
            {
                let viewCountFloat = Float(viewCount) / 1000.0
                frequencyLabel.text = String(format: "%1.1fk views", viewCountFloat)
            }
            else
            {
                frequencyLabel.text = String(format: "%d views", viewCount)
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
                    self.videoThumbnailImageView.image = image!
                }
                else
                {
                    self.videoThumbnailImageView.image = UIImage(named: "EmptyVideoScores")
                }
            })
        }
        else
        {
            videoThumbnailImageView.image = UIImage(named: "EmptyVideoScores")
        }
        
        if (isHighlighted == true)
        {
            nowPlayingBackgroundView.isHidden = false
            nowPlayingLabel.isHidden = false
            videoDurationLabel.isHidden = true
            videoDurationBackground.isHidden = true
        }
        else
        {
            nowPlayingBackgroundView.isHidden = true
            nowPlayingLabel.isHidden = true
            videoDurationLabel.isHidden = false
            videoDurationBackground.isHidden = false
        }
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        videoThumbnailImageView.layer.cornerRadius = 8
        videoThumbnailImageView.clipsToBounds = true
        
        videoDurationBackground.layer.cornerRadius = 6
        videoDurationBackground.clipsToBounds = true
        
        nowPlayingBackgroundView.layer.cornerRadius = 8
        nowPlayingBackgroundView.layer.borderWidth = 3
        nowPlayingBackgroundView.layer.borderColor = nowPlayingColor.cgColor
        nowPlayingBackgroundView.clipsToBounds = true
        
        nowPlayingLabel.textColor = nowPlayingColor

    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
