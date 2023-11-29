//
//  ToolTipFourViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/20/22.
//

import UIKit

protocol ToolTipFourDelegate: AnyObject
{
    func toolTipFourClosed()
}

class ToolTipFourViewController: UIViewController
{
    weak var delegate: ToolTipFourDelegate?
    
    @IBOutlet weak var containerView: UIView!
        
    // MARK: - Button Methods
    
    @IBAction func closeButtonTouched()
    {
        UIView.animate(withDuration: 0.33, animations: {
            
            self.view.backgroundColor = .clear
            self.containerView.alpha = 0.01
            
        })
        { (finished) in
            
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: true), forKey: kToolTipFourShownKey)
            
            self.delegate?.toolTipFourClosed()
            self.dismiss(animated: false)
        }
    }
    
    // MARK: - Background Hole Methods
    
    private func addRoundRectBackgroundHole(frame: CGRect)
    {
        let path = CGMutablePath()
        path.addRoundedRect(in: frame, cornerWidth: 12, cornerHeight: 12, transform: .identity)
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

        // Add a round rect hole in the background
        let holeFrame = CGRect(x: 4.0, y: CGFloat(kStatusBarHeight + SharedData.topNotchHeight + 138), width: CGFloat(kDeviceWidth - 8), height: 46.0)
        self.addRoundRectBackgroundHole(frame: holeFrame)
        
        containerView.frame = CGRect(x: Int((kDeviceWidth - 300) / 2.0), y: kStatusBarHeight + SharedData.topNotchHeight + 182, width: 304, height: 219)
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
