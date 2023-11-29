//
//  RosterAthleteTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 7/30/21.
//

import UIKit

class RosterAthleteTableViewCell: UITableViewCell
{
    @IBOutlet weak var athleteImageView: UIImageView!
    @IBOutlet weak var jerseyLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var chevronImageView: UIImageView!
    @IBOutlet weak var captainLabel: UILabel!
    
    // MARK: - Load Data
    
    func loadData(athlete: RosterAthlete)
    {
        titleLabel.text = athlete.firstName + " " + athlete.lastName
        
        if (athlete.isCaptain == true)
        {
            captainLabel.isHidden = false
            
            // Shift the captain label to the right of the name
            let textWidth = titleLabel.text?.widthOfString(usingFont: titleLabel.font)
            captainLabel.center = CGPoint(x: Int(titleLabel.frame.origin.x) + Int(textWidth!) + 14, y: Int(captainLabel.center.y))
        }
        else
        {
            captainLabel.isHidden = true
        }
        
        if (athlete.jersey.count > 0)
        {
            jerseyLabel.text = athlete.jersey
        }
        else
        {
            jerseyLabel.text = "--"
        }
        
        // Load the postions
        var positionsArray = [] as Array<String>
        
        if (athlete.position1.count > 0)
        {
            positionsArray.append(athlete.position1)
        }
        
        if (athlete.position2.count > 0)
        {
            positionsArray.append(athlete.position2)
        }
        
        if (athlete.position3.count > 0)
        {
            positionsArray.append(athlete.position3)
        }
        
        var positionsText = ""
        
        if (positionsArray.count == 1)
        {
            positionsText = positionsArray[0]
        }
        else if (positionsArray.count == 2)
        {
            positionsText = positionsArray[0] + ", " + positionsArray[1]
        }
        else if (positionsArray.count == 3)
        {
            positionsText = positionsArray[0] + ", " + positionsArray[1] + ", " + positionsArray[2]
        }
        
        // Add the grade
        var grade = ""
        
        if (athlete.classYear == "5")
        {
            grade = "5th"
        }
        else if (athlete.classYear == "6")
        {
            grade = "6th"
        }
        else if (athlete.classYear == "7")
        {
            grade = "7th"
        }
        else if (athlete.classYear == "8")
        {
            grade = "8th"
        }
        else if (athlete.classYear == "9")
        {
            grade = "Fr"
        }
        else if (athlete.classYear == "10")
        {
            grade = "So"
        }
        else if (athlete.classYear == "11")
        {
            grade = "Jr"
        }
        else if (athlete.classYear == "12")
        {
            grade = "Sr"
        }
        
        // Height
        var height = ""

        if ((athlete.heightFeet.count > 0) && (athlete.heightInches.count > 0))
        {
            height = athlete.heightFeet + "'" + athlete.heightInches + "\""
        }
        
        // Weight
        var weight = ""

        if (athlete.weight.count > 0)
        {
            weight = athlete.weight + " lbs."
        }
        
        // Now glue the fields together
        var compositeText = ""
        
        if (positionsText.count == 0)
        {
            if ((height.count > 0) || (weight.count > 0))
            {
                compositeText = grade + " • "
            }
            else
            {
                compositeText = grade
            }
        }
        else
        {
            if ((height.count > 0) || (weight.count > 0))
            {
                compositeText = positionsText + " • " + grade + " • "
            }
            else
            {
                compositeText = positionsText + " • " + grade
            }
        }

        
        if (height.count > 0) && (weight.count == 0)
        {
            compositeText = compositeText + height
        }
        else if (height.count == 0) && (weight.count > 0)
        {
            compositeText = compositeText + weight
        }
        else if (height.count > 0) && (weight.count > 0)
        {
            compositeText = compositeText + height + " • " + weight
        }
        
        subtitleLabel.text = compositeText
        
        // Load the photo
        if (athlete.photoUrl.count > 0)
        {
            let url = URL(string: athlete.photoUrl)
            
            // Get the data and make an image
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        self.athleteImageView.image = image
                    }
                }
            }
        }
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        athleteImageView.layer.cornerRadius = athleteImageView.frame.size.width / 2
        athleteImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

    }
    
}
