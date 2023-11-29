//
//  UploadVideoAthleteSearchView.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/29/21.
//

import UIKit

protocol UploadVideoAthleteSearchViewDelegate: AnyObject
{
    func uploadVideoAthleteSearchDidSelectAthlete(selectedAthlete: Athlete, showSaveFavoriteButton: Bool, showRemoveFavoriteButton: Bool)
}

class UploadVideoAthleteSearchView: UIView, IQActionSheetPickerViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, SearchSportViewControllerDelegate
{
    weak var delegate: UploadVideoAthleteSearchViewDelegate?
    
    var parentVC: UIViewController!
        
    private var sportContainerView: UIView?
    private var sportPlaceholderLabel: UILabel?
    private var downArrowImageView: UIImageView?
    private var sportLabel: UILabel?
    private var sportIconImageView: UIImageView?
    private var selectSportButton: UIButton?
    
    private var searchContainerView: UIView?
    private var searchTextField: UITextField?
    private var searchIconImageView: UIImageView?
    
    private var searchTableView: UITableView!
    private var filterButton: UIButton!
    
    private var allAthletesArray = Array<Dictionary<String,Any>>()
    private var filteredAthletesArray = Array<Dictionary<String,Any>>()
    private var favoriteAthletesIdentifierArray = [] as Array
    
    private var trackingGuid = ""
    
    let kDefaultFilterState = "All States"
    
    private var searchSportVC: SearchSportViewController!
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Filter Athletes
    
    private func filterAthletes()
    {
        filteredAthletesArray.removeAll()
        
        // All States case
        if (filterButton.titleLabel?.text == kDefaultFilterState)
        {
            filteredAthletesArray = allAthletesArray
            searchTableView.isHidden = false
            searchTableView.reloadData()
        }
        else
        {
            // Only gather athletes from the matching state
            for athlete in allAthletesArray
            {
                let state = athlete["schoolState"] as! String
                
                if (filterButton.titleLabel?.text == state)
                {
                    filteredAthletesArray.append(athlete)
                }
            }
            searchTableView.isHidden = false
            searchTableView.reloadData()
        }
    }
    
    // MARK: - Search for Athlete
    
    private func searchForAthlete()
    {
        self.allAthletesArray = []
        searchTableView.isHidden = true
        self.searchTableView.reloadData()
        
        // Show the busy indicator
        //MBProgressHUD.showAdded(to: self, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        let sportArray = sportLabel!.text!.split(separator: " ", maxSplits: 1)
        
        if (sportArray.count == 2)
        {
            let gender = String(sportArray.first!)
            let sport = String(sportArray.last!)
            
            var state = "" // This means national in the API
            if (filterButton.titleLabel?.text != kDefaultFilterState)
            {
                state = (filterButton.titleLabel?.text?.lowercased())!
            }
            
            NewFeeds.searchForAthlete(name:searchTextField!.text!, gender:gender, sport:sport, state: state) { (athletes, error) in
                
                // Hide the busy indicator
                DispatchQueue.main.async
                {
                    //MBProgressHUD.hide(for: self, animated: true)
                    if (self.progressOverlay != nil)
                    {
                        self.progressOverlay.hide(animated: false)
                        self.progressOverlay = nil
                    }
                }
                
                if (error == nil)
                {
                    print("Search Done")
                    
                    if (athletes!.count == 0)
                    {
                        MiscHelper.showAlert(in: self.parentVC!, withActionNames: ["OK"], title: "Search Result", message: "No matches were found for that sport.", lastItemCancelType: false) { (tag) in
                            
                        }
                    }
                    else
                    {
                        self.allAthletesArray = athletes!
                        
                        // Filter the athletes
                        //self.filterAthletes()
                    }
                    
                    self.searchTableView.isHidden = false
                    self.searchTableView.reloadData()
                    
                    // Tracking
                    TrackingManager.trackState(featureName: "search-athletes-results", trackingGuid: self.trackingGuid, cData: kEmptyTrackingContextData)
                }
                else
                {
                    MiscHelper.showAlert(in: self.parentVC!, withActionNames: ["OK"], title: "We're Sorry", message: "The search returned a server error", lastItemCancelType: false) { (tag) in
                        
                    }
                }
            }
        }
        
    }
    
