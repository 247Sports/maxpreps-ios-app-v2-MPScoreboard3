//
//  TeamHomeSchoolInfoTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/2/22.
//

import UIKit

class TeamHomeSchoolInfoTableViewCell: UITableViewCell
{
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var colorPillOne: UIView!
    @IBOutlet weak var colorPillTwo: UIView!
    @IBOutlet weak var colorPillThree: UIView!
    @IBOutlet weak var mascotNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationButton: UIButton!
    
    // MARK: - Load Data
    
    func loadData(color1: String, color2: String, color3: String, schoolCity: String, schoolState: String, mascotName: String)
    {
        colorPillOne.isHidden = true
        colorPillTwo.isHidden = true
        colorPillThree.isHidden = true
        
        let fixedColor1 = color1.components(separatedBy: .whitespacesAndNewlines).joined()
        let fixedColor2 = color2.components(separatedBy: .whitespacesAndNewlines).joined()
        let fixedColor3 = color3.components(separatedBy: .whitespacesAndNewlines).joined()
        
        if (fixedColor1.count > 0)
        {
            colorPillOne.isHidden = false
            colorPillOne.backgroundColor = ColorHelper.color(fromHexString: fixedColor1, colorCorrection: true)
        }
        
        if (fixedColor2.count > 0)
        {
            colorPillTwo.isHidden = false
            colorPillTwo.backgroundColor = ColorHelper.color(fromHexString: fixedColor2, colorCorrection: false)
        }
        
        if (fixedColor3.count > 0)
        {
            colorPillThree.isHidden = false
            colorPillThree.backgroundColor = ColorHelper.color(fromHexString: fixedColor3, colorCorrection: false)
        }
        
        mascotNameLabel.text = mascotName
        locationLabel.text = String(format: "%@, %@", schoolCity, schoolState)
        
        self.colorizeCell(color1: fixedColor1, color2: fixedColor2)
    }
    
    // MARK: - Colorize Cell
    
