//
//  FavoritesListView.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/31/21.
//

import UIKit

protocol FavoritesListViewDelegate: AnyObject
{
    func closeFavoritesListView()
    func closeFavoritesListViewAfterChange()
    func joinButtonTouched(index: Int)
}

class FavoritesListView: UIView, UITableViewDelegate, UITableViewDataSource
{
    weak var delegate: FavoritesListViewDelegate?
    
    var teamOrAthleteDeleted = false
    
    private var searchVC: SearchViewController?
    private var favoriteTeamsArray = [] as Array
    private var favoriteAthletesArray = [] as Array
    private var deleteItemIndex = 0
    private let kCellHeight = 60
    
    private var favoritesTableView: UITableView?
    private var blackBackgroundView : UIView?
    private var roundRectView : UIView?
    private var roundRectHeaderContainer : UIView?
    //private var headerTitleLabel : UILabel?
    //private var headerSubtitleLabel : UILabel?
    //private var headerMascotImageView : UIImageView?
    //private var headerFirstLetterLabel : UILabel?
    
    private var editButton : UIButton?
    
    var initialCenter = CGPoint()  // The initial center point of the roundRectView for the pan geture.
    
    // MARK: - Get and Delete Favorite Athlete
    
    private func deleteFavoriteAthlete()
    {
        let favoriteToDelete = favoriteAthletesArray[deleteItemIndex] as! Dictionary<String, Any>
        let careerProfileIdToDelete = favoriteToDelete[kCareerProfileIdKey] as! String
            
        favoriteAthletesArray.remove(at: deleteItemIndex)
        
        kUserDefaults.set(favoriteAthletesArray, forKey: kUserFavoriteAthletesArrayKey)
        
        //favoritesTableView?.reloadData()
        let indexPath = IndexPath(row: deleteItemIndex, section: 1)
        favoritesTableView?.deleteRows(at: [indexPath], with: .automatic)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
        { [self] in
            
            if ((favoriteAthletesArray.count == 0) && (favoriteTeamsArray.count == 0))
            {
                favoritesTableView?.isHidden = true
                editButton?.isHidden = true
            }
            
            if (kUserDefaults .string(forKey: kUserIdKey) != kTestDriveUserId)
            {
                self.deleteUserFavoriteAthleteFromDatabase(careerProfileId: careerProfileIdToDelete)
            }
            else
            {
                self.teamOrAthleteDeleted = true
            }
        }
    }
    
