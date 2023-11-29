//
//  PlayerInfoSocialTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/9/23.
//

import UIKit

protocol PlayerInfoSocialTableViewCellDelegate: AnyObject
{
    func socialCellDidSelectTwitter(handle: String)
    func socialCellDidSelectInstagram(username: String)
    func socialCellDidSelectSnapchat(urlString: String)
    func socialCellDidSelectTikTok(handle: String)
    func socialCellDidSelectFacebook(urlString: String)
    func socialCellDidSelectGameChanger(urlString: String)
    func socialCellDidSelectHudl(urlString: String)
    func socialCellDidSelectItem(urlString: String, title: String)
    func socialCellAddNewButtonTouched()
}

class PlayerInfoSocialTableViewCell: UITableViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var itemScrollView: UIScrollView!
    @IBOutlet weak var addNewButton: UIButton!
    
    weak var delegate: PlayerInfoSocialTableViewCellDelegate?
    private var dataCopy: Dictionary<String,Any> = [:]
    
    // MARK: - Button Methods
    
    @objc private func twitterTouched(_ sender: UIButton)
    {
        if let urlString = dataCopy["twitterFullUrl"] as? String
        {
            self.delegate?.socialCellDidSelectItem(urlString: urlString, title: "X")
        }
        else
        {
            // Use the old way
            let twitter = dataCopy["twitterHandle"] as? String ?? ""
            self.delegate?.socialCellDidSelectTwitter(handle: twitter)
        }
    }
    
    @objc private func instagramTouched(_ sender: UIButton)
    {
        if let urlString = dataCopy["instagramFullUrl"] as? String
        {
            self.delegate?.socialCellDidSelectItem(urlString: urlString, title: "Instagram")
        }
        else
        {
            // Use the old way
            let instagram = dataCopy["instagram"] as? String ?? ""
            self.delegate?.socialCellDidSelectInstagram(username: instagram)
        }
    }
    
    @objc private func snapchatTouched(_ sender: UIButton)
    {
        if let urlString = dataCopy["snapchatFullUrl"] as? String
        {
            self.delegate?.socialCellDidSelectItem(urlString: urlString, title: "Snapchat")
        }
        else
        {
            // Use the old way
            let snapchat = dataCopy["snapchat"] as? String ?? ""
            self.delegate?.socialCellDidSelectSnapchat(urlString: snapchat)
        }
    }
    
    @objc private func tiktokTouched(_ sender: UIButton)
    {
        if let urlString = dataCopy["tikTokFullUrl"] as? String
        {
            self.delegate?.socialCellDidSelectItem(urlString: urlString, title: "TikTok")
        }
        else
        {
            // Use the old way
            let tikTok = dataCopy["tikTok"] as? String ?? ""
            self.delegate?.socialCellDidSelectTikTok(handle: tikTok)
        }
    }
    
    @objc private func facebookTouched(_ sender: UIButton)
    {
        if let urlString = dataCopy["facebookFullUrl"] as? String
        {
            self.delegate?.socialCellDidSelectItem(urlString: urlString, title: "Facebook")
        }
        else
        {
            // Use the old way
            let facebook = dataCopy["facebookProfile"] as? String ?? ""
            self.delegate?.socialCellDidSelectFacebook(urlString: facebook)
        }
    }
    
    @objc private func gameChangerTouched(_ sender: UIButton)
    {
        if let urlString = dataCopy["gameChangerFullUrl"] as? String
        {
            self.delegate?.socialCellDidSelectItem(urlString: urlString, title: "GameChanger")
        }
        else
        {
            // Use the old way
            let gameChanger = dataCopy["gameChanger"] as? String ?? ""
            self.delegate?.socialCellDidSelectGameChanger(urlString: gameChanger)
        }
    }
    
    @objc private func hudlTouched(_ sender: UIButton)
    {
        if let urlString = dataCopy["hudlFullUrl"] as? String
        {
            self.delegate?.socialCellDidSelectItem(urlString: urlString, title: "Hudl")
        }
        else
        {
            // Use the old way
            let hudl = dataCopy["hudl"] as? String ?? ""
            self.delegate?.socialCellDidSelectHudl(urlString: hudl)
        }
    }
    
    @IBAction func addNewButtonTouched()
    {
        self.delegate?.socialCellAddNewButtonTouched()
    }
    
    // MARK: - Load Data
    
    func loadData(_ data: Dictionary<String,Any>, canEdit: Bool)
    {
        dataCopy = data
        
        // Build an array of images to use
        // ["Twitter", "Instagram", "Snapchat", "TikTok", "Facebook", "Hudl", "GameChanger"]
        var imageNames: Array<String> = []
        
        let twitter = data["twitterHandle"] as? String ?? ""
        if (twitter != "")
        {
            imageNames.append("Twitter")
        }
        
        let instagram = data["instagram"] as? String ?? ""
        if (instagram != "")
        {
            imageNames.append("Instagram")
        }
        
        let snapchat = data["snapchat"] as? String ?? ""
        if (snapchat != "")
        {
            imageNames.append("Snapchat")
        }
        
        let tikTok = data["tikTok"] as? String ?? ""
        if (tikTok != "")
        {
            imageNames.append("TikTok")
        }
        
        let facebook = data["facebookProfile"] as? String ?? ""
        if (facebook != "")
        {
            imageNames.append("Facebook")
        }
        
        let hudl = data["hudl"] as? String ?? ""
        if (hudl != "")
        {
            imageNames.append("Hudl")
        }
        
        let gameChanger = data["gameChanger"] as? String ?? ""
        if (gameChanger != "")
        {
            imageNames.append("GameChanger")
        }
        
        var leftPad = 0
        let rightPad = 16
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
            case "Instagram":
                button.addTarget(self, action: #selector(self.instagramTouched), for: .touchUpInside)
            case "Snapchat":
                button.addTarget(self, action: #selector(self.snapchatTouched), for: .touchUpInside)
            case "TikTok":
                button.addTarget(self, action: #selector(self.tiktokTouched), for: .touchUpInside)
            case "Facebook":
                button.addTarget(self, action: #selector(self.facebookTouched), for: .touchUpInside)
            case "GameChanger":
                button.addTarget(self, action: #selector(self.gameChangerTouched), for: .touchUpInside)
            case "Hudl":
                button.addTarget(self, action: #selector(self.hudlTouched), for: .touchUpInside)
            default:
                return
            }
            
            itemScrollView.addSubview(button)
            
            index += 1
            overallWidth += (leftPad + itemWidth + spacing)
        }
        
        itemScrollView.contentSize = CGSize(width: overallWidth - spacing + rightPad, height: Int(itemScrollView.frame.size.height))
        
        /*
         Image names:
         Twitter
         Instagram
         Snapchat
         TikTok
         Hudl
         GameChanger
         */
        
        if ((imageNames.count == 0) && (canEdit == true))
        {
            addNewButton.isHidden = false
        }
        else
        {
            addNewButton.isHidden = true
        }
 
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        
        // This will be shown if needed whentha data loads
        addNewButton.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
