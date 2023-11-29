//
//  VideoUploadAlertView.swift
//  MPScoreboard3
//
//  Created by David Smith on 11/3/22.
//

import UIKit

protocol VideoUploadAlertViewDelegate: AnyObject
{
    func videoUploadAlertCancelButtonTouched()
    func videoUploadAlertContinueButtonTouched()
    func videoUploadAlertDoneButtonTouched()
    func videoUploadAlertViewDidDismiss()
}

class VideoUploadAlertView: UIView
{
    var blackBackgroundView: UIView!
    var roundRectView: UIView!
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    var continueButton: UIButton!
    var doneButton: UIButton!
    var cancelButton: UIButton!
    var uploadProgress: UIProgressView!
    var uploadProgressBackground: UIView!
    var activityIndicator: UIActivityIndicatorView!
    
    weak var delegate: VideoUploadAlertViewDelegate?
    
    // MARK: - Parent Control Methods

    func updateProgress(_ value: Float)
    {
        uploadProgress.setProgress(value, animated: true)
    }
    
    func showContinue(text: String)
    {
        activityIndicator.isHidden = true
        continueButton.isHidden = false
        cancelButton.isHidden = false
        subtitleLabel.text = text
        titleLabel.text = "Post Video"
    }
    
    func uploadCompleted()
    {
        uploadProgressBackground.isHidden = true
        doneButton.isHidden = false
        titleLabel.text = "Upload Complete"
        subtitleLabel.text = "The video was successfully uploaded and will be posted within 30 minutes."
    }
    
    func dismissAlert()
    {
        UIView.animate(withDuration: 0.16, animations: {
            self.blackBackgroundView.alpha = 0.0
            self.roundRectView.transform = CGAffineTransformMakeTranslation(0, (self.frame.size.height / 2.0) + 100.0)
        })
        { (finished) in
            
            self.delegate?.videoUploadAlertViewDidDismiss()
        }
    }
    
    // MARK: - Button Methods
    
    @objc private func cancelButtonTouched()
    {
        UIView.animate(withDuration: 0.16, animations: {
            self.blackBackgroundView.alpha = 0.0
            self.roundRectView.transform = CGAffineTransformMakeTranslation(0, (self.frame.size.height / 2.0) + 100.0)
        })
        { (finished) in
            
            self.delegate?.videoUploadAlertCancelButtonTouched()
        }
    }
    
    @objc private func continueButtonTouched()
    {
        self.delegate?.videoUploadAlertContinueButtonTouched()
        continueButton.isHidden = true
        cancelButton.isHidden = true
        uploadProgressBackground.isHidden = false
        subtitleLabel.text = ""
    }
    
    @objc private func doneButtonTouched()
    {
        self.delegate?.videoUploadAlertDoneButtonTouched()
    }
    
    // MARK: - Init Methods
    
    required override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        blackBackgroundView = UIView(frame: frame)
        blackBackgroundView.backgroundColor = .black
        blackBackgroundView.alpha = 0.0
        self.addSubview(blackBackgroundView)
        
        roundRectView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        roundRectView.center = self.center
        roundRectView.backgroundColor = UIColor.mpWhiteColor()
        roundRectView.layer.cornerRadius = 12.0
        roundRectView.clipsToBounds = true
        roundRectView.transform = CGAffineTransformMakeTranslation(0, (frame.size.height / 2.0) + 100.0)
        self.addSubview(roundRectView)
        
        cancelButton = UIButton(type: .custom)
        //cancelButton.frame = CGRect(x: roundRectView.frame.size.width - 44.0, y: 4.0, width: 40.0, height: 40.0)
        cancelButton.frame = CGRect(x: 4.0, y: 4.0, width: 40.0, height: 40.0)
        cancelButton.setImage(UIImage(named: "CloseButtonGray"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTouched), for: .touchUpInside)
        roundRectView.addSubview(cancelButton)
        cancelButton.isHidden = true
        
        titleLabel = UILabel(frame: CGRect(x: 20.0, y: 28.0, width: 280.0, height: 30.0))
        titleLabel.text = "Preparing Video"
        titleLabel.font = UIFont.mpBoldFontWith(size: 22.0)
        titleLabel.textColor = UIColor.mpBlackColor()
        titleLabel.textAlignment = .center
        roundRectView.addSubview(titleLabel)
        
        subtitleLabel = UILabel(frame: CGRect(x: 25.0, y: 65.0, width: 270.0, height: 60.0))
        subtitleLabel.numberOfLines = 3
        subtitleLabel.text = ""
        subtitleLabel.font = UIFont.mpRegularFontWith(size: 15.0)
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.5
        subtitleLabel.textColor = UIColor.mpBlackColor()
        subtitleLabel.textAlignment = .center
        roundRectView.addSubview(subtitleLabel)
        
        continueButton = UIButton(type: .custom)
        continueButton.frame = CGRect(x: 16.0, y: 140.0, width: 288.0, height: 36.0)
        continueButton.backgroundColor = UIColor.mpRedColor()
        continueButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 14)
        continueButton.setTitle("CONTINUE", for: .normal)
        continueButton.setTitleColor(UIColor.mpWhiteColor(), for: .normal)
        continueButton.layer.cornerRadius = 8
        continueButton.clipsToBounds = true
        continueButton.addTarget(self, action: #selector(continueButtonTouched), for: .touchUpInside)
        roundRectView.addSubview(continueButton)
        continueButton.isHidden = true
        
        doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: 16.0, y: 140.0, width: 288.0, height: 36.0)
        doneButton.backgroundColor = UIColor.mpRedColor()
        doneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 14)
        doneButton.setTitle("GOT IT", for: .normal)
        doneButton.setTitleColor(UIColor.mpWhiteColor(), for: .normal)
        doneButton.layer.cornerRadius = 8
        doneButton.clipsToBounds = true
        doneButton.addTarget(self, action: #selector(doneButtonTouched), for: .touchUpInside)
        roundRectView.addSubview(doneButton)
        doneButton.isHidden = true
        
        uploadProgressBackground = UIView(frame: CGRect(x: 16, y: 75, width: 287, height: 88))
        uploadProgressBackground.backgroundColor = UIColor.mpOffWhiteNavColor()
        uploadProgressBackground.layer.cornerRadius = 8
        uploadProgressBackground.clipsToBounds = true
        roundRectView.addSubview(uploadProgressBackground)
        uploadProgressBackground.isHidden = true
        
        uploadProgress = UIProgressView(frame: CGRect(x: 12.0, y: 54.0, width: 263.0, height: 4.0))
        uploadProgress.tintColor = UIColor.mpRedColor()
        uploadProgress.layer.cornerRadius = 4
        uploadProgress.clipsToBounds = true
        uploadProgressBackground.addSubview(uploadProgress)
        
        let uploadProgressSubtitle = UILabel(frame: CGRect(x: 0.0, y: 22.0, width: 287.0, height: 20.0))
        uploadProgressSubtitle.text = "Uploading..."
        uploadProgressSubtitle.font = UIFont.mpRegularFontWith(size: 15.0)
        uploadProgressSubtitle.textColor = UIColor.mpGrayColor()
        uploadProgressSubtitle.textAlignment = .center
        uploadProgressBackground.addSubview(uploadProgressSubtitle)
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = CGPointMake(continueButton.center.x, continueButton.center.y - 30.0)
        activityIndicator.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        roundRectView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        // Animate
        UIView.animate(withDuration: 0.33, animations: {
            self.blackBackgroundView.alpha = 0.7
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
