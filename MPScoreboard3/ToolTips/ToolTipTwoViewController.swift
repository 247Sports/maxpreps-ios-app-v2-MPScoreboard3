//
//  ToolTipTwoViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/20/22.
//

import UIKit

class ToolTipTwoViewController: UIViewController
{
    @IBOutlet weak var containerView: UIView!
    
    var rankingsView = false
    
    // MARK: - Button Methods
    
    @IBAction func closeButtonTouched()
    {
        UIView.animate(withDuration: 0.33, animations: {
            
            self.view.backgroundColor = .clear
            self.containerView.alpha = 0.01
            
        })
        { (finished) in
            
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: true), forKey: kToolTipTwoShownKey)
            
            self.dismiss(animated: false)
        }
    }
    
    // MARK: - Background Hole Method
    
    private func addRoundBackgroundHole(xOffset: CGFloat, yOffset: CGFloat, radius: CGFloat)
    {
        let path = CGMutablePath()
        path.addArc(center: CGPoint(x: xOffset, y: yOffset),
                        radius: radius,
                        startAngle: 0.0,
                        endAngle: 2.0 * .pi,
                        clockwise: false)
        path.addRect(CGRect(origin: .zero, size: CGSize(width: kDeviceWidth, height: kDeviceHeight)))

        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = .evenOdd
        
        self.view.layer.mask = maskLayer
        self.view.clipsToBounds = true
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.view.backgroundColor = .clear
        
        // Add a hole in the background
        let xOffset = CGFloat(kDeviceWidth - 36)
        let yOffset = CGFloat(kStatusBarHeight + SharedData.topNotchHeight + 176)
        let radius = 28.0
        
        var vertCorrection = 0
        
        if (rankingsView == true)
        {
            vertCorrection = -52
        }
        
        self.addRoundBackgroundHole(xOffset: xOffset, yOffset: yOffset + CGFloat(vertCorrection), radius: radius)
        
        containerView.frame = CGRect(x: Int(kDeviceWidth - 306), y: kStatusBarHeight + SharedData.topNotchHeight + 202 + vertCorrection, width: 300, height: 148)
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        containerView.alpha = 0.01
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
            
        setNeedsStatusBarAppearanceUpdate()
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.33, animations: {
            
            self.view.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
            self.containerView.alpha = 1.0
        })
        { (finished) in
            
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.lightContent
    }
    
    override open var shouldAutorotate: Bool
    {
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation
    {
        return UIInterfaceOrientation.portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        return .portrait
    }
}
