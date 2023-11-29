//
//  AthleteVideosView.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/20/21.
//

import UIKit

protocol AthleteVideosViewDelegate: AnyObject
{
    func athleteVideosViewDidScroll(_ yScroll : Int)
    func athleteVideosPlayButtonTouched(videoId: String)
}

class AthleteVideosView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    weak var delegate: AthleteVideosViewDelegate?
    
    var selectedAthlete : Athlete?
    private var videosCollectionView: UICollectionView!

    private var videoHeaderObj = [:] as Dictionary<String,Any>
    private var videosArray = [] as Array<Dictionary<String,Any>>
    private var pageNumber = 1
    private let kMaxItems = 25
    private var showFooter = false
    private var footerView: UIView!
    private var sortModeString = "Most Recent"
    private var sortModeQueryParameter = "MostRecent"
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Get Videos
    
    func getCareerVideos()
    {
        // Show the busy indicator
        //MBProgressHUD.showAdded(to: self, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        let careerId = self.selectedAthlete!.careerId
        
        CareerFeeds.getCareerVideos(careerId, pageNumber: pageNumber, maxItems: kMaxItems, sort:sortModeQueryParameter) { [self] (result, error) in
            
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                //MBProgressHUD.hide(for: self, animated: true)
                if (self.progressOverlay != nil)
                {
                    self.progressOverlay.hide(animated: false)
                    self.progressOverlay = nil
                }
            }
            
            if error == nil
            {
                print("Get career videos success.")
                let resultArray = result!["videos"] as! Array<Dictionary<String,Any>>
                
                videosCollectionView.isHidden = false
                
                if (resultArray.count > 0)
                {
                    if (pageNumber == 1)
                    {
                        // Put the first item into the videoHeaderObj
                        videoHeaderObj = resultArray[0]
                        
                        // Fill the videosArray with all items, then remove the first
                        videosArray.append(contentsOf:resultArray)
                        
                        videosArray.remove(at: 0)
                    }
                    else
                    {
                        // Append the results so the array will grow with each request
                        videosArray.append(contentsOf:resultArray)
                    }
                    
                    
                    /*
                    // Debug
                    for item in itemArray
                    {
                        let type = item["type"] as! Int
                        print("Type: " + String(type))
                    }
                    */
                }
                
                // Hide the button if the item count is less than the max value
                if (resultArray.count < kMaxItems)
                {
                    showFooter = false
                }
                else
                {
                    showFooter = true
                    pageNumber += 1
                }
            }
            else
            {
                print("Get career videos failed.")
                
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "There was a problem getting the videos from the server.", lastItemCancelType: false) { (tag) in
                    
                }
            }
            
            self.videosCollectionView.reloadData()
        }
    }
    
    // MARK: - Button Methods
    
    @objc private func headerPlayButtonTouched()
    {
        let videoId = videoHeaderObj["videoId"] as! String        
        self.delegate?.athleteVideosPlayButtonTouched(videoId: videoId)
    }
    
    @objc private func getMoreButtonTouched()
    {
        self.getCareerVideos()
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
            return CGSize(width: kDeviceWidth, height: 459.0)
        }
        else
        {
            if (videosArray.count > 0)
            {
                return CGSize(width: kDeviceWidth, height: 82.0)
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
            if (showFooter == true)
            {
                // There are at least 25 items showing
                return CGSize(width: kDeviceWidth, height: 60.0 + 62)
            }
            
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
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "VideosTabTopHeaderCollectionReusableView", for: indexPath as IndexPath) as! VideosTabTopHeaderCollectionReusableView
                
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
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "VideosTabHeaderCollectionReusableView", for: indexPath as IndexPath) as! VideosTabHeaderCollectionReusableView
                
                // Add the sortMenu to the button
                headerView.sortButton.menu = sortMenu
                headerView.sortButton.showsMenuAsPrimaryAction = true
                headerView.sortModeLabel.text = sortModeString
        
                return headerView
            }
            
        case UICollectionView.elementKindSectionFooter:

            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "VideosTabFooterCollectionReusableView", for: indexPath as IndexPath) as! VideosTabFooterCollectionReusableView
            
            footerView.getMoreButton.isHidden = true
            footerView.getMoreButton.addTarget(self, action: #selector(getMoreButtonTouched), for: .touchUpInside)
            
            // Tint the get more button with the school color
            let colorString = selectedAthlete?.schoolColor
            let teamColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
            footerView.getMoreButton.backgroundColor = teamColor
            
            if (showFooter == true)
            {
                // There are at least 25 items showing
                footerView.getMoreButton.isHidden = false
            }
            
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
        self.delegate?.athleteVideosPlayButtonTouched(videoId: videoId)
    }
    
    // MARK: - Sort Menu Methods
    
    private var menuItems: [UIAction]
    {
        /*
        return [
            UIAction(title: "Oldest", image: UIImage(systemName: "trash"), handler: { (_) in
            }),
            UIAction(title: "Most Popular", image: UIImage(systemName: "moon"), handler: { (_) in
            }),
            UIAction(title: "Most Recent", image: UIImage(systemName: "sun.max"), handler: { (_) in
            })
        ]
        */
        return [
            UIAction(title: "Oldest", image: nil, handler: { (_) in
                print("Oldest Touched")
                self.sortModeString = "Oldest"
                self.sortModeQueryParameter = "Oldest"
                self.videosArray.removeAll()
                self.pageNumber = 1
                self.showFooter = false
                self.getCareerVideos()
            }),
            UIAction(title: "Most Popular", image: nil, handler: { (_) in
                print("Most Popular Touched")
                self.sortModeString = "Most Popular"
                self.sortModeQueryParameter = "MostPopular"
                self.videosArray.removeAll()
                self.pageNumber = 1
                self.showFooter = false
                self.getCareerVideos()
            }),
            UIAction(title: "Most Recent", image: nil, handler: { (_) in
                print("Most Recent Touched")
                self.sortModeString = "Most Recent"
                self.sortModeQueryParameter = "MostRecent"
                self.videosArray.removeAll()
                self.pageNumber = 1
                self.showFooter = false
                self.getCareerVideos()
            })
        ]
    }

    private var sortMenu: UIMenu
    {
        return UIMenu(title: "Sort Videos By", image: nil, identifier: nil, options: [], children: menuItems)
    }
    
    // MARK: - Set CollectionView Scroll Location
    
    func setCollectionViewScrollLocation(yScroll: Int)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
        {
            self.videosCollectionView.contentOffset = CGPoint(x: 0, y: yScroll)
        }
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        self.delegate?.athleteVideosViewDidScroll(Int(scrollView.contentOffset.y))
    }
    
    // MARK: - CollectionView Flow Layout
    
    var flowLayout: UICollectionViewFlowLayout
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
        
        /*
        // Calculate the footer required if the content doesn't exceed the visible region by at least 180
        let numberOfRows = photosArray.count / 3
        var remainder = photosArray.count % 3
        if (remainder > 0)
        {
            remainder = 1
        }
        print("Row Count: " + String(numberOfRows + remainder))
        
        let contentHeight = (numberOfRows + remainder) * 202
        let collectionViewVisibleHeight = self.frame.size.height - 180
        let difference = contentHeight - Int(collectionViewVisibleHeight)
        print("Height Difference: " + String(difference))
        
        if (difference > 0) && (difference <= 180)
        {
            let pad = 180 - difference
            _flowLayout.footerReferenceSize = CGSize(width: kDeviceWidth, height: CGFloat(pad))
        }
        */
        return _flowLayout
    }
    
    // MARK: - Init Method
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        // Add the collectionView
        videosCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), collectionViewLayout: flowLayout)
        videosCollectionView.backgroundColor = UIColor.mpWhiteColor()
        videosCollectionView.delegate = self
        videosCollectionView.dataSource = self
        self.addSubview(videosCollectionView)
        
        videosCollectionView.isHidden = true
        
        videosCollectionView.register(UINib.init(nibName: "VideosTabCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VideosTabCollectionViewCell")
        
        // Top Header
        videosCollectionView.register(UINib.init(nibName: "VideosTabTopHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "VideosTabTopHeaderCollectionReusableView")
        
        // Section 1 Header
        videosCollectionView.register(UINib.init(nibName: "VideosTabHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "VideosTabHeaderCollectionReusableView")
        
        // Footer
        videosCollectionView.register(UINib.init(nibName: "VideosTabFooterCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "VideosTabFooterCollectionReusableView")
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
