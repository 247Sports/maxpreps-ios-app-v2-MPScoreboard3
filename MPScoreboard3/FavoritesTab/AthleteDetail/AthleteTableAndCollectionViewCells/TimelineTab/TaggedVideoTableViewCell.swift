//
//  TaggedVideoTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/2/21.
//

import UIKit

class TaggedVideoTableViewCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var innerGradientView: UIView!
    @IBOutlet weak var innerCaptionLabel: UILabel!
    @IBOutlet weak var innerTimeLabel: UILabel!
    @IBOutlet weak var innerImageView: UIImageView!
    @IBOutlet weak var playIcon: UIImageView!
    @IBOutlet weak var viewMoreButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    // MARK: - Load Data
    
    func loadData(itemData: Dictionary<String,Any>)
    {
        playIcon.isHidden = false
        
        let title = itemData["title"] as! String
        titleLabel.text = title
        
        let subtitle = itemData["text"] as! String
        subtitleLabel.text = subtitle
        
        let timeText = itemData["timeStampString"] as! String
        dateLabel.text = timeText
        
        let links = itemData["links"] as! Array<Dictionary<String,String>>
        let link = links.first
        let moreButtonTitle = link!["text"]
        viewMoreButton.setTitle(moreButtonTitle, for: .normal)
        
        let data = itemData["data"] as! Dictionary<String,Any>
        let durationString = data["durationString"] as? String ?? ""
        innerTimeLabel.text = durationString
        
        let description = data["description"] as? String ?? ""
        innerCaptionLabel.text = description
        
        let urlString = data["thumbnailUrl"] as? String ?? ""
        
        if (urlString.count > 0)
        {
            let url = URL(string: urlString)
            
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        self.innerImageView.image = image
                    }
                    else
                    {
                        self.innerImageView.image = UIImage(named: "EmptyVideo")
                        self.playIcon.isHidden = true
                    }
                }
            }
        }
        else
        {
            self.innerImageView.image = UIImage(named: "EmptyVideo")
            self.playIcon.isHidden = true
        }
        
        
        /*
         ▿ 8 elements
           ▿ 0 : 2 elements
             - key : "timeStampString"
             - value : Tuesday, Nov 5, 2019
           ▿ 1 : 2 elements
             - key : "text"
             - value : Jaxson Dart has been tagged in the video "Jaxson Dart's highlights Northridge High School".
           ▿ 2 : 2 elements
             - key : "timeStamp"
             - value : 2019-11-05T03:50:00
           ▿ 3 : 2 elements
             - key : "type"
             - value : 3
           ▿ 4 : 2 elements
             - key : "title"
             - value : Video
           ▿ 5 : 2 elements
             - key : "shareLink"
             - value : https://dev.maxpreps.com/athlete/jaxson-dart/GFer9FUbEeeT-Oz0u-e-FA/videos.htm?videoid=b5d462a6-4fdb-4db3-bfb5-f8ff7771f44b
           ▿ 6 : 2 elements
             - key : "links"
             ▿ value : 1 element
               ▿ 0 : 2 elements
                 ▿ 0 : 2 elements
                   - key : url
                   - value : https://dev.maxpreps.com/athlete/jaxson-dart/GFer9FUbEeeT-Oz0u-e-FA/videos.htm
                 ▿ 1 : 2 elements
                   - key : text
                   - value : View More Videos
           ▿ 7 : 2 elements
             - key : "data"
             ▿ value : 15 elements
               ▿ 0 : 2 elements
                 - key : durationString
                 - value : 2:19
               ▿ 1 : 2 elements
                 - key : description
                 - value : Watch this highlight video of Jaxson Dart of the Roy (UT) football team in its game Northridge High School on Oct 25, 2019
               ▿ 2 : 2 elements
                 - key : videoId
                 - value : b5d462a6-4fdb-4db3-bfb5-f8ff7771f44b
               ▿ 3 : 2 elements
                 - key : videoType
                 - value : HUDL_Game_Athlete
               ▿ 4 : 2 elements
                 - key : externalVideoURL
                 - value : https://va.hudl.com/p-highlights/User/9482774/5dc0f15e2347950fc065683b/2d7ef516_720.mp4?v=BB6667FE3062D708
               ▿ 5 : 2 elements
                 - key : thumbnailUrl
                 - value : https://vf.hudl.com/usp/sof/7fb1e50b-0c14-4451-ab3e-7365ce8da979/t12665/x8pgpgho8c7ag96m_3000_Full.jpg?v=359EE13AA361D708
               ▿ 6 : 2 elements
                 - key : title
                 - value : Jaxson Dart's highlights Northridge High School
               ▿ 7 : 2 elements
                 - key : canonicalUrl
                 - value : https://dev.maxpreps.com/athlete/jaxson-dart/GFer9FUbEeeT-Oz0u-e-FA/videos.htm?videoid=b5d462a6-4fdb-4db3-bfb5-f8ff7771f44b
               ▿ 8 : 2 elements
                 - key : thumbnailHeight
                 - value : 7
               ▿ 9 : 2 elements
                 - key : viewCount
                 - value : 7
               ▿ 10 : 2 elements
                 - key : externalPartnerVideoId
                 - value : 3abb5dca-da75-404f-abc0-fab83ba7a882
               ▿ 11 : 2 elements
                 - key : publishedOn
                 - value : 2019-11-05T03:50:00
               ▿ 12 : 2 elements
                 - key : thumbnailWidth
                 - value : 1920
               ▿ 13 : 2 elements
                 - key : duration
                 - value : 139000
               ▿ 14 : 2 elements
                 - key : externalPartner
                 - value : HUDL

         */
    }

    // MARK: - Set Cell Height
    
    func setCellHeight()
    {
        // Update the inner containerView's size to keep the aspect at 16:9
        let newInnerContainerHeight = (kDeviceWidth - 40) * (9/16)
        let cellHeightDifference = newInnerContainerHeight - innerContainerView.frame.size.height
        
        innerContainerView.frame = CGRect(x: innerContainerView.frame.origin.x, y: innerContainerView.frame.origin.y, width: (kDeviceWidth - 40), height: newInnerContainerHeight)
        
        // Update the cell's contentView size
        contentView.frame = CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: contentView.frame.size.height + cellHeightDifference)
        
        // Shift the play button too
        playIcon.center = CGPoint(x: playIcon.center.x, y: playIcon.center.y + (cellHeightDifference / 2))
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        innerContainerView.layer.cornerRadius = 12
        innerContainerView.clipsToBounds = true
        
        innerImageView.layer.cornerRadius = 12
        innerImageView.clipsToBounds = true
        
        innerTimeLabel.layer.cornerRadius = 4
        innerTimeLabel.clipsToBounds = true
        
        let topColor = UIColor(white: 0, alpha: 0)
        let bottomColor = UIColor(white: 0, alpha: 0.75)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: kDeviceWidth - 40, height: innerGradientView.frame.size.height)
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        innerGradientView.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
