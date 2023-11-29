//
//  TallFavoriteTeamTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/11/21.
//

import UIKit

protocol TallFavoriteTeamTableViewCellDelegate: AnyObject
{
    func collectionViewDidSelectWebItem(urlString: String, title: String)
    func collectionViewDidSelectVideoItem(videoId: String)
    func topContestTouched(urlString: String, contestId: String)
    func bottomContestTouched(urlString: String, contestId: String)
}

class TallFavoriteTeamTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource
{
    weak var delegate: TallFavoriteTeamTableViewCellDelegate?
    private var kCornerRadius = CGFloat(12)
    
    var articleArray = [] as Array<Dictionary<String,String>>
    var topContestData = [:] as Dictionary<String,Any>
    var bottomContestData = [:] as Dictionary<String,Any>
    
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var mascotContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var sportIconImageView: UIImageView!
    @IBOutlet weak var teamMascotImageView: UIImageView!
    @IBOutlet weak var teamFirstLetterLabel: UILabel!
    @IBOutlet weak var memberContainerView: UIView!
    @IBOutlet weak var adminContainerView: UIView!
    
    @IBOutlet weak var recordContainerView: UIView!
    @IBOutlet weak var recordLabel: UILabel!
    
    @IBOutlet weak var contestContainerView: UIView!
    @IBOutlet weak var contestTopInnerContainerView: UIView!
    @IBOutlet weak var topContestMascotImageView: UIImageView!
    @IBOutlet weak var topContestFirstLetterLabel: UILabel!
    @IBOutlet weak var topContestHomeAwayLabel: UILabel!
    @IBOutlet weak var topContestOpponentLabel: UILabel!
    @IBOutlet weak var topContestDateLabel: UILabel!
    @IBOutlet weak var topContestResultOrTimeLabel: UILabel!
    
    @IBOutlet weak var contestBottomInnerContainerView: UIView!
    @IBOutlet weak var bottomContestMascotImageView: UIImageView!
    @IBOutlet weak var bottomContestFirstLetterLabel: UILabel!
    @IBOutlet weak var bottomContestHomeAwayLabel: UILabel!
    @IBOutlet weak var bottomContestOpponentLabel: UILabel!
    @IBOutlet weak var bottomContestDateLabel: UILabel!
    @IBOutlet weak var bottomContestResultOrTimeLabel: UILabel!
    
    @IBOutlet weak var articleContainerView: UIView!
    @IBOutlet weak var articleCollectionView: UICollectionView!
    
    
    // MARK: - CollectionView Delegate Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return articleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArticleCollectionViewCell", for: indexPath) as! ArticleCollectionViewCell
        
        let article = articleArray[indexPath.row]
        let articleUrlString = article["thumbnailUrl"]
        let articleTitle = article["title"]
        let type = article["type"]
        
        // Load the title
        cell.articleTitleLabel.text = articleTitle
        
        // Show the video or photo icons
        if (type == "Article")
        {
            cell.photoIconImageView.isHidden = true
            cell.videoPlayIconImageView.isHidden = true
        }
        else if (type == "Video")
        {
            cell.photoIconImageView.isHidden = true
            cell.videoPlayIconImageView.isHidden = false
        }
        else
        {
            cell.photoIconImageView.isHidden = false
            cell.videoPlayIconImageView.isHidden = true
        }
        
        // Load the image
        if (articleUrlString!.count > 0)
        {
            let url = URL(string: articleUrlString!)
            
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }
                
