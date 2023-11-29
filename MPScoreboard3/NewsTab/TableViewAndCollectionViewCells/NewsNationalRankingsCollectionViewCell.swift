//
//  NewsNationalRankingsCollectionViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 12/14/21.
//

import UIKit

class NewsNationalRankingsCollectionViewCell: UICollectionViewCell
{
    // 66 properties, yikes
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fullRankingsButton: UIButton!
    @IBOutlet weak var strengthHeaderLabel: UILabel!
    
    @IBOutlet weak var innerContainerView1: UIView!
    @IBOutlet weak var rankingLabel1: UILabel!
    @IBOutlet weak var schoolNameLabel1: UILabel!
    @IBOutlet weak var schoolCityLabel1: UILabel!
    @IBOutlet weak var schoolInitialLabel1: UILabel!
    @IBOutlet weak var schoolMascotImageView1: UIImageView!
    @IBOutlet weak var schoolMascotContainerView1: UIView!
    @IBOutlet weak var recordLabel1: UILabel!
    @IBOutlet weak var strengthLabel1: UILabel!
    @IBOutlet weak var movementLabel1: UILabel!
    @IBOutlet weak var movementImageView1: UIImageView!
    @IBOutlet weak var containerButton1: UIButton!
    
    @IBOutlet weak var innerContainerView2: UIView!
    @IBOutlet weak var rankingLabel2: UILabel!
    @IBOutlet weak var schoolNameLabel2: UILabel!
    @IBOutlet weak var schoolCityLabel2: UILabel!
    @IBOutlet weak var schoolInitialLabel2: UILabel!
    @IBOutlet weak var schoolMascotImageView2: UIImageView!
    @IBOutlet weak var schoolMascotContainerView2: UIView!
    @IBOutlet weak var recordLabel2: UILabel!
    @IBOutlet weak var strengthLabel2: UILabel!
    @IBOutlet weak var movementLabel2: UILabel!
    @IBOutlet weak var movementImageView2: UIImageView!
    @IBOutlet weak var containerButton2: UIButton!
    
    @IBOutlet weak var innerContainerView3: UIView!
    @IBOutlet weak var rankingLabel3: UILabel!
    @IBOutlet weak var schoolNameLabel3: UILabel!
    @IBOutlet weak var schoolCityLabel3: UILabel!
    @IBOutlet weak var schoolInitialLabel3: UILabel!
    @IBOutlet weak var schoolMascotImageView3: UIImageView!
    @IBOutlet weak var schoolMascotContainerView3: UIView!
    @IBOutlet weak var recordLabel3: UILabel!
    @IBOutlet weak var strengthLabel3: UILabel!
    @IBOutlet weak var movementLabel3: UILabel!
    @IBOutlet weak var movementImageView3: UIImageView!
    @IBOutlet weak var containerButton3: UIButton!
    
    @IBOutlet weak var innerContainerView4: UIView!
    @IBOutlet weak var rankingLabel4: UILabel!
    @IBOutlet weak var schoolNameLabel4: UILabel!
    @IBOutlet weak var schoolCityLabel4: UILabel!
    @IBOutlet weak var schoolInitialLabel4: UILabel!
    @IBOutlet weak var schoolMascotImageView4: UIImageView!
    @IBOutlet weak var schoolMascotContainerView4: UIView!
    @IBOutlet weak var recordLabel4: UILabel!
    @IBOutlet weak var strengthLabel4: UILabel!
    @IBOutlet weak var movementLabel4: UILabel!
    @IBOutlet weak var movementImageView4: UIImageView!
    @IBOutlet weak var containerButton4: UIButton!
    
    @IBOutlet weak var innerContainerView5: UIView!
    @IBOutlet weak var rankingLabel5: UILabel!
    @IBOutlet weak var schoolNameLabel5: UILabel!
    @IBOutlet weak var schoolCityLabel5: UILabel!
    @IBOutlet weak var schoolInitialLabel5: UILabel!
    @IBOutlet weak var schoolMascotImageView5: UIImageView!
    @IBOutlet weak var schoolMascotContainerView5: UIView!
    @IBOutlet weak var recordLabel5: UILabel!
    @IBOutlet weak var strengthLabel5: UILabel!
    @IBOutlet weak var movementLabel5: UILabel!
    @IBOutlet weak var movementImageView5: UIImageView!
    @IBOutlet weak var containerButton5: UIButton!
    
