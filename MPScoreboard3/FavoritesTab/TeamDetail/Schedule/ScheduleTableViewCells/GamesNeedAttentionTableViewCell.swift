//
//  GamesNeedAttentionTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 9/21/21.
//

import UIKit

class GamesNeedAttentionTableViewCell: UITableViewCell
{
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var homeAwayLabel: UILabel!
    @IBOutlet weak var mascotImageView: UIImageView!
    @IBOutlet weak var initialLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    // MARK: - Load Data
    
    func loadData(_ data: Dictionary<String,Any>)
    {
        let dateCode = data["dateCode"] as! Int
        /*
         Default = 0,
         DateTBA = 1,
         TimeTBA = 2,
         DateTimeTBA = 4
         */
        
        switch dateCode
        {
        case 0,2:
            var contestDateString = data["date"] as! String
            contestDateString = contestDateString.replacingOccurrences(of: "Z", with: "")
            
            let dateFormatter = DateFormatter()
            dateFormatter.isLenient = true
            dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
            let contestDate = dateFormatter.date(from: contestDateString)
            if (contestDate != nil)
            {
                dateFormatter.dateFormat = "EEE M/d"
                dateLabel.text = dateFormatter.string(from: contestDate!)
            }
            else
            {
                dateLabel.text = ""
            }

        default:
            dateLabel.text = "TBA Date"
        }
        
        /*
        // 1900-01-01T12:15:00 = TBA date
        // 1901-01-01T00:00:00 = TBA date-time
        if (contestDateString == "1900-01-01T12:15:00")
        {
            dateLabel.text = "TBA Date"
        }
        else if (contestDateString == "1901-01-01T00:00:00")
        {
            dateLabel.text = "TBA Date"
        }
        else
        {
            let dateFormatter = DateFormatter()
            dateFormatter.isLenient = true
            dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
            let contestDate = dateFormatter.date(from: contestDateString)
            
            dateFormatter.dateFormat = "EEE M/d"
            dateLabel.text = dateFormatter.string(from: contestDate!)
        }
        */
        let homeAwayType = data["opponentHomeAwayType"] as! Int
        
        switch homeAwayType
        {
        case 0:
            homeAwayLabel.text = "@"
        case 1:
            homeAwayLabel.text = "vs."
        default:
            homeAwayLabel.text = "vs."
        }
        
        if (data["opponentName"] is NSNull)
        {
            schoolNameLabel.text = "TBA"
            initialLabel.text = "T"
            initialLabel.textColor = UIColor.mpRedColor()
        }
        else
        {
            let schoolName = data["opponentName"] as! String
            schoolNameLabel.text = schoolName
            initialLabel.text = schoolName.first?.uppercased()
            
            let colorString = data["opponentColor1"] as? String
            let color = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
            initialLabel.textColor = color
            
            let mascotUrl = data["opponentMascotUrl"] as! String
            
            if (mascotUrl.count > 0)
            {
                // Get the data and make an image
                let url = URL(string: mascotUrl)
                
                MiscHelper.getData(from: url!) { data, response, error in
                    guard let data = data, error == nil else { return }

                    DispatchQueue.main.async()
                    {
                        let image = UIImage(data: data)
                        
                        if (image != nil)
                        {
                            self.initialLabel.isHidden = true
                            
                            // Render the mascot using this helper
                            MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.mascotImageView)!)
                        }
                    }
                }
            }
        }
        
        // Load the descriptionLabel
        let description = data["calloutText"] as! String
        descriptionLabel.text = description
        
        /*
         ▿ 0 : 12 elements
                   ▿ 0 : 2 elements
                     - key : opponentFormattedNameWithoutState
                     - value : MaxPreps B (Max)
                   ▿ 1 : 2 elements
                     - key : opponentMascotUrl
                     - value :
                   ▿ 2 : 2 elements
                     - key : calloutLink
                     - value : https://dev.maxpreps.com/high-schools/maxpreps-preppies-(max,ca)/basketball-winter-20-21/manage-contest.htm?admin=1&contestid=eb07f020-13bf-470e-8abd-b45b84e014da&apptype=teams
                   ▿ 3 : 2 elements
                     - key : opponentFormattedName
                     - value : MaxPreps B (Max, CA)
                   ▿ 4 : 2 elements
                     - key : calloutText
                     - value : Add System.Collections.Generic.List`1[System.String], 0, 0 & Date
                   ▿ 5 : 2 elements
                     - key : date
                     - value : 1900-01-01T12:00:00
                   ▿ 6 : 2 elements
                     - key : opponentHomeAwayType
                     - value : 1
                   ▿ 7 : 2 elements
                     - key : opponentName
                     - value : MaxPreps B
                   ▿ 8 : 2 elements
                     - key : opponentCanonicalUrl
                     - value : https://dev.maxpreps.com/high-schools/maxpreps-b-mascot-(max,ca)/basketball-winter-20-21/schedule.htm
                   ▿ 9 : 2 elements
                     - key : opponentCity
                     - value : Max
                   ▿ 10 : 2 elements
                     - key : opponentState
                     - value : CA
                   ▿ 11 : 2 elements
                     - key : contestId
                     - value : eb07f020-13bf-470e-8abd-b45b84e014da
         */
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
