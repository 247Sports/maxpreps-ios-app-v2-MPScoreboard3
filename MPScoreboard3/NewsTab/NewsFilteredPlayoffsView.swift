//
//  NewsFilteredPlayoffsView.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/10/23.
//

import UIKit

protocol NewsFilteredPlayoffsViewDelegate: AnyObject
{
    func newsFilterPlayoffsViewBracketTouched(urlString: String)
}

class NewsFilteredPlayoffsView: UIView, UITextFieldDelegate, IQActionSheetPickerViewDelegate, UITableViewDelegate, UITableViewDataSource
{
    weak var delegate: NewsFilteredPlayoffsViewDelegate?

    private var stateTextField: UITextField!
    private var seasonTextField: UITextField!
    private var playoffsTableView: UITableView!
    private var emptyBracketsLabel: UILabel!
    
    private var selectedStateIndex = 0
    private var selectedState = ""
    private var selectedYear = ""
    private var selectedSeason = ""
    private var genderCopy = ""
    private var sportCopy = ""
    private var ftagCopy = ""
    private var trackingGuid = ""
    
    private var statesArray: Array<Dictionary<String,Any>> = []
    private var seasonYearArray: Array<String> = []
    private var bracketsArray: Array<Dictionary<String,Any>> = []
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Get State Seasons
     