    // MARK: - Load Data
    
    func loadData(_ data: Dictionary<String,Any>, nationalMode: Bool)
    {
        let sport = data["sport"] as! String
        let headerColor = MiscHelper.getColorForSport(sport)
        headerView.backgroundColor = headerColor
        
        let gender = data["gender"] as! String
        let genderSport = MiscHelper.genderSportFrom(gender: gender, sport: sport)
        titleLabel.text = genderSport
        
        var dateString = data["updatedOn"] as! String
        dateString = dateString.replacingOccurrences(of: "Z", with: "")
        
        let dateFormatter = DateFormatter()
        dateFormatter.isLenient = true
        dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let publishDate = dateFormatter.date(from: dateString)
        
        // Make sure the date was converted properly
        if (publishDate != nil)
        {
            dateFormatter.dateFormat = "M/d/yyyy"
            let publishDateString = dateFormatter.string(from: publishDate!)
            dateLabel.text = String(format: "Updated: %@", publishDateString)
        }
        else
        {
            dateLabel.text = "Updated: Unknown"
        }

        let rankingData = data["rankingData"] as! Array<Dictionary<String,Any>>
        
        innerContainerView1.isHidden = true
        innerContainerView2.isHidden = true
        innerContainerView3.isHidden = true
        innerContainerView4.isHidden = true
        innerContainerView5.isHidden = true
        
        movementImageView1.isHidden = false
        movementImageView2.isHidden = false
        movementImageView3.isHidden = false
        movementImageView4.isHidden = false
        movementImageView5.isHidden = false
        
        schoolMascotImageView1.image = nil
        schoolMascotImageView2.image = nil
        schoolMascotImageView3.image = nil
        schoolMascotImageView4.image = nil
        schoolMascotImageView5.image = nil
        
        // Hide the strength column if not computer rankings
        if (nationalMode == true)
        {
            if ((sport == "Football") || (sport == "Basketball") || (sport == "Baseball") || (sport == "Softball") || (genderSport == "Girls Volleyball"))
            {
                strengthHeaderLabel.isHidden = true
            }
            else
            {
                strengthHeaderLabel.isHidden = false
            }
        }
        else
        {
            strengthHeaderLabel.isHidden = false
        }
        
        if (rankingData.count > 0)
        {
            innerContainerView1.isHidden = false
            
            let ranking = rankingData[0]
            
            let schoolName = ranking["schoolName"] as! String
            let schoolNameAcronym = ranking["schoolNameAcronym"] as! String
            
            if (schoolName.count > 20)
            {
                schoolNameLabel1.text = schoolNameAcronym
            }
            else
            {
                schoolNameLabel1.text = schoolName
            }
            
            let schoolLocation = ranking["schoolLocation"] as! String
            schoolCityLabel1.text = schoolLocation
            
            let rank = ranking["rank"] as! Int
            rankingLabel1.text = String(rank)
            
            if (strengthHeaderLabel.isHidden == true)
            {
                strengthLabel1.text = ""
            }
            else
            {
                let strength = ranking["strength"] as? Double ?? 0
                strengthLabel1.text = String(format: "%1.1f", strength)
            }
            
            let overallRecord = ranking["overallRecord"] as? String ?? "?"
            let overallRecordArray = overallRecord.components(separatedBy: "-")
            if (overallRecordArray.count == 3)
            {
                if (overallRecordArray[2] == "0")
                {
                    recordLabel1.text = String(format: "%@-%@", overallRecordArray[0], overallRecordArray[1])
                }
                else
                {
                    recordLabel1.text = overallRecord
                }
            }
            else
            {
                recordLabel1.text = overallRecord
            }
            
            let movement = ranking["movement"] as! String
            let movementValue = Int(movement) ?? 0
            
            if (movementValue == 0)
            {
                movementImageView1.isHidden = true
                movementLabel1.text = "--"
            }
            else if (movementValue < 0)
            {
                movementImageView1.image = UIImage(named: "RankingDownArrow")
                movementLabel1.text = String(abs(movementValue))
            }
            else
            {
                movementImageView1.image = UIImage(named: "RankingUpArrow")
                movementLabel1.text = String(movementValue)
            }
            
            let colorString = ranking["schoolColor1"] as! String
            let color = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
            schoolInitialLabel1.textColor = color
            schoolInitialLabel1.text = String(schoolName.prefix(1))
            
            let mascotUrl = ranking["schoolMascotUrl"] as? String ?? ""
            
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
                            self.schoolInitialLabel1.isHidden = true
                            MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.schoolMascotImageView1)!)
                        }
                    }
                }
            }
            
            if (rankingData.count > 1)
            {
                innerContainerView2.isHidden = false
                
                let ranking = rankingData[1]
                
                let schoolName = ranking["schoolName"] as! String
                let schoolNameAcronym = ranking["schoolNameAcronym"] as! String
                
                if (schoolName.count > 20)
                {
                    schoolNameLabel2.text = schoolNameAcronym
                }
                else
                {
                    schoolNameLabel2.text = schoolName
                }
                
                let schoolLocation = ranking["schoolLocation"] as! String
                schoolCityLabel2.text = schoolLocation
                
                let rank = ranking["rank"] as! Int
                rankingLabel2.text = String(rank)
                
                if (strengthHeaderLabel.isHidden == true)
                {
                    strengthLabel2.text = ""
                }
                else
                {
                    let strength = ranking["strength"] as? Double ?? 0
                    strengthLabel2.text = String(format: "%1.1f", strength)
                }
                
                let overallRecord = ranking["overallRecord"] as? String ?? "?"
                let overallRecordArray = overallRecord.components(separatedBy: "-")
                if (overallRecordArray.count == 3)
                {
                    if (overallRecordArray[2] == "0")
                    {
                        recordLabel2.text = String(format: "%@-%@", overallRecordArray[0], overallRecordArray[1])
                    }
                    else
                    {
                        recordLabel2.text = overallRecord
                    }
                }
                else
                {
                    recordLabel2.text = overallRecord
                }
                
                let movement = ranking["movement"] as! String
                let movementValue = Int(movement) ?? 0
                
                if (movementValue == 0)
                {
                    movementImageView2.isHidden = true
                    movementLabel2.text = "--"
                }
                else if (movementValue < 0)
                {
                    movementImageView2.image = UIImage(named: "RankingDownArrow")
                    movementLabel2.text = String(abs(movementValue))
                }
                else
                {
                    movementImageView2.image = UIImage(named: "RankingUpArrow")
                    movementLabel2.text = String(movementValue)
                }
                
                let colorString = ranking["schoolColor1"] as! String
                let color = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
                schoolInitialLabel2.textColor = color
                schoolInitialLabel2.text = String(schoolName.prefix(1))
                
                let mascotUrl = ranking["schoolMascotUrl"] as? String ?? ""
                
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
                                self.schoolInitialLabel2.isHidden = true
                                MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.schoolMascotImageView2)!)
                            }
                        }
                    }
                }
                
                if (rankingData.count > 2)
                {
                    innerContainerView3.isHidden = false
                    
                    let ranking = rankingData[2]
                    
                    let schoolName = ranking["schoolName"] as! String
                    let schoolNameAcronym = ranking["schoolNameAcronym"] as! String
                    
                    if (schoolName.count > 20)
                    {
                        schoolNameLabel3.text = schoolNameAcronym
                    }
                    else
                    {
                        schoolNameLabel3.text = schoolName
                    }
                    
                    let schoolLocation = ranking["schoolLocation"] as! String
                    schoolCityLabel3.text = schoolLocation
                    
                    let rank = ranking["rank"] as! Int
                    rankingLabel3.text = String(rank)
                    
                    if (strengthHeaderLabel.isHidden == true)
                    {
                        strengthLabel3.text = ""
                    }
                    else
                    {
                        let strength = ranking["strength"] as? Double ?? 0
                        strengthLabel3.text = String(format: "%1.1f", strength)
                    }
                    
                    let overallRecord = ranking["overallRecord"] as? String ?? "?"
                    let overallRecordArray = overallRecord.components(separatedBy: "-")
                    if (overallRecordArray.count == 3)
                    {
                        if (overallRecordArray[2] == "0")
                        {
                            recordLabel3.text = String(format: "%@-%@", overallRecordArray[0], overallRecordArray[1])
                        }
                        else
                        {
                            recordLabel3.text = overallRecord
                        }
                    }
                    else
                    {
                        recordLabel3.text = overallRecord
                    }
                    
                    let movement = ranking["movement"] as! String
                    let movementValue = Int(movement) ?? 0
                    
                    if (movementValue == 0)
                    {
                        movementImageView3.isHidden = true
                        movementLabel3.text = "--"
                    }
                    else if (movementValue < 0)
                    {
                        movementImageView3.image = UIImage(named: "RankingDownArrow")
                        movementLabel3.text = String(abs(movementValue))
                    }
                    else
                    {
                        movementImageView3.image = UIImage(named: "RankingUpArrow")
                        movementLabel3.text = String(movementValue)
                    }
                    
                    let colorString = ranking["schoolColor1"] as! String
                    let color = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
                    schoolInitialLabel3.textColor = color
                    schoolInitialLabel3.text = String(schoolName.prefix(1))
                    
                    let mascotUrl = ranking["schoolMascotUrl"] as? String ?? ""
                    
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
                                    self.schoolInitialLabel3.isHidden = true
                                    MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.schoolMascotImageView3)!)
                                }
                            }
                        }
                    }
                    
                    if (rankingData.count > 3)
                    {
                        innerContainerView4.isHidden = false
                        
                        let ranking = rankingData[3]
                        
                        let schoolName = ranking["schoolName"] as! String
                        let schoolNameAcronym = ranking["schoolNameAcronym"] as! String
                        
                        if (schoolName.count > 20)
                        {
                            schoolNameLabel4.text = schoolNameAcronym
                        }
                        else
                        {
                            schoolNameLabel4.text = schoolName
                        }
                        
                        let schoolLocation = ranking["schoolLocation"] as! String
                        schoolCityLabel4.text = schoolLocation
                        
                        let rank = ranking["rank"] as! Int
                        rankingLabel4.text = String(rank)
                        
                        if (strengthHeaderLabel.isHidden == true)
                        {
                            strengthLabel4.text = ""
                        }
                        else
                        {
                            let strength = ranking["strength"] as? Double ?? 0
                            strengthLabel4.text = String(format: "%1.1f", strength)
                        }
                        
                        let overallRecord = ranking["overallRecord"] as? String ?? "?"
                        let overallRecordArray = overallRecord.components(separatedBy: "-")
                        if (overallRecordArray.count == 3)
                        {
                            if (overallRecordArray[2] == "0")
                            {
                                recordLabel4.text = String(format: "%@-%@", overallRecordArray[0], overallRecordArray[1])
                            }
                            else
                            {
                                recordLabel4.text = overallRecord
                            }
                        }
                        else
                        {
                            recordLabel4.text = overallRecord
                        }
                        
                        let movement = ranking["movement"] as! String
                        let movementValue = Int(movement) ?? 0
                        
                        if (movementValue == 0)
                        {
                            movementImageView4.isHidden = true
                            movementLabel4.text = "--"
                        }
                        else if (movementValue < 0)
                        {
                            movementImageView4.image = UIImage(named: "RankingDownArrow")
                            movementLabel4.text = String(abs(movementValue))
                        }
                        else
                        {
                            movementImageView4.image = UIImage(named: "RankingUpArrow")
                            movementLabel4.text = String(movementValue)
                        }
                        
                        let colorString = ranking["schoolColor1"] as! String
                        let color = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
                        schoolInitialLabel4.textColor = color
                        schoolInitialLabel4.text = String(schoolName.prefix(1))
                        
                        let mascotUrl = ranking["schoolMascotUrl"] as? String ?? ""
                        
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
                                        self.schoolInitialLabel4.isHidden = true
                                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.schoolMascotImageView4)!)
                                    }
                                }
                            }
                        }
                        
                        if (rankingData.count > 4)
                        {
                            innerContainerView5.isHidden = false
                            
                            let ranking = rankingData[4]
                            
                            let schoolName = ranking["schoolName"] as! String
                            let schoolNameAcronym = ranking["schoolNameAcronym"] as! String
                            
                            if (schoolName.count > 20)
                            {
                                schoolNameLabel5.text = schoolNameAcronym
                            }
                            else
                            {
                                schoolNameLabel5.text = schoolName
                            }
                            
                            let schoolLocation = ranking["schoolLocation"] as! String
                            schoolCityLabel5.text = schoolLocation
                            
                            if (nationalMode == true)
                            {
                                if ((sport == "Football") || (sport == "Basketball") || (sport == "Baseball") || (sport == "Softball") || (genderSport == "Girls Volleyball"))
                                {
                                    strengthLabel5.text = ""
                                }
                                else
                                {
                                    let strength = ranking["strength"] as? Double ?? 0
                                    strengthLabel5.text = String(format: "%1.1f", strength)
                                }
                            }
                            else
                            {
                                let strength = ranking["strength"] as? Double ?? 0
                                strengthLabel5.text = String(format: "%1.1f", strength)
                            }
                            
                            let overallRecord = ranking["overallRecord"] as? String ?? "?"
                            let overallRecordArray = overallRecord.components(separatedBy: "-")
                            if (overallRecordArray.count == 3)
                            {
                                if (overallRecordArray[2] == "0")
                                {
                                    recordLabel5.text = String(format: "%@-%@", overallRecordArray[0], overallRecordArray[1])
                                }
                                else
                                {
                                    recordLabel5.text = overallRecord
                                }
                            }
                            else
                            {
                                recordLabel5.text = overallRecord
                            }
                            
                            let movement = ranking["movement"] as! String
                            let movementValue = Int(movement) ?? 0
                            
                            if (movementValue == 0)
                            {
                                movementImageView5.isHidden = true
                                movementLabel5.text = "--"
                            }
                            else if (movementValue < 0)
                            {
                                movementImageView5.image = UIImage(named: "RankingDownArrow")
                                movementLabel5.text = String(abs(movementValue))
                            }
                            else
                            {
                                movementImageView5.image = UIImage(named: "RankingUpArrow")
                                movementLabel5.text = String(movementValue)
                            }
                            
                            let colorString = ranking["schoolColor1"] as! String
                            let color = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
                            schoolInitialLabel5.textColor = color
                            schoolInitialLabel5.text = String(schoolName.prefix(1))
                            
                            let mascotUrl = ranking["schoolMascotUrl"] as? String ?? ""
                            
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
                                            self.schoolInitialLabel5.isHidden = true
                                            MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.schoolMascotImageView5)!)
                                        }
                                    }
                                }
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

        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        containerView.clipsToBounds = true
        
        schoolMascotContainerView1.layer.cornerRadius = schoolMascotContainerView1.frame.size.width / 2
        schoolMascotContainerView1.clipsToBounds = true
        
        schoolMascotContainerView2.layer.cornerRadius = schoolMascotContainerView2.frame.size.width / 2
        schoolMascotContainerView2.clipsToBounds = true
        
        schoolMascotContainerView3.layer.cornerRadius = schoolMascotContainerView3.frame.size.width / 2
        schoolMascotContainerView3.clipsToBounds = true
        
        schoolMascotContainerView4.layer.cornerRadius = schoolMascotContainerView4.frame.size.width / 2
        schoolMascotContainerView4.clipsToBounds = true
        
        schoolMascotContainerView5.layer.cornerRadius = schoolMascotContainerView5.frame.size.width / 2
        schoolMascotContainerView5.clipsToBounds = true
    }

}
