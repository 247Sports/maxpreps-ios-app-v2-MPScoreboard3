//
//  TeamVideoToolTipViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 1/27/23.
//

import UIKit

protocol TeamVideoToolTipDelegate: AnyObject
{
    func teamVideoToolTipDidCancel()
}

class TeamVideoToolTipViewController: UIViewController
{
    weak var delegate: TeamVideoToolTipDelegate?
    
    @IBOutlet weak var containerView: UIView!
        
    // MARK: - Button Methods
    
    @IBAction func closeButtonTouched()
    {
        UIView.animate(withDuration: 0.33, animations: {
            
            self.view.backgroundColor = .clear
            self.containerView.alpha = 0.01
            
        })
        { (finished) in
            
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: true), forKey: kTeamVideoToolTipShownKey)
            
            //self.dismiss(animated: false)
            self.delegate?.teamVideoToolTipDidCancel()
        }
        
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.view.backgroundColor = .clear
        
        containerView.frame = CGRect(x: kDeviceWidth - 367.0, y: CGFloat(kStatusBarHeight + SharedData.topNotchHeight) + 16.0, width: 371.0, height: 130.0)
        containerView.backgroundColor = .clear
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
            
            self.view.backgroundColor = UIColor.init(white: 0, alpha: 0.25)
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