    private func getSportSeasons(gender: String, sport: String)
    {
        NewFeeds.getSportsArenaPlayoffStateSeasons(gender: gender, sport: sport) { result, error in

            if (error == nil)
            {
                print("Get State Seasons Success")
                self.statesArray = result!["states"] as! Array<Dictionary<String,Any>>
                
                if (self.statesArray.count > 0)
                {
                    let zipCode = kUserDefaults.string(forKey: kUserZipKey)
                    let usersZipCodeState = ZipCodeHelper.state(forZipCode: zipCode)
                    
                    // Check if there is a match betwween the user's zip code state and any of the stateCodes in the array to get an initial index
                    var index = 0
                    for dict in self.statesArray
                    {
                        let stateCode = dict["stateCode"] as! String
                        
                        if (stateCode == usersZipCodeState)
                        {
                            self.selectedStateIndex = index
                            break
                        }
                        index += 1
                    }
                    
                    // load the textFields and variables
                    let stateDict = self.statesArray[self.selectedStateIndex]
                    let stateName = stateDict["name"] as! String
                    self.stateTextField.text = stateName
                    self.selectedState = stateName
                    
                    // Build the seasonYearArray
                    let seasons = stateDict["seasons"] as! Array<Dictionary<String,String>>
                    
                    for season in seasons
                    {
                        let seasonName = season["season"]
                        let yearName = season["year"]
                        let seasonYear = String(format: "%@ %@", seasonName!, yearName!)
                        self.seasonYearArray.append(seasonYear)
                    }
                    
                    if (self.seasonYearArray.count > 0)
                    {
                        self.seasonTextField.text = self.seasonYearArray[0]
                        let seasonsArray = self.seasonTextField.text!.components(separatedBy: " ")
                        if (seasonsArray.count == 2)
                        {
                            self.selectedSeason = seasonsArray.first!
                            self.selectedYear = seasonsArray.last!
                        }
                    }
                    
                    self.getPlayoffBrackets()
                }
            }
            else
            {
                print("Get State Seasons Failed")
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "An error occured when retrieving the available seasons for this sport.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - Get Brackets
    
    private func getPlayoffBrackets()
    {
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.getSportsArenaPlayoffBrackets(gender: genderCopy, sport: sportCopy, state: selectedState, season: selectedSeason, year: selectedYear) { [self] result, error in
            
            // Hide the busy indicator
            DispatchQueue.main.async
            {
                if (self.progressOverlay != nil)
                {
                    self.progressOverlay.hide(animated: false)
                    self.progressOverlay = nil
                }
            }
            
            if (error == nil)
            {
                print("Get Brackets Success")
                
                self.bracketsArray = result!
                
                if (self.bracketsArray.count > 0)
                {
                    self.playoffsTableView.isHidden = false
                    self.emptyBracketsLabel.isHidden = true
                    self.playoffsTableView.reloadData()
                    
                    // Build the tracking context data object
                    var cData = kEmptyTrackingContextData
                
                    cData[kTrackingSportNameKey] = self.sportCopy
                    cData[kTrackingSportGenderKey] = self.genderCopy
                    cData[kTrackingSeasonKey] = selectedSeason
                    cData[kTrackingSchoolYearKey] = selectedYear
                    cData[kTrackingFtagKey] = self.ftagCopy
                    
                    TrackingManager.trackState(featureName: "sport-playoffs", trackingGuid: self.trackingGuid, cData: cData)
                }
                else
                {
                    self.playoffsTableView.isHidden = true
                    self.emptyBracketsLabel.isHidden = false
                }
            }
            else
            {
                print("Get Brackets Failed")
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "We're Sorry", message: "An error occured when retrieving the brackets for this sport.", lastItemCancelType: false) { tag in
                    
                }
                self.playoffsTableView.isHidden = true
                self.emptyBracketsLabel.isHidden = true
            }
        }
    }
    
    // MARK: - TextField Delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if (textField == stateTextField)
        {
            // Build an array of state names
            var stateNamesArray: Array<String> = []
            
            for stateDict in statesArray
            {
                let stateName = stateDict["name"] as? String ?? ""
                stateNamesArray.append(stateName)
            }

            let picker = IQActionSheetPickerView(title: "Select State", delegate: self)
            picker.toolbarButtonColor = UIColor.mpDarkGrayColor()
            picker.toolbarTintColor = UIColor.mpGrayButtonBorderColor()
            picker.titlesForComponents = [stateNamesArray]
            picker.tag = 1
            picker.show()

            return false
        }
        else
        {
            let picker = IQActionSheetPickerView(title: "Select Season", delegate: self)
            picker.toolbarButtonColor = UIColor.mpDarkGrayColor()
            picker.toolbarTintColor = UIColor.mpGrayButtonBorderColor()
            picker.titlesForComponents = [seasonYearArray]
            picker.tag = 2
            picker.show()

            return false
        }
    }
    
    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelectTitles titles: [String])
    {
        if (pickerView.tag == 1)
        {
            selectedState = titles.first!
            stateTextField.text = titles.first!
            
            // Update the selectedStateIndex
            var index = 0
            for dict in statesArray
            {
                let state = dict["name"] as! String
                
                if (state == selectedState)
                {
                    selectedStateIndex = index
                    break
                }
                index += 1
            }
            
            // Update the seasonYearsArray
            seasonYearArray.removeAll()
            
            let stateDict = statesArray[selectedStateIndex]
            let seasons = stateDict["seasons"] as! Array<Dictionary<String,String>>
            
            for season in seasons
            {
                let seasonName = season["season"]
                let yearName = season["year"]
                let seasonYear = String(format: "%@ %@", seasonName!, yearName!)
                seasonYearArray.append(seasonYear)
            }
            
            if (seasonYearArray.count > 0)
            {
                seasonTextField.text = seasonYearArray[0]
                
                let seasonsArray = seasonTextField.text!.components(separatedBy: " ")
                if (seasonsArray.count == 2)
                {
                    selectedSeason = seasonsArray.first!
                    selectedYear = seasonsArray.last!
                }
            }
        }
        else if (pickerView.tag == 2)
        {
            seasonTextField.text = titles.first
            
            let seasonsArray = titles.first!.components(separatedBy: " ")
            if (seasonsArray.count == 2)
            {
                selectedSeason = seasonsArray.first!
                selectedYear = seasonsArray.last!
            }
        }
        
        self.getPlayoffBrackets()
    }
    
    func actionSheetPickerViewDidCancel(_ pickerView: IQActionSheetPickerView)
    {
        
    }

    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return bracketsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let section = bracketsArray[section]
        let brackets = section["brackets"] as! Array<Dictionary<String,Any>>
        
