//
//  NewProfileMyTeamsTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/13/23.
//

import UIKit

protocol NewProfileMyTeamsTableViewCellDelegate: AnyObject
{
    func myTeamsTableViewCellTouched(selectedTeam: Dictionary<String,Any>)
}

class NewProfileMyTeamsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    weak var delegate: NewProfileMyTeamsTableViewCellDelegate?
    
    @IBOutlet weak var sportNameLabel: UILabel!
    @IBOutlet weak var sportIconImageView: UIImageView!
    @IBOutlet weak var teamsCollectionView: UICollectionView!
    @IBOutlet weak var contactButton: UIButton!
    
    private var teamsArray = [] as Array<Dictionary<String,Any>>
    
    // MARK: - CollectionView Delegate Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return teamsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if (teamsArray.count > 1)
        {
            // Narrow the cell so the neighbor will show
            return CGSize(width: kDeviceWidth - 50.0, height: 172.0)
        }
        else
        {
            return CGSize(width: kDeviceWidth - 40.0, height: 172.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 12.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 12.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewProfileMyTeamsCollectionViewCell", for: indexPath) as! NewProfileMyTeamsCollectionViewCell
        
        let cardData = teamsArray[indexPath.row]

        let sport = cardData["sport"] as! String
        sportNameLabel.text = sport.uppercased()
        
        let sportImage = MiscHelper.getImageForSport(sport)
        sportIconImageView.image = sportImage
        
        cell.loadData(data: cardData)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let team = teamsArray[indexPath.row]
        self.delegate!.myTeamsTableViewCellTouched(selectedTeam: team)
    }
    
    // MARK: - Load Data Method
    
    func loadData(data: Dictionary<String,Any>)
    {
        teamsArray = data["teams"] as! Array<Dictionary<String,Any>>
        teamsCollectionView.reloadData()
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        // Register the ProfileTeamsCollectionView Cell
        teamsCollectionView.register(UINib.init(nibName: "NewProfileMyTeamsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewProfileMyTeamsCollectionViewCell")

    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
