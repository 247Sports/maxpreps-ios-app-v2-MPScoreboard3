//
//  NewsTeamRankingsTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 12/14/21.
//

import UIKit

protocol NewsTeamRankingsTableViewCellDelegate: AnyObject
{
    func newsTeamRankingsTableViewCellFullRankingsTouched(urlString: String)
    func newsTeamRankingsTableViewCellDidSelectTeam(team: Team)
}

class NewsTeamRankingsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate
{
    weak var delegate: NewsTeamRankingsTableViewCellDelegate?
    
    @IBOutlet weak var rankingsCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    private var rankingsArray = [] as! Array<Dictionary<String,Any>>
    
    // MARK: - CollectionView Delegates
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return rankingsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: kDeviceWidth, height: 408.0)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsTeamRankingsCollectionViewCell", for: indexPath) as! NewsTeamRankingsCollectionViewCell
        
        let rankings = rankingsArray[indexPath.row]
        cell.loadData(rankings)
        
        cell.headerButton.tag = 100 + indexPath.row
        cell.headerButton.addTarget(self, action: #selector(headerButtonTouched(_:)), for: .touchUpInside)
        
        cell.fullRankingsButton.tag = 100 + indexPath.row
        cell.fullRankingsButton.addTarget(self, action: #selector(fullRankingsButtonTouched(_:)), for: .touchUpInside)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        
    }
    
    // MARK: - Button Methods
    
    @objc private func headerButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let rankings = rankingsArray[index]
        
        let gender = rankings["gender"] as! String
        let sport = rankings["sport"] as! String
        let season = rankings["season"] as! String
        let schoolId = rankings["teamId"] as! String
        let allSeasonId = rankings["allSeasonId"] as! String
        let schoolName = rankings["schoolName"] as! String
        let schoolColor = rankings["schoolColor1"] as! String
        let schoolMascotUrl = rankings["schoolMascotUrl"] as! String
        
        let selectedTeam = Team(teamId: 0, allSeasonId: allSeasonId, gender: gender, sport: sport, teamColor: schoolColor, mascotUrl: schoolMascotUrl, schoolName: schoolName, teamLevel: "Varsity", schoolId: schoolId, schoolState: "", schoolCity: "", schoolFullName: "", season: season, notifications: [])
        
        self.delegate?.newsTeamRankingsTableViewCellDidSelectTeam(team:selectedTeam)
    }
    
    @objc private func fullRankingsButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let rankings = rankingsArray[index]
        
        let schoolId = rankings["teamId"] as! String
        let ssid = rankings["sportSeasonId"] as! String
        let allSeasonId = rankings["allSeasonId"] as! String
        
        var subDomain = ""
        
        // Build the subdomain
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            let branchValue = kUserDefaults.string(forKey: kBranchValue)
            subDomain = String(format: "branch-%@.fe", branchValue!.lowercased())
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            subDomain = "dev"
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            subDomain = "staging"
        }
        else
        {
            subDomain = "www"
        }

        let urlString = String(format: kRankingsHostGeneric, subDomain, schoolId, ssid, allSeasonId)
        
        self.delegate?.newsTeamRankingsTableViewCellFullRankingsTouched(urlString: urlString)
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
        rankingsArray = data
        
        if (rankingsArray.count > 1)
        {
            pageControl.numberOfPages = rankingsArray.count
            pageControl.isUserInteractionEnabled = false
            subtitleLabel.text = String(format: "Following %d teams", rankingsArray.count)
        }
        else
        {
            pageControl.isHidden = true
            subtitleLabel.text = "Following 1 team"
        }

        

    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.contentView.layer.cornerRadius = 12
        self.contentView.clipsToBounds = true
        
        // Register the NewsTeamRankingsCollectionViewCell
        rankingsCollectionView.register(UINib.init(nibName: "NewsTeamRankingsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewsTeamRankingsCollectionViewCell")

    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
