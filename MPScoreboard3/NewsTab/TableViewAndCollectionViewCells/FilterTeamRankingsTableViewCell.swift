//
//  FilterTeamRankingsTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/1/22.
//

import UIKit

class FilterTeamRankingsTableViewCell: UITableViewCell
{
    @IBOutlet weak var rankingLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var schoolCityLabel: UILabel!
    @IBOutlet weak var schoolInitialLabel: UILabel!
    @IBOutlet weak var schoolMascotImageView: UIImageView!
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var strengthLabel: UILabel!
    @IBOutlet weak var movementLabel: UILabel!
    @IBOutlet weak var movementImageView: UIImageView!
    
    // MARK: - Load Data
    
    func loadData(_ data: Dictionary<String,Any>, gender: String, sport: String, context: String)
    {
        movementImageView.isHidden = false
        schoolInitialLabel.isHidden = false
        schoolMascotImageView.image = nil
        
        let rank = data["rank"] as! Int
        rankingLabel.text = String(rank)
        
        // Use the acronym if the name is too long (includes the auto-shrink)
        let schoolName = data["schoolName"] as! String
        let schoolNameWidth = schoolName.widthOfString(usingFont: schoolNameLabel.font)
        let maxWidth = schoolNameLabel.frame.size.width / schoolNameLabel.minimumScaleFactor
        
        if (schoolNameWidth > maxWidth)
        {
            let acronym = data["schoolNameAcronym"] as! String
            schoolNameLabel.text = acronym
        }
        else
        {
            schoolNameLabel.text = schoolName
        }
        
        let colorString = data["schoolColor1"] as! String
        let color = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
        schoolInitialLabel.textColor = color
        schoolInitialLabel.text = String(schoolName.prefix(1))
        
        //let location = data["schoolLocation"] as! String
        //schoolCityLabel.text = location
        let schoolCity = data["schoolCity"] as! String
        let schoolState = data["schoolState"] as! String
        schoolCityLabel.text = String(format: "%@, %@", schoolCity, schoolState)
        
        let mascotUrl = data["schoolMascotUrl"] as? String ?? ""
        
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
                        self.schoolInitialLabel.isHidden = true
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.schoolMascotImageView)!)
                    }
                }
            }
        }
        
        
        // Hide the strength column if not computer rankings
        if (context == "National")
        {
            if ((sport == "Football") || (sport == "Basketball") || (sport == "Baseball") || (sport == "Softball") || ((gender == "Girls") && (sport == "Volleyball")))
            {
                strengthLabel.text = ""
            }
            else
            {
                let strength = data["strength"] as? Double ?? 0
                strengthLabel.text = String(format: "%1.1f", strength)
            }
        }
        else
        {
            let strength = data["strength"] as? Double ?? 0
            strengthLabel.text = String(format: "%1.1f", strength)
        }
        
        let overallRecord = data["overallRecord"] as? String ?? "?"
        let overallRecordArray = overallRecord.components(separatedBy: "-")
        if (overallRecordArray.count == 3)
        {
            if (overallRecordArray[2] == "0")
            {
                recordLabel.text = String(format: "%@-%@", overallRecordArray[0], overallRecordArray[1])
            }
            else
            {
                recordLabel.text = overallRecord
            }
        }
        else
        {
            recordLabel.text = overallRecord
        }
        
        // Hide the movement except for national or state
        if ((context == "National") || (context == "State"))
        {
            let movement = data["movement"] as! String
            let movementValue = Int(movement) ?? 0
            
            if (movementValue == 0)
            {
                movementImageView.isHidden = true
                movementLabel.text = "--"
            }
            else if (movementValue < 0)
            {
                movementImageView.image = UIImage(named: "RankingDownArrow")
                movementLabel.text = String(abs(movementValue))
            }
            else
            {
                movementImageView.image = UIImage(named: "RankingUpArrow")
                movementLabel.text = String(movementValue)
            }
        }
        else
        {
            movementImageView.isHidden = true
            movementLabel.text = "--"
        }
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
