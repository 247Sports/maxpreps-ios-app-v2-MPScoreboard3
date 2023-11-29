//
//  ProfileViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/3/23.
//

import UIKit
import GoogleMobileAds
//import MoPubAdapter
import DTBiOSSDK
import AdSupport
import AppTrackingTransparency

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DTBAdCallback, GADBannerViewDelegate, APHonorsDetailViewControllerDelegate, EditAcademicsTopViewControllerDelegate, NewEditMeasurementsViewControllerDelegate, AchievementsAwardsDetailViewControllerDelegate, EditAchievementsAwardsTopViewControllerDelegate, ExtracurricularsDetailViewControllerDelegate, EditExtracurricularsTopViewControllerDelegate
{
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var darkObscurringView: UIView!
    
    var selectedAthlete : Athlete!
    var ftag = ""
    
    private var academicsArray: Array<Dictionary<String,Any>> = []
    private var measurementsTitleArray: Array<String> = []
    private var measurementsValueArray: Array<Double> = []
    private var measurementsInchesArray: Array<Double> = []
    private var measurementsDictionary = [:] as Dictionary<String,Any>
    private var achievementsAwardsArray: Array<Dictionary<String,Any>> = []
    private var extracurricularsArray: Array<Dictionary<String,Any>> = []
    
    private var apHonorsDetailVC: APHonorsDetailViewController!
    private var achievementsAwardsDetailVC: AchievementsAwardsDetailViewController!
    private var extracurricularsDetailVC: ExtracurricularsDetailViewController!
    private var editAcademicsTopVC: EditAcademicsTopViewController!
    private var editMeasurementsVC: NewEditMeasurementsViewController!
    private var editAchievementsAwardsTopVC: EditAchievementsAwardsTopViewController!
    private var editExtracurricularsTopVC: EditExtracurricularsTopViewController!
    
    private var googleBannerAdView: GAMBannerView!
    private var bannerBackgroundView: UIVisualEffectView! //UIImageView!
    
    private var trackingGuid = ""
    private var progressOverlay: ProgressHUD!
    
    private var kAllAcademics = ["GPA", "SAT", "ACT", "AP Classes", "Honors Classes"]
    private var kAllMeasurements = ["Height", "Weight", "Wingspan", "Standing Reach", "Dominant Hand", "Dominant Foot", "Bench", "Squat", "Deadlift", "Shuttle", "40-Yard Dash", "Vertical Jump", "Broad Jump"]
    
    // MARK: - Nimbus Variables
    
    let apsLoader: DTBAdLoader = {
        let loader = DTBAdLoader()
        loader.setAdSizes([
            DTBAdSize(bannerAdSizeWithWidth: 320, height: 50, andSlotUUID: kAmazonBannerAdSlotUUID) as Any
        ])
        return loader
    }()
    
    lazy var bidders: [Bidder] = [
        // Position identifies this placement in our dashboard, it is freeform so I matched the Google ad unit name
        NimbusBidder(request: .forBannerAd(position: "career")),
        APSBidder(adLoader: apsLoader)
    ]
    
    lazy var dynamicPriceManager = DynamicPriceManager(bidders: bidders, refreshInterval: TimeInterval(kNimbusAdTimerValue))
    
    // MARK: - Get Career Profile Bio Data
    
    private func getCareerProfileBioData()
    {
        let careerId = self.selectedAthlete?.careerId
        print(careerId!)
        
        // Show the busy indicator
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        CareerFeeds.getCareerProfileBio(careerId!) { (result, error) in
            
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                if (self.progressOverlay != nil)
                {
                    self.progressOverlay.hide(animated: false)
                    self.progressOverlay = nil
                }
            }
            
            if error == nil
            {
                print("Get career profile bio success.")
                
                // Build the academics items
                let academics = result!["academics"] as! Dictionary<String,Any>
  
                self.academicsArray.removeAll()
                
                // Nested for loops to build the arrays in a particular order
                for title in self.kAllAcademics
                {
                    for item in academics
                    {
                        let key = item.key
                        var refactoredAcademics: Dictionary<String,Any> = [:]
                        
                        if ((key == "highSchoolGpa") && (title == "GPA"))
                        {
                            let value = academics[key] as? Double ?? -1.0
                            if (value != -1.0)
                            {
                                refactoredAcademics["value"] = value
                                refactoredAcademics["title"] = title
                                self.academicsArray.append(refactoredAcademics)
                            }
                        }
                        
                        if ((key == "satScore") && (title == "SAT"))
                        {
                            let value = academics[key] as? Int ?? -1
                            if (value != -1)
                            {
                                refactoredAcademics["value"] = value
                                refactoredAcademics["title"] = title
                                self.academicsArray.append(refactoredAcademics)
                            }
                        }
                        
                        if ((key == "actScore") && (title == "ACT"))
                        {
                            let value = academics[key] as? Int ?? -1
                            if (value != -1)
                            {
                                refactoredAcademics["value"] = value
                                refactoredAcademics["title"] = title
                                self.academicsArray.append(refactoredAcademics)
                            }
                        }
                        
                        if ((key == "apClasses") && (title == "AP Classes"))
                        {
                            let objectArray = academics[key] as? Array<Dictionary<String,Any>> ?? []
                            var values: Array<String> = []
                            
                            for apItem in objectArray
                            {
                                let className = apItem["className"] as! String
                                values.append(className)
                            }
                            refactoredAcademics["value"] = values
                            refactoredAcademics["title"] = title
                            if (values.count > 0)
                            {
                                self.academicsArray.append(refactoredAcademics)
                            }
                        }
                        
                        if ((key == "honorClasses") && (title == "Honors Classes"))
                        {
                            let objectArray = academics[key] as? Array<Dictionary<String,Any>> ?? []
                            var values: Array<String> = []
                            
                            for apItem in objectArray
                            {
                                let className = apItem["className"] as! String
                                values.append(className)
                            }
                            refactoredAcademics["value"] = values
                            refactoredAcademics["title"] = title
                            if (values.count > 0)
                            {
                                self.academicsArray.append(refactoredAcademics)
                            }
                        }
                    }
                }
                
                // Build the measurement items
                self.measurementsDictionary = result!["measurements"] as! Dictionary<String,Any>
                
                let measurements = result!["measurements"] as! Dictionary<String,Any>
                
                self.measurementsTitleArray.removeAll()
                self.measurementsValueArray.removeAll()
                self.measurementsInchesArray.removeAll()
                
                // ["Height", "Weight", "Wingspan", "Standing Reach", "Dominant Hand", "Dominant Foot", "Bench", "Squat", "Deadlift", "Shuttle", "40 Yard Dash", "Vertical Jump", "Broad Jump"]
                
                // Nested for loops to build the arrays in a particular order
                for title in self.kAllMeasurements
                {
                    for item in measurements
                    {
                        let key = item.key
                        var value = -1.0
                        
                        // Special case the dominantHand or dominantFoot by converting a string into 0 or 1
                        if (key == "dominantHand")
                        {
                            let stringValue = measurements[key] as? String ?? ""
                            if (stringValue == "left")
                            {
                                value = 0
                            }
                            else if (stringValue == "right")
                            {
                                value = 1.0
                            }
                            else if (stringValue == "both")
                            {
                                value = 2.0
                            }
                            else
                            {
                                value = -1.0
                            }
                        }
                        else if (key == "dominantFoot")
                        {
                            let stringValue = measurements[key] as? String ?? ""
                            if (stringValue == "left")
                            {
                                value = 0
                            }
                            else if (stringValue == "right")
                            {
                                value = 1.0
                            }
                            else if (stringValue == "both")
                            {
                                value = 2.0
                            }
                            else
                            {
                                value = -1.0
                            }
                        }
                        else
                        {
                            value = measurements[key] as? Double ?? -1.0
                        }
                        
                        // Skip Null items for the arrays
                        if (value != -1.0)
                        {
                            if (title == "Height")
                            {
                                if (key == "heightFeet")
                                {
                                    self.measurementsTitleArray.append(title)
                                    self.measurementsValueArray.append(value)
                                }
                                else if (key == "heightInches")
                                {
                                    self.measurementsInchesArray.append(value)
                                }
                            }
                            
                            if ((key == "weight") && (title == "Weight"))
                            {
                                self.measurementsTitleArray.append(title)
                                self.measurementsValueArray.append(value)
                                self.measurementsInchesArray.append(0)
                            }
                            
                            if (title == "Wingspan")
                            {
                                if (key == "wingspanFeet")
                                {
                                    self.measurementsTitleArray.append(title)
                                    self.measurementsValueArray.append(value)
                                }
                                else if (key == "wingspanInches")
                                {
                                    self.measurementsInchesArray.append(value)
                                }
                            }
                            
                            if (title == "Standing Reach")
                            {
                                if (key == "standingReachFeet")
                                {
                                    self.measurementsTitleArray.append(title)
                                    self.measurementsValueArray.append(value)
                                }
                                else if (key == "standingReachInches")
                                {
                                    self.measurementsInchesArray.append(value)
                                }
                            }
                            
                            if ((key == "dominantHand") && (title == "Dominant Hand"))
                            {
                                self.measurementsTitleArray.append(title)
                                self.measurementsValueArray.append(value)
                                self.measurementsInchesArray.append(0)
                            }
                            
                            if ((key == "dominantFoot") && (title == "Dominant Foot"))
                            {
                                self.measurementsTitleArray.append(title)
                                self.measurementsValueArray.append(value)
                                self.measurementsInchesArray.append(0)
                            }
                            
                            if ((key == "benchPress") && (title == "Bench"))
                            {
                                self.measurementsTitleArray.append(title)
                                self.measurementsValueArray.append(value)
                                self.measurementsInchesArray.append(0)
                            }
                            
                            if ((key == "squat") && (title == "Squat"))
                            {
                                self.measurementsTitleArray.append(title)
                                self.measurementsValueArray.append(value)
                                self.measurementsInchesArray.append(0)
                            }
                            
                            if ((key == "deadlift") && (title == "Deadlift"))
                            {
                                self.measurementsTitleArray.append(title)
                                self.measurementsValueArray.append(value)
                                self.measurementsInchesArray.append(0)
                            }
                            
                            if ((key == "shuttleRunTime") && (title == "Shuttle"))
                            {
                                self.measurementsTitleArray.append(title)
                                self.measurementsValueArray.append(value)
                                self.measurementsInchesArray.append(0)
                            }
                            
                            if ((key == "fortyYardDashTime") && (title == "40-Yard Dash"))
                            {
                                self.measurementsTitleArray.append(title)
                                self.measurementsValueArray.append(value)
                                self.measurementsInchesArray.append(0)
                            }
                            
                            if ((key == "verticalJump") && (title == "Vertical Jump"))
                            {
                                self.measurementsTitleArray.append(title)
                                self.measurementsValueArray.append(0)
                                self.measurementsInchesArray.append(value)
                            }
                            
                            if (title == "Broad Jump")
                            {
                                if (key == "broadJumpFeet")
                                {
                                    self.measurementsTitleArray.append(title)
                                    self.measurementsValueArray.append(value)
                                }
                                else if (key == "broadJumpInches")
                                {
                                    self.measurementsInchesArray.append(value)
                                }
                            }
                        }
                    }
                }
                
                // Get the awards items
                self.achievementsAwardsArray = result!["achievementsAwards"] as! Array<Dictionary<String,Any>>
                
                print("AchievementsAwardsArray Count: " + String(self.academicsArray.count))
                
                // Get the extracurriculars items
                self.extracurricularsArray = result!["extracurriculars"] as! Array<Dictionary<String,Any>>
                
                print("ExtraCurricularsArray Count: " + String(self.extracurricularsArray.count))
                
                // Reload the table so the data is inserted
                self.profileTableView.reloadData()
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
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section == 0)
        {
            if (academicsArray.count > 0)
            {
                return academicsArray.count
            }
            else
            {
                return 1
            }
        }
        else if (section == 1)
        {
            if (measurementsTitleArray.count > 0)
            {
                return measurementsTitleArray.count
            }
            else
            {
                return 1
            }
        }
        else if (section == 2)
        {
            if (achievementsAwardsArray.count > 0)
            {
                return achievementsAwardsArray.count
            }
            else
            {
                return 1
            }
        }
        else
        {
            if (extracurricularsArray.count > 0)
            {
                return extracurricularsArray.count
            }
            else
            {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if (indexPath.section == 2)
        {
            if (achievementsAwardsArray.count > 0)
            {
                return 64.0
            }
            else
            {
                return 40.0
            }
        }
        else if (indexPath.section == 3)
        {
            if (extracurricularsArray.count > 0)
            {
                return 64.0
            }
            else
            {
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
        return 64.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if ((section == 0) || (section == 1) || (section == 2))
        {
            return 16.0
        }
        else
        {
            // Add pad for the banner ad
            return 16 + 62
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if (section == 0)
        {
            // Instantiate the header view
            let headerNib = Bundle.main.loadNibNamed("ProfileHeaderViewCell", owner: self, options: nil)
            let headerView = headerNib![0] as? ProfileHeaderViewCell
            headerView!.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 64)
            headerView!.editButton.addTarget(self, action: #selector(editAcademicsTouched), for: .touchUpInside)
            headerView!.iconImageView.image = UIImage(named: "AcademicsIcon")
            headerView!.titleLabel.text = "Academics"
            
            // Show the pencil if allowed to edit this profile
            let userId = kUserDefaults.string(forKey: kUserIdKey)
            var canEditCareer = false
            if (userId != kTestDriveUserId)
            {
                canEditCareer = MiscHelper.userCanEditSpecificCareer(careerId: self.selectedAthlete!.careerId).canEdit
            }
            
            if (canEditCareer == true)
            {
                if (academicsArray.count == 0)
                {
                    headerView!.editButton.isHidden = true
                }
                else
                {
                    headerView!.editButton.isHidden = false
                }
            }
            else
            {
                headerView!.editButton.isHidden = true
            }
            
            return headerView!
        }
        else if (section == 1)
        {
            // Instantiate the header view
            let headerNib = Bundle.main.loadNibNamed("ProfileHeaderViewCell", owner: self, options: nil)
            let headerView = headerNib![0] as? ProfileHeaderViewCell
            headerView!.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 64)
            headerView!.editButton.addTarget(self, action: #selector(editMeasurementsTouched), for: .touchUpInside)
            headerView!.iconImageView.image = UIImage(named: "MeasurementsIcon")
            headerView!.titleLabel.text = "Measurements"
            
            // Show the pencil if allowed to edit this profile
            let userId = kUserDefaults.string(forKey: kUserIdKey)
            var canEditCareer = false
            if (userId != kTestDriveUserId)
            {
                canEditCareer = MiscHelper.userCanEditSpecificCareer(careerId: self.selectedAthlete!.careerId).canEdit
            }
            
            if (canEditCareer == true)
            {
                if (measurementsTitleArray.count == 0)
                {
                    headerView!.editButton.isHidden = true
                }
                else
                {
                    headerView!.editButton.isHidden = false
                }
            }
            else
            {
                headerView!.editButton.isHidden = true
            }
            
            return headerView!
        }
        else if (section == 2)
        {
            // Instantiate the header view
            let headerNib = Bundle.main.loadNibNamed("ProfileHeaderViewCell", owner: self, options: nil)
            let headerView = headerNib![0] as? ProfileHeaderViewCell
            headerView!.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 64)
            headerView!.editButton.addTarget(self, action: #selector(editAwardsTouched), for: .touchUpInside)
            headerView!.iconImageView.image = UIImage(named: "AwardsIcon")
            headerView!.titleLabel.text = "Achievements & Awards"
            
            // Show the pencil if allowed to edit this profile
            let userId = kUserDefaults.string(forKey: kUserIdKey)
            var canEditCareer = false
            if (userId != kTestDriveUserId)
            {
                canEditCareer = MiscHelper.userCanEditSpecificCareer(careerId: self.selectedAthlete!.careerId).canEdit
            }
            
            if (canEditCareer == true)
            {
                if (achievementsAwardsArray.count == 0)
                {
                    headerView!.editButton.isHidden = true
                }
                else
                {
                    headerView!.editButton.isHidden = false
                }
            }
            else
            {
                headerView!.editButton.isHidden = true
            }
            
            return headerView!
        }
        else
        {
            // Instantiate the header view
            let headerNib = Bundle.main.loadNibNamed("ProfileHeaderViewCell", owner: self, options: nil)
            let headerView = headerNib![0] as? ProfileHeaderViewCell
            headerView!.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 64)
            headerView!.editButton.addTarget(self, action: #selector(editExtracurricularsTouched), for: .touchUpInside)
            headerView!.iconImageView.image = UIImage(named: "ExtracurricularsIcon")
            headerView!.titleLabel.text = "Extracurriculars"
            
            // Show the pencil if allowed to edit this profile
            let userId = kUserDefaults.string(forKey: kUserIdKey)
            var canEditCareer = false
            if (userId != kTestDriveUserId)
            {
                canEditCareer = MiscHelper.userCanEditSpecificCareer(careerId: self.selectedAthlete!.careerId).canEdit
            }
            
            if (canEditCareer == true)
            {
                if (extracurricularsArray.count == 0)
                {
                    headerView!.editButton.isHidden = true
                }
                else
                {
                    headerView!.editButton.isHidden = false
                }
            }
            else
            {
                headerView!.editButton.isHidden = true
            }
            
            return headerView!
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 16))
        footerView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        
        let footerInnerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 16))
        footerInnerView.backgroundColor = UIColor.mpWhiteColor()
        footerInnerView.layer.cornerRadius = 12
        footerInnerView.layer.maskedCorners =  [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        footerInnerView.clipsToBounds = true
        footerView.addSubview(footerInnerView)
        return footerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        var canEditCareer = false
        if (userId != kTestDriveUserId)
        {
            canEditCareer = MiscHelper.userCanEditSpecificCareer(careerId: self.selectedAthlete!.careerId).canEdit
        }
        if (indexPath.section == 0)
        {
            // Academics Cell
            var cell = tableView.dequeueReusableCell(withIdentifier: "NewAcademicsTableViewCell") as? NewAcademicsTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("NewAcademicsTableViewCell", owner: self, options: nil)
                cell = nib![0] as? NewAcademicsTableViewCell
            }
            
            cell?.selectionStyle = .none
            
            cell?.addNewButton.addTarget(self, action: #selector(editAcademicsTouched), for: .touchUpInside)
            
            cell?.noDataLabel.isHidden = true
            cell?.addNewButton.isHidden = true
            cell?.titleLabel.isHidden = true
            cell?.valueLabel.isHidden = true
            cell?.chevronImageView.isHidden = true
            cell?.containerView.layer.cornerRadius = 0
            cell?.containerView.clipsToBounds = true
            
            if (academicsArray.count == 0)
            {
                // Show the noData Label if not edit capable
                if (canEditCareer == false)
                {
                    cell?.noDataLabel.isHidden = false
                }
                else
                {
                    cell?.addNewButton.isHidden = false
                }
                
                // Round all corners of the cell
                cell?.containerView.layer.cornerRadius = 8
            }
            else
            {
                // Load the labels
                let item = academicsArray[indexPath.row]
                
                let title = item["title"] as! String
                cell?.titleLabel.text = title
                cell?.titleLabel.isHidden = false
                
                cell?.valueLabel.isHidden = false
                
                if (title == "GPA")
                {
                    let value = item["value"] as! Double
                    cell?.valueLabel.text = String(format: "%1.2f", value)
                }
                else if ((title == "SAT") || (title == "ACT"))
                {
                    let value = item["value"] as! Int
                    cell?.valueLabel.text = String(format: "%d", Int(value))
                }
                else if ((title == "AP Classes") || (title == "Honors Classes"))
                {
                    let value = item["value"] as! Array<String>
                    let valueString = value.joined(separator: ", ")
                    cell?.valueLabel.text = valueString
                    cell?.chevronImageView.isHidden = false
                }
                
                // Decide how to round the cells
                if (academicsArray.count == 1)
                {
                    // Round all corners of the cell
                    cell?.containerView.layer.cornerRadius = 8
                }
                else
                {
                    // Round the first and last cells only
                    if (indexPath.row == 0)
                    {
                        cell?.containerView.layer.cornerRadius = 8
                        cell?.containerView.layer.maskedCorners =  [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                    }
                    
                    if (indexPath.row == (academicsArray.count - 1))
                    {
                        cell?.containerView.layer.cornerRadius = 8
                        cell?.containerView.layer.maskedCorners =  [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                    }
                }
            }
            
            return cell!
        }
        else if (indexPath.section == 1)
        {
            // Measurements Cell
            var cell = tableView.dequeueReusableCell(withIdentifier: "MeasurementsTableViewCell") as? MeasurementsTableViewCell
            
            if (cell == nil)
            {
                let nib = Bundle.main.loadNibNamed("MeasurementsTableViewCell", owner: self, options: nil)
                cell = nib![0] as? MeasurementsTableViewCell
            }
            
            cell?.addNewButton.addTarget(self, action: #selector(editMeasurementsTouched), for: .touchUpInside)
            
            cell?.selectionStyle = .none
            cell?.noDataLabel.isHidden = true
            cell?.addNewButton.isHidden = true
            cell?.titleLabel.isHidden = true
            cell?.valueLabel.isHidden = true
            cell?.containerView.layer.cornerRadius = 0
            cell?.containerView.clipsToBounds = true
            
            if (measurementsTitleArray.count == 0)
            {
                // Show the noData Label if not edit capable
                if (canEditCareer == false)
                {
                    cell?.noDataLabel.isHidden = false
                }
                else
                {
                    cell?.addNewButton.isHidden = false
                }
                
                // Round all corners of the cell
                cell?.containerView.layer.cornerRadius = 8
            }
            else
            {
                cell?.titleLabel.isHidden = false
                cell?.valueLabel.isHidden = false
                
                // Load the labels
                let title = measurementsTitleArray[indexPath.row]
                let value = measurementsValueArray[indexPath.row]
                let inches = measurementsInchesArray[indexPath.row]
                cell?.titleLabel.text = title
                
                //["Height", "Weight", "Wingspan", "Standing Reach", "Dominant Hand", "Dominant Foot", "Bench", "Squat", "Deadlift", "Shuttle", "40-Yard Dash", "Vertical Jump", "Broad Jump"]
                
                if (title == "Height")
                {
                    cell?.valueLabel.text = String(format: "%d'%d\"", Int(value), Int(inches))
                }
                else if (title == "Weight")
                {
                    cell?.valueLabel.text = String(format: "%d lbs", Int(value))
                }
                else if (title == "Wingspan")
                {
                    cell?.valueLabel.text = String(format: "%d'%d\"", Int(value), Int(inches))
                }
                else if (title == "Standing Reach")
                {
                    cell?.valueLabel.text = String(format: "%d'%d\"", Int(value), Int(inches))
                }
                else if (title == "Dominant Hand")
                {
                    if (Int(value) == 0)
                    {
                        cell?.valueLabel.text = "Left"
                    }
                    else if (Int(value) == 1)
                    {
                        cell?.valueLabel.text = "Right"
                    }
                    else if (Int(value) == 2)
                    {
                        cell?.valueLabel.text = "Both"
                    }
                }
                else if (title == "Dominant Foot")
                {
                    if (Int(value) == 0)
                    {
                        cell?.valueLabel.text = "Left"
                    }
                    else if (Int(value) == 1)
                    {
                        cell?.valueLabel.text = "Right"
                    }
                    else if (Int(value) == 2)
                    {
                        cell?.valueLabel.text = "Both"
                    }
                }
                else if (title == "Bench")
                {
                    cell?.valueLabel.text = String(format: "%d lbs", Int(value))
                }
                else if (title == "Squat")
                {
                    cell?.valueLabel.text = String(format: "%d lbs", Int(value))
                }
                else if (title == "Deadlift")
                {
                    cell?.valueLabel.text = String(format: "%d lbs", Int(value))
                }
                else if (title == "Shuttle")
                {
                    cell?.valueLabel.text = String(format: "%1.3f secs", value)
                }
                else if (title == "40-Yard Dash")
                {
                    cell?.valueLabel.text = String(format: "%1.3f secs", value)
                }
                else if (title == "Vertical Jump")
                {
                    cell?.valueLabel.text = String(format: "%d\"", Int(inches))
                }
                else if (title == "Broad Jump")
                {
                    cell?.valueLabel.text = String(format: "%d'%d\"", Int(value), Int(inches))
                }

                // Decide how to round the cells
                if (measurementsTitleArray.count == 1)
                {
                    // Round all corners of the cell
                    cell?.containerView.layer.cornerRadius = 8
                }
                else
                {
                    // Round the first and last cells only
                    if (indexPath.row == 0)
                    {
                        cell?.containerView.layer.cornerRadius = 8
                        cell?.containerView.layer.maskedCorners =  [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                    }
                    
                    if (indexPath.row == (measurementsTitleArray.count - 1))
                    {
                        cell?.containerView.layer.cornerRadius = 8
                        cell?.containerView.layer.maskedCorners =  [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                    }
                }
            }
            
            return cell!
        }
        else if (indexPath.section == 2)
        {
            if (achievementsAwardsArray.count == 0)
            {
                // Empty Awards Cell
                var cell = tableView.dequeueReusableCell(withIdentifier: "EmptyAwardsTableViewCell") as? EmptyAwardsTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("EmptyAwardsTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? EmptyAwardsTableViewCell
                }
                
                cell?.addNewButton.addTarget(self, action: #selector(editAwardsTouched), for: .touchUpInside)
                
                cell?.selectionStyle = .none
                cell?.noDataLabel.isHidden = true
                cell?.noDataLabel.text = "Achievements & awards data has not been entered."
                cell?.addNewButton.isHidden = true
                cell?.addNewButton.setTitle("+ Add achievements & awards", for: .normal)
                cell?.containerView.layer.cornerRadius = 8
                cell?.containerView.clipsToBounds = true
                
                // Show the noData Label if not edit capable
                if (canEditCareer == false)
                {
                    cell?.noDataLabel.isHidden = false
                }
                else
                {
                    cell?.addNewButton.isHidden = false
                }
                
                return cell!
            }
            else
            {
                // Awards Cell
                var cell = tableView.dequeueReusableCell(withIdentifier: "AwardsTableViewCell") as? AwardsTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("AwardsTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? AwardsTableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.containerView.layer.cornerRadius = 0
                cell?.containerView.clipsToBounds = true
                cell?.horizLine.isHidden = false
                
                // Decide how to round the cells
                if (achievementsAwardsArray.count == 1)
                {
                    // Round all corners of the cell
                    cell?.containerView.layer.cornerRadius = 8
                }
                else
                {
                    // Round the first and last cells only
                    if (indexPath.row == 0)
                    {
                        cell?.containerView.layer.cornerRadius = 8
                        cell?.containerView.layer.maskedCorners =  [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                    }
                    
                    if (indexPath.row == (achievementsAwardsArray.count - 1))
                    {
                        cell?.containerView.layer.cornerRadius = 8
                        cell?.containerView.layer.maskedCorners =  [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                    }
                }
                
                // Add the data
                let data = achievementsAwardsArray[indexPath.row]
                let title = data["title"] as? String ?? ""
                let description = data["description"] as? String ?? ""
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
                
                
                if (description.count > 0)
                {
                    cell?.chevronImageView.isHidden = false
                }
                else
                {
                    cell?.chevronImageView.isHidden = true
                }
                
                // Get rid of the last horizLine
                if (indexPath.row == achievementsAwardsArray.count - 1)
                {
                    cell?.horizLine.isHidden = true
                }
                
                return cell!
                
            }
        }
        else
        {
            if (extracurricularsArray.count == 0)
            {
                // Empty Awards Cell
                var cell = tableView.dequeueReusableCell(withIdentifier: "EmptyAwardsTableViewCell") as? EmptyAwardsTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("EmptyAwardsTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? EmptyAwardsTableViewCell
                }
                
                cell?.addNewButton.addTarget(self, action: #selector(editExtracurricularsTouched), for: .touchUpInside)
                
                cell?.selectionStyle = .none
                cell?.noDataLabel.isHidden = true
                cell?.noDataLabel.text = "Extracurricular data has not been entered."
                cell?.addNewButton.isHidden = true
                cell?.addNewButton.setTitle("+ Add extracurriculars", for: .normal)
                cell?.containerView.layer.cornerRadius = 8
                cell?.containerView.clipsToBounds = true
                
                // Show the noData Label if not edit capable
                if (canEditCareer == false)
                {
                    cell?.noDataLabel.isHidden = false
                }
                else
                {
                    cell?.addNewButton.isHidden = false
                }
                
                return cell!
            }
            else
            {
                // Awards Cell
                var cell = tableView.dequeueReusableCell(withIdentifier: "AwardsTableViewCell") as? AwardsTableViewCell
                
                if (cell == nil)
                {
                    let nib = Bundle.main.loadNibNamed("AwardsTableViewCell", owner: self, options: nil)
                    cell = nib![0] as? AwardsTableViewCell
                }
                
                cell?.selectionStyle = .none
                cell?.containerView.layer.cornerRadius = 0
                cell?.containerView.clipsToBounds = true
                cell?.horizLine.isHidden = false
                
                // Decide how to round the cells
                if (extracurricularsArray.count == 1)
                {
                    // Round all corners of the cell
                    cell?.containerView.layer.cornerRadius = 8
                }
                else
                {
                    // Round the first and last cells only
                    if (indexPath.row == 0)
                    {
                        cell?.containerView.layer.cornerRadius = 8
                        cell?.containerView.layer.maskedCorners =  [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                    }
                    
                    if (indexPath.row == (extracurricularsArray.count - 1))
                    {
                        cell?.containerView.layer.cornerRadius = 8
                        cell?.containerView.layer.maskedCorners =  [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                    }
                }
                
                // Add the data
                let data = extracurricularsArray[indexPath.row]
                let title = data["activity"] as? String ?? ""
                let role = data["role"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                
                cell?.titleLabel.text = title
                cell?.subtitleLabel.text = role
                
                if (description.count > 0)
                {
                    cell?.chevronImageView.isHidden = false
                }
                else
                {
                    cell?.chevronImageView.isHidden = true
                }
                
                // Get rid of the last horizLine
                if (indexPath.row == extracurricularsArray.count - 1)
                {
                    cell?.horizLine.isHidden = true
                }
                
                return cell!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if ((indexPath.section == 0) && (academicsArray.count > 0))
        {
            let item = academicsArray[indexPath.row]
            let title = item["title"] as! String
            
            if (title == "AP Classes")
            {
                let apArray = item["value"] as! Array<String>
                self.showAPHonorsDetailViewController(title: title, dataArray: apArray)
            }
            
            if (title == "Honors Classes")
            {
                let honorsArray = item["value"] as! Array<String>
                self.showAPHonorsDetailViewController(title: title, dataArray: honorsArray)
            }
        }
        
        if (indexPath.section == 2) && (achievementsAwardsArray.count > 0)
        {
            let data = achievementsAwardsArray[indexPath.row]
            let description = data["description"] as? String ?? ""
            
            if (description.count > 0)
            {
                self.showAchievementsAwardsDetailViewController(data: data)
            }
        }
        
        if (indexPath.section == 3) && (extracurricularsArray.count > 0)
        {
            let data = extracurricularsArray[indexPath.row]
            let description = data["description"] as? String ?? ""
            
            if (description.count > 0)
            {
                self.showExtracurricularsDetailViewController(data: data)
            }
        }
    }
    
    // MARK: - AP Honors Detail View Controller Methods
    
    private func showAPHonorsDetailViewController(title: String, dataArray: Array<String>)
    {
        self.clearBannerAd()
        
        self.tabBarController?.tabBar.isHidden = true
        
        apHonorsDetailVC = APHonorsDetailViewController(nibName: "APHonorsDetailViewController", bundle: nil)
        apHonorsDetailVC.titleString = title
        apHonorsDetailVC.dataArray = dataArray
        apHonorsDetailVC.delegate = self
        apHonorsDetailVC.isModalInPresentation = true // This prevents auto close
            
        if let sheet = apHonorsDetailVC.sheetPresentationController
        {
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
        }
        self.present(apHonorsDetailVC, animated: true, completion: nil)
        
        // Add some delay to show the darkObscurringView
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
        {
            UIView.animate(withDuration: 0.3)
            { [self] in
                self.darkObscurringView.alpha = 1.0
            }
        }
        
    }
    
    func apHonorsDetailViewControllerDidClose()
    {
        self.dismiss(animated: true)
        {
            self.apHonorsDetailVC = nil
            self.tabBarController?.tabBar.isHidden = false
            
            self.loadBannerViews()
        }
        
        // Add some delay to hide the darkObscurringView
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
        {
            UIView.animate(withDuration: 0.1)
            { [self] in
                self.darkObscurringView.alpha = 0.0
            }
        }
    }
    
    // MARK: - Achievements & Awards Detail View Controller Methods
    
    private func showAchievementsAwardsDetailViewController(data: Dictionary<String,Any>)
    {
        self.clearBannerAd()
        
        self.tabBarController?.tabBar.isHidden = true
        
        achievementsAwardsDetailVC = AchievementsAwardsDetailViewController(nibName: "AchievementsAwardsDetailViewController", bundle: nil)
        achievementsAwardsDetailVC.data = data
        achievementsAwardsDetailVC.delegate = self
        achievementsAwardsDetailVC.isModalInPresentation = true // This prevents auto close
            
        if let sheet = achievementsAwardsDetailVC.sheetPresentationController
        {
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
        }
        self.present(achievementsAwardsDetailVC, animated: true, completion: nil)
        
        // Add some delay to show the darkObscurringView
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
        {
            UIView.animate(withDuration: 0.3)
            { [self] in
                self.darkObscurringView.alpha = 1.0
            }
        }
        
    }
    
    func achievementsAwardsDetailViewControllerDidClose()
    {
        self.dismiss(animated: true)
        {
            self.achievementsAwardsDetailVC = nil
            self.tabBarController?.tabBar.isHidden = false
            
            self.loadBannerViews()
        }
        
        // Add some delay to hide the darkObscurringView
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
        {
            UIView.animate(withDuration: 0.1)
            { [self] in
                self.darkObscurringView.alpha = 0.0
            }
        }
    }
    
    // MARK: - Extracurriculars Detail View Controller Methods
    
    private func showExtracurricularsDetailViewController(data: Dictionary<String,Any>)
    {
        self.clearBannerAd()
        
        self.tabBarController?.tabBar.isHidden = true
        
        extracurricularsDetailVC = ExtracurricularsDetailViewController(nibName: "ExtracurricularsDetailViewController", bundle: nil)
        extracurricularsDetailVC.data = data
        extracurricularsDetailVC.delegate = self
        extracurricularsDetailVC.isModalInPresentation = true // This prevents auto close
            
        if let sheet = extracurricularsDetailVC.sheetPresentationController
        {
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
        }
        self.present(extracurricularsDetailVC, animated: true, completion: nil)
        
        // Add some delay to show the darkObscurringView
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
        {
            UIView.animate(withDuration: 0.3)
            { [self] in
                self.darkObscurringView.alpha = 1.0
            }
        }
        
    }
    
    func extracurricularsDetailViewControllerDidClose()
    {
        self.dismiss(animated: true)
        {
            self.extracurricularsDetailVC = nil
            self.tabBarController?.tabBar.isHidden = false
            
            self.loadBannerViews()
        }
        
        // Add some delay to hide the darkObscurringView
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
        {
            UIView.animate(withDuration: 0.1)
            { [self] in
                self.darkObscurringView.alpha = 0.0
            }
        }
    }

    // MARK: - EditAcademicsTopViewController Delegate
    
    func editAcademicsTopViewControllerDone()
    {
        self.dismiss(animated: true)
        {
            self.editAcademicsTopVC = nil
            self.tabBarController?.tabBar.isHidden = false
            self.getCareerProfileBioData()
            
            // Show the ad
            self.loadBannerViews()
        }
    }
    
    // MARK: - EditAchievementsAwardsTopViewController Delegate
    
    func editAchievementsAwardsTopViewControllerDone()
    {
        self.dismiss(animated: true)
        {
            self.editAchievementsAwardsTopVC = nil
            self.tabBarController?.tabBar.isHidden = false
            self.getCareerProfileBioData()
            
            // Show the ad
            self.loadBannerViews()
        }
    }
    
    // MARK: - EditExtracuricularsTopViewController Delegate
    
    func editExtracurricularsTopViewControllerDone()
    {
        self.dismiss(animated: true)
        {
            self.editExtracurricularsTopVC = nil
            self.tabBarController?.tabBar.isHidden = false
            self.getCareerProfileBioData()
            
            // Show the ad
            self.loadBannerViews()
        }
    }
    
    // MARK: - EditMeasurementsViewController Delegate
    
    func editMeasurementsViewControllerDidSave()
    {
        self.dismiss(animated: true)
        {
            self.editMeasurementsVC = nil
            self.tabBarController?.tabBar.isHidden = false
            self.getCareerProfileBioData()
            
            // Show the ad
            self.loadBannerViews()
        }
    }
    
    func editMeasurementsViewControllerDidCancel()
    {
        self.dismiss(animated: true)
        {
            self.editMeasurementsVC = nil
            self.tabBarController?.tabBar.isHidden = false
            
            // Show the ad
            self.loadBannerViews()
        }
    }

    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func editAcademicsTouched()
    {
        self.clearBannerAd()
        
        self.tabBarController?.tabBar.isHidden = true
        
        editAcademicsTopVC = EditAcademicsTopViewController(nibName: "EditAcademicsTopViewController", bundle: nil)
        editAcademicsTopVC.delegate = self
        editAcademicsTopVC.allAcademics = kAllAcademics
        editAcademicsTopVC.careerId = self.selectedAthlete!.careerId
        
        let editAcademicsNav = TopNavigationController()
        editAcademicsNav.viewControllers = [editAcademicsTopVC] as Array
        editAcademicsNav.modalPresentationStyle = .fullScreen
        self.present(editAcademicsNav, animated: true)
        {
            
        }
        
        // Tracking
        let firstName = self.selectedAthlete?.firstName
        let lastName = self.selectedAthlete?.lastName
        let fullName = firstName! + " " + lastName!
        let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId]
                    
        TrackingManager.trackState(featureName: "career-manage", trackingGuid: trackingGuid, cData: cData as Dictionary<String, Any>)
    }
    
    @objc private func editMeasurementsTouched()
    {
        self.clearBannerAd()
        
        self.tabBarController?.tabBar.isHidden = true
        
        let careerId = self.selectedAthlete?.careerId
        
        editMeasurementsVC = NewEditMeasurementsViewController(nibName: "NewEditMeasurementsViewController", bundle: nil)
        editMeasurementsVC.modalPresentationStyle = .overCurrentContext
        editMeasurementsVC.delegate = self
        editMeasurementsVC.careerId = careerId!
        editMeasurementsVC.measurementsDictionary = self.measurementsDictionary
        
        self.present(editMeasurementsVC, animated: true)
        {
            
        }
        
        // Tracking
        let firstName = self.selectedAthlete?.firstName
        let lastName = self.selectedAthlete?.lastName
        let fullName = firstName! + " " + lastName!
        let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId]
                    
        TrackingManager.trackState(featureName: "career-manage", trackingGuid: trackingGuid, cData: cData as Dictionary<String, Any>)
    }
    
    @objc private func editAwardsTouched()
    {
        self.clearBannerAd()
        
        self.tabBarController?.tabBar.isHidden = true
        
        editAchievementsAwardsTopVC = EditAchievementsAwardsTopViewController(nibName: "EditAchievementsAwardsTopViewController", bundle: nil)
        editAchievementsAwardsTopVC.delegate = self
        editAchievementsAwardsTopVC.careerId = self.selectedAthlete!.careerId
        
        let editAchievementsAwardsNav = TopNavigationController()
        editAchievementsAwardsNav.viewControllers = [editAchievementsAwardsTopVC] as Array
        editAchievementsAwardsNav.modalPresentationStyle = .fullScreen
        self.present(editAchievementsAwardsNav, animated: true)
        {
            
        }
        
        // Tracking
        let firstName = self.selectedAthlete?.firstName
        let lastName = self.selectedAthlete?.lastName
        let fullName = firstName! + " " + lastName!
        let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId]
                    
        TrackingManager.trackState(featureName: "career-manage", trackingGuid: trackingGuid, cData: cData as Dictionary<String, Any>)
    }
    
    @objc private func editExtracurricularsTouched()
    {
        self.clearBannerAd()
        
        self.tabBarController?.tabBar.isHidden = true
        
        editExtracurricularsTopVC = EditExtracurricularsTopViewController(nibName: "EditExtracurricularsTopViewController", bundle: nil)
        editExtracurricularsTopVC.delegate = self
        editExtracurricularsTopVC.careerId = self.selectedAthlete!.careerId
        
        let editExtracurricularsNav = TopNavigationController()
        editExtracurricularsNav.viewControllers = [editExtracurricularsTopVC] as Array
        editExtracurricularsNav.modalPresentationStyle = .fullScreen
        self.present(editExtracurricularsNav, animated: true)
        {
            
        }
        
        // Tracking
        let firstName = self.selectedAthlete?.firstName
        let lastName = self.selectedAthlete?.lastName
        let fullName = firstName! + " " + lastName!
        let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId]
                    
        TrackingManager.trackState(featureName: "career-manage", trackingGuid: trackingGuid, cData: cData as Dictionary<String, Any>)
    }
    
    // MARK: - Amazon Banner Ad Methods
    
    private func requestAmazonBannerAd()
    {
        let adSize = DTBAdSize(bannerAdSizeWithWidth: 320, height: 50, andSlotUUID: kAmazonBannerAdSlotUUID)
        let adLoader = DTBAdLoader()
        adLoader.setAdSizes([adSize!])
        adLoader.loadAd(self)
    }
    
    func onSuccess(_ adResponse: DTBAdResponse!)
    {
        var adResponseDictionary = adResponse.customTargeting()
        
        adResponseDictionary!.updateValue(trackingGuid, forKey: "vguid")
        
        let ccpaString = kUserDefaults.string(forKey: "IABUSPrivacy_String") ?? ""
        adResponseDictionary!.updateValue(ccpaString, forKey: "us_privacy")
        
        // To be added in V6.2.8
        if (MiscHelper.isUserMinorAged() == true)
        {
            adResponseDictionary!.updateValue("1", forKey: "tfcd")
        }
        
        print("Received Amazon Banner Ad")
        
        let request = GAMRequest()
        request.customTargeting = adResponseDictionary
        /*
        // Add a location
        let location = ZipCodeHelper.locationForAd() as! Dictionary<String, String>
        let latitudeValue = Float(location[kLatitudeKey]!)
        let longitudeValue = Float(location[kLongitudeKey]!)
        
        if ((latitudeValue != 0) && (longitudeValue != 0))
        {
            request.setLocationWithLatitude(CGFloat(latitudeValue!), longitude: CGFloat(longitudeValue!), accuracy: 30)
        }
        */
        if (googleBannerAdView != nil)
        {
            googleBannerAdView.load(request)
        }
    }
    
    func onFailure(_ error: DTBAdError)
    {
        print("Amazon Banner Ad Failed")
        
        let request = GAMRequest()
        
        var customTargetDictionary = [:] as Dictionary<String, String>
        let idfaString = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        customTargetDictionary.updateValue(trackingGuid, forKey: "vguid")
        customTargetDictionary.updateValue(idfaString, forKey: "idtype")
        
        // Get the ATT type string to add to the custonTargetDictionary
        let trackingString = MiscHelper.trackingStatusForAds()
        customTargetDictionary.updateValue(trackingString, forKey: "attmas")
        
        let ccpaString = kUserDefaults.string(forKey: "IABUSPrivacy_String") ?? ""
        customTargetDictionary.updateValue(ccpaString, forKey: "us_privacy")
        
        // To be added in V6.2.8
        if (MiscHelper.isUserMinorAged() == true)
        {
            customTargetDictionary.updateValue("1", forKey: "tfcd")
        }
        
        request.customTargeting = customTargetDictionary
        /*
        // Add a location
        let location = ZipCodeHelper.locationForAd() as! Dictionary<String, String>
        let latitudeValue = Float(location[kLatitudeKey]!)
        let longitudeValue = Float(location[kLongitudeKey]!)
        
        if ((latitudeValue != 0) && (longitudeValue != 0))
        {
            request.setLocationWithLatitude(CGFloat(latitudeValue!), longitude: CGFloat(longitudeValue!), accuracy: 30)
        }
        */
        /*
        // Add MoPub
        let extras = GADMoPubNetworkExtras()
        extras.privacyIconSize = 20
        request.register(extras)
        */
        
        if (googleBannerAdView != nil)
        {
            googleBannerAdView.load(request)
        }
    }
    
    // MARK: - Google Ad Methods
    
    private func loadBannerViews()
    {
        // Removed for Nimbus
        /*
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
        */
        
        self.clearBannerAd()
        
        // Removed for Nimbus
        // Add a timer to request a new ad after 15 seconds
        //tickTimer = Timer.scheduledTimer(timeInterval: TimeInterval(kGoogleAdTimerValue), target: self, selector: #selector(adTimerExpired), userInfo: nil, repeats: true)
        
        //GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = ["ab075279b6aba4510e894e3563b029dc"]
        let adId = kUserDefaults.value(forKey: kAthleteBannerAdIdKey) as! String
        print("AdId: ", adId)
        
        googleBannerAdView = GAMBannerView(adSize: GADAdSizeBanner, origin: CGPoint(x: (kDeviceWidth - GADAdSizeBanner.size.width) / 2.0, y: 6.0))
        googleBannerAdView.delegate = self
        googleBannerAdView.adUnitID = adId
        googleBannerAdView.rootViewController = self
        
        // Removed for Nimbus
        //self.requestAmazonBannerAd()
        
        // Added for Nimbus
        // Starts a task to refresh every 30 seconds with proper foreground/background notifications
        //dynamicPriceManager.autoRefresh { [weak self] request in
        dynamicPriceManager.autoRefresh { request in
            
            request.customTargeting?.updateValue(self.trackingGuid, forKey: "vguid")
            
            // Get the ATT type string to add to the customTargetDictionary
            let trackingString = MiscHelper.trackingStatusForAds()
            request.customTargeting?.updateValue(trackingString, forKey: "attmas")
            
            let ccpaString = kUserDefaults.string(forKey: "IABUSPrivacy_String") ?? ""
            request.customTargeting?.updateValue(ccpaString, forKey: "us_privacy")
            
            let idfaString = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            request.customTargeting?.updateValue(idfaString, forKey: "idtype")
            
            let abTestString = MiscHelper.userABTestValue()
            if (abTestString != "")
            {
                request.customTargeting?.updateValue(abTestString, forKey: "test")
            }
            
            // To be added in V6.2.8
            if (MiscHelper.isUserMinorAged() == true)
            {
                request.customTargeting?.updateValue("1", forKey: "tfcd")
            }
            
            if (self.googleBannerAdView != nil)
            {
                self.googleBannerAdView.load(request)
            }
        }
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView)
    {
        print("Received Google Banner Ad")
        
        /* // MoPub is disabled
        if (bannerView.responseInfo?.adNetworkClassName != "GADMAdapterGoogleAdMobAds")
        {
            print("MoPub Ad Served")
         if (kUserDefaults.bool(forKey: kDebugDialogsKey) == true)
            {
                tickTimer.invalidate()
                tickTimer = nil
                
                MiscHelper.showAlert(in: self, withActionNames: ["Ok"], title: "MoPub Ad", message: "", lastItemCancelType: false) { tag in
                    
                }
            }
        }
        */
        
        // Added for Nimbus
        if (bannerBackgroundView != nil)
        {
            bannerBackgroundView.removeFromSuperview()
            bannerBackgroundView = nil
        }
        
        // Delay added for Nimbus
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
        {
            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            self.bannerBackgroundView = UIVisualEffectView(effect: blurEffect)
            self.bannerBackgroundView.frame = CGRect(x: 0, y: Int(kDeviceHeight) - kTabBarHeight - SharedData.bottomSafeAreaHeight - Int(GADAdSizeBanner.size.height) - 12, width: Int(kDeviceWidth), height: Int(GADAdSizeBanner.size.height) + 12)
            
            // Add the background to the view and the banner ad to the background
            self.view.addSubview(self.bannerBackgroundView)
            self.bannerBackgroundView.contentView.addSubview(bannerView)
            
            // Move it down so it is hidden
            self.bannerBackgroundView.transform = CGAffineTransform(translationX: 0, y: self.bannerBackgroundView.frame.size.height + 5)
            
            // Animate the ad up
            UIView.animate(withDuration: 0.25, animations: {
                self.bannerBackgroundView.transform = CGAffineTransform(translationX: 0, y: 0)
                
            })
            { (finished) in
                
            }
        }
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error)
    {
        print("Google Banner Ad Failed")
        
        // Added for Nimbus
        if (bannerBackgroundView != nil)
        {
            bannerBackgroundView.removeFromSuperview()
            bannerBackgroundView = nil
        }
    }
    
    private func clearBannerAd()
    {
        // Added for Nimbus
        dynamicPriceManager.cancelRefresh()
        
        if (googleBannerAdView != nil)
        {
            googleBannerAdView.removeFromSuperview()
            googleBannerAdView = nil
            
            if (bannerBackgroundView != nil)
            {
                bannerBackgroundView.removeFromSuperview()
                bannerBackgroundView = nil
            }
        }
    }
    
    // MARK: - App Entered Background Notification
    
    @objc private func applicationDidEnterBackground()
    {
        self.clearBannerAd()
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        trackingGuid = NSUUID().uuidString
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        // Explicitly set the header view size. The items within the view are pinned to the bottom
        navView.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight + kNavBarHeight)
        profileTableView.frame = CGRect(x: 0, y: Int(navView.frame.size.height), width: Int(kDeviceWidth), height: Int(kDeviceHeight) - Int(navView.frame.size.height) - SharedData.bottomSafeAreaHeight - kTabBarHeight)
        darkObscurringView.frame = CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight)
        darkObscurringView.alpha = 0.0
        
        let schoolColorString = self.selectedAthlete!.schoolColor
        let schoolColor = ColorHelper.color(fromHexString: schoolColorString, colorCorrection: true)!
        navView.backgroundColor = schoolColor
        
        // Tracking
        let firstName = self.selectedAthlete!.firstName
        let lastName = self.selectedAthlete!.lastName
        let fullName = firstName + " " + lastName
        let cData = [kTrackingCareerNameKey:fullName, kTrackingPlayerIdKey:selectedAthlete?.careerId, kTrackingFtagKey: self.ftag]
                    
        TrackingManager.trackState(featureName: "career-profile", trackingGuid: trackingGuid, cData: cData as Dictionary<String, Any>)
        
        // Add an observer for the app going into the background
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // Show the ad
        self.loadBannerViews()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = false
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mpBlackColor(), .font: UIFont.mpSemiBoldFontWith(size: kNavBarFontSize)]
        
        // Get the career profile bio data
        self.getCareerProfileBioData()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)

        self.clearBannerAd()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.lightContent
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

    deinit
    {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
}
