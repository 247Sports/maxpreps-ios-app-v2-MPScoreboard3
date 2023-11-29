//
//  NewsVideoCollectionViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 11/29/21.
//

import UIKit

class NewsVideoCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var playIconBackgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    // MARK: - Load Data
    
    func loadData(data: Dictionary<String,Any>)
    {
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
          
        thumbnailImageView.image = nil
        
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
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // Add a shadow to the cell
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        playIconBackgroundView.layer.cornerRadius = playIconBackgroundView.frame.self.width / 2
        playIconBackgroundView.clipsToBounds = true

    }

}
