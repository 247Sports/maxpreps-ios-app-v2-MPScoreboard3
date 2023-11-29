//
//  LandscapeKeyboardView.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/21/21.
//

import UIKit

protocol LandscapeKeyboardViewDelegate: AnyObject
{
    func landscapeKeyboardDoneButtonTouched()
    func landscapeKeyboardNumberButtonTouched(value: Int)
    func landscapeKeyboardBackspaceButtonTouched()
    func landscapeKeyboardLeftButtonTouched()
    func landscapeKeyboardRightButtonTouched()
}

class LandscapeKeyboardView: UIView
{
    weak var delegate: LandscapeKeyboardViewDelegate?
    
    private var keyboardLeftButton: UIButton!
    private var keyboardRightButton: UIButton!
    
    private let kKeyboardTitles = ["1","2","3","4","5","6","7","8","9","0","BSP"]
    
    // MARK: - Button Methods
    
    @objc private func doneButtonTouched()
    {
        self.delegate?.landscapeKeyboardDoneButtonTouched()
    }
    
    @objc private func numberButtonTouched(_ sender: UIButton)
    {
        let keyValue = sender.tag - 100
        self.delegate?.landscapeKeyboardNumberButtonTouched(value: keyValue)
    }
    
    @objc private func backspaceButtonTouched()
    {
        self.delegate?.landscapeKeyboardBackspaceButtonTouched()
    }
    
    @objc private func keyboardLeftButtonTouched()
    {
        self.delegate?.landscapeKeyboardLeftButtonTouched()
    }
    
    @objc private func keyboardRightButtonTouched()
    {
        self.delegate?.landscapeKeyboardRightButtonTouched()
    }
    
    // MARK: - Set Button Methods
    
    func enableLeftKeyboardButton(_ enabled: Bool)
    {
        if (enabled == true)
        {
            keyboardLeftButton.setImage(UIImage(named: "AccessoryLeftRed"), for: .normal)
            keyboardLeftButton.isUserInteractionEnabled = true
        }
        else
        {
            keyboardLeftButton.setImage(UIImage(named: "AccessoryLeftGray"), for: .normal)
            keyboardLeftButton.isUserInteractionEnabled = false
        }
    }
    
    func enableRightKeyboardButton(_ enabled: Bool)
    {
        if (enabled == true)
        {
            keyboardRightButton.setImage(UIImage(named: "AccessoryRightRed"), for: .normal)
            keyboardRightButton.isUserInteractionEnabled = true
        }
        else
        {
            keyboardRightButton.setImage(UIImage(named: "AccessoryRightGray"), for: .normal)
            keyboardRightButton.isUserInteractionEnabled = false
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(red: 214.0/255.0, green: 215.0/255.0, blue: 220.0/255.0, alpha: 1.0)
        
        let navView = UIView(frame: CGRect(x: 0, y: 0, width: Int(frame.size.width), height: 30))
        navView.backgroundColor = UIColor.mpWhiteColor()
        self.addSubview(navView)
        
        // The nav buttons are inset on notched devices
        let doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: Int(frame.size.width) - 85 - SharedData.topNotchHeight, y: 0, width: 80, height: 30)
        doneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.mpRedColor(), for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonTouched), for: .touchUpInside)
        navView.addSubview(doneButton)
        
        keyboardLeftButton = UIButton(type: .custom)
        keyboardLeftButton.frame = CGRect(x: SharedData.topNotchHeight + 5, y: 0, width: 40, height: 30)
        keyboardLeftButton.setImage(UIImage(named: "AccessoryLeftRed"), for: .normal)
        keyboardLeftButton.addTarget(self, action: #selector(keyboardLeftButtonTouched), for: .touchUpInside)
        self.addSubview(keyboardLeftButton)
        self.enableLeftKeyboardButton(false)
        
        keyboardRightButton = UIButton(type: .custom)
        keyboardRightButton.frame = CGRect(x: SharedData.topNotchHeight + 50, y: 0, width: 40, height: 30)
        keyboardRightButton.setImage(UIImage(named: "AccessoryRightRed"), for: .normal)
        keyboardRightButton.addTarget(self, action: #selector(keyboardRightButtonTouched), for: .touchUpInside)
        self.addSubview(keyboardRightButton)
        
        // Add the keyboard buttons
        let edgePad = 20
        let spacing = 4
        let width = (Int(frame.size.width) - (2 * edgePad) - ((kKeyboardTitles.count - 1) * spacing)) / kKeyboardTitles.count
        var index = 0
        
        for title in kKeyboardTitles
        {
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: edgePad + (index * (width + spacing)) , y: 38, width: width, height: 30)
            
            if (index < (kKeyboardTitles.count - 1))
            {
                button.layer.cornerRadius = 5
                button.clipsToBounds = false
                button.backgroundColor = UIColor.mpWhiteColor()
                button.titleLabel?.font = UIFont.mpRegularFontWith(size: 16)
                button.setTitleColor(UIColor.mpBlackColor(), for: .normal)
                button.setTitle(title, for: .normal)
                button.tag = 100 + Int(title)!
                button.addTarget(self, action: #selector(numberButtonTouched(_:)), for: .touchUpInside)
                
                // Add a shadow to the button
                let shadowPath = UIBezierPath(rect: button.bounds)
                button.layer.masksToBounds = false
                button.layer.shadowColor = UIColor(white: 0.4, alpha: 1.0).cgColor
                button.layer.shadowOffset = CGSize(width: 0, height: 3)
                button.layer.shadowOpacity = 0.5
                button.layer.shadowPath = shadowPath.cgPath
                
                self.addSubview(button)
                
                index += 1
            }
            else
            {
                button.setImage(UIImage(named: "KeyboardBackspace"), for: .normal)
                button.addTarget(self, action: #selector(backspaceButtonTouched), for: .touchUpInside)
                self.addSubview(button)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
