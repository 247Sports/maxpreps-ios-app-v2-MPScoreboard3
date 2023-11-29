//
//  NewsStatsTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 12/14/21.
//

import UIKit

protocol NewsStatsTableViewCellDelegate: AnyObject
{
    func newsStatsTableViewCellFullStatsTouched(urlString: String)
    func newsStatsTableViewCellDidSelectTeam(team: Team)
    func newsStatsTableViewCellDidSelectAthlete(athlete: Athlete)
}

class NewsStatsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate
{
    weak var delegate: NewsStatsTableViewCellDelegate?
    
    @IBOutlet weak var statsCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var athleteMode = true
    private var statsArray = [] as! Array<Dictionary<String,Any>>
    
    // MARK: - Button Methods
    
    @objc private func fullPlayerStatsButtonTouched(_ sender: UIButton)
    {
        self.delegate?.newsStatsTableViewCellFullStatsTouched(urlString: "")
    }
    
    @objc private func fullTeamStatsButtonTouched(_ sender: UIButton)
    {
        self.delegate?.newsStatsTableViewCellFullStatsTouched(urlString: "")
    }
    
    // MARK: - CollectionView Delegates
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return statsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: kDeviceWidth, height: 458.0)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsStatsCollectionViewCell", for: indexPath) as! NewsStatsCollectionViewCell
        
        cell.fullPlayerStatLeadersButton.tag = 100 + indexPath.row
        cell.fullTeamStatLeadersButton.tag = 100 + indexPath.row
        
        cell.fullPlayerStatLeadersButton.addTarget(self, action: #selector(fullPlayerStatsButtonTouched(_:)), for: .touchUpInside)
        cell.fullTeamStatLeadersButton.addTarget(self, action: #selector(fullTeamStatsButtonTouched(_:)), for: .touchUpInside)
        
        /*
        let stats = statsArray[indexPath.row]
        cell.loadData(stats, nationalMode: true)
        */
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        
    }
    
    // MARK: - Button Methods
    
    @objc private func containerButtonTouched(_ sender: UIButton)
    {
        /*
        var index = 0
        var offset = 0
        
        if (sender.tag >= 100) && (sender.tag < 200)
        {
            index = sender.tag - 100
            offset = 0
        }
        else if (sender.tag >= 200) && (sender.tag < 300)
        {
            index = sender.tag - 200
            offset = 1
        }
        else if (sender.tag >= 300) && (sender.tag < 400)
        {
            index = sender.tag - 300
            offset = 2
        }
        else if (sender.tag >= 400) && (sender.tag < 500)
        {
            index = sender.tag - 400
            offset = 3
        }
        else if (sender.tag >= 500) && (sender.tag < 600)
        {
            index = sender.tag - 500
            offset = 4
        }
        
        let rankingObj = statsArray[index]
        let rankingData = rankingObj["rankingData"] as! Array<Dictionary<String,Any>>
        let rankings = rankingData[offset]
        
        let gender = rankingObj["gender"] as! String
        let sport = rankingObj["sport"] as! String
        let season = rankingObj["season"] as! String
        let allSeasonId = rankingObj["allSeasonId"] as! String
        let schoolId = rankings["teamId"] as! String
        let schoolName = rankings["schoolName"] as! String
        let schoolColor = rankings["schoolColor1"] as! String
        let schoolMascotUrl = rankings["schoolMascotUrl"] as! String
        
        let selectedTeam = Team(teamId: 0, allSeasonId: allSeasonId, gender: gender, sport: sport, teamColor: schoolColor, mascotUrl: schoolMascotUrl, schoolName: schoolName, teamLevel: "Varsity", schoolId: schoolId, schoolState: "", schoolCity: "", schoolFullName: "", season: season, notifications: [])
        
        self.delegate?.newsNationalRankingsTableViewCellDidSelectTeam(team: selectedTeam)
        */
    }
    
    @objc private func fullRankingsButtonTouched(_ sender: UIButton)
    {
        /*
        let index = sender.tag - 100
        let rankingObj = rankingsArray[index]
        let urlString = rankingObj["canonicalUrl"] as! String
        
        self.delegate?.newsNationalRankingsTableViewCellFullRankingsTouched(urlString: urlString)
         */
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
        statsArray = data
        
        if (statsArray.count > 1)
        {
            pageControl.numberOfPages = statsArray.count
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
        
        // Register the NewsNationalRankingsCollectionViewCell
        statsCollectionView.register(UINib.init(nibName: "NewsStatsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewsStatsCollectionViewCell")

    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
