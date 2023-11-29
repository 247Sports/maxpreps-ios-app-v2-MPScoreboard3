//
//  TeamVideoViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 7/12/22.
//

import UIKit

class TeamVideoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    
    var selectedTeam : Team?
    //var schoolId = ""
    //var allSeasonId = ""
    var trackingKey = ""
    var trackingContextData = kEmptyTrackingContextData
    
    private var videosCollectionView: UICollectionView!
    private var videosArray = [] as Array<Dictionary<String,Any>>
    private var videoHeaderObj = [:] as Dictionary<String,Any>
    
    //private var showFooter = false
    private var footerView: UIView!
    
    private var progressOverlay: ProgressHUD!
    private var videoPlayerVC: VideoPlayerViewController!
    
    // MARK: - Get Team Videos
    
    private func getTeamVideos()
    {
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.getTeamVideos(schoolId: self.selectedTeam!.schoolId, allSeasonId: self.selectedTeam!.allSeasonId, sortOrder: 0) { videos, error in
            
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
                print("Get Team Videos Success")
                
                self.videosCollectionView.isHidden = false
                
                if (videos!.count > 0)
                {
                    // Put the first item into the videoHeaderObj
                    self.videoHeaderObj = videos![0]
                    
                    // Fill the videosArray with all items, then remove the first
                    self.videosArray.append(contentsOf:videos!)
                    
                    self.videosArray.remove(at: 0)
                }
                
                /*
                for video in self.videosArray
                {
                    let videoId = video["videoId"] as! String
                    print(videoId)
                    
                    let renditions = video["renditions"] as! Array<Any>
                    
                    if (renditions.count == 0)
                    {
                        print("No rendition")
                    }
                }
                */
                self.videosCollectionView.reloadData()
            }
            else
            {
                print("Get Team Videos Failed")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "There was a problem getting the videos from the server.", lastItemCancelType: false) { (tag) in
                    
                }
            }
        }
    }
    
    // MARK: - Show Video Player
    
    private func showVideoPlayer(videoId: String)
    {
        videoPlayerVC = VideoPlayerViewController(nibName: "VideoPlayerViewController", bundle: nil)
        videoPlayerVC.videoIdString = videoId
        videoPlayerVC.trackingKey = self.trackingKey
        videoPlayerVC.trackingContextData = self.trackingContextData
        videoPlayerVC.modalPresentationStyle = .fullScreen
        self.present(videoPlayerVC, animated: true)
        {
            
        }
    }
    
    // MARK: - CollectionView Delegates
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        
        if (section == 0)
        {
            return 0
        }
        else
        {
            return videosArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        if (section == 0)
        {
            return CGSize(width: kDeviceWidth, height: 279.0)
        }
        else
        {
            if (videosArray.count > 0)
            {
                //return CGSize(width: kDeviceWidth, height: 82.0)
                return CGSize(width: kDeviceWidth, height: 8.0)
            }
            else
            {
                return CGSize(width: kDeviceWidth, height: 0.0)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    {
        if (section == 0)
        {
            return CGSize(width: kDeviceWidth, height: 0.0)
        }
        else
        {
            if (videosArray.count == 0)
            {
                return CGSize(width: kDeviceWidth, height: 376.0)
            }
            else if (videosArray.count == 1) || (videosArray.count == 2)
            {
                return CGSize(width: kDeviceWidth, height: 220.0)
            }
            else if (videosArray.count == 3) || (videosArray.count == 4)
            {
                return CGSize(width: kDeviceWidth, height: 64.0)
            }
            else
            {
                return CGSize(width: kDeviceWidth, height: 0.0 + 62)
            }
            
            /*
            let numberOfRows = videosArray.count / 2
            let remainder = videosArray.count % 2

            //print("Row Count: " + String(numberOfRows + remainder))
            let contentHeight = ((numberOfRows + remainder) * 156)
            let headerVisibleHeight = 279
            let collectionViewVisibleHeight = self.frame.size.height - 180
            let difference = Int(collectionViewVisibleHeight) - contentHeight - headerVisibleHeight
            print("Height Difference: " + String(difference))
            
            if (difference > 0) && (difference <= 180)
            {
                //let pad = 180 - difference
                return CGSize(width: kDeviceWidth, height: CGFloat(180))
            }
            else
            {
                return CGSize(width: kDeviceWidth, height: 0.0)
            }
            */
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        switch kind
        {
        case UICollectionView.elementKindSectionHeader:

            if (indexPath.section == 0)
            {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TeamVideosTopHeaderCollectionReusableView", for: indexPath as IndexPath) as! TeamVideosTopHeaderCollectionReusableView
                
                headerView.headerTitleLabel.text = ""
                headerView.videoThumbnailImageView.image = nil
                headerView.videoPlayButton.isHidden = false
                
                // Load the header and thumbnail with the first item from the videosArray
                if (videoHeaderObj["title"] != nil)
                {
                    let title = videoHeaderObj["title"] as! String
                    headerView.headerTitleLabel.text = title
                }
                
                headerView.videoPlayButton.addTarget(self, action: #selector(headerPlayButtonTouched), for: .touchUpInside)
                
                if (videoHeaderObj["thumbnailUrl"] != nil)
                {
                    let thumbnailUrl = videoHeaderObj["thumbnailUrl"] as! String
                    
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
                                    headerView.videoThumbnailImageView.image = image
                                }
                                else
                                {
                                    headerView.videoThumbnailImageView.image = UIImage(named: "EmptyVideo")
                                    headerView.videoPlayButton.isHidden = true
                                }
                            }
                        }
                    }
                    else
                    {
                        headerView.videoThumbnailImageView.image = UIImage(named: "EmptyVideo")
                        headerView.videoPlayButton.isHidden = true
                    }
                }
            
                return headerView
            }
            else
            {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TeamVideosHeaderCollectionReusableView", for: indexPath as IndexPath) as! TeamVideosHeaderCollectionReusableView

                // Add the sortMenu to the button
                //headerView.sortButton.menu = sortMenu
                //headerView.sortButton.showsMenuAsPrimaryAction = true
                //headerView.sortModeLabel.text = sortModeString
        
                return headerView
            }
            
        case UICollectionView.elementKindSectionFooter:

            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "VideosTabFooterCollectionReusableView", for: indexPath as IndexPath) as! VideosTabFooterCollectionReusableView
            
            footerView.getMoreButton.isHidden = true
            //footerView.getMoreButton.addTarget(self, action: #selector(getMoreButtonTouched), for: .touchUpInside)
            
            // Tint the get more button with the school color
            //let colorString = selectedAthlete?.schoolColor
            //let teamColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
            //footerView.getMoreButton.backgroundColor = teamColor
            
            //if (showFooter == true)
            //{
                // There are at least 25 items showing
                //footerView.getMoreButton.isHidden = false
            //}
            
            return footerView

        default:

            assert(false, "Unexpected element kind")
        }
        
        // Default (shouldn't happen, but this silences the warning)
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PhotosTabHeaderCollectionReusableView", for: indexPath as IndexPath) as! PhotosTabHeaderCollectionReusableView
        
        footerView.headerTitleLabel.text = ""
        return footerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        // Calculate the cell size based upon the screen width
        return CGSize(width: (kDeviceWidth - 60) / 2, height: CGFloat(156))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideosTabCollectionViewCell", for: indexPath) as! VideosTabCollectionViewCell
        
        let videoObj = videosArray[indexPath.item]
        
        cell.articleTitleLabel.text = ""
        cell.thumbnailImageView.image = nil
        cell.videoPlayIconImageView.isHidden = false
                
        if (videoObj["title"] != nil)
        {
            let title = videoObj["title"] as! String
            cell.articleTitleLabel.text = title
        }
        
        if (videoObj["thumbnailUrl"] != nil)
        {
            let thumbnailUrl = videoObj["thumbnailUrl"] as! String
            
            if (thumbnailUrl.count > 0)
            {
                let url = URL(string: thumbnailUrl)
                
                MiscHelper.getData(from: url!) { data, response, error in
                    guard let data = data, error == nil else { return }
                    
                    DispatchQueue.main.async()
                    {
                        let image = UIImage(data: data)
                        
                        if (image != nil)
                        {
                            cell.thumbnailImageView.image = image
                        }
                        else
                        {
                            cell.thumbnailImageView.image = UIImage(named: "EmptyVideo")
                            cell.videoPlayIconImageView.isHidden = true
                        }
                    }
                }
            }
            else
            {
                cell.thumbnailImageView.image = UIImage(named: "EmptyVideo")
                cell.videoPlayIconImageView.isHidden = true
            }
        }
 
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let videoObj = videosArray[indexPath.item]
        let videoId = videoObj["videoId"] as! String
        self.showVideoPlayer(videoId: videoId)
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func headerPlayButtonTouched()
    {
        let videoId = videoHeaderObj["videoId"] as! String
        self.showVideoPlayer(videoId: videoId)
    }
    
    // MARK: - CollectionView Flow Layout
    
    private var flowLayout: UICollectionViewFlowLayout
    {
        let _flowLayout = UICollectionViewFlowLayout()

        // edit properties here
        _flowLayout.itemSize = CGSize(width: (kDeviceWidth - 60) / 2, height: 156)
        _flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        _flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        _flowLayout.minimumInteritemSpacing = 20.0
        _flowLayout.minimumLineSpacing = 0.0
        _flowLayout.sectionFootersPinToVisibleBounds = false
        _flowLayout.sectionHeadersPinToVisibleBounds = false
        //_flowLayout.headerReferenceSize = CGSize(width: kDeviceWidth, height: 1)

        return _flowLayout
    }

    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Size the fakeStatusBar and the navBar
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        
        // Add the collectionView
        videosCollectionView = UICollectionView(frame: CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height - CGFloat(kTabBarHeight) - CGFloat(SharedData.bottomSafeAreaHeight)), collectionViewLayout: flowLayout)
        videosCollectionView.backgroundColor = UIColor.mpWhiteColor()
        videosCollectionView.delegate = self
        videosCollectionView.dataSource = self
        self.view.addSubview(videosCollectionView)
        
        videosCollectionView.isHidden = true
        
        videosCollectionView.register(UINib.init(nibName: "VideosTabCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VideosTabCollectionViewCell")
        
        // Top Header
        videosCollectionView.register(UINib.init(nibName: "TeamVideosTopHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TeamVideosTopHeaderCollectionReusableView")
        
        // Section 1 Header
        videosCollectionView.register(UINib.init(nibName: "TeamVideosHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TeamVideosHeaderCollectionReusableView")
        
        // Footer
        videosCollectionView.register(UINib.init(nibName: "VideosTabFooterCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "VideosTabFooterCollectionReusableView")
        
        self.getTeamVideos()

    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mpBlackColor(), .font: UIFont.mpSemiBoldFontWith(size: kNavBarFontSize)]
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (videoPlayerVC != nil)
        {
            videoPlayerVC = nil
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