    private func colorizeCell(color1: String, color2: String)
    {
        // Override the colors if they don't exist
        var primaryColor = UIColor.mpRedColor()
        var secondaryColor = UIColor.gray
        
        if (color1.count > 0)
        {
            primaryColor = ColorHelper.color(fromHexString: color1, colorCorrection: true)
        }
        
        if (color2.count > 0)
        {
            secondaryColor = ColorHelper.color(fromHexString: color2, colorCorrection: true)
        }
        
        // Create a new path for the rear part
        let rearPath = UIBezierPath() // 135 - 78

        // Starting point for the path
        rearPath.move(to: CGPoint(x: kDeviceWidth, y: 0))
        rearPath.addLine(to: CGPoint(x: kDeviceWidth, y: innerContainerView.frame.size.height))
        rearPath.addLine(to: CGPoint(x: kDeviceWidth - 135, y: innerContainerView.frame.size.height))
        rearPath.addLine(to: CGPoint(x: kDeviceWidth - 78, y: 0))
        rearPath.addLine(to: CGPoint(x: kDeviceWidth, y: 0))
        rearPath.close()
        
        // Create a CAShapeLayer
        let rearShapeLayer = CAShapeLayer()
        rearShapeLayer.name = "Rear"
        rearShapeLayer.path = rearPath.cgPath
        rearShapeLayer.fillColor = secondaryColor.cgColor
        rearShapeLayer.position = CGPoint(x: 0, y: 0)

        innerContainerView.layer.addSublayer(rearShapeLayer)
        
        // Create a new path for the front part
        let frontPath = UIBezierPath() // 98 - 68

        // Starting point for the path
        frontPath.move(to: CGPoint(x: kDeviceWidth, y: 0))
        frontPath.addLine(to: CGPoint(x: kDeviceWidth, y: innerContainerView.frame.size.height))
        frontPath.addLine(to: CGPoint(x: kDeviceWidth - 98, y: innerContainerView.frame.size.height))
        frontPath.addLine(to: CGPoint(x: kDeviceWidth - 68, y: 0))
        frontPath.addLine(to: CGPoint(x: kDeviceWidth, y: 0))
        frontPath.close()
        
        // Create a CAShapeLayer
        let frontShapeLayer = CAShapeLayer()
        frontShapeLayer.name = "Front"
        frontShapeLayer.path = frontPath.cgPath
        frontShapeLayer.fillColor = primaryColor.cgColor
        frontShapeLayer.position = CGPoint(x: 0, y: 0)

        innerContainerView.layer.insertSublayer(frontShapeLayer, above: rearShapeLayer)
        
        // Create a path for the transparent overlay
        let overlayPath = UIBezierPath() // 80 - 24

        // Starting point for the path
        overlayPath.move(to: CGPoint(x: kDeviceWidth, y: 0))
        overlayPath.addLine(to: CGPoint(x: kDeviceWidth, y: innerContainerView.frame.size.height))
        overlayPath.addLine(to: CGPoint(x: kDeviceWidth - 80, y: innerContainerView.frame.size.height))
        overlayPath.addLine(to: CGPoint(x: kDeviceWidth - 24, y: 0))
        overlayPath.addLine(to: CGPoint(x: kDeviceWidth, y: 0))
        overlayPath.close()
        
        // Create a CAShapeLayer
        let overlayShapeLayer = CAShapeLayer()
        overlayShapeLayer.name = "Overlay"
        overlayShapeLayer.path = overlayPath.cgPath
        //overlayShapeLayer.fillColor = primaryColor.darker(by: 20)?.cgColor
        overlayShapeLayer.fillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        overlayShapeLayer.position = CGPoint(x: 0, y: 0)

        innerContainerView.layer.insertSublayer(overlayShapeLayer, above: frontShapeLayer)
        
        // Add one final shape with drop shadows
        let shadowPath = UIBezierPath()
        
        // Starting point for the path
        shadowPath.move(to: CGPoint(x: kDeviceWidth - 26, y: 0))
        shadowPath.addLine(to: CGPoint(x: kDeviceWidth - 82, y: innerContainerView.frame.size.height))
        shadowPath.addLine(to: CGPoint(x: kDeviceWidth - 98, y: innerContainerView.frame.size.height))
        shadowPath.addLine(to: CGPoint(x: kDeviceWidth - 68, y: 0))
        shadowPath.addLine(to: CGPoint(x: kDeviceWidth - 26, y: 0))
        shadowPath.close()
        
        // Create a CAShapeLayer
        let shadowShapeLayer = CAShapeLayer()
        shadowShapeLayer.name = "Shadow"
        shadowShapeLayer.path = shadowPath.cgPath
        shadowShapeLayer.fillColor = primaryColor.cgColor
        shadowShapeLayer.position = CGPoint(x: 0, y: 0)
        shadowShapeLayer.shadowColor = UIColor.mpBlackColor().cgColor
        shadowShapeLayer.shadowRadius = 6.0
        shadowShapeLayer.shadowOpacity = 0.5
        shadowShapeLayer.shadowOffset = CGSize(width: 0, height: 0)

        innerContainerView.layer.insertSublayer(shadowShapeLayer, above: frontShapeLayer)
        
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        innerContainerView.layer.cornerRadius = 12
        innerContainerView.clipsToBounds = true
        
        colorPillOne.layer.cornerRadius = colorPillOne.frame.size.height / 2.0
        colorPillOne.layer.borderWidth = 1
        colorPillOne.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        colorPillOne.clipsToBounds = true
        
        colorPillTwo.layer.cornerRadius = colorPillTwo.frame.size.height / 2.0
        colorPillTwo.layer.borderWidth = 1
        colorPillTwo.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        colorPillTwo.clipsToBounds = true
        
        colorPillThree.layer.cornerRadius = colorPillThree.frame.size.height / 2.0
        colorPillThree.layer.borderWidth = 1
        colorPillThree.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        colorPillThree.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
