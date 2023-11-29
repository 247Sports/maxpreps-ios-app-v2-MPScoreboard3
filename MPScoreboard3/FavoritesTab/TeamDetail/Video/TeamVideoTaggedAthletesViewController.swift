//
//  TeamVideoTaggedAthletesViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 11/17/22.
//

import UIKit

class TeamVideoTaggedAthletesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var addFromRosterBackgroundView: UIView!
    @IBOutlet weak var taggedAthleteCountLabel: UILabel!
    @IBOutlet weak var taggedAthletesTableView: UITableView!
    
    var taggedAthletes = [] as! Array<Any>
    var selectedTeam : Team?
    var activeTeams = [] as! Array<Dictionary<String,Any>>
    
    private var uploadVideoAthleteSearchVC: UploadVideoAthleteSearchViewController!
    private var teamVideoRosterSearchVC: TeamVideoRosterSearchViewController!
    
    // MARK: - TableView Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return taggedAthletes.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 58.0
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
        var cell = tableView.dequeueReusableCell(withIdentifier: "TaggedAthleteTableViewCell") as? TaggedAthleteTableViewCell
        
        if (cell == nil)
        {
            let nib = Bundle.main.loadNibNamed("TaggedAthleteTableViewCell", owner: self, options: nil)
            cell = nib![0] as? TaggedAthleteTableViewCell
        }
        
        cell?.selectionStyle = .none
        
        cell?.deleteAthleteButton.isHidden = false
        cell?.athleteImageView.image = UIImage(named: "Avatar")
        
        let athlete = taggedAthletes[indexPath.row] as! Athlete
        cell?.nameLabel.text = String(format: "%@ %@", athlete.firstName, athlete.lastName)
        
        if (athlete.schoolName == athlete.schoolCity)
        {
            cell?.schoolNameLabel.text = String(format: "%@ (%@)", athlete.schoolName, athlete.schoolState)
        }
        else
        {
            cell?.schoolNameLabel.text = String(format: "%@ (%@, %@)", athlete.schoolName, athlete.schoolCity, athlete.schoolState)
        }
        
        cell?.deleteAthleteButton.tag = 100 + indexPath.row
        cell?.deleteAthleteButton.addTarget(self, action: #selector(deleteAthleteButtonTouched(_:)), for: .touchUpInside)
        
        /*
        if (indexPath.row == 0)
        {
            cell?.deleteAthleteButton.isHidden = true
        }
        */
        let photoUrl = athlete.photoUrl
        print(photoUrl)
        print("Done")
        
        // Load the photo
        if (photoUrl.count > 0)
        {
            let url = URL(string: athlete.photoUrl)
            
            // Get the data and make an image
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        cell?.athleteImageView.image = image
                    }
                }
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchButtonTouched(_ sender: UIButton)
    {
        uploadVideoAthleteSearchVC = UploadVideoAthleteSearchViewController(nibName: "UploadVideoAthleteSearchViewController", bundle: nil)
        uploadVideoAthleteSearchVC.taggedAthletes = taggedAthletes
        
        self.navigationController?.pushViewController(uploadVideoAthleteSearchVC, animated: true)
    }
    
    @IBAction func addFromRosterButtonTouched(_ sender: UIButton)
    {
        teamVideoRosterSearchVC = TeamVideoRosterSearchViewController(nibName: "TeamVideoRosterSearchViewController", bundle: nil)
        teamVideoRosterSearchVC.selectedTeam = selectedTeam
        teamVideoRosterSearchVC.taggedAthletes = taggedAthletes
        teamVideoRosterSearchVC.activeTeams = activeTeams
        self.navigationController?.pushViewController(teamVideoRosterSearchVC, animated: true)
    }
    
    @objc private func deleteAthleteButtonTouched(_ sender: UIButton)
    {
        let index = sender.tag - 100
        let athlete = taggedAthletes[index] as! Athlete
        let message = String(format: "Do you want to untag %@ %@ from the video?", athlete.firstName, athlete.lastName)
        
        MiscHelper.showAlert(in: self, withActionNames: ["Cancel", "Yes"], title: "Untag Athlete", message: message, lastItemCancelType: false) { tag in
            
            if (tag == 1)
            {
                self.taggedAthletes.remove(at: index)
                self.taggedAthletesTableView.reloadData()
                
                // Update the tag count label
                self.taggedAthleteCountLabel.text = String(format: "TAGGED (%d)", self.taggedAthletes.count)
            }
        }
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        containerView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight))
        
        addFromRosterBackgroundView.layer.cornerRadius = 8
        addFromRosterBackgroundView.clipsToBounds = true
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if (uploadVideoAthleteSearchVC != nil)
        {
            // Iterate to remove for duplicates athletes
            for item in uploadVideoAthleteSearchVC.taggedAthletes
            {
                let taggedAthlete = item as! Athlete
                var matchFound = false
                for item2 in taggedAthletes
                {
                    let existingAthlete = item2 as! Athlete
                    if (existingAthlete.careerId == taggedAthlete.careerId)
                    {
                        matchFound = true
                        break
                    }
                }
                
                if (matchFound == false)
                {
                    taggedAthletes.append(taggedAthlete)
                }
            }
        }
        
        if (teamVideoRosterSearchVC != nil)
        {
            // Update the taggedAthletes array
            taggedAthletes = teamVideoRosterSearchVC.taggedAthletes
        }
        
        taggedAthletesTableView.reloadData()
    
        // Update the tag count label
        taggedAthleteCountLabel.text = String(format: "TAGGED (%d)", taggedAthletes.count)
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        if (uploadVideoAthleteSearchVC != nil)
        {
            uploadVideoAthleteSearchVC = nil
        }
        
        if (teamVideoRosterSearchVC != nil)
        {
            teamVideoRosterSearchVC = nil
        }
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
