//
//  NewsArticleTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 11/29/21.
//

import UIKit

class NewsArticleTableViewCell: UITableViewCell
{
    @IBOutlet weak var sportLabel: UILabel!
    @IBOutlet weak var sportIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var horizLine: UIView!
    @IBOutlet weak var articleImageView: UIImageView!
    
    // MARK: - Load Data
    
    func loadData(_ data: Dictionary<String,Any>)
    {
        let gender = data["gender"] as! String
        let sport = data["sport"] as! String
        let level = data["level"] as! String
        
        sportLabel.text = MiscHelper.genderSportLevelFrom(gender: gender, sport: sport, level: level)
        sportIconImageView.image = MiscHelper.getImageForSport(sport)
        
        let headline = data["listHeadline"] as! String
        titleLabel.text = headline
        
        let publishOnString = data["publishedOn"] as! String
        let dateFormatter = DateFormatter()
        dateFormatter.isLenient = true
        dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
        let publishOnDate = dateFormatter.date(from: publishOnString)
        
        var publishDateString = ""
        if (publishOnDate != nil)
        {
            dateFormatter.dateFormat = "MMM d, yyyy"
            publishDateString = dateFormatter.string(from: publishOnDate!)
        }
        
        let writerFirstName = data["writerFirstName"] as! String
        let writerLastName = data["writerLastName"] as! String
        
        if ((writerFirstName.count > 0) && (writerLastName.count > 0))
        {
            subtitleLabel.text = String(format: "%@ • %@ %@", publishDateString, writerFirstName, writerLastName)
        }
        else
        {
            subtitleLabel.text = publishDateString
        }
        
        articleImageView.image = nil
        
        let thumbnailUrl = data["thumbnailUrl"] as? String ?? ""
        
        if (thumbnailUrl.count > 0)
        {
            // Get the data and make an image
            let url = URL(string: thumbnailUrl)
            
            SDWebImageManager.shared().downloadImage(with: url!, progress: { receivedSize, expectedSize in
                
            }, completed: { image, error, cacheType, finished, imageUrl in
                
                if (image != nil)
                {
                    self.articleImageView.image = image!
                }
                else
                {
                    self.articleImageView.image = UIImage(named: "EmptyArticleImage")
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
                        self.articleImageView.image = image
                    }
                    else
                    {
                        self.articleImageView.image = UIImage(named: "EmptyArticleImage")
                    }
                }
            }
            */
        }
        else
        {
            articleImageView.image = UIImage(named: "EmptyArticleImage")
        }
        
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        titleLabel.text = ""
        subtitleLabel.text = ""
        sportLabel.text = ""
        sportIconImageView.image = nil

        articleImageView.layer.cornerRadius = 8
        articleImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
