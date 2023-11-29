//
//  TeamVideoTeamPickerView.swift
//  MPScoreboard3
//
//  Created by David Smith on 11/18/22.
//

import UIKit

protocol TeamVideoTeamPickerViewDelegate: AnyObject
{
    func teamVideoTeamPickerViewDidSelectItem(index: Int)
}

class TeamVideoTeamPickerView: UIView, UITableViewDelegate, UITableViewDataSource
{
    weak var delegate: TeamVideoTeamPickerViewDelegate?
    
    private var roundRectView: UIView!
    private var teamsTableView: UITableView!
    private var activeTeamsArray = [] as! Array<Dictionary<String,Any>>
    private var schoolNameCopy = ""
    private var selectedIndex = 0
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return activeTeamsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 64.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 1.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "CareerRosterPickerTableViewCell") as? CareerRosterPickerTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("CareerRosterPickerTableViewCell", owner: self, options: nil)
            cell = nib![0] as? CareerRosterPickerTableViewCell
        }
        
        cell?.selectionStyle = .none
        cell?.horizLine.isHidden = false
        cell?.checkmarkImageView.isHidden = true
        
        if (indexPath.row == (activeTeamsArray.count - 1))
        {
            cell?.horizLine.isHidden = true
        }
        
        if (indexPath.row == selectedIndex)
        {
            cell?.checkmarkImageView.isHidden = false
        }
        
        let currentTeam = activeTeamsArray[indexPath.row]
        
        let gender = currentTeam["gender"] as? String ?? ""
        let sport = currentTeam["sport"] as? String ?? ""
        let level = currentTeam["level"] as? String ?? ""
        let year = currentTeam["year"] as? String ?? ""
        let season = currentTeam["season"] as? String ?? ""
        
        cell?.schoolNameLabel.text = schoolNameCopy
        
        let genderSportLevel = MiscHelper.genderSportLevelFrom(gender: gender, sport: sport, level: level)
        
        if (sport.lowercased() == "soccer")
        {
            cell?.genderSportLabel.text = String(format: "%@ (%@ %@)", genderSportLevel, season, year)
        }
        else
        {
            cell?.genderSportLabel.text = String(format: "%@ (%@)", genderSportLevel, year)
        }
        
        cell?.sportIconImageView.image = MiscHelper.getImageForSport(sport)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
                
        // Animate back
        let scaleTransform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        let translateTransform = CGAffineTransform(translationX: (self.frame.size.width / 2.0) - 12.0, y: -roundRectView.frame.size.height / 2.0)
        
        UIView.animate(withDuration: 0.33, animations: {
            
            // Return to the button location
            self.roundRectView.alpha = 0
            self.roundRectView.transform = CGAffineTransformConcat(scaleTransform, translateTransform)
        })
        { (finished) in
            
            self.delegate?.teamVideoTeamPickerViewDidSelectItem(index: indexPath.row)
        } 
    }
    
    // MARK: - Gesture Methods
    
    @objc func handleTap(sender: UITapGestureRecognizer)
    {
        // Animate back
        let scaleTransform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        let translateTransform = CGAffineTransform(translationX: (self.frame.size.width / 2.0) - 12.0, y: -roundRectView.frame.size.height / 2.0)
        
        UIView.animate(withDuration: 0.33, animations: {
            
            // Return to the button location
            self.roundRectView.alpha = 0
            self.roundRectView.transform = CGAffineTransformConcat(scaleTransform, translateTransform)
        })
        { (finished) in
            
            self.delegate?.teamVideoTeamPickerViewDidSelectItem(index: self.selectedIndex)
        }
    }
    
    // MARK: - Init Methods
    
    required init(frame: CGRect, activeTeams: Array<Dictionary<String,Any>>, index: Int, buttonFrame: CGRect, schoolName: String)
    {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        let clearBackgroundView = UIView(frame: frame)
        clearBackgroundView.backgroundColor = .clear
        self.addSubview(clearBackgroundView)
        
        // Add a tap gesture recognizer to the blackBackgroundView
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        clearBackgroundView.addGestureRecognizer(tapGesture)
        
        activeTeamsArray = activeTeams
        selectedIndex = index
        schoolNameCopy = schoolName
        
        roundRectView = UIView(frame: CGRect(x: 12, y: buttonFrame.origin.y + buttonFrame.size.height + 56, width: frame.size.width - 24.0, height: 256))
        roundRectView.backgroundColor = UIColor.mpOffWhiteNavColor()
        roundRectView.layer.cornerRadius = 12
        roundRectView.layer.borderWidth = 1
        roundRectView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        
        // Add a shadow to the roundRectView
        roundRectView.layer.shadowColor = UIColor(white: 0.7, alpha: 1.0).cgColor
        roundRectView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        roundRectView.layer.shadowRadius = 3.0
        roundRectView.layer.shadowOpacity = 0.5
        roundRectView.layer.masksToBounds = false
        self.addSubview(roundRectView)
        
        teamsTableView = UITableView(frame: CGRect(x: 0, y: 0, width: roundRectView.frame.size.width, height: roundRectView.frame.size.height), style: .grouped)
        teamsTableView.backgroundColor = UIColor.mpOffWhiteNavColor()
        teamsTableView.delegate = self
        teamsTableView.dataSource = self
        teamsTableView.separatorStyle = .none
        teamsTableView.insetsContentViewsToSafeArea = false
        teamsTableView.layer.cornerRadius = 12
        teamsTableView.clipsToBounds = true
        roundRectView.addSubview(teamsTableView)
        
        // Transform and shrink the view to the button location
        let scaleTransform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        let translateTransform = CGAffineTransform(translationX: (frame.size.width / 2.0) - 12.0, y: -roundRectView.frame.size.height / 2.0)
        roundRectView.transform = CGAffineTransformConcat(scaleTransform, translateTransform)
        roundRectView.alpha = 0
 
        // Animate to full size and rotate the button
        UIView.animate(withDuration: 0.33, animations: {
            
            self.roundRectView.alpha = 1.0
            self.roundRectView.transform = .identity
        })
        { (finished) in
            
            // Flash the scroll indicator
            self.teamsTableView.flashScrollIndicators()
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
