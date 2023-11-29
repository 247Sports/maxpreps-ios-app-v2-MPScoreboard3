//
//  RosterStaffTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 7/30/21.
//

import UIKit

class RosterStaffTableViewCell: UITableViewCell
{
    @IBOutlet weak var staffImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var horizLine: UIView!
    
    // MARK: - Load Data
    
    func loadData(staff: RosterStaff)
    {
        titleLabel.text = staff.userFirstName + " " + staff.userLastName
        subtitleLabel.text = staff.position
        
        //print("Staff Photo URL: " + staff.photoUrl)
        
        if (staff.photoUrl.count > 0)
        {
            let url = URL(string: staff.photoUrl)
            
            // Get the data and make an image
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        self.staffImageView.image = image
                    }
                    else
                    {
                        self.staffImageView.image = UIImage(named: "Avatar")
                    }
                }
            }
        }
        else
        {
            staffImageView.image = UIImage(named: "Avatar")
        }
        
        /*
        // Get the photo from the userId
        if (staff.userId.count > 0)
        {
            LegacyFeeds.getUserImage(userId: staff.userId) { data, error in
                
                if (error == nil)
                {
                    let image = UIImage.init(data: data!)
                    
                    if (image != nil)
                    {
                        self.staffImageView.image = image
                    }
                    else
                    {
                        self.staffImageView.image = UIImage(named: "Avatar")
                    }
                }
                else
                {
                    self.staffImageView.image = UIImage(named: "Avatar")
                }
            }
        }
        else
        {
            staffImageView.image = UIImage(named: "Avatar")
        }
        */
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        staffImageView.layer.cornerRadius = staffImageView.frame.size.width / 2
        staffImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

    }
    
}
