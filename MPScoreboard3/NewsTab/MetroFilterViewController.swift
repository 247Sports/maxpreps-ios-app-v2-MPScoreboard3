//
//  MetroFilterViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 1/13/22.
//

import UIKit

protocol MetroFilterViewControllerDelegate: AnyObject
{
    func metroFilterViewControllerStateSeasonArrayChanged(stateSeasonArray: Array<Dictionary<String,Any>>, statsViewIsParent: Bool)
}

class MetroFilterViewController: UIViewController, UITextFieldDelegate, IQActionSheetPickerViewDelegate
{
    weak var delegate: MetroFilterViewControllerDelegate!
    
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var seasonTextField: UITextField!
    @IBOutlet weak var metroTextField: UITextField!
    @IBOutlet weak var metroTitleLabel: UILabel!
    @IBOutlet weak var metroTextFieldBackground: UIView!
    @IBOutlet weak var metroCoverView: UIView!
    @IBOutlet weak var metroContainerView: UIView!
    @IBOutlet weak var teamSizeContainerView: UIView!
    @IBOutlet weak var teamSizeTextField: UITextField!
    
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var resetFilterButton: UIButton!
    @IBOutlet weak var applyFilterButton: UIButton!
    
    var selectedGender = ""
    var selectedSport = ""
    var selectedState = ""
    var selectedYear = ""
    var selectedSeason = ""
    var selectedMetroAliasName = ""
    var selectedMetroEntityName = ""
    var selectedMetroEntityId = ""
    var selectedMetroDivisionType = ""
    var selectedTeamSize = "11"
    var selectedSeasonIndex = 0
    var showDma = false
    var showLeague = false
    var showTeamSize = false
    var statsViewIsParent = false
    var titleString = ""
    
    var allSeasons = [] as! Array<Dictionary<String,Any>>
    var stateSeasons = [] as! Array<Dictionary<String,Any>>
    
    //private var eightManMode = false
    private var metroSelectorVC: MetroFilterSelectorViewController!
    
    let kNationalTeamsName = "National"
    
    // MARK: - Get State Seasons Method
    
