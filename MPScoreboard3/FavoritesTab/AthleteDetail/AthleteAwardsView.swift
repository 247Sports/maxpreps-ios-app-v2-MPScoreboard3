//
//  AthleteAwardsView.swift
//  MPScoreboard3
//
//  Created by David Smith on 5/20/21.
//

import UIKit

protocol AthleteAwardsViewDelegate: AnyObject
{
    func athleteAwardsViewDidScroll(_ yScroll : Int)
}

class AthleteAwardsView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, AwardsDetailViewDelegate, AnalystAwardDetailViewDelegate
{
    weak var delegate: AthleteAwardsViewDelegate?
    
    var selectedAthlete : Athlete?
    
    private var awardsCollectionView: UICollectionView!
    private var awardsDetailView: AwardsDetailView!
    private var analystAwardDetailView: AnalystAwardDetailView!
    private var awardsArray = [] as! Array<Dictionary<String,Any>>
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Get Awards Data
    
    func getCareerAwardsData()
    {
        // Show the busy indicator
        //MBProgressHUD.showAdded(to: self, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        let careerId = self.selectedAthlete!.careerId
        
        CareerFeeds.getCareerAwards(careerId) { [self] (result, error) in
            
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
                print("Get career awards success.")
                awardsArray = result!["athleteAwards"] as! Array<Dictionary<String,Any>>
            }
            else
            {
                print("Get career awards failed.")
                
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "There was a problem getting the awards from the server.", lastItemCancelType: false) { (tag) in
                    
                }
            }
            
