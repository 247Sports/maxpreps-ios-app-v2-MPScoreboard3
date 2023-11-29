//
//  DeleteAccountViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/20/22.
//

import UIKit

class DeleteAccountViewController: UIViewController
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var deleteAccountButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var chevronImageView: UIImageView!
    
    private var webVC: WebViewController!
    
    var accountDeleted = false
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Delete User Account
    
    private func deleteUserAccount()
    {
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.deleteUserAccount { error in
            
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                //MBProgressHUD.hide(for: self.view, animated: true)
                if (self.progressOverlay != nil)
                {
                    self.progressOverlay.hide(animated: false)
                    self.progressOverlay = nil
                }
            }
            
            if (error == nil)
            {
                print("Delete User Account Success")
                
                // Logout in the parent VC when finished
                self.accountDeleted = true
                self.navigationController?.popViewController(animated: true)
            }
            else
            {
                print("Delete User Account Failed")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong while trying to delete the account.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - Show Web View Controller
    
    private func showWebViewController(title: String, urlString: String)
    {
        webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC?.titleString = title
        webVC?.urlString = urlString
        webVC?.titleColor = UIColor.mpBlackColor()
        webVC?.navColor = UIColor.mpWhiteColor()
        webVC?.allowRotation = false
        webVC?.showShareButton = false
        webVC?.showScrollIndicators = true
        webVC?.showLoadingOverlay = true
        webVC?.showBannerAd = false
        webVC?.tabBarVisible = false
        webVC?.enableAdobeQueryParameter = true

        self.navigationController?.pushViewController(webVC!, animated: true)
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func supportButtonTouched(_ sender: UIButton)
    {
        self.showWebViewController(title: "Support", urlString: kTechSupportUrl)
    }
    
    @IBAction func learnMoreButtonTouched(_ sender: UIButton)
    {
        self.showWebViewController(title: "Support", urlString: "https://support.maxpreps.com/hc/en-us/articles/4401990671771-Cancel-MaxPreps-Membership-or-Deleting-an-Athlete-Profile")
    }
    
    @IBAction func deleteAccountButtonTouched(_ sender: UIButton)
    {
        MiscHelper.showAlert(in: self, withActionNames: ["Cancel", "Delete"], title: "Delete My Account", message: "Are you sure you want to delete your MaxPreps account? All of your personalized settings will be lost and cannot be recovered.", lastItemCancelType: true) { tag in
            
            if (tag == 1)
            {
                self.deleteUserAccount()
            }
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        containerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight))
        
        deleteAccountButton.layer.cornerRadius = 8.0
        deleteAccountButton.layer.borderWidth = 1
        deleteAccountButton.layer.borderColor = UIColor.mpRedColor().cgColor
        deleteAccountButton.clipsToBounds = true
        
        //
        // Underline and bold the supportLabel text
        let messageText = "If you have any questions or wish to speak to someone regarding your account, please reach out to our support team."
        let attributedString = NSMutableAttributedString(string: messageText)
        
        let range = messageText.range(of: "support team")
        let convertedRange = NSRange(range!, in: messageText)

        attributedString.addAttributes([NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 16), NSAttributedString.Key.foregroundColor: UIColor.mpBlueColor()], range: convertedRange)
                    
        messageLabel.attributedText = attributedString
        
        chevronImageView.setImageColor(color: UIColor.mpBlueColor())
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
        
        if (webVC != nil)
        {
            webVC = nil
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
}
