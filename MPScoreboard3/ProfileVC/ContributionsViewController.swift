//
//  ContributionsViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/14/23.
//

import UIKit

class ContributionsViewController: UIViewController
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var finalScoreCountLabel: UILabel!
    @IBOutlet weak var liveScoreCountLabel: UILabel!
    @IBOutlet weak var videoCountLabel: UILabel!
    
    var profileData: Dictionary<String,Any> = [:]
    
    private var videoListArray = [] as Array<Dictionary<String,Any>>
    private var progressOverlay: ProgressHUD!
    
    private var webVC: WebViewController!
    private var videoContributionsListVC: VideoContributionsListViewController!
    
    // MARK: - Get Video List
    
    private func getVideoList()
    {
        videoListArray.removeAll()
        
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.getUserVideoContributions { videos, error in
            
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
                print("Get Video Contributions Success")
                
                for video in videos!
                {
                    let uploadStatus = (video["uploadStatus"] as! NSNumber).intValue
                    
                    if (uploadStatus == 2) || (uploadStatus == 7)
                    {
                        self.videoListArray.append(video)
                    }
                }
                
                self.videoCountLabel.text = String(self.videoListArray.count)
            }
            else
            {
                print("Get Video Contributions Failed")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "There was a problem finding the video count.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func myVideosButtonTouched(_ sender: UIButton)
    {
        videoContributionsListVC = VideoContributionsListViewController(nibName: "VideoContributionsListViewController", bundle: nil)
        self.navigationController?.pushViewController(videoContributionsListVC, animated: true)
    }
    
    @IBAction func faqButtonTouched(_ sender: UIButton)
    {
        self.hidesBottomBarWhenPushed = true
        
        webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC.titleString = "Contributions FAQ"
        //webVC.urlString = "https://support.maxpreps.com/hc/en-us/articles/1260801147750"
        webVC.urlString = "https://support.maxpreps.com/hc/en-us/articles/16431716681115"
        webVC.titleColor = UIColor.mpBlackColor()
        webVC.navColor = UIColor.mpWhiteColor()
        webVC.allowRotation = false
        webVC.showShareButton = false
        webVC.showScrollIndicators = false
        webVC.showLoadingOverlay = true
        webVC.showBannerAd = false
        webVC.tabBarVisible = false
        webVC.enableAdobeQueryParameter = true

        self.navigationController?.pushViewController(webVC, animated: true)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
                
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        containerView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height)
        
        innerContainerView.layer.cornerRadius = 8.0
        innerContainerView.clipsToBounds = true
        
        //let test = profileData
        let qualityGames = profileData["qualityGames"] as? Int ?? 0
        let acceptedScoreCount = profileData["acceptedScoreCount"] as? Int ?? 0
        
        finalScoreCountLabel.text = String(acceptedScoreCount)
        liveScoreCountLabel.text = String(qualityGames)
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.getVideoList()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
 
        if (webVC != nil)
        {
            webVC = nil
        }
        
        if (videoContributionsListVC != nil)
        {
            videoContributionsListVC = nil
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
