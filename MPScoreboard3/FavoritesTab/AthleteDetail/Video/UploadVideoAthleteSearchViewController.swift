//
//  UploadVideoAthleteSearchViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/12/22.
//

import UIKit

class UploadVideoAthleteSearchViewController: UIViewController, UploadVideoAthleteSearchViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    
    //var hostAthlete : Athlete!
    var taggedAthletes = [] as! Array<Any>
    
    private var uploadVideoAthleteSearchView: UploadVideoAthleteSearchView!
    private var progressOverlay: ProgressHUD!
    
    // MARK: - AthleteSearchView Delegate
    
    func uploadVideoAthleteSearchDidSelectAthlete(selectedAthlete: Athlete, showSaveFavoriteButton: Bool, showRemoveFavoriteButton: Bool)
    {
        // Iterate through the taaged athlete array to look for duplicates
        var duplicateFound = false
        for item in taggedAthletes
        {
            let athlete = item as! Athlete
            if (athlete.careerId == selectedAthlete.careerId)
            {
                duplicateFound = true
                break
            }
        }
        
        if (duplicateFound == true)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Duplicate Athlete", message: "This athlete has already been tagged.", lastItemCancelType: false) { tag in
                
            }
            
            return
        }
        
        // Add this athlete to the array
        taggedAthletes.append(selectedAthlete)
        
        // Call the popup here
        OverlayView.showPopupOverlay(withMessage: "Athlete Tagged")
        {
            
        }
        
        /*
        // Click Tracking
        let cData = [kClickTrackingEventKey:"", kClickTrackingActionKey:"claim-athlete", kClickTrackingModuleNameKey: "user preferences", kClickTrackingModuleLocationKey:"claim athlete prompt", kClickTrackingModuleActionKey: "impression", kClickTrackingClickTextKey:""]
        
        TrackingManager.trackEvent(featureName: "claim-pop-up", cData: cData)
        */
    }
    
    // MARK: - Button Methods
    
    @IBAction func doneButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        
        uploadVideoAthleteSearchView = UploadVideoAthleteSearchView(frame: CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: CGFloat(kDeviceWidth), height: CGFloat(kDeviceHeight) - navView.frame.size.height - fakeStatusBar.frame.size.height - CGFloat(SharedData.bottomSafeAreaHeight)))
        uploadVideoAthleteSearchView.delegate = self
        uploadVideoAthleteSearchView.backgroundColor = UIColor.mpWhiteColor()
        uploadVideoAthleteSearchView.parentVC = self
        self.view.addSubview(uploadVideoAthleteSearchView)
        
        let trackingGuid = NSUUID().uuidString
        TrackingManager.trackState(featureName: "search-athletes", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    
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
