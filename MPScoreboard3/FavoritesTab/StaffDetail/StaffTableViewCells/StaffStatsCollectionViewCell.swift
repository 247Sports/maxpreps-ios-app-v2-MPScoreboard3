//
//  StaffStatsCollectionViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/18/21.
//

import UIKit

class StaffStatsCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var topContainerHeaderLabel: UILabel!
    @IBOutlet weak var topContainerTitleLabel: UILabel!
    @IBOutlet weak var topContainerSubtitleLabel: UILabel!
    @IBOutlet weak var topContainerSportIconImageView: UIImageView!
    @IBOutlet weak var athleteImageView: UIImageView!
    @IBOutlet weak var captainIconImageView: UIImageView!
    
    @IBOutlet weak var heightWeightTitleLabel: UILabel!
    @IBOutlet weak var heightWeightLabel: UILabel!
    @IBOutlet weak var jerseyTitleLabel: UILabel!
    @IBOutlet weak var jerseyLabel: UILabel!
    @IBOutlet weak var positionsTitleLabel: UILabel!
    @IBOutlet weak var positionsLabel: UILabel!
    
    @IBOutlet weak var statsTitleLabel1: UILabel!
    @IBOutlet weak var statsLabel1: UILabel!
    @IBOutlet weak var statsTitleLabel2: UILabel!
    @IBOutlet weak var statsLabel2: UILabel!
    @IBOutlet weak var statsTitleLabel3: UILabel!
    @IBOutlet weak var statsLabel3: UILabel!
    @IBOutlet weak var statsTitleLabel4: UILabel!
    @IBOutlet weak var statsLabel4: UILabel!
    @IBOutlet weak var statsTitleLabel5: UILabel!
    @IBOutlet weak var statsLabel5: UILabel!
    @IBOutlet weak var statsTitleLabel6: UILabel!
    @IBOutlet weak var statsLabel6: UILabel!
    @IBOutlet weak var statsTitleLabel7: UILabel!
    @IBOutlet weak var statsLabel7: UILabel!
    
    @IBOutlet weak var fullCareerButton: UIButton!
    
    // MARK: - Draw Shape Layers
    
    func addShapeLayers(color: UIColor)
    {
        // Create a new path for the rear light part
        let rearPath = UIBezierPath()

        // Starting point for the path
        rearPath.move(to: CGPoint(x: 0, y: 0))
        rearPath.addLine(to: CGPoint(x: 62, y: 0))
        rearPath.addLine(to: CGPoint(x: 13, y: topContainerView.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: topContainerView.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: 0))
        rearPath.close()
        
        // Create a CAShapeLayer
        //let lightColor = color.lighter(by: 70.0)
        let lightColor = color.withAlphaComponent(0.3)
        let rearShapeLayer = CAShapeLayer()
        rearShapeLayer.path = rearPath.cgPath
        rearShapeLayer.fillColor = lightColor.cgColor
        rearShapeLayer.position = CGPoint(x: 0, y: 0)

        topContainerView.layer.addSublayer(rearShapeLayer)
        
        // Create a new path for the dark front part
        let frontPath = UIBezierPath()

        // Starting point for the path
        frontPath.move(to: CGPoint(x: 0, y: 0))
        frontPath.addLine(to: CGPoint(x: 45, y: 0))
        frontPath.addLine(to: CGPoint(x: 10, y: topContainerView.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: topContainerView.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: 0))
        frontPath.close()
        
        // Create a CAShapeLayer
        let frontShapeLayer = CAShapeLayer()
        frontShapeLayer.path = frontPath.cgPath
        frontShapeLayer.fillColor = color.cgColor
        frontShapeLayer.position = CGPoint(x: 0, y: 0)

        topContainerView.layer.insertSublayer(frontShapeLayer, above: rearShapeLayer)
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // Add a shadow to the cell
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        //containerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        //containerView.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        //containerView.layer.shadowOpacity = 0.15
        //containerView.layer.shadowRadius = 6.0
        containerView.clipsToBounds = true
        
        topContainerView.layer.cornerRadius = 12
        topContainerView.clipsToBounds = true
        topContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        athleteImageView.layer.cornerRadius = athleteImageView.frame.size.width / 2
        athleteImageView.clipsToBounds = true
    }

}
