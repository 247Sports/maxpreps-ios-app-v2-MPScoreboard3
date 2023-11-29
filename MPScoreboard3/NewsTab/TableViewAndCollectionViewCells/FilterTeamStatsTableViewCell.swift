//
//  FilterTeamStatsTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 1/21/22.
//

import UIKit

class FilterTeamStatsTableViewCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleBackgroundView: UIView!
    @IBOutlet weak var fullTeamStatLeadersButton: UIButton!
    
    @IBOutlet weak var innerContainerView1: UIView!
    @IBOutlet weak var innerMascotImageView1: UIImageView!
    @IBOutlet weak var innerInitialLabel1: UILabel!
    @IBOutlet weak var innerTitleLabel1: UILabel!
    @IBOutlet weak var innerSubtitleLabel1: UILabel!
    @IBOutlet weak var innerPointsLabel1: UILabel!
    @IBOutlet weak var innerShortCategoryLabel1: UILabel!
    @IBOutlet weak var innerButton1: UIButton!
    
    @IBOutlet weak var innerContainerView2: UIView!
    @IBOutlet weak var innerTitleLabel2: UILabel!
    @IBOutlet weak var innerSubtitleLabel2: UILabel!
    @IBOutlet weak var innerPointsLabel2: UILabel!
    @IBOutlet weak var innerShortCategoryLabel2: UILabel!
    @IBOutlet weak var innerButton2: UIButton!
    
    @IBOutlet weak var innerContainerView3: UIView!
    @IBOutlet weak var innerTitleLabel3: UILabel!
    @IBOutlet weak var innerSubtitleLabel3: UILabel!
    @IBOutlet weak var innerPointsLabel3: UILabel!
    @IBOutlet weak var innerShortCategoryLabel3: UILabel!
    @IBOutlet weak var innerButton3: UIButton!
    
    @IBOutlet weak var innerContainerView4: UIView!
    @IBOutlet weak var innerTitleLabel4: UILabel!
    @IBOutlet weak var innerSubtitleLabel4: UILabel!
    @IBOutlet weak var innerPointsLabel4: UILabel!
    @IBOutlet weak var innerShortCategoryLabel4: UILabel!
    @IBOutlet weak var innerButton4: UIButton!
    
    @IBOutlet weak var innerContainerView5: UIView!
    @IBOutlet weak var innerTitleLabel5: UILabel!
    @IBOutlet weak var innerSubtitleLabel5: UILabel!
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
        innerInitialLabel1.isHidden = false
        
        let title = data["statDisplayName"] as! String
        titleLabel.text = title.uppercased()

        let teams = data["teams"] as! Array<Dictionary<String,Any>>
        
        if (teams.count > 0)
        {
            innerContainerView1.isHidden = false
            
            let team = teams[0]
            
            let schoolName = team["schoolName"] as! String
            innerTitleLabel1.text = schoolName
            
            let schoolCity = team["schoolCity"] as! String
            let schoolState = team["schoolState"] as! String
            innerSubtitleLabel1.text = String(format: "%@, %@", schoolCity, schoolState)
            
            let schoolColorString = team["schoolColor1"] as! String
            let schoolColor = ColorHelper.color(fromHexString: schoolColorString, colorCorrection: true)
            
            innerInitialLabel1.text = String(schoolName.prefix(1))
            innerInitialLabel1.textColor = schoolColor
            
            let stats = team["stats"] as! Array<Dictionary<String,Any>>
            let stat = stats[0]
            let header = stat["header"] as! String
            innerShortCategoryLabel1.text = header
            innerShortCategoryLabel2.text = header
            innerShortCategoryLabel3.text = header
            innerShortCategoryLabel4.text = header
            innerShortCategoryLabel5.text = header
            
            let value = stat["value"] as! String
            innerPointsLabel1.text = value
            
            // Load the photo if it is available
            let mascotUrlString = team["schoolMascotUrl"] as? String ?? ""
            
            if (mascotUrlString.count > 0)
            {
                // Get the data and make an image
                let url = URL(string: mascotUrlString)
                
                MiscHelper.getData(from: url!) { data, response, error in
                    guard let data = data, error == nil else { return }

                    DispatchQueue.main.async()
                    {
                        let image = UIImage(data: data)
                        
                        if (image != nil)
                        {
                            self.innerInitialLabel1.isHidden = true
                            MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: self.innerMascotImageView1)
                        }
                    }
                }
            }
            
            if (teams.count > 1)
            {
                innerContainerView2.isHidden = false
                
                let team = teams[1]
                
                let schoolName = team["schoolName"] as! String
                innerTitleLabel2.text = schoolName
                
                let schoolCity = team["schoolCity"] as! String
                let schoolState = team["schoolState"] as! String
                innerSubtitleLabel2.text = String(format: "%@, %@", schoolCity, schoolState)
                
                let stats = team["stats"] as! Array<Dictionary<String,Any>>
                let stat = stats[0]
                
                let value = stat["value"] as! String
                innerPointsLabel2.text = value
                
                if (teams.count > 2)
                {
                    innerContainerView3.isHidden = false
                    
                    let team = teams[2]
                    
                    let schoolName = team["schoolName"] as! String
                    innerTitleLabel3.text = schoolName
                    
                    let schoolCity = team["schoolCity"] as! String
                    let schoolState = team["schoolState"] as! String
                    innerSubtitleLabel3.text = String(format: "%@, %@", schoolCity, schoolState)
                    
                    let stats = team["stats"] as! Array<Dictionary<String,Any>>
                    let stat = stats[0]
                    
                    let value = stat["value"] as! String
                    innerPointsLabel3.text = value
                    
                    if (teams.count > 3)
                    {
                        innerContainerView4.isHidden = false
                        
                        let team = teams[3]
                        
                        let schoolName = team["schoolName"] as! String
                        innerTitleLabel4.text = schoolName
                        
                        let schoolCity = team["schoolCity"] as! String
                        let schoolState = team["schoolState"] as! String
                        innerSubtitleLabel4.text = String(format: "%@, %@", schoolCity, schoolState)
                        
                        let stats = team["stats"] as! Array<Dictionary<String,Any>>
                        let stat = stats[0]
                        
                        let value = stat["value"] as! String
                        innerPointsLabel4.text = value
                        
                        if (teams.count > 4)
                        {
                            innerContainerView5.isHidden = false
                            
                            let team = teams[4]
                            
                            let schoolName = team["schoolName"] as! String
                            innerTitleLabel5.text = schoolName
                            
                            let schoolCity = team["schoolCity"] as! String
                            let schoolState = team["schoolState"] as! String
                            innerSubtitleLabel5.text = String(format: "%@, %@", schoolCity, schoolState)
                            
                            let stats = team["stats"] as! Array<Dictionary<String,Any>>
                            let stat = stats[0]
                            
                            let value = stat["value"] as! String
                            innerPointsLabel5.text = value
                            
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
        
        titleBackgroundView.layer.cornerRadius = 8
        titleBackgroundView.clipsToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
