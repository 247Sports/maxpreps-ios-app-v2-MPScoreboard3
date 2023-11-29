//
//  AthleteStatsCareerFooterViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 7/14/21.
//

import UIKit

class AthleteStatsCareerFooterViewCell: UITableViewCell, UIScrollViewDelegate
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
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
    
    func loadData(statTotalsArray: Array<Dictionary<String,Any>>)
    {
        verticalLine.isHidden = false
        leftShadow.isHidden = true
        rightShadow.isHidden = true
        
        // Remove all subviews from the scrollView
        for subview in statsScrollView.subviews
        {
            subview.removeFromSuperview()
        }
                
        // Add labels for each item in the statsArray
        var overallWidth = 0
        let width = 45
        for item in statTotalsArray
        {
            var title = item["value"] as! String
            if (title.count == 0)
            {
                title = "--"
            }
            
            let statLabel = UILabel(frame: CGRect(x: overallWidth, y: 6, width: width, height: 20))
            statLabel.font = UIFont.mpRegularFontWith(size: 12)
            statLabel.textColor = UIColor.mpGrayColor()
            statLabel.textAlignment = .center
            statLabel.adjustsFontSizeToFitWidth = true
            statLabel.minimumScaleFactor = 0.5
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
        
        leftShadow.isHidden = true
        rightShadow.isHidden = true
        
        // Round the container lower corners
        containerView.layer.cornerRadius = 12
        containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        containerView.clipsToBounds = true

        // Add a notification handler to detect that another cell scrolled
        NotificationCenter.default.addObserver(self, selector: #selector(scrollStats), name: Notification.Name("ScrollStats"), object: nil)
        
        // Modify the descrition label so the word "varsity" is in bold.
        let attributedString = descriptionLabel.text?.attributedText(withString: descriptionLabel.text!, boldString: "varsity", font: UIFont.mpRegularFontWith(size: 12), size: 12)
        descriptionLabel.attributedText = attributedString
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("ScrollStats"), object: nil)
    }
    
}
