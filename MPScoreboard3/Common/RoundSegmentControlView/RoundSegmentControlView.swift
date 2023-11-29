//
//  RoundSegmentControlView.swift
//  MPScoreboard3
//
//  Created by David Smith on 12/23/21.
//

import UIKit

protocol RoundSegmentControlViewDelegate: AnyObject
{
    func segmentChanged()
}

class RoundSegmentControlView: UIView
{
    var selectedSegment = 0
    weak var delegate: RoundSegmentControlViewDelegate?
    
    var segmentWidth = 0.0
    
    var labelOne : UILabel?
    var labelTwo : UILabel?
    var buttonOne : UIButton?
    var buttonTwo : UIButton?
    var indicatorView : UIView?
    
    /*
    let kSegmentOnColor = UIColor.mpWhiteColor()
    let kSegmentOffColor = UIColor.mpWhiteAlpha80Color()
    let kSegmentOnColorLightTheme = UIColor.mpBlackColor()
    let kSegmentOffColorLightTheme = UIColor.mpLightGrayColor()
     */
    // MARK: Init Methods
    
    required init(frame: CGRect, buttonOneTitle : String, buttonTwoTitle : String)
    {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.mpHeaderBackgroundColor()
        self.layer.cornerRadius = frame.size.height / 2.0
        self.clipsToBounds = true
        
        self.selectedSegment = 0;
        
        segmentWidth = Double(frame.size.width / 2.0)
        
        indicatorView = UIView(frame: CGRect(x: 2, y: 2, width: CGFloat(segmentWidth), height: frame.size.height - 4))
        indicatorView!.clipsToBounds = true
        indicatorView!.layer.cornerRadius = (frame.size.height - 4) / 2.0
        indicatorView!.backgroundColor = UIColor.mpWhiteColor()
    
        self.addSubview(indicatorView!)
        
        labelOne = UILabel(frame: CGRect(x: 0, y: 0, width: segmentWidth, height: frame.size.height))
        labelOne?.textAlignment = .center
        labelOne?.text = buttonOneTitle;
        labelOne?.font = UIFont.mpBoldFontWith(size: 12)
        labelOne?.textColor = UIColor.mpBlackColor()
        self.addSubview(labelOne!)
        
        labelTwo = UILabel(frame: CGRect(x: segmentWidth, y: 0, width: segmentWidth, height: frame.size.height))
        labelTwo?.textAlignment = .center
        labelTwo?.text = buttonTwoTitle;
        labelTwo?.font = UIFont.mpBoldFontWith(size: 12)
        labelTwo?.textColor = UIColor.mpDarkGrayColor()
        self.addSubview(labelTwo!)
        
        buttonOne = UIButton(type: .custom)
        buttonOne?.frame = CGRect(x: 0, y: 0, width: CGFloat(segmentWidth), height: frame.size.height)
        buttonOne?.backgroundColor = .clear
        buttonOne?.addTarget(self, action: #selector(self.buttonOneTouched), for: .touchUpInside)
        self.addSubview(buttonOne!)
        
        buttonTwo = UIButton(type: .custom)
        buttonTwo?.frame = CGRect(x: CGFloat(segmentWidth), y: 0, width: CGFloat(segmentWidth), height: frame.size.height)
        buttonTwo?.backgroundColor = .clear
        buttonTwo?.addTarget(self, action: #selector(self.buttonTwoTouched), for: .touchUpInside)
        self.addSubview(buttonTwo!)

    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Button Methods
    
    @objc private func buttonOneTouched()
    {
        if (self.selectedSegment == 0)
        {
            return;
        }
        
        self.selectedSegment = 0;
        
        labelOne?.textColor = UIColor.mpBlackColor()
        labelTwo?.textColor = UIColor.mpDarkGrayColor()
        
        self.animateIndicator(offset:0.0)
        
        self.delegate?.segmentChanged()
    }
    
    @objc private func buttonTwoTouched()
    {
        if (self.selectedSegment == 1)
        {
            return;
        }
        
        self.selectedSegment = 1;
        
        labelOne?.textColor = UIColor.mpDarkGrayColor()
        labelTwo?.textColor = UIColor.mpBlackColor()
        
        self.animateIndicator(offset:segmentWidth - 4)
        
        self.delegate?.segmentChanged()
    }
    
    // MARK: - Animation Method
    
    private func animateIndicator(offset : Double)
    {
        UIView.animate(withDuration: 0.2)
        { [self] in
            self.indicatorView?.transform = CGAffineTransform.init(translationX: CGFloat(offset), y: 0)
        }
    }
    
    // MARK: - Set Segment Method
    
    func setSegment(index : Int)
    {
        switch index
        {
        case 0:
            self.selectedSegment = 0
            labelOne?.textColor = UIColor.mpBlackColor()
            labelTwo?.textColor = UIColor.mpDarkGrayColor()
            self.indicatorView?.transform = CGAffineTransform.init(translationX: 0, y: 0)
            
        case 1:
            self.selectedSegment = 1
            labelOne?.textColor = UIColor.mpDarkGrayColor()
            labelTwo?.textColor = UIColor.mpBlackColor()
            self.indicatorView?.transform = CGAffineTransform.init(translationX: CGFloat(segmentWidth - 4), y: 0)
            
        default:
            break
        }
    }
}
