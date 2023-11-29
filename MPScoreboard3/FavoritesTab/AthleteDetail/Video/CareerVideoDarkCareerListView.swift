//
//  CareerVideoDarkCareerListView.swift
//  MPScoreboard3
//
//  Created by David Smith on 9/28/22.
//

import UIKit

protocol CareerVideoDarkCareerListViewDelegate: AnyObject
{
    func closeCareerVideoDarkCareerListView()
    func careerVideoDarkCareerListViewAthleteSelected(taggedAthlete: AthleteWithProfile)
    func careerVideoDarkCareerListViewAthleteUntagged()
}

class CareerVideoDarkCareerListView: UIView, UITableViewDelegate, UITableViewDataSource
{
    weak var delegate: CareerVideoDarkCareerListViewDelegate?
    
    private var taggedAthletesTableView: UITableView?
    private var blackBackgroundView : UIView?
    private var roundRectView : UIView?
    private var titleContainer : UIView?
    private var titleLabel : UILabel?
    private var bottomPad = 0
    
    private var headerView: TeamVideoDarkCareerHeaderViewCell!
    private var progressOverlay: ProgressHUD!
    private var taggedAthletesArray = [] as Array
    private var isUserUploadedVideo = false
    private var videoIdCopy = ""
    private var videoUserId = ""
    
    private var initialCenter = CGPoint()  // The initial center point of the roundRectView for the pan geture.
    
    // MARK: - Get Tagged Athletes
    
