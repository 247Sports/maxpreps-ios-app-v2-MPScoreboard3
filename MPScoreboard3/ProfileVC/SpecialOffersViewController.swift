//
//  SpecialOffersViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 12/2/22.
//

import UIKit

class SpecialOffersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SpecialOffersAlertViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var specialOffersTableView: UITableView!
    
    private var specialOffersArray = [] as! Array<Dictionary<String,Any>>
    private var progressOverlay: ProgressHUD!
    
    private var ncsaAthleteVC: NCSAAthleteViewController!
    private var ncsaParentVC: NCSAParentViewController!
    private var specialOffersAlertView: SpecialOffersAlertView!
    
    // MARK: - SpecialOffersAlertView
    
    private func showSpecialOffersAlertView(title: String, message: String, buttonTitle: String, buttonBackgroundColor: UIColor, buttonTextColor: UIColor)
    {
        // Show the alert view
        specialOffersAlertView = SpecialOffersAlertView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight), title: title, message: message, buttonTitle: buttonTitle, buttonBackgroundColor: buttonBackgroundColor, buttonTextColor: buttonTextColor)
        specialOffersAlertView.delegate = self
        self.view.addSubview(specialOffersAlertView)
    }
    
    func specialOffersAlertDoneButtonTouched()
    {
        specialOffersAlertView.removeFromSuperview()
        specialOffersAlertView = nil
        
        // Update the sepecial offers
        self.getUserSpecialOffers()
    }
    
    // MARK: - Update User Special Offer
    
    private func updateUserSpecialOffer(type: Int)
    {
        /*
        Unknown = 0,
        NCSAAthlete = 1,
        NCSAParent = 2,
        THSCA = 3,
        CIF = 4,
        NMAA = 5,
        AIA = 6
        */
        
        NewFeeds.updateUserSpecialOfferType(type) { error in
            
            if (error == nil)
            {
                if (type == 3)
                {
                    let buttonTextColor = UIColor.init(hexString: "F2BE2C")
                    self.showSpecialOffersAlertView(title: "Success!", message: "You have signed up to the Texas High School Coaches Association.", buttonTitle: "GOT IT", buttonBackgroundColor: UIColor.mpBlackColor(), buttonTextColor: buttonTextColor)
                }
                else if (type == 5)
                {
                    self.showSpecialOffersAlertView(title: "Success!", message: "You have signed up to the New Mexico Activities Association.", buttonTitle: "GOT IT", buttonBackgroundColor: UIColor.mpRedColor(), buttonTextColor: UIColor.mpWhiteColor())
                }
                else if (type == 6)
                {
                    let buttonBackgroundColor = UIColor.init(hexString: "036FBA")
                    self.showSpecialOffersAlertView(title: "Success!", message: "You have signed up to the Arizona Interscholastic Association.", buttonTitle: "GOT IT", buttonBackgroundColor: buttonBackgroundColor, buttonTextColor: UIColor.mpWhiteColor())
                }
            }
            else
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to sign up for this special offer.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - Get User Special Offers
    
    private func getUserSpecialOffers()
    {
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        specialOffersArray.removeAll()
        
        NewFeeds.getUserSpecialOffers { offers, error in
            
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
                print("Get User Special Offers Success")
                
                /*
                 [{"specialOfferType":1,"specialOfferName":"NCSA Athlete","hasOptedIn":false}]
                 */
                
                // Iterate through the offers and store those that are available
                for offer in offers!
                {
                    let offerType = offer["specialOfferType"] as! Int
                    let hasOptedIn = offer["hasOptedIn"] as! Bool
                    let userType = kUserDefaults.string(forKey: kUserTypeKey)
                    
                    // Always add the NCSAParent badge for a Parent
                    if (userType == "Parent")
                    {
                        if (offerType == 2)
                        {
                            self.specialOffersArray.append(offer)
                        }
                        else
                        {
                            if (hasOptedIn == false)
                            {
                                self.specialOffersArray.append(offer)
                            }
                        }
                    }
                    else
                    {
                        if (hasOptedIn == false)
                        {
                            self.specialOffersArray.append(offer)
                        }
                    }
                }
            }
            else
            {
                print("Get User Special Offers Failed")
                
            }
            
            self.specialOffersTableView.reloadData()
        }
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (specialOffersArray.count > 0)
        {
            return specialOffersArray.count
        }
        else
        {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (specialOffersArray.count > 0)
        {
            let offer = specialOffersArray[indexPath.row]
            let offerType = offer["specialOfferType"] as! Int
            
            switch offerType
            {
            case 1, 2: // NCSA
                return 357.0
            case 3: //THSCA
                return 301.0
            case 4: //CIF (not used)
                return 40.0
            case 5: //NMAA
                return 288.0
            case 6: //AIA
                return 275.0
            default: // Unknown
                return 40.0
            }
        }
        else
        {
            return 40.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 4.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 24.0 //0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 4))
        headerView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (specialOffersArray.count > 0)
        {
            let offer = specialOffersArray[indexPath.row]
            let offerType = offer["specialOfferType"] as! Int
            
            if (offerType == 1)
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "NCSATableViewCell") as? NCSATableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("NCSATableViewCell", owner: self, options: nil)
                    cell = nib![0] as? NCSATableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.badgeImageView.image = UIImage(named: "NCSAAthlete")
                
                cell?.selectButton.addTarget(self, action: #selector(ncsaAthleteTouched), for: .touchUpInside)
                
                return cell!
            }
            else if (offerType == 2)
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "NCSATableViewCell") as? NCSATableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("NCSATableViewCell", owner: self, options: nil)
                    cell = nib![0] as? NCSATableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.badgeImageView.image = UIImage(named: "NCSAParent")
                
                cell?.selectButton.addTarget(self, action: #selector(ncsaParentTouched), for: .touchUpInside)
                
                return cell!
            }
            else if (offerType == 3)
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "THSCATableViewCell") as? THSCATableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("THSCATableViewCell", owner: self, options: nil)
                    cell = nib![0] as? THSCATableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.selectButton.addTarget(self, action: #selector(thscaTouched), for: .touchUpInside)
                
                return cell!
            }
            else if (offerType == 5)
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "NMAATableViewCell") as? NMAATableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("NMAATableViewCell", owner: self, options: nil)
                    cell = nib![0] as? NMAATableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.selectButton.addTarget(self, action: #selector(nmaaTouched), for: .touchUpInside)
                
                return cell!
            }
            else if (offerType == 6)
            {
                var cell = tableView.dequeueReusableCell(withIdentifier: "AIATableViewCell") as? AIATableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("AIATableViewCell", owner: self, options: nil)
                    cell = nib![0] as? AIATableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.selectButton.addTarget(self, action: #selector(aiaTouched), for: .touchUpInside)
                
                return cell!
            }
            else
            {
                // Use a plain cell for the unknown and CIF case
                var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
                
                if (cell == nil)
                {
                    cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
                }
                
                cell?.selectionStyle = .none
                
                cell?.textLabel?.font = UIFont.mpRegularFontWith(size: 15)
                cell?.textLabel?.textColor = UIColor.mpDarkGrayColor()
                cell?.textLabel?.text = "Unknown offer."
                
                return cell!
            }
        }
        else
        {
            // Use a plain cell for the empty case
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            
            if (cell == nil)
            {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
            }
            
            cell?.selectionStyle = .none
            
            cell?.textLabel?.font = UIFont.mpRegularFontWith(size: 15)
            cell?.textLabel?.textColor = UIColor.mpDarkGrayColor()
            cell?.textLabel?.text = "No new offers available at this time."
            
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func ncsaAthleteTouched()
    {
        ncsaAthleteVC = NCSAAthleteViewController(nibName: "NCSAAthleteViewController", bundle: nil)
        self.navigationController?.pushViewController(ncsaAthleteVC, animated: true)
    }
    
    @objc private func ncsaParentTouched()
    {
        ncsaParentVC = NCSAParentViewController(nibName: "NCSAParentViewController", bundle: nil)
        self.navigationController?.pushViewController(ncsaParentVC, animated: true)
    }
    
    @objc private func aiaTouched()
    {
        self.updateUserSpecialOffer(type: 6)
    }
    
    @objc private func nmaaTouched()
    {
        self.updateUserSpecialOffer(type: 5)
    }
    
    @objc private func thscaTouched()
    {
        self.updateUserSpecialOffer(type: 3)
    }
    
    @IBAction func txAlertTouched(_ sender: UIButton)
    {
        let buttonTextColor = UIColor.init(hexString: "F2BE2C")
        self.showSpecialOffersAlertView(title: "Success!", message: "You have signed up to the Texas High School Coaches Association.", buttonTitle: "GOT IT", buttonBackgroundColor: UIColor.mpBlackColor(), buttonTextColor: buttonTextColor)
    }
    
    @IBAction func nmAlertTouched(_ sender: UIButton)
    {
        self.showSpecialOffersAlertView(title: "Success!", message: "You have signed up to the New Mexico Activities Association.", buttonTitle: "GOT IT", buttonBackgroundColor: UIColor.mpRedColor(), buttonTextColor: UIColor.mpWhiteColor())
    }
    
    @IBAction func azAlertTouched(_ sender: UIButton)
    {
        let buttonBackgroundColor = UIColor.init(hexString: "036FBA")
        self.showSpecialOffersAlertView(title: "Success!", message: "You have signed up to the Arizona Interscholastic Association.", buttonTitle: "GOT IT", buttonBackgroundColor: buttonBackgroundColor, buttonTextColor: UIColor.mpWhiteColor())
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
        specialOffersTableView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mpBlackColor(), .font: UIFont.mpSemiBoldFontWith(size: kNavBarFontSize)]
        
        self.getUserSpecialOffers()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (ncsaAthleteVC != nil)
        {
            ncsaAthleteVC = nil
        }
        
        if (ncsaParentVC != nil)
        {
            ncsaParentVC = nil
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
