//
//  TeamVideoExtrasSelectorView.swift
//  MPScoreboard3
//
//  Created by David Smith on 1/30/23.
//

import UIKit

protocol TeamVideoExtrasSelectorViewDelegate: AnyObject
{
    func teamVideoExtrasSelectorViewDidSelectItem(index: Int)
    func teamVideoExtrasSelectorViewDidCancel()
}

class TeamVideoExtrasSelectorView: UIView
{
    weak var delegate: TeamVideoExtrasSelectorViewDelegate?
    
    private var roundRectView: UIView!
    
    // MARK: - Button Methods
    
    @objc func reportButtonTouched()
    {
        // Animate back
        let scaleTransform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        let translateTransform = CGAffineTransform(translationX: (roundRectView.frame.size.width / 2.0), y: -roundRectView.frame.size.height / 2.0)
        
        UIView.animate(withDuration: 0.33, animations: {
            
            // Return to the button location
            self.roundRectView.alpha = 0
            self.roundRectView.transform = CGAffineTransformConcat(scaleTransform, translateTransform)
        })
        { (finished) in
            
            self.delegate?.teamVideoExtrasSelectorViewDidSelectItem(index: 1)
        }
    }
    
    @objc func shareButtonTouched()
    {
        // Animate back
        let scaleTransform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        let translateTransform = CGAffineTransform(translationX: (roundRectView.frame.size.width / 2.0), y: -roundRectView.frame.size.height / 2.0)
        
        UIView.animate(withDuration: 0.33, animations: {
            
            // Return to the button location
            self.roundRectView.alpha = 0
            self.roundRectView.transform = CGAffineTransformConcat(scaleTransform, translateTransform)
        })
        { (finished) in
            
            self.delegate?.teamVideoExtrasSelectorViewDidSelectItem(index: 0)
        }
    }
    
    // MARK: - Gesture Methods
    
    @objc func handleTap(sender: UITapGestureRecognizer)
    {
        // Animate back
        let scaleTransform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        let translateTransform = CGAffineTransform(translationX: (roundRectView.frame.size.width / 2.0), y: -roundRectView.frame.size.height / 2.0)
        
        UIView.animate(withDuration: 0.33, animations: {
            
            // Return to the button location
            self.roundRectView.alpha = 0
            self.roundRectView.transform = CGAffineTransformConcat(scaleTransform, translateTransform)
        })
        { (finished) in
            
            self.delegate?.teamVideoExtrasSelectorViewDidCancel()
        }
    }
    
    // MARK: - Init Methods
    
    required init(frame: CGRect, buttonFrame: CGRect)
    {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        let clearBackgroundView = UIView(frame: frame)
        clearBackgroundView.backgroundColor = .clear
        self.addSubview(clearBackgroundView)
        
        // Add a tap gesture recognizer to the blackBackgroundView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        clearBackgroundView.addGestureRecognizer(tapGesture)
        
        roundRectView = UIView(frame: CGRect(x: frame.size.width - 270.0, y: buttonFrame.origin.y + buttonFrame.size.height, width: 254, height: 92))
        roundRectView.backgroundColor = UIColor(white: 0.20, alpha: 1)
        roundRectView.layer.cornerRadius = 12
        roundRectView.layer.masksToBounds = true
        self.addSubview(roundRectView)
        
        // Add the icons
        let shareIcon = UIImageView(frame: CGRect(x: 214.0, y: 11.0, width: 24.0, height: 24.0))
        shareIcon.image = UIImage(named: "ShareIconWhite")
        roundRectView.addSubview(shareIcon)
        
        let flagIcon = UIImageView(frame: CGRect(x: 214.0, y: 57.0, width: 24.0, height: 24.0))
        flagIcon.image = UIImage(named: "FlagIconWhite")
        roundRectView.addSubview(flagIcon)
        
        // Add the buttons and horiz lines
        let shareButton = UIButton(type: .system)
        shareButton.frame = CGRect(x: 16, y: 0, width: 238, height: 46)
        shareButton.setTitle("Share Video", for: .normal)
        shareButton.setTitleColor(UIColor.mpWhiteColor(), for: .normal)
        shareButton.contentHorizontalAlignment = .left
        shareButton.titleLabel?.font = UIFont.mpRegularFontWith(size: 17)
        shareButton.addTarget(self, action: #selector(shareButtonTouched), for: .touchUpInside)
        roundRectView.addSubview(shareButton)
        
        let reportButton = UIButton(type: .system)
        reportButton.frame = CGRect(x: 16, y: 46, width: 238, height: 46)
        reportButton.setTitle("Report Video", for: .normal)
        reportButton.setTitleColor(UIColor.mpWhiteColor(), for: .normal)
        reportButton.contentHorizontalAlignment = .left
        reportButton.titleLabel?.font = UIFont.mpRegularFontWith(size: 17)
        reportButton.addTarget(self, action: #selector(reportButtonTouched), for: .touchUpInside)
        roundRectView.addSubview(reportButton)
        
        let horizLine1 = UIView(frame: CGRect(x: 0, y: 45, width: 270, height: 1))
        horizLine1.backgroundColor = UIColor(white: 0.30, alpha: 1)
        horizLine1.alpha = 0.5
        roundRectView.addSubview(horizLine1)
        
        // Transform and shrink the view to the button location
        let scaleTransform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        //let translateTransform = CGAffineTransform(translationX: (frame.size.width / 2.0) - 24.0, y: -roundRectView.frame.size.height / 2.0)
        let translateTransform = CGAffineTransform(translationX: (roundRectView.frame.size.width / 2.0), y: -roundRectView.frame.size.height / 2.0)
        roundRectView.transform = CGAffineTransformConcat(scaleTransform, translateTransform)
        roundRectView.alpha = 0
 
        // Animate to full size and rotate the button
        UIView.animate(withDuration: 0.33, animations: {
            
            self.roundRectView.alpha = 1.0
            self.roundRectView.transform = .identity
        })
        { (finished) in
            
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

}
