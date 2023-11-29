//
//  RestoreDeletedAthleteViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/1/21.
//

import UIKit
import AVFoundation

protocol RestoreDeletedAthleteViewControllerDelegate: AnyObject
{
    func restoreDeletedAthleteRestoreButtonTouched()
    func restoreDeletedAthleteCancelButtonTouched()
}

class RestoreDeletedAthleteViewController: UIViewController, UITextFieldDelegate
{
    weak var delegate: RestoreDeletedAthleteViewControllerDelegate?
    
    var selectedTeam : Team?
    var ssid : String?
    var currentAthlete : RosterAthlete?
    
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    
    @IBOutlet weak var nameContainerView: UIView!
    @IBOutlet weak var athletePhotoImageView: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var gradeContainerView: UIView!
    @IBOutlet weak var gradeTextField: UITextField!
    
    @IBOutlet weak var jerseyContainerView: UIView!
    @IBOutlet weak var jerseyTextField: UITextField!
    
    @IBOutlet weak var heightContainerView: UIView!
    @IBOutlet weak var heightTextField: UITextField!
    
    @IBOutlet weak var weightContainerView: UIView!
    @IBOutlet weak var weightTextField: UITextField!
    
    @IBOutlet weak var genderContainerView: UIView!
    @IBOutlet weak var genderTextField: UITextField!
    
    @IBOutlet weak var weightClassContainerView: UIView!
    @IBOutlet weak var weightClassTextField: UITextField!
    
    @IBOutlet weak var positionsContainerView: UIView!
    @IBOutlet weak var positionsTextField: UITextField!
    @IBOutlet weak var positionsLabel: UILabel!
    
    @IBOutlet weak var captainContainerView: UIView!
    @IBOutlet weak var captainButton: UIButton!
    
    @IBOutlet weak var tabBarContainer: UIView!
    @IBOutlet weak var restoreButton: UIButton!

