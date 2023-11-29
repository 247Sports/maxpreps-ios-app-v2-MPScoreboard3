//
//  VideoSettingsViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/14/22.
//

import UIKit

class VideoSettingsViewController: UIViewController
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var allAutoplayImageView: UIImageView!
    @IBOutlet weak var wifiAutoplayImageView: UIImageView!
    @IBOutlet weak var noAutoplayImageView: UIImageView!
    //@IBOutlet weak var pipSwitch: UISwitch!
    @IBOutlet weak var audioMixSwitch: UISwitch!
    
    // MARK: - Switch Methods

    @IBAction func audioMixSwitchChanged(_ sender: UISwitch)
    {
        kUserDefaults.setValue(NSNumber.init(booleanLiteral: sender.isOn), forKey: kAudioMixEnableKey)
    }
    
    // MARK: - Update Buttons
    
    private func updateButtons()
    {
        let autoplayMode = kUserDefaults.value(forKey: kVideoAutoplayModeKey) as! Int
        
        switch autoplayMode
        {
        case 0:
            noAutoplayImageView.image = UIImage(named: "CheckmarkRed")
            wifiAutoplayImageView.image = nil
            allAutoplayImageView.image = nil
            break
        case 1:
            noAutoplayImageView.image = nil
            wifiAutoplayImageView.image = UIImage(named: "CheckmarkRed")
            allAutoplayImageView.image = nil
            break
        case 2:
            noAutoplayImageView.image = nil
            wifiAutoplayImageView.image = nil
            allAutoplayImageView.image = UIImage(named: "CheckmarkRed")
            break
        default:
            break
        }
    }
    
    // MARK: - Gesture Recognizer Method
    
    @objc private func handleTripleTap()
    {
        MiscHelper.showAlert(in: self, withActionNames: ["On", "Off"], title: "Debug Mode", message: "", lastItemCancelType: false) { (tag) in
            if (tag == 0)
            {
                kUserDefaults.setValue(NSNumber(booleanLiteral: true), forKey: kDebugDialogsKey)
            }
            else
            {
                kUserDefaults.setValue(NSNumber(booleanLiteral: false), forKey: kDebugDialogsKey)
            }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.loadGoolgeAdIds()
        }
        
        // Reset any "one time display" keys here for testing
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtontouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func noAutoplayButtontouched(_ sender: UIButton)
    {
        kUserDefaults.setValue(NSNumber.init(value: 0), forKey: kVideoAutoplayModeKey)
        self.updateButtons()
    }
    
    @IBAction func wifiAutoplayButtontouched(_ sender: UIButton)
    {
        kUserDefaults.setValue(NSNumber.init(value: 1), forKey: kVideoAutoplayModeKey)
        self.updateButtons()
    }
    
    @IBAction func allAutoplayButtontouched(_ sender: UIButton)
    {
        kUserDefaults.setValue(NSNumber.init(value: 2), forKey: kVideoAutoplayModeKey)
        self.updateButtons()
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        containerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height)
        
        let tripleTap = UITapGestureRecognizer(target: self, action: #selector(handleTripleTap))
        tripleTap.numberOfTapsRequired = 3
        
        let hiddenTouchRegion = UIView(frame: CGRect(x: (kDeviceWidth - 240) / 2.0, y: containerView.frame.size.height - 130 - CGFloat(SharedData.bottomSafeAreaHeight), width: 240.0, height: 130.0))
        hiddenTouchRegion.backgroundColor = .clear
        hiddenTouchRegion.isMultipleTouchEnabled = true
        hiddenTouchRegion.isUserInteractionEnabled = true
        hiddenTouchRegion.addGestureRecognizer(tripleTap)
        containerView.addSubview(hiddenTouchRegion)
        
        audioMixSwitch.isOn = kUserDefaults.bool(forKey: kAudioMixEnableKey)
        audioMixSwitch.onTintColor = UIColor.mpRedColor()
        
        // Tracking
        let trackingGuid = NSUUID().uuidString
        TrackingManager.trackState(featureName: "video-settings", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.updateButtons()
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
