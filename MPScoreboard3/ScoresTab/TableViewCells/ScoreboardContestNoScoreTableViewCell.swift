//
//  ScoreboardContestNoScoreTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 9/7/21.
//

import UIKit

class ScoreboardContestNoScoreTableViewCell: UITableViewCell
{
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var teamANameLabel: UILabel!
    @IBOutlet weak var teamBNameLabel: UILabel!
    @IBOutlet weak var teamAInitialLabel: UILabel!
    @IBOutlet weak var teamBInitialLabel: UILabel!
    @IBOutlet weak var teamAImageView: UIImageView!
    @IBOutlet weak var teamBImageView: UIImageView!
    @IBOutlet weak var teamARecordLabel: UILabel!
    @IBOutlet weak var teamBRecordLabel: UILabel!
    @IBOutlet weak var reportScoreButton: UIButton!
    
    // MARK: - Load Data
    
    func loadData(_ data: Dictionary<String,Any>)
    {
        //print("load")
        let teams = data["teams"] as! Array<Dictionary<String,Any>>
        var teamA = teams[0]
        var teamB = teams[1]
        let haType = teamA["homeAwayType"] as! Int
        
        if (haType == 0) // Home is teamB
        {
            teamA = teams[1]
            teamB = teams[0]
        }
                
        var teamAName = teamA["name"] as? String ?? "TBA"
        var teamBName = teamB["name"] as? String ?? "TBA"
        
        if (teamAName.count == 0) // Empty string can occur
        {
            teamAName = "TBA"
        }
        
        if (teamBName.count == 0)
        {
            teamBName = "TBA"
        }
        
        teamANameLabel.text = teamAName
        teamBNameLabel.text = teamBName
        
        let teamAMascotUrl = teamA["mascotUrl"] as? String ?? ""
        let teamBMascotUrl = teamB["mascotUrl"] as? String ?? ""
        let teamAInitial = teamAName.first?.uppercased()
        let teamBInitial = teamBName.first?.uppercased()
        let teamAColorString = teamA["color1"] as? String ?? kMissingSchoolColor
        let teamBColorString = teamB["color1"] as? String ?? kMissingSchoolColor
        
        teamAInitialLabel.text = teamAInitial
        teamBInitialLabel.text = teamBInitial
        teamAInitialLabel.textColor = ColorHelper.color(fromHexString: teamAColorString, colorCorrection: true)
        teamBInitialLabel.textColor = ColorHelper.color(fromHexString: teamBColorString, colorCorrection: true)
        teamAInitialLabel.isHidden = true
        teamBInitialLabel.isHidden = true
        
        if (teamAMascotUrl.count > 0)
        {
            // Get the data and make an image
            let url = URL(string: teamAMascotUrl)
            
            /*
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        // Render the mascot using this helper
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.teamAImageView)!)
                    }
                    else
                    {
                        self.teamAInitialLabel.isHidden = false
                    }
                }
            }
            */
            SDWebImageManager.shared().downloadImage(with: url!, progress: { receivedSize, expectedSize in
                
            }, completed: { image, error, cacheType, finished, imageUrl in
                
                if (image != nil)
                {
                    // Render the mascot using this helper
                    MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.teamAImageView)!)
                }
                else
                {
                    self.teamAInitialLabel.isHidden = false
                }
            })
        }
        else
        {
            self.teamAInitialLabel.isHidden = false
        }
        
        if (teamBMascotUrl.count > 0)
        {
            // Get the data and make an image
            let url = URL(string: teamBMascotUrl)
            /*
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        // Render the mascot using this helper
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.teamBImageView)!)
                    }
                    else
                    {
                        self.teamBInitialLabel.isHidden = false
                    }
                }
            }
            */
            SDWebImageManager.shared().downloadImage(with: url!, progress: { receivedSize, expectedSize in
                
            }, completed: { image, error, cacheType, finished, imageUrl in
                
                if (image != nil)
                {
                    // Render the mascot using this helper
                    MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.teamBImageView)!)
                }
                else
                {
                    self.teamBInitialLabel.isHidden = false
                }
            })
        }
        else
        {
            teamBInitialLabel.isHidden = true
        }
        
        // Load and shift the team record labels
        let teamARecord = teamA["standings"] as! String
        let teamBRecord = teamB["standings"] as! String
        
        teamARecordLabel.text = teamARecord
        teamBRecordLabel.text = teamBRecord
        
        let teamANameLength = teamAName.widthOfString(usingFont: teamANameLabel.font)
        let teamBNameLength = teamBName.widthOfString(usingFont: teamBNameLabel.font)
        let teamANameLabelMaxWidth = kDeviceWidth - teamANameLabel.frame.origin.x - 175
        let teamBNameLabelMaxWidth = kDeviceWidth - teamBNameLabel.frame.origin.x - 175
        
        if (teamANameLength < teamANameLabelMaxWidth)
        {
            teamARecordLabel.frame = CGRect(x: teamANameLabel.frame.origin.x + CGFloat(teamANameLength) + CGFloat(8), y: teamARecordLabel.frame.origin.y, width: teamARecordLabel.frame.size.width, height: teamARecordLabel.frame.size.height)
        }
        else
        {
            teamARecordLabel.frame = CGRect(x: teamANameLabel.frame.origin.x + CGFloat(teamANameLabelMaxWidth) + CGFloat(8), y: teamARecordLabel.frame.origin.y, width: teamARecordLabel.frame.size.width, height: teamARecordLabel.frame.size.height)
        }
        
        if (teamBNameLength < teamBNameLabelMaxWidth)
        {
            teamBRecordLabel.frame = CGRect(x: teamBNameLabel.frame.origin.x + CGFloat(teamBNameLength) + CGFloat(8), y: teamBRecordLabel.frame.origin.y, width: teamBRecordLabel.frame.size.width, height: teamBRecordLabel.frame.size.height)
        }
        else
        {
            teamBRecordLabel.frame = CGRect(x: teamBNameLabel.frame.origin.x + CGFloat(teamBNameLabelMaxWidth) + CGFloat(8), y: teamBRecordLabel.frame.origin.y, width: teamBRecordLabel.frame.size.width, height: teamBRecordLabel.frame.size.height)
        }
        
        //dateLabel.text = "FINAL"
        let dateCode = data["dateCode"] as? Int ?? 0
        if (dateCode == 0)
        {
            var contestDateString = data["date"] as! String
            contestDateString = contestDateString.replacingOccurrences(of: "Z", with: "")
            let dateFormatter = DateFormatter()
            dateFormatter.isLenient = true
            dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
            let contestDate = dateFormatter.date(from: contestDateString)
            if (contestDate != nil)
            {
                dateFormatter.dateFormat = "h:mm a"
                let formattedDateString = dateFormatter.string(from: contestDate!)
                dateLabel.text = formattedDateString
            }
            else
            {
                dateLabel.text = ""
            }
        }
        else
        {
            dateLabel.text = "TBA"
        }
        
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        reportScoreButton.layer.cornerRadius = 8
        reportScoreButton.layer.borderWidth = 1
        reportScoreButton.layer.borderColor = UIColor.mpNegativeRedColor().cgColor
        reportScoreButton.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
