//
//  ProgressHUD.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/29/22.
//

import UIKit
import NVActivityIndicatorView

class ProgressHUD: NSObject
{
    private var backgroundView: UIView!
    private var activityBackgroundView: UIView!
    private var activityIndicatorView: NVActivityIndicatorView!
    
    let fadeColor = UIColor.init(white: 0.9, alpha: 0.9)
    
    // MARK: - Overlay Methods
    
    func show(animated: Bool)
    {        
        backgroundView = UIView(frame: kAppKeyWindow.bounds)
        backgroundView.backgroundColor = .clear
        kAppKeyWindow.addSubview(backgroundView)
        
        activityBackgroundView = UIView(frame: CGRect(x: (kAppKeyWindow.bounds.width - 80) / 2.0, y: (kAppKeyWindow.bounds.height - 80) * 0.45, width: 80, height: 80))
        activityBackgroundView.backgroundColor = .clear//UIColor.init(white: 0.9, alpha: 1)
        //activityBackgroundView.layer.cornerRadius = 5
        //activityBackgroundView.clipsToBounds = true
        
        backgroundView.addSubview(activityBackgroundView)
        
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: (activityBackgroundView.frame.size.width - 40) / 2.0, y: (activityBackgroundView.frame.size.height - 40) / 2.0, width: 40, height: 40), type: .ballPulse, color: UIColor.mpRedColor(), padding: 0)
        activityBackgroundView.addSubview(activityIndicatorView)
        
        if (animated == true)
        {
            activityIndicatorView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            activityBackgroundView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)

            // Animate the first container to the left
            UIView.animate(withDuration: 0.25, animations: {
                
                self.activityIndicatorView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.activityBackgroundView.transform = CGAffineTransform(scaleX: 1, y: 1)
                
            })
            { (finished) in
                
                self.activityIndicatorView.startAnimating()
            }
        }
        else
        {
            activityIndicatorView.startAnimating()
        }
    }
    
    func hide(animated: Bool)
    {
        activityIndicatorView.stopAnimating()
        
        if (animated == true)
        {
            // Animate the first container to the left
            UIView.animate(withDuration: 0.33, animations: {
                
                self.activityIndicatorView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                self.activityBackgroundView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                
            })
            { (finished) in
                
                self.activityIndicatorView.removeFromSuperview()
                self.activityBackgroundView.removeFromSuperview()
                self.backgroundView.removeFromSuperview()
            }
        }
        else
        {
            activityIndicatorView.removeFromSuperview()
            activityBackgroundView.removeFromSuperview()
            backgroundView.removeFromSuperview()
        }
    }
    
}
