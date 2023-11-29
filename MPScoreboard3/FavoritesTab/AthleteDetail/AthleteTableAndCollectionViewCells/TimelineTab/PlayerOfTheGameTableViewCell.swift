//
//  PlayerOfTheGameTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/9/21.
//

import UIKit

class PlayerOfTheGameTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var awardsCollectionView: UICollectionView!
    @IBOutlet weak var gameRecapButton: UIButton!
    @IBOutlet weak var awardsButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var awardsArray = [["key":"1"]] as Array<Dictionary<String,Any>>
    
    private var selectedAthleteCopy = Athlete(firstName: "", lastName: "", schoolName: "", schoolState: "", schoolCity: "", schoolId: "", schoolColor: "", schoolMascotUrl: "", careerId: "", photoUrl: "")

    // MARK: - CollectionView Delegate Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return awardsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        // Calculate the cell size based upon the screen width
        return CGSize(width: kDeviceWidth - 40, height: CGFloat(340))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        //let photo = awardsArray[indexPath.item]

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayerOfTheGameCollectionViewCell", for: indexPath) as! PlayerOfTheGameCollectionViewCell
        
        let item = awardsArray[indexPath.item]
        
        cell.loadData(awardsData: item, selectedAthlete: selectedAthleteCopy)
        /*
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
        */
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        
    }
    
    // MARK: - Load Data
    
    func loadData(awardsData: Dictionary<String,Any>, selectedAthlete: Athlete)
    {
        selectedAthleteCopy = selectedAthlete
        
        awardsArray.removeAll()
        let dataObj = awardsData["data"] as! Dictionary<String,Any>
        awardsArray = dataObj["playersOfTheGame"] as! Array<Dictionary<String, Any>>
        
        let title = awardsData["title"] as! String
        titleLabel.text = title
        
        let subtitle = awardsData["text"] as! String
        subtitleLabel.text = subtitle
        
        let timeText = awardsData["timeStampString"] as! String
        dateLabel.text = timeText
        
        let links = awardsData["links"] as! Array<Dictionary<String,String>>
        let link0 = links.first
        let link1 = links.last
        let gameRecapButtonTitle = link0!["text"]
        let awardsButtonTitle = link1!["text"]
        gameRecapButton.setTitle(gameRecapButtonTitle, for: .normal)
        awardsButton.setTitle(awardsButtonTitle, for: .normal)
        
        // Resize the awardsButton to fit the text
        let textWidth = awardsButtonTitle?.widthOfString(usingFont: (awardsButton.titleLabel?.font)!)
        awardsButton.frame = CGRect(x: awardsButton.frame.origin.x, y: awardsButton.frame.origin.y, width: CGFloat(textWidth! + 10), height: awardsButton.frame.size.height)
        
        
        
        // Show or hide the page control
        if (awardsArray.count < 2)
        {
            pageControl.isHidden = true
        }
        else
        {
            pageControl.numberOfPages = awardsArray.count
            pageControl.isUserInteractionEnabled = false
        }
        
        /*
         ▿ 8 elements
           ▿ 0 : 2 elements
             - key : "timeStamp"
             - value : 2019-11-02T03:35:49.783
           ▿ 1 : 2 elements
             - key : "text"
             - value : Jaxson Dart has been named player of the game for his outstanding performance on the court.
           ▿ 2 : 2 elements
             - key : "shareLink"
             - value : https://dev.maxpreps.com/athlete/jaxson-dart/GFer9FUbEeeT-Oz0u-e-FA/awards.htm
           ▿ 3 : 2 elements
             - key : "timeStampString"
             - value : Saturday, Nov 2, 2019
           ▿ 4 : 2 elements
             - key : "title"
             - value : Player of the Game
           ▿ 5 : 2 elements
             - key : "type"
             - value : 6
           ▿ 6 : 2 elements
             - key : "data"
             ▿ value : 2 elements
               ▿ 0 : 16 elements
                 ▿ 0 : 2 elements
                   - key : athleteLastName
                   - value :
                 ▿ 1 : 2 elements
                   - key : comments
                   - value :
                 ▿ 2 : 2 elements
                   - key : athleteId
                   - value : 9c3d96c1-c4e7-494f-be48-9d1df230acc2
                 ▿ 3 : 2 elements
                   - key : playerOfTheGameId
                   - value : b8fb773e-221c-4941-a132-92419a62f399
                 ▿ 4 : 2 elements
                   - key : createdOn
                   - value : 2019-11-02T03:05:42.367
                 ▿ 5 : 2 elements
                   - key : athletePhotoUrl
                   - value :
                 ▿ 6 : 2 elements
                   - key : schoolId
                   - value : b1350e52-edfe-4180-aa66-b60135a68acc
                 ▿ 7 : 2 elements
                   - key : teamId
                   - value : b1350e52-edfe-4180-aa66-b60135a68acc
                 ▿ 8 : 2 elements
                   - key : badgeUrl
                   - value : https://images-development.maxpreps.com/pot/b/8/f/b8fb773e-221c-4941-a132-92419a62f399.png?version=637082625497830000
                 ▿ 9 : 2 elements
                   - key : type
                   - value : Overall
                 ▿ 10 : 2 elements
                   - key : modifiedOn
                   - value : 2019-11-02T03:35:49.783
                 ▿ 11 : 2 elements
                   - key : careerProfileId
                   - value : 00000000-0000-0000-0000-000000000000
                 ▿ 12 : 2 elements
                   - key : athleteFirstName
                   - value :
                 ▿ 13 : 2 elements
                   - key : ssid
                   - value : 8d610ab9-220b-465b-9cf0-9f417bce6c65
                 ▿ 14 : 2 elements
                   - key : sportSeasonId
                   - value : 8d610ab9-220b-465b-9cf0-9f417bce6c65
                 ▿ 15 : 2 elements
                   - key : contestId
                   - value : 24bb1cf0-0063-4262-b80d-9d1774bedcab
               ▿ 1 : 16 elements
                 ▿ 0 : 2 elements
                   - key : athleteLastName
                   - value :
                 ▿ 1 : 2 elements
                   - key : comments
                   - value :
                 ▿ 2 : 2 elements
                   - key : athleteId
                   - value : 9c3d96c1-c4e7-494f-be48-9d1df230acc2
                 ▿ 3 : 2 elements
                   - key : playerOfTheGameId
                   - value : 6dd70319-da39-4467-b811-a538bdd6b694
                 ▿ 4 : 2 elements
                   - key : createdOn
                   - value : 2019-11-02T03:05:42.613
                 ▿ 5 : 2 elements
                   - key : athletePhotoUrl
                   - value :
                 ▿ 6 : 2 elements
                   - key : schoolId
                   - value : b1350e52-edfe-4180-aa66-b60135a68acc
                 ▿ 7 : 2 elements
                   - key : teamId
                   - value : b1350e52-edfe-4180-aa66-b60135a68acc
                 ▿ 8 : 2 elements
                   - key : badgeUrl
                   - value : https://images-development.maxpreps.com/pot/6/d/d/6dd70319-da39-4467-b811-a538bdd6b694.png?version=637082625498770000
                 ▿ 9 : 2 elements
                   - key : type
                   - value : Offensive
                 ▿ 10 : 2 elements
                   - key : modifiedOn
                   - value : 2019-11-02T03:35:49.877
                 ▿ 11 : 2 elements
                   - key : careerProfileId
                   - value : 00000000-0000-0000-0000-000000000000
                 ▿ 12 : 2 elements
                   - key : athleteFirstName
                   - value :
                 ▿ 13 : 2 elements
                   - key : ssid
                   - value : 8d610ab9-220b-465b-9cf0-9f417bce6c65
                 ▿ 14 : 2 elements
                   - key : sportSeasonId
                   - value : 8d610ab9-220b-465b-9cf0-9f417bce6c65
                 ▿ 15 : 2 elements
                   - key : contestId
                   - value : 24bb1cf0-0063-4262-b80d-9d1774bedcab
           ▿ 7 : 2 elements
             - key : "links"
             ▿ value : 2 elements
               ▿ 0 : 2 elements
                 ▿ 0 : 2 elements
                   - key : url
                   - value : https://dev.maxpreps.com/games/11-01-2019/football-fall-19/american-fork-vs-roy.htm?c=8By7JGMAYkK4DZ0XdL7cqw#tab=recap
                 ▿ 1 : 2 elements
                   - key : text
                   - value : View Game Recap
               ▿ 1 : 2 elements
                 ▿ 0 : 2 elements
                   - key : url
                   - value : https://dev.maxpreps.com/athlete/jaxson-dart/GFer9FUbEeeT-Oz0u-e-FA/awards.htm
                 ▿ 1 : 2 elements
                   - key : text
                   - value : Jaxson's Awards
         */
        
    }
    
    // MARK: - ScrollView Delegate

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let xScroll = CGFloat(scrollView.contentOffset.x)
        let currentPage = Int(xScroll / (kDeviceWidth - 40))
        pageControl.currentPage = currentPage
        //print("Current Page: " + String(currentPage))
        
        if (currentPage > 0) && (currentPage < (awardsArray.count - 1))
        {
            awardsCollectionView.setContentOffset(CGPoint(x: awardsCollectionView.contentOffset.x - CGFloat(currentPage * 32), y: 0), animated: true)
        }
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // Register the POG Award Cell
        awardsCollectionView.register(UINib.init(nibName: "PlayerOfTheGameCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PlayerOfTheGameCollectionViewCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
