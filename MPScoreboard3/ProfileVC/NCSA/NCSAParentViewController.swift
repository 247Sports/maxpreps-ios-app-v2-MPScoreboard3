//
//  NCSAParentViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 12/8/22.
//

import UIKit

class NCSAParentViewController: UIViewController, UITextFieldDelegate, IQActionSheetPickerViewDelegate, SpecialOffersAlertViewDelegate, ExtraAthleteViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var disclaimerTextView: UITextView!
    @IBOutlet weak var addAnotherButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var firstNameContainerView: UIView!
    @IBOutlet weak var lastNameContainerView: UIView!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var graduationYearContainerView: UIView!
    @IBOutlet weak var primarySportContainerView: UIView!
    @IBOutlet weak var parentFirstNameContainerView: UIView!
    @IBOutlet weak var parentLastNameContainerView: UIView!
    @IBOutlet weak var parentEmailContainerView: UIView!
    @IBOutlet weak var parentPhoneNumberContainerView: UIView!
    @IBOutlet weak var parentZipcodeContainerView: UIView!
    @IBOutlet weak var lowerContainerView: UIView!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var graduationYearTextField: UITextField!
    @IBOutlet weak var primarySportTextField: UITextField!
    @IBOutlet weak var parentFirstNameTextField: UITextField!
    @IBOutlet weak var parentLastNameTextField: UITextField!
    @IBOutlet weak var parentEmailTextField: UITextField!
    @IBOutlet weak var parentPhoneNumberTextField: UITextField!
    @IBOutlet weak var parentZipcodeTextField: UITextField!
    
    private var yearsArray = [] as Array<String>
    private var tickTimer: Timer!
    private var progressOverlay: ProgressHUD!
    private var specialOffersAlertView: SpecialOffersAlertView!
    
    private var extraAthleteCount = 0
    private let kMaxExtraAthletes = 9
    
    private let kTopSectionHeight = 935.0
    private let kExtraAthleteViewHeight = 490
    
    // MARK: - SpecialOffersAlertView
    
    private func showSpecialOffersAlertView(title: String, message: String, buttonTitle: String, buttonBackgroundColor: UIColor, buttonTextColor: UIColor)
    {
        // Show the alert view
        specialOffersAlertView = SpecialOffersAlertView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: kDeviceHeight), title: title, message: message, buttonTitle: buttonTitle, buttonBackgroundColor: buttonBackgroundColor, buttonTextColor: buttonTextColor)
        specialOffersAlertView.delegate = self
        self.view.addSubview(specialOffersAlertView)
    }
    
    func specialOffersAlertDoneButtonTouched()
    {
        specialOffersAlertView.removeFromSuperview()
        specialOffersAlertView = nil
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Update Special Offer
    
    private func updateSpecialOffer()
    {
        /*
        "athleteFirstName": "Fathlete1",
        "athleteLastName": "Lathlete1",
        "athleteEmail": "athlete123@test.com",
        "athleteZipCode": "95747",
        "athletePhone": "999-999-9999",
        "athleteBornOn": null, // Omit this property rather than empty string
        "graduationYear": 2024,
        "gender": "boys",
        "sport": "football",
        "parentFirstName": "Fparent1",
        "parentLastName": "Lparent2",
        "parentEmail": "parent123@test.com",
        "parentZipCode": "95747",
        "parentPhone": "999-999-9999"
        */
        
        // Build the postData (use the same zipcode for the parent and athlete)
        let index = kNCSAGenderSportsArray.firstIndex(of: primarySportTextField.text!)
        let gender = kNCSAGenderArray[index!]
        let sport = kNCSASportsArray[index!]
        let graduationYearInt = Int(graduationYearTextField.text!)!
        let graduationYear = NSNumber.init(integerLiteral: graduationYearInt)
        
        let basePostData = ["athleteFirstName":firstNameTextField.text!, "athleteLastName":lastNameTextField.text!, "athleteEmail":emailTextField.text!, "athleteZipCode":parentZipcodeTextField.text!, "athletePhone":parentPhoneNumberTextField.text!, "graduationYear":graduationYear, "gender":gender, "sport":sport, "parentFirstName":parentFirstNameTextField.text!, "parentLastName":parentLastNameTextField.text!, "parentEmail":parentEmailTextField.text!, "parentZipCode":parentZipcodeTextField.text!, "parentPhone":parentPhoneNumberTextField.text!] as [String : Any]

        var postArray = [] as Array<Dictionary<String,Any>>
        postArray.append(basePostData)
        
        // Iterate through the ncsa extra athletes dictionary to add more athletes
        let keys = SharedData.ncsaExtraAthleteDictionary.keys
        
        for key in keys
        {
            let extraPostData = SharedData.ncsaExtraAthleteDictionary[key] as! Dictionary<String,Any>
            let extraFirstName = extraPostData["firstName"] as! String
            let extraLastName = extraPostData["lastName"] as! String
            let extraEmail = extraPostData["email"] as! String
            let extraYearString = extraPostData["graduationYear"] as! String
            let extraYear = NSNumber.init(integerLiteral: Int(extraYearString)!)
            let extraPrimarySport = extraPostData["primarySport"] as! String
            let extraIndex = kNCSAGenderSportsArray.firstIndex(of: extraPrimarySport)
            let extraGender = kNCSAGenderArray[extraIndex!]
            let extraSport = kNCSASportsArray[extraIndex!]
            
            let refactoredPostData = ["athleteFirstName":extraFirstName, "athleteLastName":extraLastName, "athleteEmail":extraEmail, "athleteZipCode":parentZipcodeTextField.text!, "athletePhone":parentPhoneNumberTextField.text!, "graduationYear":extraYear, "gender":extraGender, "sport":extraSport, "parentFirstName":parentFirstNameTextField.text!, "parentLastName":parentLastNameTextField.text!, "parentEmail":parentEmailTextField.text!, "parentZipCode":parentZipcodeTextField.text!, "parentPhone":parentPhoneNumberTextField.text!] as [String : Any]
            
            postArray.append(refactoredPostData)
        }
        
        // Call the feed
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.submitNCSAType(2, postDataArray: postArray) { error in
            
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
                print("NCSA Parent successfully submitted")
                
                let buttonBackgroundColor = UIColor.init(hexString: "036FBA")
                self.showSpecialOffersAlertView(title: "Success!", message: "Your information has been submitted to the NCSA.", buttonTitle: "GOT IT", buttonBackgroundColor: buttonBackgroundColor, buttonTextColor: UIColor.mpWhiteColor())
            }
            else
            {
                print("NCSA Parent failed")
                
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "Something went wrong while trying to submit the data.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelectTitles titles: [String])
    {
        let title = titles.first
        
        if (pickerView.tag == 1)
        {
            graduationYearTextField.text = title
        }
        else if (pickerView.tag == 2)
        {
            primarySportTextField.text = title
        }
        
        graduationYearContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        primarySportContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
    }
    
    func actionSheetPickerViewDidCancel(_ pickerView: IQActionSheetPickerView)
    {
        graduationYearContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        primarySportContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
    }
    
    // MARK: - TextField Delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if (textField == graduationYearTextField)
        {
            graduationYearContainerView.layer.borderColor = UIColor.mpDarkGrayColor().cgColor
            primarySportContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
            
            let picker = IQActionSheetPickerView(title: "Select Year", delegate: self)
            picker.tag = 1
            picker.backgroundColor = UIColor.mpWhiteColor()
            picker.toolbarButtonColor = UIColor.mpWhiteColor()
            picker.toolbarTintColor = UIColor.mpPickerToolbarColor()
            picker.titlesForComponents = [yearsArray]
            picker.show()
            
            return false
        }
        else if (textField == primarySportTextField)
        {
            graduationYearContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
            primarySportContainerView.layer.borderColor = UIColor.mpDarkGrayColor().cgColor
            
            let picker = IQActionSheetPickerView(title: "Select Sport", delegate: self)
            picker.tag = 2
            picker.backgroundColor = UIColor.mpWhiteColor()
            picker.toolbarButtonColor = UIColor.mpWhiteColor()
            picker.toolbarTintColor = UIColor.mpPickerToolbarColor()
            picker.titlesForComponents = [kNCSAGenderSportsArray]
            picker.show()
            
            return false
        }
        else
        {
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if (textField == firstNameTextField)
        {
            firstNameContainerView.layer.borderColor = UIColor.mpDarkGrayColor().cgColor
        }
        else if (textField == lastNameTextField)
        {
            lastNameContainerView.layer.borderColor = UIColor.mpDarkGrayColor().cgColor
        }
        else if (textField == emailTextField)
        {
            emailContainerView.layer.borderColor = UIColor.mpDarkGrayColor().cgColor
        }
        else if (textField == parentZipcodeTextField)
        {
            parentZipcodeContainerView.layer.borderColor = UIColor.mpDarkGrayColor().cgColor
        }
        else if (textField == parentFirstNameTextField)
        {
            parentFirstNameContainerView.layer.borderColor = UIColor.mpDarkGrayColor().cgColor
        }
        else if (textField == parentLastNameTextField)
        {
            parentLastNameContainerView.layer.borderColor = UIColor.mpDarkGrayColor().cgColor
        }
        else if (textField == parentEmailTextField)
        {
            parentEmailContainerView.layer.borderColor = UIColor.mpDarkGrayColor().cgColor
        }
        else if (textField == parentPhoneNumberTextField)
        {
            parentPhoneNumberContainerView.layer.borderColor = UIColor.mpDarkGrayColor().cgColor
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        firstNameContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        lastNameContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        emailContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        parentZipcodeContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        graduationYearContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        primarySportContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        parentFirstNameContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        parentLastNameContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        parentEmailContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        parentPhoneNumberContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        
        if ((textField == parentFirstNameTextField) || (textField == parentLastNameTextField) || (textField == firstNameTextField) || (textField == lastNameTextField))
        {
            if (textField.text!.containsEmoji == true)
            {
                // Special characters were found
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: "You can't use special characters in a name.", lastItemCancelType: false) { tag in
                    
                    textField.text! = ""
                }
                return
            }
            
            // Check for bad words
            let badName = IODProfanityFilter.rangesOfFilteredWords(in: textField.text!)
            
            if (badName!.count > 0)
            {
                // Bad word was found
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Language", message: "This name is objectionable and can not be used.", lastItemCancelType: false) { tag in
                    
                    textField.text! = ""
                }
                return
            }
        }
        else if (textField == parentEmailTextField)
        {
            if (MiscHelper.isValidEmailAddress(parentEmailTextField.text!) == false)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Oops", message: "The email is not a valid format.", lastItemCancelType: false) { tag in
                    
                    self.parentEmailTextField.text = ""
                }
            }
        }
        else if (textField == parentPhoneNumberTextField)
        {
            if (parentPhoneNumberTextField.text?.count != 12)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Oops", message: "The phone number needs to be 10 digits.", lastItemCancelType: false) { tag in
                    
                    self.parentPhoneNumberTextField.text = ""
                }
            }
        }
        else if (textField == parentZipcodeTextField)
        {
            if (parentZipcodeTextField.text?.count != 5)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Oops", message: "The zip code needs to be five digits.", lastItemCancelType: false) { tag in
                    
                }
            }
        }
        else if (textField == emailTextField)
        {
            if (MiscHelper.isValidEmailAddress(emailTextField.text!) == false)
            {
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Oops", message: "The email is not a valid format.", lastItemCancelType: false) { tag in
                    
                    self.emailTextField.text = ""
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if (textField == parentPhoneNumberTextField)
        {
            guard let text = textField.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            textField.text = self.formatPhoneNumber(with: "XXX-XXX-XXXX", phone: newString)
            return false
        }
        else if (textField == parentZipcodeTextField)
        {
            if (range.location > 4)
            {
                return false
            }
            else
            {
                if (string == ".")
                {
                    return false
                }
                else
                {
                    return true
                }
            }
        }
        else
        {
            return true
        }
    }
    
    // MARK: - Phone Number Formatter
    
    func formatPhoneNumber(with mask: String, phone: String) -> String
    {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex // numbers iterator

        // iterate over the mask characters until the iterator of numbers ends
        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                // mask requires a number in this place, so take the next one
                result.append(numbers[index])

                // move numbers iterator to the next index
                index = numbers.index(after: index)

            } else {
                result.append(ch) // just append a mask character
            }
        }
        return result
    }
    
    // MARK: - Extra Athlete Delegate Methods
    
    func extraAthleteRemoveButtonTouched(tag: Int)
    {
        // Find the matching view in the scrollView and remove it.
        for subView in containerScrollView.subviews
        {
            if (subView.tag == tag)
            {
                subView.removeFromSuperview()
                
                // Decrement the extra athlete count
                extraAthleteCount -= 1
                
                // Resize the scrollView content size and move the lowerContainer
                containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: kTopSectionHeight + CGFloat(extraAthleteCount * kExtraAthleteViewHeight) + lowerContainerView.frame.size.height)
                lowerContainerView.frame.origin.y = kTopSectionHeight + CGFloat(extraAthleteCount * kExtraAthleteViewHeight)
            }
        }
        
        // Now recalculate the y-position of each extra athlete
        var subViewCount = 0
        for subView in containerScrollView.subviews
        {
            if (subView.tag >= 100)
            {
                subView.frame.origin.y = kTopSectionHeight + CGFloat(subViewCount * kExtraAthleteViewHeight)
                subViewCount += 1
            }
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func parentZipcodeDoneButtonTouched()
    {
        parentZipcodeTextField.resignFirstResponder()
    }
    
    @objc private func parentPhoneNumberDoneButtonTouched()
    {
        parentPhoneNumberTextField.resignFirstResponder()
    }
    
    @IBAction func addAnotherButtonTouched()
    {
        // Limit the number of extra athletes
        if (extraAthleteCount > kMaxExtraAthletes)
        {
            let message = String(format: "The maximum number of athletes that can be submitted is %d.", kMaxExtraAthletes + 1)
            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: message, lastItemCancelType: false) { tag in
                
            }
            return
        }
        
        let extraAthleteView = (UINib(nibName: "ExtraAthleteView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! ExtraAthleteView)
        extraAthleteView.frame = CGRect(x: 0, y: kTopSectionHeight + CGFloat(extraAthleteCount * kExtraAthleteViewHeight), width: kDeviceWidth, height: CGFloat(kExtraAthleteViewHeight))
        extraAthleteView.tag = extraAthleteCount + 100
        extraAthleteView.delegate = self
        extraAthleteView.parentVC = self
        extraAthleteView.initializeView()
        containerScrollView.addSubview(extraAthleteView)
        extraAthleteCount += 1
        
        // Resize the scrollView content size and move the lowerContainer
        containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: kTopSectionHeight + CGFloat(extraAthleteCount * kExtraAthleteViewHeight) + lowerContainerView.frame.size.height)
        lowerContainerView.frame.origin.y = kTopSectionHeight + CGFloat(extraAthleteCount * kExtraAthleteViewHeight)
    }
    
    @IBAction func submitButtonTouched()
    {     
        self.updateSpecialOffer()
    }
    
    @IBAction func testAlertTouched(_ sender: UIButton)
    {
        let buttonBackgroundColor = UIColor.init(hexString: "036FBA")
        self.showSpecialOffersAlertView(title: "Success!", message: "Your information has been submitted to the NCSA.", buttonTitle: "GOT IT", buttonBackgroundColor: buttonBackgroundColor, buttonTextColor: UIColor.mpWhiteColor())
    }
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        if ((firstNameTextField.text?.count == 0) ||
            (lastNameTextField.text?.count == 0) ||
            (emailTextField.text?.count == 0) ||
            (parentZipcodeTextField.text?.count != 5) ||
            (graduationYearTextField.text?.count == 0) ||
            (primarySportTextField.text?.count == 0) ||
            (parentFirstNameTextField.text?.count == 0) ||
            (parentLastNameTextField.text?.count == 0) ||
            (parentEmailTextField.text?.count == 0) ||
            (parentPhoneNumberTextField.text?.count != 12))
        {
            submitButton.isEnabled = false
            submitButton.alpha = 0.5
        }
        else
        {
            // Now check the NCSA extra athlete dictionary for valid items
            var extraAthletesAreGood = true
            
            for subView in containerScrollView.subviews
            {
                if (subView.tag >= 100)
                {
                    let tagString = String(subView.tag)
                    if let extraAthleteDictionary = SharedData.ncsaExtraAthleteDictionary[tagString] as? Dictionary<String,Any>
                    {
                        let isValid = extraAthleteDictionary["isValid"] as! Bool
                        if (isValid == false)
                        {
                            extraAthletesAreGood = false
                            break
                        }
                    }
                }
            }
            
            if (extraAthletesAreGood == true)
            {
                submitButton.isEnabled = true
                submitButton.alpha = 1.0
            }
            else
            {
                submitButton.isEnabled = false
                submitButton.alpha = 0.5
            }
        }
    }
    
    // MARK: - Initialize Containers
    
    private func initializeContainers()
    {
        firstNameContainerView.layer.cornerRadius = 8
        firstNameContainerView.layer.borderWidth = 1
        firstNameContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        firstNameContainerView.clipsToBounds = true
        
        lastNameContainerView.layer.cornerRadius = 8
        lastNameContainerView.layer.borderWidth = 1
        lastNameContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        lastNameContainerView.clipsToBounds = true
        
        emailContainerView.layer.cornerRadius = 8
        emailContainerView.layer.borderWidth = 1
        emailContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        emailContainerView.clipsToBounds = true
        
        graduationYearContainerView.layer.cornerRadius = 8
        graduationYearContainerView.layer.borderWidth = 1
        graduationYearContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        graduationYearContainerView.clipsToBounds = true
        
        primarySportContainerView.layer.cornerRadius = 8
        primarySportContainerView.layer.borderWidth = 1
        primarySportContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        primarySportContainerView.clipsToBounds = true
        
        parentFirstNameContainerView.layer.cornerRadius = 8
        parentFirstNameContainerView.layer.borderWidth = 1
        parentFirstNameContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        parentFirstNameContainerView.clipsToBounds = true
        
        parentLastNameContainerView.layer.cornerRadius = 8
        parentLastNameContainerView.layer.borderWidth = 1
        parentLastNameContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        parentLastNameContainerView.clipsToBounds = true
        
        parentEmailContainerView.layer.cornerRadius = 8
        parentEmailContainerView.layer.borderWidth = 1
        parentEmailContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        parentEmailContainerView.clipsToBounds = true
        
        parentPhoneNumberContainerView.layer.cornerRadius = 8
        parentPhoneNumberContainerView.layer.borderWidth = 1
        parentPhoneNumberContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        parentPhoneNumberContainerView.clipsToBounds = true
        
        parentZipcodeContainerView.layer.cornerRadius = 8
        parentZipcodeContainerView.layer.borderWidth = 1
        parentZipcodeContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        parentZipcodeContainerView.clipsToBounds = true
        
        parentFirstNameTextField.text = kUserDefaults.string(forKey: kUserFirstNameKey)
        parentLastNameTextField.text = kUserDefaults.string(forKey: kUserLastNameKey)
        parentEmailTextField.text = kUserDefaults.string(forKey: kUserEmailKey)
        parentZipcodeTextField.text = kUserDefaults.string(forKey: kUserZipKey)
    }
    
    // MARK: - Build Years Array
    
    private func buildYearsArray()
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let currentYearString = dateFormatter.string(from: Date())
        let currentYear = Int(currentYearString)!
        
        // Get the current month
        dateFormatter.dateFormat = "M"
        let currentMonth = dateFormatter.string(from: Date())
        
        var firstYear = 0
        
        switch currentMonth
        {
        case "1":
            firstYear = currentYear
        case "2":
            firstYear = currentYear
        case "3":
            firstYear = currentYear
        case "4":
            firstYear = currentYear
        case "5":
            firstYear = currentYear
        case "6":
            firstYear = currentYear
        case "7":
            firstYear = currentYear
        case "8":
            firstYear = currentYear // currentYear + 1, changed in V6.1.3
        case "9":
            firstYear = currentYear + 1
        case "10":
            firstYear = currentYear + 1
        case "11":
            firstYear = currentYear + 1
        case "12":
            firstYear = currentYear + 1
        default:
            firstYear = 0
        }
        
        yearsArray.append(String(firstYear))
        yearsArray.append(String(firstYear + 1))
        yearsArray.append(String(firstYear + 2))
        yearsArray.append(String(firstYear + 3))
        yearsArray.append(String(firstYear + 4))
        //yearsArray.append(String(firstYear + 5))
    }
    
    // MARK: - Accessory Views
    
    private func addParentZipcodeAccessoryView()
    {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        accessoryView.backgroundColor = UIColor.mpOffWhiteNavColor()
        
        let horizLine = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 1))
        horizLine.backgroundColor = UIColor.mpHeaderBackgroundColor()
        accessoryView.addSubview(horizLine)
        
        let doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: kDeviceWidth - 82, y: 5, width: 80, height: 30)
        doneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        doneButton.addTarget(self, action: #selector(parentZipcodeDoneButtonTouched), for: .touchUpInside)
        accessoryView.addSubview(doneButton)
        
        parentZipcodeTextField!.inputAccessoryView = accessoryView
    }
    
    private func addParentPhoneNumberAccessoryView()
    {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        accessoryView.backgroundColor = UIColor.mpOffWhiteNavColor()
        
        let horizLine = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 1))
        horizLine.backgroundColor = UIColor.mpHeaderBackgroundColor()
        accessoryView.addSubview(horizLine)
        
        let doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: kDeviceWidth - 82, y: 5, width: 80, height: 30)
        doneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        doneButton.addTarget(self, action: #selector(parentPhoneNumberDoneButtonTouched), for: .touchUpInside)
        accessoryView.addSubview(doneButton)
        
        parentPhoneNumberTextField!.inputAccessoryView = accessoryView
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // Size the fakeStatusBar, navBar, and scrollView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: kDeviceWidth, height: navView.frame.size.height)
        containerScrollView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: kDeviceHeight - navView.frame.origin.y - navView.frame.size.height)
        
        // The contentSize will increase when the keyboard is visible so the last container can be seen
        containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: kTopSectionHeight + lowerContainerView.frame.size.height)
        
        submitButton.layer.cornerRadius = submitButton.frame.size.height / 2.0
        submitButton.clipsToBounds = true
        
        submitButton.isEnabled = false
        submitButton.alpha = 0.5
        
        self.initializeContainers()
        
        self.addParentZipcodeAccessoryView()
        self.addParentPhoneNumberAccessoryView()
        
        // Build the yearsArray
        self.buildYearsArray()
        
        // Empty the NCSA extra athlete dictionary
        SharedData.ncsaExtraAthleteDictionary.removeAll()
        
        // Add hyperlinks to the disclaimerTextView
        let policyString = "NCSA will receive this information to set up a profile and contact you to discuss your college recruiting game plan. Your information may be shared according to NCSA's privacy policy and terms and conditions of use."
        
        let attributedString = NSMutableAttributedString(string: policyString, attributes: [NSAttributedString.Key.font: UIFont.mpRegularFontWith(size: 14), NSAttributedString.Key.foregroundColor: UIColor.mpDarkGrayColor()])
                
        let range1 = policyString.range(of: "terms and conditions of use")
        let convertedRange1 = NSRange(range1!, in: policyString)
        let termsUrl = URL(string: kNCSATermsOfUseUrl)!
        
        let range2 = policyString.range(of: "privacy policy")
        let convertedRange2 = NSRange(range2!, in: policyString)
        let privacyUrl = URL(string: kNCSAPrivacyPolicyUrl)!
        
        // Set the links
        attributedString.setAttributes([.link: termsUrl], range: convertedRange1)
        attributedString.setAttributes([.link: privacyUrl], range: convertedRange2)
        
        disclaimerTextView.attributedText = attributedString

        // Set how links should appear: blue and underlined
        //disclaimerTextView.linkTextAttributes = [.foregroundColor: UIColor.mpBlueColor(), .underlineStyle: NSUnderlineStyle.single.rawValue]
        disclaimerTextView.linkTextAttributes = [.foregroundColor: UIColor.mpBlueColor()]
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        
        setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.mpWhiteColor()
        self.navigationController?.navigationBar.tintColor = UIColor.mpBlackColor()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.mpBlackColor(), .font: UIFont.mpSemiBoldFontWith(size: kNavBarFontSize)]
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.lightContent
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
        tickTimer.invalidate()
        tickTimer = nil
    }
}
