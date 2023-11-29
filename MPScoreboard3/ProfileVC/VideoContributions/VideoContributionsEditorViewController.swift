//
//  VideoContributionsEditorViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 1/3/23.
//

import UIKit

class VideoContributionsEditorViewController: UIViewController, UITextViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var thumbnailBackgroundView: UIView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var descriptionContainerView: UIView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleTextCountLabel: UILabel!
    @IBOutlet weak var descriptionTextCountLabel: UILabel!
    
    var selectedVideoObj = [:] as! Dictionary<String,Any>
    var videoDetailsUpdated = false
    
    private var thumbnailOriginalHeight = 0.0
    private var tickTimer: Timer!
    private var progressOverlay: ProgressHUD!
    
    let kEmptyTitle = "Create a title for this video..."
    let kEmptyDescription = "Write a description..."
    
    // MARK: - Update User Video Details
    
    private func updateUserVideoDetails()
    {
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        let videoId = selectedVideoObj["videoId"] as! String
        
        NewFeeds.updateUserVideoDetails(videoId: videoId, title: titleTextView.text, description: descriptionTextView.text) { result, error in
            
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                if (self.progressOverlay != nil)
                {
                    self.progressOverlay.hide(animated: false)
                    self.progressOverlay = nil
                }
            }
            
            if (error == nil)
            {
                // Show the toast and pop the view when it is done
                OverlayView.showPopupOverlay(withMessage: "Video Details Updated")
                {
                    self.videoDetailsUpdated = true
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "We were unable to update the video details due to a server error.", lastItemCancelType: false) { tag in
                
                }
            }
        }
    }
    
    // MARK: - TextView Delegate Methods
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if (textView == titleTextView)
        {
            if (titleTextView.text == kEmptyTitle)
            {
                titleTextView.text = ""
                titleTextView.textColor = UIColor.mpBlackColor()
                titleTextCountLabel.text = "0/130"
            }
        }
        else
        {
            if (descriptionTextView.text == kEmptyDescription)
            {
                descriptionTextView.text = ""
                descriptionTextView.textColor = UIColor.mpBlackColor()
                descriptionTextCountLabel.text = "0/250"
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if (textView.text == "")
        {
            if (textView == titleTextView)
            {
                titleTextView.text = kEmptyTitle
                titleTextView.textColor = UIColor.mpGrayColor()
                titleTextCountLabel.text = "0/130"
            }
            else
            {
                descriptionTextView.text = kEmptyDescription
                descriptionTextView.textColor = UIColor.mpGrayColor()
                descriptionTextCountLabel.text = "0/250"
            }
        }
        else
        {
            let badWords = IODProfanityFilter.rangesOfFilteredWords(in: textView.text)
            
            if (badWords!.count > 0)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Language", message: "The text that you have entered is objectionable and can not be used.", lastItemCancelType: false) { tag in
                    /*
                    if (textView == self.titleTextView)
                    {
                        self.titleTextView.text = self.kEmptyTitle
                        self.titleTextView.textColor = UIColor.mpGrayColor()
                        self.titleTextCountLabel.text = "0/130"
                    }
                    else
                    {
                        self.descriptionTextView.text = self.kEmptyDescription
                        self.descriptionTextView.textColor = UIColor.mpGrayColor()
                        self.descriptionTextCountLabel.text = "0/250"
                    }
                    */
                }
                return
            }
            
            if (textView.text.containsEmoji == true)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "You can't use special characters in this field.", lastItemCancelType: false) { tag in
                    /*
                    if (textView == self.titleTextView)
                    {
                        self.titleTextView.text = self.kEmptyTitle
                        self.titleTextView.textColor = UIColor.mpGrayColor()
                        self.titleTextCountLabel.text = "0/130"
                    }
                    else
                    {
                        self.descriptionTextView.text = self.kEmptyDescription
                        self.descriptionTextView.textColor = UIColor.mpGrayColor()
                        self.descriptionTextCountLabel.text = "0/250"
                    }
                    */
                }
                return
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if (textView == titleTextView)
        {
            if let paste = UIPasteboard.general.string, text == paste
            {
                // Pasteboard
                if ((textView.text.count + text.count) > 130)
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Excess Length", message: "The text that you are pasting will exceed the 130 character limit.", lastItemCancelType: false) { tag in
                        
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
                
                if (range.location > 129)
                {
                    return false
                }
                return true
            }
        }
        else
        {
            if let paste = UIPasteboard.general.string, text == paste
            {
                // Pasteboard
                if ((textView.text.count + text.count) > 250)
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Excess Length", message: "The text that you are pasting will exceed the 250 character limit.", lastItemCancelType: false) { tag in
                        
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
                
                if (range.location > 249)
                {
                    return false
                }
                return true
            }
        }
    }
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        // Update the character count labels
        if (titleTextView.text != kEmptyTitle)
        {
            titleTextCountLabel.text = String(titleTextView.text.count) + "/130"
            
            if (titleTextView.text.count == 130)
            {
                titleTextCountLabel.textColor = UIColor.mpRedColor()
            }
            else
            {
                titleTextCountLabel.textColor = UIColor.mpGrayColor()
            }
        }
        else
        {
            titleTextCountLabel.text = "0/130"
            titleTextCountLabel.textColor = UIColor.mpGrayColor()
        }
        
        if (descriptionTextView.text != kEmptyDescription)
        {
            descriptionTextCountLabel.text = String(descriptionTextView.text.count) + "/250"
            
            if (descriptionTextView.text.count == 250)
            {
                descriptionTextCountLabel.textColor = UIColor.mpRedColor()
            }
            else
            {
                descriptionTextCountLabel.textColor = UIColor.mpGrayColor()
            }
        }
        else
        {
            descriptionTextCountLabel.text = "0/250"
            descriptionTextCountLabel.textColor = UIColor.mpGrayColor()
        }
        
        // Disable the post button if the keyboard is active
        if ((titleTextView.isFirstResponder == true) || (descriptionTextView.isFirstResponder == true))
        {
            saveButton.isEnabled = false
            saveButton.alpha = 0.5
        }
        else
        {
            if ((titleTextView.text! != kEmptyTitle) && (descriptionTextView.text! != kEmptyDescription))
            {
                saveButton.isEnabled = true
                saveButton.alpha = 1.0
            }
            else
            {
                saveButton.isEnabled = false
                saveButton.alpha = 0.5
            }
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonTouched(_ sender: UIButton)
    {
        // Added this check in case the user pasted the text or used auto-complete
        if (titleTextView.text.count > 130)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "The title has too many characters.", lastItemCancelType: false) { tag in
            }
            return
        }
        
        if (descriptionTextView.text.count > 250)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "The description has too many characters.", lastItemCancelType: false) { tag in
            }
            return
        }
        
        self.updateUserVideoDetails()
    }
    
    @objc private func titleDoneButtonTouched()
    {
        titleTextView.resignFirstResponder()
    }
    
    @objc private func descriptionDoneButtonTouched()
    {
        descriptionTextView.resignFirstResponder()
    }
    
    @objc private func titleDownButtonTouched()
    {
        self.descriptionTextView.becomeFirstResponder()
    }
    
    @objc private func descriptionUpButtonTouched()
    {
        self.titleTextView.becomeFirstResponder()
    }
    
    // MARK: - Accessory Views
    
    private func addTitleKeyboardAccessoryView()
    {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        accessoryView.backgroundColor = UIColor.mpOffWhiteNavColor()
        
        let horizLine = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 1))
        horizLine.backgroundColor = UIColor.mpHeaderBackgroundColor()
        accessoryView.addSubview(horizLine)
        
        let doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: kDeviceWidth - 82, y: 5, width: 80, height: 30)
        doneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        doneButton.addTarget(self, action: #selector(titleDoneButtonTouched), for: .touchUpInside)
        accessoryView.addSubview(doneButton)
        
        let downButton = UIButton(type: .custom)
        downButton.frame = CGRect(x: 8, y: 5, width: 35, height: 30)
        downButton.setImage(UIImage(named: "DownArrowDarkGray"), for: .normal)
        downButton.addTarget(self, action: #selector(titleDownButtonTouched), for: .touchUpInside)
        accessoryView.addSubview(downButton)
            
        titleTextView!.inputAccessoryView = accessoryView
    }
    
    private func addDescriptionKeyboardAccessoryView()
    {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        accessoryView.backgroundColor = UIColor.mpOffWhiteNavColor()
        
        let horizLine = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 1))
        horizLine.backgroundColor = UIColor.mpHeaderBackgroundColor()
        accessoryView.addSubview(horizLine)
        
        let doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: kDeviceWidth - 82, y: 5, width: 80, height: 30)
        doneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        doneButton.addTarget(self, action: #selector(descriptionDoneButtonTouched), for: .touchUpInside)
        accessoryView.addSubview(doneButton)
        
        let upButton = UIButton(type: .custom)
        upButton.frame = CGRect(x: 8, y: 5, width: 35, height: 30)
        upButton.setImage(UIImage(named: "UpArrowDarkGray"), for: .normal)
        upButton.addTarget(self, action: #selector(descriptionUpButtonTouched), for: .touchUpInside)
        accessoryView.addSubview(upButton)
            
        descriptionTextView!.inputAccessoryView = accessoryView
    }
    
    // MARK: - Keyboard Notifications
    
    @objc private func keyboardDidShow(notification: Notification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            //print("Keyboard Height: " + String(Int(keyboardSize.size.height)))
            
            // Need to use the device coordinates for this calculation
            let descriptionContainerViewBottom = Int(containerScrollView.frame.origin.y) + Int(descriptionContainerView.frame.origin.y) + Int(descriptionContainerView.frame.size.height)
            
            let keyboardTop = Int(kDeviceHeight) - Int(keyboardSize.size.height)
            
            if (keyboardTop < descriptionContainerViewBottom)
            {
                let difference = descriptionContainerViewBottom - keyboardTop
                print("Height Difference:" + String(difference))
                
                // Scale the thumbnail and transform the scrollView
                let newThumbnailHeight = Int(thumbnailOriginalHeight) - difference
                let scaleFactor = CGFloat(newThumbnailHeight) / thumbnailOriginalHeight
                let scaleTransform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
                let translateTransform = CGAffineTransform(translationX: 0, y: CGFloat(-difference) / 2.0)
                
                thumbnailImageView.transform = CGAffineTransformConcat(scaleTransform, translateTransform)
                containerScrollView.transform = CGAffineTransform(translationX: 0, y: CGFloat(-difference))
            }
        }
        
        /*
        // Only scroll if the descriptionTextView is the first responder
        if (descriptionTextView.isFirstResponder == true)
        {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            {
                //print("Keyboard Height: " + String(Int(keyboardSize.size.height)))

                // Need to use the device coordinates for this calculation
                let descriptionContainerViewBottom = Int(containerScrollView.frame.origin.y) + Int(descriptionContainerView.frame.origin.y) + Int(descriptionContainerView.frame.size.height)
                
                let keyboardTop = Int(kDeviceHeight) - Int(keyboardSize.size.height)
                
                if (keyboardTop < descriptionContainerViewBottom)
                {
                    let difference = descriptionContainerViewBottom - keyboardTop
                    print("Height Difference:" + String(difference))
                    containerScrollView.contentOffset = CGPoint(x: 0, y: difference)
                }
            }
        }
        */
    }
    
    @objc private func keyboardDidHide(notification: Notification)
    {
        //print("Keyboard will hide")
        //containerScrollView.contentOffset = CGPoint(x: 0, y: 0)
        
        thumbnailImageView.transform = .identity
        containerScrollView.transform = .identity
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, videoContainer, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        
        thumbnailOriginalHeight = (kDeviceWidth / 16.0) * 9.0 as CGFloat
        
        thumbnailBackgroundView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: thumbnailOriginalHeight)
        thumbnailImageView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: thumbnailOriginalHeight)
        
        containerScrollView.frame = CGRect(x: 0, y: thumbnailImageView.frame.origin.y + thumbnailImageView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - thumbnailImageView.frame.origin.y - thumbnailImageView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight))
        
        
        // Try to load the thumbnail
        // Load the thumbnail
        let thumbnailUrl = selectedVideoObj["thumbnailUrl"] as? String ?? ""
            
        if (thumbnailUrl.count > 0)
        {
            // Get the data and make an image
            let url = URL(string: thumbnailUrl)
            
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        self.thumbnailImageView.image = image
                    }
                    else
                    {
                        self.thumbnailImageView.image = UIImage(named: "EmptyVideoScores")
                    }
                }
            }
        }
        else
        {
            thumbnailImageView.image = UIImage(named: "EmptyVideoScores")
        }
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
        
        //uploadButton.isEnabled = false
        //uploadButton.alpha = 0.5
        
        //titleTextView.text = kEmptyTitle
        //titleTextView.textColor = UIColor.mpGrayColor()
        //descriptionTextView.text = kEmptyDescription
        //descriptionTextView.textColor = UIColor.mpGrayColor()
        
        // Load the data
        let title = selectedVideoObj["title"] as! String
        let description = selectedVideoObj["description"] as! String
        
        titleTextView.text = title
        descriptionTextView.text = description
        
        titleTextCountLabel.text = String(format: "%d/130", titleTextView.text.count)
        descriptionTextCountLabel.text = String(format: "%d/250", descriptionTextView.text.count)
        
        self.addTitleKeyboardAccessoryView()
        self.addDescriptionKeyboardAccessoryView()
        
        // Add the keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mpBlackColor(), .font: UIFont.mpSemiBoldFontWith(size: kNavBarFontSize)]
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.default
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
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
