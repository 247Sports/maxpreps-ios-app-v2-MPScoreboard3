//
//  LoginLandingViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/15/22.
//

import UIKit

protocol LoginLandingViewControllerDelegate: AnyObject
{
    func loginLandingFinished()
}

class LoginLandingViewController: UIViewController, IQActionSheetPickerViewDelegate
{
    weak var delegate: LoginLandingViewControllerDelegate?
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var guestButton: UIButton!
    @IBOutlet weak var hostLabel: UILabel!
    @IBOutlet weak var oldLoginButton: UIButton!
    @IBOutlet weak var leftScrollView: UIScrollView!
    @IBOutlet weak var rightScrollView: UIScrollView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var splashView: UIView!
    @IBOutlet weak var animationContainerView: UIView!
    @IBOutlet weak var lowerAnimationContainerView: UIView!
    @IBOutlet weak var imageCoverView: UIView!
    
    private var oldLoginVC: OldLoginViewController!
    private var loginVC: LoginViewController!
    private var newAccountEmailVC: NewAccountEmailViewController!
    private var claimAthleteLandingVC: ClaimAthleteLandingViewController!
    
    private var tickTimer1: Timer!
    private var tickTimer2: Timer!
    
    let hostValues = ["Production","Staging","Dev","Branch-A","Branch-B","Branch-C","Branch-D","Branch-E","Branch-F","Branch-G"]

    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelectTitles titles: [String])
    {
        let title = titles.first
        
        switch title
        {
        case "Production":
            kUserDefaults.setValue(kServerModeProduction, forKey: kServerModeKey)
            kUserDefaults.setValue("", forKey: kBranchValue)
            hostLabel.text = ""
            break
        case "Staging":
            kUserDefaults.setValue(kServerModeStaging, forKey: kServerModeKey)
            kUserDefaults.setValue("", forKey: kBranchValue)
            hostLabel.text = "Staging Server"
            break
        case "Dev":
            kUserDefaults.setValue(kServerModeDev, forKey: kServerModeKey)
            kUserDefaults.setValue("", forKey: kBranchValue)
            hostLabel.text = "Dev Server"
            break
        case "Branch-A":
            kUserDefaults.setValue(kServerModeBranch, forKey: kServerModeKey)
            kUserDefaults.setValue("A", forKey: kBranchValue)
            hostLabel.text = "Branch-A Server"
            break
        case "Branch-B":
            kUserDefaults.setValue(kServerModeBranch, forKey: kServerModeKey)
            kUserDefaults.setValue("B", forKey: kBranchValue)
            hostLabel.text = "Branch-B Server"
            break
        case "Branch-C":
            kUserDefaults.setValue(kServerModeBranch, forKey: kServerModeKey)
            kUserDefaults.setValue("C", forKey: kBranchValue)
            hostLabel.text = "Branch-C  Server"
            break
        case "Branch-D":
            kUserDefaults.setValue(kServerModeBranch, forKey: kServerModeKey)
            kUserDefaults.setValue("D", forKey: kBranchValue)
            hostLabel.text = "Branch-D Server"
            break
        case "Branch-E":
            kUserDefaults.setValue(kServerModeBranch, forKey: kServerModeKey)
            kUserDefaults.setValue("E", forKey: kBranchValue)
            hostLabel.text = "Branch-E Server"
            break
        case "Branch-F":
            kUserDefaults.setValue(kServerModeBranch, forKey: kServerModeKey)
            kUserDefaults.setValue("F", forKey: kBranchValue)
            hostLabel.text = "Branch-F Server"
            break
        case "Branch-G":
            kUserDefaults.setValue(kServerModeBranch, forKey: kServerModeKey)
            kUserDefaults.setValue("G", forKey: kBranchValue)
            hostLabel.text = "Branch-G Server"
            break
        default:
            kUserDefaults.setValue(kServerModeProduction, forKey: kServerModeKey)
            kUserDefaults.setValue("", forKey: kBranchValue)
            hostLabel.text = ""
            break
        }
    }
    
    func actionSheetPickerViewDidCancel(_ pickerView: IQActionSheetPickerView)
    {
        
    }
    
    // MARK: - Create Account Notification Method
    
    @objc private func createAccountFinished()
    {
        // This notification is sent by the roleVC once an account is successfully created.
        
        // A small delay is added so the views on the stack will disappear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
        {
            let userType = kUserDefaults.string(forKey: kUserTypeKey)
            var isAthlete = false
            
            if (userType == "Athlete")
            {
                isAthlete = true
            }
            
            // Put the code here that steers the user to the link athlete flow
            if (self.claimAthleteLandingVC != nil)
            {
                self.claimAthleteLandingVC = nil
            }
            
            self.claimAthleteLandingVC = ClaimAthleteLandingViewController(nibName: "ClaimAthleteLandingViewController", bundle: nil)
            self.claimAthleteLandingVC.userIsAthlete = isAthlete
            self.navigationController?.pushViewController(self.claimAthleteLandingVC, animated: true)
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func oldLoginButtonTouched(_ sender: UIButton)
    {
        if (oldLoginVC != nil)
        {
            oldLoginVC = nil
        }
        
        oldLoginVC = OldLoginViewController(nibName: "OldLoginViewController", bundle: nil)
        self.navigationController?.pushViewController(oldLoginVC, animated: true)
    }
    
    @IBAction func testModalsButtonTouched(_ sender: UIButton)
    {
        let testModalVC = TestModalViewController(nibName: "TestModalViewController", bundle: nil)
        self.navigationController?.pushViewController(testModalVC, animated: true)
    }
    
    @IBAction func testClaimButtonTouched(_ sender: UIButton)
    {
        // Put the code here that steers the user to the link athlete flow
        if (self.claimAthleteLandingVC != nil)
        {
            self.claimAthleteLandingVC = nil
        }
        
        self.claimAthleteLandingVC = ClaimAthleteLandingViewController(nibName: "ClaimAthleteLandingViewController", bundle: nil)
        self.claimAthleteLandingVC.userIsAthlete = false
        self.navigationController?.pushViewController(self.claimAthleteLandingVC, animated: true)
    }
    
    @IBAction func testClaimButton2Touched(_ sender: UIButton)
    {
        // Put the code here that steers the user to the link athlete flow
        if (self.claimAthleteLandingVC != nil)
        {
            self.claimAthleteLandingVC = nil
        }
        
        self.claimAthleteLandingVC = ClaimAthleteLandingViewController(nibName: "ClaimAthleteLandingViewController", bundle: nil)
        self.claimAthleteLandingVC.userIsAthlete = true
        self.navigationController?.pushViewController(self.claimAthleteLandingVC, animated: true)
    }
    
    @IBAction func loginButtonTouched(_ sender: UIButton)
    {
        if (loginVC != nil)
        {
            loginVC = nil
        }
        
        loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
    @IBAction func joinButtonTouched(_ sender: UIButton)
    {
        if (newAccountEmailVC != nil)
        {
            newAccountEmailVC = nil
        }
        
        newAccountEmailVC = NewAccountEmailViewController(nibName: "NewAccountEmailViewController", bundle: nil)
        self.navigationController?.pushViewController(newAccountEmailVC, animated: true)
    }
    
    @IBAction func loginGuestUser(_ sender: UIButton)
    {
        kUserDefaults.setValue(kTestDriveUserId, forKey: kUserIdKey)
        kUserDefaults.setValue(kDefaultSchoolLocation, forKey: kCurrentLocationKey)
        kUserDefaults.setValue("99999", forKey: kUserZipKey)
        kUserDefaults.setValue("Guest", forKey: kUserTypeKey)
        
        // Set the token buster
        let now = NSDate()
        let timeInterval = Int(now.timeIntervalSinceReferenceDate)
        kUserDefaults.setValue(String(timeInterval), forKey: kTokenBusterKey)
        
        // Set the app id cookie
        MiscHelper.setAppIdCookie()
        
        self.delegate?.loginLandingFinished()
        
        // Post a notification that the favorite teams have been updated
        NotificationCenter.default.post(name: Notification.Name("FavoriteTeamsUpdated"), object: nil)
    }
    
    // MARK: - Timers
    
    @objc private func timer1Expired()
    {
        let endY = leftScrollView.contentSize.height - leftScrollView.frame.size.height
        let yScroll = leftScrollView.contentOffset.y
        
        if (yScroll < endY)
        {
            leftScrollView.setContentOffset(CGPoint(x: 0, y: yScroll + 1), animated: false)
        }
        else
        {
            // Reset the scrollViews
            leftScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
    }
    
    @objc private func timer2Expired()
    {
        let endY = rightScrollView.contentSize.height - rightScrollView.frame.size.height
        let yScroll = rightScrollView.contentOffset.y
        
        if (yScroll < endY)
        {
            rightScrollView.setContentOffset(CGPoint(x: 0, y: yScroll + 1), animated: false)
        }
        else
        {
            // Reset the scrollViews
            rightScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
    }
    
    // MARK: - Gesture Recognizer Method
    
    @objc private func handleTripleTap()
    {
        let picker = IQActionSheetPickerView(title: "Select Host", delegate: self)
        picker.toolbarButtonColor = UIColor.mpWhiteColor()
        picker.toolbarTintColor = UIColor.mpPickerToolbarColor()
        picker.titlesForComponents = [hostValues]
        picker.show()
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        loginButton.layer.cornerRadius = loginButton.frame.size.height / 2.0
        loginButton.clipsToBounds = true
        
        joinButton.layer.cornerRadius = joinButton.frame.size.height / 2.0
        joinButton.layer.borderWidth = 1
        joinButton.layer.borderColor = UIColor.mpWhiteColor().cgColor
        joinButton.clipsToBounds = true
        
        let attributedString = NSMutableAttributedString(string: "Continue as guest", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 15), NSAttributedString.Key.foregroundColor: UIColor.mpWhiteColor()])
        
        guestButton.setAttributedTitle(attributedString, for: .normal)
        
        // Set the gradientView frame
        let gradientHeight = kDeviceHeight - 308
        
        gradientView.frame = CGRect(x: 0, y: 0, width: kDeviceWidth, height: gradientHeight)
        let topColor = UIColor(white: 0, alpha: 0.5)
        let bottomColor = UIColor(white: 0, alpha: 1.0)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: kDeviceWidth, height: gradientHeight)
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
        lowerAnimationContainerView.frame = CGRect(x: 0, y: gradientHeight, width: kDeviceWidth, height: kDeviceHeight - gradientHeight)
        imageCoverView.frame = CGRect(x: 0, y: 0, width: kDeviceWidth, height: gradientHeight)
        imageCoverView.alpha = 0
        
        let tripleTap = UITapGestureRecognizer(target: self, action: #selector(handleTripleTap))
        tripleTap.numberOfTapsRequired = 3
        
        let hiddenTouchRegion = UIView(frame: CGRect(x: (kDeviceWidth - 240) / 2.0, y: CGFloat(SharedData.topNotchHeight), width: 240.0, height: 130.0))
        hiddenTouchRegion.backgroundColor = .clear
        hiddenTouchRegion.isMultipleTouchEnabled = true
        hiddenTouchRegion.isUserInteractionEnabled = true
        hiddenTouchRegion.addGestureRecognizer(tripleTap)
        self.view.addSubview(hiddenTouchRegion)
        
        oldLoginButton.isHidden = true
        
        #if DEBUG
        oldLoginButton.isHidden = false
        #endif
        
        // Set the scrollView frames. The spacing is 10 pixels
        let scrollWidth = (kDeviceWidth - 10) / 2.0
        
        leftScrollView.frame = CGRect(x: 0, y: 0, width: scrollWidth, height: gradientHeight)
        rightScrollView.frame = CGRect(x: scrollWidth + 10, y: 0, width: scrollWidth, height: gradientHeight)
        
        // Set the scrollView content size to match the embedded image (2649 tall)
        leftScrollView.contentSize = CGSize(width: scrollWidth, height: 2649)
        rightScrollView.contentSize = CGSize(width: scrollWidth, height: 2649)

        // This forces the content to start at the top
        leftScrollView.contentInsetAdjustmentBehavior = .never
        rightScrollView.contentInsetAdjustmentBehavior = .never
        
        // Add a notification handler that new account finished
        NotificationCenter.default.addObserver(self, selector: #selector(createAccountFinished), name: Notification.Name("CreateAccountFinished"), object: nil)
        
        // Animate the containerView if coming from a cold launch
        if (SharedData.coldLaunch == true)
        {
            SharedData.coldLaunch = false
            
            animationContainerView.transform = CGAffineTransform(translationX: kDeviceWidth, y: 0)
            lowerAnimationContainerView.transform = CGAffineTransform(translationX: 0, y: kDeviceHeight - lowerAnimationContainerView.frame.origin.y)
            imageCoverView.alpha = 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            {
                // Animate the first container to the left
                UIView.animate(withDuration: 0.33, animations: {
                    
                    self.animationContainerView.transform = CGAffineTransform(translationX: 0, y: 0)
                    
                })
                { (finished) in
                    
                    // Animate the lower container up
                    UIView.animate(withDuration: 0.48, animations: {
                        
                        self.lowerAnimationContainerView.transform = CGAffineTransform(translationX: 0, y: 0)
                        
                    })
                    { (finished) in
                        
                        // Animate the coverView to transparent
                        UIView.animate(withDuration: 0.67, animations: {
                            
                            self.imageCoverView.alpha = 0.0
                            
                        })
                        { (finished) in
                            
                            
                        }
                    }
                }
            }
        }
        
        // Tracking
        let trackingGuid = NSUUID().uuidString
        TrackingManager.trackState(featureName: "membership-landing", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            let branchValue = kUserDefaults .string(forKey: kBranchValue)
            hostLabel.text = String(format: "Branch-%@ Server", branchValue!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            hostLabel.text = "Dev Server"
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            hostLabel.text = "Staging Server"
        }
        else
        {
            hostLabel.text = ""
        }
        
        // Reset the scrollViews
        leftScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        rightScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        // Add a timer to check for valid fields
        if (tickTimer1 != nil)
        {
            tickTimer1.invalidate()
            tickTimer1 = nil
        }
        
        if (tickTimer2 != nil)
        {
            tickTimer2.invalidate()
            tickTimer2 = nil
        }
        tickTimer1 = Timer.scheduledTimer(timeInterval: 0.028, target: self, selector: #selector(timer1Expired), userInfo: nil, repeats: true)
        tickTimer2 = Timer.scheduledTimer(timeInterval: 0.025, target: self, selector: #selector(timer2Expired), userInfo: nil, repeats: true)
        
        if (claimAthleteLandingVC != nil)
        {
            // Placing this here is critical so the createAccount() method will happen afterwards.
            claimAthleteLandingVC = nil
            
            // The user either finished claiming an athlete or skipped
            self.delegate?.loginLandingFinished()
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (oldLoginVC != nil)
        {
            if (oldLoginVC.loginFinished == true)
            {
                self.delegate?.loginLandingFinished()
            }
            
            oldLoginVC = nil
        }
        
        if (loginVC != nil)
        {
            if (loginVC.loginFinished == true)
            {
                self.delegate?.loginLandingFinished()
            }
            
            loginVC = nil
        }
        
        if (newAccountEmailVC != nil)
        {
            newAccountEmailVC = nil
        }
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        if (tickTimer1 != nil)
        {
            tickTimer1.invalidate()
            tickTimer1 = nil
        }
        
        if (tickTimer2 != nil)
        {
            tickTimer2.invalidate()
            tickTimer2 = nil
        }
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
        if (tickTimer1 != nil)
        {
            tickTimer1.invalidate()
            tickTimer1 = nil
        }
        
        if (tickTimer2 != nil)
        {
            tickTimer2.invalidate()
            tickTimer2 = nil
        }
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("CreateAccountFinished"), object: nil)
    }
}
