//
//  AnalystAwardTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/15/21.
//

import UIKit

class AnalystAwardTableViewCell: UITableViewCell
{
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var innerTitleLabel: UILabel!
    @IBOutlet weak var innerSubtitleLabel: UILabel!
    @IBOutlet weak var viewStoryButton: UIButton!
    @IBOutlet weak var awardsButton: UIButton!
    
    // MARK: - Load Data
    
    func loadData(awardsData: Dictionary<String,Any>, selectedAthlete: Athlete)
    {
        print("Data")

        let title = awardsData["title"] as! String
        titleLabel.text = title
        
        let timeText = awardsData["timeStampString"] as! String
        dateLabel.text = timeText
        
        let dataObj = awardsData["data"] as! Dictionary<String, Any>
        
        let innerTitle = dataObj["athleteName"] as! String
        innerTitleLabel.text = innerTitle
        
        let innerSubtitle = dataObj["comments"] as! String
        innerSubtitleLabel.text = innerSubtitle
        
        let firstName = selectedAthlete.firstName
        var possesiveName = ""
        if (firstName.last == "s")
        {
            possesiveName = firstName + "'"
        }
        else
        {
            possesiveName = firstName + "'s"
        }
        
        let awardsButtonTitle =  possesiveName + " Awards"
        awardsButton.setTitle(awardsButtonTitle, for: .normal)
        
        // Resize the awardsButton to fit the text
        let textWidth = awardsButtonTitle.widthOfString(usingFont: (awardsButton.titleLabel?.font)!)
        awardsButton.frame = CGRect(x: awardsButton.frame.origin.x, y: awardsButton.frame.origin.y, width: CGFloat(textWidth + 10), height: awardsButton.frame.size.height)
        
        let urlString = dataObj["imageUrl"] as! String
        
        self.iconImageView.image = nil
        
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
                        self.iconImageView.image = image
                    }
                    else
                    {
                        self.iconImageView.image = UIImage(named: "XmanLogo")
                    }
                }
            }
        }
        else
        {
            self.iconImageView.image = UIImage(named: "XmanLogo")
        }
        
        /*
         Printing description of awardsData:
         ▿ 8 elements
           ▿ 0 : 2 elements
             - key : "timeStamp"
             - value : 2021-01-29T10:30:00
           ▿ 1 : 2 elements
             - key : "type"
             - value : 8
           ▿ 2 : 2 elements
             - key : "title"
             - value : Analyst Award
           ▿ 3 : 2 elements
             - key : "data"
             ▿ value : 5 elements
               ▿ 0 : 2 elements
                 - key : storyLinkUrl
                 - value : https://www.maxpreps.com/news/VUf5H0lFl0WQtyV77mCLyg/2020-maxpreps-high-school-football-all-america-team.htm
               ▿ 1 : 2 elements
                 - key : imageUrl
                 - value : https://images.maxpreps.com/analyst/category/7fc19b20-5d62-eb11-80ce-a444a33a3a97.png?version=637613551051537221
               ▿ 2 : 2 elements
                 - key : athleteName
                 - value : Jaxson Dart
               ▿ 3 : 2 elements
                 - key : comments
                 - value : Congratulations to Jaxson Dart of Corner Canyon High School for being selected to the 2020 MaxPreps All-American Team - First Team Offense.
               ▿ 4 : 2 elements
                 - key : storyLinkText
                 - value : View Story
           ▿ 4 : 2 elements
             - key : "shareLink"
             - value : https://www.maxpreps.com/news/VUf5H0lFl0WQtyV77mCLyg/2020-maxpreps-high-school-football-all-america-team.htm
           ▿ 5 : 2 elements
             - key : "text"
             - value :
           ▿ 6 : 2 elements
             - key : "links"
             - value : 0 elements
           ▿ 7 : 2 elements
             - key : "timeStampString"
             - value : Friday, Jan 29, 2021
         */
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        innerContainerView.layer.cornerRadius = 12
        innerContainerView.clipsToBounds = true
        
        iconContainerView.layer.cornerRadius = self.iconContainerView.frame.size.width / 2.0
        iconContainerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        iconContainerView.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        iconContainerView.layer.shadowOpacity = 1.0
        iconContainerView.layer.shadowRadius = 4.0
        iconContainerView.clipsToBounds = false
        
        viewStoryButton.layer.cornerRadius = 8
        viewStoryButton.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
