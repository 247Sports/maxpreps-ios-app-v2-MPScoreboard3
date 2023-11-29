//
//  MiniPlayerInfoTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/19/22.
//

import UIKit

protocol MiniPlayerInfoTableViewCellDelegate: AnyObject
{
    func socialCellDidSelectItem(urlString: String, title: String)
}

class MiniPlayerInfoTableViewCell: UITableViewCell
{
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var sportLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var topHorizLine: UIView!
    @IBOutlet weak var socialHorizLine: UIView!
    @IBOutlet weak var socialTitleLabel: UILabel!
    @IBOutlet weak var lowerContainerView: UIView!
    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var bioLabel: UILabel!

    weak var delegate: MiniPlayerInfoTableViewCellDelegate?
    
    private var twitterUrl = ""
    private var instagramUrl = ""
    private var snapchatUrl = ""
    private var tikTokUrl = ""
    private var facebookUrl = ""
    private var gameChangerUrl = ""
    private var hudlUrl = ""
    
    // MARK: - Button Methods
    
    @objc private func twitterTouched(_ sender: UIButton)
    {
        self.delegate?.socialCellDidSelectItem(urlString: twitterUrl, title: "X")
    }
    
    @objc private func instagramTouched(_ sender: UIButton)
    {
        self.delegate?.socialCellDidSelectItem(urlString: instagramUrl, title: "Instagram")
    }
    
    @objc private func snapchatTouched(_ sender: UIButton)
    {
        self.delegate?.socialCellDidSelectItem(urlString: snapchatUrl, title: "Snapchat")
    }
    
    @objc private func tiktokTouched(_ sender: UIButton)
    {
        self.delegate?.socialCellDidSelectItem(urlString: tikTokUrl, title: "TikTok")
    }
    
    @objc private func facebookTouched(_ sender: UIButton)
    {
        self.delegate?.socialCellDidSelectItem(urlString: facebookUrl, title: "Facebook")
    }
    
    @objc private func gameChangerTouched(_ sender: UIButton)
    {
        self.delegate?.socialCellDidSelectItem(urlString: gameChangerUrl, title: "GameChanger")
    }
    
    @objc private func hudlTouched(_ sender: UIButton)
    {
        self.delegate?.socialCellDidSelectItem(urlString: hudlUrl, title: "Hudl")
    }
    
    // MARK: - Add Buttons
    
    private func addButtons()
    {
        // Build an array of images to use (in reverse for right justification
        // ["Twitter", "Instagram", "Snapchat", "TikTok", "Facebook", "Hudl", "GameChanger"]
        var imageNames: Array<String> = []

        if (hudlUrl != "")
        {
            imageNames.append("Hudl")
        }
        
        if (gameChangerUrl != "")
        {
            imageNames.append("GameChanger")
        }
        
        if (facebookUrl != "")
        {
            imageNames.append("Facebook")
        }
        
        if (tikTokUrl != "")
        {
            imageNames.append("TikTok")
        }
        
        if (snapchatUrl != "")
        {
            imageNames.append("Snapchat")
        }
        
        if (instagramUrl != "")
        {
            imageNames.append("Instagram")
        }
        
        if (twitterUrl != "")
        {
            imageNames.append("Twitter")
        }
        
        let spacing = 12
        let itemWidth = 24
        var index = 0
        
        for name in imageNames
        {
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: Int(iconContainerView.frame.size.width) - itemWidth - (index * (itemWidth + spacing)), y: 0, width: itemWidth, height: Int(iconContainerView.frame.size.height))
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
            
            iconContainerView.addSubview(button)
            index += 1
        }
    }
    
    // MARK: - Load Data
    
    func loadData(_ taggedAthlete: AthleteWithProfile)
    {
        twitterUrl = taggedAthlete.twitterUrl
        instagramUrl = taggedAthlete.instagramUrl
        snapchatUrl = taggedAthlete.snapchatUrl
        tikTokUrl = taggedAthlete.tikTokUrl
        facebookUrl = taggedAthlete.facebookUrl
        gameChangerUrl = taggedAthlete.gameChangerUrl
        hudlUrl = taggedAthlete.hudlUrl
        
        self.addButtons()
        
        classLabel.text = taggedAthlete.gradeClass
        sportLabel.text = taggedAthlete.sportsPlayedString
        
        // Resize the bioLabel height based upon the text
        let originalLabelHeight = bioLabel.frame.size.height
        
        //bioLabel.text = "This is a very long bio that takes more than one line. This is a very long bio that takes more than one line. This is a very long bio that takes more than one line."
        bioLabel.text = taggedAthlete.bio
        
        // Resize the bioLabel height based upon the text
        // Shift the lower container up
        
        var labelHeight = 0.0
        topHorizLine.isHidden = true
        
        if (bioLabel.text!.count > 0)
        {
            //labelHeight = (bioLabel.text!.size(font: UIFont.mpRegularFontWith(size: 15), width: bioLabel.frame.size.width)).height
            labelHeight = (bioLabel.text!.size(font: UIFont.mpRegularFontWith(size: 15), width: kDeviceWidth - 96.0)).height
            topHorizLine.isHidden = false
            
            // Cap the height to no more than the original size
            if (labelHeight > originalLabelHeight)
            {
                labelHeight = originalLabelHeight
            }
        }
        bioLabel.frame.size.height = labelHeight
        lowerContainerView.frame.origin.y = bioLabel.frame.origin.y + labelHeight + 8.0
                
        // This is a tuned value
        let heightDifference = originalLabelHeight - labelHeight - 8.0
        
        // Resize the cell based upon social data availability
        if ((twitterUrl != "") ||
        (instagramUrl != "") ||
        (snapchatUrl != "") ||
        (tikTokUrl != "") ||
        (facebookUrl != "") ||
        (gameChangerUrl != "") ||
        (hudlUrl != ""))
        {
            socialTitleLabel.isHidden = false
            socialHorizLine.isHidden = false
            iconContainerView.isHidden = false
            
            // Reduce the height of the containerView by any bioLabel difference
            innerContainerView.frame.size = CGSize(width: innerContainerView.frame.size.width, height: innerContainerView.frame.size.height - heightDifference)
        }
        else
        {
            socialTitleLabel.isHidden = true
            socialHorizLine.isHidden = true
            iconContainerView.isHidden = true
            
            // Reduce the height of the containerView by 40 and any bioLabel difference
            innerContainerView.frame.size = CGSize(width: innerContainerView.frame.size.width, height: innerContainerView.frame.size.height - 40.0 - heightDifference)
        }
    }
    
    // MARK: - Init Methods
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        innerContainerView.layer.cornerRadius = 8
        innerContainerView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