    private var isCaptain = false
    private var positions = [""]
    private var scrollViewInitialHeight = 0
    private var currentSport = ""
    private var currentGender = ""
    private var teamColor = UIColor.mpRedColor()
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - TextField Delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        return false
    }
    
    // MARK: - Button Methods
    
    @IBAction func cancelButtonTouched(_ sender: UIButton)
    {
        self.delegate?.restoreDeletedAthleteCancelButtonTouched()
    }
    
    @IBAction func restoreButtonTouched(_ sender: UIButton)
    {
        // Call the feed
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        RosterFeeds.restoreSecureAthlete(schoolId: selectedTeam!.schoolId, ssid: self.ssid!, athleteId: currentAthlete!.athleteId) { result, error in
            
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
                print("Restore Athlete Success")
                
                OverlayView.showPopupOverlay(withMessage: "Athlete Restored")
                {
                    self.delegate?.restoreDeletedAthleteRestoreButtonTouched()
                }
            }
            else
            {
                print("Restore Athlete Failed")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when trying to restore this athlete.", lastItemCancelType: false) { tag in
                    
                }
            }
        } 
    }
    
    // MARK: - Load User Interface
    
    private func loadUserInterface()
    {
        // Adjust the positions title label to reflect the sport
        if ((currentSport == "Golf") || (currentSport == "Tennis"))
        {
            positionsLabel.text = "R/L Handed"
        }
        else if ((currentSport == "Track & Field") || (currentSport == "Swimming"))
        {
            positionsLabel.text = "Specialty"
        }

        let topContentHeight = Int(nameContainerView.frame.size.height) + Int(jerseyContainerView.frame.size.height) + Int(gradeContainerView.frame.size.height) + Int(heightContainerView.frame.size.height)
        
        var bottomContentHeight = 0

        if (currentSport == "Wrestling")
        {
            weightContainerView.isHidden = true
            
            // Move the weightClass, positions, and captain containers after the gender container
            weightClassContainerView.frame = CGRect(x: 0.0, y: genderContainerView.frame.origin.y + genderContainerView.frame.size.height, width: weightClassContainerView.frame.size.width, height: weightClassContainerView.frame.size.height)
            
            positionsContainerView.frame = CGRect(x: 0.0, y: weightClassContainerView.frame.origin.y + weightClassContainerView.frame.size.height, width: positionsContainerView.frame.size.width, height: positionsContainerView.frame.size.height)
            
            captainContainerView.frame = CGRect(x: 0.0, y: positionsContainerView.frame.origin.y + positionsContainerView.frame.size.height, width: captainContainerView.frame.size.width, height: captainContainerView.frame.size.height)
            
            bottomContentHeight = Int(genderContainerView.frame.size.height) + Int(weightClassContainerView.frame.size.height) + Int(positionsContainerView.frame.size.height) + Int(captainContainerView.frame.size.height)
        }
        else
        {
            // Hide the weightClassContainer and genderContainer
            weightClassContainerView.isHidden = true
            genderContainerView.isHidden = true
            
            if (currentGender == "Girls")
            {
                // Hide the weight container and move the positions and captain containers up
                weightContainerView.isHidden = true
                
                positionsContainerView.frame = CGRect(x: 0.0, y: heightContainerView.frame.origin.y + heightContainerView.frame.size.height, width: positionsContainerView.frame.size.width, height: positionsContainerView.frame.size.height)
                
                captainContainerView.frame = CGRect(x: 0.0, y: positionsContainerView.frame.origin.y + positionsContainerView.frame.size.height, width: captainContainerView.frame.size.width, height: captainContainerView.frame.size.height)
                
                bottomContentHeight = Int(positionsContainerView.frame.size.height) + Int(captainContainerView.frame.size.height)
            }
            else
            {
                positionsContainerView.frame = CGRect(x: 0.0, y: weightContainerView.frame.origin.y + weightContainerView.frame.size.height, width: positionsContainerView.frame.size.width, height: positionsContainerView.frame.size.height)
                
                captainContainerView.frame = CGRect(x: 0.0, y: positionsContainerView.frame.origin.y + positionsContainerView.frame.size.height, width: captainContainerView.frame.size.width, height: captainContainerView.frame.size.height)
                
                bottomContentHeight = Int(weightContainerView.frame.size.height) + Int(positionsContainerView.frame.size.height) + Int(captainContainerView.frame.size.height)
            }
        }
        
        // Check to see if the positions container should be hidden. This MiscHelper method returns an array with one element if no posiitons exist.
        let positionsArray = MiscHelper.positionsForSport(currentSport)
        
        if (positionsArray.count == 1)
        {
            positionsContainerView.isHidden = true
            
            captainContainerView.frame = CGRect(x: 0.0, y: positionsContainerView.frame.origin.y, width: captainContainerView.frame.size.width, height: captainContainerView.frame.size.height)
            
            bottomContentHeight = bottomContentHeight - Int(positionsContainerView.frame.size.height)
        }
        
        // Set the scrollView content size
        containerScrollView.contentSize = CGSize(width: Int(kDeviceWidth), height: topContentHeight + bottomContentHeight)
        
        
        // Now populate the athlete info into the various cells
        firstNameTextField.text = currentAthlete!.firstName
        lastNameTextField.text = currentAthlete!.lastName
        jerseyTextField.text = currentAthlete!.jersey
        
        // Height
        if ((currentAthlete!.heightFeet.count > 0) && (currentAthlete!.heightInches.count > 0))
        {
            heightTextField.text = currentAthlete!.heightFeet + "'" + currentAthlete!.heightInches + "\""
        }
        
        // Grade
        if (currentAthlete!.classYear == "8")
        {
            gradeTextField.text = "8th"
        }
        else if (currentAthlete!.classYear == "9")
        {
            gradeTextField.text = "Fr"
        }
        else if (currentAthlete!.classYear == "10")
        {
            gradeTextField.text = "So"
        }
        else if (currentAthlete!.classYear == "11")
        {
            gradeTextField.text = "Jr"
        }
        else if (currentAthlete!.classYear == "12")
        {
            gradeTextField.text = "Sr"
        }

        // Weight
        if (currentAthlete!.weight.count > 0)
        {
            weightTextField.text = currentAthlete!.weight + " lbs."
        }
        
        // WeightClass
        if (currentAthlete!.weightClass.count > 0)
        {
            weightClassTextField.text = currentAthlete!.weightClass + " lbs."
        }
        
        // Positions
        var positions = [] as Array<String>
        
        if (currentAthlete!.position1.count > 0)
        {
            positions.append(currentAthlete!.position1)
        }
        
        if (currentAthlete!.position2.count > 0)
        {
            positions.append(currentAthlete!.position2)
        }
        
        if (currentAthlete!.position3.count > 0)
        {
            positions.append(currentAthlete!.position3)
        }
        
        if (positions.count == 1)
        {
            positionsTextField.text = positions[0]
        }
        else if (positions.count == 2)
        {
            positionsTextField.text = positions[0] + ", " + positions[1]
        }
        else if (positions.count == 3)
        {
            positionsTextField.text = positions[0] + ", " + positions[1] + ", " + positions[2]
        }
        
        // Gender
        if (currentAthlete!.isFemale == true)
        {
            genderTextField.text = "Female"
        }
        else
        {
            genderTextField.text = "Male"
        }
        
        // Captain button
        isCaptain = currentAthlete!.isCaptain
        
        if (isCaptain == true)
        {
            captainButton.setImage(UIImage(named: "CheckBoxBlue"), for: .normal)
        }
        else
        {
            captainButton.setImage(UIImage(named: "CheckBoxOff"), for: .normal)
        }
        
        // Roster image
        let photoUrl = currentAthlete!.photoUrl
        
        if (photoUrl.count > 0)
        {
            let url = URL(string: photoUrl)
            
            // Get the data and make an image
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        self.athletePhotoImageView.image = image
                    }
                }
            }
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        currentSport = selectedTeam!.sport
        currentGender = selectedTeam!.gender
        
        fakeStatusBar.backgroundColor = .clear
        
        let hexColorString = self.selectedTeam?.teamColor
        teamColor = ColorHelper.color(fromHexString: hexColorString, colorCorrection: true)!
 
        // Size and locate the fakeStatusBar, navBar, containerScrollView, and tabBarContainer
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 76 + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height - 12, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        
        scrollViewInitialHeight = Int(kDeviceHeight) - Int(fakeStatusBar.frame.size.height) - Int(navView.frame.size.height) + 12 - 66 - Int(SharedData.bottomSafeAreaHeight)
        
        containerScrollView.frame = CGRect(x: 0, y: Int(fakeStatusBar.frame.size.height) + Int(navView.frame.size.height) - 12, width: Int(kDeviceWidth), height: scrollViewInitialHeight)
        tabBarContainer.frame = CGRect(x: 0, y: Int(kDeviceHeight) - 66 - SharedData.bottomSafeAreaHeight, width: Int(kDeviceWidth), height: 66 + SharedData.bottomSafeAreaHeight)
        
        navView.layer.cornerRadius = 12
        navView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        navView.clipsToBounds = true
        
        restoreButton.layer.cornerRadius = 8
        restoreButton.clipsToBounds = true
        restoreButton.backgroundColor = teamColor
        restoreButton.isEnabled = true
        
        // Add a shadow to the tabBarContainer
        let shadowPath = UIBezierPath(rect: tabBarContainer.bounds)
        tabBarContainer.layer.masksToBounds = false
        tabBarContainer.layer.shadowColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        tabBarContainer.layer.shadowOffset = CGSize(width: 0, height: -3)
        tabBarContainer.layer.shadowOpacity = 0.5
        tabBarContainer.layer.shadowPath = shadowPath.cgPath
        
        athletePhotoImageView.layer.cornerRadius = athletePhotoImageView.frame.size.width / 2
        athletePhotoImageView.clipsToBounds = true
        
        // Update the UI to match the sport
        self.loadUserInterface()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
                
        setNeedsStatusBarAppearanceUpdate()
        
        // Add some delay so the view is partially showing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3)
        {
            UIView.animate(withDuration: 0.3)
            { [self] in
                fakeStatusBar.backgroundColor = UIColor(white: 0, alpha: 0.6)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

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
}
