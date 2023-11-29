//
//  JoinTeamCoachRequestViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/28/22.
//

import UIKit

class JoinTeamCoachRequestViewController: UIViewController
{
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var successContainerView: UIView!
    @IBOutlet weak var successTitleLabel: UILabel!
    @IBOutlet weak var successMessageLabel: UILabel!
    @IBOutlet weak var successFinishButton: UIButton!
    
    @IBOutlet weak var failedContainerView: UIView!
    @IBOutlet weak var schoolContainerView: UIView!
    @IBOutlet weak var failedMessageLabel: UILabel!
    @IBOutlet weak var failedFinishButton: UIButton!
    @IBOutlet weak var supportLabel: UILabel!
    @IBOutlet weak var mascotContainerView: UIView!
    @IBOutlet weak var mascotImageView: UIImageView!
    @IBOutlet weak var initialLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var sportLabel: UILabel!
    
    var selectedTeam : Team?
    var message = ""
    var status = -1
    
    var webVC: WebViewController!
    
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
    
    @IBAction func finishButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func supportButtonTouched(_ sender: UIButton)
    {
        self.showWebViewController(title: "Support", urlString: "https://support.maxpreps.com/hc/en-us/requests/new?ticket_form_id=1260804029810")
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        navView.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight + 44)
        successContainerView.frame = CGRect(x: 0, y: navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.size.height)
        failedContainerView.frame = CGRect(x: 0, y: navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.size.height)
        
        successFinishButton.layer.cornerRadius = successFinishButton.frame.size.height / 2.0
        failedFinishButton.layer.cornerRadius = failedFinishButton.frame.size.height / 2.0
        schoolContainerView.layer.cornerRadius = 12
        mascotContainerView.layer.cornerRadius = mascotContainerView.frame.size.height / 2.0
        
        successFinishButton.clipsToBounds = true
        failedFinishButton.clipsToBounds = true
        schoolContainerView.clipsToBounds = true
        mascotContainerView.clipsToBounds = true
        
        /*
         AutoAccepted = 1,
         TicketCreated = 2,
         TooManyCoaches = 3,
         */
        
        let genderSportLevel = MiscHelper.genderSportLevelFrom(gender: selectedTeam!.gender, sport: selectedTeam!.sport, level: selectedTeam!.teamLevel)
        
        if (status == 1)
        {
            failedContainerView.isHidden = true
            
            successTitleLabel.text = "You're All Set!"
            successMessageLabel.text = String(format: "You now have Coach Admin Access to %@ where you can manage all of your team's information such as your roster, schedule, scores, stats, and more.", genderSportLevel)
        }
        else if (status == 2)
        {
            failedContainerView.isHidden = true
            
            successTitleLabel.text = "Request Sent!"
            successMessageLabel.text = "Your request for Admin Access has been submitted. Please allow 1-2 business days for an email response."
            
            // Resize the successMessageLabel so the top text is aligned
            let height = successMessageLabel.text!.height(withConstrainedWidth: kDeviceWidth - 40, font: UIFont.mpLightFontWith(size: 20))
            successMessageLabel.frame = CGRect(x: 20, y: successMessageLabel.frame.origin.y, width: kDeviceWidth - 40, height: height + 8)
        }
        else
        {
            successContainerView.isHidden = true
            
            failedMessageLabel.text = self.message
            schoolNameLabel.text = self.selectedTeam!.schoolFullName
            sportLabel.text = genderSportLevel
            
            // Resize the failedMessageLabel so the top of the text is aligned.
            let height = self.message.height(withConstrainedWidth: kDeviceWidth - 40, font: UIFont.mpRegularFontWith(size: 17))
            failedMessageLabel.frame = CGRect(x: 20, y: failedMessageLabel.frame.origin.y, width: kDeviceWidth - 40, height: height + 4)
            
            // Underline and bold the supportLabel text
            let buttonText = "If you believe this is an error, please contact our support team."
            let attributedString = NSMutableAttributedString(string: buttonText)
            
            let range = buttonText.range(of: "support team")
            let convertedRange = NSRange(range!, in: buttonText)

            attributedString.addAttributes([NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue, NSAttributedString.Key.font: UIFont.mpSemiBoldFontWith(size: 17), NSAttributedString.Key.foregroundColor: UIColor.mpWhiteColor()], range: convertedRange)
                        
            supportLabel.attributedText = attributedString
            
            initialLabel.textColor = ColorHelper.color(fromHexString: self.selectedTeam!.teamColor, colorCorrection: true)
            initialLabel.text = self.selectedTeam!.schoolName.first?.uppercased()
            
            let mascotUrlString = self.selectedTeam!.mascotUrl
            
            if (mascotUrlString.count > 0)
            {
                // Get the data and make an image
                let url = URL(string: mascotUrlString)
                
                MiscHelper.getData(from: url!) { data, response, error in
                    guard let data = data, error == nil else { return }

                    DispatchQueue.main.async()
                    {
                        let image = UIImage(data: data)
                        
                        if (image != nil)
                        {
                            self.initialLabel.isHidden = true
                            MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.mascotImageView)!)
                        }
                    }
                }
            }
        }
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
