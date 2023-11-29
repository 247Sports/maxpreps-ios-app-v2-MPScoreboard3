//
//  NewsPhotosCollectionViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 12/10/21.
//

import UIKit

class NewsPhotosCollectionViewCell: UICollectionViewCell
{
    @IBOutlet weak var sportIconImageView: UIImageView!
    @IBOutlet weak var sportLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
        
    // MARK: - Load Data
    
    func loadData(_ data: Dictionary<String,Any>)
    {
        // Clear out the imageViews
        imageView1.image = nil
        imageView2.image = nil
        imageView3.image = nil
        imageView4.image = nil
        
        button1.isUserInteractionEnabled = false
        button2.isUserInteractionEnabled = false
        button3.isUserInteractionEnabled = false
        button4.isUserInteractionEnabled = false
        
        let gender = data["gender"] as! String
        let sport = data["sport"] as! String
        let level = data["level"] as! String
        let name = data["name"] as! String
        
        sportLabel.text = MiscHelper.genderSportLevelFrom(gender: gender, sport: sport, level: level)
        sportIconImageView.image = MiscHelper.getImageForSport(sport)
        titleLabel.text = name
        
        let photosCount = data["photosCount"] as! Int
  
        var dateString = data["modifiedOn"] as! String
        dateString = dateString.replacingOccurrences(of: "Z", with: "")
        
        let dateFormatter = DateFormatter()
        dateFormatter.isLenient = true
        dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        let publishDate = dateFormatter.date(from: dateString)
        
        // Make sure the date was converted properly
        if (publishDate != nil)
        {
            dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
            let publishDateString = dateFormatter.string(from: publishDate!)
            dateLabel.text = String(format: "Published: %@ | %d Photos", publishDateString, photosCount)
        }
        else
        {
            dateLabel.text = String(format: "%d Photos", photosCount)
        }
        
        let firstName = data["photographerFirstName"] as! String
        let lastName = data["photographerLastName"] as! String
        authorNameLabel.text = String(format: "%@ %@", firstName, lastName)
        
        // Load the thumbnails
        let photos = data["photos"] as! Array<Dictionary<String,Any>>
        
        if (photos.count > 0)
        {
            button1.isUserInteractionEnabled = true
            
            let photo = photos[0]
            var photoUrlString = photo["sourceCanonicalUrl"] as? String ?? ""
            photoUrlString = photoUrlString.replacingOccurrences(of: "images-development", with: "images")
            
            if (photoUrlString.count > 0)
            {
                // Get the data and make an image
                let url = URL(string: photoUrlString)
                
                MiscHelper.getData(from: url!) { data, response, error in
                    guard let data = data, error == nil else { return }

                    DispatchQueue.main.async()
                    {
                        let image = UIImage(data: data)
                        
                        if (image != nil)
                        {
                            self.imageView1.image = image
                        }
                        else
                        {
                            self.imageView1.image = UIImage(named: "EmptyPortraitPhoto")
                        }
                    }
                }
            }
            else
            {
                self.imageView1.image = UIImage(named: "EmptyPortraitPhoto")
            }
            
            // Next image
            if (photos.count > 1)
            {
                button2.isUserInteractionEnabled = true
                
                let photo = photos[1]
                var photoUrlString = photo["sourceCanonicalUrl"] as? String ?? ""
                photoUrlString = photoUrlString.replacingOccurrences(of: "images-development", with: "images")
                
                if (photoUrlString.count > 0)
                {
                    // Get the data and make an image
                    let url = URL(string: photoUrlString)
                    
                    MiscHelper.getData(from: url!) { data, response, error in
                        guard let data = data, error == nil else { return }

                        DispatchQueue.main.async()
                        {
                            let image = UIImage(data: data)
                            
                            if (image != nil)
                            {
                                self.imageView2.image = image
                            }
                            else
                            {
                                self.imageView2.image = UIImage(named: "EmptyLandscapePhoto")
                            }
                        }
                    }
                }
                else
                {
                    self.imageView2.image = UIImage(named: "EmptyLandscapePhoto")
                }
                
                // Next Image
                if (photos.count > 2)
                {
                    button3.isUserInteractionEnabled = true
                    
                    let photo = photos[2]
                    var photoUrlString = photo["sourceCanonicalUrl"] as? String ?? ""
                    photoUrlString = photoUrlString.replacingOccurrences(of: "images-development", with: "images")
                    
                    if (photoUrlString.count > 0)
                    {
                        // Get the data and make an image
                        let url = URL(string: photoUrlString)
                        
                        MiscHelper.getData(from: url!) { data, response, error in
                            guard let data = data, error == nil else { return }

                            DispatchQueue.main.async()
                            {
                                let image = UIImage(data: data)
                                
                                if (image != nil)
                                {
                                    self.imageView3.image = image
                                }
                                else
                                {
                                    self.imageView3.image = UIImage(named: "EmptyLandscapePhoto")
                                }
                            }
                        }
                    }
                    else
                    {
                        self.imageView3.image = UIImage(named: "EmptyLandscapePhoto")
                    }
                    
                    // Next Image
                    if (photos.count > 3)
                    {
                        button4.isUserInteractionEnabled = true
                        
                        let photo = photos[3]
                        var photoUrlString = photo["sourceCanonicalUrl"] as? String ?? ""
                        photoUrlString = photoUrlString.replacingOccurrences(of: "images-development", with: "images")
                        
                        if (photoUrlString.count > 0)
                        {
                            // Get the data and make an image
                            let url = URL(string: photoUrlString)
                            
                            MiscHelper.getData(from: url!) { data, response, error in
                                guard let data = data, error == nil else { return }

                                DispatchQueue.main.async()
                                {
                                    let image = UIImage(data: data)
                                    
                                    if (image != nil)
                                    {
                                        self.imageView4.image = image
                                    }
                                    else
                                    {
                                        self.imageView4.image = UIImage(named: "EmptyPortraitPhoto")
                                    }
                                }
                            }
                        }
                        else
                        {
                            self.imageView4.image = UIImage(named: "EmptyPortraitPhoto")
                        }
                    }
                }
            }
        }
        
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        imageView1.layer.cornerRadius = 8
        imageView1.clipsToBounds = true
        imageView2.layer.cornerRadius = 8
        imageView2.clipsToBounds = true
        imageView3.layer.cornerRadius = 8
        imageView3.clipsToBounds = true
        imageView4.layer.cornerRadius = 8
        imageView4.clipsToBounds = true

    }

}
