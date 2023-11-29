//
//  AthletePhotosView.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/20/21.
//

import UIKit

protocol AthletePhotosViewDelegate: AnyObject
{
    func athletePhotosViewDidScroll(_ yScroll : Int)
    func athletePhotosWebButtonTouched(urlString: String)
}

class AthletePhotosView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    weak var delegate: AthletePhotosViewDelegate?
    
    var selectedAthlete : Athlete?
    private var photosCollectionView: UICollectionView!
    private var groupedPhotosArray = [] as Array<Dictionary<String,Any>>
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Get Photos
        
    func getCareerPhotos()
    {
        // Show the busy indicator
        //MBProgressHUD.showAdded(to: self, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        let careerId = self.selectedAthlete!.careerId
        
        CareerFeeds.getCareerPhotos(careerId) { [self] (result, error) in
            
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
                print("Get career photos success.")
                let groupedPhotos = result!["groupedPhotos"] as! Array<Dictionary<String,Any>>
                groupedPhotosArray = groupedPhotos
                
                photosCollectionView.isHidden = false
            }
            else
            {
                print("Get career photos failed.")
                
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "There was a problem getting photos from the server.", lastItemCancelType: false) { (tag) in
                    
                }
            }
            
            self.photosCollectionView.reloadData()
        }
    }
    
    // MARK: - CollectionView Delegates
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return groupedPhotosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let groupObj = groupedPhotosArray[section]
        let innerArray = groupObj["photos"] as! Array<Dictionary<String,Any>>
        return innerArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        if (section == 0)
        {
            return CGSize(width: kDeviceWidth, height: 180.0 + 48.0)
        }
        else
        {
            return CGSize(width: kDeviceWidth, height: 48.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    {
        if (section == (groupedPhotosArray.count - 1))
        {
            // Calculate the footer required if the content doesn't exceed the visible region by at least 180
            var overallContentHeight = 0
            for groupObj in groupedPhotosArray
            {
                overallContentHeight += 48
                
                let innerArray = groupObj["photos"] as! Array<Dictionary<String,Any>>
                let numberOfRows = innerArray.count / 3
                var remainder = innerArray.count % 3
                if (remainder > 0)
                {
                    remainder = 1
                }
                //print("Row Count: " + String(numberOfRows + remainder))
                let contentHeight = ((numberOfRows + remainder) * 120) + ((numberOfRows + remainder - 1) * 8)
                overallContentHeight += contentHeight
            }
            
            let collectionViewVisibleHeight = self.frame.size.height - 180
            let difference = overallContentHeight - Int(collectionViewVisibleHeight)
            print("Height Difference: " + String(difference))
            
            if (difference > 0) && (difference <= 180)
            {
                let pad = 180 - difference
                return CGSize(width: kDeviceWidth, height: CGFloat(pad + 62))
            }
            else
            {
                return CGSize(width: kDeviceWidth, height: 8.0 + 62)
            }
        }
        else
        {
            return CGSize(width: kDeviceWidth, height: 0.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        switch kind
        {
        case UICollectionView.elementKindSectionHeader:

            if (indexPath.section == 0)
            {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PhotosTabTopHeaderCollectionReusableView", for: indexPath as IndexPath) as! PhotosTabTopHeaderCollectionReusableView
            
                let groupObj = groupedPhotosArray[indexPath.section]
                let headerTitle = groupObj["groupName"] as! String
                headerView.headerTitleLabel.text = headerTitle.uppercased()
                return headerView
            }
            else
            {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PhotosTabHeaderCollectionReusableView", for: indexPath as IndexPath) as! PhotosTabHeaderCollectionReusableView
                
                let groupObj = groupedPhotosArray[indexPath.section]
                let headerTitle = groupObj["groupName"] as! String
                headerView.headerTitleLabel.text = headerTitle.uppercased()
                return headerView
            }
            
        case UICollectionView.elementKindSectionFooter:

            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PhotosTabHeaderCollectionReusableView", for: indexPath as IndexPath) as! PhotosTabHeaderCollectionReusableView

            footerView.headerTitleLabel.text = ""
            
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
        return CGSize(width: (kDeviceWidth - 16) / 3, height: CGFloat(120))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosTabCollectionViewCell", for: indexPath) as! PhotosTabCollectionViewCell
        
        let groupObj = groupedPhotosArray[indexPath.section]
        let innerArray = groupObj["photos"] as! Array<Dictionary<String,Any>>
        let photo = innerArray[indexPath.item]
        
        let urlString = photo["sourceCanonicalUrl"] as! String
        
        cell.thumbnailImageView.image = nil
        
        if (urlString.count > 0)
        {
            let url = URL(string: urlString)
            
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
                        cell.thumbnailImageView.image = UIImage(named: "EmptyLandscapePhoto")
                    }
                }
            }
        }
        else
        {
            cell.thumbnailImageView.image = UIImage(named: "EmptyLandscapePhoto")
        }
      
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let groupObj = groupedPhotosArray[indexPath.section]
        let innerArray = groupObj["photos"] as! Array<Dictionary<String,Any>>
        let photo = innerArray[indexPath.item]
        let urlString = photo["canonicalUrl"] as! String
        
        self.delegate?.athletePhotosWebButtonTouched(urlString:urlString)
    }
    
    // MARK: - Set CollectionView Scroll Location
    
    func setCollectionViewScrollLocation(yScroll: Int)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
        {
            self.photosCollectionView.contentOffset = CGPoint(x: 0, y: yScroll)
        }
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        self.delegate?.athletePhotosViewDidScroll(Int(scrollView.contentOffset.y))
    }
    
    // MARK: - CollectionView Flow Layout
    
    var flowLayout: UICollectionViewFlowLayout
    {
        let _flowLayout = UICollectionViewFlowLayout()

        // edit properties here
        _flowLayout.itemSize = CGSize(width: (kDeviceWidth - 16) / 3, height: 120)
        _flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        _flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        _flowLayout.minimumInteritemSpacing = 6.0
        _flowLayout.minimumLineSpacing = 8.0
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
        photosCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), collectionViewLayout: flowLayout)
        photosCollectionView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        self.addSubview(photosCollectionView)
        
        photosCollectionView.isHidden = true
        
        photosCollectionView.register(UINib.init(nibName: "PhotosTabCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotosTabCollectionViewCell")
        
        // Top Header
        photosCollectionView.register(UINib.init(nibName: "PhotosTabTopHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "PhotosTabTopHeaderCollectionReusableView")
        
        // Using the same view for the  middle headers and an optional footer
        photosCollectionView.register(UINib.init(nibName: "PhotosTabHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "PhotosTabHeaderCollectionReusableView")
        
        photosCollectionView.register(UINib.init(nibName: "PhotosTabHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "PhotosTabHeaderCollectionReusableView")
        
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