    // MARK: - Reload Athlete Table
    
    func reloadAthleteTable()
    {
        // Build the favorite athlete identifier array so a star can be put next to each favorite team
        favoriteAthletesIdentifierArray.removeAll()
        
        // Get the favorite athletes
        if let favoriteAthletes = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
        {
            for favoriteAthlete in favoriteAthletes
            {
                let item = favoriteAthlete  as! Dictionary<String, Any>
                let careerProfileId = item["careerProfileId"] as! String
                            
                favoriteAthletesIdentifierArray.append(careerProfileId)
            }
        }
        
        searchTableView.reloadData()
    }
    
    // MARK: - TextField Delegates
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()

        if (searchTextField!.text!.count == 0)
        {
            MiscHelper.showAlert(in: parentVC!, withActionNames: ["OK"], title: "Missing Info", message: "You must enter the name of the athlete.", lastItemCancelType: false) { (tag) in
                
            }
        }
        else
        {
            self.searchForAthlete()
        }

        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
        return true
    }

    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelectTitles titles: [String])
    {
        
        let title = titles.first
        
        if (pickerView.tag == 100)
        {
            // Skip if the sport didn't change
            if (sportLabel?.text == title)
            {
                return
            }
            
            sportPlaceholderLabel?.isHidden = true
            downArrowImageView?.isHidden = true
            sportLabel?.isHidden = false
            sportIconImageView?.isHidden = false
            searchContainerView?.isHidden = false
            
            sportLabel?.text = title
            
            // Extract the sport from the title
            let sportArray = title!.split(separator: " ", maxSplits: 1)
            
            if (sportArray.count == 2)
            {
                let sport = String(sportArray.last!)
                
                sportIconImageView!.image = MiscHelper.getImageForSport(sport)
            }
            
            allAthletesArray.removeAll()
            filteredAthletesArray.removeAll()
            searchTableView.isHidden = true
            searchTableView.reloadData()
        }
        else
        {
            filterButton.setTitle(title, for: .normal)
            
            // Filter the athletes
            //self.filterAthletes()
            self.searchForAthlete()
        }
        
    }
    
    func actionSheetPickerViewDidCancel(_ pickerView: IQActionSheetPickerView)
    {
        
    }
    
    // MARK: - SearchSportViewController Delegates
    
    func searchSportCancelButtonTouched()
    {
        parentVC!.dismiss(animated: true)
        {
            
        }
    }
    
    func searchSportSelectButtonTouched()
    {
        let sport = searchSportVC.selectedSport
        let gender = searchSportVC.selectedGender
        let title = gender + " " + sport
        
        // Skip if the sport didn't change
        if (sportLabel?.text == title)
        {
            parentVC!.dismiss(animated: true)
            {
                
            }
            return
        }
        
        sportPlaceholderLabel?.isHidden = true
        downArrowImageView?.isHidden = true
        sportLabel?.isHidden = false
        sportIconImageView?.isHidden = false
        searchContainerView?.isHidden = false
        
        sportLabel?.text = title
        sportIconImageView!.image = MiscHelper.getImageForSport(sport)
        
        allAthletesArray.removeAll()
        filteredAthletesArray.removeAll()
        searchTableView.isHidden = true
        searchTableView.reloadData()
        
        parentVC!.dismiss(animated: true)
        {
            
        }
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return allAthletesArray.count //filteredAthletesArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {

        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 44))
        view.backgroundColor = UIColor.mpWhiteColor()
        
        let label = UILabel(frame: CGRect(x: 16, y: 14, width: tableView.frame.size.width - 40, height: 30))
        label.font = UIFont.mpSemiBoldFontWith(size: 14)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.mpLightGrayColor()
        view.addSubview(label)
        
        //label.text = String(format: "RESULTS (%ld)", filteredAthletesArray.count)
        label.text = String(format: "RESULTS (%ld)", allAthletesArray.count)
            
        // Add the filterButton that were created at init
        filterButton.frame = CGRect(x: tableView.frame.size.width - 106, y: 14, width: 90, height: 30)
        view.addSubview(filterButton)
            
        return view
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "SearchAthleteTableViewCell") as? SearchAthleteTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("SearchAthleteTableViewCell", owner: self, options: nil)
            cell = nib![0] as? SearchAthleteTableViewCell
        }
        
        cell?.selectionStyle = .none
        cell?.starImageView.isHidden = true
        
        //let athlete = filteredAthletesArray[indexPath.row]
        let athlete = allAthletesArray[indexPath.row]
        var firstName = ""
        var fullName = ""
        let lastName = athlete["lastName"] as! String
        
        // Check for NULL first name
        if (athlete["firstName"] as? NSNull) != nil
        {
            fullName = lastName
        }
        else
        {
            firstName = athlete["firstName"] as! String
            fullName = firstName + " " + lastName
        }

        //let city = athlete["schoolCity"] as! String
        //let state = athlete["schoolState"] as! String
        let schoolFullName = athlete["schoolFormattedName"] as! String
        let careerId = athlete["careerId"] as! String
        
        cell?.schoolNameLabel.text = schoolFullName
        cell?.nameLabel.text = fullName
        
        // Add a year label on the right side of the cell
        let yearLabel = UILabel(frame: CGRect(x: ((tableView.frame.size.width - 32.0) / 2.0) + 16, y: 10, width: (tableView.frame.size.width - 32.0) / 2.0, height: 16.0))
        yearLabel.tag = 200 + indexPath.row
        yearLabel.textColor = UIColor.mpLightGrayColor()
        yearLabel.font = UIFont.mpRegularFontWith(size: 13)
        yearLabel.textAlignment = .right
        cell?.contentView.addSubview(yearLabel)
        
        // Get the sportYears or the gradeClass for the text (sportYears will be deprecated)
        if let gradeClass = athlete["gradeClass"] as? String
        {
            cell?.yearLabel.text = gradeClass
        }
        else
        {
            let sportYears = athlete["sportYears"] as! Array<Dictionary<String,Any>>
            let firstSport = sportYears.first!
            let years = firstSport["years"] as! Array<String>
            let joinedYears = years.joined(separator: ", ")
            cell?.yearLabel.text = joinedYears
        }
        
        // Add a star if the athlete is already a favorite
        let result = favoriteAthletesIdentifierArray.filter { $0 as! String == careerId }
        if (!result.isEmpty)
        {
            cell?.starImageView.isHidden = false
        }
        
        /*
        // Get the athlete's photo if the property is available
        if let photoUrl = athlete["photoUrl"] as? String
        {
            print("PhotoUrl: " + photoUrl)
        }
        */
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        

        // Refactor the athlete dictionary sinto an Athlete object
        
        //let athlete = filteredAthletesArray[indexPath.row]
        let athlete = allAthletesArray[indexPath.row]
        
        // Check for NULL first name
        let firstName = athlete["firstName"] as? String ?? ""
        let lastName = athlete["lastName"] as! String
        let schoolName = athlete["schoolName"] as! String
        let schoolId = athlete["schoolId"] as! String
        let schoolColor1 = athlete["schoolColor1"] as! String
        let schoolMascotUrl = athlete["schoolMascotUrl"] as! String
        let schoolCity = athlete["schoolCity"] as! String
        let schoolState = athlete["schoolState"] as! String
        let careerId = athlete["careerId"] as! String
        let photoUrl = athlete["photoUrl"] as? String ?? ""
        
        let selectedAthlete = Athlete(firstName: firstName, lastName: lastName, schoolName: schoolName, schoolState: schoolState, schoolCity: schoolCity, schoolId: schoolId, schoolColor: schoolColor1, schoolMascotUrl: schoolMascotUrl, careerId: careerId, photoUrl: photoUrl)
        
        var showSaveFavoriteButton = false
        var showRemoveFavoriteButton = false
        
        
        // Check to see if the athlete is already a favorite
        let result = favoriteAthletesIdentifierArray.filter { $0 as! String == careerId }
        
        if (result.isEmpty == false)
        {
            showSaveFavoriteButton = false
            showRemoveFavoriteButton = true
        }
        else
        {
            // Two paths depending on wheteher the user is logged in or not
            let userId = kUserDefaults.value(forKey: kUserIdKey) as! String
            
            if (userId != kTestDriveUserId)
            {
                showSaveFavoriteButton = true
                showRemoveFavoriteButton = false
            }
            else
            {
                showSaveFavoriteButton = false
                showRemoveFavoriteButton = false
            }
        }
        
        self.delegate?.uploadVideoAthleteSearchDidSelectAthlete(selectedAthlete: selectedAthlete, showSaveFavoriteButton: showSaveFavoriteButton, showRemoveFavoriteButton: showRemoveFavoriteButton)
        
    }
    
    // MARK: - Button Methods
    
    @objc func sportSelectorButtonTouched()
    {
        if (searchSportVC != nil)
        {
            searchSportVC = nil
        }
        
        searchSportVC = SearchSportViewController(nibName: "SearchSportViewController", bundle: nil)
        searchSportVC.delegate = self
        searchSportVC.showReducedSports = false
        searchSportVC.modalPresentationStyle = .overCurrentContext
        
        // Add this on top of everything
        parentVC!.present(searchSportVC, animated: true)
        {
            
        }
        
        /*
        let picker = IQActionSheetPickerView(title: "", delegate: self)
        picker.tag = 100
        picker.toolbarButtonColor = UIColor.mpWhiteColor()
        picker.toolbarTintColor = UIColor.mpPickerToolbarColor()
        picker.titlesForComponents = [kSearchGenderSportsArray]
        picker.show()
        */
    }
    
    @objc func filterButtonTouched(_ sender: UIButton)
    {
        var stateList = kStateShortNamesArray
        stateList.insert(kDefaultFilterState, at: 0)
        
        let picker = IQActionSheetPickerView(title: "", delegate: self)
        picker.tag = 101
        picker.toolbarButtonColor = UIColor.mpBlackColor()
        picker.toolbarTintColor = UIColor.mpOffWhiteNavColor()
        picker.titlesForComponents = [stateList]
        picker.show()
    }
    
    @objc func keyboardCancelButtonTouched(_ sender: UIButton)
    {
        searchTextField!.resignFirstResponder()
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let yScroll = Int(scrollView.contentOffset.y)
        
        if (yScroll < 0)
        {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
    }
    
    // MARK: - Init Method
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        trackingGuid = NSUUID().uuidString
        
        // Build the sportContainerView
        sportContainerView = UIView(frame: CGRect(x: 16, y: 20, width: CGFloat(kDeviceWidth - 32), height: 40))
        sportContainerView?.backgroundColor = UIColor.mpWhiteColor()
        sportContainerView?.layer.cornerRadius = 8
        sportContainerView?.layer.borderWidth = 1
        sportContainerView?.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        sportContainerView?.clipsToBounds = true
        self.addSubview(sportContainerView!)
        
        sportPlaceholderLabel = UILabel(frame: CGRect(x: 16, y: 11, width: (sportContainerView?.frame.size.width)! / 2.0, height: 18))
        sportPlaceholderLabel?.font = UIFont.mpRegularFontWith(size: 15)
        sportPlaceholderLabel?.textColor = UIColor.mpLightGrayColor()
        sportPlaceholderLabel?.text = "Select a Sport"
        sportContainerView?.addSubview(sportPlaceholderLabel!)
        
        downArrowImageView = UIImageView(frame: CGRect(x: (sportContainerView?.frame.size.width)! - 28, y: 17, width: 10, height: 6))
        downArrowImageView?.image = UIImage(named: "SmallDownArrowGray")
        sportContainerView?.addSubview(downArrowImageView!)
        
        sportIconImageView = UIImageView(frame: CGRect(x: 16, y: 10, width: 20, height: 20))
        sportContainerView?.addSubview(sportIconImageView!)
        sportIconImageView?.isHidden = true
        
        sportLabel = UILabel(frame: CGRect(x: 44, y: 11, width: (sportContainerView?.frame.size.width)! / 2.0, height: 18))
        sportLabel?.font = UIFont.mpRegularFontWith(size: 15)
        sportLabel?.textColor = UIColor.mpBlackColor()
        sportContainerView?.addSubview(sportLabel!)
        sportLabel?.isHidden = true
        
        selectSportButton = UIButton(type: .custom)
        selectSportButton?.frame = CGRect(x: 0, y: 0, width: (sportContainerView?.frame.size.width)!, height: (sportContainerView?.frame.size.height)!)
        selectSportButton?.addTarget(self, action: #selector(sportSelectorButtonTouched), for: .touchUpInside)
        sportContainerView?.addSubview(selectSportButton!)
        
        
        // Build the searchContainerView
        searchContainerView = UIView(frame: CGRect(x: 16, y: 68, width: CGFloat(kDeviceWidth - 32), height: 40))
        searchContainerView?.backgroundColor = UIColor.mpWhiteColor()
        searchContainerView?.layer.cornerRadius = 8
        searchContainerView?.layer.borderWidth = 1
        searchContainerView?.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        searchContainerView?.clipsToBounds = true
        self.addSubview(searchContainerView!)
        searchContainerView?.isHidden = true
        
        searchIconImageView = UIImageView(frame: CGRect(x: 16, y: 12, width: 16, height: 16))
        searchIconImageView?.image = UIImage(named: "SmallSearchIconGray")
        searchContainerView?.addSubview(searchIconImageView!)
        
        searchTextField = UITextField(frame: CGRect(x: 44, y: 3, width: (searchContainerView?.frame.size.width)! - 48, height: 34))
        searchTextField?.delegate = self
        searchTextField?.textColor = UIColor.mpBlackColor()
        searchTextField?.font = UIFont.mpRegularFontWith(size: 15)
        searchTextField?.placeholder = "Search by Full Name"
        searchTextField?.borderStyle = .none
        searchTextField?.backgroundColor = UIColor.mpWhiteColor()
        searchTextField?.returnKeyType = .search
        searchTextField?.keyboardType = .asciiCapable
        searchTextField?.autocorrectionType = .no
        searchTextField?.autocapitalizationType = .none
        searchTextField?.clearButtonMode = .whileEditing
        searchTextField?.smartQuotesType = .no
        searchTextField?.smartDashesType = .no
        searchTextField?.smartInsertDeleteType = .no
        searchTextField?.spellCheckingType = .no
        searchContainerView?.addSubview(searchTextField!)
        
        // Add an Accessory view to the keyboard
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        accessoryView.backgroundColor = UIColor.mpWhiteColor()
        
        let horizLine = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 1))
        horizLine.backgroundColor = UIColor.mpHeaderBackgroundColor()
        accessoryView.addSubview(horizLine)
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.frame = CGRect(x: 5, y: 5, width: 80, height: 30)
        cancelButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        cancelButton.addTarget(self, action: #selector(keyboardCancelButtonTouched), for: .touchUpInside)
        accessoryView.addSubview(cancelButton)
        searchTextField!.inputAccessoryView = accessoryView
        
        // Make a filter button that will be used in the header
        filterButton = UIButton(type: .custom)
        filterButton.setTitle(kDefaultFilterState, for: .normal)
        filterButton.setTitleColor(UIColor.mpBlueColor(), for: .normal)
        filterButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 14)
        filterButton.contentHorizontalAlignment = .right
        filterButton.setImage(UIImage(named: "SmallBlueFilter"), for: .normal)
        filterButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        filterButton.addTarget(self, action: #selector(filterButtonTouched), for: .touchUpInside)
        
        // Add the tableView
        searchTableView = UITableView()
        searchTableView.frame = CGRect(x: 0, y: (searchContainerView?.frame.origin.y)! + (searchContainerView?.frame.size.height)!, width: frame.size.width, height: frame.size.height - (searchContainerView?.frame.origin.y)! - (searchContainerView?.frame.size.height)!)
        searchTableView.delegate = self
        searchTableView.dataSource = self
        self.addSubview(searchTableView)
        searchTableView.isHidden = true
        
        // Build the favorite athlete identifier array so a star can be put next to each favorite team
        favoriteAthletesIdentifierArray.removeAll()
        
        // Get the favorite athletes
        if let favoriteAthletes = kUserDefaults.array(forKey: kUserFavoriteAthletesArrayKey)
        {
            for favoriteAthlete in favoriteAthletes
            {
                let item = favoriteAthlete  as! Dictionary<String, Any>
                let careerProfileId = item["careerProfileId"] as! String
                            
                favoriteAthletesIdentifierArray.append(careerProfileId)
            }
        }
        
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
}