    private func getStateSeasons()
    {
        NewFeeds.getStateCompetitiveSeasons(state: selectedState) { result, error in
            
            if (error == nil)
            {
                print("Get State Sport Seasons Success")
                
                // Refactor this feed so the data structure looks like the national allSeasonsArray
                var unsortedSeasonsArray = [] as! Array<Dictionary<String,Any>>
                for team in result!
                {
                    let gender = team["gender"] as! String
                    let sport = team["sport"] as! String
                    let isPublished = team["isPublished"] as! NSNumber
                    
                    if ((gender == self.selectedGender) && (sport == self.selectedSport) && (isPublished.boolValue == true))
                    {
                        let year = team["year"] as! String
                        let season = team["season"] as! String
                        let name = String(format: "%@ %@", season, year)
                        let obj = ["name":name, "season":season, "year":year]
                        unsortedSeasonsArray.append(obj)
                    }
                }
                
                if (unsortedSeasonsArray.count > 0)
                {
                    //let sortedSeasonsArray = (unsortedSeasonsArray as NSArray).sortedArray(using: [NSSortDescriptor(key: "year", ascending: false)]) as! [[String:AnyObject]]
                    
                    self.stateSeasons = (unsortedSeasonsArray as NSArray).sortedArray(using: [NSSortDescriptor(key: "year", ascending: false)]) as! [[String:AnyObject]]
                    
                    let latestSeason = self.stateSeasons[0]
                    let latestName = latestSeason["name"] as! String
                    self.seasonTextField.text = latestName
                    
                    self.selectedSeason = latestSeason["season"] as! String
                    self.selectedYear = latestSeason["year"] as! String
                    
                    self.selectedMetroAliasName = ""
                    self.selectedMetroEntityName = ""
                    self.selectedMetroEntityId = ""
                    self.selectedMetroDivisionType = ""
                    
                    self.metroTextField.text = ""
                    
                    // Update the stateArrays at the parent to keep everything synchronized
                    self.delegate.metroFilterViewControllerStateSeasonArrayChanged(stateSeasonArray: self.stateSeasons, statsViewIsParent: self.statsViewIsParent)
                    
                    print("Refactored")
                }
                else
                {
                    let message = String(format: "%@ %@ is not played in %@", self.selectedGender, self.selectedSport, self.selectedState)
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: message, lastItemCancelType: false) { [self] tag in
                        
                        // Rest the state to national
                        self.stateTextField.text = kNationalTeamsName
                        self.selectedState = kNationalTeamsName
                        self.selectedMetroAliasName = ""
                        self.selectedMetroEntityName = ""
                        self.selectedMetroEntityId = ""
                        self.selectedMetroDivisionType = ""
                        
                        self.metroCoverView.isHidden = false
                        self.metroTextField.text = ""
                        self.metroTitleLabel.textColor = UIColor.mpLightGrayColor()
                        
                        self.selectedSeasonIndex = 0
                        let selectedSeasonObj = self.allSeasons[0]
                        self.seasonTextField.text = (selectedSeasonObj["name"] as! String)
                        self.selectedSeason = selectedSeasonObj["season"] as! String
                        self.selectedYear = selectedSeasonObj["year"] as! String
                        
                    }
                }
                
                
            }
            else
            {
                print("Get State Sport Seasons Failed")
            }
        }
    }
    
    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelectTitles titles: [String])
    {
        if (pickerView.tag == 1)
        {
            // Skip if nothing changed
            if (titles.first == selectedState)
            {
                return
            }
            
            stateTextField.text = titles.first
            metroTextField.text = ""
            
            selectedSeasonIndex = 0
            selectedState = titles.first!
            selectedMetroAliasName = ""
            selectedMetroEntityName = ""
            selectedMetroEntityId = ""
            selectedMetroDivisionType = ""
            
            if (selectedState != kNationalTeamsName)
            {
                metroCoverView.isHidden = true
                metroTitleLabel.textColor = UIColor.mpBlackColor()
                
                // Get the seasons for the selected state
                self.getStateSeasons()
            }
            else
            {
                metroCoverView.isHidden = false
                metroTitleLabel.textColor = UIColor.mpLightGrayColor()
            }
        }
        else if (pickerView.tag == 2)
        {
            seasonTextField.text = titles.first
            
            if (selectedState == kNationalTeamsName)
            {
                var seasonYears = [] as! Array<String>
                for season in allSeasons
                {
                    let name = season["name"] as! String
                    seasonYears.append(name)
                }
                
                selectedSeasonIndex = seasonYears.firstIndex(of: titles.first!)!
                
                let selectedSeasonObj = allSeasons[selectedSeasonIndex]
                selectedSeason = selectedSeasonObj["season"] as! String
                selectedYear = selectedSeasonObj["year"] as! String
                
                selectedMetroAliasName = ""
                selectedMetroEntityName = ""
                selectedMetroEntityId = ""
                selectedMetroDivisionType = ""
                
                metroTextField.text = ""
            }
            else
            {
                var seasonYears = [] as! Array<String>
                for season in stateSeasons
                {
                    let name = season["name"] as! String
                    seasonYears.append(name)
                }
                
                selectedSeasonIndex = seasonYears.firstIndex(of: titles.first!)!
                
                let selectedSeasonObj = stateSeasons[selectedSeasonIndex]
                selectedSeason = selectedSeasonObj["season"] as! String
                selectedYear = selectedSeasonObj["year"] as! String
                
                selectedMetroAliasName = ""
                selectedMetroEntityName = ""
                selectedMetroEntityId = ""
                selectedMetroDivisionType = ""
                
                metroTextField.text = ""
            }
        }
        else if (pickerView.tag == 3)
        {
            teamSizeTextField.text = titles.first
            
            if (teamSizeTextField.text == "6/8/9 Man")
            {
                selectedTeamSize = "8"
            }
            else
            {
                selectedTeamSize = "11"
            }
        }
    }
    
    func actionSheetPickerViewDidCancel(_ pickerView: IQActionSheetPickerView)
    {
        
    }
    
    // MARK: - UITextField Delgates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if (textField == stateTextField)
        {
            var namesArray = kStateNamesArray
            namesArray.insert(kNationalTeamsName, at: 0)
            
            let picker = IQActionSheetPickerView(title: "Select State", delegate: self)
            //picker.toolbarButtonColor = UIColor.mpWhiteColor()
            //picker.toolbarTintColor = UIColor.mpPickerToolbarColor()
            picker.toolbarButtonColor = UIColor.mpDarkGrayColor()
            picker.toolbarTintColor = UIColor.mpGrayButtonBorderColor()
            picker.titlesForComponents = [namesArray]
            picker.tag = 1
            //picker.show(inVC: self)
            picker.show()

            return false
        }
        else if (textField == seasonTextField)
        {
            var seasonYears = [] as! Array<String>
            
            if (selectedState == kNationalTeamsName)
            {
                if (allSeasons.count > 0)
                {
                    for season in allSeasons
                    {
                        let name = season["name"] as! String
                        seasonYears.append(name)
                    }
                    
                    let picker = IQActionSheetPickerView(title: "Select Year", delegate: self)
                    //picker.toolbarButtonColor = UIColor.mpWhiteColor()
                    //picker.toolbarTintColor = UIColor.mpPickerToolbarColor()
                    picker.toolbarButtonColor = UIColor.mpDarkGrayColor()
                    picker.toolbarTintColor = UIColor.mpGrayButtonBorderColor()
                    picker.titlesForComponents = [seasonYears]
                    picker.tag = 2
                    //picker.show(inVC: self)
                    picker.show()
                }
                else
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "There was an error retriving available years from the server.", lastItemCancelType: false) { (tag) in
                    }
                }
            }
            else
            {
                if (stateSeasons.count > 0)
                {
                    for season in stateSeasons
                    {
                        let name = season["name"] as! String
                        seasonYears.append(name)
                    }
                    
                    let picker = IQActionSheetPickerView(title: "Select Year", delegate: self)
                    //picker.toolbarButtonColor = UIColor.mpWhiteColor()
                    //picker.toolbarTintColor = UIColor.mpPickerToolbarColor()
                    picker.toolbarButtonColor = UIColor.mpDarkGrayColor()
                    picker.toolbarTintColor = UIColor.mpGrayButtonBorderColor()
                    picker.titlesForComponents = [seasonYears]
                    picker.tag = 2
                    //picker.show(inVC: self)
                    picker.show()
                }
                else
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "There was an error retriving available years from the server.", lastItemCancelType: false) { (tag) in
                    }
                }
            }
            
            
            return false
        }
        else if (textField == teamSizeTextField)
        {
            let picker = IQActionSheetPickerView(title: "Select Team Size", delegate: self)
            //picker.toolbarButtonColor = UIColor.mpWhiteColor()
            //picker.toolbarTintColor = UIColor.mpPickerToolbarColor()
            picker.toolbarButtonColor = UIColor.mpDarkGrayColor()
            picker.toolbarTintColor = UIColor.mpGrayButtonBorderColor()
            picker.titlesForComponents = [["11 Man", "6/8/9 Man"]]
            picker.tag = 3
            //picker.show(inVC: self)
            picker.show()
            
            return false
        }
        else
        {
            // Open the metro selector VC
            if (metroSelectorVC != nil)
            {
                metroSelectorVC = nil
            }
            
            metroSelectorVC = MetroFilterSelectorViewController(nibName: "MetroFilterSelectorViewController", bundle: nil)
            
            metroSelectorVC.selectedState = selectedState
            metroSelectorVC.selectedSport = selectedSport
            metroSelectorVC.selectedGender = selectedGender
            metroSelectorVC.selectedYear = selectedYear
            metroSelectorVC.selectedSeason = selectedSeason
            metroSelectorVC.showDma = showDma
            metroSelectorVC.showLeague = showLeague

            self.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(metroSelectorVC, animated: true)
            return false
        }        
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetFilterButtonTouched(_ sender: UIButton)
    {
        stateTextField.text = kNationalTeamsName
        selectedState = kNationalTeamsName
        selectedMetroAliasName = ""
        selectedMetroEntityName = ""
        selectedMetroEntityId = ""
        selectedMetroDivisionType = ""
        
        metroCoverView.isHidden = false
        metroTextField.text = ""
        metroTitleLabel.textColor = UIColor.mpLightGrayColor()
        
        selectedSeasonIndex = 0
        let selectedSeasonObj = allSeasons[0]
        seasonTextField.text = (selectedSeasonObj["name"] as! String)
        selectedSeason = selectedSeasonObj["season"] as! String
        selectedYear = selectedSeasonObj["year"] as! String
    }
    
    @IBAction func applyFilterButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func extraMetroButtonTouched(_ sender: UIButton)
    {
        // Open the metro selector VC
        if (metroSelectorVC != nil)
        {
            metroSelectorVC = nil
        }
        
        metroSelectorVC = MetroFilterSelectorViewController(nibName: "MetroFilterSelectorViewController", bundle: nil)
        
        metroSelectorVC.selectedState = selectedState
        metroSelectorVC.selectedSport = selectedSport
        metroSelectorVC.selectedGender = selectedGender
        metroSelectorVC.selectedYear = selectedYear
        metroSelectorVC.selectedSeason = selectedSeason

        self.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(metroSelectorVC, animated: true)
    }
    
    @IBAction func eightManButtonTouched(_ sender: UIButton)
    {
        /*
        eightManMode = !eightManMode
        
        if (eightManMode == true)
        {
            eightManButton.setImage(UIImage(named: "CheckBoxBlue"), for: .normal)
            selectedTeamSize = "8"
        }
        else
        {
            eightManButton.setImage(UIImage(named: "CheckBoxOff"), for: .normal)
            selectedTeamSize = "11"
        }
        */
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        titleLabel.text = titleString
                
        stateTextField.text = selectedState
        
        if (selectedState != kNationalTeamsName)
        {
            metroCoverView.isHidden = true
            metroTitleLabel.textColor = UIColor.mpBlackColor()
        }
        else
        {
            metroCoverView.isHidden = false
            metroTitleLabel.textColor = UIColor.mpLightGrayColor()
        }
        
        if (selectedState == kNationalTeamsName)
        {
            // Use the allSeasonsArray
            if (allSeasons.count > 0)
            {
                let latestSeason = allSeasons[selectedSeasonIndex]
                let name = latestSeason["name"] as! String
                seasonTextField.text = name
                
                selectedSeason = latestSeason["season"] as! String
                selectedYear = latestSeason["year"] as! String
            }
            else
            {
                seasonTextField.text = ""
            }
        }
        else
        {
            // Use the stateSeasonsArray
            if (stateSeasons.count > 0)
            {
                let latestSeason = stateSeasons[selectedSeasonIndex]
                let name = latestSeason["name"] as! String
                seasonTextField.text = name
                
                selectedSeason = latestSeason["season"] as! String
                selectedYear = latestSeason["year"] as! String
            }
            else
            {
                seasonTextField.text = ""
            }
        }
        
        if ((selectedMetroAliasName != "") && (selectedMetroEntityName != ""))
        {
            metroTextField.text = String(format: "(%@) %@", selectedMetroAliasName, selectedMetroEntityName)
        }
        
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        containerView.frame = CGRect(x: 0.0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height)
        bottomContainerView.frame = CGRect(x: 0.0, y: containerView.frame.size.height - 76 - CGFloat(SharedData.bottomSafeAreaHeight), width: containerView.frame.size.width, height: 76 + CGFloat(SharedData.bottomSafeAreaHeight))
        
        //stateContainerView.isHidden = true
        //metroContainerView.isHidden = true
        //bottomContainerView.isHidden = true
       
        // Add a border to the metroTextFieldBackgound to match the border of the other textFields
        let scale = UIScreen.main.scale
        metroTextFieldBackground.layer.cornerRadius = 5
        metroTextFieldBackground.layer.borderWidth = 1 / scale // This thins out the border to match
        metroTextFieldBackground.layer.borderColor = UIColor(white: 194.0/255.0, alpha: 1).cgColor
        metroTextFieldBackground.clipsToBounds = true
        
        resetFilterButton.layer.cornerRadius = resetFilterButton.frame.size.height / 2.0
        resetFilterButton.layer.borderWidth = 1
        resetFilterButton.layer.borderColor = UIColor.mpRedColor().cgColor
        resetFilterButton.clipsToBounds = true
        
        applyFilterButton.layer.cornerRadius = applyFilterButton.frame.size.height / 2.0
        applyFilterButton.clipsToBounds = true
        
        let buttonWidth = (kDeviceWidth - 52) / 2.0
        resetFilterButton.frame = CGRect(x: 20, y: resetFilterButton.frame.origin.y, width: buttonWidth, height: resetFilterButton.frame.size.height)
        applyFilterButton.frame = CGRect(x: 32 + buttonWidth, y: applyFilterButton.frame.origin.y, width: buttonWidth, height: applyFilterButton.frame.size.height)
        
        // Add a shadow to the bottomContainerView
        let shadowPath = UIBezierPath(rect: bottomContainerView.bounds)
        bottomContainerView.layer.masksToBounds = false
        bottomContainerView.layer.shadowColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        bottomContainerView.layer.shadowOffset = CGSize(width: 0, height: -3)
        bottomContainerView.layer.shadowOpacity = 0.5
        bottomContainerView.layer.shadowPath = shadowPath.cgPath
        
        // Show the eight man button if football
        if ((selectedSport == "Football") && (showTeamSize == true))
        {
            teamSizeContainerView.isHidden = false
            metroContainerView.center = CGPoint(x: metroContainerView.center.x, y: metroContainerView.center.y + 70.0)
        }
        else
        {
            teamSizeContainerView.isHidden = true
        }

    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
                
        
        // Uodate the selectedMetro object if returning from the metro selector
        if (metroSelectorVC != nil)
        {
            /*
                 - key : "scoreboardStateName"
                 - value : ""
                 - key : "scoreboardAliasName"
                 - value : "National"
                 - key : "scoreboardSport"
                 - value : "Basketball"
                 - key : "scoreboardStateCode"
                 - value : ""
                 - key : "scoreboardEntityId"
                 - value : ""
                 - key : "scoreboardEntityName"
                 - value : ""
                 - key : "scoreboardDefaultName"
                 - value : "National"
                 - key : "scoreboardDivisionType"
                 - value : ""
                 - key : "scoreboardGender"
                 - value : "Boys"
                 - key : "scoreboardSectionName"
                 - value : ""
             */
            
            // The selectedMetro object may not have been set if the user hit the back button or just selected the state/national setting
            let name = metroSelectorVC.selectedMetro[kScoreboardDefaultNameKey] as? String ?? ""
            
            // Check if the name has be set to "metro"
            if ((name != "") && (name != "state") && (name != "national"))
            {
                selectedMetroAliasName = metroSelectorVC.selectedMetro[kScoreboardAliasNameKey] as! String
                selectedMetroEntityName = metroSelectorVC.selectedMetro[kScoreboardEntityNameKey] as! String
                selectedMetroEntityId = metroSelectorVC.selectedMetro[kScoreboardEntityIdKey] as! String
                selectedMetroDivisionType = metroSelectorVC.selectedMetro[kScoreboardDivisionTypeKey] as! String
                
                // Update the screen
                metroTextField.text = String(format: "(%@) %@", selectedMetroAliasName, selectedMetroEntityName)
                metroTitleLabel.textColor = UIColor.mpBlackColor()
            }
            else
            {
                metroTextField.text = ""
                metroTitleLabel.textColor = UIColor.mpLightGrayColor()
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
