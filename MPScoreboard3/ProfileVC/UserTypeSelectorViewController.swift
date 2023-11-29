//
//  UserTypeSelectorViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/14/23.
//

import UIKit

protocol UserTypeSelectorViewControllerDelegate: AnyObject
{
    func userTypeSelectorViewControllerDidCancel()
    func userTypeSelectorViewControllerDidSave()
}

class UserTypeSelectorViewController: UIViewController
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var parentImageView: UIImageView!
    @IBOutlet weak var highSchoolCoachImageView: UIImageView!
    @IBOutlet weak var adImageView: UIImageView!
    @IBOutlet weak var statisticianImageView: UIImageView!
    @IBOutlet weak var collegeCoachImageView: UIImageView!
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var schoolAdministratorImageView: UIImageView!
    
    weak var delegate: UserTypeSelectorViewControllerDelegate?
        
    private var selectedIndex = 0
    private var progressOverlay: ProgressHUD!
    
    private var kRoleValues = ["Parent", "High School Coach", "Athletic Director", "Statistician", "College Coach",  "Media", "School Administrator"]
    
    // MARK: - Button Image Method
    
    private func setButtonImage()
    {
        switch selectedIndex
        {
        case 0:
            parentImageView.image = UIImage(named: "CheckmarkBlack")
            highSchoolCoachImageView.image = nil
            adImageView.image = nil
            statisticianImageView.image = nil
            collegeCoachImageView.image = nil
            mediaImageView.image = nil
            schoolAdministratorImageView.image = nil
        case 1:
            parentImageView.image = nil
            highSchoolCoachImageView.image = UIImage(named: "CheckmarkBlack")
            adImageView.image = nil
            statisticianImageView.image = nil
            collegeCoachImageView.image = nil
            mediaImageView.image = nil
            schoolAdministratorImageView.image = nil
        case 2:
            parentImageView.image = nil
            highSchoolCoachImageView.image = nil
            adImageView.image = UIImage(named: "CheckmarkBlack")
            statisticianImageView.image = nil
            collegeCoachImageView.image = nil
            mediaImageView.image = nil
            schoolAdministratorImageView.image = nil
        case 3:
            parentImageView.image = nil
            highSchoolCoachImageView.image = nil
            adImageView.image = nil
            statisticianImageView.image = UIImage(named: "CheckmarkBlack")
            collegeCoachImageView.image = nil
            mediaImageView.image = nil
            schoolAdministratorImageView.image = nil
        case 4:
            parentImageView.image = nil
            highSchoolCoachImageView.image = nil
            adImageView.image = nil
            statisticianImageView.image = nil
            collegeCoachImageView.image = UIImage(named: "CheckmarkBlack")
            mediaImageView.image = nil
            schoolAdministratorImageView.image = nil
        case 5:
            parentImageView.image = nil
            highSchoolCoachImageView.image = nil
            adImageView.image = nil
            statisticianImageView.image = nil
            collegeCoachImageView.image = nil
            mediaImageView.image = UIImage(named: "CheckmarkBlack")
            schoolAdministratorImageView.image = nil
        case 6:
            parentImageView.image = nil
            highSchoolCoachImageView.image = nil
            adImageView.image = nil
            statisticianImageView.image = nil
            collegeCoachImageView.image = nil
            mediaImageView.image = nil
            schoolAdministratorImageView.image = UIImage(named: "CheckmarkBlack")
        default:
            parentImageView.image = UIImage(named: "CheckmarkBlack")
            highSchoolCoachImageView.image = nil
            adImageView.image = nil
            statisticianImageView.image = nil
            collegeCoachImageView.image = nil
            mediaImageView.image = nil
            schoolAdministratorImageView.image = nil
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func cancelButtonTouched()
    {
        self.delegate?.userTypeSelectorViewControllerDidCancel()
    }
    
    @IBAction func saveButtonTouched()
    {
        // Call the API to update the user's info
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        let userType = kRoleValues[selectedIndex]
        
        NewFeeds.updateUserInfo(firstName: "", lastName: "", birthdate: "", gender: "", zipcode: "", userType: userType) { statusCode, error in
            
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
                if (statusCode == 200)
                {
                    // Update the user's prefs
                    kUserDefaults.set(userType, forKey: kUserTypeKey)
                    
                    self.delegate?.userTypeSelectorViewControllerDidSave()
                }
                else if (statusCode == 400)
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Oops", message: "There is a problem updating your role.", lastItemCancelType: false) { tag in
                        
                    }
                }
                else
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "A server error has occurred.", lastItemCancelType: false) { tag in
                        
                    }
                }
            }
            else
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "A server error has occurred.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    @IBAction func parentButtonTouched()
    {
        selectedIndex = 0
        self.setButtonImage()
    }
    
    @IBAction func highSchoolCoachButtonTouched()
    {
        selectedIndex = 1
        self.setButtonImage()
    }
    
    @IBAction func adButtonTouched()
    {
        selectedIndex = 2
        self.setButtonImage()
    }
    
    @IBAction func statisticianButtonTouched()
    {
        selectedIndex = 3
        self.setButtonImage()
    }
    
    @IBAction func collegeCoachButtonTouched()
    {
        selectedIndex = 4
        self.setButtonImage()
    }
    
    @IBAction func mediaButtonTouched()
    {
        selectedIndex = 5
        self.setButtonImage()
    }
    
    @IBAction func schoolAdministratorButtonTouched()
    {
        selectedIndex = 6
        self.setButtonImage()
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        fakeStatusBar.backgroundColor = .clear

        // Size the fakeStatusBar, navBar, and containerScrollView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight + 24)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        containerView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height)

        navView.layer.cornerRadius = 12
        navView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        //navView.clipsToBounds = true
        
        // Add a shadow to the navView
        let shadowPath = UIBezierPath(rect: navView.bounds)
        navView.layer.masksToBounds = false
        navView.layer.shadowColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        navView.layer.shadowOffset = CGSize(width: 0, height: -3)
        navView.layer.shadowOpacity = 0.5
        navView.layer.shadowPath = shadowPath.cgPath
        
        saveButton.layer.cornerRadius = 8.0
        saveButton.clipsToBounds = true
        
        selectedIndex = 0
        self.setButtonImage()

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
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        /*
        // Add some delay so the view is partially showing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
        {
            UIView.animate(withDuration: 0.3)
            { [self] in
                fakeStatusBar.backgroundColor = UIColor(white: 0, alpha: 0.2)
            }
        }
        */
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
}
