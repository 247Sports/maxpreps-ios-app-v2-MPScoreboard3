//
//  ExtraAthleteView.swift
//  MPScoreboard3
//
//  Created by David Smith on 12/12/22.
//

import UIKit

protocol ExtraAthleteViewDelegate: AnyObject
{
    func extraAthleteRemoveButtonTouched(tag: Int)
}   

class ExtraAthleteView: UIView, UITextFieldDelegate, IQActionSheetPickerViewDelegate
{
    weak var delegate: ExtraAthleteViewDelegate?
    
    @IBOutlet weak var firstNameContainerView: UIView!
    @IBOutlet weak var lastNameContainerView: UIView!
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var graduationYearContainerView: UIView!
    @IBOutlet weak var primarySportContainerView: UIView!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var graduationYearTextField: UITextField!
    @IBOutlet weak var primarySportTextField: UITextField!
    
    var parentVC: UIViewController!
    
    private var yearsArray = [] as Array<String>
    private var tickTimer: Timer!
    
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
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        firstNameContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        lastNameContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        emailContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        graduationYearContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        primarySportContainerView.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        
        if ((textField == firstNameTextField) || (textField == lastNameTextField))
        {
            if (textField.text!.containsEmoji == true)
            {
                // Special characters were found
                MiscHelper.showAlert(in: self.parentVC, withActionNames: ["OK"], title: "We're Sorry", message: "You can't use special characters in a name.", lastItemCancelType: false) { tag in
                    
                    textField.text! = ""
                }
                return
            }
            
            // Check for bad words
            let badName = IODProfanityFilter.rangesOfFilteredWords(in: textField.text!)
            
            if (badName!.count > 0)
            {
                // Bad word was found
                MiscHelper.showAlert(in: self.parentVC, withActionNames: ["OK"], title: "Language", message: "This name is objectionable and can not be used.", lastItemCancelType: false) { tag in
                    
                    textField.text! = ""
                }
                return
            }
        }
        else if (textField == emailTextField)
        {
            if (MiscHelper.isValidEmailAddress(emailTextField.text!) == false)
            {
                MiscHelper.showAlert(in: self.parentVC, withActionNames: ["OK"], title: "Oops", message: "The email is not a valid format.", lastItemCancelType: false) { tag in
                    
                    self.emailTextField.text = ""
                }
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        return true
    }
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        let tag = String(self.tag)
        
        if ((firstNameTextField.text?.count == 0) ||
            (lastNameTextField.text?.count == 0) ||
            (emailTextField.text?.count == 0) ||
            (graduationYearTextField.text?.count == 0) ||
            (primarySportTextField.text?.count == 0))
        {
            // Clear the NCSA Extra Athlete Dictionary
            let innerDictionary = ["firstName":"", "lastName":"", "email":"", "graduationYear":"", "primarySport":"", "isValid":false] as [String : Any]
            SharedData.ncsaExtraAthleteDictionary[tag] = innerDictionary
        }
        else
        {
            // Set the NCSA Extra Athlete Dictionary
            let innerDictionary = ["firstName":firstNameTextField.text!, "lastName":lastNameTextField.text!, "email":emailTextField.text!, "graduationYear":graduationYearTextField.text!, "primarySport":primarySportTextField.text!, "isValid":true] as [String : Any]
            SharedData.ncsaExtraAthleteDictionary[tag] = innerDictionary
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func removeAthleteButtonTouched(_ sender: UIButton)
    {
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
        
        // Remove the data for this tag from the NCSA extra athletes dictionary
        let tagString = String(self.tag)
        SharedData.ncsaExtraAthleteDictionary[tagString] = nil
        
        self.delegate?.extraAthleteRemoveButtonTouched(tag: self.tag)
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
            firstYear = currentYear + 1
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
        yearsArray.append(String(firstYear + 5))
    }
    
    // MARK: - Initialize View
    
    func initializeView()
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
        
        self.buildYearsArray()
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
    }

}