            self.awardsCollectionView.reloadData()
        }
    }
    
    // MARK: - AwardsDetailView Delegate
    
    func closeAwardsDetailView()
    {
        awardsDetailView.removeFromSuperview()
    }
    
    // MARK: - AnalystAwardDetailView Delegate
    
    func closeAnalystAwardDetailView()
    {
        analystAwardDetailView.removeFromSuperview()
    }
    
    // MARK: - CollectionView Delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return awardsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        // Added the header and footer when ads were added
        return CGSize(width: kDeviceWidth, height: 180.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize
    {
        // Added the header and footer when ads were added
        return CGSize(width: kDeviceWidth, height: 8.0 + 62)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        // Added the header and footer when ads were added
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PhotosTabHeaderCollectionReusableView", for: indexPath as IndexPath) as! PhotosTabHeaderCollectionReusableView

        footerView.headerTitleLabel.text = ""
        return footerView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let award = awardsArray[indexPath.item]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AwardsTabCollectionViewCell", for: indexPath) as! AwardsTabCollectionViewCell
        
        //let title = award["awardName"] as! String
        let aliasTitle = award["awardNameAlias"] as! String
        let type = award["type"] as! String
        
        // Only include the type for football. It is an empty string for other sports
        if (type.lowercased() == "overall") || (type.lowercased() == "special teams") || (type.lowercased() == "offensive") || (type.lowercased() == "defensive")
        {
            cell.titleLabel.text = String(format: "%@ (%@)", aliasTitle, type)
        }
        else
        {
            cell.titleLabel.text = aliasTitle
        }
        
        let timeStampString = award["timeStampString"] as! String
        
        if (timeStampString != "")
        {
            cell.dateLabel.text = timeStampString
        }
        else
        {
            // Use the time stamp instead
            let timeStamp = award["timeStamp"] as! String
            let dateFormatter = DateFormatter()
            dateFormatter.isLenient = true
            dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
            let date = dateFormatter.date(from: timeStamp)
            
            if (date != nil)
            {
                dateFormatter.dateFormat = "MMM d, yyyy"
                let dateString = dateFormatter.string(from: date!)
                cell.dateLabel.text = dateString
            }
            else
            {
                cell.dateLabel.text = ""
            }
        }
        
        /*
        if (title.lowercased() == "player of the game")
        {
            cell.iconImageView.image = UIImage(named: "POGIcon")
        }
        else if (title.lowercased() == "player of the year")
        {
            cell.iconImageView.image = UIImage(named: "POYIcon")
        }
        else
        {
            // Use the badgeUrl for this case (Analyst Awards)
            let urlString = award["badgeUrl"] as! String
                        
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
                            cell.iconImageView.image = image
                        }
                        else
                        {
                            cell.iconImageView.image = UIImage(named: "XmanLogo")
                        }
                    }
                }
            }
            else
            {
                cell.iconImageView.image = UIImage(named: "XmanLogo")
            }
        }
        */
        
        // Use the awardImageUrl
        let urlString = award["awardImageUrl"] as! String
                    
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
                        cell.iconImageView.image = image
                    }
                    else
                    {
                        cell.iconImageView.image = UIImage(named: "XmanLogo")
                    }
                }
            }
        }
        else
        {
            cell.iconImageView.image = UIImage(named: "XmanLogo")
        }
        
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        /*
         Printing description of award:
         ▿ 12 elements
           ▿ 0 : 2 elements
             - key : "timeStampString"
             - value : Jan 29, 2021
           ▿ 1 : 2 elements
             - key : "athleteId"
             - value : cbde04ce-7989-483c-96ca-09ee29ce4143
           ▿ 2 : 2 elements
             - key : "comments"
             - value : Congratulations to Jaxson Dart of Corner Canyon High School for being selected to the 2020 MaxPreps All-American Team - First Team Offense.
           ▿ 3 : 2 elements
             - key : "storyLinkText"
             - value : View Story
           ▿ 4 : 2 elements
             - key : "badgeUrl"
             - value : https://images.maxpreps.com/analyst/category/7fc19b20-5d62-eb11-80ce-a444a33a3a97.png?version=637613586052992323
           ▿ 5 : 2 elements
             - key : "athleteName"
             - value : Jaxson Dart
           ▿ 6 : 2 elements
             - key : "timeStamp"
             - value : 2021-01-29T10:30:00
           ▿ 7 : 2 elements
             - key : "awardName"
             - value : Analyst Award
           ▿ 8 : 2 elements
             - key : "sportSeasonId"
             - value : a9cbf684-16ef-4997-9539-15fefe9df410
           ▿ 9 : 2 elements
             - key : "teamId"
             - value : 7e4dce6a-b7c1-4d9a-959c-892cd4b227df
           ▿ 10 : 2 elements
             - key : "storyLinkUrl"
             - value : https://www.maxpreps.com/news/VUf5H0lFl0WQtyV77mCLyg/2020-maxpreps-high-school-football-all-america-team.htm
           ▿ 11 : 2 elements
             - key : "type"
             - value : 2020 MaxPreps All-American Team - First Team Offense
         */
        
        let award = awardsArray[indexPath.item]
        //let title = award["awardName"] as! String
        let awardSource = award["awardSource"] as! NSNumber
        let awardSourceInt = awardSource.intValue
        
        // Two cases: POG/POY show the awards detail view
        // Analyst Award shows the analyst detail view
        
        //if (title.lowercased() == "player of the game") || (title.lowercased() == "player of the year")
        if ((awardSourceInt == 2) || (awardSourceInt == 3))
        {
            awardsDetailView = AwardsDetailView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight))
            awardsDetailView.delegate = self
            
            let urlString = award["badgeUrl"] as! String
            //let urlString = award["awardImageUrl"] as! String
            
            if (urlString.count > 0)
            {
                let url = URL(string: urlString)
                
                MiscHelper.getData(from: url!) { data, response, error in
                    guard let data = data, error == nil else { return }

                    DispatchQueue.main.async()
                    {
                        //let image = UIImage(data: data)
                        let screenScale = UIScreen.main.scale
                        let scaledImage = UIImage(data: data, scale: screenScale)
                        
                        if (scaledImage != nil)
                        {
                            self.awardsDetailView.loadImage(scaledImage!)
                        }
                        else
                        {
                            let image = UIImage(named: "EmptyPOGImage")
                            self.awardsDetailView.loadImage(image!)
                        }
                    }
                }
            }
            else
            {
                let image = UIImage(named: "EmptyPOGImage")
                awardsDetailView.loadImage(image!)
            }
            
            kAppKeyWindow.rootViewController?.view.addSubview(awardsDetailView)
        }
        else
        {
            analystAwardDetailView = AnalystAwardDetailView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight))
            analystAwardDetailView.delegate = self
            
            analystAwardDetailView.loadData(award, athlete: selectedAthlete!)
            
            kAppKeyWindow.rootViewController?.view.addSubview(analystAwardDetailView)
        }
        
        // Click Tracking
        let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"awards-modal-click", kClickTrackingModuleNameKey: "awards-modal", kClickTrackingModuleLocationKey:"awards home", kClickTrackingModuleActionKey: "click", kClickTrackingClickTextKey:""]
        
        TrackingManager.trackEvent(featureName: "awards-modal", cData: cData)
    }
    
    // MARK: - Set CollectionView Scroll Location
    
    func setCollectionViewScrollLocation(yScroll: Int)
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
        {
            self.awardsCollectionView.contentOffset = CGPoint(x: 0, y: yScroll)
        }
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        self.delegate?.athleteAwardsViewDidScroll(Int(scrollView.contentOffset.y))
    }
    
    // MARK: - CollectionView Flow Layout
    
    var flowLayout: UICollectionViewFlowLayout
    {
        let _flowLayout = UICollectionViewFlowLayout()

        // edit properties here
        _flowLayout.itemSize = CGSize(width: (kDeviceWidth - 60) / 2, height: 182)
        _flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        _flowLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        _flowLayout.minimumInteritemSpacing = 20.0
        _flowLayout.minimumLineSpacing = 20.0
        _flowLayout.headerReferenceSize = CGSize(width: kDeviceWidth, height: 180)
        
        // Calculate the footer required if the content doesn't exceed the visible region by at least 180
        let numberOfRows = awardsArray.count / 2
        let remainder = awardsArray.count % 2
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

        return _flowLayout
    }
    
    // MARK: - Init Method
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        // Add the collectionView
        awardsCollectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), collectionViewLayout: flowLayout)
        awardsCollectionView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        awardsCollectionView.delegate = self
        awardsCollectionView.dataSource = self
        self.addSubview(awardsCollectionView)
        
        awardsCollectionView.register(UINib.init(nibName: "AwardsTabCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AwardsTabCollectionViewCell")
        
        // Resuse the photosTabHeader as the footer for this collectionView (being lazy)
        awardsCollectionView.register(UINib.init(nibName: "PhotosTabHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "PhotosTabHeaderCollectionReusableView")
        
        awardsCollectionView.register(UINib.init(nibName: "PhotosTabHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "PhotosTabHeaderCollectionReusableView")

    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
