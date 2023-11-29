//
//  ReportVideoViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 1/30/23.
//

import UIKit

class ReportVideoViewController: UIViewController, UITextViewDelegate
{
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var descriptionContainerView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionTextCountLabel: UILabel!
    
    var videoId = ""
    
    private var tickTimer: Timer!
    private var progressOverlay: ProgressHUD!
    
    let kEmptyDescription = "Tell us about your experience..."
    
    // MARK: - Send Report
    
    private func sendReport()
    {
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.reportVideo(videoId: videoId, message: descriptionTextView.text) { error in
            
            // Hide the busy indicator
            if (self.progressOverlay != nil)
            {
                self.progressOverlay.hide(animated: false)
                self.progressOverlay = nil
            }
            
            if (error == nil)
            {
                MiscHelper.showDarkAlert(in: self, withActionNames: ["OK"], title: "Submitted", message: "Thank you for helping us improve MaxPreps. The video will be reviewed by our support team within the next business day and will be removed if it does not meet our standards.", lastItemCancelType: false) { tag in
                    
                    UIView.animate(withDuration: 0.33, animations: {
                        
                        self.view.backgroundColor = .clear
                    })
                    { (finished) in
                        self.dismiss(animated: true)
                    }
                }
            }
            else
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're  Sorry", message: "We are unable to report this video due to a server error.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - TextView Delegate Methods
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView.text == kEmptyDescription)
        {
            descriptionTextView.text = ""
            descriptionTextCountLabel.text = "0/50"
        }
        
        descriptionTextView.textColor = UIColor.mpWhiteColor()
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == "")
        {
            descriptionTextView.text = kEmptyDescription
            descriptionTextView.textColor = UIColor.mpLighterGrayColor()
            descriptionTextCountLabel.text = "0/50"
        }
        else
        {
            let badWords = IODProfanityFilter.rangesOfFilteredWords(in: textView.text)
            
            if (badWords!.count > 0)
            {
                MiscHelper.showDarkAlert(in: self, withActionNames: ["OK"], title: "Language", message: "The text that you have entered is objectionable and can not be used.", lastItemCancelType: false) { tag in
                }
                return
            }
            
            if (textView.text.containsEmoji == true)
            {
                MiscHelper.showDarkAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "You can't use special characters in this field.", lastItemCancelType: false) { tag in
                }
                return
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if let paste = UIPasteboard.general.string, text == paste
        {
            // Pasteboard
            if ((textView.text.count + text.count) > 50)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Excess Length", message: "The text that you are pasting will exceed the 50 character limit.", lastItemCancelType: false) { tag in
                    
                }
                return false
            }
            return true
        }
        else
        {
            // Normal typing
            if (text == "\n")
            {
                return false
            }
            
            if (range.location > 49)
            {
                return false
            }
            return true
        }
    }
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        // Disable the post button if the keyboard is active
        if (descriptionTextView.isFirstResponder == true)
        {
            sendButton.isEnabled = false
            sendButton.alpha = 0.5
        }
        else
        {
            if (descriptionTextView.text! != kEmptyDescription)
            {
                sendButton.isEnabled = true
                sendButton.alpha = 1.0
            }
            else
            {
                sendButton.isEnabled = false
                sendButton.alpha = 0.5
            }
        }
        
        if (descriptionTextView.text != kEmptyDescription)
        {
            descriptionTextCountLabel.text = String(descriptionTextView.text.count) + "/50"
            
            if (descriptionTextView.text.count == 50)
            {
                descriptionTextCountLabel.textColor = UIColor.mpRedColor()
            }
            else
            {
                descriptionTextCountLabel.textColor = UIColor.mpLighterGrayColor()
            }
        }
        else
        {
            descriptionTextCountLabel.text = "0/50"
            descriptionTextCountLabel.textColor = UIColor.mpLighterGrayColor()
        }
    }

    // MARK: - Button Methods
    
    @IBAction func closeButtonTouched(_ sender: UIButton)
    {
        UIView.animate(withDuration: 0.33, animations: {
            
            self.view.backgroundColor = .clear
        })
        { (finished) in
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func sendButtonTouched(_ sender: UIButton)
    {
        if (descriptionTextView.text.count > 50)
        {
            MiscHelper.showDarkAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Your reason can not exceed 50 characters.", lastItemCancelType: false) { tag in
            }
            return
        }
        
        self.sendReport()
    }
    
    @objc private func descriptionDoneButtonTouched()
    {
        descriptionTextView.resignFirstResponder()
    }

    // MARK: - Keyboard Accessory Views
    
    private func addDescriptionKeyboardAccessoryView()
    {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        accessoryView.backgroundColor = UIColor(white: 0.20, alpha: 1)
        
        let horizLine = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 1))
        horizLine.backgroundColor = UIColor(white: 0.35, alpha: 1)
        accessoryView.addSubview(horizLine)
        
        let doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: kDeviceWidth - 82, y: 8, width: 80, height: 30)
        doneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.mpOffWhiteNavColor(), for: .normal)
        doneButton.addTarget(self, action: #selector(descriptionDoneButtonTouched), for: .touchUpInside)
        accessoryView.addSubview(doneButton)
        
        descriptionTextView!.inputAccessoryView = accessoryView
        
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the navBar, and textViewContainer
        navView.frame = CGRect(x: 0, y: 44.0, width: kDeviceWidth, height: navView.frame.size.height)
        descriptionContainerView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height)
        
        sendButton.isEnabled = false
        sendButton.alpha = 0.5
        
        descriptionTextView.text = kEmptyDescription
        descriptionTextView.textColor = UIColor.mpLighterGrayColor()
        
        self.addDescriptionKeyboardAccessoryView()
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.33, animations: {
            
            self.view.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
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
    
    deinit
    {
        tickTimer.invalidate()
        tickTimer = nil
    }
}
