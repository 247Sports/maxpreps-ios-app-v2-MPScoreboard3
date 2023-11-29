//
//  NewsStandingsCollectionViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 12/7/21.
//

import UIKit

class NewsStandingsCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var bottomContainerOverlayView: UIView!
    @IBOutlet weak var bottomContactSupportButton: UIButton!
    @IBOutlet weak var bottomContainerOverlayLabel: UILabel!
    @IBOutlet weak var bottomStandingsButton: UIButton!
    @IBOutlet weak var topSportLabel: UILabel!
    @IBOutlet weak var topSportIconImageView: UIImageView!
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var bottomTitleLabel: UILabel!
        
    @IBOutlet weak var topInnerContainerView1: UIView!
    @IBOutlet weak var topInnerImageBackgroundView1: UIView!
    @IBOutlet weak var topMascotImage1: UIImageView!
    @IBOutlet weak var topInitialLabel1: UILabel!
    @IBOutlet weak var topRankingLabel1: UILabel!
    @IBOutlet weak var topSchoolNameLabel1: UILabel!
    @IBOutlet weak var topWinLossLabel1: UILabel!
    @IBOutlet weak var topPercentageLabel1: UILabel!
    @IBOutlet weak var topTeamSelectorButton1: UIButton!
    
    @IBOutlet weak var topInnerContainerView2: UIView!
    @IBOutlet weak var topInnerImageBackgroundView2: UIView!
    @IBOutlet weak var topMascotImage2: UIImageView!
    @IBOutlet weak var topInitialLabel2: UILabel!
    @IBOutlet weak var topRankingLabel2: UILabel!
    @IBOutlet weak var topSchoolNameLabel2: UILabel!
    @IBOutlet weak var topWinLossLabel2: UILabel!
    @IBOutlet weak var topPercentageLabel2: UILabel!
    @IBOutlet weak var topTeamSelectorButton2: UIButton!
    
    @IBOutlet weak var topInnerContainerView3: UIView!
    @IBOutlet weak var topInnerImageBackgroundView3: UIView!
    @IBOutlet weak var topMascotImage3: UIImageView!
    @IBOutlet weak var topInitialLabel3: UILabel!
    @IBOutlet weak var topRankingLabel3: UILabel!
    @IBOutlet weak var topSchoolNameLabel3: UILabel!
    @IBOutlet weak var topWinLossLabel3: UILabel!
    @IBOutlet weak var topPercentageLabel3: UILabel!
    @IBOutlet weak var topTeamSelectorButton3: UIButton!
    
    @IBOutlet weak var bottomInnerContainerView1: UIView!
    @IBOutlet weak var bottomInnerImageBackgroundView1: UIView!
    @IBOutlet weak var bottomMascotImage1: UIImageView!
    @IBOutlet weak var bottomInitialLabel1: UILabel!
    @IBOutlet weak var bottomRankingLabel1: UILabel!
    @IBOutlet weak var bottomSchoolNameLabel1: UILabel!
    @IBOutlet weak var bottomWinLossLabel1: UILabel!
    @IBOutlet weak var bottomPercentageLabel1: UILabel!
    @IBOutlet weak var bottomTeamSelectorButton1: UIButton!
    
    @IBOutlet weak var bottomInnerContainerView2: UIView!
    @IBOutlet weak var bottomInnerImageBackgroundView2: UIView!
    @IBOutlet weak var bottomMascotImage2: UIImageView!
    @IBOutlet weak var bottomInitialLabel2: UILabel!
    @IBOutlet weak var bottomRankingLabel2: UILabel!
    @IBOutlet weak var bottomSchoolNameLabel2: UILabel!
    @IBOutlet weak var bottomWinLossLabel2: UILabel!
    @IBOutlet weak var bottomPercentageLabel2: UILabel!
    @IBOutlet weak var bottomTeamSelectorButton2: UIButton!
    
    @IBOutlet weak var bottomInnerContainerView3: UIView!
    @IBOutlet weak var bottomInnerImageBackgroundView3: UIView!
    @IBOutlet weak var bottomMascotImage3: UIImageView!
    @IBOutlet weak var bottomInitialLabel3: UILabel!
    @IBOutlet weak var bottomRankingLabel3: UILabel!
    @IBOutlet weak var bottomSchoolNameLabel3: UILabel!
    @IBOutlet weak var bottomWinLossLabel3: UILabel!
    @IBOutlet weak var bottomPercentageLabel3: UILabel!
    @IBOutlet weak var bottomTeamSelectorButton3: UIButton!
    
    var favoriteTeamIdentifierArray = [] as Array<String>
    
    // MARK: - Clear Fields
    
    private func clearFields()
    {
        topTitleLabel.text = ""
        bottomTitleLabel.text = ""
        
        topInitialLabel1.isHidden = false
        topInitialLabel2.isHidden = false
        topInitialLabel3.isHidden = false
        bottomInitialLabel1.isHidden = false
        bottomInitialLabel2.isHidden = false
        bottomInitialLabel3.isHidden = false

        topMascotImage1.image = nil
        topInitialLabel1.text = ""
        topRankingLabel1.text = ""
        topSchoolNameLabel1.text = ""
        topWinLossLabel1.text = ""
        topPercentageLabel1.text = ""
        
        topMascotImage2.image = nil
        topInitialLabel2.text = ""
        topRankingLabel2.text = ""
        topSchoolNameLabel2.text = ""
        topWinLossLabel2.text = ""
        topPercentageLabel2.text = ""
        
        topMascotImage3.image = nil
        topInitialLabel3.text = ""
        topRankingLabel3.text = ""
        topSchoolNameLabel3.text = ""
        topWinLossLabel3.text = ""
        topPercentageLabel3.text = ""
        
        bottomMascotImage1.image = nil
        bottomInitialLabel1.text = ""
        bottomRankingLabel1.text = ""
        bottomSchoolNameLabel1.text = ""
        bottomWinLossLabel1.text = ""
        bottomPercentageLabel1.text = ""
        
        bottomMascotImage2.image = nil
        bottomInitialLabel2.text = ""
        bottomRankingLabel2.text = ""
        bottomSchoolNameLabel2.text = ""
        bottomWinLossLabel2.text = ""
        bottomPercentageLabel2.text = ""
        
        bottomMascotImage3.image = nil
        bottomInitialLabel3.text = ""
        bottomRankingLabel3.text = ""
        bottomSchoolNameLabel3.text = ""
        bottomWinLossLabel3.text = ""
        bottomPercentageLabel3.text = ""
        
        // Reset the colors and fonts for each team cell
        
        topRankingLabel1.textColor = UIColor.mpGrayColor()
        topSchoolNameLabel1.textColor = UIColor.mpGrayColor()
        topWinLossLabel1.textColor = UIColor.mpGrayColor()
        topPercentageLabel1.textColor = UIColor.mpGrayColor()
        topRankingLabel1.font = UIFont.mpRegularFontWith(size: 13)
        topSchoolNameLabel1.font = UIFont.mpRegularFontWith(size: 13)
        topWinLossLabel1.font = UIFont.mpRegularFontWith(size: 13)
        topPercentageLabel1.font = UIFont.mpRegularFontWith(size: 13)
        
        topRankingLabel2.textColor = UIColor.mpGrayColor()
        topSchoolNameLabel2.textColor = UIColor.mpGrayColor()
        topWinLossLabel2.textColor = UIColor.mpGrayColor()
        topPercentageLabel2.textColor = UIColor.mpGrayColor()
        topRankingLabel2.font = UIFont.mpRegularFontWith(size: 13)
        topSchoolNameLabel2.font = UIFont.mpRegularFontWith(size: 13)
        topWinLossLabel2.font = UIFont.mpRegularFontWith(size: 13)
        topPercentageLabel2.font = UIFont.mpRegularFontWith(size: 13)
        
        topRankingLabel3.textColor = UIColor.mpGrayColor()
        topSchoolNameLabel3.textColor = UIColor.mpGrayColor()
        topWinLossLabel3.textColor = UIColor.mpGrayColor()
        topPercentageLabel3.textColor = UIColor.mpGrayColor()
        topRankingLabel3.font = UIFont.mpRegularFontWith(size: 13)
        topSchoolNameLabel3.font = UIFont.mpRegularFontWith(size: 13)
        topWinLossLabel3.font = UIFont.mpRegularFontWith(size: 13)
        topPercentageLabel3.font = UIFont.mpRegularFontWith(size: 13)
        
        bottomRankingLabel1.textColor = UIColor.mpGrayColor()
        bottomSchoolNameLabel1.textColor = UIColor.mpGrayColor()
        bottomWinLossLabel1.textColor = UIColor.mpGrayColor()
        bottomPercentageLabel1.textColor = UIColor.mpGrayColor()
        bottomRankingLabel1.font = UIFont.mpRegularFontWith(size: 13)
        bottomSchoolNameLabel1.font = UIFont.mpRegularFontWith(size: 13)
        bottomWinLossLabel1.font = UIFont.mpRegularFontWith(size: 13)
        bottomPercentageLabel1.font = UIFont.mpRegularFontWith(size: 13)
        
        bottomRankingLabel2.textColor = UIColor.mpGrayColor()
        bottomSchoolNameLabel2.textColor = UIColor.mpGrayColor()
        bottomWinLossLabel2.textColor = UIColor.mpGrayColor()
        bottomPercentageLabel2.textColor = UIColor.mpGrayColor()
        bottomRankingLabel2.font = UIFont.mpRegularFontWith(size: 13)
        bottomSchoolNameLabel2.font = UIFont.mpRegularFontWith(size: 13)
        bottomWinLossLabel2.font = UIFont.mpRegularFontWith(size: 13)
        bottomPercentageLabel2.font = UIFont.mpRegularFontWith(size: 13)
        
        bottomRankingLabel3.textColor = UIColor.mpGrayColor()
        bottomSchoolNameLabel3.textColor = UIColor.mpGrayColor()
        bottomWinLossLabel3.textColor = UIColor.mpGrayColor()
        bottomPercentageLabel3.textColor = UIColor.mpGrayColor()
        bottomRankingLabel3.font = UIFont.mpRegularFontWith(size: 13)
        bottomSchoolNameLabel3.font = UIFont.mpRegularFontWith(size: 13)
        bottomWinLossLabel3.font = UIFont.mpRegularFontWith(size: 13)
        bottomPercentageLabel3.font = UIFont.mpRegularFontWith(size: 13)
        
        // Remove the border from the mascot background
        topInnerImageBackgroundView1.layer.borderWidth = 0
        topInnerImageBackgroundView2.layer.borderWidth = 0
        topInnerImageBackgroundView3.layer.borderWidth = 0
        
        bottomInnerImageBackgroundView1.layer.borderWidth = 0
        bottomInnerImageBackgroundView2.layer.borderWidth = 0
        bottomInnerImageBackgroundView3.layer.borderWidth = 0
        
        // Clear out all of the sublayers
        let sublayers1 = topInnerContainerView1.layer.sublayers
        
        for layer in sublayers1!
        {
            if ((layer.name == "Front") || (layer.name == "Rear"))
            {
                layer.removeFromSuperlayer()
            }
        }
        
        let sublayers2 = topInnerContainerView2.layer.sublayers
        
        for layer in sublayers2!
        {
            if ((layer.name == "Front") || (layer.name == "Rear"))
            {
                layer.removeFromSuperlayer()
            }
        }
        
        let sublayers3 = topInnerContainerView3.layer.sublayers
        
        for layer in sublayers3!
        {
            if ((layer.name == "Front") || (layer.name == "Rear"))
            {
                layer.removeFromSuperlayer()
            }
        }
        
        let sublayers4 = bottomInnerContainerView1.layer.sublayers
        
        for layer in sublayers4!
        {
            if ((layer.name == "Front") || (layer.name == "Rear"))
            {
                layer.removeFromSuperlayer()
            }
        }
        
        let sublayers5 = bottomInnerContainerView2.layer.sublayers
        
        for layer in sublayers5!
        {
            if ((layer.name == "Front") || (layer.name == "Rear"))
            {
                layer.removeFromSuperlayer()
            }
        }
        
        let sublayers6 = bottomInnerContainerView3.layer.sublayers
        
        for layer in sublayers6!
        {
            if ((layer.name == "Front") || (layer.name == "Rear"))
            {
                layer.removeFromSuperlayer()
            }
        }
    }
    
    // MARK: - Highlight Cells
    
    private func highlightTopCell1(color: UIColor)
    {
        topRankingLabel1.textColor = UIColor.mpWhiteColor()
        topSchoolNameLabel1.textColor = UIColor.mpBlackColor()
        topWinLossLabel1.textColor = UIColor.mpBlackColor()
        topPercentageLabel1.textColor = UIColor.mpBlackColor()
        topRankingLabel1.font = UIFont.mpBoldFontWith(size: 13)
        topSchoolNameLabel1.font = UIFont.mpBoldFontWith(size: 13)
        topWinLossLabel1.font = UIFont.mpBoldFontWith(size: 13)
        topPercentageLabel1.font = UIFont.mpBoldFontWith(size: 13)
        
        /*
        // Add a shadow to the image background
        topInnerImageBackgroundView1.layer.masksToBounds = false
        topInnerImageBackgroundView1.layer.shadowColor = UIColor(white: 0.7, alpha: 1.0).cgColor
        topInnerImageBackgroundView1.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        topInnerImageBackgroundView1.layer.shadowRadius = 2
        topInnerImageBackgroundView1.layer.shadowOpacity = 0.5
        */
        topInnerImageBackgroundView1.layer.borderWidth = 1
        topInnerImageBackgroundView1.layer.borderColor = UIColor.mpOffWhiteNavColor().cgColor
        
        // Create a new path for the rear light part
        let rearPath = UIBezierPath()

        // Starting point for the path
        rearPath.move(to: CGPoint(x: 0, y: 0))
        rearPath.addLine(to: CGPoint(x: 71, y: 0))
        rearPath.addLine(to: CGPoint(x: 43, y: topInnerContainerView1.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: topInnerContainerView1.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: 0))
        rearPath.close()
        
        // Create a CAShapeLayer
        //let lightColor = color.lighter(by: 70.0)
        let lightColor = color.withAlphaComponent(0.3)
        let rearShapeLayer = CAShapeLayer()
        rearShapeLayer.name = "Rear"
        rearShapeLayer.path = rearPath.cgPath
        rearShapeLayer.fillColor = lightColor.cgColor
        rearShapeLayer.position = CGPoint(x: 0, y: 0)

        topInnerContainerView1.layer.insertSublayer(rearShapeLayer, below: topInnerImageBackgroundView1.layer)
        
        // Create a new path for the dark front part
        let frontPath = UIBezierPath()

        // Starting point for the path
        frontPath.move(to: CGPoint(x: 0, y: 0))
        frontPath.addLine(to: CGPoint(x: 56, y: 0))
        frontPath.addLine(to: CGPoint(x: 40, y: topInnerContainerView1.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: topInnerContainerView1.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: 0))
        frontPath.close()
        
        // Create a CAShapeLayer
        let frontShapeLayer = CAShapeLayer()
        frontShapeLayer.name = "Front"
        frontShapeLayer.path = frontPath.cgPath
        frontShapeLayer.fillColor = color.cgColor
        frontShapeLayer.position = CGPoint(x: 0, y: 0)

        topInnerContainerView1.layer.insertSublayer(frontShapeLayer, above: rearShapeLayer)
    }
    
    private func highlightTopCell2(color: UIColor)
    {
        topRankingLabel2.textColor = UIColor.mpWhiteColor()
        topSchoolNameLabel2.textColor = UIColor.mpBlackColor()
        topWinLossLabel2.textColor = UIColor.mpBlackColor()
        topPercentageLabel2.textColor = UIColor.mpBlackColor()
        topRankingLabel2.font = UIFont.mpBoldFontWith(size: 13)
        topSchoolNameLabel2.font = UIFont.mpBoldFontWith(size: 13)
        topWinLossLabel2.font = UIFont.mpBoldFontWith(size: 13)
        topPercentageLabel2.font = UIFont.mpBoldFontWith(size: 13)
        
        /*
        // Add a shadow to the image background
        topInnerImageBackgroundView2.layer.masksToBounds = false
        topInnerImageBackgroundView2.layer.shadowColor = UIColor(white: 0.7, alpha: 1.0).cgColor
        topInnerImageBackgroundView2.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        topInnerImageBackgroundView2.layer.shadowRadius = 2
        topInnerImageBackgroundView2.layer.shadowOpacity = 0.5
        */
        topInnerImageBackgroundView2.layer.borderWidth = 1
        topInnerImageBackgroundView2.layer.borderColor = UIColor.mpOffWhiteNavColor().cgColor
        
        // Create a new path for the rear light part
        let rearPath = UIBezierPath()

        // Starting point for the path
        rearPath.move(to: CGPoint(x: 0, y: 0))
        rearPath.addLine(to: CGPoint(x: 71, y: 0))
        rearPath.addLine(to: CGPoint(x: 43, y: topInnerContainerView2.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: topInnerContainerView2.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: 0))
        rearPath.close()
        
        // Create a CAShapeLayer
        //let lightColor = color.lighter(by: 70.0)
        let lightColor = color.withAlphaComponent(0.3)
        let rearShapeLayer = CAShapeLayer()
        rearShapeLayer.name = "Rear"
        rearShapeLayer.path = rearPath.cgPath
        rearShapeLayer.fillColor = lightColor.cgColor
        rearShapeLayer.position = CGPoint(x: 0, y: 0)

        topInnerContainerView2.layer.insertSublayer(rearShapeLayer, below: topInnerImageBackgroundView2.layer)
        
        // Create a new path for the dark front part
        let frontPath = UIBezierPath()

        // Starting point for the path
        frontPath.move(to: CGPoint(x: 0, y: 0))
        frontPath.addLine(to: CGPoint(x: 56, y: 0))
        frontPath.addLine(to: CGPoint(x: 40, y: topInnerContainerView2.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: topInnerContainerView2.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: 0))
        frontPath.close()
        
        // Create a CAShapeLayer
        let frontShapeLayer = CAShapeLayer()
        frontShapeLayer.name = "Front"
        frontShapeLayer.path = frontPath.cgPath
        frontShapeLayer.fillColor = color.cgColor
        frontShapeLayer.position = CGPoint(x: 0, y: 0)

        topInnerContainerView2.layer.insertSublayer(frontShapeLayer, above: rearShapeLayer)
    }
    
    private func highlightTopCell3(color: UIColor)
    {
        topRankingLabel3.textColor = UIColor.mpWhiteColor()
        topSchoolNameLabel3.textColor = UIColor.mpBlackColor()
        topWinLossLabel3.textColor = UIColor.mpBlackColor()
        topPercentageLabel3.textColor = UIColor.mpBlackColor()
        topRankingLabel3.font = UIFont.mpBoldFontWith(size: 13)
        topSchoolNameLabel3.font = UIFont.mpBoldFontWith(size: 13)
        topWinLossLabel3.font = UIFont.mpBoldFontWith(size: 13)
        topPercentageLabel3.font = UIFont.mpBoldFontWith(size: 13)
        
        /*
        // Add a shadow to the image background
        topInnerImageBackgroundView3.layer.masksToBounds = false
        topInnerImageBackgroundView3.layer.shadowColor = UIColor(white: 0.7, alpha: 1.0).cgColor
        topInnerImageBackgroundView3.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        topInnerImageBackgroundView3.layer.shadowRadius = 2
        topInnerImageBackgroundView3.layer.shadowOpacity = 0.5
        */
        topInnerImageBackgroundView3.layer.borderWidth = 1
        topInnerImageBackgroundView3.layer.borderColor = UIColor.mpOffWhiteNavColor().cgColor
        
        // Create a new path for the rear light part
        let rearPath = UIBezierPath()

        // Starting point for the path
        rearPath.move(to: CGPoint(x: 0, y: 0))
        rearPath.addLine(to: CGPoint(x: 71, y: 0))
        rearPath.addLine(to: CGPoint(x: 43, y: topInnerContainerView3.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: topInnerContainerView3.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: 0))
        rearPath.close()
        
        // Create a CAShapeLayer
        //let lightColor = color.lighter(by: 70.0)
        let lightColor = color.withAlphaComponent(0.3)
        let rearShapeLayer = CAShapeLayer()
        rearShapeLayer.name = "Rear"
        rearShapeLayer.path = rearPath.cgPath
        rearShapeLayer.fillColor = lightColor.cgColor
        rearShapeLayer.position = CGPoint(x: 0, y: 0)

        topInnerContainerView3.layer.insertSublayer(rearShapeLayer, below: topInnerImageBackgroundView3.layer)
        
        // Create a new path for the dark front part
        let frontPath = UIBezierPath()

        // Starting point for the path
        frontPath.move(to: CGPoint(x: 0, y: 0))
        frontPath.addLine(to: CGPoint(x: 56, y: 0))
        frontPath.addLine(to: CGPoint(x: 40, y: topInnerContainerView3.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: topInnerContainerView3.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: 0))
        frontPath.close()
        
        // Create a CAShapeLayer
        let frontShapeLayer = CAShapeLayer()
        frontShapeLayer.name = "Front"
        frontShapeLayer.path = frontPath.cgPath
        frontShapeLayer.fillColor = color.cgColor
        frontShapeLayer.position = CGPoint(x: 0, y: 0)

        topInnerContainerView3.layer.insertSublayer(frontShapeLayer, above: rearShapeLayer)
    }
    
    private func highlightBottomCell1(color: UIColor)
    {
        bottomRankingLabel1.textColor = UIColor.mpWhiteColor()
        bottomSchoolNameLabel1.textColor = UIColor.mpBlackColor()
        bottomWinLossLabel1.textColor = UIColor.mpBlackColor()
        bottomPercentageLabel1.textColor = UIColor.mpBlackColor()
        bottomRankingLabel1.font = UIFont.mpBoldFontWith(size: 13)
        bottomSchoolNameLabel1.font = UIFont.mpBoldFontWith(size: 13)
        bottomWinLossLabel1.font = UIFont.mpBoldFontWith(size: 13)
        bottomPercentageLabel1.font = UIFont.mpBoldFontWith(size: 13)
        /*
        // Add a shadow to the image background
        bottomInnerImageBackgroundView1.layer.masksToBounds = false
        bottomInnerImageBackgroundView1.layer.shadowColor = UIColor(white: 0.7, alpha: 1.0).cgColor
        bottomInnerImageBackgroundView1.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        bottomInnerImageBackgroundView1.layer.shadowRadius = 2
        bottomInnerImageBackgroundView1.layer.shadowOpacity = 0.5
        */
        bottomInnerImageBackgroundView1.layer.borderWidth = 1
        bottomInnerImageBackgroundView1.layer.borderColor = UIColor.mpOffWhiteNavColor().cgColor
        
        // Create a new path for the rear light part
        let rearPath = UIBezierPath()

        // Starting point for the path
        rearPath.move(to: CGPoint(x: 0, y: 0))
        rearPath.addLine(to: CGPoint(x: 71, y: 0))
        rearPath.addLine(to: CGPoint(x: 43, y: bottomInnerContainerView1.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: bottomInnerContainerView1.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: 0))
        rearPath.close()
        
        // Create a CAShapeLayer
        //let lightColor = color.lighter(by: 70.0)
        let lightColor = color.withAlphaComponent(0.3)
        let rearShapeLayer = CAShapeLayer()
        rearShapeLayer.name = "Rear"
        rearShapeLayer.path = rearPath.cgPath
        rearShapeLayer.fillColor = lightColor.cgColor
        rearShapeLayer.position = CGPoint(x: 0, y: 0)

        bottomInnerContainerView1.layer.insertSublayer(rearShapeLayer, below: bottomInnerImageBackgroundView1.layer)

        // Create a new path for the dark front part
        let frontPath = UIBezierPath()

        // Starting point for the path
        frontPath.move(to: CGPoint(x: 0, y: 0))
        frontPath.addLine(to: CGPoint(x: 56, y: 0))
        frontPath.addLine(to: CGPoint(x: 40, y: bottomInnerContainerView1.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: bottomInnerContainerView1.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: 0))
        frontPath.close()
        
        // Create a CAShapeLayer
        let frontShapeLayer = CAShapeLayer()
        frontShapeLayer.name = "Front"
        frontShapeLayer.path = frontPath.cgPath
        frontShapeLayer.fillColor = color.cgColor
        frontShapeLayer.position = CGPoint(x: 0, y: 0)

        bottomInnerContainerView1.layer.insertSublayer(frontShapeLayer, above: rearShapeLayer)
    }
    
    private func highlightBottomCell2(color: UIColor)
    {
        bottomRankingLabel2.textColor = UIColor.mpWhiteColor()
        bottomSchoolNameLabel2.textColor = UIColor.mpBlackColor()
        bottomWinLossLabel2.textColor = UIColor.mpBlackColor()
        bottomPercentageLabel2.textColor = UIColor.mpBlackColor()
        bottomRankingLabel2.font = UIFont.mpBoldFontWith(size: 13)
        bottomSchoolNameLabel2.font = UIFont.mpBoldFontWith(size: 13)
        bottomWinLossLabel2.font = UIFont.mpBoldFontWith(size: 13)
        bottomPercentageLabel2.font = UIFont.mpBoldFontWith(size: 13)
        /*
        // Add a shadow to the image background
        bottomInnerImageBackgroundView2.layer.masksToBounds = false
        bottomInnerImageBackgroundView2.layer.shadowColor = UIColor(white: 0.7, alpha: 1.0).cgColor
        bottomInnerImageBackgroundView2.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        bottomInnerImageBackgroundView2.layer.shadowRadius = 2
        bottomInnerImageBackgroundView2.layer.shadowOpacity = 0.5
        */
        bottomInnerImageBackgroundView2.layer.borderWidth = 1
        bottomInnerImageBackgroundView2.layer.borderColor = UIColor.mpOffWhiteNavColor().cgColor
        
        // Create a new path for the rear light part
        let rearPath = UIBezierPath()

        // Starting point for the path
        rearPath.move(to: CGPoint(x: 0, y: 0))
        rearPath.addLine(to: CGPoint(x: 71, y: 0))
        rearPath.addLine(to: CGPoint(x: 43, y: bottomInnerContainerView2.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: bottomInnerContainerView2.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: 0))
        rearPath.close()
        
        // Create a CAShapeLayer
        //let lightColor = color.lighter(by: 70.0)
        let lightColor = color.withAlphaComponent(0.3)
        let rearShapeLayer = CAShapeLayer()
        rearShapeLayer.name = "Rear"
        rearShapeLayer.path = rearPath.cgPath
        rearShapeLayer.fillColor = lightColor.cgColor
        rearShapeLayer.position = CGPoint(x: 0, y: 0)

        bottomInnerContainerView2.layer.insertSublayer(rearShapeLayer, below: bottomInnerImageBackgroundView2.layer)

        // Create a new path for the dark front part
        let frontPath = UIBezierPath()

        // Starting point for the path
        frontPath.move(to: CGPoint(x: 0, y: 0))
        frontPath.addLine(to: CGPoint(x: 56, y: 0))
        frontPath.addLine(to: CGPoint(x: 40, y: bottomInnerContainerView2.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: bottomInnerContainerView2.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: 0))
        frontPath.close()
        
        // Create a CAShapeLayer
        let frontShapeLayer = CAShapeLayer()
        frontShapeLayer.name = "Front"
        frontShapeLayer.path = frontPath.cgPath
        frontShapeLayer.fillColor = color.cgColor
        frontShapeLayer.position = CGPoint(x: 0, y: 0)

        bottomInnerContainerView2.layer.insertSublayer(frontShapeLayer, above: rearShapeLayer)
    }
    
    private func highlightBottomCell3(color: UIColor)
    {
        bottomRankingLabel3.textColor = UIColor.mpWhiteColor()
        bottomSchoolNameLabel3.textColor = UIColor.mpBlackColor()
        bottomWinLossLabel3.textColor = UIColor.mpBlackColor()
        bottomPercentageLabel3.textColor = UIColor.mpBlackColor()
        bottomRankingLabel3.font = UIFont.mpBoldFontWith(size: 13)
        bottomSchoolNameLabel3.font = UIFont.mpBoldFontWith(size: 13)
        bottomWinLossLabel3.font = UIFont.mpBoldFontWith(size: 13)
        bottomPercentageLabel3.font = UIFont.mpBoldFontWith(size: 13)
        /*
        // Add a shadow to the image background
        bottomInnerImageBackgroundView3.layer.masksToBounds = false
        bottomInnerImageBackgroundView3.layer.shadowColor = UIColor(white: 0.7, alpha: 1.0).cgColor
        bottomInnerImageBackgroundView3.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        bottomInnerImageBackgroundView3.layer.shadowRadius = 2
        bottomInnerImageBackgroundView3.layer.shadowOpacity = 0.5
        */
        bottomInnerImageBackgroundView3.layer.borderWidth = 1
        bottomInnerImageBackgroundView3.layer.borderColor = UIColor.mpOffWhiteNavColor().cgColor
        
        // Create a new path for the rear light part
        let rearPath = UIBezierPath()

        // Starting point for the path
        rearPath.move(to: CGPoint(x: 0, y: 0))
        rearPath.addLine(to: CGPoint(x: 71, y: 0))
        rearPath.addLine(to: CGPoint(x: 43, y: bottomInnerContainerView3.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: bottomInnerContainerView3.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: 0))
        rearPath.close()
        
        // Create a CAShapeLayer
        //let lightColor = color.lighter(by: 70.0)
        let lightColor = color.withAlphaComponent(0.3)
        let rearShapeLayer = CAShapeLayer()
        rearShapeLayer.name = "Rear"
        rearShapeLayer.path = rearPath.cgPath
        rearShapeLayer.fillColor = lightColor.cgColor
        rearShapeLayer.position = CGPoint(x: 0, y: 0)

        bottomInnerContainerView3.layer.insertSublayer(rearShapeLayer, below: bottomInnerImageBackgroundView3.layer)

        // Create a new path for the dark front part
        let frontPath = UIBezierPath()

        // Starting point for the path
        frontPath.move(to: CGPoint(x: 0, y: 0))
        frontPath.addLine(to: CGPoint(x: 56, y: 0))
        frontPath.addLine(to: CGPoint(x: 40, y: bottomInnerContainerView3.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: bottomInnerContainerView3.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: 0))
        frontPath.close()
        
        // Create a CAShapeLayer
        let frontShapeLayer = CAShapeLayer()
        frontShapeLayer.name = "Front"
        frontShapeLayer.path = frontPath.cgPath
        frontShapeLayer.fillColor = color.cgColor
        frontShapeLayer.position = CGPoint(x: 0, y: 0)

        bottomInnerContainerView3.layer.insertSublayer(frontShapeLayer, above: rearShapeLayer)
    }
    
    // MARK: - Load Sections
    
    private func loadTopSection(_ section: Dictionary<String,Any>, genderCommaSport: String)
    {
        let headerName = section["headerName"] as! String
        topTitleLabel.text = headerName
        
        let standings = section["standings"] as! Array<Dictionary<String,Any>>
        
        if (standings.count > 0)
        {
            let team = standings[0]
            
            let schoolName = team["schoolName"] as! String
            if (schoolName.count > 15)
            {
                let acronym = team["schoolNameAcronym"] as! String
                topSchoolNameLabel1.text = acronym
            }
            else
            {
                topSchoolNameLabel1.text = schoolName
            }
            
            topInitialLabel1.text = String(schoolName.prefix(1)).uppercased()
            let colorString = team["schoolColor1"] as! String
            topInitialLabel1.textColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
            
            let ranking = team["conferenceStandingPlacement"] as? Int ?? -1
            if (ranking == -1)
            {
                topRankingLabel1.text = "--"
            }
            else
            {
                topRankingLabel1.text = String(ranking)
            }
            
            let winLoss = team["conferenceWinLossTies"] as! String
            topWinLossLabel1.text = winLoss
            
            let percentage = team["conferenceWinningPercentage"] as! Double
            topPercentageLabel1.text = String(format: "%1.2f", percentage)
            
            let mascotUrl = team["schoolMascotUrl"] as? String ?? ""
            
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
                            self.topInitialLabel1.isHidden = true
                            //self.topMascotImage1.image = image
                            MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.topMascotImage1)!)
                        }
                    }
                }
            }
            
            // Check if this cell should be highlighted
            let schoolId = team["schoolId"] as! String
            let identifier = String(format: "%@_%@", schoolId, genderCommaSport)
            
            let result = favoriteTeamIdentifierArray.filter { $0 == identifier }
            if (!result.isEmpty)
            {
                self.highlightTopCell1(color:topInitialLabel1.textColor)
            }
                        
            if (standings.count > 1)
            {
                let team = standings[1]
                
                let schoolName = team["schoolName"] as! String
                if (schoolName.count > 15)
                {
                    let acronym = team["schoolNameAcronym"] as! String
                    topSchoolNameLabel2.text = acronym
                }
                else
                {
                    topSchoolNameLabel2.text = schoolName
                }
                
                topInitialLabel2.text = String(schoolName.prefix(1)).uppercased()
                let colorString = team["schoolColor1"] as! String
                topInitialLabel2.textColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
                
                let ranking = team["conferenceStandingPlacement"] as? Int ?? -1
                if (ranking == -1)
                {
                    topRankingLabel2.text = "--"
                }
                else
                {
                    topRankingLabel2.text = String(ranking)
                }
                
                let winLoss = team["conferenceWinLossTies"] as! String
                topWinLossLabel2.text = winLoss
                
                let percentage = team["conferenceWinningPercentage"] as! Double
                topPercentageLabel2.text = String(format: "%1.2f", percentage)
                
                let mascotUrl = team["schoolMascotUrl"] as? String ?? ""
                
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
                                self.topInitialLabel2.isHidden = true
                                //self.topMascotImage2.image = image
                                MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.topMascotImage2)!)
                            }
                        }
                    }
                }
                
                // Check if this cell should be highlighted
                let schoolId = team["schoolId"] as! String
                let identifier = String(format: "%@_%@", schoolId, genderCommaSport)
                
                let result = favoriteTeamIdentifierArray.filter { $0 == identifier }
                if (!result.isEmpty)
                {
                    self.highlightTopCell2(color:topInitialLabel2.textColor)
                }
                
                if (standings.count > 2)
                {
                    let team = standings[2]
                    
                    let schoolName = team["schoolName"] as! String
                    if (schoolName.count > 15)
                    {
                        let acronym = team["schoolNameAcronym"] as! String
                        topSchoolNameLabel3.text = acronym
                    }
                    else
                    {
                        topSchoolNameLabel3.text = schoolName
                    }
                    
                    topInitialLabel3.text = String(schoolName.prefix(1)).uppercased()
                    let colorString = team["schoolColor1"] as! String
                    topInitialLabel3.textColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
                    
                    let ranking = team["conferenceStandingPlacement"] as? Int ?? -1
                    if (ranking == -1)
                    {
                        topRankingLabel3.text = "--"
                    }
                    else
                    {
                        topRankingLabel3.text = String(ranking)
                    }
                    
                    let winLoss = team["conferenceWinLossTies"] as! String
                    topWinLossLabel3.text = winLoss
                    
                    let percentage = team["conferenceWinningPercentage"] as! Double
                    topPercentageLabel3.text = String(format: "%1.2f", percentage)
                    
                    let mascotUrl = team["schoolMascotUrl"] as? String ?? ""
                    
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
                                    self.topInitialLabel3.isHidden = true
                                    //self.topMascotImage3.image = image
                                    MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.topMascotImage3)!)
                                }
                            }
                        }
                    }
                    
                    // Check if this cell should be highlighted
                    let schoolId = team["schoolId"] as! String
                    let identifier = String(format: "%@_%@", schoolId, genderCommaSport)
                    
                    let result = favoriteTeamIdentifierArray.filter { $0 == identifier }
                    if (!result.isEmpty)
                    {
                        self.highlightTopCell3(color:topInitialLabel3.textColor)
                    }
                }
            }
        }
    }
    
    private func loadBottomSection(_ section: Dictionary<String,Any>, genderCommaSport: String)
    {
        let headerName = section["headerName"] as! String
        bottomTitleLabel.text = headerName
        
        let standings = section["standings"] as! Array<Dictionary<String,Any>>
        
        if (standings.count > 0)
        {
            let team = standings[0]
            
            let schoolName = team["schoolName"] as! String
            if (schoolName.count > 15)
            {
                let acronym = team["schoolNameAcronym"] as! String
                bottomSchoolNameLabel1.text = acronym
            }
            else
            {
                bottomSchoolNameLabel1.text = schoolName
            }
            
            bottomInitialLabel1.text = String(schoolName.prefix(1)).uppercased()
            let colorString = team["schoolColor1"] as! String
            bottomInitialLabel1.textColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
            
            let ranking = team["overallStandingPlacement"] as? Int ?? -1
            if (ranking == -1)
            {
                bottomRankingLabel1.text = "--"
            }
            else
            {
                bottomRankingLabel1.text = String(ranking)
            }
            
            let winLoss = team["overallWinLossTies"] as! String
            bottomWinLossLabel1.text = winLoss
            
            let percentage = team["winningPercentage"] as! Double
            bottomPercentageLabel1.text = String(format: "%1.2f", percentage)
            
            let mascotUrl = team["schoolMascotUrl"] as? String ?? ""
            
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
                            self.bottomInitialLabel1.isHidden = true
                            //self.bottomMascotImage1.image = image
                            MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.bottomMascotImage1)!)
                        }
                    }
                }
            }
            
            // Check if this cell should be highlighted
            let schoolId = team["schoolId"] as! String
            let identifier = String(format: "%@_%@", schoolId, genderCommaSport)
            
            let result = favoriteTeamIdentifierArray.filter { $0 == identifier }
            if (!result.isEmpty)
            {
                self.highlightBottomCell1(color:bottomInitialLabel1.textColor)
            }
                        
            if (standings.count > 1)
            {
                let team = standings[1]
                
                let schoolName = team["schoolName"] as! String
                if (schoolName.count > 15)
                {
                    let acronym = team["schoolNameAcronym"] as! String
                    bottomSchoolNameLabel2.text = acronym
                }
                else
                {
                    bottomSchoolNameLabel2.text = schoolName
                }
                
                bottomInitialLabel2.text = String(schoolName.prefix(1)).uppercased()
                let colorString = team["schoolColor1"] as! String
                bottomInitialLabel2.textColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
                
                let ranking = team["overallStandingPlacement"] as? Int ?? -1
                if (ranking == -1)
                {
                    bottomRankingLabel2.text = "--"
                }
                else
                {
                    bottomRankingLabel2.text = String(ranking)
                }
                
                let winLoss = team["overallWinLossTies"] as! String
                bottomWinLossLabel2.text = winLoss
                
                let percentage = team["winningPercentage"] as! Double
                bottomPercentageLabel2.text = String(format: "%1.2f", percentage)
                
                let mascotUrl = team["schoolMascotUrl"] as? String ?? ""
                
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
                                self.bottomInitialLabel2.isHidden = true
                                //self.bottomMascotImage2.image = image
                                MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.bottomMascotImage2)!)
                            }
                        }
                    }
                }
                
                // Check if this cell should be highlighted
                let schoolId = team["schoolId"] as! String
                let identifier = String(format: "%@_%@", schoolId, genderCommaSport)
                
                let result = favoriteTeamIdentifierArray.filter { $0 == identifier }
                if (!result.isEmpty)
                {
                    self.highlightBottomCell2(color:bottomInitialLabel2.textColor)
                }
                
                if (standings.count > 2)
                {
                    let team = standings[2]
                    
                    let schoolName = team["schoolName"] as! String
                    if (schoolName.count > 15)
                    {
                        let acronym = team["schoolNameAcronym"] as! String
                        bottomSchoolNameLabel3.text = acronym
                    }
                    else
                    {
                        bottomSchoolNameLabel3.text = schoolName
                    }
                    
                    bottomInitialLabel3.text = String(schoolName.prefix(1)).uppercased()
                    let colorString = team["schoolColor1"] as! String
                    bottomInitialLabel3.textColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
                    
                    let ranking = team["overallStandingPlacement"] as? Int ?? -1
                    if (ranking == -1)
                    {
                        bottomRankingLabel3.text = "--"
                    }
                    else
                    {
                        bottomRankingLabel3.text = String(ranking)
                    }
                    
                    let winLoss = team["overallWinLossTies"] as! String
                    bottomWinLossLabel3.text = winLoss
                    
                    let percentage = team["winningPercentage"] as! Double
                    bottomPercentageLabel3.text = String(format: "%1.2f", percentage)
                    
                    let mascotUrl = team["schoolMascotUrl"] as? String ?? ""
                    
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
                                    self.bottomInitialLabel3.isHidden = true
                                    //self.bottomMascotImage3.image = image
                                    MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.bottomMascotImage3)!)
                                }
                            }
                        }
                    }
                    
                    // Check if this cell should be highlighted
                    let schoolId = team["schoolId"] as! String
                    let identifier = String(format: "%@_%@", schoolId, genderCommaSport)
                    
                    let result = favoriteTeamIdentifierArray.filter { $0 == identifier }
                    if (!result.isEmpty)
                    {
                        self.highlightBottomCell3(color:bottomInitialLabel3.textColor)
                    }
                }
            }
        }
    }
    
    // MARK: - Load Data
    
    func loadData(_ data: Dictionary<String,Any>)
    {
        // Clear out the fields
        self.clearFields()
        
        let genderSport = data["genderSport"] as! String
        let genderSportArray = genderSport.components(separatedBy: ",")
        if (genderSportArray.count == 2)
        {
            let gender = genderSportArray.first
            let sport = genderSportArray.last
    
            topSportLabel.text = String(format: "Varsity %@", MiscHelper.genderSportFrom(gender: gender!, sport: sport!))
            
            topSportIconImageView.image = MiscHelper.getImageForSport(sport!)
        }
        else
        {
            topSportLabel.text = "Unknown Gender Sport"
            topSportIconImageView.image = nil
        }
        
        // Load the sections
        let standingSections = data["standingSections"] as! Array<Dictionary<String,Any>>
        
        topContainerView.isHidden = true
        bottomContainerView.isHidden = true
        
        if (standingSections.count == 1)
        {
            bottomContainerOverlayView.isHidden = false
        }
        else
        {
            bottomContainerOverlayView.isHidden = true
        }
        
        if (standingSections.count > 0)
        {
            topContainerView.isHidden = false
            bottomContainerView.isHidden = false
            let topSection = standingSections[0]
            
            self.loadTopSection(topSection, genderCommaSport: genderSport)
            
            if (standingSections.count > 1)
            {
                
                let bottomSection = standingSections[1]
                
                self.loadBottomSection(bottomSection, genderCommaSport: genderSport)
            }
        }
        
        
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // Change the color from the xib layout color
        topContainerView.backgroundColor = UIColor.mpWhiteColor()
        bottomContainerView.backgroundColor = UIColor.mpWhiteColor()
        
        topContainerView.layer.cornerRadius = 12
        topContainerView.layer.borderWidth = 1
        topContainerView.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        topContainerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        topContainerView.clipsToBounds = true
        
        bottomContainerView.layer.cornerRadius = 12
        bottomContainerView.layer.borderWidth = 1
        bottomContainerView.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        bottomContainerView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        bottomContainerView.clipsToBounds = true
        
        topInnerImageBackgroundView1.layer.cornerRadius = 14
        topInnerImageBackgroundView1.clipsToBounds = true
        
        topInnerImageBackgroundView2.layer.cornerRadius = 14
        topInnerImageBackgroundView2.clipsToBounds = true
        
        topInnerImageBackgroundView3.layer.cornerRadius = 14
        topInnerImageBackgroundView3.clipsToBounds = true
        
        bottomInnerImageBackgroundView1.layer.cornerRadius = 14
        bottomInnerImageBackgroundView1.clipsToBounds = true
        
        bottomInnerImageBackgroundView2.layer.cornerRadius = 14
        bottomInnerImageBackgroundView2.clipsToBounds = true
        
        bottomInnerImageBackgroundView3.layer.cornerRadius = 14
        bottomInnerImageBackgroundView3.clipsToBounds = true
        
        // Build attributed text
        let title = "No standings available for Section or Division. If this is incorrect, please contact support with the correction."
        
        let attributedString = NSMutableAttributedString(string: title)
        
        // MP Blue
        let range1 = title.range(of: "support")
        let convertedRange1 = NSRange(range1!, in: title)

        attributedString.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.mpBlueColor()], range: convertedRange1)
        
        bottomContainerOverlayLabel.attributedText = attributedString
    }

}
