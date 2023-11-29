//
//  PlayerOfTheGameCollectionViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/9/21.
//

import UIKit

class PlayerOfTheGameCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var positionsLabel: UILabel!
    @IBOutlet weak var renderedImageView: UIImageView!
    
    // MARK: - Load Data
    
    func loadData(awardsData: Dictionary<String,Any>, selectedAthlete: Athlete)
    {
        containerView.isHidden = true
        
        //let urlString = "https://d1yf833igi2o06.cloudfront.net/pot/1/1/1/11111111-1111-1111-1111-0002ee22a3f3.png?version=63685dd"
        let urlString = awardsData["badgeUrl"] as! String
        
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
        // Build a gradient layer with the school color
        let topColor = UIColor(red: 0, green: 51.0/255.0, blue: 0, alpha: 1)
        let bottomColor = UIColor(red: 0, green: 51.0/255.0, blue: 0, alpha: 0.5)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: kDeviceWidth - 40, height: topBackgroundView.frame.size.height)
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        topBackgroundView.layer.insertSublayer(gradientLayer, at: 0)
        
        let sport = "Softball"
        let pogType = "Special Teams"
        
        if (sport == "Football")
        {
            sportLabel.text = "MAXPREPS " + pogType.uppercased() + " " + sport.uppercased()
        }
        else
        {
            sportLabel.text = "MAXPREPS " + sport.uppercased()
        }
        
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

}
