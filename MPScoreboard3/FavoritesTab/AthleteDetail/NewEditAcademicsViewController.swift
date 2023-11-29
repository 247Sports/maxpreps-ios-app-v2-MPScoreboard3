//
//  NewEditAcademicsViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/9/23.
//

import UIKit

class NewEditAcademicsViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var gpaTextField: UITextField!
    @IBOutlet weak var satTextField: UITextField!
    @IBOutlet weak var actTextField: UITextField!
    
    var careerId = ""
    var gpa = -1.0
    var satScore = -1 // Int
    var actScore = -1 // Int
    
    private var editAttempted = false
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Load Data
    
    private func loadData()
    {
        if (gpa == -1.0)
        {
            gpaTextField.text = ""
        }
        else
        {
            gpaTextField.text = String(format: "%1.2f", gpa)
        }
        
        if (satScore == -1)
        {
            satTextField.text = ""
        }
        else
        {
            satTextField.text = String(satScore)
        }
        
        if (actScore == -1)
        {
            actTextField.text = ""
        }
        else
        {
            actTextField.text = String(actScore)
        }
    }
    
    // MARK: - TextField Delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        editAttempted = true
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if (textField == gpaTextField)
        {
            if (textField.text != "")
            {
                // Check if this is a number from 0 to 5.0
                let double = Double(textField.text!) ?? -1.0
                
                if ((double > 5) || (double == -1.0))
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Invalid GPA", message: "The GPA must be a number less than or equal to 5.", lastItemCancelType: false) { tag in
                        
                        self.gpaTextField.text = ""
                    }
                }
            }
        }
        else if (textField == satTextField)
        {
            if (textField.text != "")
            {
                // Check if this is a number from 1 to 1600
                let int = Int(textField.text!) ?? -1
                
                if ((int > 1600) || (int <= 0))
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Invalid SAT", message: "The SAT score must be between 1 and 1600.", lastItemCancelType: false) { tag in
                        
                        self.satTextField.text = ""
                    }
                }
            }
        }
        else if (textField == actTextField)
        {
            if (textField.text != "")
            {
                // Check if this is a number from 1 to 36
                let int = Int(textField.text!) ?? -1
                
                if ((int > 36) || (int <= 0))
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Invalid ACT", message: "The ACT score must be between 1 and 36.", lastItemCancelType: false) { tag in
                        
                        self.actTextField.text = ""
                    }
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if (textField == gpaTextField) // Only allow up to 4 characters
        {
            if (range.location > 3)
            {
                return false
            }
            else
            {
                if ((string == ".") && (gpaTextField.text?.contains(".") == true))
                {
                    return false
                }
                else
                {
                    return true
                }
            }
        }
        else if (textField == satTextField) // Only allow up to 4 integers
        {
            if ((range.location > 3) || (string == "."))
            {
                return false
            }
            else
            {
                return true
            }
        }
        else // Only allow up to 2 integers
        {
            if ((range.location > 1) || (string == "."))
            {
                return false
            }
            else
            {
                return true
            }
        }
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
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }

        CareerFeeds.updateAthleteAcademicScores(careerId: self.careerId, gpa: gpaTextField.text!, satScore: satTextField.text!, actScore: actTextField.text!) { error in
  
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
                print("Update Athlete Academics Success")
                
                OverlayView.showTwoLinePopupOverlay(withMessage: "Success! Your changes will take a few minutes to be reflected on your profile.", boldText: "Success!", withDismissHandler: {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                    {
                        self.navigationController?.popViewController(animated: true)
                    }
                })
            }
            else
            {
                print("Update Athlete Academics Failed")
                
                let errorMessage = error?.localizedDescription
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: errorMessage, lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    @objc private func gpaDoneButtonTouched()
    {
        gpaTextField.resignFirstResponder()
    }
    
    @objc private func satDoneButtonTouched()
    {
        satTextField.resignFirstResponder()
    }
    
    @objc private func actDoneButtonTouched()
    {
        actTextField.resignFirstResponder()
    }
    
    // MARK: - Keyboard Accessory Views
    
    private func addGpaKeyboardAccessoryView()
    {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        accessoryView.backgroundColor = UIColor.mpGrayButtonBorderColor()
        
        let doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: kDeviceWidth - 85, y: 6, width: 80, height: 30)
        doneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        doneButton.addTarget(self, action: #selector(gpaDoneButtonTouched), for: .touchUpInside)
        accessoryView.addSubview(doneButton)
        gpaTextField!.inputAccessoryView = accessoryView
    }
        
    private func addSatKeyboardAccessoryView()
    {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        accessoryView.backgroundColor = UIColor.mpGrayButtonBorderColor()
        
        let doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: kDeviceWidth - 85, y: 6, width: 80, height: 30)
        doneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        doneButton.addTarget(self, action: #selector(satDoneButtonTouched), for: .touchUpInside)
        accessoryView.addSubview(doneButton)
        satTextField!.inputAccessoryView = accessoryView
    }
    
    private func addActKeyboardAccessoryView()
    {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        accessoryView.backgroundColor = UIColor.mpGrayButtonBorderColor()
        
        let doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: kDeviceWidth - 85, y: 6, width: 80, height: 30)
        doneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        doneButton.addTarget(self, action: #selector(actDoneButtonTouched), for: .touchUpInside)
        accessoryView.addSubview(doneButton)
        actTextField!.inputAccessoryView = accessoryView
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Size the fakeStatusBar, navBar, bottomContainer, and containerScrollView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        bottomContainerView.frame = CGRect(x: 0, y: Int(kDeviceHeight) - 70 - SharedData.bottomSafeAreaHeight, width: Int(kDeviceWidth), height: 70 + SharedData.bottomSafeAreaHeight)
        containerScrollView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height - bottomContainerView.frame.size.height)
        
        self.addGpaKeyboardAccessoryView()
        self.addSatKeyboardAccessoryView()
        self.addActKeyboardAccessoryView()
        
        saveButton.layer.cornerRadius = 8
        saveButton.clipsToBounds = true
        
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

}
