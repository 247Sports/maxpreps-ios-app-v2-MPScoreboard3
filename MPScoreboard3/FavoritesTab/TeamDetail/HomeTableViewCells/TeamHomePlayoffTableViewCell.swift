//
//  TeamHomePlayoffTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 7/25/23.
//

import UIKit

class TeamHomePlayoffTableViewCell: UITableViewCell
{
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    // MARK: - Load Data
    
    func loadData(title: String, subtitle: String)
    {
        //containerView.backgroundColor = UIColor(red: 0.831, green: 0.686, blue: 0.216, alpha: 1.0)
        // 20% lighter
        containerView.backgroundColor = UIColor(red: 0.997, green: 0.823, blue: 0.259, alpha: 1.0)
        
        // Add a gradient layer
        let leftColor = UIColor(white: 1, alpha: 0.4)
        let rightColor = UIColor(white: 1, alpha: 1)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: kDeviceWidth, height: containerView.frame.size.height)
        gradientLayer.colors = [leftColor.cgColor, rightColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        //gradientLayer.locations = [0.0, 1.0]
        containerView.layer.insertSublayer(gradientLayer, at: 0)
        
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        /*
         layer0.colors = [
         UIColor(red: 0.831, green: 0.686, blue: 0.216, alpha: 0.4).cgColor,
         UIColor(red: 0.831, green: 0.686, blue: 0.216, alpha: 0).cgColor
         ]
         layer0.locations = [0, 1]
         layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
         layer0.endPoint = CGPoint(x: 0.75, y: 0.5)
         layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0.99, b: 0, c: 0, d: 15.16, tx: 0, ty: -7.04))
         layer0.bounds = view.bounds.insetBy(dx: -0.5*view.bounds.size.width, dy: -0.5*view.bounds.size.height)
         layer0.position = view.center
         */
        
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
