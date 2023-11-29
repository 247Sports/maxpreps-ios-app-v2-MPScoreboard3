//
//  ToolTipNineViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/23/22.
//

import UIKit

protocol ToolTipNineDelegate: AnyObject
{
    func toolTipNineClosed()
}

class ToolTipNineViewController: UIViewController
{
    weak var delegate: ToolTipNineDelegate?
    
    @IBOutlet weak var containerView: UIView!
        
    // MARK: - Button Methods
    
    @IBAction func closeButtonTouched()
    {
        UIView.animate(withDuration: 0.33, animations: {
            
            self.view.backgroundColor = .clear
            self.containerView.alpha = 0.01
            
        })
        { (finished) in
            
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: true), forKey: kToolTipNineShownKey)
            
            self.delegate?.toolTipNineClosed()
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
        let xOffset = CGFloat(kDeviceWidth - 74)
        let yOffset = CGFloat(kStatusBarHeight + SharedData.topNotchHeight + 23)
        let radius = 26.0
        
        self.addRoundBackgroundHole(xOffset: xOffset, yOffset: yOffset, radius: radius)
        
        containerView.frame = CGRect(x: Int(kDeviceWidth - 380), y: kStatusBarHeight + SharedData.topNotchHeight + 47, width: 355, height: 163)
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