        return brackets.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 48.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 84.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        if (section == (bracketsArray.count - 1))
        {
            return 16 + 62 // Ad pad
        }
        else
        {
            return 16
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        // Instantiate the header view
        let headerNib = Bundle.main.loadNibNamed("FilterPlayoffsHeaderViewCell", owner: self, options: nil)
        let headerView = headerNib![0] as? FilterPlayoffsHeaderViewCell
        headerView!.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: 84)
        
        let section = bracketsArray[section]
        let headerTitle = section["name"] as? String ?? ""
        headerView!.titleLabel.text = headerTitle
        
        let logoImageUrlString = section["logoImageUrl"] as? String ?? ""
        
        if (logoImageUrlString.count > 0)
        {
            // Get the data and make an image
            let url = URL(string: logoImageUrlString)
            
            SDWebImageManager.shared().downloadImage(with: url!, progress: { receivedSize, expectedSize in
                
            }, completed: { image, error, cacheType, finished, imageUrl in
                
                if (image != nil)
                {
                    headerView!.logoImageView.image = image!
                }
                else
                {
                    headerView!.logoImageView.image = UIImage(named: "TourneyLogo")
                }
            })
        }
        else
        {
            headerView!.logoImageView.image = UIImage(named: "TourneyLogo")
        }

