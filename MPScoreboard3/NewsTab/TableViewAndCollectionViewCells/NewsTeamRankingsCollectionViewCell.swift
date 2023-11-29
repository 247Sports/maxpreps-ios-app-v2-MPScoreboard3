//
//  NewsTeamRankingsCollectionViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 12/14/21.
//

import UIKit

class NewsTeamRankingsCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var genderSportLabel: UILabel!
    @IBOutlet weak var schoolInitialLabel: UILabel!
    @IBOutlet weak var schoolMascotImageView: UIImageView!
    @IBOutlet weak var schoolMascotContainerView: UIView!
    @IBOutlet weak var headerButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fullRankingsButton: UIButton!
    
    @IBOutlet weak var innerContainerView1: UIView!
    @IBOutlet weak var titleLabel1: UILabel!
    @IBOutlet weak var rankingLabel1: UILabel!
    @IBOutlet weak var movementLabel1: UILabel!
    @IBOutlet weak var movementImageView1: UIImageView!
    
    @IBOutlet weak var innerContainerView2: UIView!
    @IBOutlet weak var titleLabel2: UILabel!
    @IBOutlet weak var rankingLabel2: UILabel!
    @IBOutlet weak var movementLabel2: UILabel!
    @IBOutlet weak var movementImageView2: UIImageView!
    
    @IBOutlet weak var innerContainerView3: UIView!
    @IBOutlet weak var titleLabel3: UILabel!
    @IBOutlet weak var rankingLabel3: UILabel!
    @IBOutlet weak var movementLabel3: UILabel!
    @IBOutlet weak var movementImageView3: UIImageView!
    
    @IBOutlet weak var innerContainerView4: UIView!
    @IBOutlet weak var titleLabel4: UILabel!
    @IBOutlet weak var rankingLabel4: UILabel!
    @IBOutlet weak var movementLabel4: UILabel!
    @IBOutlet weak var movementImageView4: UIImageView!
    
    @IBOutlet weak var innerContainerView5: UIView!
    @IBOutlet weak var titleLabel5: UILabel!
    @IBOutlet weak var rankingLabel5: UILabel!
    @IBOutlet weak var movementLabel5: UILabel!
    @IBOutlet weak var movementImageView5: UIImageView!
    
    // MARK: - Load Data
    
    func loadData(_ data: Dictionary<String,Any>)
    {
        let schoolName = data["schoolName"] as! String
        let schoolNameAcronym = data["schoolNameAcronym"] as! String
        
        if (schoolName.count > 20)
        {
            schoolNameLabel.text = schoolNameAcronym
        }
        else
        {
            schoolNameLabel.text = schoolName
        }
        
        let schoolColorString = data["schoolColor1"] as! String
        let schoolColor = ColorHelper.color(fromHexString: schoolColorString, colorCorrection: true)
        
        schoolInitialLabel.text = String(schoolName.prefix(1))
        schoolInitialLabel.textColor = schoolColor
        
        headerView.backgroundColor = schoolColor
        
        let gender = data["gender"] as! String
        let sport = data["sport"] as! String
        let level = data["level"] as! String
        
        genderSportLabel.text = MiscHelper.genderSportLevelFrom(gender: gender, sport: sport, level: level)
        
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
        
        let rankingData = data["rankingData"] as! Array<Dictionary<String,Any>>
        
        if (rankingData.count > 0)
        {
            innerContainerView1.isHidden = false
            
            let ranking = rankingData[0]
            
            let contextName = ranking["contextName"] as! String
            titleLabel1.text = contextName
            
            let rank = ranking["rank"] as! Int
            rankingLabel1.text = "#" + String(rank)
            
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
            
            if (rankingData.count > 1)
            {
                innerContainerView2.isHidden = false
                
                let ranking = rankingData[1]
                
                let contextName = ranking["contextName"] as! String
                titleLabel2.text = contextName
                
                let rank = ranking["rank"] as! Int
                rankingLabel2.text = "#" + String(rank)
                
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
                
                if (rankingData.count > 2)
                {
                    innerContainerView3.isHidden = false
                    
                    let ranking = rankingData[2]
                    
                    let contextName = ranking["contextName"] as! String
                    titleLabel3.text = contextName
                    
                    let rank = ranking["rank"] as! Int
                    rankingLabel3.text = "#" + String(rank)
                    
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
                    
                    if (rankingData.count > 3)
                    {
                        innerContainerView4.isHidden = false
                        
                        let ranking = rankingData[3]
                        
                        let contextName = ranking["contextName"] as! String
                        titleLabel4.text = contextName
                        
                        let rank = ranking["rank"] as! Int
                        rankingLabel4.text = "#" + String(rank)
                        
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
                        
                        if (rankingData.count > 4)
                        {
                            innerContainerView5.isHidden = false
                            
                            let ranking = rankingData[4]
                            
                            let contextName = ranking["contextName"] as! String
                            titleLabel5.text = contextName
                            
                            let rank = ranking["rank"] as! Int
                            rankingLabel5.text = "#" + String(rank)
                            
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
        
        schoolMascotContainerView.layer.cornerRadius = schoolMascotContainerView.frame.size.width / 2
        schoolMascotContainerView.clipsToBounds = true
        
    }

}
