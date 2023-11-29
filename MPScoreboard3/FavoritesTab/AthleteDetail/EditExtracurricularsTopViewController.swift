//
//  EditExtracurricularsTopViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 9/6/23.
//

import UIKit

protocol EditExtracurricularsTopViewControllerDelegate: AnyObject
{
    func editExtracurricularsTopViewControllerDone()
}

class EditExtracurricularsTopViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var extracurricularsTableView: UITableView!
    
    var careerId = ""
    
    weak var delegate: EditExtracurricularsTopViewControllerDelegate?
    
    private var extracurricularsArray: Array<Dictionary<String,Any>> = []
    private var addExtracurricularsVC: AddExtracurricularsViewController!
    private var editExtracurricularsVC: EditExtracurricularsViewController!
        
    // MARK: - Get Career Profile Bio Data
    
    private func getCareerProfileBioData(autoOpenEditor: Bool)
    {
        CareerFeeds.getCareerProfileBio(self.careerId) { (result, error) in
            
            if error == nil
            {
                print("Get career profile bio success.")
                
                // Build the extracurriculars items
                self.extracurricularsArray = result!["extracurriculars"] as! Array<Dictionary<String,Any>>
  
                self.extracurricularsTableView.reloadData()
                
                // Disable scrolling if the content fits
                let contentHeight = 84 * self.extracurricularsArray.count
                if (contentHeight <= Int(self.extracurricularsTableView.frame.size.height))
                {
                    self.extracurricularsTableView.isScrollEnabled = false
                }
                else
                {
                    self.extracurricularsTableView.isScrollEnabled = true
                }
                
                // Auto-open the addExtraCurricularsVC if allowed
                if ((self.extracurricularsArray.count == 0) && (autoOpenEditor == true))
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
        return extracurricularsArray.count
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
        label.text = "Extracurriculars will be sorted alphabetically."
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
        
        let data = extracurricularsArray[indexPath.row]
        let title = data["activity"] as? String ?? ""
        let role = data["role"] as? String ?? ""
        
        cell?.titleLabel.text = title
        cell?.subtitleLabel.text = role
 
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let data = extracurricularsArray[indexPath.row]
        
        editExtracurricularsVC = EditExtracurricularsViewController(nibName: "EditExtracurricularsViewController", bundle: nil)
        editExtracurricularsVC.careerId = self.careerId
        editExtracurricularsVC.dataObj = data
        self.navigationController?.pushViewController(editExtracurricularsVC, animated: true)
    }
    
    // MARK: - Button Methods
    
    @IBAction func doneButtonTouched()
    {
        self.delegate?.editExtracurricularsTopViewControllerDone()
    }
    
    @IBAction func addButtonTouched()
    {
        addExtracurricularsVC = AddExtracurricularsViewController(nibName: "AddExtracurricularsViewController", bundle: nil)
        addExtracurricularsVC.careerId = self.careerId
        self.navigationController?.pushViewController(addExtracurricularsVC, animated: true)
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
        
        if ((addExtracurricularsVC != nil) || (editExtracurricularsVC != nil))
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
        
        if (addExtracurricularsVC != nil)
        {
            addExtracurricularsVC = nil
        }
        
        if (editExtracurricularsVC != nil)
        {
            editExtracurricularsVC = nil
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