    private func deleteUserFavoriteAthleteFromDatabase(careerProfileId : String)
    {
        NewFeeds.deleteUserFavoriteAthlete(careerProfileId) { (error) in
            
            if error == nil
            {
                self.teamOrAthleteDeleted = true
                
                // Get the favoriteAthletes from the database agsin
                self.getUserFavoriteAthletesFromDatabase()
            }
            else
            {
                // Dismiss any view controllers
                kAppKeyWindow.rootViewController?.dismiss(animated: false, completion: {
                    
                })
                
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "There was a server problem when unfollowing this athlete.", lastItemCancelType: false) { (tag) in
                    
                }
            }
        }
    }
    
    private func getUserFavoriteAthletesFromDatabase()
    {
        NewFeeds.getUserFavoriteAthletes(completionHandler: { error in
            
            if error == nil
            {
                self.teamOrAthleteDeleted = true
                
                if let favAthletes = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
                {
                    self.favoriteAthletesArray = favAthletes
                }
                self.favoritesTableView?.reloadData()
            }
            else
            {
                print("Download user favorite athletes error")
            }
        })
    }
    
    // MARK: - Get and Delete Favorite Team
    
    private func deleteFavoriteTeam()
    {
        let favoriteToDelete = favoriteTeamsArray[deleteItemIndex] as! Dictionary<String, Any>
        
        favoriteTeamsArray.remove(at: deleteItemIndex)
        
        kUserDefaults.set(favoriteTeamsArray, forKey: kNewUserFavoriteTeamsArrayKey)
        //favoritesTableView?.reloadData()
        let indexPath = IndexPath(row: deleteItemIndex, section: 0)
        favoritesTableView?.deleteRows(at: [indexPath], with: .automatic)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1)
        { [self] in
            
            if ((favoriteAthletesArray.count == 0) && (favoriteTeamsArray.count == 0))
                    {
                        favoritesTableView?.isHidden = true
                        editButton?.isHidden = true
            }
            
            if (kUserDefaults .string(forKey: kUserIdKey) != kTestDriveUserId)
            {
                self.deleteUserFavoriteTeamFromDatabase(team:favoriteToDelete)
            }
            else
            {
                self.teamOrAthleteDeleted = true
            }
        }
    }
    
    private func deleteUserFavoriteTeamFromDatabase(team : Dictionary<String, Any>)
    {
        NewFeeds.deleteUserFavoriteTeam(favorite: team) { (error) in
            
            if error == nil
            {
                self.teamOrAthleteDeleted = true
                
                // Get the favoriteTeams from the database agsin
                self.getUserFavoriteTeamsFromDatabase()
                
                // Post a notification that the favorite teams have been updated
                NotificationCenter.default.post(name: Notification.Name("FavoriteTeamsUpdated"), object: nil)
            }
            else
            {
                // Dismiss any view controllers
                kAppKeyWindow.rootViewController?.dismiss(animated: false, completion: {
                    
                })
                
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "There was a server problem when unfollowing this team.", lastItemCancelType: false) { (tag) in
                    
                }
            }
        }
    }
    
    private func getUserFavoriteTeamsFromDatabase()
    {
        NewFeeds.getUserFavoriteTeams(completionHandler: { error in

            if error == nil
            {
                if let favTeams = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
                {
                    self.favoriteTeamsArray = favTeams
                }
                self.favoritesTableView?.reloadData()
            }
            else
            {
                print("Download user favorite teams error")
            }
        })
        
        // Update the locationTracking regions in the app delegate
        //[appDelegate addRegionsForTracking];
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section == 0)
        {
            return favoriteTeamsArray.count
        }
        else
        {
            return favoriteAthletesArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return CGFloat(kCellHeight)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (section == 0)
        {
            if (favoriteAthletesArray.count > 0)
            {
                return 0.01
            }
            else
            {
                return 30 // Pad added to allow the last cell so it can be deleted
            }
            
        }
        else
        {
            if (favoriteAthletesArray.count > 0)
            {
                return 30 // Pad added to allow the last cell so it can be deleted
            }
            else
            {
                return 0.01
            }
        }
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
        var cell = tableView.dequeueReusableCell(withIdentifier: "ShortFavoriteTeamTableViewCell") as? ShortFavoriteTeamTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("ShortFavoriteTeamTableViewCell", owner: self, options: nil)
            cell = nib![0] as? ShortFavoriteTeamTableViewCell
        }
        
        cell?.selectionStyle = .none
        cell?.adminContainerView.isHidden = true
        cell?.joinButton.isHidden = true
        cell?.teamMascotImageView.layer.cornerRadius = 0
        cell?.teamMascotImageView.clipsToBounds = true
        
        cell?.joinButton.tag = indexPath.row + 100
        cell?.joinButton.addTarget(self, action: #selector(joinButtonTouched), for: .touchUpInside)
                
        if (indexPath.section == 0)
        {
            cell?.teamFirstLetterLabel.isHidden = false
            
            // Favorite teams section
            let favoriteTeam = favoriteTeamsArray[indexPath.row] as! Dictionary<String, Any>
            
            let name = favoriteTeam[kNewSchoolNameKey] as! String
            let initial = String(name.prefix(1))
            let gender = favoriteTeam[kNewGenderKey] as! String
            let sport = favoriteTeam[kNewSportKey] as! String
            let level = favoriteTeam[kNewLevelKey] as!String
            let schoolId = favoriteTeam[kNewSchoolIdKey] as!String
            let allSeasonId = favoriteTeam[kNewAllSeasonIdKey] as!String
            //let season = favoriteTeam[kNewSeasonKey] as! String
            let levelGenderSport = MiscHelper.genderSportLevelFrom(gender: gender, sport: sport, level: level)
            
            // Show the season for soccer
            //if (sport == "Soccer")
            //{
                //cell?.subtitleLabel.text =  String(format: "%@ (%@)", genderSportLevel, season)
            //}
            //else
            //{
                cell?.subtitleLabel.text =  levelGenderSport
            //}
            
            cell?.titleLabel.text = name
            cell?.teamFirstLetterLabel.text = initial
            cell?.teamFirstLetterLabel.isHidden = true
            
            // Look at the roles dictionary for a match if a logged in user
            let userId = kUserDefaults.string(forKey: kUserIdKey)
            
            if (userId != kTestDriveUserId)
            {
                let userIsAdmin = MiscHelper.isUserAnAdmin(schoolId: schoolId, allSeasonId: allSeasonId)
                
                if (userIsAdmin == true)
                {
                    cell?.adminContainerView.isHidden = false
                }
                
                // Add a join button if adminContainer is hidden and the user is a high school coach or statistician
                let userType = kUserDefaults.string(forKey: kUserTypeKey)
                let isAllowedToJoin = ((userType == "High School Coach") || (userType == "Statistician"))
                if ((cell?.adminContainerView.isHidden == true) && (isAllowedToJoin == true))
                {
                    cell?.joinButton.isHidden = false
                }
            }
            
            // Look for a mascot
            if let schoolsInfo = kUserDefaults.dictionary(forKey: kNewSchoolInfoDictionaryKey)
            {
                if let schoolInfo = schoolsInfo[schoolId] as? Dictionary<String, String>
                {
                    // Set the first letter color
                    let hexColorString = schoolInfo[kNewSchoolInfoColor1Key]!
                    //let color = UIColor.init(hexString: hexColorString, alpha: 1)
                    let color = ColorHelper.color(fromHexString: hexColorString, colorCorrection: true)
                    cell?.teamFirstLetterLabel.textColor = color
                    
                    let mascotUrl = schoolInfo[kNewSchoolInfoMascotUrlKey]
                    let url = URL(string: mascotUrl!)

                    if (mascotUrl!.count > 0)
                    {
                        /*
                        // Get the data and make an image
                        MiscHelper.getData(from: url!) { data, response, error in
                            guard let data = data, error == nil else { return }
                            //print("Download Finished")
                            DispatchQueue.main.async()
                            {
                                let image = UIImage(data: data)
                                
                                if (image != nil)
                                {
                                    // Render the mascot using this helper
                                    MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (cell?.teamMascotImageView)!)
                                }
                                else
                                {
                                    cell?.teamFirstLetterLabel.isHidden = false
                                }
                            }
                        }
                        */
                        SDWebImageManager.shared().downloadImage(with: url!, progress: { receivedSize, expectedSize in
                            
                        }, completed: { image, error, cacheType, finished, imageUrl in
                            
                            if (image != nil)
                            {
                                // Render the mascot using this helper
                                MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (cell?.teamMascotImageView)!)
                            }
                            else
                            {
                                cell?.teamFirstLetterLabel.isHidden = false
                            }
                        })
                    }
                    else
                    {
                        cell?.teamFirstLetterLabel.isHidden = false
                    }
                }
            }
            else
            {
                cell?.teamFirstLetterLabel.isHidden = false
            }
        }
        else
        {
            // Favorite athletes section
            let favoriteAthlete = favoriteAthletesArray[indexPath.row] as! Dictionary<String, Any>

            let firstName = favoriteAthlete[kCareerProfileFirstNameKey] as! String
            let lastName = favoriteAthlete[kCareerProfileLastNameKey] as! String
            let schoolName = favoriteAthlete[kCareerProfileSchoolNameKey] as! String
            //let initial = String(schoolName.prefix(1))
            //let mascotUrlString = favoriteAthlete[kCareerProfileSchoolMascotUrlKey] as! String
            //let colorString = favoriteAthlete[kCareerProfileSchoolColor1Key] as! String
            let athletePhotoUrlString = favoriteAthlete[kCareerProfilePhotoUrlKey] as! String
            
            cell?.titleLabel.text = firstName + " " + lastName
            cell?.subtitleLabel.text = schoolName
            
            cell?.teamFirstLetterLabel.isHidden = true
            cell?.teamMascotImageView.layer.cornerRadius = (cell?.teamMascotImageView.frame.size.width)! / 2.0
            
            cell?.teamMascotImageView.image = UIImage(named: "Avatar")
            
            if (athletePhotoUrlString.count > 0)
            {
                let url = URL(string: athletePhotoUrlString)
                
                SDWebImageManager.shared().downloadImage(with: url!, progress: { receivedSize, expectedSize in
                    
                }, completed: { image, error, cacheType, finished, imageUrl in
                    
                    if (image != nil)
                    {
                        cell?.teamMascotImageView.image = image
                    }
                })
                /*
                // Get the data and make an image
                MiscHelper.getData(from: url!) { data, response, error in
                    guard let data = data, error == nil else { return }
                    DispatchQueue.main.async()
                    {
                        let image = UIImage(data: data)
                        
                        if (image != nil)
                        {
                            cell?.teamMascotImageView.image = image
                        }
                    }
                }
                */
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
        let userId = kUserDefaults.value(forKey: kUserIdKey) as! String
        
        if (userId != kTestDriveUserId)
        {
            return .delete
        }
        else
        {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        if (indexPath.section == 0)
        {
            if (favoriteTeamsArray.count > 0)
            {
                return true
            }
            else
            {
                return false
            }
        }
        else
        {
            if (favoriteAthletesArray.count > 0)
            {
                return true
            }
            else
            {
                return false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if (editingStyle == .delete)
        {
            deleteItemIndex = indexPath.row
            
            var title = ""
            
            if (indexPath.section == 0)
            {
                let favoriteTeam = favoriteTeamsArray[indexPath.row] as! Dictionary<String, Any>
                let schoolName = favoriteTeam[kNewSchoolNameKey] as! String
                
                if (schoolName.count < 12)
                {
                    title = "Unfollow " + schoolName + "?"
                }
                else
                {
                    title = "Unfollow the selected team?"
                }
                
                // Dismiss any view controllers
                kAppKeyWindow.rootViewController?.dismiss(animated: false, completion: {
                    
                })
                
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["Unfollow", "Cancel"], title: title, message: "You will no longer receive news and scores for this team.", lastItemCancelType: true) { (tag) in
                    if (tag == 0)
                    {
                        self.deleteFavoriteTeam()
                    }
                    else
                    {
                        tableView.setEditing(false, animated: true)
                    }
                }
            }
            else
            {
                let favoriteAthlete = favoriteAthletesArray[indexPath.row] as! Dictionary<String, Any>

                let firstName = favoriteAthlete[kCareerProfileFirstNameKey] as! String
                let lastName = favoriteAthlete[kCareerProfileLastNameKey] as! String
                let initial = String(lastName.prefix(1))
                
                if (firstName.count < 12)
                {
                    title = "Unfollow " + firstName + " " + initial + "?"
                }
                else
                {
                    title = "Unfollow the selected athlete?"
                }

                // Dismiss any view controllers
                kAppKeyWindow.rootViewController?.dismiss(animated: false, completion: {
                    
                })
                
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["Unfollow", "Cancel"], title: title, message: "You will no longer receive updates for this athlete.", lastItemCancelType: true) { (tag) in
                    if (tag == 0)
                    {
                        self.deleteFavoriteAthlete()
                    }
                    else
                    {
                        tableView.setEditing(false, animated: true)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
    {
        return "Unfollow"
    }
    
    // MARK: - Button Method
    
    @objc private func editButtonTouched()
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        if (userId == kTestDriveUserId)
        {
            // Dismiss any view controllers
            kAppKeyWindow.rootViewController?.dismiss(animated: false, completion: {
                
            })
            
            MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "Membership Required", message: "Membership is required to edit teams.", lastItemCancelType: false) { tag in
                
            }
            return
        }
        
        if (favoritesTableView?.isEditing == true)
        {
            favoritesTableView?.setEditing(false, animated: true)
            editButton!.setTitle("Manage", for: .normal)
        }
        else
        {
            favoritesTableView?.setEditing(true, animated: true)
            editButton!.setTitle("Done", for: .normal)
        }
    }
    
    @objc private func closeButtonTouched()
    {
        // Animate the roundRectView and blackBackgroundView
        UIView.animate(withDuration: 0.24, animations:
                        {
                            self.roundRectView?.transform = CGAffineTransform(translationX: 0, y: (self.roundRectView?.frame.size.height)!)
                            self.blackBackgroundView?.alpha = 0.0
                        })
        { (finished) in
            
            if (self.teamOrAthleteDeleted == true)
            {
                self.delegate?.closeFavoritesListViewAfterChange()
            }
            else
            {
                self.delegate?.closeFavoritesListView()
            }
        }
    }
    
    @objc private func joinButtonTouched(_ button : UIButton)
    {
        let index = button.tag - 100
        
        // Animate the roundRectView and blackBackgroundView
        UIView.animate(withDuration: 0.24, animations:
                        {
                            self.roundRectView?.transform = CGAffineTransform(translationX: 0, y: (self.roundRectView?.frame.size.height)!)
                            self.blackBackgroundView?.alpha = 0.0
                        })
        { (finished) in
            
            self.delegate?.joinButtonTouched(index: index)
        }
    }
    
    // MARK: - Gesture Methods
    
    @objc func handleTap(sender: UITapGestureRecognizer)
    {
        // Animate the roundRectView and blackBackgroundView
        UIView.animate(withDuration: 0.24, animations:
                        {
                            self.roundRectView?.transform = CGAffineTransform(translationX: 0, y: (self.roundRectView?.frame.size.height)!)
                            self.blackBackgroundView?.alpha = 0.0
                        })
        { (finished) in
            
            if (self.teamOrAthleteDeleted == true)
            {
                self.delegate?.closeFavoritesListViewAfterChange()
            }
            else
            {
                self.delegate?.closeFavoritesListView()
            }
        }
    }
    
    @objc func handlePan(panGestureRecognizer: UIPanGestureRecognizer)
    {
        guard panGestureRecognizer.view != nil else {return}
        
        let piece = panGestureRecognizer.view!
        // Get the changes in the X and Y directions relative to
        // the superview's coordinate space.
        let translation = panGestureRecognizer.translation(in: piece.superview)
        
        if panGestureRecognizer.state == .began
        {
            // Save the view's original position.
            self.initialCenter = roundRectView!.center
        }
        // Update the position for the .began, .changed, and .ended states
        if (panGestureRecognizer.state == .began) || (panGestureRecognizer.state == .changed)
        {
            // Add the X and Y translation to the view's original position.
            let newCenter = CGPoint(x: initialCenter.x, y: initialCenter.y + translation.y)
            //print("InitialCenter: " +  String(Int(initialCenter.y)) + ", NewCenter: " + String(Int(newCenter.y)))
            
            if (newCenter.y > initialCenter.y)
            {
                roundRectView!.center = newCenter
            }
            else
            {
                roundRectView!.center = initialCenter
            }
        }
        else if (panGestureRecognizer.state == .ended)
        {
            let newCenter = CGPoint(x: initialCenter.x, y: initialCenter.y + translation.y)

            if ((newCenter.y - initialCenter.y) < ((roundRectView?.frame.size.height)! / 2))
            {
                // Animate the roundRectView back to it's starting position
                UIView.animate(withDuration: 0.24, animations:
                                { [self] in
                                    self.roundRectView?.center = initialCenter
                                    
                                })
                { (finished) in
                    
                }
            }
            else
            {
                // Animate the roundRectView and blackBackgroundView
                UIView.animate(withDuration: 0.24, animations:
                                {
                                    self.roundRectView?.transform = CGAffineTransform(translationX: 0, y: (self.roundRectView?.frame.size.height)!)
                                    self.blackBackgroundView?.alpha = 0.0
                                })
                { (finished) in
                    
                    if (self.teamOrAthleteDeleted == true)
                    {
                        self.delegate?.closeFavoritesListViewAfterChange()
                    }
                    else
                    {
                        self.delegate?.closeFavoritesListView()
                    }
                    
                }
            }
            
 
        }
        else
        {
            // On cancellation, return the piece to its original location.
            roundRectView!.center = initialCenter
        }
    }
    
    // MARK: - Init Method
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        if let favTeams = kUserDefaults.array(forKey: kNewUserFavoriteTeamsArrayKey)
        {
            favoriteTeamsArray = favTeams
        }
        
        if let favAthletes = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
        {
            favoriteAthletesArray = favAthletes
        }
        
        self.backgroundColor = .clear
        
        blackBackgroundView = UIView(frame: frame)
        blackBackgroundView?.backgroundColor = UIColor.mpBlackColor()
        blackBackgroundView?.alpha = 0.0
        self.addSubview(blackBackgroundView!)
        
        // Add a tap gesture recognizer to the blackBackgroundView
        let topTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        blackBackgroundView?.addGestureRecognizer(topTapGesture)
        
        var bottomPad = 0
        
        if (SharedData.bottomSafeAreaHeight > 0)
        {
            bottomPad = SharedData.bottomSafeAreaHeight + 20
        }
        
        // Calculate the height of the roundRectView to match the table content if it is less than the available height
        let headerViewHeight = 68
        let maxRoundRectViewHeight = Int(kDeviceHeight) - 56 - kStatusBarHeight - SharedData.topNotchHeight
        let totalCellCount = favoriteTeamsArray.count + favoriteAthletesArray.count
        let tableHeight = (totalCellCount * kCellHeight) + 30 // Includes the footer pad
        var roundRectViewHeight = 0
        
        
        if (tableHeight + headerViewHeight + bottomPad) >= maxRoundRectViewHeight
        {
            roundRectViewHeight = maxRoundRectViewHeight
        }
        else
        {
            roundRectViewHeight = tableHeight + headerViewHeight + bottomPad
        }
        
        roundRectView = UIView(frame: CGRect(x: 0, y: Int(kDeviceHeight) - roundRectViewHeight, width: Int(kDeviceWidth), height: roundRectViewHeight))
        roundRectView?.backgroundColor = UIColor.mpWhiteColor()
        roundRectView?.layer.cornerRadius = 12
        roundRectView?.clipsToBounds = true
        
        roundRectView?.transform = CGAffineTransform(translationX: 0, y: (roundRectView?.frame.size.height)!)
        self.addSubview(roundRectView!)
        
        // Add a header container
        roundRectHeaderContainer = UIView(frame: CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: headerViewHeight))
        roundRectHeaderContainer!.backgroundColor = UIColor.mpWhiteColor()
        
        // Add a pan gesture recognizer to the two subviews
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(panGestureRecognizer:)))
        roundRectHeaderContainer!.addGestureRecognizer(panGesture)
        
        let titleLabel = UILabel(frame: CGRect(x: 20, y: 29, width: 200, height: 24))
        titleLabel.font = UIFont.mpExtraBoldFontWith(size: 24)
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.mpBlackColor()
        titleLabel.text = "Following"
        roundRectHeaderContainer!.addSubview(titleLabel)
        
        let closeButtonHorizLine = UIView(frame: CGRect(x: (kDeviceWidth - 75) / 2.0, y: 8, width: 75, height: 4))
        closeButtonHorizLine.backgroundColor = UIColor.mpGrayButtonBorderColor()
        closeButtonHorizLine.layer.cornerRadius = 2
        closeButtonHorizLine.clipsToBounds = true
        roundRectHeaderContainer!.addSubview(closeButtonHorizLine)
        
        // Add an edit button
        editButton = UIButton(frame: CGRect(x: kDeviceWidth - 96, y: 28, width: 80, height: 30))
        editButton!.backgroundColor = .clear
        editButton!.contentHorizontalAlignment = .right
        editButton!.setTitle("Manage", for: .normal)
        editButton!.setTitleColor(UIColor.mpBlackColor(), for: .normal)
        editButton!.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 16)
        editButton!.addTarget(self, action: #selector(editButtonTouched), for: .touchUpInside)
        roundRectHeaderContainer!.addSubview(editButton!)
        
        roundRectView?.addSubview(roundRectHeaderContainer!)
        
        // Add a no favorites label under the table
        let noFavoritesLabel = UILabel(frame: CGRect(x: 20, y: CGFloat(headerViewHeight + 10), width: kDeviceWidth - 32, height: 20))
        noFavoritesLabel.textColor = UIColor.mpBlueColor()
        noFavoritesLabel.font = UIFont.mpRegularFontWith(size: 17)
        noFavoritesLabel.text = "No Favorites"
        roundRectView?.addSubview(noFavoritesLabel)
        
        // Add the tableView
        favoritesTableView = UITableView(frame: CGRect(x: 0, y: CGFloat(headerViewHeight), width: kDeviceWidth, height: (roundRectView?.frame.size.height)! - CGFloat(headerViewHeight) - CGFloat(bottomPad)), style: .grouped)

        favoritesTableView?.delegate = self
        favoritesTableView?.dataSource = self
        favoritesTableView?.separatorStyle = .none
        favoritesTableView?.backgroundColor = UIColor.mpWhiteColor()
        roundRectView?.addSubview(favoritesTableView!)
        
        // Animate the roundRectView and blackBackgroundView
        UIView.animate(withDuration: 0.24, animations:
                        {
                            self.roundRectView?.transform = CGAffineTransform(translationX: 0, y: 0)
                            self.blackBackgroundView?.alpha = 0.7
                        })
        { (finished) in
            
            
        }
        
        // Hide the tableView if no favorites
        if (favoriteTeamsArray.count == 0) && (favoriteAthletesArray.count == 0)
        {
            favoritesTableView?.isHidden = true
            editButton?.isHidden = true
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

}
