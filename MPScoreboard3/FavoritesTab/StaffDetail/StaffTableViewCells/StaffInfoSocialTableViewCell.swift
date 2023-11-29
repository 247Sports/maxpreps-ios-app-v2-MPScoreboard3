//
//  StaffInfoSocialTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/1/23.
//

import UIKit

protocol StaffInfoSocialTableViewCellDelegate: AnyObject
{
    func socialCellDidSelectTwitter(handle: String)
    func socialCellDidSelectFacebook(urlString: String)
}

class StaffInfoSocialTableViewCell: UITableViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var itemScrollView: UIScrollView!
    
    weak var delegate: StaffInfoSocialTableViewCellDelegate?
    var dataCopy: Dictionary<String,Any> = [:]
    
    // MARK: - Button Methods
    
    @objc private func twitterTouched(_ sender: UIButton)
    {
        let twitter = dataCopy["twitterHandle"] as? String ?? ""
        
        if (twitter != "")
        {
            self.delegate?.socialCellDidSelectTwitter(handle: twitter)
        }
    }
    
    @objc private func facebookTouched(_ sender: UIButton)
    {
        let facebook = dataCopy["facebookUrl"] as? String ?? ""
        
        if ((facebook != "") && (facebook.isValidUrl == true))
        {
            self.delegate?.socialCellDidSelectFacebook(urlString: facebook)
        }
    }
    
    // MARK: - Load Data
    
    func loadData(_ data: Dictionary<String,Any>)
    {
        dataCopy = data
        
        // Build an array of images to use
        // ["Twitter", "Instagram", "Facebook"]
        var imageNames: Array<String> = []
        
        let twitter = data["twitterHandle"] as? String ?? ""
        if (twitter != "")
        {
            imageNames.append("Twitter")
        }
        
        let facebook = data["facebookUrl"] as? String ?? ""
        if (facebook != "")
        {
            imageNames.append("Facebook")
        }
        
        var leftPad = 0
        //let rightPad = 16
        let spacing = 20
        let itemWidth = 32
        var overallWidth = 0
        var index = 0
        
        for name in imageNames
        {
            // Add the left pad to the first cell
            if (index == 0)
            {
                leftPad = 16
            }
            else
            {
                leftPad = 0
            }
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: overallWidth + leftPad, y: 0, width: itemWidth, height: Int(itemScrollView.frame.size.height))
            button.backgroundColor = .clear
            button.setImage(UIImage(named: name), for: .normal)
            
            switch name
            {
            case "Twitter":
                button.addTarget(self, action: #selector(self.twitterTouched), for: .touchUpInside)
            case "Facebook":
                button.addTarget(self, action: #selector(self.facebookTouched), for: .touchUpInside)
            default:
                return
            }
            
            itemScrollView.addSubview(button)
            
            index += 1
            overallWidth += (leftPad + itemWidth + spacing)
        }
        
        //itemScrollView.contentSize = CGSize(width: overallWidth - spacing + rightPad, height: Int(itemScrollView.frame.size.height))
        
        /*
         Image names:
         Twitter
         Facebook
         */
        
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
