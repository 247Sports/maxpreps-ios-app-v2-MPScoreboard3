//
//  FilterPlayerStatsTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 1/21/22.
//

import UIKit

class FilterPlayerStatsTableViewCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleBackgroundView: UIView!
    @IBOutlet weak var fullPlayerStatLeadersButton: UIButton!
    
    @IBOutlet weak var innerContainerView1: UIView!
    @IBOutlet weak var innerAthletePhotoImageView1: UIImageView!
    @IBOutlet weak var innerTitleLabel1: UILabel!
    @IBOutlet weak var innerSubtitleLabel1: UILabel!
    @IBOutlet weak var innerPositionLabel1: UILabel!
    @IBOutlet weak var innerPointsLabel1: UILabel!
    @IBOutlet weak var innerShortCategoryLabel1: UILabel!
    @IBOutlet weak var innerButton1: UIButton!
    
    @IBOutlet weak var innerContainerView2: UIView!
    @IBOutlet weak var innerTitleLabel2: UILabel!
    @IBOutlet weak var innerSubtitleLabel2: UILabel!
    @IBOutlet weak var innerPositionLabel2: UILabel!
    @IBOutlet weak var innerPointsLabel2: UILabel!
    @IBOutlet weak var innerShortCategoryLabel2: UILabel!
    @IBOutlet weak var innerButton2: UIButton!
    
    @IBOutlet weak var innerContainerView3: UIView!
    @IBOutlet weak var innerTitleLabel3: UILabel!
    @IBOutlet weak var innerSubtitleLabel3: UILabel!
    @IBOutlet weak var innerPositionLabel3: UILabel!
    @IBOutlet weak var innerPointsLabel3: UILabel!
    @IBOutlet weak var innerShortCategoryLabel3: UILabel!
    @IBOutlet weak var innerButton3: UIButton!
    
    @IBOutlet weak var innerContainerView4: UIView!
    @IBOutlet weak var innerTitleLabel4: UILabel!
    @IBOutlet weak var innerSubtitleLabel4: UILabel!
    @IBOutlet weak var innerPositionLabel4: UILabel!
    @IBOutlet weak var innerPointsLabel4: UILabel!
    @IBOutlet weak var innerShortCategoryLabel4: UILabel!
    @IBOutlet weak var innerButton4: UIButton!
    
    @IBOutlet weak var innerContainerView5: UIView!
    @IBOutlet weak var innerTitleLabel5: UILabel!
    @IBOutlet weak var innerSubtitleLabel5: UILabel!
    @IBOutlet weak var innerPositionLabel5: UILabel!
    @IBOutlet weak var innerPointsLabel5: UILabel!
    @IBOutlet weak var innerShortCategoryLabel5: UILabel!
    @IBOutlet weak var innerButton5: UIButton!
    
    // MARK: - Load Data
    
    func loadData(_ data: Dictionary<String,Any>)
    {
        innerContainerView1.isHidden = true
        innerContainerView2.isHidden = true
        innerContainerView3.isHidden = true
        innerContainerView4.isHidden = true
        innerContainerView5.isHidden = true
        
        let title = data["statDisplayName"] as! String
        titleLabel.text = title.uppercased()

        let athletes = data["athletes"] as! Array<Dictionary<String,Any>>
        
        if (athletes.count > 0)
        {
            innerContainerView1.isHidden = false
            
            let athlete = athletes[0]
            let firstName = athlete["athleteFirstName"] as? String ?? ""
            let lastName = athlete["athleteLastName"] as? String ?? ""
            innerTitleLabel1.text = String(format: "%@ %@", firstName, lastName)
            
            let schoolName = athlete["schoolFormattedName"] as! String
            innerSubtitleLabel1.text = schoolName
            
            let stats = athlete["stats"] as! Array<Dictionary<String,Any>>
            let stat = stats[0]
            let header = stat["header"] as! String
            innerShortCategoryLabel1.text = header
            innerShortCategoryLabel2.text = header
            innerShortCategoryLabel3.text = header
            innerShortCategoryLabel4.text = header
            innerShortCategoryLabel5.text = header
            
            let value = stat["value"] as! String
            innerPointsLabel1.text = value
            
            var positions = [] as! Array<String>
            let position1 = athlete["athletePosition1"] as! String
            let position2 = athlete["athletePosition2"] as! String
            let position3 = athlete["athletePosition3"] as! String
            
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
                innerPositionLabel1.text = ""
            }
            else if (positions.count == 1)
            {
                innerPositionLabel1.text = positions[0]
            }
            else if (positions.count == 2)
            {
                innerPositionLabel1.text = String(format: "%@, %@", positions[0], positions[1])
            }
            else
            {
                innerPositionLabel1.text = String(format: "%@, %@, %@", positions[0], positions[1], positions[2])
            }
            
            // Calculate the size of the name and move the positions label to the right
            let positionsTextWidth = CGFloat((innerPositionLabel1.text?.widthOfString(usingFont: innerPositionLabel1.font))!)
            let nameWidth = CGFloat((innerTitleLabel1.text?.widthOfString(usingFont: innerTitleLabel1.font))!)
            
            let maxAvailableWidth = kDeviceWidth - innerTitleLabel1.frame.origin.x - innerPointsLabel1.frame.size.width - 16
            
            if (maxAvailableWidth >= positionsTextWidth + nameWidth + 16)
            {
                // Place the positions label to the right of the name
                innerTitleLabel1.frame = CGRect(x: innerTitleLabel1.frame.origin.x, y: innerTitleLabel1.frame.origin.y, width: nameWidth + 4, height: innerTitleLabel1.frame.size.height)
                
                innerPositionLabel1.frame = CGRect(x: innerTitleLabel1.frame.origin.x + innerTitleLabel1.frame.size.width, y: innerPositionLabel1.frame.origin.y, width: positionsTextWidth, height: innerPositionLabel1.frame.size.height)
            }
            else
            {
                // Shrink the width of the titleLabel by a shrink value
                let titleShrinkValue = positionsTextWidth + nameWidth + 16 - maxAvailableWidth
                
                innerTitleLabel1.frame = CGRect(x: innerTitleLabel1.frame.origin.x, y: innerTitleLabel1.frame.origin.y, width: nameWidth + 4 - titleShrinkValue, height: innerTitleLabel1.frame.size.height)
                
                innerPositionLabel1.frame = CGRect(x: innerTitleLabel1.frame.origin.x + innerTitleLabel1.frame.size.width, y: innerPositionLabel1.frame.origin.y, width: positionsTextWidth, height: innerPositionLabel1.frame.size.height)
            }
            
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
                            self.innerAthletePhotoImageView1.image = image
                        }
                        else
                        {
                            self.innerAthletePhotoImageView1.image = UIImage(named: "Avatar")
                        }
                    }
                }
            }
            else
            {
                self.innerAthletePhotoImageView1.image = UIImage(named: "Avatar")
            }
            
            if (athletes.count > 1)
            {
                innerContainerView2.isHidden = false
                
                let athlete = athletes[1]
                let firstName = athlete["athleteFirstName"] as? String ?? ""
                let lastName = athlete["athleteLastName"] as? String ?? ""
                innerTitleLabel2.text = String(format: "%@ %@", firstName, lastName)
                
                let schoolName = athlete["schoolFormattedName"] as! String
                innerSubtitleLabel2.text = schoolName
                
                let stats = athlete["stats"] as! Array<Dictionary<String,Any>>
                let stat = stats[0]
                
                let value = stat["value"] as! String
                innerPointsLabel2.text = value
                
                var positions = [] as! Array<String>
                let position1 = athlete["athletePosition1"] as! String
                let position2 = athlete["athletePosition2"] as! String
                let position3 = athlete["athletePosition3"] as! String
                
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
                    innerPositionLabel2.text = ""
                }
                else if (positions.count == 1)
                {
                    innerPositionLabel2.text = positions[0]
                }
                else if (positions.count == 2)
                {
                    innerPositionLabel2.text = String(format: "%@, %@", positions[0], positions[1])
                }
                else
                {
                    innerPositionLabel2.text = String(format: "%@, %@, %@", positions[0], positions[1], positions[2])
                }
                
                // Calculate the size of the name and move the positions label to the right
                let positionsTextWidth = CGFloat((innerPositionLabel2.text?.widthOfString(usingFont: innerPositionLabel2.font))!)
                let nameWidth = CGFloat((innerTitleLabel2.text?.widthOfString(usingFont: innerTitleLabel2.font))!)
                
                let maxAvailableWidth = kDeviceWidth - innerTitleLabel2.frame.origin.x - innerPointsLabel2.frame.size.width - 16
                
                if (maxAvailableWidth >= positionsTextWidth + nameWidth + 16)
                {
                    // Place the positions label to the right of the name
                    innerTitleLabel2.frame = CGRect(x: innerTitleLabel2.frame.origin.x, y: innerTitleLabel2.frame.origin.y, width: nameWidth + 4, height: innerTitleLabel2.frame.size.height)
                    
                    innerPositionLabel2.frame = CGRect(x: innerTitleLabel2.frame.origin.x + innerTitleLabel2.frame.size.width, y: innerPositionLabel2.frame.origin.y, width: positionsTextWidth, height: innerPositionLabel2.frame.size.height)
                }
                else
                {
                    // Shrink the width of the titleLabel by a shrink value
                    let titleShrinkValue = positionsTextWidth + nameWidth + 16 - maxAvailableWidth
                    
                    innerTitleLabel2.frame = CGRect(x: innerTitleLabel2.frame.origin.x, y: innerTitleLabel2.frame.origin.y, width: nameWidth + 4 - titleShrinkValue, height: innerTitleLabel2.frame.size.height)
                    
                    innerPositionLabel2.frame = CGRect(x: innerTitleLabel2.frame.origin.x + innerTitleLabel2.frame.size.width, y: innerPositionLabel2.frame.origin.y, width: positionsTextWidth, height: innerPositionLabel2.frame.size.height)
                }
                
                if (athletes.count > 2)
                {
                    innerContainerView3.isHidden = false
                    
                    let athlete = athletes[2]
                    let firstName = athlete["athleteFirstName"] as? String ?? ""
                    let lastName = athlete["athleteLastName"] as? String ?? ""
                    innerTitleLabel3.text = String(format: "%@ %@", firstName, lastName)
                    
                    let schoolName = athlete["schoolFormattedName"] as! String
                    innerSubtitleLabel3.text = schoolName
                    
                    let stats = athlete["stats"] as! Array<Dictionary<String,Any>>
                    let stat = stats[0]
                    
                    let value = stat["value"] as! String
                    innerPointsLabel3.text = value
                    
                    var positions = [] as! Array<String>
                    let position1 = athlete["athletePosition1"] as! String
                    let position2 = athlete["athletePosition2"] as! String
                    let position3 = athlete["athletePosition3"] as! String
                    
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
                        innerPositionLabel3.text = ""
                    }
                    else if (positions.count == 1)
                    {
                        innerPositionLabel3.text = positions[0]
                    }
                    else if (positions.count == 2)
                    {
                        innerPositionLabel3.text = String(format: "%@, %@", positions[0], positions[1])
                    }
                    else
                    {
                        innerPositionLabel3.text = String(format: "%@, %@, %@", positions[0], positions[1], positions[2])
                    }
                    
                    // Calculate the size of the name and move the positions label to the right
                    let positionsTextWidth = CGFloat((innerPositionLabel3.text?.widthOfString(usingFont: innerPositionLabel3.font))!)
                    let nameWidth = CGFloat((innerTitleLabel3.text?.widthOfString(usingFont: innerTitleLabel3.font))!)
                    
                    let maxAvailableWidth = kDeviceWidth - innerTitleLabel3.frame.origin.x - innerPointsLabel3.frame.size.width - 16
                    
                    if (maxAvailableWidth >= positionsTextWidth + nameWidth + 16)
                    {
                        // Place the positions label to the right of the name
                        innerTitleLabel3.frame = CGRect(x: innerTitleLabel3.frame.origin.x, y: innerTitleLabel3.frame.origin.y, width: nameWidth + 4, height: innerTitleLabel3.frame.size.height)
                        
                        innerPositionLabel3.frame = CGRect(x: innerTitleLabel3.frame.origin.x + innerTitleLabel3.frame.size.width, y: innerPositionLabel3.frame.origin.y, width: positionsTextWidth, height: innerPositionLabel3.frame.size.height)
                    }
                    else
                    {
                        // Shrink the width of the titleLabel by a shrink value
                        let titleShrinkValue = positionsTextWidth + nameWidth + 16 - maxAvailableWidth
                        
                        innerTitleLabel3.frame = CGRect(x: innerTitleLabel3.frame.origin.x, y: innerTitleLabel3.frame.origin.y, width: nameWidth + 4 - titleShrinkValue, height: innerTitleLabel3.frame.size.height)
                        
                        innerPositionLabel3.frame = CGRect(x: innerTitleLabel3.frame.origin.x + innerTitleLabel3.frame.size.width, y: innerPositionLabel3.frame.origin.y, width: positionsTextWidth, height: innerPositionLabel3.frame.size.height)
                    }
                    
                    if (athletes.count > 3)
                    {
                        innerContainerView4.isHidden = false
                        
                        let athlete = athletes[3]
                        let firstName = athlete["athleteFirstName"] as? String ?? ""
                        let lastName = athlete["athleteLastName"] as? String ?? ""
                        innerTitleLabel4.text = String(format: "%@ %@", firstName, lastName)
                        
                        let schoolName = athlete["schoolFormattedName"] as! String
                        innerSubtitleLabel4.text = schoolName
                        
                        let stats = athlete["stats"] as! Array<Dictionary<String,Any>>
                        let stat = stats[0]
                        
                        let value = stat["value"] as! String
                        innerPointsLabel4.text = value
                        
                        var positions = [] as! Array<String>
                        let position1 = athlete["athletePosition1"] as! String
                        let position2 = athlete["athletePosition2"] as! String
                        let position3 = athlete["athletePosition3"] as! String
                        
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
                            innerPositionLabel4.text = ""
                        }
                        else if (positions.count == 1)
                        {
                            innerPositionLabel4.text = positions[0]
                        }
                        else if (positions.count == 2)
                        {
                            innerPositionLabel4.text = String(format: "%@, %@", positions[0], positions[1])
                        }
                        else
                        {
                            innerPositionLabel4.text = String(format: "%@, %@, %@", positions[0], positions[1], positions[2])
                        }
                        
                        // Calculate the size of the name and move the positions label to the right
                        let positionsTextWidth = CGFloat((innerPositionLabel4.text?.widthOfString(usingFont: innerPositionLabel4.font))!)
                        let nameWidth = CGFloat((innerTitleLabel4.text?.widthOfString(usingFont: innerTitleLabel4.font))!)
                        
                        let maxAvailableWidth = kDeviceWidth - innerTitleLabel4.frame.origin.x - innerPointsLabel4.frame.size.width - 16
                        
                        if (maxAvailableWidth >= positionsTextWidth + nameWidth + 16)
                        {
                            // Place the positions label to the right of the name
                            innerTitleLabel4.frame = CGRect(x: innerTitleLabel4.frame.origin.x, y: innerTitleLabel4.frame.origin.y, width: nameWidth + 4, height: innerTitleLabel4.frame.size.height)
                            
                            innerPositionLabel4.frame = CGRect(x: innerTitleLabel4.frame.origin.x + innerTitleLabel4.frame.size.width, y: innerPositionLabel4.frame.origin.y, width: positionsTextWidth, height: innerPositionLabel4.frame.size.height)
                        }
                        else
                        {
                            // Shrink the width of the titleLabel by a shrink value
                            let titleShrinkValue = positionsTextWidth + nameWidth + 16 - maxAvailableWidth
                            
                            innerTitleLabel4.frame = CGRect(x: innerTitleLabel4.frame.origin.x, y: innerTitleLabel4.frame.origin.y, width: nameWidth + 4 - titleShrinkValue, height: innerTitleLabel4.frame.size.height)
                            
                            innerPositionLabel4.frame = CGRect(x: innerTitleLabel4.frame.origin.x + innerTitleLabel4.frame.size.width, y: innerPositionLabel4.frame.origin.y, width: positionsTextWidth, height: innerPositionLabel4.frame.size.height)
                        }
                        
                        if (athletes.count > 4)
                        {
                            innerContainerView5.isHidden = false
                            
                            let athlete = athletes[4]
                            let firstName = athlete["athleteFirstName"] as? String ?? ""
                            let lastName = athlete["athleteLastName"] as? String ?? ""
                            innerTitleLabel5.text = String(format: "%@ %@", firstName, lastName)
                            
                            let schoolName = athlete["schoolFormattedName"] as! String
                            innerSubtitleLabel5.text = schoolName
                            
                            let stats = athlete["stats"] as! Array<Dictionary<String,Any>>
                            let stat = stats[0]
                            
                            let value = stat["value"] as! String
                            innerPointsLabel5.text = value
                            
                            var positions = [] as! Array<String>
                            let position1 = athlete["athletePosition1"] as! String
                            let position2 = athlete["athletePosition2"] as! String
                            let position3 = athlete["athletePosition3"] as! String
                            
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
                                innerPositionLabel5.text = ""
                            }
                            else if (positions.count == 1)
                            {
                                innerPositionLabel5.text = positions[0]
                            }
                            else if (positions.count == 2)
                            {
                                innerPositionLabel5.text = String(format: "%@, %@", positions[0], positions[1])
                            }
                            else
                            {
                                innerPositionLabel5.text = String(format: "%@, %@, %@", positions[0], positions[1], positions[2])
                            }
                            
                            // Calculate the size of the name and move the positions label to the right
                            let positionsTextWidth = CGFloat((innerPositionLabel5.text?.widthOfString(usingFont: innerPositionLabel5.font))!)
                            let nameWidth = CGFloat((innerTitleLabel5.text?.widthOfString(usingFont: innerTitleLabel5.font))!)
                            
                            let maxAvailableWidth = kDeviceWidth - innerTitleLabel5.frame.origin.x - innerPointsLabel5.frame.size.width - 16
                            
                            if (maxAvailableWidth >= positionsTextWidth + nameWidth + 16)
                            {
                                // Place the positions label to the right of the name
                                innerTitleLabel5.frame = CGRect(x: innerTitleLabel5.frame.origin.x, y: innerTitleLabel5.frame.origin.y, width: nameWidth + 4, height: innerTitleLabel5.frame.size.height)
                                
                                innerPositionLabel5.frame = CGRect(x: innerTitleLabel5.frame.origin.x + innerTitleLabel5.frame.size.width, y: innerPositionLabel5.frame.origin.y, width: positionsTextWidth, height: innerPositionLabel5.frame.size.height)
                            }
                            else
                            {
                                // Shrink the width of the titleLabel by a shrink value
                                let titleShrinkValue = positionsTextWidth + nameWidth + 16 - maxAvailableWidth
                                
                                innerTitleLabel5.frame = CGRect(x: innerTitleLabel5.frame.origin.x, y: innerTitleLabel5.frame.origin.y, width: nameWidth + 4 - titleShrinkValue, height: innerTitleLabel5.frame.size.height)
                                
                                innerPositionLabel5.frame = CGRect(x: innerTitleLabel5.frame.origin.x + innerTitleLabel5.frame.size.width, y: innerPositionLabel5.frame.origin.y, width: positionsTextWidth, height: innerPositionLabel5.frame.size.height)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 12
        self.contentView.clipsToBounds = true
        
        self.innerAthletePhotoImageView1.layer.cornerRadius = self.innerAthletePhotoImageView1.frame.size.width / 2.0
        self.innerAthletePhotoImageView1.clipsToBounds = true
        
        titleBackgroundView.layer.cornerRadius = 8
        titleBackgroundView.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
