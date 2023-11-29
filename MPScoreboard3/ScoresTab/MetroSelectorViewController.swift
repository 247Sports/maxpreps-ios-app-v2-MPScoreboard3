//
//  MetroSelectorViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/31/21.
//

import UIKit

class MetroSelectorViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var itemScrollView: UIScrollView!
    @IBOutlet weak var scoreboardsTableView: UITableView!
    
    var selectedMetro = [:] as Dictionary<String,Any>
    var selectedState = ""
    var selectedSport = ""
    var selectedGender = ""
    
    private var selectedItemIndex = 0
    private var entitiesObject = [:] as Dictionary<String,Any>
    private var sectionNameLookupTable = [:] as! Dictionary<String,String>
    private var entityDefaultNameArray = [] as! Array<String>
    private var entitySelectorArray = [] as! Array<String>
    
    private var progressOverlay: ProgressHUD!
    
    //let kItemList = ["Metro", "Section", "League", "Division", "Association"]
    
    // MARK: - Get Metros Feed
    
    private func getScoreboardEntities()
    {
        let stateCode = kShortStateLookupDictionary[selectedState]!
        let genderCommaSport = MiscHelper.genderCommaSportFrom(gender: selectedGender, sport: selectedSport)
        
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.getScoreboardEntities(stateCode: stateCode.lowercased(), genderCommaSport: genderCommaSport, year: "", season: "") { result, error in
            
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
                print("Get Scoreboard Entities Success")
                
                self.buildStateEntitiesArray(data: result!)
            }
            else
            {
                print("Get Scoreboard Entities Failed")
            }
        }
    }
    
    // MARK: - Build State Entities Array
    
    private func buildStateEntitiesArray(data: Dictionary<String,Any>)
    {
        // Refactor the feed result into a single array broken into sections
        var dmaName = "Metro"
        var sectionName = "Section"
        var leagueName = "League"
        var divisionName = "Division"
        var associationName = "Association"
        
        if let aliases = data["aliases"] as? Dictionary<String,String>
        {
            if let dmaAlias = aliases["dmaAlias"]
            {
                dmaName = dmaAlias
            }
            
            if let sectionAlias = aliases["sectionAlias"]
            {
                sectionName = sectionAlias
            }
            
            if let leagueAlias = aliases["leagueAlias"]
            {
                leagueName = leagueAlias
            }
            
            if let divisionAlias = aliases["divisionAlias"]
            {
                divisionName = divisionAlias
            }
            
            if let associationAlias = aliases["associationAlias"]
            {
                associationName = associationAlias
            }
        }
        
        if let dmas = data["dmas"] as? Array<Dictionary<String,Any>>
        {
            if (dmas.count > 0)
            {
                entitySelectorArray.append(dmaName)
                entityDefaultNameArray.append("dma")
                entitiesObject[dmaName] = dmas
            }
        }
        
        if let sections = data["sections"] as? Array<Dictionary<String,Any>>
        {
            if (sections.count > 0)
            {
                entitySelectorArray.append(sectionName)
                entityDefaultNameArray.append("section")
                entitiesObject[sectionName] = sections
                
                // Iterate through the sectionsArray to build a section name lookup table using sertionId as the key
                for section in sections
                {
                    let name = section["name"] as! String
                    let sectionId = section["sectionId"] as! String
                    sectionNameLookupTable[sectionId] = name
                }
            }
        }
        
        if let leagues = data["leagues"] as? Array<Dictionary<String,Any>>
        {
            if (leagues.count > 0)
            {
                entitySelectorArray.append(leagueName)
                entityDefaultNameArray.append("league")
                entitiesObject[leagueName] = leagues
            }
        }
        
        if let divisions = data["divisions"] as? Array<Dictionary<String,Any>>
        {
            if (divisions.count > 0)
            {
                entitySelectorArray.append(divisionName)
                entityDefaultNameArray.append("division")
                entitiesObject[divisionName] = divisions
            }
        }
        
        if let associations = data["associations"] as? Array<Dictionary<String,Any>>
        {
            if (associations.count > 0)
            {
                entitySelectorArray.append(associationName)
                entityDefaultNameArray.append("association")
                entitiesObject[associationName] = associations
            }
        }
        
        for title in entitySelectorArray
        {
            print(title)
        }
        
        self.loadItemSelector()
    }
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (entitySelectorArray.count > 0)
        {
            let selectorTitle = entitySelectorArray[selectedItemIndex]
            let entitiesArray = entitiesObject[selectorTitle] as! Array<Any>
            return entitiesArray.count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 56
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let selectedItemDefaultTitle = entityDefaultNameArray[selectedItemIndex]
        
        // Use different cell styles
        if ((selectedItemDefaultTitle == "league") || (selectedItemDefaultTitle == "division"))
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cell1")
                    
            if (cell == nil)
            {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell1")
            }
            
            cell?.selectionStyle = .none
            
            let selectorTitle = entitySelectorArray[selectedItemIndex]
            let entitiesArray = entitiesObject[selectorTitle] as! Array<Dictionary<String,Any>>
            let entity = entitiesArray[indexPath.row]
            
            cell?.textLabel?.font = UIFont.mpBoldFontWith(size: 16)
            cell?.textLabel?.textColor = UIColor.mpBlackColor()
            cell?.textLabel?.text = entity["name"] as? String
            
            cell?.detailTextLabel?.font = UIFont.mpRegularFontWith(size: 13)
            cell?.detailTextLabel?.textColor = UIColor.mpGrayColor()
            
            // Get the section name using the lookup table
            let sectionId = entity["sectionId"] as! String
            
            if let sectionName = sectionNameLookupTable[sectionId]
            {
                cell?.detailTextLabel?.text = sectionName
            }
            else
            {
                cell?.detailTextLabel?.text = selectedState //""
            }
                    
            return cell!
        }
        else
        {
            var cell = tableView.dequeueReusableCell(withIdentifier: "Cell2")
                    
            if (cell == nil)
            {
                cell = UITableViewCell(style: .default, reuseIdentifier: "Cell2")
            }
            
            cell?.selectionStyle = .none
            
            let selectorTitle = entitySelectorArray[selectedItemIndex]
            let entitiesArray = entitiesObject[selectorTitle] as! Array<Dictionary<String,Any>>
            let entity = entitiesArray[indexPath.row]
            
            cell?.textLabel?.font = UIFont.mpBoldFontWith(size: 16)
            cell?.textLabel?.textColor = UIColor.mpBlackColor()
            
            // Use the code property if it is available (associations only)
            let name = entity["name"] as! String
            let code = entity["code"] as? String ?? ""
            
            if (code != "")
            {
                cell?.textLabel?.text = code
            }
            else
            {
                cell?.textLabel?.text = name
            }
                    
            return cell!
        }
          
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectorTitle = entitySelectorArray[selectedItemIndex]
        let entitiesArray = entitiesObject[selectorTitle] as! Array<Dictionary<String,Any>>
        let entity = entitiesArray[indexPath.row]
        let entityName = entity["name"] as! String
        
        var sectionId = kEmptyGuid
        if (entity["sectionId"] != nil)
        {
            sectionId = entity["sectionId"] as! String
        }
        
        var sectionName = ""
        
        if (sectionNameLookupTable[sectionId] != nil)
        {
            sectionName = sectionNameLookupTable[sectionId]!
        }
        
        let stateCode = kShortStateLookupDictionary[selectedState]!
        
        // The entityId property is named differently depending on the entitly section
        let defaultName = entityDefaultNameArray[selectedItemIndex]
        var entityId = ""
        var divisionType = ""
        
        switch defaultName
        {
        case "dma":
            entityId = entity["dmaId"] as! String
        case "section":
            entityId = entity["sectionId"] as! String
        case "league":
            entityId = entity["leagueId"] as! String
        case "division":
            entityId = entity["divisionId"] as! String
            divisionType = entity["type"] as! String
        case "association":
            entityId = entity["associationId"] as! String
        default:
            entityId = ""
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
        
        // Include defaultName, aliasName, gender, sport, state, stateCode, entityId
        self.selectedMetro = [kScoreboardDefaultNameKey: defaultName, kScoreboardAliasNameKey: selectorTitle, kScoreboardGenderKey: selectedGender, kScoreboardSportKey: selectedSport, kScoreboardStateNameKey: selectedState, kScoreboardStateCodeKey: stateCode, kScoreboardEntityIdKey: entityId, kScoreboardEntityNameKey: entityName, kScoreboardDivisionTypeKey: divisionType, kScoreboardSectionNameKey: sectionName]
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    // MARK: - Load Item Selector
    
    private func loadItemSelector()
    {
        selectedItemIndex = 0
        
        // Remove existing buttons
        let itemScrollViewSubviews = itemScrollView.subviews
        for subview in itemScrollViewSubviews
        {
            subview.removeFromSuperview()
        }
        
        // Remove the shadows from to top view
        let mainSubviews = self.view.subviews
        for subview in mainSubviews
        {
            if (subview.tag == 200) || (subview.tag == 201)
            {
                subview.removeFromSuperview()
            }
        }
        
        var overallWidth = 0
        let pad = 10
        var leftPad = 0
        let rightPad = 10
        var index = 0
        
        for item in entitySelectorArray
        {
            let itemWidth = Int(item.widthOfString(usingFont: UIFont.mpSemiBoldFontWith(size: 13))) + (2 * pad)
            let tag = entitySelectorArray.firstIndex(of: item)! + 100
            
            // Add the left pad to the first cell
            if (index == 0)
            {
                leftPad = 10
            }
            else
            {
                leftPad = 0
            }
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: overallWidth + leftPad, y: 0, width: itemWidth, height: Int(itemScrollView.frame.size.height))
            button.backgroundColor = .clear
            button.setTitle(item, for: .normal)
            button.tag = tag
            button.addTarget(self, action: #selector(self.itemTouched), for: .touchUpInside)
            
            // Add a line at the bottom of each button
            let textWidth = itemWidth - (2 * pad)
            let line = UIView(frame: CGRect(x: (button.frame.size.width - CGFloat(textWidth)) / 2.0, y: button.frame.size.height - 4, width: CGFloat(textWidth), height: 4))
            line.backgroundColor = UIColor.mpRedColor()

            // Round the top corners
            line.clipsToBounds = true
            line.layer.cornerRadius = 4
            line.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            
            button.addSubview(line)
            
            if (index == 0)
            {
                button.titleLabel?.font = UIFont.mpBoldFontWith(size: 13)
                button.setTitleColor(UIColor.mpBlackColor(), for: .normal)
            }
            else
            {
                button.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 13)
                button.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
                
                // Hide the inactive horiz line
                let horizLine = button.subviews[0]
                horizLine.isHidden = true
            }
            
            itemScrollView.addSubview(button)
            
            index += 1
            overallWidth += (itemWidth + leftPad)
        }
        
        itemScrollView.contentSize = CGSize(width: overallWidth + rightPad, height: Int(itemScrollView.frame.size.height))
        
        scoreboardsTableView.reloadData()
        
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
        
    @objc private func itemTouched(_ sender: UIButton)
    {
        // Change the font of the all of the buttons to regular, hide the underline view
        for subview in itemScrollView.subviews as Array<UIView>
        {
            if (subview is UIButton)
            {
                let button = subview as! UIButton
                button.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 13)
                button.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
                
                let horizLine = button.subviews[0]
                horizLine.isHidden = true
            }
        }
        
        // Set the selected item's font to bold
        selectedItemIndex = sender.tag - 100
        sender.titleLabel?.font = UIFont.mpBoldFontWith(size: 13)
        sender.setTitleColor(UIColor.mpBlackColor(), for: .normal)
        
        // Show the underline on the button
        let horizLine = sender.subviews[0]
        horizLine.isHidden = false
        
        scoreboardsTableView.reloadData()
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        scoreboardsTableView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight))
        
        let genderSportLevel = MiscHelper.genderSportLevelFrom(gender: selectedGender, sport: selectedSport, level: "Varsity")
        subtitleLabel.text = selectedState + " " + genderSportLevel
        
        self.getScoreboardEntities()

    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
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
