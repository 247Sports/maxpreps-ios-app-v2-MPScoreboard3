//
//  JoinTeamStatisticianSuccessViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/6/22.
//

import UIKit

class JoinTeamStatisticianSuccessViewController: UIViewController
{
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var supportLabel: UILabel!
    
    var webVC: WebViewController!
    var requestSent = false
    
    // MARK: - Button Methods
    
    @IBAction func finishButtonTouched()
    {
        self.navigationController?.popViewController(animated: false)
        self.requestSent = true
    }
    
    @IBAction func supportButtonTouched(_ sender: UIButton)
    {
        webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC?.titleString = "Support"
        webVC?.urlString = "https://support.maxpreps.com/hc/en-us/requests/new"
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
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        navView.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight + 44)
        containerView.frame = CGRect(x: 0, y: navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight))
        
        finishButton.layer.cornerRadius = finishButton.frame.size.height / 2.0
        finishButton.clipsToBounds = true
        
        // Underline and bold the supportLabel text
        let buttonText = "For questions or concerns, please reach out to our support team."
        let attributedString = NSMutableAttributedString(string: buttonText)
        
        let range = buttonText.range(of: "support team")
        let convertedRange = NSRange(range!, in: buttonText)

        attributedString.addAttributes([NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 17), NSAttributedString.Key.foregroundColor: UIColor.mpWhiteColor()], range: convertedRange)
                    
        supportLabel.attributedText = attributedString
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
}
