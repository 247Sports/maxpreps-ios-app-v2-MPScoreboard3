//
//  NewsStandingsTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 12/7/21.
//

import UIKit

protocol NewsStandingsTableViewCellDelegate: AnyObject
{
    func newsStandingsTableViewCellDidSelectTeam(team: Team)
    func newsStandingsTableViewCellDidSelectStandings(urlString: String, title: String)
}

class NewsStandingsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate
{
    weak var delegate: NewsStandingsTableViewCellDelegate?
    
    @IBOutlet weak var standingsCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var favoriteTeamIdentifierArray = [] as Array<String>
    
    private var standingsArray = [] as! Array<Dictionary<String,Any>>
    
    // MARK: - Build Team Method
    
    private func buildTeam(index: Int, section: Int, item: Int)
    {
        let standingObj = standingsArray[index]
        let genderSport = standingObj["genderSport"] as! String
        let genderSportArray = genderSport.components(separatedBy: ",")
        
        var gender = ""
        var sport = ""
        if (genderSportArray.count == 2)
        {
            gender = genderSportArray[0]
            sport = genderSportArray[1]
        }
        
        // This is optional until the prperties are added to the feed
        let allSeasonId = standingObj["allSeasonId"] as? String ?? ""
        let season = standingObj["season"] as? String ?? ""
        
        let sections = standingObj["standingSections"] as! Array<Dictionary<String,Any>>
        let section = sections[section]
        let teams = section["standings"] as! Array<Dictionary<String,Any>>
        let team = teams[item]
        let schoolName = team["schoolName"] as! String
        let schoolId = team["schoolId"] as! String
        let schoolColor = team["schoolColor1"] as! String
        let schoolMascotUrl = team["schoolMascotUrl"] as! String
        
        let selectedTeam = Team(teamId: 0, allSeasonId: allSeasonId, gender: gender, sport: sport, teamColor: schoolColor, mascotUrl: schoolMascotUrl, schoolName: schoolName, teamLevel: "Varsity", schoolId: schoolId, schoolState: "", schoolCity: "", schoolFullName: "", season: season, notifications: [])
        
        self.delegate?.newsStandingsTableViewCellDidSelectTeam(team: selectedTeam)
    }
    
    // MARK: - Button Methods
    
    @objc private func topTeamTouched(_ sender: UIButton)
    {
        if ((sender.tag >= 100) && (sender.tag < 200))
        {
            let index = sender.tag - 100
            self.buildTeam(index: index, section: 0, item: 0)
        }
        else if ((sender.tag >= 200) && (sender.tag < 300))
        {
            let index = sender.tag - 200
            self.buildTeam(index: index, section: 0, item: 1)
        }
        else if ((sender.tag >= 300) && (sender.tag < 400))
        {
            let index = sender.tag - 300
            self.buildTeam(index: index, section: 0, item: 2)
        }
    }
    
    @objc private func bottomTeamTouched(_ sender: UIButton)
    {
        if ((sender.tag >= 100) && (sender.tag < 200))
        {
            let index = sender.tag - 100
            self.buildTeam(index: index, section: 1, item: 0)
        }
        else if ((sender.tag >= 200) && (sender.tag < 300))
        {
            let index = sender.tag - 200
            self.buildTeam(index: index, section: 1, item: 1)
        }
        else if ((sender.tag >= 300) && (sender.tag < 400))
        {
            let index = sender.tag - 300
            self.buildTeam(index: index, section: 1, item: 2)
        }
    }
    
    @objc private func contactSupportButtonTouched(_ sender: UIButton)
    {
        self.delegate?.newsStandingsTableViewCellDidSelectStandings(urlString: kTechSupportUrl, title: "Support")
    }
    
    @objc private func bottomOverallStandingsTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let standingObj = standingsArray[index]
        
        let urlString = standingObj["teamStandingsUrl"] as? String ?? ""
        self.delegate?.newsStandingsTableViewCellDidSelectStandings(urlString: urlString, title: "Standings")
    }
    
    // MARK: - CollectionView Delegates
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return standingsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: kDeviceWidth, height: 510.0)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsStandingsCollectionViewCell", for: indexPath) as! NewsStandingsCollectionViewCell
        
        cell.favoriteTeamIdentifierArray = self.favoriteTeamIdentifierArray
        
        let standing = standingsArray[indexPath.row]
        cell.loadData(standing)
        
        cell.topTeamSelectorButton1.tag = 100 + indexPath.row
        cell.topTeamSelectorButton2.tag = 200 + indexPath.row
        cell.topTeamSelectorButton3.tag = 300 + indexPath.row
        cell.bottomTeamSelectorButton1.tag = 100 + indexPath.row
        cell.bottomTeamSelectorButton2.tag = 200 + indexPath.row
        cell.bottomTeamSelectorButton3.tag = 300 + indexPath.row
        cell.bottomContactSupportButton.tag = 100 + indexPath.row
        cell.bottomStandingsButton.tag = 100 + indexPath.row
        
        cell.topTeamSelectorButton1.addTarget(self, action: #selector(topTeamTouched(_:)), for: .touchUpInside)
        cell.topTeamSelectorButton2.addTarget(self, action: #selector(topTeamTouched(_:)), for: .touchUpInside)
        cell.topTeamSelectorButton3.addTarget(self, action: #selector(topTeamTouched(_:)), for: .touchUpInside)
        cell.bottomTeamSelectorButton1.addTarget(self, action: #selector(bottomTeamTouched(_:)), for: .touchUpInside)
        cell.bottomTeamSelectorButton2.addTarget(self, action: #selector(bottomTeamTouched(_:)), for: .touchUpInside)
        cell.bottomTeamSelectorButton3.addTarget(self, action: #selector(bottomTeamTouched(_:)), for: .touchUpInside)
        cell.bottomContactSupportButton.addTarget(self, action: #selector(contactSupportButtonTouched(_:)), for: .touchUpInside)
        cell.bottomStandingsButton.addTarget(self, action: #selector(bottomOverallStandingsTouched(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        
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
        standingsArray = data
        
        if (standingsArray.count > 1)
        {
            pageControl.numberOfPages = standingsArray.count
            pageControl.isUserInteractionEnabled = false
            subtitleLabel.text = String(format: "Following %d teams", standingsArray.count)
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

        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        // Register the NewsStandingsCollectionViewCell
        standingsCollectionView.register(UINib.init(nibName: "NewsStandingsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewsStandingsCollectionViewCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
