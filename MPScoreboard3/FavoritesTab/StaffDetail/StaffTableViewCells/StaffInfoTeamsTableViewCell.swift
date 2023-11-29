//
//  StaffInfoTeamsTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/1/23.
//

import UIKit

class StaffInfoTeamsTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var adminTeamsCollectionView: UICollectionView!
    
    private var adminTeamsArray = [] as Array<Dictionary<String,Any>>
    
    // MARK: - CollectionView Delegate Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return adminTeamsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        if (adminTeamsArray.count > 1)
        {
            return CGSize(width: 306.0, height: 80.0)
        }
        else
        {
            return CGSize(width: kDeviceWidth - 40, height: 80.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 10.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StaffTeamsCollectionViewCell", for: indexPath) as! StaffTeamsCollectionViewCell
        
        let cardData = adminTeamsArray[indexPath.row]
        let colorString = cardData["schoolColor1"] as! String
        let schoolColor = ColorHelper.color(fromHexString: colorString, colorCorrection: true)
        
        cell.addShapeLayers(color: schoolColor!)
        cell.loadData(data: cardData)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        //let team = adminTeamsArray[indexPath.row]
        //self.delegate!.adminTeamsTableViewCellTouched(selectedTeam: team)
    }
        
    // MARK: - Load Data Method
    
    func loadData(_ data: Dictionary<String,Any>)
    {
        if (data["adminTeams"] != nil)
        {
            adminTeamsArray = data["adminTeams"] as! Array<Dictionary<String,Any>>
            adminTeamsCollectionView.reloadData()
        }
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        // Register the ProfileAdminTeamsCollectionView Cell
        adminTeamsCollectionView.register(UINib.init(nibName: "StaffTeamsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "StaffTeamsCollectionViewCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
