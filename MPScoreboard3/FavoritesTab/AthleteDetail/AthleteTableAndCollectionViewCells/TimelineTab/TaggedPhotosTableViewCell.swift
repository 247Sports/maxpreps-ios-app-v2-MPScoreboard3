//
//  TaggedPhotosTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/2/21.
//

import UIKit

protocol TaggedPhotosTableViewCellDelegate: AnyObject
{
    func collectionViewDidSelectItem(urlString: String)
}

class TaggedPhotosTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    weak var delegate: TaggedPhotosTableViewCellDelegate?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var viewMoreButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    
    private var taggedPhotosArray = [] as Array<Dictionary<String,Any>>

    // MARK: - CollectionView Delegate Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return taggedPhotosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let photo = taggedPhotosArray[indexPath.item]
        let width = photo["width"] as! Int
        let height = photo["height"] as! Int
        let aspect = width / height
        if (aspect > 1)
        {
            // Landscape
            return CGSize(width: CGFloat(271), height: CGFloat(200))
        }
        else
        {
            return CGSize(width: CGFloat(148), height: CGFloat(200))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let photo = taggedPhotosArray[indexPath.item]
        let width = photo["width"] as! Int
        let height = photo["height"] as! Int
        let aspect = width / height
        
        if (aspect > 1)
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaggedPhotoLandscapeCollectionViewCell", for: indexPath) as! TaggedPhotoLandscapeCollectionViewCell
            
            let urlString = photo["sourceUrl"] as! String
            
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
                            cell.photoImageView.image = image
                        }
                        else
                        {
                            cell.photoImageView.image = UIImage(named: "EmptyLandscapePhoto")
                        }
                    }
                }
            }
            else
            {
                cell.photoImageView.image = UIImage(named: "EmptyLandscapePhoto")
            }
            
            return cell
        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaggedPhotoPortraitCollectionViewCell", for: indexPath) as! TaggedPhotoPortraitCollectionViewCell
            
            let urlString = photo["sourceUrl"] as! String
            
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
                            cell.photoImageView.image = image
                        }
                        else
                        {
                            cell.photoImageView.image = UIImage(named: "EmptyPortraitPhoto")
                        }
                    }
                }
            }
            else
            {
                cell.photoImageView.image = UIImage(named: "EmptyPortraitPhoto")
            }
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let photo = taggedPhotosArray[indexPath.item]
        let urlString = photo["canonicalUrl"] as! String
        
        self.delegate?.collectionViewDidSelectItem(urlString: urlString)
    }
    
    // MARK: - Load Data
    
    func loadData(itemData: Dictionary<String,Any>)
    {
        let title = itemData["title"] as! String
        titleLabel.text = title
        
        let subtitle = itemData["text"] as! String
        subtitleLabel.text = subtitle
        
        let timeText = itemData["timeStampString"] as! String
        dateLabel.text = timeText
        
        let links = itemData["links"] as! Array<Dictionary<String,String>>
        let link = links.first
        let moreButtonTitle = link!["text"]
        viewMoreButton.setTitle(moreButtonTitle, for: .normal)
        
        let data = itemData["data"] as! Dictionary<String,Any>
        taggedPhotosArray = data["photos"] as! Array<Dictionary<String,Any>>
        
        /*
         ▿ 8 elements
           ▿ 0 : 2 elements
             - key : "data"
             ▿ value : 5 elements
               ▿ 0 : 2 elements
                 - key : photographerUrl
                 - value : https://dev.maxpreps.com/photography/photographer/anthony+brunsman?id=e7f37416-01c7-489e-88c6-2545a22ce4b2
               ▿ 1 : 2 elements
                 - key : photos
                 ▿ value : 2 elements
                   ▿ 0 : 4 elements
                     ▿ 0 : 2 elements
                       - key : sourceUrl
                       - value : https://images-development.maxpreps.com/Gallery/PDCj2GE2b0GM0qv5n97cww/wxvcBBMMikqGpWCcDmZBdA/1,660,520/oak_ridge_del_oro_boys_football_image.jpg
                     ▿ 1 : 2 elements
                       - key : canonicalUrl
                       - value : https://dev.maxpreps.com/photo/gallery.aspx?photogalleryid=d8a3303c-3661-416f-8cd2-abf99fdedcc3&photoid=04dc1bc3-0c13-4a8a-86a5-609c0e664174
                     ▿ 2 : 2 elements
                       - key : width
                       - value : 1600
                     ▿ 3 : 2 elements
                       - key : height
                       - value : 2167
                   ▿ 1 : 4 elements
                     ▿ 0 : 2 elements
                       - key : sourceUrl
                       - value : https://images-development.maxpreps.com/Gallery/PDCj2GE2b0GM0qv5n97cww/G8PTFdXRJkCelZr9ScRI8w/1,660,520/oak_ridge_del_oro_boys_football_image.jpg
                     ▿ 1 : 2 elements
                       - key : canonicalUrl
                       - value : https://dev.maxpreps.com/photo/gallery.aspx?photogalleryid=d8a3303c-3661-416f-8cd2-abf99fdedcc3&photoid=15d3c31b-d1d5-4026-9e95-9afd49c448f3
                     ▿ 2 : 2 elements
                       - key : width
                       - value : 1600
                     ▿ 3 : 2 elements
                       - key : height
                       - value : 2167
               ▿ 2 : 2 elements
                 - key : photoGalleryName
                 - value : Oak Ridge @ Del Oro
               ▿ 3 : 2 elements
                 - key : photoGalleryUrl
                 - value : https://dev.maxpreps.com/photo/gallery.aspx?photogalleryid=d8a3303c-3661-416f-8cd2-abf99fdedcc3
               ▿ 4 : 2 elements
                 - key : photographerName
                 - value : Anthony Brunsman
           ▿ 1 : 2 elements
             - key : "timeStampString"
             - value : Saturday, Sep 17, 2011
           ▿ 2 : 2 elements
             - key : "text"
             - value : Jon David Smith has been tagged in the photo gallery "Oak Ridge @ Del Oro".
           ▿ 3 : 2 elements
             - key : "timeStamp"
             - value : 2011-09-17T13:48:16.46
           ▿ 4 : 2 elements
             - key : "shareLink"
             - value : https://dev.maxpreps.com/athlete/jon-david-smith/YvH-N_TlEeKZ5AAmVebBJg/photo/full_size.htm
           ▿ 5 : 2 elements
             - key : "type"
             - value : 2
           ▿ 6 : 2 elements
             - key : "title"
             - value : Pro Photos
           ▿ 7 : 2 elements
             - key : "links"
             ▿ value : 1 element
               ▿ 0 : 2 elements
                 ▿ 0 : 2 elements
                   - key : url
                   - value : https://dev.maxpreps.com/athlete/jon-david-smith/YvH-N_TlEeKZ5AAmVebBJg/photo/full_size.htm
                 ▿ 1 : 2 elements
                   - key : text
                   - value : View Photo Gallery
         */
        
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // Register the Photo Cells
        photoCollectionView.register(UINib.init(nibName: "TaggedPhotoPortraitCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TaggedPhotoPortraitCollectionViewCell")
        
        photoCollectionView.register(UINib.init(nibName: "TaggedPhotoLandscapeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "TaggedPhotoLandscapeCollectionViewCell")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
