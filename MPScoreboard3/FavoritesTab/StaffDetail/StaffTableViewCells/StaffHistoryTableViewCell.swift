//
//  StaffHistoryTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/2/23.
//

import UIKit

protocol StaffHistoryTableViewCellDelegate: AnyObject
{
    func staffCollectionViewDidSelectCareer(selectedAthlete: Athlete)
}

class StaffHistoryTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    weak var delegate: StaffHistoryTableViewCellDelegate?
    //var schoolColor: UIColor!
    
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var qwickStatsCollectionView: UICollectionView!
    
    private var staffStatsArray = [] as Array<Dictionary<String,Any>>
    private var careerInfo = [:] as Dictionary<String,Any>

    // MARK: - CollectionView Delegate Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return staffStatsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if (staffStatsArray.count > 1)
        {
            //return CGSize(width: kDeviceWidth - 48.0, height: 343.0)
            return CGSize(width: 324.0, height: 343.0)
        }
        else
        {
            return CGSize(width: kDeviceWidth - 32, height: 343.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 16.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 16.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StaffHistoryCollectionViewCell", for: indexPath) as! StaffHistoryCollectionViewCell
        
        let cardData = staffStatsArray[indexPath.row]
        
        let schoolColorString = cardData["schoolColor"] as? String
        let schoolColor = ColorHelper.color(fromHexString: schoolColorString, colorCorrection: true)!
        cell.addShapeLayers(color: schoolColor)
        
        cell.fullSeasonButton.tag = indexPath.row + 100
        cell.fullSeasonButton.isHidden = false
        cell.fullSeasonButton.addTarget(self, action: #selector(fullSeasonButtonTouched), for: .touchUpInside)

        // Load the labels
        cell.heightWeightTitleLabel.text = cardData["heightWeightLabel"] as? String
        //cell.positionsTitleLabel.text = cardData["positionsLabel"] as? String
        cell.positionsTitleLabel.text = "Position"
        
        var heightWeightString = cardData["heightWeightString"] as! String
        
        var heightWeight = "- -"
        if (heightWeightString.count > 0)
        {
            heightWeightString = heightWeightString.replacingOccurrences(of: ", ", with: " • ")
            heightWeight = heightWeightString.replacingOccurrences(of: "lbs", with: " lbs")
        }
        cell.heightWeightLabel.text = heightWeight
        
        let jerseyString = cardData["jersey"] as! String
        var jersey = "- -"
        
        if (jerseyString.count > 0)
        {
            jersey = String(format: "#%@", jerseyString)
        }
        cell.jerseyLabel.text = jersey
        
        let positionsString = cardData["positionsString"] as! String
        var positions = "- -"
        
        if (positionsString.count > 0)
        {
            positions = positionsString
        }
        cell.positionsLabel.text = positions
    
        let year = cardData["year"] as! String
        let grade = cardData["grade"] as! String
        //let shortGrade = MiscHelper.shortGradeFrom(grade: grade)
        cell.topContainerHeaderLabel.text = String(format: "20%@ | %@", year, grade)
        
        let schoolName = cardData["schoolName"] as! String
        cell.topContainerTitleLabel.text = schoolName
        
        let sport = cardData["sport"] as! String
        let teamLevel = cardData["level"] as! String
        cell.topContainerSubtitleLabel.text = String(format: "%@ %@", teamLevel, sport)
        
        let sportImage = MiscHelper.getImageForSport(sport)
        cell.topContainerSportIconImageView.image = sportImage
        
        // Load the image
        let urlString = cardData["photoUrl"] as! String
        
        if (urlString.count > 0)
        {
            let url = URL(string: urlString)
            
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }
                
                //print("Download Finished")
                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        cell.athleteImageView.image = image
                    }
                    else
                    {
                        cell.athleteImageView.image = UIImage(named: "Avatar")
                    }
                }
            }
        }
        else
        {
            cell.athleteImageView.image = UIImage(named: "Avatar")
        }
        
        // Show the captain icon
        cell.captainIconFrontImageView.isHidden = true
        cell.captainIconRearImageView.isHidden = true
        
        let tintedImage = UIImage(named: "CaptainIconRear")?.withRenderingMode(.alwaysTemplate)
        cell.captainIconRearImageView.image = tintedImage
        cell.captainIconRearImageView.tintColor = schoolColor
        
        if let isCaptain = cardData["isCaptain"] as? Bool
        {
            if (isCaptain == true)
            {
                cell.captainIconFrontImageView.isHidden = false
                cell.captainIconRearImageView.isHidden = false
            }
        }
        
        // Load the stats cells
        let statsData = cardData["stats"] as! Array<Dictionary<String,Any>>
        
        cell.statsTitleLabel1.text = "- -"
        cell.statsLabel1.text = "- -"
        cell.statsTitleLabel2.text = "- -"
        cell.statsLabel2.text = "- -"
        cell.statsTitleLabel3.text = "- -"
        cell.statsLabel3.text = "- -"
        cell.statsTitleLabel4.text = "- -"
        cell.statsLabel4.text = "- -"
        cell.statsTitleLabel5.text = "- -"
        cell.statsLabel5.text = "- -"
        cell.statsTitleLabel6.text = "- -"
        cell.statsLabel6.text = "- -"
        cell.statsTitleLabel7.text = "- -"
        cell.statsLabel7.text = "- -"
        
        // Hide the View Stats Button if empty
        if (statsData.count == 0)
        {
            cell.fullSeasonButton.isHidden = true
            return cell
        }
        
        // Add a second check to see if there are values for at least one category, otherwise hide the button
        var statFound = false
        for statDict in statsData
        {
            let valueString = statDict["value"] as! String
            if (valueString.count > 0)
            {
                statFound = true
                break
            }
        }
        
        if (statFound == false)
        {
            cell.fullSeasonButton.isHidden = true
            return cell
        }
        
        if (statsData.count > 0)
        {
            let statDict = statsData[0]
            let titleString = statDict["header"] as! String
            let valueString = statDict["value"] as! String
            
            if (titleString.count > 0)
            {
                cell.statsTitleLabel1.text = titleString.uppercased()
            }
            
            if (valueString.count > 0)
            {
                cell.statsLabel1.text = valueString
            }
        }
        
        if (statsData.count > 1)
        {
            let statDict = statsData[1]
            let titleString = statDict["header"] as! String
            let valueString = statDict["value"] as! String
            
            if (titleString.count > 0)
            {
                cell.statsTitleLabel2.text = titleString.uppercased()
            }
            
            if (valueString.count > 0)
            {
                cell.statsLabel2.text = valueString
            }
        }
        
        if (statsData.count > 2)
        {
            let statDict = statsData[2]
            let titleString = statDict["header"] as! String
            let valueString = statDict["value"] as! String

            if (titleString.count > 0)
            {
                cell.statsTitleLabel3.text = titleString.uppercased()
            }
            
            if (valueString.count > 0)
            {
                cell.statsLabel3.text = valueString
            }
        }
        
        if (statsData.count > 3)
        {
            let statDict = statsData[3]
            let titleString = statDict["header"] as! String
            let valueString = statDict["value"] as! String

            if (titleString.count > 0)
            {
                cell.statsTitleLabel4.text = titleString.uppercased()
            }
            
            if (valueString.count > 0)
            {
                cell.statsLabel4.text = valueString
            }
        }
        
        if (statsData.count > 4)
        {
            let statDict = statsData[4]
            let titleString = statDict["header"] as! String
            let valueString = statDict["value"] as! String
            
            if (titleString.count > 0)
            {
                cell.statsTitleLabel5.text = titleString.uppercased()
            }
            
            if (valueString.count > 0)
            {
                cell.statsLabel5.text = valueString
            }
        }
        
        if (statsData.count > 5)
        {
            let statDict = statsData[5]
            let titleString = statDict["header"] as! String
            let valueString = statDict["value"] as! String
            
            if (titleString.count > 0)
            {
                cell.statsTitleLabel6.text = titleString.uppercased()
            }
            
            if (valueString.count > 0)
            {
                cell.statsLabel6.text = valueString
            }
        }
        
        if (statsData.count > 6)
        {
            let statDict = statsData[6]
            let titleString = statDict["header"] as! String
            let valueString = statDict["value"] as! String
            
            if (titleString.count > 0)
            {
                cell.statsTitleLabel7.text = titleString.uppercased()
            }
            
            if (valueString.count > 0)
            {
                cell.statsLabel7.text = valueString
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        
    }
    
    // MARK: - Button Methods
    
    @objc func fullSeasonButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let cardData = staffStatsArray[index]
        
        // This is the bare minimum needed to open the AthleteDetailVC
        let careerId = careerInfo["careerId"] as! String
        let schoolColor = cardData["schoolColor"] as! String
        let firstName = careerInfo["firstName"] as! String
        let lastName = careerInfo["lastName"] as! String
        let schoolName = cardData["schoolName"] as! String
        let schoolId = cardData["schoolId"] as! String
        let city = cardData["schoolCity"] as? String ?? "?"
        let state = cardData["schoolState"] as? String ?? "?"
        let mascotUrl = cardData["schoolMascotUrl"] as? String ?? ""
        let photoUrl = cardData["photoUrl"] as! String
        
        let selectedAthlete = Athlete(firstName: firstName, lastName: lastName, schoolName: schoolName, schoolState: state, schoolCity: city, schoolId: schoolId, schoolColor: schoolColor, schoolMascotUrl: mascotUrl, careerId: careerId, photoUrl: photoUrl)

        self.delegate?.staffCollectionViewDidSelectCareer(selectedAthlete: selectedAthlete)
    }
    
    // MARK: - Load Data Method
    
    func loadData(staffStatsData: Array<Dictionary<String,Any>>, info: Dictionary<String,Any>)
    {
        staffStatsArray = staffStatsData
        careerInfo = info
    }
    
    // MARK: - Init Methods
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        innerContainerView.layer.cornerRadius = 12
        innerContainerView.clipsToBounds = true
        
        // Register the QuickStats Cell
        qwickStatsCollectionView.register(UINib.init(nibName: "StaffHistoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StaffHistoryCollectionViewCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
