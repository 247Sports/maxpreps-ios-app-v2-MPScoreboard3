//
//  VerticalVideoOverlayView.swift
//  MPScoreboard3
//
//  Created by David Smith on 11/2/23.
//

import UIKit

protocol VerticalVideoTitleOverlayViewDelegate: AnyObject
{
    func overlayViewExpanded(_ expanded: Bool)
}

class VerticalVideoTitleOverlayView: UIView 
{
    weak var delegate: VerticalVideoTitleOverlayViewDelegate?
    
    private var titleLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var bumpTextLabel: UILabel!
    private var expandColapseButton: UIButton!
    
    private var overlayIsExpanded = false
    private var transformHeightCopy = 0.0
    
    // MARK: - Show Bump Text
    
    func enableBumpText(_ enable: Bool)
    {
        bumpTextLabel.isHidden = !enable
        expandColapseButton.isEnabled = !enable
    }
    
    // MARK: - Reset Overlay Method
    
    func resetOverlay()
    {
        overlayIsExpanded = true
        self.expandColapseButtonTouched()
    }
    
    // MARK: - Load Methods
    
    func loadTitleOverlayData(title: String, description: String)
    {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.8
        titleLabel.attributedText = NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        //titleLabel.text = title
        descriptionLabel.text = description
    }
    
    // MARK: - Button Methods
    
    @objc private func expandColapseButtonTouched()
    {
        overlayIsExpanded = !overlayIsExpanded
        
        if (overlayIsExpanded == true)
        {
            UIView.animate(withDuration: 0.2)
            { [self] in
                self.expandColapseButton.transform = CGAffineTransform(rotationAngle: .pi * 0.999)
                self.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
            }
            
            // Let the parent know that the overlay should be transformed
            self.delegate?.overlayViewExpanded(true)
            
            // Resize the description label based upon the text length
            descriptionLabel.numberOfLines = 0
            let height = descriptionLabel.text?.height(withConstrainedWidth: frame.size.width - 32.0, font: UIFont.mpRegularFontWith(size: 14))
            
            // Add a little pad so the label fits better
            if (height! <= transformHeightCopy + 10)
            {
                descriptionLabel.frame = CGRect(x: 16.0, y: 52.0, width: frame.size.width - 32.0, height: height!)
            }
            else
            {
                descriptionLabel.frame = CGRect(x: 16.0, y: 52.0, width: frame.size.width - 32.0, height: transformHeightCopy + 10)
            }
        }
        else
        {
            UIView.animate(withDuration: 0.2)
            { [self] in
                self.expandColapseButton.transform = CGAffineTransformIdentity
                self.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
            }
            
            // Let the parent know that the overlay should be transformed
            self.delegate?.overlayViewExpanded(false)
            
            // Reset the description label
            descriptionLabel.numberOfLines = 1
            descriptionLabel.frame = CGRect(x: 16.0, y: 52.0, width: frame.size.width - 32.0, height: 18.0)
        }
    }
    
    // MARK: - Gesture Methods
    
    @objc func handleTap(sender: UITapGestureRecognizer)
    {
        print("Tap Detected")
        
        //if (overlayIsExpanded == true)
        //{
            self.expandColapseButtonTouched()
        //}
    }
    
    // MARK: - Init Method
    
    init(frame: CGRect, transformHeight: CGFloat)
    {
        super.init(frame: frame)
        
        transformHeightCopy = transformHeight
        
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        /*
        self.backgroundColor = .clear
         
        // Add a gradient layer to the top 75 pixels
        let topColor = UIColor(white: 0, alpha: 0.0)
        let bottomColor = UIColor(white: 0, alpha: 1.0)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: kDeviceWidth, height: 75.0)
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        self.layer.insertSublayer(gradientLayer, at: 0)
        
        // Add a black background below the gradient
        let blackBackground = UIView(frame: CGRect(x: 0, y: 75.0, width: frame.size.width, height: frame.size.height - 75.0))
        blackBackground.backgroundColor = .black
        self.addSubview(blackBackground)
        */
        
        titleLabel = UILabel(frame: CGRect(x: 16.0, y: 16.0, width: frame.size.width - 60.0, height: 32.0))
        titleLabel.textColor = .white
        titleLabel.font = UIFont.mpBoldFontWith(size: 16)
        titleLabel.numberOfLines = 2
        
        self.addSubview(titleLabel)
        
        descriptionLabel = UILabel(frame: CGRect(x: 16.0, y: 52.0, width: frame.size.width - 32.0, height: 18.0))
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.mpRegularFontWith(size: 14)
        descriptionLabel.numberOfLines = 1
        self.addSubview(descriptionLabel)
        
        bumpTextLabel = UILabel(frame: CGRect(x: 16.0, y: 128.0, width: frame.size.width - 32.0, height: 20.0))
        bumpTextLabel.textColor = .white
        bumpTextLabel.font = UIFont.mpRegularFontWith(size: 16)
        bumpTextLabel.numberOfLines = 1
        bumpTextLabel.textAlignment = .center
        bumpTextLabel.text = "Swipe up to see more"
        self.addSubview(bumpTextLabel)
        bumpTextLabel.isHidden = true
        
        expandColapseButton = UIButton(type: .custom)
        expandColapseButton.frame = CGRect(x: frame.size.width - 45, y: 10, width: 40, height: 40)
        expandColapseButton.setImage(UIImage(named: "DownArrowVerticalVideo"), for: .normal)
        expandColapseButton.addTarget(self, action: #selector(expandColapseButtonTouched), for: .touchUpInside)
        self.addSubview(expandColapseButton)
        
        // Add a tap gesture recognizer to the blackBackgroundView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.cancelsTouchesInView = true
        self.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

}