                //print("Download Finished")
                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        cell.articleImageView.image = image
                    }
                    else
                    {
                        cell.articleImageView.image = UIImage(named: "EmptyLandscapePhoto")
                    }
                }
            }
        }
        else
        {
            cell.articleImageView.image = UIImage(named: "EmptyLandscapePhoto")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let article = articleArray[indexPath.row]
        let articleUrl = article["canonicalUrl"]
        var title = article["type"]   
        
        // Extract the videoid from the url if the type is video
        if (title == "Video")
        {
            let videoId = MiscHelper.extractVideoIdFromString(articleUrl!)
            
            if (videoId.count > 0)
            {
                // Video was found
                self.delegate!.collectionViewDidSelectVideoItem(videoId: videoId)
            }
        }
        else
        {
            // Call the web
            if (title == "PhotoGallery")
            {
                title = "Pro Photos"
            }
            
            self.delegate?.collectionViewDidSelectWebItem(urlString: articleUrl!, title: title!)
        }
        
    }
    
    // MARK: - Button Methods
    
    @IBAction func topContestButtonTouched()
    {
        let urlString = topContestData["canonicalUrl"] as? String ?? ""
        let contestId = topContestData["contestId"] as? String ?? ""
        self.delegate?.topContestTouched(urlString: urlString, contestId: contestId)
    }
    
    @IBAction func bottomContestButtonTouched()
    {
        let urlString = bottomContestData["canonicalUrl"] as? String ?? ""
        let contestId = bottomContestData["contestId"] as? String ?? ""
        self.delegate?.bottomContestTouched(urlString: urlString, contestId: contestId)
    }
    
    // MARK: - Load Team Record Data
    
    func loadTeamRecordData(_ data: Dictionary<String, Any>)
    {
        recordContainerView.isHidden = false
        
        // Check if there is any data since it could be an empty dictionary
        if (data["overallStanding"] == nil)
        {
            recordLabel.text = "No record found"
        }
        else
        {
            let overallStandingDict = data["overallStanding"] as! Dictionary<String,Any>
            let leagueStandingDict = data["leagueStanding"] as! Dictionary<String,Any>
            let winLossTies = overallStandingDict["overallWinLossTies"] as! String
            let leagueName = leagueStandingDict["leagueName"] as! String
            let conferenceStanding = leagueStandingDict["conferenceStandingPlacement"] as! String
            
            var text = ""
            if (leagueName.count > 0)
            {
                if (conferenceStanding.count > 0)
                {
                    text = String(format: "%@, %@ in %@", winLossTies, conferenceStanding, leagueName)
                }
                else
                {
                    text = String(format: "%@, %@", winLossTies, leagueName)
                }
            }
            else
            {
                text = String(format: "Record: %@", winLossTies)
            }
            
            recordLabel.text = text
        }
    }
    
    // MARK: - Load Contest Data
    
    func loadTopContestData(_ data: Dictionary<String,Any>)
    {
        contestContainerView.isHidden = false
        contestTopInnerContainerView.isHidden = false
        
        topContestData = data
        
        var opponentName = data["opponentNameAcronym"] as? String ?? ""
        var opponentUrl = ""
        var opponentColor = UIColor.mpRedColor()
        var initial = ""
        
        if (opponentName.count > 0)
        {
            // Normal opponent
            opponentUrl = data["opponentMascotUrl"] as? String ?? ""
            let opponentColorString = data["opponentColor1"] as? String ?? ""
            opponentColor = ColorHelper.color(fromHexString: opponentColorString, colorCorrection: true)
            initial = String(opponentName.prefix(1))
        }
        else
        {
            // TBA Case
            opponentName = "TBA"
            initial = "T"
        }
        let dateString = data["dateString"] as! String

        topContestFirstLetterLabel.text = initial
        topContestOpponentLabel.text = opponentName
        topContestDateLabel.text = dateString
        
        let homeAwayType = data["homeAwayType"] as! String
        if (homeAwayType == "Away")
        {
            topContestHomeAwayLabel.text = "@"
        }
        else
        {
            topContestHomeAwayLabel.text = "vs."
        }
        
        let hasResult = data["hasResult"] as! Bool
        if (hasResult == true)
        {
            let resultString = data["resultString"] as! String
            let attrString =  NSMutableAttributedString(string:resultString)
            let range = NSRange(location: 0, length: 1)
            let firstLetter = resultString.prefix(1)
            
            // Gray for ties
            var color = UIColor.mpGrayColor()
            if (firstLetter == "W")
            {
                color = UIColor.mpGreenColor()
            }
            else if (firstLetter == "L")
            {
                color = UIColor.mpRedColor()
            }
            attrString.addAttribute(NSAttributedString.Key.foregroundColor,value:color, range:range)
            topContestResultOrTimeLabel.attributedText = attrString
        }
        else
        {
            let timeString = data["timeString"] as! String
            topContestResultOrTimeLabel.text = timeString
        }
        
        let url = URL(string: opponentUrl)

        if (opponentUrl.count > 0)
        {
            // Get the data and make an image
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }
                //print("Download Finished")
                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        self.topContestFirstLetterLabel.isHidden = true
                        
                        // Render the mascot using this helper
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.topContestMascotImageView)!)
                    }
                    else
                    {
                        // Set the first letter color
                        self.topContestFirstLetterLabel.textColor = opponentColor
                    }
                }
            }
        }
        else
        {
            // Set the first letter color
            self.topContestFirstLetterLabel.textColor = opponentColor
        }
    }
    
    func loadBottomContestData(_ data: Dictionary<String,Any>)
    {
        contestContainerView.isHidden = false
        contestBottomInnerContainerView.isHidden = false
        
        bottomContestData = data
        
        var opponentName = data["opponentNameAcronym"] as? String ?? ""
        var opponentUrl = ""
        var opponentColor = UIColor.mpRedColor()
        var initial = ""
        
        if (opponentName.count > 0)
        {
            // Normal opponent
            opponentUrl = data["opponentMascotUrl"] as? String ?? ""
            let opponentColorString = data["opponentColor1"] as? String ?? ""
            opponentColor = ColorHelper.color(fromHexString: opponentColorString, colorCorrection: true)
            initial = String(opponentName.prefix(1))
        }
        else
        {
            // TBA Case
            opponentName = "TBA"
            initial = "T"
        }

        let dateString = data["dateString"] as! String

        bottomContestFirstLetterLabel.text = initial
        bottomContestOpponentLabel.text = opponentName
        bottomContestDateLabel.text = dateString
        
        let homeAwayType = data["homeAwayType"] as! String
        if (homeAwayType == "Away")
        {
            bottomContestHomeAwayLabel.text = "@"
        }
        else
        {
            bottomContestHomeAwayLabel.text = "vs."
        }
        
        let hasResult = data["hasResult"] as! Bool
        if (hasResult == true)
        {
            let resultString = data["resultString"] as! String
            let attrString =  NSMutableAttributedString(string:resultString)
            let range = NSRange(location: 0, length: 1)
            let firstLetter = resultString.prefix(1)
            
            // Gray for ties
            var color = UIColor.mpGrayColor()
            if (firstLetter == "W")
            {
                color = UIColor.mpGreenColor()
            }
            else if (firstLetter == "L")
            {
                color = UIColor.mpRedColor()
            }
            attrString.addAttribute(NSAttributedString.Key.foregroundColor,value:color, range:range)
            bottomContestResultOrTimeLabel.attributedText = attrString
        }
        else
        {
            let timeString = data["timeString"] as! String
            bottomContestResultOrTimeLabel.text = timeString
        }
        
        let url = URL(string: opponentUrl)

        if (opponentUrl.count > 0)
        {
            // Get the data and make an image
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }
                //print("Download Finished")
                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        self.bottomContestFirstLetterLabel.isHidden = true
                        
                        // Render the mascot using this helper
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.bottomContestMascotImageView)!)
                    }
                    else
                    {
                        // Set the first letter color
                        self.bottomContestFirstLetterLabel.textColor = opponentColor
                    }
                }
            }
        }
        else
        {
            // Set the first letter color
            self.bottomContestFirstLetterLabel.textColor = opponentColor
        }
    }
    
    // MARK: - Load Article Data
    
    func loadArticleData(_ data: Array<Dictionary<String,String>>)
    {
        articleContainerView.isHidden = false
        
        articleArray = data
        
        articleCollectionView.reloadData()
    }
    
    // MARK: - Set Display Mode
    
    func setDisplayMode(mode: FavoriteDetailCellMode)
    {
        switch mode
        {
        case FavoriteDetailCellMode.allCells:
            
            // Reset the frmaes to their default location
            contestContainerView.frame = CGRect(x: 0, y: topContainerView.frame.origin.y + topContainerView.frame.size.height + recordContainerView.frame.size.height, width: contestContainerView.frame.size.width, height: contestContainerView.frame.size.height)
            
            articleContainerView.frame = CGRect(x: 0, y: topContainerView.frame.origin.y + topContainerView.frame.size.height + recordContainerView.frame.size.height + contestContainerView.frame.size.height, width: articleContainerView.frame.size.width, height: articleContainerView.frame.size.height)
                        
            articleContainerView.layer.cornerRadius = kCornerRadius
            articleContainerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            articleContainerView.clipsToBounds = true
            
        case FavoriteDetailCellMode.allCellsOneContest:
            
            // Reset the frmaes to their default location
            contestContainerView.frame = CGRect(x: 0, y: topContainerView.frame.origin.y + topContainerView.frame.size.height + recordContainerView.frame.size.height, width: contestContainerView.frame.size.width, height: contestContainerView.frame.size.height - contestBottomInnerContainerView.frame.size.height)
            
            articleContainerView.frame = CGRect(x: 0, y: topContainerView.frame.origin.y + topContainerView.frame.size.height + recordContainerView.frame.size.height + contestContainerView.frame.size.height, width: articleContainerView.frame.size.width, height: articleContainerView.frame.size.height)
                            
            articleContainerView.layer.cornerRadius = kCornerRadius
            articleContainerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            articleContainerView.clipsToBounds = true
            
        case FavoriteDetailCellMode.noArticlesAllContests:
            
            articleContainerView.isHidden = true
            
            contestContainerView.frame = CGRect(x: 0, y: topContainerView.frame.origin.y + topContainerView.frame.size.height + recordContainerView.frame.size.height, width: contestContainerView.frame.size.width, height: contestContainerView.frame.size.height)
            
            contestContainerView.layer.cornerRadius = kCornerRadius
            contestContainerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            contestContainerView.clipsToBounds = true
            
        case FavoriteDetailCellMode.noArticlesOneContest:
            
            articleContainerView.isHidden = true
            
            contestContainerView.frame = CGRect(x: 0, y: topContainerView.frame.origin.y + topContainerView.frame.size.height + recordContainerView.frame.size.height, width: contestContainerView.frame.size.width, height: contestContainerView.frame.size.height - contestBottomInnerContainerView.frame.size.height)
            
            contestContainerView.layer.cornerRadius = kCornerRadius
            contestContainerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            contestContainerView.clipsToBounds = true

        case FavoriteDetailCellMode.noContests:
            
            contestContainerView.isHidden = true
            
            articleContainerView.frame = CGRect(x: 0, y: topContainerView.frame.origin.y + topContainerView.frame.size.height + recordContainerView.frame.size.height, width: articleContainerView.frame.size.width, height: articleContainerView.frame.size.height)
            
            articleContainerView.layer.cornerRadius = kCornerRadius
            articleContainerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            articleContainerView.clipsToBounds = true
            
        case FavoriteDetailCellMode.noContestsOrArticles:
            
            contestContainerView.isHidden = true
            articleContainerView.isHidden = true
            
            recordContainerView.layer.cornerRadius = kCornerRadius
            recordContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            recordContainerView.clipsToBounds = true
        }
    }
    
    // MARK: - Draw Shape Layers
    
    func addShapeLayers(color: UIColor)
    {
        // Create a new path for the rear light part
        let rearPath = UIBezierPath()

        // Starting point for the path
        rearPath.move(to: CGPoint(x: 0, y: 0))
        rearPath.addLine(to: CGPoint(x: 57, y: 0))
        rearPath.addLine(to: CGPoint(x: 13, y: topContainerView.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: topContainerView.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: 0))
        rearPath.close()
        
        // Create a CAShapeLayer
        //let lightColor = color.lighter(by: 70.0)
        let lightColor = color.withAlphaComponent(0.3)
        let rearShapeLayer = CAShapeLayer()
        rearShapeLayer.path = rearPath.cgPath
        rearShapeLayer.fillColor = lightColor.cgColor
        rearShapeLayer.position = CGPoint(x: 0, y: 0)

        self.topContainerView.layer.insertSublayer(rearShapeLayer, below: self.mascotContainerView.layer)
        
        
        // Create a new path for the dark front part
        let frontPath = UIBezierPath()

        // Starting point for the path
        frontPath.move(to: CGPoint(x: 0, y: 0))
        frontPath.addLine(to: CGPoint(x: 42, y: 0))
        frontPath.addLine(to: CGPoint(x: 10, y: topContainerView.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: topContainerView.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: 0))
        frontPath.close()
        
        // Create a CAShapeLayer
        let frontShapeLayer = CAShapeLayer()
        frontShapeLayer.path = frontPath.cgPath
        frontShapeLayer.fillColor = color.cgColor
        frontShapeLayer.position = CGPoint(x: 0, y: 0)

        self.topContainerView.layer.insertSublayer(frontShapeLayer, above: rearShapeLayer)
    }
    
    // MARK: - Init Methods
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        self.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        self.contentView.clipsToBounds = true
        
        // Round the edges
        topContainerView.layer.cornerRadius = kCornerRadius
        topContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        topContainerView.clipsToBounds = true
        
        mascotContainerView.layer.cornerRadius = self.mascotContainerView.frame.size.width / 2.0
        mascotContainerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        mascotContainerView.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        mascotContainerView.layer.shadowOpacity = 1.0
        mascotContainerView.layer.shadowRadius = 4.0
        mascotContainerView.clipsToBounds = false
        
        // Register the Gallery Cell
        articleCollectionView.register(UINib.init(nibName: "ArticleCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ArticleCollectionViewCell")
        
        // Hide the various inner containers. They will be unhidden in the load data functions
        recordContainerView.isHidden = true
        contestContainerView.isHidden = true
        contestTopInnerContainerView.isHidden = true
        contestBottomInnerContainerView.isHidden = true
        articleContainerView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
