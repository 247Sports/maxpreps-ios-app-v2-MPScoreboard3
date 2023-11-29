//
//  CareerStatsTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/30/23.
//

import UIKit

class CareerStatsTableViewCell: UITableViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sportImageView: UIImageView!
    @IBOutlet weak var sportLabel: UILabel!
    @IBOutlet weak var statsButton: UIButton!
    @IBOutlet weak var statsTitleLabel1: UILabel!
    @IBOutlet weak var statsLabel1: UILabel!
    @IBOutlet weak var statsTitleLabel2: UILabel!
    @IBOutlet weak var statsLabel2: UILabel!
    @IBOutlet weak var statsTitleLabel3: UILabel!
    @IBOutlet weak var statsLabel3: UILabel!
    @IBOutlet weak var statsTitleLabel4: UILabel!
    @IBOutlet weak var statsLabel4: UILabel!
    @IBOutlet weak var statsTitleLabel5: UILabel!
    @IBOutlet weak var statsLabel5: UILabel!
    @IBOutlet weak var statsTitleLabel6: UILabel!
    @IBOutlet weak var statsLabel6: UILabel!
    @IBOutlet weak var statsTitleLabel7: UILabel!
    @IBOutlet weak var statsLabel7: UILabel!
    
    // MARK: - Load Data
    
    func loadData(careerStatsData: Dictionary<String,Any>)
    {
        let sport = careerStatsData["sport"] as! String
        let position = careerStatsData["position"] as! String
        sportImageView.image = MiscHelper.getImageForSport(sport)
        
        if (position.count > 0)
        {
            // Make the sport bold and black
            let sportPositionString = String(format: "%@ (%@)", sport, position.uppercased())
            let attributedString = NSMutableAttributedString(string: sportPositionString)
            
            let range = sportPositionString.range(of: sport)
            let convertedRange = NSRange(range!, in: sportPositionString)
            
            attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpBoldFontWith(size: 14), NSAttributedString.Key.foregroundColor: UIColor.mpBlackColor()], range: convertedRange)
            
            sportLabel.attributedText = attributedString
        }
        else
        {
            sportLabel.text = sport
        }
        
        statsTitleLabel1.text = "- -"
        statsLabel1.text = "- -"
        statsTitleLabel2.text = "- -"
        statsLabel2.text = "- -"
        statsTitleLabel3.text = "- -"
        statsLabel3.text = "- -"
        statsTitleLabel4.text = "- -"
        statsLabel4.text = "- -"
        statsTitleLabel5.text = "- -"
        statsLabel5.text = "- -"
        statsTitleLabel6.text = "- -"
        statsLabel6.text = "- -"
        statsTitleLabel7.text = "- -"
        statsLabel7.text = "- -"
        
        let statsArray = careerStatsData["stats"] as! Array<Dictionary<String,Any>>
        
        if (statsArray.count > 0)
        {
            let dataDict = statsArray[0]
            let title = dataDict["header"] as! String
            let value = dataDict["value"] as! String
            
            if (title.count > 0)
            {
                statsTitleLabel1.text = title.uppercased()
            }
            
            if (value.count > 0)
            {
                statsLabel1.text = value
            }
        }
        
        if (statsArray.count > 1)
        {
            let dataDict = statsArray[1]
            let title = dataDict["header"] as! String
            let value = dataDict["value"] as! String
            
            if (title.count > 0)
            {
                statsTitleLabel2.text = title.uppercased()
            }
            
            if (value.count > 0)
            {
                statsLabel2.text = value
            }
        }
        
        if (statsArray.count > 2)
        {
            let dataDict = statsArray[2]
            let title = dataDict["header"] as! String
            let value = dataDict["value"] as! String
            
            if (title.count > 0)
            {
                statsTitleLabel3.text = title.uppercased()
            }
            
            if (value.count > 0)
            {
                statsLabel3.text = value
            }
        }
        
        if (statsArray.count > 3)
        {
            let dataDict = statsArray[3]
            let title = dataDict["header"] as! String
            let value = dataDict["value"] as! String
            
            if (title.count > 0)
            {
                statsTitleLabel4.text = title.uppercased()
            }
            
            if (value.count > 0)
            {
                statsLabel4.text = value
            }
        }
        
        if (statsArray.count > 4)
        {
            let dataDict = statsArray[4]
            let title = dataDict["header"] as! String
            let value = dataDict["value"] as! String
            
            if (title.count > 0)
            {
                statsTitleLabel5.text = title.uppercased()
            }
            
            if (value.count > 0)
            {
                statsLabel5.text = value
            }
        }
        
        if (statsArray.count > 5)
        {
            let dataDict = statsArray[5]
            let title = dataDict["header"] as! String
            let value = dataDict["value"] as! String
            
            if (title.count > 0)
            {
                statsTitleLabel6.text = title.uppercased()
            }
            
            if (value.count > 0)
            {
                statsLabel6.text = value
            }
        }
        
        if (statsArray.count > 6)
        {
            let dataDict = statsArray[6]
            let title = dataDict["header"] as! String
            let value = dataDict["value"] as! String
            
            if (title.count > 0)
            {
                statsTitleLabel7.text = title.uppercased()
            }
            
            if (value.count > 0)
            {
                statsLabel7.text = value
            }
        }
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
