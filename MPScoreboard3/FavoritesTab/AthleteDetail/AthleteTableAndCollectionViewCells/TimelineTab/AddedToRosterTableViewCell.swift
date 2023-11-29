//
//  AddedToRosterTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/2/21.
//

import UIKit

class AddedToRosterTableViewCell: UITableViewCell
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var innerContainerYearLabel: UILabel!
    @IBOutlet weak var innerContainerSchoolNameLabel: UILabel!
    @IBOutlet weak var logoContainerView: UIView!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var teamLetterLabel: UILabel!
    
    // MARK: - Load Data Method
    
    func loadData(rosterData: Dictionary<String,Any>, selectedAthlete: Athlete)
    {
        /*
         ▿ 8 elements
           ▿ 0 : 2 elements
             - key : "text"
             - value : Jon David's has been added to the Oak Ridge 2011 football roster.
           ▿ 1 : 2 elements
             - key : "title"
             - value : Added to Roster
           ▿ 2 : 2 elements
             - key : "timeStamp"
             - value : 2011-07-20T19:15:00
           ▿ 3 : 2 elements
             - key : "type"
             - value : 5
           ▿ 4 : 2 elements
             - key : "timeStampString"
             - value : Wednesday, Jul 20, 2011
           ▿ 5 : 2 elements
             - key : "shareLink"
             - value : https://dev.maxpreps.com/high-schools/oak-ridge-trojans-(el-dorado-hills,ca)/football-fall-11/roster.htm
           ▿ 6 : 2 elements
             - key : "links"
             ▿ value : 2 elements
               ▿ 0 : 2 elements
                 ▿ 0 : 2 elements
                   - key : url
                   - value : https://dev.maxpreps.com/high-schools/oak-ridge-trojans-(el-dorado-hills,ca)/football-fall-11/roster.htm
                 ▿ 1 : 2 elements
                   - key : text
                   - value : Roster
               ▿ 1 : 2 elements
                 ▿ 0 : 2 elements
                   - key : url
                   - value : https://dev.maxpreps.com/high-schools/oak-ridge-trojans-(el-dorado-hills,ca)/football-fall-11/schedule.htm
                 ▿ 1 : 2 elements
                   - key : text
                   - value : Schedule
           ▿ 7 : 2 elements
             - key : "data"
             ▿ value : 7 elements
               ▿ 0 : 2 elements
                 - key : schoolColor2
                 - value : FFD700
               ▿ 1 : 2 elements
                 - key : schoolColor3
                 - value : FFFFFF
               ▿ 2 : 2 elements
                 - key : schoolColor4
                 - value :
               ▿ 3 : 2 elements
                 - key : schoolName
                 - value : Oak Ridge
               ▿ 4 : 2 elements
                 - key : sportSeasonYear
                 - value : 2011
               ▿ 5 : 2 elements
                 - key : schoolMascotUrl
                 - value : https://d1yf833igi2o06.cloudfront.net/fit-in/1024x1024/school-mascot/7/4/c/74c1621c-e0cf-4821-b5e1-3c8170c8125a.gif?version=636482374200000000
               ▿ 6 : 2 elements
                 - key : schoolColor1
                 - value : 000080
         */
        
        let title = rosterData["title"] as! String
        titleLabel.text = title
        
        let subtitle = rosterData["text"] as! String
        subtitleLabel.text = subtitle
        
        let dateString = rosterData["timeStampString"] as! String
        dateLabel.text = dateString
        
        let data = rosterData["data"] as! Dictionary<String, Any>
        let year = data["sportSeasonYear"] as! String
        innerContainerYearLabel.text = year
        
        let schoolName = selectedAthlete.schoolName
        innerContainerSchoolNameLabel.text = schoolName
        
        let colorString = selectedAthlete.schoolColor
        let color = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
        innerContainerView.backgroundColor = color
        
        let urlString = selectedAthlete.schoolMascotUrl
        
        if (urlString.count > 0)
        {
            let url = URL(string: urlString)
            
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        self.logoImageView.image = image
                    }
                    else
                    {
                        self.logoImageView.isHidden = true
                        
                        let name = selectedAthlete.schoolName
                        let initial = String(name.prefix(1))
                        
                        self.teamLetterLabel.text = initial
                        self.teamLetterLabel.textColor = color
                    }
                }
            }
        }
        else
        {
            logoImageView.isHidden = true
            
            let name = selectedAthlete.schoolName
            let initial = String(name.prefix(1))
            
            teamLetterLabel.text = initial
            teamLetterLabel.textColor = color
        }
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        logoContainerView.layer.cornerRadius = logoContainerView.frame.size.width / 2
        logoContainerView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
