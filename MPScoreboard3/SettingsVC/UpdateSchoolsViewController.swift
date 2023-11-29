//
//  UpdateSchoolsViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 4/14/22.
//

import UIKit

class UpdateSchoolsViewController: UIViewController
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var innerContainerView1: UIView!
    @IBOutlet weak var innerContainerView2: UIView!
    @IBOutlet weak var updateButton: UIButton!
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - File Cleanup
    
    private func cleanUpSchoolsFile()
    {
        let documentDirectory = MiscHelper.documentDirectory()
        let filePath = documentDirectory + "/ALL.txt"
        
        // Read the file
        var wordstring = ""
        do {
                wordstring = try String(contentsOfFile: filePath, encoding: .utf8)
            }
            catch
            {
                print("Couldn't read file")
            }
            
        // Split the string into an array
        let lineArray = wordstring.components(separatedBy: "\n")
        
        // Iterate backwards to remove items
        var fixedArray = [""]
        for line in lineArray
        {
            let components = line.components(separatedBy: "|")
            
            if (components.count > 10)
            {
                let state = components[6]
                
                // Remove schools with no state (international)
                if (state.count == 0)
                {
                   //NSLog(@"Missing State Found at index: %ld", (long)i);
                    continue
                }
            }
            else
            {
                // Empty line
                //NSLog(@"Empty Line Found at index: %ld", (long)i);
                continue
            }
            
            fixedArray.append(line)
        }
        
        print("Final School Count: " + String(fixedArray.count));
        
        // Update the file with the cleaned up data
        var fileString = ""
        
        for (index, line) in fixedArray.enumerated()
        {
            if ((lineArray.count - 1) == index)
            {
                // Last line
                fileString = fileString + line
            }
            else
            {
                fileString = fileString + line + "\n"
            }
        }

        // Hide the HUD
        //MBProgressHUD.hide(for: self.view, animated: true)
        if (self.progressOverlay != nil)
        {
            self.progressOverlay.hide(animated: false)
            self.progressOverlay = nil
        }
            
        // Write the file
        MiscHelper.saveStringFile(text: fileString, toDirectory: documentDirectory, withFileName: "ALL.txt")
        
        innerContainerView2.isHidden = false

    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func updateButtonTouched(_ sender: UIButton)
    {
        innerContainerView1.isHidden = true
        
        DispatchQueue.main.async
        {
            //MBProgressHUD.showAdded(to: self.view, animated: true)
            if (self.progressOverlay == nil)
            {
                self.progressOverlay = ProgressHUD()
                self.progressOverlay.show(animated: false)
            }
        }
        var urlString = ""
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kDownloadSchoolListHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kDownloadSchoolListHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kDownloadSchoolListHostStaging
        }
        else
        {
            urlString = kDownloadSchoolListHostProduction
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        // Calculate the DT and HH values using the FeedsHelper
        let dt = FeedsHelper.getDateCode(SharedData.utcTimeOffset)
        let hh = FeedsHelper.getHashCode(withPassword: "-Score$Board#APPS-", andDate: dt)
        
        urlRequest.addValue(dt, forHTTPHeaderField:"DT")
        urlRequest.addValue(hh, forHTTPHeaderField:"HH")
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { (data, response, connectionError) in
                        
            DispatchQueue.main.async
            {
                if (connectionError == nil)
                {
                    if let httpResponse = response as? HTTPURLResponse
                    {
                        print("Response: " + response!.description)
                        
                        if (httpResponse.statusCode == 200)
                        {
                            if (data != nil)
                            {
                                // School Full Name | SchoolID | School URL | School Name | Address | City | State | Zip | Phone | Longitude | Latitude
                                
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Write the downloaded file to the Documents Directory
                                let documentDirectory = MiscHelper.documentDirectory()
                                MiscHelper.saveStringFile(text: logDataReceived, toDirectory: documentDirectory, withFileName: "ALL.txt")
                                
                                // Clean up the file
                                self.cleanUpSchoolsFile()
                            }
                            else
                            {
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
                                print("Data was nil")
                                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when updating the school database. Data was nil.", lastItemCancelType: false) { (tag) in
                                    
                                    self.innerContainerView1.isHidden = false
                                }
                            }
                        }
                        else
                        {
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
                            print("Status != 200")
                            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when updating the school database. Non-200 reponse.", lastItemCancelType: false) { (tag) in
                                
                                self.innerContainerView1.isHidden = false
                            }
                        }
                    }
                    else
                    {
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
                        print("Response was nil")
                        MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when updating the school database. Nil response.", lastItemCancelType: false) { (tag) in
                            
                            self.innerContainerView1.isHidden = false
                        }
                    }
                }
                else
                {
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
                    print("Connection Error")
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong when updating the school database. Failed connection.", lastItemCancelType: false) { (tag) in
                        
                        self.innerContainerView1.isHidden = false
                    }
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and tableView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        containerView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - fakeStatusBar.frame.size.height - navView.frame.size.height)
        
        updateButton.layer.cornerRadius = 8.0
        updateButton.clipsToBounds = true
        
        innerContainerView2.isHidden = true
        
        // Tracking
        let trackingGuid = NSUUID().uuidString
        TrackingManager.trackState(featureName: "update-schools", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        // Update the schools database
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.getSchoolsFile()
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
