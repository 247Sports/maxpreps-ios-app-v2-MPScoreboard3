//
//  ClaimedProfilesViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 6/29/23.
//

import UIKit

class ClaimedProfilesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserTypeSelectorViewControllerDelegate, FullUserTypeSelectorViewControllerDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var emptyCareersView: UIView!
    @IBOutlet weak var academicsLabel: UILabel!
    @IBOutlet weak var measurementsLabel: UILabel!
    @IBOutlet weak var uploadVideoLabel: UILabel!
    @IBOutlet weak var claimProfileButton: UIButton!
    
    var userProfileType: String = ""
    
    private var userAdminCareers: Array<Dictionary<String,Any>> = []
    private var existingClaimedCareers: Array<String> = []
    
    private var claimedAthletesHeaderView: NewClaimedAthletesHeaderViewCell!
    private var claimedAthletesFooterView: NewClaimedAthletesFooterViewCell!
    
    private var athleteDetailVC: NewAthleteDetailViewController!
    private var webVC: WebViewController!
    private var userTypeSelectorVC: UserTypeSelectorViewController!
    private var fullUserTypeSelectorVC: FullUserTypeSelectorViewController!
    private var newAthleteSearchVC: NewAthleteSearchViewController!
    
    // MARK: - Show Web View Controller
    
    private func showWebViewController(urlString: String, title: String)
    {
        self.hidesBottomBarWhenPushed = true
        
        webVC = WebViewController(nibName: "WebViewController", bundle: nil)
        webVC.titleString = title
        webVC.urlString = urlString
        webVC.titleColor = UIColor.mpBlackColor()
        webVC.navColor = UIColor.mpWhiteColor()
        webVC.allowRotation = false
        webVC.showShareButton = false
        webVC.showScrollIndicators = false
        webVC.showLoadingOverlay = true
        webVC.showBannerAd = false
        webVC.tabBarVisible = false
        webVC.enableAdobeQueryParameter = true

        self.navigationController?.pushViewController(webVC, animated: true)
        //self.hidesBottomBarWhenPushed = false
    }
    
    // MARK: - Get User Careers
    
    private func getUserAdminCareers()
    {
        NewFeeds.getUserCareerAdminContacts { result, error in
        
            self.userAdminCareers.removeAll()
            self.existingClaimedCareers.removeAll()
            
            if (error == nil)
            {
                print("Get User Admin Careers Success")
                
                if (result!["careerAthlete"] is NSNull)
                {
                    print("Null Object")
                }
                else
                {
                    // Add the item into the array (could be nil for null API data)
                    if let careerAthlete = result!["careerAthlete"] as? Dictionary<String,Any>
                    {
                        self.userAdminCareers.append(careerAthlete)
                    }
                }
                
                // Iterate through the children to add to the array (could be nil for null API data)
                if let childrenAthletes = result!["childrenAthletes"] as? Array<Dictionary<String,Any>>
                {
                    for childAthlete in childrenAthletes
                    {
                        self.userAdminCareers.append(childAthlete)
                    }
                }
                
                // Fill the existingClaimeCareers array
                // This is used in the search to prevent a duplicate claim
                for career in self.userAdminCareers
                {
                    let careerId = career["careerId"] as! String
                    self.existingClaimedCareers.append(careerId)
                }
                
                if (self.userAdminCareers.count > 0)
                {
                    self.profileTableView.isHidden = false
                    self.emptyCareersView.isHidden = true
                }
                else
                {
                    self.profileTableView.isHidden = true
                    self.emptyCareersView.isHidden = false
                }
            }
            else
            {
                print("Get User Admin Careers Failed")
                
                self.profileTableView.isHidden = true
                self.emptyCareersView.isHidden = true
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "A server error has occurred.", lastItemCancelType: false) { tag in
                    
                }
            }
            
            self.profileTableView.reloadData()
        }
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return userAdminCareers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 72.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 60.0 + 60 // Pad to avoid a conflict with the device gestures
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let view = UIView()
        view.addSubview(claimedAthletesHeaderView!)
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let view = UIView()
        view.addSubview(claimedAthletesFooterView!)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "NewClaimedAthletesTableViewCell") as? NewClaimedAthletesTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("NewClaimedAthletesTableViewCell", owner: self, options: nil)
            cell = nib![0] as? NewClaimedAthletesTableViewCell
        }
        
        cell?.selectionStyle = .none

        let item = userAdminCareers[indexPath.row]
        let firstName = item["athleteFirstName"] as! String
        let lastName = item["athleteLastName"] as! String
        let gradeClass = item["athleteGradeClass"] as! String
        
        cell?.nameLabel.text = String(format: "%@ %@", firstName, lastName)
        cell?.classYearLabel.text = gradeClass
        
        // Load the photo
        let photoUrlString = item["athletePhotoUrl"] as! String
        
        if (photoUrlString.count > 0)
        {
            let url = URL(string: photoUrlString)
            
            // Get the data and make an image
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        cell?.athleteImageView.image = image
                    }
                    else
                    {
                        cell?.athleteImageView.image = UIImage(named: "Avatar")
                    }
                }
            }
        }
        else
        {
            cell?.athleteImageView.image = UIImage(named: "Avatar")
        }

        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = userAdminCareers[indexPath.row]
        
        let schoolId = item["athleteSchoolId"] as? String ?? kEmptyGuid
        let schoolName = item["athleteSchoolName"] as? String ?? "Unknown School"
        let schoolState = item["athleteSchoolState"] as? String ?? ""
        let schoolCity = item["athleteSchoolCity"] as? String ?? ""
        let schoolColor = item["athleteSchoolColor1"] as? String ?? "808080"
        
        let firstName = item["athleteFirstName"] as? String ?? ""
        let lastName = item["athleteLastName"] as? String ?? ""
        let careerId = item["careerId"] as? String ?? ""
        
        let selectedAthlete = Athlete(firstName: firstName, lastName: lastName, schoolName: schoolName, schoolState: schoolState, schoolCity: schoolCity, schoolId: schoolId, schoolColor: schoolColor, schoolMascotUrl: "", careerId: careerId, photoUrl: "")
        
        // Check to see if the athlete is already a favorite
        let isFavorite = MiscHelper.isAthleteMyFavoriteAthlete(careerId: careerId)
        
        var showSaveFavoriteButton = false
        var showRemoveFavoriteButton = false
        
        if (isFavorite == true)
        {
            showSaveFavoriteButton = false
            showRemoveFavoriteButton = true
        }
        else
        {
            showSaveFavoriteButton = true
            showRemoveFavoriteButton = false
        }
        
        self.tabBarController?.tabBar.isHidden = false
        
        // This is added to disable tha tabbar buttons
        let tabBarControllerItems = self.tabBarController?.tabBar.items

        if let tabArray = tabBarControllerItems
        {
            let tabBarItem1 = tabArray[0]
            let tabBarItem2 = tabArray[1]
            let tabBarItem3 = tabArray[2]

            tabBarItem1.isEnabled = false
            tabBarItem2.isEnabled = false
            tabBarItem3.isEnabled = false
        }
        
        if (athleteDetailVC != nil)
        {
            athleteDetailVC = nil
        }
        
        athleteDetailVC = NewAthleteDetailViewController(nibName: "NewAthleteDetailViewController", bundle: nil)
        athleteDetailVC.selectedAthlete = selectedAthlete
        athleteDetailVC.showSaveFavoriteButton = showSaveFavoriteButton
        athleteDetailVC.showRemoveFavoriteButton = showRemoveFavoriteButton
        self.navigationController?.pushViewController(athleteDetailVC, animated: true)
    }
    
    // MARK: - UserTypeSelectorViewController Delegate
    
    func userTypeSelectorViewControllerDidSave()
    {
        self.dismiss(animated: true) {
            
            self.userTypeSelectorVC = nil
            
            // Show the new SearchVC
            self.hidesBottomBarWhenPushed = true
            
            self.newAthleteSearchVC = NewAthleteSearchViewController(nibName: "NewAthleteSearchViewController", bundle: nil)
            self.newAthleteSearchVC.existingClaimedCareers = self.existingClaimedCareers
            self.newAthleteSearchVC.userProfileType = self.userProfileType
            self.navigationController?.pushViewController(self.newAthleteSearchVC, animated: true)
            
        }
    }
    
    func userTypeSelectorViewControllerDidCancel()
    {
        self.dismiss(animated: true) {
            
            self.userTypeSelectorVC = nil
        }
    }
    
    // MARK: - FullUserTypeSelectorViewController Delegate
    
    func fullUserTypeSelectorViewControllerDidSave()
    {
        self.dismiss(animated: true) {
            
            self.fullUserTypeSelectorVC = nil
            
            // Show the new SearchVC
            self.hidesBottomBarWhenPushed = true
            
            self.newAthleteSearchVC = NewAthleteSearchViewController(nibName: "NewAthleteSearchViewController", bundle: nil)
            self.newAthleteSearchVC.existingClaimedCareers = self.existingClaimedCareers
            self.newAthleteSearchVC.userProfileType = self.userProfileType
            self.navigationController?.pushViewController(self.newAthleteSearchVC, animated: true)
            
        }
    }
    
    func fullUserTypeSelectorViewControllerDidCancel()
    {
        self.dismiss(animated: true) {
            
            self.fullUserTypeSelectorVC = nil
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addButtonTouched(_ sender: UIButton)
    {
        // Show the FullUserTypeSelector for fan or coach user profiles
        if ((self.userProfileType == "Fan") || (self.userProfileType == "Coach"))
        {
            fullUserTypeSelectorVC = FullUserTypeSelectorViewController(nibName: "FullUserTypeSelectorViewController", bundle: nil)
            fullUserTypeSelectorVC.delegate = self
            fullUserTypeSelectorVC.modalPresentationStyle = .overCurrentContext
            self.present(fullUserTypeSelectorVC, animated: true)
        }
        else
        {
            userTypeSelectorVC = UserTypeSelectorViewController(nibName: "UserTypeSelectorViewController", bundle: nil)
            userTypeSelectorVC.delegate = self
            userTypeSelectorVC.modalPresentationStyle = .overCurrentContext
            self.present(userTypeSelectorVC, animated: true)
            
            /*
            let userType = kUserDefaults.string(forKey: kUserTypeKey)
            
            if (userType == "Athlete")
            {
                userTypeSelectorVC = UserTypeSelectorViewController(nibName: "UserTypeSelectorViewController", bundle: nil)
                userTypeSelectorVC.delegate = self
                userTypeSelectorVC.modalPresentationStyle = .overCurrentContext
                self.present(userTypeSelectorVC, animated: true)
            }
            else
            {
                // Show the new SearchVC directly
                self.hidesBottomBarWhenPushed = true
                
                self.newAthleteSearchVC = NewAthleteSearchViewController(nibName: "NewAthleteSearchViewController", bundle: nil)
                self.newAthleteSearchVC.existingClaimedCareers = self.existingClaimedCareers
                self.newAthleteSearchVC.userProfileType = self.userProfileType
                self.navigationController?.pushViewController(self.newAthleteSearchVC, animated: true)
            }
            */
        }
    }
    
    @objc func supportButtonTouched()
    {
        self.showWebViewController(urlString: kTechSupportUrl, title: "Support")
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
                
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                
        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        containerView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height)
        
        //profileTableView.contentInsetAdjustmentBehavior = .never
        //profileTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -20.0, right: 0)
        
        let claimedAthletesHeaderNib = Bundle.main.loadNibNamed("NewClaimedAthletesHeaderViewCell", owner: self, options: nil)
        claimedAthletesHeaderView = claimedAthletesHeaderNib![0] as? NewClaimedAthletesHeaderViewCell
        claimedAthletesHeaderView?.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 60)
        
        let claimedAthletesFooterNib = Bundle.main.loadNibNamed("NewClaimedAthletesFooterViewCell", owner: self, options: nil)
        claimedAthletesFooterView = claimedAthletesFooterNib![0] as? NewClaimedAthletesFooterViewCell
        claimedAthletesFooterView?.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 120)
        claimedAthletesFooterView.supportButton.addTarget(self, action: #selector(supportButtonTouched), for: .touchUpInside)
        
        claimProfileButton.layer.cornerRadius = 8.0
        claimProfileButton.clipsToBounds = true
        
        academicsLabel.layer.cornerRadius = 12.0
        academicsLabel.clipsToBounds = true
        measurementsLabel.layer.cornerRadius = 12.0
        measurementsLabel.clipsToBounds = true
        uploadVideoLabel.layer.cornerRadius = 12.0
        uploadVideoLabel.clipsToBounds = true
        
        // Center the academicsLabel and measurementsLabel into the view
        let overallWidth = academicsLabel.frame.size.width + 4.0 + measurementsLabel.frame.size.width
        let leftPad = (kDeviceWidth - overallWidth) / 2.0
        academicsLabel.frame.origin = CGPoint(x: leftPad, y: academicsLabel.frame.origin.y)
        measurementsLabel.frame.origin = CGPoint(x: leftPad + academicsLabel.frame.size.width + 4.0, y: measurementsLabel.frame.origin.y)
        
        profileTableView.isHidden = true
        emptyCareersView.isHidden = true

    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        
        // This is added to enable the tabbar buttons when returning from the VCs
        let tabBarControllerItems = self.tabBarController?.tabBar.items
        
        if let tabArray = tabBarControllerItems
        {
            let tabBarItem1 = tabArray[0]
            let tabBarItem2 = tabArray[1]
            let tabBarItem3 = tabArray[2]
            
            tabBarItem1.isEnabled = true
            tabBarItem2.isEnabled = true
            tabBarItem3.isEnabled = true
        }
        
        // This is added to reset the background when returning from the VCs
        kAppKeyWindow.rootViewController!.view.backgroundColor = UIColor.mpWhiteColor()
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.getUserAdminCareers()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
 
        if (athleteDetailVC != nil)
        {
            athleteDetailVC = nil
        }
        
        if (newAthleteSearchVC != nil)
        {
            if (newAthleteSearchVC.athleteClaimed == true)
            {
                    newAthleteSearchVC = nil
                    
                    // Get the user's info
                    let tabBarController = self.tabBarController as! TabBarController
                    tabBarController.getUserInfo()
                    
                if ((self.userProfileType == "Athlete") || (self.userProfileType == "Fan"))
                {
                    // Close everything if the user profile was for an athlete or a fan
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.default
    }

    override open var shouldAutorotate: Bool
    {
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation
    {
        return UIInterfaceOrientation.portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        return .portrait
    }

    
}
