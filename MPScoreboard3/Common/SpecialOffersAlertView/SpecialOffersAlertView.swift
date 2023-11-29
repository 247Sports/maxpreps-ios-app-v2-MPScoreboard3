//
//  SpecialOffersAlertView.swift
//  MPScoreboard3
//
//  Created by David Smith on 12/9/22.
//

import UIKit

protocol SpecialOffersAlertViewDelegate: AnyObject
{
    func specialOffersAlertDoneButtonTouched()
}

class SpecialOffersAlertView: UIView
{
    var blackBackgroundView: UIView!
    var roundRectView: UIView!
    
    weak var delegate: SpecialOffersAlertViewDelegate?
    
    // MARK: - Button Methods
    
    @objc private func doneButtonTouched()
    {
        UIView.animate(withDuration: 0.16, animations: {
            self.blackBackgroundView.alpha = 0.0
            self.roundRectView.transform = CGAffineTransformMakeTranslation(0, (self.frame.size.height / 2.0) + 120.0)
        })
        { (finished) in
            
            self.delegate?.specialOffersAlertDoneButtonTouched()
        }
    }
    
    // MARK: - Init Methods
    
    required init(frame: CGRect, title: String, message: String, buttonTitle: String, buttonBackgroundColor: UIColor, buttonTextColor: UIColor)
    {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        blackBackgroundView = UIView(frame: frame)
        blackBackgroundView.backgroundColor = .black
        blackBackgroundView.alpha = 0.0
        self.addSubview(blackBackgroundView)
        
        roundRectView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 240))
        roundRectView.center = self.center
        roundRectView.backgroundColor = UIColor.mpWhiteColor()
        roundRectView.layer.cornerRadius = 12.0
        roundRectView.clipsToBounds = true
        roundRectView.transform = CGAffineTransformMakeTranslation(0, (frame.size.height / 2.0) + 120.0)
        self.addSubview(roundRectView)

        let watermark = UIImageView(frame: CGRect(x: 0, y: 0, width: 64.0, height: 64.0))
        watermark.center = CGPoint(x: 160.0, y: 45.0)
        watermark.image = UIImage(named: "NCSAWatermark")
        roundRectView.addSubview(watermark)
        
        let titleLabel = UILabel(frame: CGRect(x: 20.0, y: 60.0, width: 280.0, height: 25.0))
        titleLabel.text = title
        titleLabel.font = UIFont.mpBoldFontWith(size: 20.0)
        titleLabel.textColor = UIColor.mpBlackColor()
        titleLabel.textAlignment = .center
        roundRectView.addSubview(titleLabel)
        
        let subtitleLabel = UILabel(frame: CGRect(x: 25.0, y: 90.0, width: 270.0, height: 46.0))
        subtitleLabel.numberOfLines = 2
        subtitleLabel.text = message
        subtitleLabel.font = UIFont.mpRegularFontWith(size: 16.0)
        subtitleLabel.textColor = UIColor.mpBlackColor()
        subtitleLabel.textAlignment = .center
        roundRectView.addSubview(subtitleLabel)
        
        let doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: 20.0, y: 163.0, width: 280.0, height: 36.0)
        doneButton.backgroundColor = buttonBackgroundColor
        doneButton.titleLabel?.font = UIFont.mpBoldFontWith(size: 14)
        doneButton.setTitle(buttonTitle, for: .normal)
        doneButton.setTitleColor(buttonTextColor, for: .normal)
        doneButton.layer.cornerRadius = 18
        doneButton.clipsToBounds = true
        doneButton.addTarget(self, action: #selector(doneButtonTouched), for: .touchUpInside)
        roundRectView.addSubview(doneButton)
        
        // Animate
        UIView.animate(withDuration: 0.33, animations: {
            self.blackBackgroundView.alpha = 0.6
            self.roundRectView.transform = CGAffineTransformMakeTranslation(0, 0)
        })
        { (finished) in
            
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

}
