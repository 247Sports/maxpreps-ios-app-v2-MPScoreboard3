//
//  EditAchievementsAwardsTopViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/23/23.
//

import UIKit

protocol EditAchievementsAwardsTopViewControllerDelegate: AnyObject
{
    func editAchievementsAwardsTopViewControllerDone()
}

class EditAchievementsAwardsTopViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var awardsTableView: UITableView!
    
    var careerId = ""
    
    weak var delegate: EditAchievementsAwardsTopViewControllerDelegate?
    
    private var achievementsAwardsArray: Array<Dictionary<String,Any>> = []
    private var addAchievementsAwardsVC: AddAchievementsAwardsViewController!
    private var editAchievementsAwardsVC: EditAchievementsAwardsViewController!
        
    // MARK: - Get Career Profile Bio Data
    
    private func getCareerProfileBioData(autoOpenEditor: Bool)
    {
        CareerFeeds.getCareerProfileBio(self.careerId) { (result, error) in
            
            if error == nil
            {
                print("Get career profile bio success.")
                
                // Build the achievementsAwards items
                self.achievementsAwardsArray = result!["achievementsAwards"] as! Array<Dictionary<String,Any>>
  
                self.awardsTableView.reloadData()
                
                // Disable scrolling if the content fits
                let contentHeight = 84 * self.achievementsAwardsArray.count
                if (contentHeight <= Int(self.awardsTableView.frame.size.height))
                {
                    self.awardsTableView.isScrollEnabled = false
                }
                else
                {
                    self.awardsTableView.isScrollEnabled = true
                }
                
                // Auto-open the addAchievementsVC if allowed
                if ((self.achievementsAwardsArray.count == 0) && (autoOpenEditor == true))
                {
                    self.addButtonTouched()
                }
            }
            else
            {
                print("Get career profile bio failed.")
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "This career profile could not be found.", lastItemCancelType: false) { (tag) in
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
        return achievementsAwardsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 84.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 20.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 20.0))
        footerView.backgroundColor = UIColor.mpWhiteColor()
        
        let label = UILabel(frame: CGRect(x: 16.0, y: 0, width: kDeviceWidth - 32.0, height: 20.0))
        label.textColor = UIColor.mpDarkGrayColor()
        label.font = UIFont.mpRegularFontWith(size: 12)
        label.textAlignment = .center
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.text = "Achievements & awards will be sorted by most recent date."
        footerView.addSubview(label)
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // Awards Edit Cell
        var cell = tableView.dequeueReusableCell(withIdentifier: "AwardsEditTableViewCell") as? AwardsEditTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("AwardsEditTableViewCell", owner: self, options: nil)
            cell = nib![0] as? AwardsEditTableViewCell
        }
        
        cell?.selectionStyle = .none
        
        let data = achievementsAwardsArray[indexPath.row]
        let title = data["title"] as? String ?? ""
        let achievedOnDate = data["achievedOn"] as? String ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.isLenient = true
        dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
        let update = dateFormatter.date(from: achievedOnDate)
        if (update != nil)
        {
            dateFormatter.dateFormat = "MMM d, yyyy"
            let dateString = dateFormatter.string(from: update!)
            cell?.subtitleLabel.text = dateString
        }
        else
        {
            cell?.subtitleLabel.text = ""
        }
        
        cell?.titleLabel.text = title
        
 
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let data = achievementsAwardsArray[indexPath.row]
        
        editAchievementsAwardsVC = EditAchievementsAwardsViewController(nibName: "EditAchievementsAwardsViewController", bundle: nil)
        editAchievementsAwardsVC.careerId = self.careerId
        editAchievementsAwardsVC.dataObj = data
        self.navigationController?.pushViewController(editAchievementsAwardsVC, animated: true)
    }
    
    // MARK: - Button Methods
    
    @IBAction func doneButtonTouched()
    {
        self.delegate?.editAchievementsAwardsTopViewControllerDone()
    }
    
    @IBAction func addButtonTouched()
    {
        addAchievementsAwardsVC = AddAchievementsAwardsViewController(nibName: "AddAchievementsAwardsViewController", bundle: nil)
        addAchievementsAwardsVC.careerId = self.careerId
        self.navigationController?.pushViewController(addAchievementsAwardsVC, animated: true)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Size the fakeStatusBar, navBar, and containerScrollView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        containerView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height)
        
        addButton.layer.cornerRadius = 8
        addButton.layer.borderWidth = 1
        addButton.layer.borderColor = UIColor.mpBlackColor().cgColor
        addButton.clipsToBounds = true
        
        self.getCareerProfileBioData(autoOpenEditor: true)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mpBlackColor(), .font: UIFont.mpSemiBoldFontWith(size: kNavBarFontSize)]
        
        if ((addAchievementsAwardsVC != nil) || (editAchievementsAwardsVC != nil))
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1)
            {
                self.getCareerProfileBioData(autoOpenEditor: false)
            }
        }

    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (addAchievementsAwardsVC != nil)
        {
            addAchievementsAwardsVC = nil
        }
        
        if (editAchievementsAwardsVC != nil)
        {
            editAchievementsAwardsVC = nil
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
