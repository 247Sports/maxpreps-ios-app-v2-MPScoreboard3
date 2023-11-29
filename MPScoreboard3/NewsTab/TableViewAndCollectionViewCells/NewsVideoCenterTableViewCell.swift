//
//  NewsVideoCenterTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 12/2/21.
//

import UIKit

class NewsVideoCenterTableViewCell: UITableViewCell
{
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var videoFadeBackgroundImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var nowPlayingLabel: UILabel!
    @IBOutlet weak var nowPlayingBackgroundView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var horizLine: UIView!
    
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
        let publishDateString = data["publishedOn"] as! String
        let thumbnailUrl = data["thumbnailUrl"] as? String ?? ""
        
        titleLabel.text = title
        timeLabel.text = time
        
        let dateFormatter = DateFormatter()
        dateFormatter.isLenient = true
        dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
        let publishDate = dateFormatter.date(from: publishDateString)
        
        if (publishDate != nil)
        {
            dateFormatter.dateFormat = "MMM d, yyyy"
            let subtitle = dateFormatter.string(from: publishDate!)
            subtitleLabel.text = subtitle
        }
        else
        {
            subtitleLabel.text = ""
        }
          
        //thumbnailImageView.image = UIImage(named: "TestVideo")
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
            /*
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        self.thumbnailImageView.image = image
                    }
                    else
                    {
                        self.thumbnailImageView.image = UIImage(named: "EmptyVideoScores")
                    }
                }
            }
            */
        }
        else
        {
            thumbnailImageView.image = UIImage(named: "EmptyVideoScores")
        }
        
        if (isHighlighted == true)
        {
            nowPlayingBackgroundView.isHidden = false
            nowPlayingLabel.isHidden = false
            videoFadeBackgroundImageView.isHidden = true
            timeLabel.isHidden = true
        }
        else
        {
            nowPlayingBackgroundView.isHidden = true
            nowPlayingLabel.isHidden = true
            videoFadeBackgroundImageView.isHidden = false
            timeLabel.isHidden = false
        }
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        thumbnailImageView.layer.cornerRadius = 8
        thumbnailImageView.clipsToBounds = true
        
        nowPlayingBackgroundView.layer.cornerRadius = 8
        nowPlayingBackgroundView.layer.borderWidth = 3
        nowPlayingBackgroundView.layer.borderColor = nowPlayingColor.cgColor
        nowPlayingBackgroundView.clipsToBounds = true
        
        nowPlayingLabel.textColor = nowPlayingColor
        
        videoFadeBackgroundImageView.layer.cornerRadius = 8
        videoFadeBackgroundImageView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        videoFadeBackgroundImageView.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