        return headerView!
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 16))
        footerView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        
        let contentView = UIView(frame: CGRect(x: 20, y: 0, width: kDeviceWidth - 40, height: 16))
        contentView.backgroundColor = UIColor.mpWhiteColor()
        contentView.layer.cornerRadius = 12
        contentView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        contentView.clipsToBounds = true
        footerView.addSubview(contentView)
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {

        var cell = tableView.dequeueReusableCell(withIdentifier: "FilterPlayoffsTableViewCell") as? FilterPlayoffsTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("FilterPlayoffsTableViewCell", owner: self, options: nil)
            cell = nib![0] as? FilterPlayoffsTableViewCell
        }
        
        cell?.selectionStyle = .none
        
        let section = bracketsArray[indexPath.section]
        let brackets = section["brackets"] as! Array<Dictionary<String,Any>>
        let bracket = brackets[indexPath.row]
        let name = bracket["name"] as? String ?? "Unknown"
        
        cell?.titleLabel.text = name
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = bracketsArray[indexPath.section]
        let brackets = section["brackets"] as! Array<Dictionary<String,Any>>
        let bracket = brackets[indexPath.row]
        let urlString = bracket["canonicalUrl"] as? String ?? ""
        
        self.delegate?.newsFilterPlayoffsViewBracketTouched(urlString: urlString)
    }
    
    @objc private func testButtonTouched()
    {
        self.delegate?.newsFilterPlayoffsViewBracketTouched(urlString: "https://www.maxpreps.com/tournament/iiAa0th1EeyA0wqb9tl3hA/J4zUOth2EeyA0wqb9tl3hA/football-22/2022-uil-texas-football-state-championships-2022-football-conference-6a-d1.htm")
    }
    
    // MARK: - Init Method
    
    required init(frame: CGRect, gender: String, sport: String, ftag: String)
    {
        super.init(frame: frame)
        
        // Find fonts helper
        UIFont.familyNames.forEach({ familyName in
            let fontNames = UIFont.fontNames(forFamilyName: familyName)
            print(familyName, fontNames)
        })
        
        trackingGuid = NSUUID().uuidString
        
        genderCopy = gender
        sportCopy = sport
        ftagCopy = ftag
                
        self.backgroundColor = UIColor.mpWhiteColor()
        
        let horizLine = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 1))
        horizLine.backgroundColor = UIColor.mpOffWhiteNavColor()
        self.addSubview(horizLine)
        
        /*
        let dummyImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        dummyImageView.image = UIImage(named: "TestPlayoffs")
        self.addSubview(dummyImageView)
        
        let testButton = UIButton(type: .custom)
        testButton.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        testButton.setTitle("", for: .normal)
        testButton.addTarget(self, action: #selector(testButtonTouched), for: .touchUpInside)
        self.addSubview(testButton)
        */
        
        let titleLabel = UILabel(frame: CGRect(x: 16, y: 20, width: frame.size.width - 32, height: 26))
        titleLabel.textColor = UIColor.mpBlackColor()
        titleLabel.font = UIFont.mpBoldFontWith(size: 20)
        titleLabel.text = "Brackets"
        self.addSubview(titleLabel)
        
        let itemWidth = (frame.size.width - 48.0) / 2.0
        
        let stateTitleLabel = UILabel(frame: CGRect(x: 16, y: 62, width: itemWidth, height: 16))
        stateTitleLabel.textColor = UIColor.mpBlackColor()
        stateTitleLabel.font = UIFont.mpSemiBoldFontWith(size: 12)
        stateTitleLabel.text = "State"
        self.addSubview(stateTitleLabel)
        
        let seasonTitleLabel = UILabel(frame: CGRect(x: 32 + itemWidth, y: 62, width: itemWidth, height: 16))
        seasonTitleLabel.textColor = UIColor.mpBlackColor()
        seasonTitleLabel.font = UIFont.mpSemiBoldFontWith(size: 12)
        seasonTitleLabel.text = "Season"
        self.addSubview(seasonTitleLabel)
        
        stateTextField = UITextField(frame: CGRect(x: 16, y: 82, width: itemWidth, height: 34))
        stateTextField.delegate = self
        stateTextField.textColor = UIColor.mpBlackColor()
        stateTextField.font = UIFont.mpRegularFontWith(size: 14)
        stateTextField.borderStyle = .roundedRect
        stateTextField.text = ""
        stateTextField.placeholder = "Select"
        stateTextField.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        stateTextField.layer.borderWidth = 1
        stateTextField.layer.cornerRadius = 5
        stateTextField.clipsToBounds = true
        self.addSubview(stateTextField)
        
        seasonTextField = UITextField(frame: CGRect(x: 32 + itemWidth, y: 82, width: itemWidth, height: 34))
        seasonTextField.delegate = self
        seasonTextField.textColor = UIColor.mpBlackColor()
        seasonTextField.font = UIFont.mpRegularFontWith(size: 14)
        seasonTextField.borderStyle = .roundedRect
        seasonTextField.text = ""
        seasonTextField.placeholder = "Select"
        seasonTextField.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        seasonTextField.layer.borderWidth = 1
        seasonTextField.layer.cornerRadius = 5
        seasonTextField.clipsToBounds = true
        self.addSubview(seasonTextField)
        
        let stateDownArrow = UIImageView(frame: CGRect(x: itemWidth - 24.0, y: 9.0, width: 16.0, height: 16.0))
        stateDownArrow.image = UIImage(named: "DownArrowBlack")
        stateTextField.addSubview(stateDownArrow)
        
        let seasonDownArrow = UIImageView(frame: CGRect(x: itemWidth - 24.0, y: 9.0, width: 16.0, height: 16.0))
        seasonDownArrow.image = UIImage(named: "DownArrowBlack")
        seasonTextField.addSubview(seasonDownArrow)
        
        let horizLine2 = UIView(frame: CGRect(x: 0, y: 134, width: frame.size.width, height: 2))
        horizLine2.backgroundColor = UIColor.mpGrayButtonBorderColor()
        self.addSubview(horizLine2)
        
        emptyBracketsLabel = UILabel(frame: CGRect(x: 16, y: 156.0, width: frame.size.width - 32.0, height: 24.0))
        emptyBracketsLabel.font = UIFont.mpItalicFontWith(size: 17)
        emptyBracketsLabel.textColor = UIColor.mpBlackColor()
        emptyBracketsLabel.text = "No Brackets"
        self.addSubview(emptyBracketsLabel)
        emptyBracketsLabel.isHidden = true
        
        playoffsTableView = UITableView(frame: CGRect(x: 0, y: 136.0, width: frame.size.width, height: frame.size.height - 136.0), style: .grouped)
        playoffsTableView.delegate = self
        playoffsTableView.dataSource = self
        playoffsTableView.separatorStyle = .none
        playoffsTableView.backgroundColor = UIColor.mpHeaderBackgroundColor()
        self.addSubview(playoffsTableView)
        
        playoffsTableView.isHidden = true

        // Get the states and seasons
        self.getSportSeasons(gender: genderCopy, sport: sportCopy)
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
