//
//  VideoContributionsMoreSelectorView.swift
//  MPScoreboard3
//
//  Created by David Smith on 1/6/23.
//

import UIKit

protocol VideoContributionsMoreSelectorViewDelegate: AnyObject
{
    func videoContributionsMoreSelectorViewDidSelectItem(index: Int)
    func videoContributionsMoreSelectorViewDidCancel()
}

class VideoContributionsMoreSelectorView: UIView
{
    weak var delegate: VideoContributionsMoreSelectorViewDelegate?
    
    private var roundRectView: UIView!
    
    // MARK: - Button Methods
    
    @objc func editButtonTouched()
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
            
            self.delegate?.videoContributionsMoreSelectorViewDidSelectItem(index: 0)
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
            
            self.delegate?.videoContributionsMoreSelectorViewDidSelectItem(index: 1)
        }
    }
    
    @objc func deleteButtonTouched()
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
            
            self.delegate?.videoContributionsMoreSelectorViewDidSelectItem(index: 2)
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
            
            self.delegate?.videoContributionsMoreSelectorViewDidCancel()
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
        
        var yStart = 0.0
        var xStart = 0.0
        
        if ((buttonFrame.origin.y + buttonFrame.size.height + 132.0) < frame.size.height)
        {
            // roundRectView will fit
            yStart = buttonFrame.origin.y + buttonFrame.size.height
            xStart = frame.size.width - 256.0
        }
        else
        {
            // bottom justify the roundRectView and shift left
            yStart = frame.size.height - 132.0 - 24.0
            xStart = frame.size.width - 256.0 - 24.0
        }
        
        roundRectView = UIView(frame: CGRect(x: xStart, y: yStart, width: 240, height: 132))
        roundRectView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        roundRectView.layer.cornerRadius = 12
        roundRectView.layer.masksToBounds = true
        self.addSubview(roundRectView)
        
        // Add the buttons and horiz lines
        let editButton = UIButton(type: .system)
        editButton.frame = CGRect(x: 16, y: 0, width: 224, height: 44)
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitleColor(UIColor.mpBlackColor(), for: .normal)
        editButton.contentHorizontalAlignment = .left
        editButton.titleLabel?.font = UIFont.mpRegularFontWith(size: 17)
        editButton.addTarget(self, action: #selector(editButtonTouched), for: .touchUpInside)
        roundRectView.addSubview(editButton)
        
        let shareButton = UIButton(type: .system)
        shareButton.frame = CGRect(x: 16, y: 44, width: 224, height: 44)
        shareButton.setTitle("Share", for: .normal)
        shareButton.setTitleColor(UIColor.mpBlackColor(), for: .normal)
        shareButton.contentHorizontalAlignment = .left
        shareButton.titleLabel?.font = UIFont.mpRegularFontWith(size: 17)
        shareButton.addTarget(self, action: #selector(shareButtonTouched), for: .touchUpInside)
        roundRectView.addSubview(shareButton)
        
        let deleteButton = UIButton(type: .system)
        deleteButton.frame = CGRect(x: 16, y: 88, width: 224, height: 44)
        deleteButton.setTitle("Delete", for: .normal)
        deleteButton.setTitleColor(UIColor.mpRedColor(), for: .normal)
        deleteButton.contentHorizontalAlignment = .left
        deleteButton.titleLabel?.font = UIFont.mpRegularFontWith(size: 17)
        deleteButton.addTarget(self, action: #selector(deleteButtonTouched), for: .touchUpInside)
        roundRectView.addSubview(deleteButton)
        
        let horizLine1 = UIView(frame: CGRect(x: 0, y: 43, width: 240, height: 1))
        horizLine1.backgroundColor = UIColor.mpGrayButtonBorderColor()
        roundRectView.addSubview(horizLine1)
        
        let horizLine2 = UIView(frame: CGRect(x: 0, y: 87, width: 240, height: 1))
        horizLine2.backgroundColor = UIColor.mpGrayButtonBorderColor()
        roundRectView.addSubview(horizLine2)
        
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
