//
//  EditAcademicsTopViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/9/23.
//

import UIKit

protocol EditAcademicsTopViewControllerDelegate: AnyObject
{
    func editAcademicsTopViewControllerDone()
}

class EditAcademicsTopViewController: UIViewController
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var gpaContainerView: UIView!
    @IBOutlet weak var apContainerView: UIView!
    @IBOutlet weak var honorsContainerView: UIView!
    @IBOutlet weak var gpaLabel: UILabel!
    @IBOutlet weak var apLabel: UILabel!
    @IBOutlet weak var honorsLabel: UILabel!
    
    var allAcademics: Array<String> = []
    var careerId = ""
    
    weak var delegate: EditAcademicsTopViewControllerDelegate?
    
    private var editAcademicsVC: NewEditAcademicsViewController!
    private var editAPClassesVC: EditAPClassesViewController!
    private var editHonorsClassesVC: EditHonorsClassesViewController!
    private var gpa = -1.0
    private var satScore = -1
    private var actScore = -1
    private var apArray: Array<String> = []
    private var honorsArray: Array<String> = []
        
    // MARK: - Get Career Profile Bio Data
    
    private func getCareerProfileBioData()
    {
        CareerFeeds.getCareerProfileBio(self.careerId) { (result, error) in
            
            if error == nil
            {
                print("Get career profile bio success.")
                
                // Build the academics items
                let academics = result!["academics"] as! Dictionary<String,Any>
  
                var gpaArray: Array<String> = []
                
                self.apArray.removeAll()
                self.honorsArray.removeAll()
                self.gpa = -1.0
                self.satScore = -1
                self.actScore = -1
                
                // Nested for loops to build the arrays in a particular order
                for title in self.allAcademics
                {
                    for item in academics
                    {
                        let key = item.key
                        
                        if ((key == "highSchoolGpa") && (title == "GPA"))
                        {
                            let value = academics[key] as? Double ?? -1.0
                            if (value != -1.0)
                            {
                                let valueString = String(format: "%1.2f", value)
                                gpaArray.append(valueString)
                                self.gpa = value
                            }
                        }
                        
                        if ((key == "satScore") && (title == "SAT"))
                        {
                            let value = academics[key] as? Int ?? -1
                            if (value != -1)
                            {
                                let valueString = String(format: "%d", value)
                                gpaArray.append(valueString)
                                self.satScore = value
                            }
                        }
                        
                        if ((key == "actScore") && (title == "ACT"))
                        {
                            let value = academics[key] as? Int ?? -1
                            if (value != -1)
                            {
                                let valueString = String(format: "%d", value)
                                gpaArray.append(valueString)
                                self.actScore = value
                            }
                        }
                        
                        if ((key == "apClasses") && (title == "AP Classes"))
                        {
                            let objectArray = academics[key] as? Array<Dictionary<String,Any>> ?? []
                            
                            for apItem in objectArray
                            {
                                let className = apItem["className"] as! String
                                self.apArray.append(className)
                            }
                        }
                        
                        if ((key == "honorClasses") && (title == "Honors Classes"))
                        {
                            let objectArray = academics[key] as? Array<Dictionary<String,Any>> ?? []
                            
                            for apItem in objectArray
                            {
                                let className = apItem["className"] as! String
                                self.honorsArray.append(className)
                            }
                        }
                    }
                }
                
                // Update the labels
                if (gpaArray.count > 0)
                {
                    self.gpaLabel.text = String(format: "%d Entered", gpaArray.count)
                }
                else
                {
                    self.gpaLabel.text = ""
                }
                
                if (self.apArray.count > 0)
                {
                    self.apLabel.text = String(format: "%d Entered", self.apArray.count)
                }
                else
                {
                    self.apLabel.text = ""
                }
                
                if (self.honorsArray.count > 0)
                {
                    self.honorsLabel.text = String(format: "%d Entered", self.honorsArray.count)
                }
                else
                {
                    self.honorsLabel.text = ""
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
    
    // MARK: - Button Methods
    
    @IBAction func doneButtonTouched()
    {
        self.delegate?.editAcademicsTopViewControllerDone()
    }
    
    @IBAction func gpaButtonTouched()
    {
        editAcademicsVC = NewEditAcademicsViewController(nibName: "NewEditAcademicsViewController", bundle: nil)
        editAcademicsVC.gpa = self.gpa
        editAcademicsVC.satScore = self.satScore
        editAcademicsVC.actScore = self.actScore
        editAcademicsVC.careerId = self.careerId
        self.navigationController?.pushViewController(editAcademicsVC, animated: true)
    }
    
    @IBAction func apButtonTouched()
    {
        editAPClassesVC = EditAPClassesViewController(nibName: "EditAPClassesViewController", bundle: nil)
        editAPClassesVC.dataArray = apArray
        editAPClassesVC.careerId = self.careerId
        self.navigationController?.pushViewController(editAPClassesVC, animated: true)
    }
    
    @IBAction func honorsButtonTouched()
    {
        editHonorsClassesVC = EditHonorsClassesViewController(nibName: "EditHonorsClassesViewController", bundle: nil)
        editHonorsClassesVC.dataArray = honorsArray
        editHonorsClassesVC.careerId = self.careerId
        self.navigationController?.pushViewController(editHonorsClassesVC, animated: true)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Size the fakeStatusBar, navBar, and containerScrollView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        containerView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height)
        
        gpaContainerView.layer.cornerRadius = 8
        gpaContainerView.clipsToBounds = true
        apContainerView.layer.cornerRadius = 8
        apContainerView.clipsToBounds = true
        honorsContainerView.layer.cornerRadius = 8
        honorsContainerView.clipsToBounds = true
        
        self.gpaLabel.text = ""
        self.apLabel.text = ""
        self.honorsLabel.text = ""
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mpBlackColor(), .font: UIFont.mpSemiBoldFontWith(size: kNavBarFontSize)]
        
        self.getCareerProfileBioData()

    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (editAcademicsVC != nil)
        {
            editAcademicsVC = nil
        }

        if (editAPClassesVC != nil)
        {
            editAPClassesVC = nil
        }
        
        if (editHonorsClassesVC != nil)
        {
            editHonorsClassesVC = nil
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
