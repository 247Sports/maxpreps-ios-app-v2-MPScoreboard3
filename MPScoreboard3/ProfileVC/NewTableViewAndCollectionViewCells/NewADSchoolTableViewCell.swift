//
//  NewADSchoolTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 7/19/23.
//

import UIKit

class NewADSchoolTableViewCell: UITableViewCell
{
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var mascotImageView: UIImageView!
    @IBOutlet weak var teamLetterLabel: UILabel!
    @IBOutlet weak var mascotContainerView: UIView!
    @IBOutlet weak var teamButton: UIButton!
    
    // MARK: - Load Data
    
    func loadData(_ data: Dictionary<String,Any>)
    {
        // Add a gradient layer
        let topColor = UIColor(white: 0, alpha: 0.0)
        let bottomColor = UIColor(white: 0, alpha: 0.3)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: kDeviceWidth - 32.0, height: innerContainerView.frame.size.height)
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        innerContainerView.layer.insertSublayer(gradientLayer, at: 0)

        mascotImageView.image = nil
        teamLetterLabel.isHidden = true
        
        let schoolName = data["schoolName"] as! String
        schoolNameLabel.text = schoolName
        
        let adminRoleTitle = data["adminRoleTitle"] as! String
        positionLabel.text = adminRoleTitle
        
        let schoolInitial = schoolName.first?.uppercased()
        teamLetterLabel.text = schoolInitial
        
        let colorString = data["schoolColor1"] as! String
        teamLetterLabel.textColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
        innerContainerView.backgroundColor = teamLetterLabel.textColor
        
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
                        // Render the mascot using this helper
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.mascotImageView)!)
                    }
                    else
                    {
                        self.teamLetterLabel.isHidden = false
                    }
                }
            }
        }
        else
        {
            self.teamLetterLabel.isHidden = false
            
        }

        /*
         ▿ 18 elements
           ▿ 0 : 2 elements
             - key : "teamLevel"
             - value : Varsity
           ▿ 1 : 2 elements
             - key : "adminRoleTitle"
             - value : Athletic Director
           ▿ 2 : 2 elements
             - key : "schoolMascot"
             - value : Node Kings
           ▿ 3 : 2 elements
             - key : "schoolMascotUrl"
             - value : https://image.maxpreps.io/school-mascot/3/2/b/32b8c0f9-3e03-46ea-b544-9d07883ab1a3.gif?version=636855609600000000&width=1024&height=1024
           ▿ 4 : 2 elements
             - key : "schoolName"
             - value : Metcalfe
           ▿ 5 : 2 elements
             - key : "schoolColor1"
             - value : 454444
           ▿ 6 : 2 elements
             - key : "schoolId"
             - value : 32b8c0f9-3e03-46ea-b544-9d07883ab1a3
           ▿ 7 : 2 elements
             - key : "schoolColor3"
             - value : 222222
           ▿ 8 : 2 elements
             - key : "sport"
             - value : Baseball
           ▿ 9 : 2 elements
             - key : "allSeasonId"
             - value : 94f7be29-2062-4d80-8064-3e8d89a3c54d
           ▿ 10 : 2 elements
             - key : "schoolColor2"
             - value : FFFFFF
           ▿ 11 : 2 elements
             - key : "season"
             - value : Spring
           ▿ 12 : 2 elements
             - key : "sportSeasonId"
             - value : adf63d11-0ada-483d-ada1-f31d2e9ea432
           ▿ 13 : 2 elements
             - key : "schoolColor4"
             - value :
           ▿ 14 : 2 elements
             - key : "schoolCity"
             - value : Max
           ▿ 15 : 2 elements
             - key : "schoolState"
             - value : CA
           ▿ 16 : 2 elements
             - key : "gender"
             - value : Boys
           ▿ 17 : 2 elements
             - key : "year"
             - value : 22-23
         */
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        innerContainerView.layer.cornerRadius = 8.0
        innerContainerView.clipsToBounds = true
        
        mascotContainerView.layer.cornerRadius = mascotContainerView.frame.size.width / 2.0
        mascotContainerView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
