//
//  PlayerOfTheYearTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/9/21.
//

import UIKit

class PlayerOfTheYearTableViewCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var awardsButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var renderedImageView: UIImageView!
    
    // MARK: - Load Data
    
    func loadData(awardsData: Dictionary<String,Any>, selectedAthlete: Athlete)
    {
        containerView.isHidden = true
        
        let title = awardsData["title"] as! String
        titleLabel.text = title
        
        let subtitle = awardsData["text"] as! String
        subtitleLabel.text = subtitle
        
        let timeText = awardsData["timeStampString"] as! String
        dateLabel.text = timeText
        
        let links = awardsData["links"] as! Array<Dictionary<String,String>>
        let link0 = links.first
        let awardsButtonTitle = link0!["text"]
        awardsButton.setTitle(awardsButtonTitle, for: .normal)
        
        // Resize the awardsButton to fit the text
        let textWidth = awardsButtonTitle?.widthOfString(usingFont: (awardsButton.titleLabel?.font)!)
        awardsButton.frame = CGRect(x: awardsButton.frame.origin.x, y: awardsButton.frame.origin.y, width: CGFloat(textWidth! + 10), height: awardsButton.frame.size.height)
        
        //let urlString = "https://d1yf833igi2o06.cloudfront.net/pot/1/1/1/11111111-1111-1111-1111-0002ee22a3f3.png?version=63685dd"
        
        let dataObj = awardsData["data"] as! Dictionary<String, Any>
        let data = dataObj["playerOfTheYear"] as! Dictionary<String,Any>
        let urlString = data["badgeUrl"] as! String
        
        if (urlString.count > 0)
        {
            let url = URL(string: urlString)
            
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    //let image = UIImage(data: data)
                    let screenScale = UIScreen.main.scale
                    let scaledImage = UIImage(data: data, scale: screenScale)
                    
                    if (scaledImage != nil)
                    {
                        self.renderedImageView.image = scaledImage
                    }
                    else
                    {
                        self.containerView.isHidden = false
                    }
                }
            }
        }
        else
        {
            containerView.isHidden = false
        }
        
        /*
         ▿ 8 elements
           ▿ 0 : 2 elements
             - key : "timeStamp"
             - value : 2018-11-14T13:00:00
           ▿ 1 : 2 elements
             - key : "data"
             ▿ value : 16 elements
               ▿ 0 : 2 elements
                 - key : sponsorId
                 - value : 00000000-0000-0000-0000-000000000000
               ▿ 1 : 2 elements
                 - key : athleteId
                 - value : 44b6ef74-8506-4713-a9c4-d65ca4c096ce
               ▿ 2 : 2 elements
                 - key : playerOfTheYearId
                 - value : 0f1aa83a-50e8-e811-80c4-a9242bd1c80e
               ▿ 3 : 2 elements
                 - key : comments
                 - value :
               ▿ 4 : 2 elements
                 - key : createdOn
                 - value : 2018-11-14T13:00:00
               ▿ 5 : 2 elements
                 - key : athletePhotoUrl
                 - value :
               ▿ 6 : 2 elements
                 - key : schoolId
                 - value : b1350e52-edfe-4180-aa66-b60135a68acc
               ▿ 7 : 2 elements
                 - key : teamId
                 - value : b1350e52-edfe-4180-aa66-b60135a68acc
               ▿ 8 : 2 elements
                 - key : isSponsorOptedIn
                 - value : 0
               ▿ 9 : 2 elements
                 - key : type
                 - value : Offensive
               ▿ 10 : 2 elements
                 - key : badgeUrl
                 - value : https://images-development.maxpreps.com/pot/0/f/1/0f1aa83a-50e8-e811-80c4-a9242bd1c80e.png
               ▿ 11 : 2 elements
                 - key : careerProfileId
                 - value : 00000000-0000-0000-0000-000000000000
               ▿ 12 : 2 elements
                 - key : athleteFirstName
                 - value :
               ▿ 13 : 2 elements
                 - key : ssid
                 - value : c3d47049-daf2-47e3-8a8e-1e4552d8a797
               ▿ 14 : 2 elements
                 - key : sportSeasonId
                 - value : c3d47049-daf2-47e3-8a8e-1e4552d8a797
               ▿ 15 : 2 elements
                 - key : athleteLastName
                 - value :
           ▿ 2 : 2 elements
             - key : "type"
             - value : 7
           ▿ 3 : 2 elements
             - key : "links"
             ▿ value : 1 element
               ▿ 0 : 2 elements
                 ▿ 0 : 2 elements
                   - key : url
                   - value : https://dev.maxpreps.com/athlete/jaxson-dart/GFer9FUbEeeT-Oz0u-e-FA/awards.htm
                 ▿ 1 : 2 elements
                   - key : text
                   - value : Jaxson's Awards
           ▿ 4 : 2 elements
             - key : "text"
             - value : Jaxson Dart has been named player of the year.
           ▿ 5 : 2 elements
             - key : "title"
             - value : Player of the Year
           ▿ 6 : 2 elements
             - key : "timeStampString"
             - value : Wednesday, Nov 14, 2018
           ▿ 7 : 2 elements
             - key : "shareLink"
             - value : https://dev.maxpreps.com/athlete/jaxson-dart/GFer9FUbEeeT-Oz0u-e-FA/awards.htm

         */
        
        /*
        // Build a gradient layer with the school color
    
        // Top color is: A17D01
        let topColor = UIColor(red: 161.0/255.0, green: 125.0/255.0, blue: 1.0/255.0, alpha: 1)
        let bottomColor = UIColor(red: 161.0/255.0, green: 125.0/255.0, blue: 1.0/255.0, alpha: 0.5)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: kDeviceWidth - 40, height: topBackgroundView.frame.size.height)
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        topBackgroundView.layer.insertSublayer(gradientLayer, at: 0)
        
        let sport = "Softball"
        sportLabel.text = "MAXPREPS " + sport.uppercased()
        
        let image = MiscHelper.getImageForSport(sport)
        sportIconImageView.image = image
        
        // Shift the sport label and sport icon so the are centered
        let textWidth = sportLabel.text?.widthOfString(usingFont: sportLabel.font)
        let textLabelPlusIconWidth = sportIconImageView.frame.size.width + 10 + textWidth!
        let cellWidth = kDeviceWidth - 40
        let startX = (cellWidth - textLabelPlusIconWidth) / 2
        
        sportIconImageView.frame = CGRect(x: startX, y: sportIconImageView.frame.origin.y, width: sportIconImageView.frame.size.width, height: sportIconImageView.frame.size.height)
        
        sportLabel.frame = CGRect(x: sportIconImageView.frame.origin.x + sportIconImageView.frame.size.width + 10, y: sportLabel.frame.origin.y, width: textWidth! + 5, height: sportLabel.frame.size.height)
        */
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
                
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        
        renderedImageView.layer.cornerRadius = 12
        renderedImageView.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
