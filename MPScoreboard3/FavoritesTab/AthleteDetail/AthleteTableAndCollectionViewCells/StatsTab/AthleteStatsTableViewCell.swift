//
//  AthleteStatsTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 7/13/21.
//

import UIKit

class AthleteStatsTableViewCell: UITableViewCell, UIScrollViewDelegate
{
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var centerLabel: UILabel!
    @IBOutlet weak var centerOverlayButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var verticalLine: UIView!
    @IBOutlet weak var leftShadow: UIImageView!
    @IBOutlet weak var rightShadow: UIImageView!
    @IBOutlet weak var statsScrollView: UIScrollView!
    
    // MARK: - Scroll Stats Notification
    
    @objc private func scrollStats()
    {
        //let userInfo = notification.userInfo
        let xScroll = SharedData.statsHorizontalScrollValue //userInfo!["scrollValue"] as! Int
        
        statsScrollView.contentOffset = CGPoint(x: xScroll, y: 0)
        
        if (xScroll <= 0)
        {
            verticalLine.isHidden = false
            leftShadow.isHidden = true
            rightShadow.isHidden = true
            
            // Show the right shadow if the content size is greater than the frame
            if (statsScrollView.contentSize.width > statsScrollView.frame.size.width)
            {
                rightShadow.isHidden = false
            }
        }
        else
        {
            verticalLine.isHidden = true
            leftShadow.isHidden = false
            rightShadow.isHidden = false
            
            // Hide the right shadow if scrolled to the end
            let sizeDifference = Int(statsScrollView.contentSize.width - statsScrollView.frame.size.width)
            if (xScroll >= sizeDifference)
            {
                rightShadow.isHidden = true
            }
        }
    }
    
    // MARK: - ScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        // Notify the other cells to scroll
        //let xScroll = Int(scrollView.contentOffset.x)
        //let xScrollNumber = NSNumber(integerLiteral: xScroll)
        SharedData.statsHorizontalScrollValue = Int(scrollView.contentOffset.x)
        
        //NotificationCenter.default.post(name: Notification.Name(rawValue:"ScrollStats"), object: nil, userInfo: ["scrollValue":xScrollNumber])
        NotificationCenter.default.post(name: Notification.Name(rawValue:"ScrollStats"), object: nil, userInfo: nil)
    }
    
    // MARK: - Load Data
    
    func loadData(statsData: Dictionary<String,Any>, careerMode:Bool)
    {
        verticalLine.isHidden = false
        leftShadow.isHidden = true
        rightShadow.isHidden = true
        
        var leftText = statsData["leftTitle"] as! String
        var centerText = statsData["centerTitle"] as! String
        var rightText = statsData["rightTitle"] as! String
        
        if (leftText.count == 0)
        {
            leftText = "--"
        }
        
        if (rightText.count == 0)
        {
            rightText = "--"
        }
        
        leftLabel.text = leftText
        
        rightButton.setTitle(rightText, for: .normal)
        rightButton.isUserInteractionEnabled = false
        rightButton.titleLabel?.minimumScaleFactor = 0.5
        rightButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        centerOverlayButton.isUserInteractionEnabled = false
        
        if (centerText.count == 0)
        {
            centerText = "--"
        }
                
        if (careerMode == false)
        {
            // Change the color of the right button text so it looks like a link
            rightButton.setTitleColor(UIColor.mpBlueColor(), for: .normal)
            rightButton.isUserInteractionEnabled = true
            
            // Enable the centerOverlayButton
            centerOverlayButton.isUserInteractionEnabled = true
            
            // Change the color and weight of the first letter of the center text
            if (centerText != "--")
            {
                let upperCaseCenterText = centerText.uppercased()
                
                let range = NSRange(location:0,length:1)
                let attributedString = NSMutableAttributedString(string: upperCaseCenterText)
                let firstCharacter = upperCaseCenterText.first
                
                // Change the text alignment and centering when a score is being displayed
                centerLabel.textAlignment = .left
                centerLabel.center = CGPoint(x: centerLabel.center.x + 6.0, y: centerLabel.center.y)
                
                if (firstCharacter == "W")
                {
                    attributedString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.mpGreenColor(), NSAttributedString.Key.font: UIFont.mpBoldFontWith(size: 12)], range: range)
                    centerLabel.attributedText = attributedString
                }
                else if (firstCharacter == "L")
                {
                    attributedString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.mpRedColor(), NSAttributedString.Key.font: UIFont.mpBoldFontWith(size: 12)], range: range)
                    centerLabel.attributedText = attributedString
                }
                else
                {
                    centerLabel.text = centerText
                }
            }
            else
            {
                centerLabel.text = centerText
                centerLabel.textAlignment = .center
            }
        }
        else
        {
            centerLabel.text = centerText
            centerLabel.textAlignment = .center
        }
        
        // Remove all subviews from the scrollView
        for subview in statsScrollView.subviews
        {
            subview.removeFromSuperview()
        }
        
        let statsArray = statsData["stats"] as! Array<Dictionary<String,String>>
        
        // Add labels for each item in the statsArray
        var overallWidth = 0
        let width = 45
        for stat in statsArray
        {
            let statLabel = UILabel(frame: CGRect(x: overallWidth, y: 6, width: width, height: 20))
            statLabel.font = UIFont.mpRegularFontWith(size: 12)
            statLabel.textColor = UIColor.mpGrayColor()
            statLabel.adjustsFontSizeToFitWidth = true
            statLabel.minimumScaleFactor = 0.5
            statLabel.textAlignment = .center
            
            var title = stat["value"]
            if(title?.count == 0)
            {
                title = "--"
            }
            statLabel.text = title
            statsScrollView.addSubview(statLabel)
            overallWidth += width
        }
        
        statsScrollView.contentSize = CGSize(width: CGFloat(overallWidth), height: statsScrollView.frame.size.height)
        
        // Show the rightShadow if the overallWidth is greater than the frame
        if (overallWidth > Int(statsScrollView.frame.size.width))
        {
            rightShadow.isHidden = false
        }
        
        self.scrollStats()
    }
        
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // Explicitely set the size
        statsScrollView.frame = CGRect(x: statsScrollView.frame.origin.x, y: 0, width: kDeviceWidth - statsScrollView.frame.origin.x, height: statsScrollView.frame.size.height)
        
        // Add a notification handler to detect that another cell scrolled
        NotificationCenter.default.addObserver(self, selector: #selector(scrollStats), name: Notification.Name("ScrollStats"), object: nil)
       
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("ScrollStats"), object: nil)
    }
    
}
