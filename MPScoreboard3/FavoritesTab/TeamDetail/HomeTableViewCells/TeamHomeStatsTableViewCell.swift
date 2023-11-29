//
//  TeamHomeStatsTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/2/22.
//

import UIKit

class TeamHomeStatsTableViewCell: UITableViewCell
{
    @IBOutlet weak var horizLine: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var athleteImageView: UIImageView!
    @IBOutlet weak var athleteNameLabel: UILabel!
    @IBOutlet weak var athletePositionLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var shortCategoryLabel: UILabel!

    // MARK: - Load Data
    
    func loadData(_ data: Dictionary<String,Any>)
    {
        /*
         ▿ 6 elements
           ▿ 0 : 2 elements
             - key : "fullStatLeadersUrl"
             - value : https://www.maxpreps.com/high-schools/de-la-salle-spartans-(concord,ca)/football-21/stats.htm
           ▿ 1 : 2 elements
             - key : "athletes"
             ▿ value : 1 element
               ▿ 0 : 20 elements
                 ▿ 0 : 2 elements
                   - key : schoolState
                   - value : CA
                 ▿ 1 : 2 elements
                   - key : sportSeasonId
                   - value : 97e3f828-856d-419e-b94f-7f41319fe3d3
                 ▿ 2 : 2 elements
                   - key : athleteFirstName
                   - value : Charles
                 ▿ 3 : 2 elements
                   - key : athleteGrade
                   - value : Junior
                 ▿ 4 : 2 elements
                   - key : schoolMascotUrl
                   - value : https://dw3jhbqsbya58.cloudfront.net/fit-in/1024x1024/school-mascot/c/5/1/c510b298-3a73-4bcf-8855-96c998d8e26e.gif?version=634129029600000000
                 ▿ 5 : 2 elements
                   - key : schoolColor1
                   - value : 00824B
                 ▿ 6 : 2 elements
                   - key : schoolName
                   - value : De La Salle
                 ▿ 7 : 2 elements
                   - key : schoolCity
                   - value : Concord
                 ▿ 8 : 2 elements
                   - key : athletePosition2
                   - value : DB
                 ▿ 9 : 2 elements
                   - key : rowNumber
                   - value : 1
                 ▿ 10 : 2 elements
                   - key : athleteLastName
                   - value : Greer
                 ▿ 11 : 2 elements
                   - key : schoolFormattedName
                   - value : De La Salle (Concord, CA)
                 ▿ 12 : 2 elements
                   - key : careerId
                   - value : 32074160-c702-ea11-80ce-a444a33a3a97
                 ▿ 13 : 2 elements
                   - key : schoolNameAcronym
                   - value : DLSHS
                 ▿ 14 : 2 elements
                   - key : teamId
                   - value : c510b298-3a73-4bcf-8855-96c998d8e26e
                 ▿ 15 : 2 elements
                   - key : stats
                   ▿ value : 1 element
                     ▿ 0 : 5 elements
                       ▿ 0 : 2 elements
                         - key : value
                         - value : 103.4
                       ▿ 1 : 2 elements
                         - key : displayName
                         - value : Rushing Yards Per Game
                       ▿ 2 : 2 elements
                         - key : name
                         - value : RushingYardsPerGame
                       ▿ 3 : 2 elements
                         - key : header
                         - value : Y/G
                       ▿ 4 : 2 elements
                         - key : field
                         - value : s60
                 ▿ 16 : 2 elements
                   - key : athleteId
                   - value : 3a3a029c-b7bb-482a-8188-86db71ec52cc
                 ▿ 17 : 2 elements
                   - key : athletePhotoUrl
                   - value :
                 ▿ 18 : 2 elements
                   - key : athletePosition3
                   - value :
                 ▿ 19 : 2 elements
                   - key : athletePosition1
                   - value : RB
           ▿ 2 : 2 elements
             - key : "subGroup"
             - value :
           ▿ 3 : 2 elements
             - key : "statName"
             - value : RushingYardsPerGame
           ▿ 4 : 2 elements
             - key : "group"
             - value :
           ▿ 5 : 2 elements
             - key : "statDisplayName"
             - value : Rushing Yards Per Game
         */
        
        let athletes = data["athletes"] as! Array<Dictionary<String,Any>>
        
        // Temporary
        if (athletes.count == 0)
        {
            athleteNameLabel.text = "Unknown Athlete"
            athletePositionLabel.text = ""
            titleLabel.text = "Unkown Category"
            shortCategoryLabel.text = ""
            pointsLabel.text = ""
            return
        }
        let athlete = athletes[0]
        let firstName = athlete["athleteFirstName"] as? String ?? ""
        let lastName = athlete["athleteLastName"] as? String ?? ""
        athleteNameLabel.text = String(format: "%@ %@", firstName, lastName)
        
        var positions = [] as! Array<String>
        let position1 = athlete["athletePosition1"] as! String
        let position2 = athlete["athletePosition2"] as! String
        let position3 = athlete["athletePosition3"] as! String
        let athleteGrade = athlete["athleteGrade"] as! String
            
        if (position1.count > 0)
        {
            positions.append(position1)
        }
        
        if (position2.count > 0)
        {
            positions.append(position2)
        }
        
        if (position3.count > 0)
        {
            positions.append(position3)
        }
        
        if (positions.count == 0)
        {
            athletePositionLabel.text = athleteGrade
        }
        else if (positions.count == 1)
        {
            athletePositionLabel.text = String(format: "%@ • %@", athleteGrade, positions[0])
        }
        else if (positions.count == 2)
        {
            athletePositionLabel.text = String(format: "%@ • %@, %@", athleteGrade, positions[0], positions[1])
        }
        else
        {
            athletePositionLabel.text = String(format: "%@ • %@, %@, %@", athleteGrade, positions[0], positions[1], positions[2])
        }
        
        let stats = athlete["stats"] as! Array<Dictionary<String,Any>>
        let stat = stats[0]
        let displayName = stat["displayName"] as! String
        titleLabel.text = displayName.uppercased()
        
        let header = stat["header"] as! String
        shortCategoryLabel.text = header
        
        let value = stat["value"] as! String
        pointsLabel.text = value
        
        // Load the photo if it is available
        let photoUrlString = athlete["athletePhotoUrl"] as? String ?? ""
        
        if (photoUrlString.count > 0)
        {
            // Get the data and make an image
            let url = URL(string: photoUrlString)
            
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        self.athleteImageView.image = image
                    }
                    else
                    {
                        self.athleteImageView.image = UIImage(named: "Avatar")
                    }
                }
            }
        }
        else
        {
            self.athleteImageView.image = UIImage(named: "Avatar")
        }
        
        
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        athleteImageView.layer.cornerRadius = athleteImageView.frame.size.width / 2.0
        athleteImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
