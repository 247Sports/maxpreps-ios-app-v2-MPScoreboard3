//
//  CareerUploadToolTipViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 1/25/23.
//

import UIKit

protocol CareerUploadToolTipDelegate: AnyObject
{
    func careerUploadToolTipClosed()
}

class CareerUploadToolTipViewController: UIViewController
{
    weak var delegate: CareerUploadToolTipDelegate?
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    private var containerHeight = 0
        
    // MARK: - Button Methods
    
    @IBAction func closeButtonTouched()
    {
        UIView.animate(withDuration: 0.33, animations: {
            
            self.view.backgroundColor = .clear
            //self.containerView.alpha = 0.01
            self.containerView.transform = CGAffineTransform(translationX: 0.0, y: CGFloat(self.containerHeight))
            
        })
        { (finished) in
            
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: true), forKey: kVideoUploadToolTipShownKey)
            
            self.delegate?.careerUploadToolTipClosed()
            self.dismiss(animated: false)
        }
        
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.view.backgroundColor = .clear
        
        // Container height varies depending on the resized backgroundImageView
        let imageHeight = (288.0 / 375.0) * kDeviceWidth
        containerHeight = Int(imageHeight) + 154 + Int(SharedData.bottomSafeAreaHeight)
        
        containerView.frame = CGRect(x: 0, y: kDeviceHeight - CGFloat(containerHeight), width: kDeviceWidth, height: CGFloat(containerHeight))
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        //containerView.alpha = 0.01
        containerView.transform = CGAffineTransform(translationX: 0.0, y: CGFloat(containerHeight))
        
        backgroundImageView.frame = CGRect(x: 0, y: 0, width: kDeviceWidth, height: imageHeight)
        
        messageLabel.frame = CGRect(x: 20.0, y: imageHeight + 24.0, width: kDeviceWidth - 40.0, height: 40.0)
        
        closeButton.frame = CGRect(x: 20, y: imageHeight + 88.0, width: kDeviceWidth - 40.0, height: 36.0)
        closeButton.layer.cornerRadius = 8.0
        closeButton.clipsToBounds = true
        
        
        // Bold the messageLabel text
        let messageText = "Go to your claimed profile's Videos tab to post videos, highlights, and game clips."
        let attributedString = NSMutableAttributedString(string: messageText)
        
        let range = messageText.range(of: "Videos")
        let convertedRange = NSRange(range!, in: messageText)

        attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpBoldFontWith(size: 15)], range: convertedRange)
                    
        messageLabel.attributedText = attributedString
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
            //self.containerView.alpha = 1.0
            self.containerView.transform = .identity
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
