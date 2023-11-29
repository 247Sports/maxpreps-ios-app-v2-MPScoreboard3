//
//  NewsPhotosTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 12/10/21.
//

import UIKit

protocol NewsPhotosTableViewCellDelegate: AnyObject
{
    func newsPhotosTableViewCellDidSelectPhoto(urlString: String)
}

class NewsPhotosTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate
{
    weak var delegate: NewsPhotosTableViewCellDelegate?
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var photosArray = [] as! Array<Dictionary<String,Any>>
    
    // MARK: - CollectionView Delegates
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return photosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: kDeviceWidth, height: 432.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsPhotosCollectionViewCell", for: indexPath) as! NewsPhotosCollectionViewCell
        
        let gallery = photosArray[indexPath.row]
        cell.loadData(gallery)
        
        cell.button1.tag = 100 + indexPath.row
        cell.button2.tag = 200 + indexPath.row
        cell.button3.tag = 300 + indexPath.row
        cell.button4.tag = 400 + indexPath.row
        
        cell.button1.addTarget(self, action: #selector(buttonTouched(_:)), for: .touchUpInside)
        cell.button2.addTarget(self, action: #selector(buttonTouched(_:)), for: .touchUpInside)
        cell.button3.addTarget(self, action: #selector(buttonTouched(_:)), for: .touchUpInside)
        cell.button4.addTarget(self, action: #selector(buttonTouched(_:)), for: .touchUpInside)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        
    }
    
    // MARK: - Button Methods
    
    @objc private func buttonTouched(_ sender: UIButton)
    {
        var index = 0
        //var offset = 0
        
        if (sender.tag >= 100) && (sender.tag < 200)
        {
            index = sender.tag - 100
            //offset = 0
        }
        else if (sender.tag >= 200) && (sender.tag < 300)
        {
            index = sender.tag - 200
            //offset = 1
        }
        else if (sender.tag >= 300) && (sender.tag < 400)
        {
            index = sender.tag - 300
            //offset = 2
        }
        else if (sender.tag >= 400) && (sender.tag < 500)
        {
            index = sender.tag - 400
            //offset = 3
        }
        
        let gallery = photosArray[index]
        //let photos = gallery["photos"] as! Array<Dictionary<String,Any>>
        //let photo = photos[offset]
        //let urlString = photo["canonicalUrl"] as! String
        let urlString = gallery["canonicalUrl"] as! String
        
        self.delegate?.newsPhotosTableViewCellDidSelectPhoto(urlString: urlString)
    }
    
    // MARK: - ScrollView Delegates
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView)
    {
        let xScroll = CGFloat(scrollView.contentOffset.x)
        let currentPage = Int(xScroll / kDeviceWidth)
        pageControl.currentPage = currentPage
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let xScroll = CGFloat(scrollView.contentOffset.x)
        let currentPage = Int(xScroll / kDeviceWidth)
        pageControl.currentPage = currentPage
        //print("Current Page: " + String(currentPage))
    }
    
    // MARK: - Load Data
    
    func loadData(_ data: Array<Dictionary<String,Any>>)
    {
        photosArray = data
        
        if (photosArray.count > 1)
        {
            pageControl.numberOfPages = photosArray.count
            pageControl.isUserInteractionEnabled = false
        }
        else
        {
            pageControl.isHidden = true
        }
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 12
        self.contentView.clipsToBounds = true
        
        // Register the NewsPhotosCollectionViewCell
        photosCollectionView.register(UINib.init(nibName: "NewsPhotosCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewsPhotosCollectionViewCell")

    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
