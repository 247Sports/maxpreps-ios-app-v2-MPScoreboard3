//
//  OldCareerVideoUploadViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/12/22.
//

import UIKit
import AVFoundation

class OldCareerVideoUploadViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var lowerContainerView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var athleteScrollView: UIScrollView!
    
    var videoUrl: URL!
    var selectedAthlete : Athlete?
    var taggedAthletes : Array<Any>?
    
    private var tickTimer: Timer!
        
    private var uploadVideoAthleteSearchVC: UploadVideoAthleteSearchViewController!
    //private var uploadVideoTitleVC: UploadVideoTitleViewController!
    
    let testAthlete1 = Athlete(firstName: "Joe", lastName: "Blow", schoolName: "", schoolState: "", schoolCity: "", schoolId: "", schoolColor: "", schoolMascotUrl: "", careerId: "123456", photoUrl: "")
    
    let testAthlete2 = Athlete(firstName: "Fred", lastName: "Flintstone", schoolName: "", schoolState: "", schoolCity: "", schoolId: "", schoolColor: "", schoolMascotUrl: "", careerId: "123457", photoUrl: "")
    
    let testAthlete3 = Athlete(firstName: "Barney", lastName: "Rubble", schoolName: "", schoolState: "", schoolCity: "", schoolId: "", schoolColor: "", schoolMascotUrl: "", careerId: "123458", photoUrl: "")
    
    // MARK: - TextField Delegate Methods
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        /*
        if (textField == titleTextField)
        {
            uploadVideoTitleVC = UploadVideoTitleViewController(nibName: "UploadVideoTitleViewController", bundle: nil)
            uploadVideoTitleVC.titleMode = true
            uploadVideoTitleVC.selectedText = titleTextField.text!
            
            self.navigationController?.pushViewController(uploadVideoTitleVC, animated: true)
        }
        else if (textField == descriptionTextField)
        {
            uploadVideoTitleVC = UploadVideoTitleViewController(nibName: "UploadVideoTitleViewController", bundle: nil)
            uploadVideoTitleVC.titleMode = false
            uploadVideoTitleVC.selectedText = descriptionTextField.text!
            
            self.navigationController?.pushViewController(uploadVideoTitleVC, animated: true)
        }
        */
        return false
    }
    
    // MARK: - Add Athlete Buttons
    
    private func addAthleteButtons()
    {
        // Remove existing buttons
        let scrollViewSubviews = athleteScrollView.subviews
        for subview in scrollViewSubviews
        {
            subview.removeFromSuperview()
        }
        
        var overallWidth = 0
        let textLeadingPad = 12
        let textTrailingPad = 30
        //let leftPad = 0
        //let rightPad = 0
        var index = 0
        var itemWidth = 0
        var yOffset = 0
        
        for item in taggedAthletes!
        {
            // Calculate the cell size based upon the text width
            let athlete = item as! Athlete
            let fullName = String(format: "%@ %@", athlete.firstName, athlete.lastName)
            
            if (index > 0)
            {
                itemWidth = Int(fullName.widthOfString(usingFont: UIFont.mpRegularFontWith(size: 12))) + textLeadingPad + textTrailingPad
            }
            else
            {
                itemWidth = Int(fullName.widthOfString(usingFont: UIFont.mpRegularFontWith(size: 12))) + (2 * textLeadingPad)
            }
            
            // Jump to the next line
            if (overallWidth + itemWidth > Int(athleteScrollView.frame.size.width))
            {
                overallWidth = 0
                yOffset += 42
            }
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: overallWidth, y: yOffset, width: itemWidth, height: 30)
            button.backgroundColor = UIColor.mpOffWhiteNavColor()
            button.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 12)
            button.setTitle(fullName, for: .normal)
            button.setTitleColor(UIColor.mpBlackColor(), for: .normal)
            
            if (index > 0)
            {
                button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -7.0, bottom: 0.0, right: 7.0)
            }
            button.layer.cornerRadius = button.frame.size.height / 2.0
            //button.clipsToBounds = true
            
            // Add a shadow to the button
            button.layer.masksToBounds = false
            button.layer.shadowColor = UIColor(white: 0.7, alpha: 1.0).cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 2.0)
            button.layer.shadowRadius = 2
            button.layer.shadowOpacity = 0.5
            
            
            // Add a delete button to the end
            if (index > 0)
            {
                let deleteButton = UIButton(type: .custom)
                deleteButton.frame = CGRect(x: itemWidth - 29, y: 0, width: 30, height: 30)
                //deleteButton.setImage(UIImage(named: "CloseButtonSmallBlack"), for: .normal)
                deleteButton.setImage(UIImage(named: "CloseCircularSmall"), for: .normal)
                deleteButton.tag = 100 + index
                deleteButton.addTarget(self, action: #selector(deleteAthleteButtonTouched), for: .touchUpInside)
                button.addSubview(deleteButton)
            }
            
            athleteScrollView.addSubview(button)
            
            index += 1
            overallWidth += itemWidth + 10
            
        }
        
        
        // Resize the scrollView contentSize to reflect the items count
        athleteScrollView.contentSize = CGSize(width: athleteScrollView.frame.size.width, height: CGFloat(yOffset + 42))
    }
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        if ((titleTextField.text!.count > 0) && (descriptionTextField.text!.count > 0))
        {
            uploadButton.isEnabled = true
            
            let attributedString = NSMutableAttributedString(string: "Upload", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 17), NSAttributedString.Key.foregroundColor: UIColor.mpBlackColor()])
            uploadButton.setAttributedTitle(attributedString, for: .normal)
        }
        else
        {
            uploadButton.isEnabled = false
            
            let attributedString = NSMutableAttributedString(string: "Upload", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 17), NSAttributedString.Key.foregroundColor: UIColor.mpLightGrayColor()])
            uploadButton.setAttributedTitle(attributedString, for: .normal)
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func closeButtonTouched(_ sender: UIButton)
    {
        self.dismiss(animated: true)
    }
    
    @IBAction func searchAthletesButtonTouched(_ sender: UIButton)
    {
        uploadVideoAthleteSearchVC = UploadVideoAthleteSearchViewController(nibName: "UploadVideoAthleteSearchViewController", bundle: nil)
        uploadVideoAthleteSearchVC.taggedAthletes = taggedAthletes!
        
        self.navigationController?.pushViewController(uploadVideoAthleteSearchVC, animated: true)
    }
    
    @objc private func deleteAthleteButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let athlete = taggedAthletes?[index] as! Athlete
        let message = String(format: "Do you want to untag %@ %@ from the video?", athlete.firstName, athlete.lastName)
        
        MiscHelper.showAlert(in: self, withActionNames: ["Cancel", "Yes"], title: "Untag Athlete", message: message, lastItemCancelType: false) { tag in
            
            if (tag == 1)
            {
                self.taggedAthletes?.remove(at: index)
                self.addAthleteButtons()
            }
        }
    }
    
    @IBAction func uploadButtonTouched(_ sender: UIButton)
    {
        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Upload", message: "This calls the upload video API.", lastItemCancelType: false) { tag in
            
        }
    }

    // MARK: - View Methods

    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, videoContainer, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        
        let thumbnailHeight = (kDeviceWidth / 16.0) * 9.0 as CGFloat
        
        thumbnailImageView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: thumbnailHeight)
        
        lowerContainerView.frame = CGRect(x: 0, y: thumbnailImageView.frame.origin.y + thumbnailImageView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - thumbnailImageView.frame.origin.y - thumbnailImageView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight))
        
        print(videoUrl!)
        
        // Try to load the thumbnail
        do {
            let asset = AVURLAsset(url: videoUrl!, options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            thumbnailImageView.image = thumbnail
        }
        catch let error
        {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            thumbnailImageView.image = UIImage(named: "EmptyVideoScores")
        }
        
        let attributedString = NSMutableAttributedString(string: "Upload", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 17), NSAttributedString.Key.foregroundColor: UIColor.mpLightGrayColor()])
        uploadButton.setAttributedTitle(attributedString, for: .normal)
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
        
        // Load some test athletes
        taggedAthletes = [selectedAthlete!]
        
        self.addAthleteButtons()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mpBlackColor(), .font: UIFont.mpSemiBoldFontWith(size: kNavBarFontSize)]
        
        /*
        if (uploadVideoTitleVC != nil)
        {
            if (uploadVideoTitleVC.titleMode == true)
            {
                titleTextField.text = uploadVideoTitleVC.selectedText
            }
            else
            {
                descriptionTextField.text = uploadVideoTitleVC.selectedText
            }
        }
        */
        if (uploadVideoAthleteSearchVC != nil)
        {
            // Iterate to remove for duplicates athletes
            for item in uploadVideoAthleteSearchVC.taggedAthletes
            {
                let taggedAthlete = item as! Athlete
                var matchFound = false
                for item2 in taggedAthletes!
                {
                    let existingAthlete = item2 as! Athlete
                    if (existingAthlete.careerId == taggedAthlete.careerId)
                    {
                        matchFound = true
                        break
                    }
                }
                
                if (matchFound == false)
                {
                    taggedAthletes?.append(taggedAthlete)
                }
            }
            
            self.addAthleteButtons()
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (uploadVideoAthleteSearchVC != nil)
        {
            uploadVideoAthleteSearchVC = nil
        }
        
        /*
        if (uploadVideoTitleVC != nil)
        {
            if (uploadVideoTitleVC.titleMode == true)
            {
                uploadVideoTitleVC = nil
                
                // This opens the uploadVideoTitleVC again
                descriptionTextField.becomeFirstResponder()
            }
            else
            {
                uploadVideoTitleVC = nil
            }
        }
        */
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
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
    }
}
