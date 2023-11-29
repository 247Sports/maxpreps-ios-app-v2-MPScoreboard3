//
//  TopNavigationController.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/2/21.
//

import UIKit

class TopNavigationController: UINavigationController
{
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

    }
    
    override var shouldAutorotate: Bool
    {
        return ((self.topViewController?.shouldAutorotate) != nil)
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation
    {
        return self.topViewController!.preferredInterfaceOrientationForPresentation
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        return self.topViewController!.supportedInterfaceOrientations
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle
    {
        if let topVC = viewControllers.last
        {
            //return the status property of each VC, look at step 2
            return topVC.preferredStatusBarStyle
        }

        return .default
    }

}