    private func getTaggedAthletes()
    {
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.getVideoTaggedCareers(videoId: videoIdCopy) { items, error in
            
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                //MBProgressHUD.hide(for: self.view, animated: true)
                if (self.progressOverlay != nil)
                {
                    self.progressOverlay.hide(animated: false)
                    self.progressOverlay = nil
                }
            }
            
            self.taggedAthletesTableView?.isHidden = false

            if (error == nil)
            {
                
                self.taggedAthletesArray = items!["careers"] as! Array<Dictionary<String,Any>>
                print("Get Tagged Athletes Success")
                
                if (self.taggedAthletesArray.count == 0)
                {
                    // Disable scrolling and hide the tagged label
                    self.taggedAthletesTableView?.isScrollEnabled = false
                    self.headerView.taggedLabel.isHidden = true
                }
            }
            
            self.taggedAthletesTableView?.reloadData()
        }
    }
    
    // MARK: - Untag Athlete
    
    private func untagAthlete(careerId: String)
    {
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
            
        NewFeeds.untagAthleteFomVideo(videoId: videoIdCopy, careerId: careerId) { error in
            
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                //MBProgressHUD.hide(for: self.view, animated: true)
                if (self.progressOverlay != nil)
                {
                    self.progressOverlay.hide(animated: false)
                    self.progressOverlay = nil
                }
            }
            
            if (error == nil)
            {
                // Animate the roundRectView and blackBackgroundView
                UIView.animate(withDuration: 0.24, animations:
                                {
                    self.roundRectView?.transform = CGAffineTransform(translationX: 0, y: (self.roundRectView?.frame.size.height)!)
                    self.blackBackgroundView?.alpha = 0.0
                })
                { (finished) in
            
                    self.delegate?.careerVideoDarkCareerListViewAthleteUntagged()
                }
            }
            else
            {
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "An error occured while trying to untag this athlete.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return taggedAthletesArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return headerView.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 16.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerContainerView = UIView()
        headerContainerView.addSubview(headerView)
        
        return headerContainerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "TeamVideoDarkCareerTableViewCell") as? TeamVideoDarkCareerTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("TeamVideoDarkCareerTableViewCell", owner: self, options: nil)
            cell = nib![0] as? TeamVideoDarkCareerTableViewCell
        }
        
        cell?.selectionStyle = .none
        
        let taggedAthlete = taggedAthletesArray[indexPath.row] as! Dictionary<String, Any>
        
        let firstName = taggedAthlete["firstName"] as! String
        let lastName = taggedAthlete["lastName"] as! String
        let athletePhotoUrlString = taggedAthlete["photoUrl"] as! String
        let schoolName = taggedAthlete["schoolName"] as! String
        let schoolCity = taggedAthlete["schoolCity"] as! String
        let schoolState = taggedAthlete["schoolState"] as! String
        
        cell?.titleLabel.text = firstName + " " + lastName
        
        if (schoolName == schoolCity)
        {
            cell?.subtitleLabel.text = String(format: "%@ (%@)", schoolName, schoolState)
        }
        else
        {
            cell?.subtitleLabel.text = String(format: "%@ (%@, %@)", schoolName, schoolCity, schoolState)
        }
        
        cell?.athletePhotoImageView.image = UIImage(named: "Avatar")
        
        if (athletePhotoUrlString.count > 0)
        {
            let url = URL(string: athletePhotoUrlString)
            
            SDWebImageManager.shared().downloadImage(with: url!, progress: { receivedSize, expectedSize in
                
            }, completed: { image, error, cacheType, finished, imageUrl in
                
                if (image != nil)
                {
                    cell?.athletePhotoImageView.image = image
                }
            })
        }
        
        cell?.deleteButton.isHidden = true
        cell?.deleteButton.tag = 100 + indexPath.row
        cell?.deleteButton.addTarget(self, action: #selector(deleteButtonTouched(_:)), for: .touchUpInside)
        
        // Show the delete button if the user is the athlete or the parent and the video is a user uploaded type OR show the button if the userId of the video matches the logged in user.
        let careerId = taggedAthlete["careerId"] as! String
        let userCanEdit = MiscHelper.userCanEditSpecificCareer(careerId: careerId).canEdit
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        
        if (isUserUploadedVideo == true)
        {
            if ((userCanEdit == true) || (videoUserId == userId))
            {
                cell?.deleteButton.isHidden = false
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedAthlete = taggedAthletesArray[indexPath.row] as! Dictionary<String, Any>
        let careerId = selectedAthlete["careerId"] as! String
        let firstName = selectedAthlete["firstName"] as! String
        let lastName = selectedAthlete["lastName"] as! String
        let schoolId = selectedAthlete["schoolId"] as! String
        let schoolName = selectedAthlete["schoolName"] as! String
        let schoolCity = selectedAthlete["schoolCity"] as! String
        let schoolState = selectedAthlete["schoolState"] as! String
        let schoolColor = selectedAthlete["schoolColor"] as! String
        let schoolMascotUrlString = selectedAthlete["schoolMascotUrl"] as! String
        let athletePhotoUrlString = selectedAthlete["photoUrl"] as! String
        let sportsPlayedString = selectedAthlete["sportsPlayedString"] as! String
        let gradeClass = selectedAthlete["gradeClass"] as! String
        let bio = selectedAthlete["bio"] as! String
        let twitterUrl = selectedAthlete["twitterFullUrl"] as? String ?? ""
        let instagramUrl = selectedAthlete["instagramFullUrl"] as? String ?? ""
        let snapchatUrl = selectedAthlete["snapchatFullUrl"] as? String ?? ""
        let tikTokUrl = selectedAthlete["tikTokFullUrl"] as? String ?? ""
        let facebookUrl = selectedAthlete["facebookFullUrl"] as? String ?? ""
        let gameChangerUrl = selectedAthlete["gameChangerFullUrl"] as? String ?? ""
        let hudlUrl = selectedAthlete["hudlFullUrl"] as? String ?? ""
        
        let taggedAthlete = AthleteWithProfile(firstName: firstName, lastName: lastName, schoolName: schoolName, schoolState: schoolState, schoolCity: schoolCity, schoolId: schoolId, schoolColor: schoolColor, schoolMascotUrl: schoolMascotUrlString, careerId: careerId, photoUrl: athletePhotoUrlString, sportsPlayedString: sportsPlayedString, gradeClass: gradeClass, bio: bio, twitterUrl: twitterUrl, instagramUrl: instagramUrl, snapchatUrl: snapchatUrl, tikTokUrl: tikTokUrl, facebookUrl: facebookUrl, gameChangerUrl: gameChangerUrl, hudlUrl: hudlUrl)
        
        self.delegate?.careerVideoDarkCareerListViewAthleteSelected(taggedAthlete: taggedAthlete)
    }
    
    // MARK: - Button Method
    
    @objc private func closeButtonTouched()
    {
        // Animate the roundRectView and blackBackgroundView
        UIView.animate(withDuration: 0.24, animations:
                        {
            self.roundRectView?.transform = CGAffineTransform(translationX: 0, y: (self.roundRectView?.frame.size.height)!)
            self.blackBackgroundView?.alpha = 0.0
        })
        { (finished) in
    
            self.delegate?.closeCareerVideoDarkCareerListView()
        }
    }
    
    @objc private func deleteButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["Cancel", "Untag"], title: "Untag Athlete?", message: "Do you want to untag this athlete from the video?", lastItemCancelType: true) { tag in
            
            if (tag == 1)
            {
                let taggedAthlete = self.taggedAthletesArray[index] as! Dictionary<String, Any>
                let careerId = taggedAthlete["careerId"] as! String
                
                self.untagAthlete(careerId: careerId)
            }
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
            
            self.delegate?.closeCareerVideoDarkCareerListView()
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
                    
                    self.delegate?.closeCareerVideoDarkCareerListView()
                }
            }  
        }
        else
        {
            // On cancellation, return the piece to its original location.
            roundRectView!.center = initialCenter
        }
    }
    
    // MARK: - Load Data Method
    
    func loadData(videoObj: Dictionary<String,Any>)
    {
        isUserUploadedVideo = videoObj["isUserUploaded"] as? Bool ?? false
        videoIdCopy = videoObj["videoId"] as! String
        videoUserId = videoObj["userId"] as? String ?? "" // HUDL videos can be null
        
        let title = videoObj["title"] as! String
        titleLabel!.text = title
        
        let publishDate = videoObj["formattedPublishedOn"] as? String ?? ""
        headerView.dateLabel!.text = publishDate
        
        let viewCount = videoObj["viewCount"] as? Int ?? 0
        
        if (viewCount >= 1000000)
        {
            let viewCountFloat = Float(viewCount) / 1000000.0
            headerView.frequencyLabel!.text = String(format: "%1.1fm", viewCountFloat)
        }
        else
        {
            if (viewCount >= 1000)
            {
                let viewCountFloat = Float(viewCount) / 1000.0
                headerView.frequencyLabel!.text = String(format: "%1.1fk", viewCountFloat)
            }
            else
            {
                headerView.frequencyLabel!.text = String(format: "%d", viewCount)
            }
        }
        
        let description = videoObj["description"] as! String
        //print("Description: " + description)
        
        // Calculate the descriptionTextHeight
        let descriptionTextHeight = description.height(withConstrainedWidth: kDeviceWidth - 32, font: UIFont.mpRegularFontWith(size: 13))
        headerView.frame = CGRect(x: 0, y: 0, width: kDeviceWidth, height: descriptionTextHeight + 64 + 32 + 24)
        
        headerView.descriptionLabel.text = description
        
        taggedAthletesTableView!.frame = CGRect(x: 0, y: titleContainer!.frame.size.height, width: kDeviceWidth, height: roundRectView!.frame.size.height - titleContainer!.frame.size.height - CGFloat(bottomPad))
        
        // Get the tagged athletes
        self.getTaggedAthletes()
    }
    
    // MARK: - Init Method
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    
        self.backgroundColor = .clear
        
        blackBackgroundView = UIView(frame: frame)
        blackBackgroundView?.backgroundColor = UIColor.mpBlackColor()
        blackBackgroundView?.alpha = 0.0
        self.addSubview(blackBackgroundView!)
        
        // Add a tap gesture recognizer to the blackBackgroundView
        let topTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        blackBackgroundView?.addGestureRecognizer(topTapGesture)
        
        if (SharedData.bottomSafeAreaHeight > 0)
        {
            bottomPad = SharedData.bottomSafeAreaHeight + 20
        }
        
        // Calculate the height of the roundRectView to match the video player's height
        let videoHeight = ((kDeviceWidth * 9) / 16)
        let roundRectViewHeight = Int(kDeviceHeight) - Int(videoHeight) - kNavBarHeight - kStatusBarHeight - SharedData.topNotchHeight

        roundRectView = UIView(frame: CGRect(x: 0, y: Int(kDeviceHeight) - roundRectViewHeight, width: Int(kDeviceWidth), height: roundRectViewHeight))
        roundRectView?.backgroundColor = UIColor.mpBlackColor()
        roundRectView?.layer.cornerRadius = 12
        roundRectView?.clipsToBounds = true
        
        // Move the roundRectView down so it is initially hidden
        roundRectView?.transform = CGAffineTransform(translationX: 0, y: (roundRectView?.frame.size.height)!)
        self.addSubview(roundRectView!)
        
        // Add a titleContainer
        titleContainer = UIView(frame: CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 80))
        titleContainer!.backgroundColor = UIColor.mpBlackColor()
        roundRectView?.addSubview(titleContainer!)
        
        // Add a pan gesture recognizer to the titleContainer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(panGestureRecognizer:)))
        titleContainer!.addGestureRecognizer(panGesture)
        
        // Add a thick horizontal line near the top of the titleContainer
        let closeButtonHorizLine = UIView(frame: CGRect(x: (kDeviceWidth - 48) / 2.0, y: 8, width: 48, height: 4))
        closeButtonHorizLine.backgroundColor = UIColor.mpGrayColor()
        closeButtonHorizLine.layer.cornerRadius = 2
        closeButtonHorizLine.clipsToBounds = true
        titleContainer!.addSubview(closeButtonHorizLine)
        
        // Add the title label to the titleContainer
        titleLabel = UILabel(frame: CGRect(x: 16, y: 28, width: kDeviceWidth - 74, height: 40))
        titleLabel!.font = UIFont.mpBoldFontWith(size: 15)
        titleLabel!.backgroundColor = .clear
        titleLabel!.textColor = UIColor.mpWhiteColor()
        titleLabel!.numberOfLines = 2
        titleLabel!.adjustsFontSizeToFitWidth = true
        titleLabel!.minimumScaleFactor = 0.7
        titleContainer!.addSubview(titleLabel!)
        
        // Add a close button to the titleContainer
        let closeButton = UIButton(type: .custom)
        closeButton.frame = CGRect(x: kDeviceWidth - 50, y: 20, width: 40, height: 40)
        closeButton.setImage(UIImage(named: "LargeDropDownArrowLightGray"), for: .normal)
        closeButton.transform = CGAffineTransform(rotationAngle: .pi * 0.999)
        closeButton.addTarget(self, action: #selector(closeButtonTouched), for: .touchUpInside)
        titleContainer!.addSubview(closeButton)
        
        // Add a horiz line to the titleContainer
        let horizLine = UIView(frame: CGRect(x: 16, y: Int(titleContainer!.frame.size.height) - 1, width: Int(kDeviceWidth) - 32, height: 1))
        horizLine.backgroundColor = UIColor.mpDarkGrayColor()
        titleContainer!.addSubview(horizLine)
        
        // Instantiate the header view
        // The height will be changed once the data is loaded
        // 64 + 12 + 68 + 12 + 32 = 188 (starting size)
        let headerNib = Bundle.main.loadNibNamed("TeamVideoDarkCareerHeaderViewCell", owner: self, options: nil)
        headerView = headerNib![0] as? TeamVideoDarkCareerHeaderViewCell
        headerView.frame = CGRect(x: 0, y: 0, width: kDeviceWidth, height: 188.0)
        
        // Add the tableView
        taggedAthletesTableView = UITableView(frame: CGRect(x: 0, y: titleContainer!.frame.size.height, width: kDeviceWidth, height: roundRectView!.frame.size.height - titleContainer!.frame.size.height - CGFloat(bottomPad)), style: .grouped)
        
        taggedAthletesTableView?.delegate = self
        taggedAthletesTableView?.dataSource = self
        taggedAthletesTableView?.separatorStyle = .none
        taggedAthletesTableView?.insetsContentViewsToSafeArea = false
        taggedAthletesTableView?.backgroundColor = UIColor.mpBlackColor()
        roundRectView?.addSubview(taggedAthletesTableView!)
        
        taggedAthletesTableView?.isHidden = true
        
        // Animate the roundRectView and blackBackgroundView
        UIView.animate(withDuration: 0.24, animations:
                        {
            self.roundRectView?.transform = CGAffineTransform(translationX: 0, y: 0)
            self.blackBackgroundView?.alpha = 0.4
        })
        { (finished) in
            
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
