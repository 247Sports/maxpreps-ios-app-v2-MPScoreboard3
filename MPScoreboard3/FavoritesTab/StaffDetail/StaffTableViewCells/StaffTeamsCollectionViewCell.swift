//
//  StaffTeamsCollectionViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/2/23.
//

import UIKit

class StaffTeamsCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var mascotContainerView: UIView!
    @IBOutlet weak var mascotImageView: UIImageView!
    @IBOutlet weak var initialLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var sportLabel: UILabel!
    @IBOutlet weak var sportIconImageView: UIImageView!
    
    // MARK: - Load Data
    
    func loadData(data: Dictionary<String,Any>)
    {
        // Clear out the cell in case it is recycled
        titleLabel.text = ""
        schoolNameLabel.text = ""
        sportLabel.text = ""
        initialLabel.text = ""
        sportIconImageView.image = nil
        mascotImageView.image = nil
        initialLabel.isHidden = false
        
        let title = data["adminRoleTitle"] as! String
        titleLabel.text = title
        
        let schoolName = data["schoolName"] as! String
        schoolNameLabel.text = schoolName
        
        if (schoolName.count == 0)
        {
            print("Empty School")
        }
        
        let sport = data["sport"] as! String
        sportIconImageView.image = MiscHelper.getImageForSport(sport)
        
        let gender = data["gender"] as! String
        let level = data["teamLevel"] as! String
        
        //sportLabel.text = level.uppercased() + " " + sport.uppercased()
        var genderSportLevel = MiscHelper.genderSportLevelFrom(gender: gender, sport: sport, level: level)
        genderSportLevel = genderSportLevel.replacingOccurrences(of: ".", with: "")
        sportLabel.text = genderSportLevel
        
        let schoolInitial = schoolName.first?.uppercased()
        initialLabel.text = schoolInitial
        let colorString = data["schoolColor1"] as! String
        initialLabel.textColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
        
        let mascotUrl = data["schoolMascotUrl"] as? String ?? ""
        
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
                        self.initialLabel.isHidden = true
                        
                        // Render the mascot using this helper
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.mascotImageView)!)
                    }
                }
            }
        }
    }
    
    // MARK: - Draw Shape Layers
    
    func addShapeLayers(color: UIColor)
    {
        // Clear out the sublayers since the cell might be recycled
        let sublayers = self.containerView.layer.sublayers
        
        for layer in sublayers!
        {
            if ((layer.name == "Front") || (layer.name == "Rear"))
            {
                layer.removeFromSuperlayer()
            }
        }
        
        // Create a new path for the rear light part
        let rearPath = UIBezierPath()

        // Starting point for the path
        rearPath.move(to: CGPoint(x: 0, y: 0))
        rearPath.addLine(to: CGPoint(x: 72, y: 0))
        rearPath.addLine(to: CGPoint(x: 0, y: containerView.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: 0))
        rearPath.close()
        
        // Create a CAShapeLayer
        let darkColor = color.darker(by: 15.0)
        //let lightColor = color.withAlphaComponent(0.3)
        let rearShapeLayer = CAShapeLayer()
        rearShapeLayer.name = "Rear"
        rearShapeLayer.path = rearPath.cgPath
        rearShapeLayer.fillColor = darkColor?.cgColor
        rearShapeLayer.position = CGPoint(x: 0, y: 0)

        self.containerView.layer.insertSublayer(rearShapeLayer, below: self.mascotContainerView.layer)
        
        
        // Create a new path for the dark front part
        let frontPath = UIBezierPath()

        // Starting point for the path
        frontPath.move(to: CGPoint(x: 0, y: 0))
        frontPath.addLine(to: CGPoint(x: 50, y: 0))
        frontPath.addLine(to: CGPoint(x: 0, y: containerView.frame.size.height - 7))
        frontPath.addLine(to: CGPoint(x: 0, y: 0))
        frontPath.close()
        
        // Create a CAShapeLayer
        let frontShapeLayer = CAShapeLayer()
        frontShapeLayer.name = "Front"
        frontShapeLayer.path = frontPath.cgPath
        frontShapeLayer.fillColor = color.cgColor
        frontShapeLayer.position = CGPoint(x: 0, y: 0)

        self.containerView.layer.insertSublayer(frontShapeLayer, above: rearShapeLayer)
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // Add a shadow to the cell
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true

        mascotContainerView.layer.cornerRadius = self.mascotContainerView.frame.size.width / 2.0
        mascotContainerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        mascotContainerView.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        mascotContainerView.layer.shadowOpacity = 1.0
        mascotContainerView.layer.shadowRadius = 4.0
        mascotContainerView.clipsToBounds = false
    }

}
