//
//  VideoContributionsListViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 1/3/23.
//

import UIKit

class VideoContributionsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, VideoContributionsMoreSelectorViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var videoCountLabel: UILabel!
    @IBOutlet weak var videoListTableView: UITableView!
    @IBOutlet weak var noVideosOverlayView: UIView!
    @IBOutlet weak var noVideosImageView: UIImageView!
    @IBOutlet weak var noVideosTextContainerView: UIView!
    
    private var videoListArray = [] as Array<Dictionary<String,Any>>
    private var selectedVideoIndex = 0
    private var moreSelectorView: VideoContributionsMoreSelectorView!
    private var videoDetailVC: VideoContributionsDetailViewController!
    private var videoEditorVC: VideoContributionsEditorViewController!
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Delete Video
    
    private func deleteUserContributionsVideo(videoId: String)
    {
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.deleteUserContributionsVideo(videoId: videoId) { error in
            
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
                print("Delete Video Success")
                // Show the toast and pop the view when it is done
                OverlayView.showPopupOverlay(withMessage: "Video Deleted")
                {
                    self.getVideoList()
                }
            }
            else
            {
                print("Delete Video Failed")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "There was a problem deleting this video.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
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
                
                self.videoCountLabel.text = String(format: "%d Videos", self.videoListArray.count)
                self.videoListTableView.isHidden = false
                
                if (self.videoListArray.count == 0)
                {
                    self.noVideosOverlayView.isHidden = false
                }
                else
                {
                    self.noVideosOverlayView.isHidden = true
                }
            }
            else
            {
                print("Get Video Contributions Failed")
                
                self.videoListTableView.isHidden = true
                self.noVideosOverlayView.isHidden = true
                self.videoCountLabel.text = ""
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "There was a problem finding your videos.", lastItemCancelType: false) { tag in
                    
                }
            }
            
            self.videoListTableView.reloadData()
        }
    }
    
    // MARK: - VideoContributionsMoreSelectorViewDelegate
    
    func videoContributionsMoreSelectorViewDidSelectItem(index: Int)
    {
        moreSelectorView.removeFromSuperview()
        moreSelectorView = nil
        
        // Find the selected tableViewCell and restore it
        if let selectedCell = videoListTableView.cellForRow(at: IndexPath(row: selectedVideoIndex, section: 0)) as? VideoContributionsListTableViewCell
        {
            selectedCell.restoreCell()
        }
        
        let videoObj = videoListArray[selectedVideoIndex]
        
        switch index
        {
        case 0:
            videoEditorVC = VideoContributionsEditorViewController(nibName: "VideoContributionsEditorViewController", bundle: nil)
            videoEditorVC.selectedVideoObj = videoObj
            self.navigationController?.pushViewController(videoEditorVC, animated: true)
            
        case 1:
            let videoUrlString = videoObj["canonicalUrl"] as! String
            
            if (videoUrlString.count > 0)
            {
                // Call the Bitly feed to compress the URL
                NewFeeds.getBitlyUrl(videoUrlString) { (dictionary, error) in
          
                    var dataToShare = [kShareMessageText + videoUrlString]
                    
                    if (error == nil)
                    {
                        print("Done")
                        if let shortUrl = dictionary!["data"] as? String
                        {
                            if (shortUrl.count > 0)
                            {
                                dataToShare = [kShareMessageText + shortUrl]
                            }
                        }
                    }
                    
                    let activityVC = UIActivityViewController(activityItems: dataToShare, applicationActivities: nil)
                    activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop]
                    activityVC.modalPresentationStyle = .fullScreen
                    self.present(activityVC, animated: true)
                }
            }
            else
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This video can not be shared.", lastItemCancelType: false) { tag in
                    
                }
            }
            
        case 2:
            let videoId = videoObj["videoId"] as! String
            print(videoId)
            //let message = String(format: "This video will be permanently deleted from MaxPreps. VideoId: %@", videoId)
            MiscHelper.showAlert(in: self, withActionNames: ["Cancel", "Delete"], title: "Delete Video?", message: "This video will be permanently deleted from MaxPreps.", lastItemCancelType: true) { tag in
                
                if (tag == 1)
                {
                    self.deleteUserContributionsVideo(videoId: videoId)
                }
            }
        default:
            return
        }
    }
    
    func videoContributionsMoreSelectorViewDidCancel()
    {
        moreSelectorView.removeFromSuperview()
        moreSelectorView = nil
        
        // Find the selected tableViewCell and restore it
        if let selectedCell = videoListTableView.cellForRow(at: IndexPath(row: selectedVideoIndex, section: 0)) as? VideoContributionsListTableViewCell
        {
            selectedCell.restoreCell()
        }
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return videoListArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 98.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 24.0 //0.01
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "VideoContributionsListTableViewCell") as? VideoContributionsListTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("VideoContributionsListTableViewCell", owner: self, options: nil)
            cell = nib![0] as? VideoContributionsListTableViewCell
        }
        
        cell?.selectionStyle = .none
        
        cell?.moreButton.tag = 100 + indexPath.row
        cell?.moreButton.addTarget(self, action: #selector(moreButtonTouched(_:)), for: .touchUpInside)
        
        let videoObj = videoListArray[indexPath.row]
        cell?.loadData(videoObj)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let videoObj = videoListArray[indexPath.row]
        
        videoDetailVC = VideoContributionsDetailViewController(nibName: "VideoContributionsDetailViewController", bundle: nil)
        videoDetailVC.selectedVideoObj = videoObj
        let videoDetailsNav = TopNavigationController()
        videoDetailsNav.viewControllers = [videoDetailVC] as Array
        videoDetailsNav.modalPresentationStyle = .fullScreen
        self.present(videoDetailsNav, animated: true)
        {
            
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func moreButtonTouched(_ sender: UIButton)
    {
        selectedVideoIndex = sender.tag - 100
        let cellTop = (selectedVideoIndex * 98) - Int(videoListTableView.contentOffset.y)
        
        let buttonFrame = CGRect(x: kDeviceWidth - 50.0, y: videoListTableView.frame.origin.y + CGFloat(cellTop) + 20.0, width: 40.0, height: 20.0)
        
        moreSelectorView = VideoContributionsMoreSelectorView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight), buttonFrame: buttonFrame)
        moreSelectorView.delegate = self
        
        self.view.addSubview(moreSelectorView)
        
        // Find the selected tableViewCell and highlight it
        if let selectedCell = videoListTableView.cellForRow(at: IndexPath(row: selectedVideoIndex, section: 0)) as? VideoContributionsListTableViewCell
        {
            selectedCell.highlightCell()
        }
        
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Size the fakeStatusBar, navBar, and scrollView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        videoListTableView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height)
        noVideosOverlayView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + 44.0, width: kDeviceWidth, height: kDeviceHeight - fakeStatusBar.frame.size.height - 44.0)
        
        // Calculate the noVideoImageView height
        let scale = kDeviceWidth / 375.0
        let height = 253.0 * scale
        
        // Scale the imageView and shift the textContainer
        noVideosImageView.frame = CGRect(x: 0, y: 0, width: kDeviceWidth, height: height)
        noVideosTextContainerView.frame = CGRect(x: 0, y: height, width: kDeviceWidth, height: noVideosTextContainerView.frame.size.height)
        
        videoCountLabel.text = ""
        noVideosOverlayView.isHidden = true
        
        // Tracking
        let trackingGuid = NSUUID().uuidString
        TrackingManager.trackState(featureName: "contributions-videos", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
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
        
        self.getVideoList()
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (videoDetailVC != nil)
        {
            videoDetailVC = nil
        }
        
        if (videoEditorVC != nil)
        {
            videoEditorVC = nil
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
