//
//  EditAPClassesViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/10/23.
//

import UIKit

class EditAPClassesViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var textField5: UITextField!
    @IBOutlet weak var textField6: UITextField!
    @IBOutlet weak var textField7: UITextField!
    @IBOutlet weak var textField8: UITextField!
    @IBOutlet weak var textField9: UITextField!
    @IBOutlet weak var textField10: UITextField!
    
    var careerId = ""
    var dataArray: Array<String> = []
    
    private var containerViewHeight = 0.0
    private var editAttempted = false
    private var progressOverlay: ProgressHUD!
    
    // MARK: - TextField Delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        editAttempted = true
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        // Emoji detection is not needed since the keyboard is ASCII
        
        let badWords = IODProfanityFilter.rangesOfFilteredWords(in: textField.text)
        
        if (badWords!.count > 0)
        {
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Language", message: "The text that you have entered is objectionable and can not be used.", lastItemCancelType: false) { tag in

                textField.text = ""
            }
            return
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        return true
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched()
    {
        if (editAttempted == false)
        {
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            MiscHelper.showAlert(in: self, withActionNames: ["Cancel", "Discard"], title: "Discard Changes?", message: "By choosing to discard, you will lose the edits you just made.", lastItemCancelType: false) { tag in
                
                if (tag == 1)
                {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func saveButtonTouched()
    {
        // Build an array of dictionaries to send to the API
        var classesArray: Array<Dictionary<String,Any>> = []
        let classType = "AP" // Honor
        
        if (textField1.text! != "")
        {
            let classDict = ["className":textField1.text!, "classType": classType] as [String : Any]
            classesArray.append(classDict)
        }
        
        if (textField2.text! != "")
        {
            let classDict = ["className":textField2.text!, "classType": classType] as [String : Any]
            classesArray.append(classDict)
        }
        
        if (textField3.text! != "")
        {
            let classDict = ["className":textField3.text!, "classType": classType] as [String : Any]
            classesArray.append(classDict)
        }
        
        if (textField4.text! != "")
        {
            let classDict = ["className":textField4.text!, "classType": classType] as [String : Any]
            classesArray.append(classDict)
        }
        
        if (textField5.text! != "")
        {
            let classDict = ["className":textField5.text!, "classType": classType] as [String : Any]
            classesArray.append(classDict)
        }
        
        if (textField6.text! != "")
        {
            let classDict = ["className":textField6.text!, "classType": classType] as [String : Any]
            classesArray.append(classDict)
        }
        
        if (textField7.text! != "")
        {
            let classDict = ["className":textField7.text!, "classType": classType] as [String : Any]
            classesArray.append(classDict)
        }
        
        if (textField8.text! != "")
        {
            let classDict = ["className":textField8.text!, "classType": classType] as [String : Any]
            classesArray.append(classDict)
        }
        
        if (textField9.text! != "")
        {
            let classDict = ["className":textField9.text!, "classType": classType] as [String : Any]
            classesArray.append(classDict)
        }
        
        if (textField10.text! != "")
        {
            let classDict = ["className":textField10.text!, "classType": classType] as [String : Any]
            classesArray.append(classDict)
        }
        
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        CareerFeeds.saveAthleteAcademicClasses(careerId: self.careerId, classType: classType, classesArray: classesArray) { error in
            
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
                print("Update Athlete Academic classes Success")
                
                OverlayView.showTwoLinePopupOverlay(withMessage: "Success! Your changes will take a few minutes to be reflected on your profile.", boldText: "Success!", withDismissHandler: {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                    {
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            }
            else
            {
                print("Update Athlete Academic Classes Failed")
                
                let errorMessage = error?.localizedDescription
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: errorMessage, lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - Load Data
    
    private func loadData()
    {
        if (dataArray.count > 0)
        {
            textField1.text = dataArray[0]
        }
        
        if (dataArray.count > 1)
        {
            textField2.text = dataArray[1]
        }
        
        if (dataArray.count > 2)
        {
            textField3.text = dataArray[2]
        }
        
        if (dataArray.count > 3)
        {
            textField4.text = dataArray[3]
        }
        
        if (dataArray.count > 4)
        {
            textField5.text = dataArray[4]
        }
        
        if (dataArray.count > 5)
        {
            textField6.text = dataArray[5]
        }
        
        if (dataArray.count > 6)
        {
            textField7.text = dataArray[6]
        }
        
        if (dataArray.count > 7)
        {
            textField8.text = dataArray[7]
        }
        
        if (dataArray.count > 8)
        {
            textField9.text = dataArray[8]
        }
        
        if (dataArray.count > 9)
        {
            textField10.text = dataArray[9]
        }
    }
    
    // MARK: - Keyboard Notifications
    
    @objc private func keyboardDidShow(notification: Notification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            //print("Keyboard Height: " + String(Int(keyboardSize.size.height)))
            
            // Shrink the containerScrollView height
            containerScrollView.frame.size = CGSize(width: kDeviceWidth, height: containerViewHeight + bottomContainerView.frame.size.height - keyboardSize.size.height)
        }
    }
    
    @objc private func keyboardDidHide(notification: Notification)
    {
        //print("Keyboard will hide")
        //containerScrollView.contentOffset = CGPoint(x: 0, y: 0)
        
        // Set the scroll size
        containerScrollView.frame.size = CGSize(width: kDeviceWidth, height: containerViewHeight - 10.0)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Size the fakeStatusBar, navBar, bottomContainer, and containerScrollView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        bottomContainerView.frame = CGRect(x: 0, y: Int(kDeviceHeight) - 70 - SharedData.bottomSafeAreaHeight, width: Int(kDeviceWidth), height: 70 + SharedData.bottomSafeAreaHeight)
        
        containerViewHeight = kDeviceHeight - navView.frame.origin.y - navView.frame.size.height - bottomContainerView.frame.size.height
        
        containerScrollView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: containerViewHeight)
        
        containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: 640)
        
        saveButton.layer.cornerRadius = 8
        saveButton.clipsToBounds = true
        
        // Add the keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.loadData()
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

    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
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

    deinit
    {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
