//
//  NewProfileMyTeamsCollectionViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/13/23.
//

import UIKit

class NewProfileMyTeamsCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var athleteNameLabel: UILabel!
    
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
    
    // MARK: - Load Data
    
    func loadData(data: Dictionary<String,Any>)
    {
        let year = data["year"] as? String ?? ""
        let level = data["level"] as? String ?? ""
        titleLabel.text = year + " " + level
        
        let schoolFullName = data["schoolFormattedName"] as? String ?? "Unknown"
        subtitleLabel.text = schoolFullName
        
        let firstName = data["firstName"] as? String ?? ""
        let lastName = data["lastName"] as? String ?? ""
        athleteNameLabel.text = firstName + " " + lastName
        
        statsLabel1.text = "- -" // Grade
        statsLabel2.text = "- -" // Jersey
        statsLabel3.text = "- -" // Height
        statsLabel4.text = "- -" // Weight
        statsLabel5.text = "- -" // Position
        statsLabel6.text = "- -" // Captain
        
        /*
        let grade = data["grade"] as? String ?? ""
        if (grade.count > 0)
        {
            statsLabel1.text = grade
        }
        */
        let classYear = data["classYear"] as? Int ?? -1
        if (classYear != -1)
        {
            statsLabel1.text = MiscHelper.shortGradeFromClassYear(year: classYear)
        }
        
        let jersey = data["jersey"] as? String ?? ""
        if (jersey.count > 0)
        {
            statsLabel2.text = jersey
        }
        
        let heightFeet = data["heightFeet"] as? Int ?? -1
        let heightInches = data["heightInches"] as? Int ?? -1
        if (heightFeet != -1) && (heightInches != -1)
        {
            statsLabel3.text = String(heightFeet) + "\'" + String(heightInches) + "\""
        }
        
        let weight = data["weight"] as? Int ?? -1
        if (weight != -1)
        {
            statsLabel4.text = String(weight)
        }
        
        let pos1 = data["position1"] as? String ?? ""
        let pos2 = data["position2"] as? String ?? ""
        let pos3 = data["position3"] as? String ?? ""
        
        var positionArray = [] as Array<String>
        
        if (pos1.count > 0)
        {
            positionArray.append(pos1)
        }
        
        if (pos2.count > 0)
        {
            positionArray.append(pos2)
        }
        
        if (pos3.count > 0)
        {
            positionArray.append(pos3)
        }
        
        switch positionArray.count
        {
        case 1:
            statsLabel5.text = positionArray.first
        case 2:
            statsLabel5.text = String(format: "%@, %@", positionArray[0], positionArray[1])
        case 3:
            statsLabel5.text = String(format: "%@, %@, %@", positionArray[0], positionArray[1], positionArray[2])
        default:
            statsLabel5.text = "- -"
        }
        
        let isCaptain = data["isCaptain"] as? Bool ?? false
        if (isCaptain != false)
        {
            statsLabel6.text = "\u{2713}"
        }
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // Add a shadow to the cell
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        containerView.clipsToBounds = true

    }

}
