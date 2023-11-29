//
//  StaffInfoTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 11/17/21.
//

import UIKit

class StaffInfoTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var adminTeamsCollectionView: UICollectionView!
    @IBOutlet weak var elsewhereTitleLabel: UILabel!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var lowerContainerView: UIView!
    @IBOutlet weak var bioLabel: UILabel!
    
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileAdminTeamsCollectionViewCell", for: indexPath) as! ProfileAdminTeamsCollectionViewCell
        
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
    
    func loadData(data: Dictionary<String,Any>)
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
        
        innerContainerView.layer.cornerRadius = 12
        innerContainerView.clipsToBounds = true

        // Register the ProfileAdminTeamsCollectionView Cell
        adminTeamsCollectionView.register(UINib.init(nibName: "ProfileAdminTeamsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProfileAdminTeamsCollectionViewCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
