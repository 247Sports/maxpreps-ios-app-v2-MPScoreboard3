//
//  AddScoreboardViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/24/21.
//

import UIKit
import BranchSDK

class AddScoreboardViewController: UIViewController, UITextFieldDelegate, SearchSportViewControllerDelegate, IQActionSheetPickerViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sportTextField: UITextField!
    @IBOutlet weak var sportIconImageView: UIImageView!
    
    @IBOutlet weak var stateContainerView: UIView!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var metroContainerView: UIView!
    @IBOutlet weak var metroTextField: UITextField!
    @IBOutlet weak var metroTextFieldBackground: UIView!
    
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var bottomContainerTitleLabel: UILabel!
    @IBOutlet weak var saveScorebordButton: UIButton!
    
    private var selectedGender = ""
    private var selectedSport = ""
    private var selectedState = ""
    private var selectedMetro = [:] as Dictionary<String,Any>
    
    private var searchSportVC: SearchSportViewController!
    private var metroSelectorVC: MetroSelectorViewController!
    
    let kNationalTeamsName = "Top National Teams"
    
    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelectTitles titles: [String])
    {
        // Skip if nothing changed
        if (titles.first == selectedState)
        {
            return
        }
        
        stateTextField.text = titles.first
        selectedState = titles.first!
        
        if (titles.first! != kNationalTeamsName)
        {
            //nationalScoreboardMessageContainer.isHidden = true
            bottomContainerView.isHidden = false
            metroContainerView.isHidden = false
            bottomContainerTitleLabel.text = titles.first!
            
            let stateCode = kShortStateLookupDictionary[selectedState]!
            
            /*
             let kScoreboardDefaultNameKey = "scoreboardDefaultName"         // String
             let kScoreboardAliasNameKey = "scoreboardAliasName"             // String
             let kScoreboardGenderKey = "scoreboardGender"                   // String
             let kScoreboardSportKey = "scoreboardSport"                     // String
             let kScoreboardStateNameKey = "scoreboardStateName"             // String
             let kScoreboardStateCodeKey = "scoreboardStateCode"              // String
             let kScoreboardEntityIdKey = "scoreboardEntityId"               // String
             let kScoreboardEntityNameKey = "scoreboardEntityName"           // String
             let kScoreboardDivisionTypeKey = "scoreboardDivisionType"       // String
             let kScoreboardSectionNameKey = "scoreboardSectionName"         // String
             let kScoreboardArrayKey = "scoreboardArray"                     // Array
             */
            
            // Include defaultName, aliasName, gender, sport, state, stateCode, entityId
            selectedMetro = [kScoreboardDefaultNameKey: "state", kScoreboardAliasNameKey: selectedState, kScoreboardGenderKey: selectedGender, kScoreboardSportKey: selectedSport, kScoreboardStateNameKey: selectedState, kScoreboardStateCodeKey: stateCode, kScoreboardEntityIdKey: stateCode, kScoreboardEntityNameKey: "", kScoreboardDivisionTypeKey: "", kScoreboardSectionNameKey: ""]
        }
        else
        {
            // Include defaultName, aliasName, gender, sport, state, stateCode, entityId
            selectedMetro = [kScoreboardDefaultNameKey: "national", kScoreboardAliasNameKey: kNationalTeamsName, kScoreboardGenderKey: selectedGender, kScoreboardSportKey: selectedSport, kScoreboardStateNameKey: selectedState, kScoreboardStateCodeKey: "", kScoreboardEntityIdKey: "25", kScoreboardEntityNameKey: "", kScoreboardDivisionTypeKey: "", kScoreboardSectionNameKey: ""]
            
            bottomContainerView.isHidden = false
            bottomContainerTitleLabel.text = titles.first!
        }
    }
    
    func actionSheetPickerViewDidCancel(_ pickerView: IQActionSheetPickerView)
    {
        
    }
    
    // MARK: - SearchSportViewController Delegates
    
    func searchSportCancelButtonTouched()
    {
        self.dismiss(animated: true)
        {
            
        }
    }
    
    func searchSportSelectButtonTouched()
    {
        selectedSport = searchSportVC.selectedSport
        selectedGender = searchSportVC.selectedGender
        
        // Add a bunch of white space to make room for the sport icon
        let genderSport = MiscHelper.genderSportFrom(gender: selectedGender, sport: selectedSport)
        sportTextField.text = "        " + genderSport
        
        sportIconImageView.image = MiscHelper.getImageForSport(selectedSport)
        stateContainerView.isHidden = false
        
        /*
        if (selectedSport == "Football")
        {
            nationalScoreboardMessageContainer.isHidden = false
            bottomContainerTitleLabel.text = "Top 25 National Teams"
            bottomContainerView.isHidden = false
        }
        */
        self.dismiss(animated: true)
        {
            
        }
    }
    
    // MARK: - TextField Delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if (textField == sportTextField)
        {
            selectedState = ""
            selectedMetro.removeAll()
            
            stateTextField.text = ""
            stateContainerView.isHidden = true
            
            metroTextField.text = ""
            metroContainerView.isHidden = true
            
            //nationalScoreboardMessageContainer.isHidden = true
            bottomContainerView.isHidden = true
            
            if (searchSportVC != nil)
            {
                searchSportVC = nil
            }
            
            searchSportVC = SearchSportViewController(nibName: "SearchSportViewController", bundle: nil)
            searchSportVC.delegate = self
            searchSportVC.showReducedSports = true
            searchSportVC.modalPresentationStyle = .overCurrentContext
            
            self.present(searchSportVC, animated: true)
            {
                
            }
            
            return false
        }
        else if (textField == stateTextField)
        {
            selectedMetro.removeAll()
            
            metroTextField.text = ""
            metroContainerView.isHidden = true
            
            var namesArray = kStateNamesArray
            
            //if (selectedSport == "Football") || (selectedSport == "Basketball")
            //{
                namesArray.insert(kNationalTeamsName, at: 0)
            //}
            
            let picker = IQActionSheetPickerView(title: "Select State", delegate: self)
            picker.toolbarButtonColor = UIColor.mpWhiteColor()
            picker.toolbarTintColor = UIColor.mpPickerToolbarColor()
            picker.titlesForComponents = [namesArray]
            picker.tag = 1
            picker.show()
            
            return false
        }
        else if (textField == metroTextField)
        {
            // Open the metro selector VC
            if (metroSelectorVC != nil)
            {
                metroSelectorVC = nil
            }
            
            metroSelectorVC = MetroSelectorViewController(nibName: "MetroSelectorViewController", bundle: nil)
            
            metroSelectorVC.selectedState = selectedState
            metroSelectorVC.selectedSport = selectedSport
            metroSelectorVC.selectedGender = selectedGender
            metroSelectorVC.selectedMetro = selectedMetro
            
            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(metroSelectorVC, animated: true)
            
            return false
        }
        else
        {
            return false
        }
    }
    
    // MARK: - Check for Duplicate Scoreboards
    
    private func checkForDuplicateScoreboards() -> Bool
    {
        var duplicateFound = false
        
        let type = selectedMetro[kScoreboardDefaultNameKey] as! String
        let gender = selectedMetro[kScoreboardGenderKey] as! String
        let sport = selectedMetro[kScoreboardSportKey] as! String
        let allScoreboards = kUserDefaults.array(forKey: kUserScoreboardsArrayKey) as! Array<Dictionary<String,String>>
        
        if (type == "national")
        {
            // Iterate through all of the scoreboards to look for a gender-sport match
            for scoreboard in allScoreboards
            {
                let testGender = scoreboard[kScoreboardGenderKey]
                let testSport = scoreboard[kScoreboardSportKey]
                let testType = scoreboard[kScoreboardDefaultNameKey]
                
                if ((gender == testGender) && (sport == testSport) && (testType == "national"))
                {
                    duplicateFound = true
                    break
                }
            }
        }
        else if (type == "state")
        {
            // Iterate through all of the scoreboards to look for a state name match and gender-sport match
            let state = selectedMetro[kScoreboardStateNameKey] as! String
            
            for scoreboard in allScoreboards
            {
                let testGender = scoreboard[kScoreboardGenderKey]
                let testSport = scoreboard[kScoreboardSportKey]
                let testState = scoreboard[kScoreboardStateNameKey]
                let testType = scoreboard[kScoreboardDefaultNameKey]
                
                if ((gender == testGender) && (sport == testSport) && (state == testState) && (testType == "state"))
                {
                    duplicateFound = true
                    break
                }
            }
        }
        else
        {
            // Must be an association, league, metro, etc. so look at the entityId for a match
            let state = selectedMetro[kScoreboardStateNameKey] as! String
            let entityId = selectedMetro[kScoreboardEntityIdKey] as! String
            
            for scoreboard in allScoreboards
            {
                let testGender = scoreboard[kScoreboardGenderKey]
                let testSport = scoreboard[kScoreboardSportKey]
                let testState = scoreboard[kScoreboardStateNameKey]
                let testEntityId = scoreboard[kScoreboardEntityIdKey]
                
                if ((gender == testGender) && (sport == testSport) && (state == testState) && (entityId == testEntityId))
                {
                    duplicateFound = true
                    break
                }
            }
        }
        
        return duplicateFound
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addScoreboardButtonTouched(_ sender: UIButton)
    {
        if (self.checkForDuplicateScoreboards() == true)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Duplicate Scoreboard", message: "This scoreboard already exists.", lastItemCancelType: false) { tag in
                
            }
            return
        }
        
        /*
         let kScoreboardDefaultNameKey = "scoreboardDefaultName"         // String
         let kScoreboardAliasNameKey = "scoreboardAliasName"             // String
         let kScoreboardGenderKey = "scoreboardGender"                   // String
         let kScoreboardSportKey = "scoreboardSport"                     // String
         let kScoreboardStateNameKey = "scoreboardStateName"             // String
         let kScoreboardStateCodeKey = "scoreboardStateCode"              // String
         let kScoreboardEntityIdKey = "scoreboardEntityId"               // String
         let kScoreboardEntityNameKey = "scoreboardEntityName"           // String
         let kScoreboardDivisionTypeKey = "scoreboardDivisionType"       // String
         let kScoreboardSectionNameKey = "scoreboardSectionName"         // String
         let kScoreboardArrayKey = "scoreboardArray"                     // Array
         */
        
        // Save the scoreboard to prefs
        var existingScoreboards = kUserDefaults.array(forKey: kUserScoreboardsArrayKey)
        existingScoreboards?.append(selectedMetro)
        kUserDefaults.setValue(existingScoreboards, forKey: kUserScoreboardsArrayKey)
        
        // Call Branch event tracking
        let userType = kUserDefaults.string(forKey: kUserTypeKey)!
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        let event = BranchEvent.customEvent(withName:"SCOREBOARD_CREATED")
        event.customData["userId"] = userId
        event.customData["userRole"] = userType
        event.alias = "SCOREBOARD CREATED"
        event.logEvent()
            
        self.navigationController?.popViewController(animated: true)

    }
    
    @IBAction func extraMetroButtonTouched(_ sender: UIButton)
    {
        // Open the metro selector VC
        if (metroSelectorVC != nil)
        {
            metroSelectorVC = nil
        }
        
        metroSelectorVC = MetroSelectorViewController(nibName: "MetroSelectorViewController", bundle: nil)
        
        metroSelectorVC.selectedState = selectedState
        metroSelectorVC.selectedSport = selectedSport
        metroSelectorVC.selectedGender = selectedGender
        metroSelectorVC.selectedMetro = selectedMetro
        
        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(metroSelectorVC, animated: true)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        containerView.frame = CGRect(x: 0.0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height)
        bottomContainerView.frame = CGRect(x: 0.0, y: containerView.frame.size.height - 120 - CGFloat(SharedData.bottomSafeAreaHeight), width: containerView.frame.size.width, height: 120 + CGFloat(SharedData.bottomSafeAreaHeight))
        
        stateContainerView.isHidden = true
        metroContainerView.isHidden = true
        bottomContainerView.isHidden = true
       
        // Add a border to the metroTextFieldBackgound to match the border of the other textFields
        let scale = UIScreen.main.scale
        metroTextFieldBackground.layer.cornerRadius = 5
        metroTextFieldBackground.layer.borderWidth = 1 / scale // This thins out the border to match
        metroTextFieldBackground.layer.borderColor = UIColor(white: 194.0/255.0, alpha: 1).cgColor
        metroTextFieldBackground.clipsToBounds = true
        
        saveScorebordButton.layer.cornerRadius = 8
        saveScorebordButton.clipsToBounds = true
        
        // Add a shadow to the bottomContainerView
        let shadowPath = UIBezierPath(rect: bottomContainerView.bounds)
        bottomContainerView.layer.masksToBounds = false
        bottomContainerView.layer.shadowColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        bottomContainerView.layer.shadowOffset = CGSize(width: 0, height: -3)
        bottomContainerView.layer.shadowOpacity = 0.5
        bottomContainerView.layer.shadowPath = shadowPath.cgPath        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
        
        // Uodate the selectedMetro object if returning from the metro selector
        if (metroSelectorVC != nil)
        {
            let name = metroSelectorVC.selectedMetro[kScoreboardDefaultNameKey] as! String
            
            // Check if the type has be set to "metro"
            if ((name != "national") && (name != "state"))
            {
                // Update the screen and the selectedMetro object
                selectedMetro = metroSelectorVC.selectedMetro
                    
                let aliasName = selectedMetro[kScoreboardAliasNameKey] as! String
                let entityName = selectedMetro[kScoreboardEntityNameKey] as! String
                let stateCode = selectedMetro[kScoreboardStateCodeKey] as! String
 
                metroTextField.text = "(" + aliasName + ") " + entityName
                bottomContainerTitleLabel.text = stateCode + " " + aliasName + " - " + entityName
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (metroSelectorVC != nil)
        {
            metroSelectorVC = nil
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
