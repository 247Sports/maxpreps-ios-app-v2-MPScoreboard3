//
//  ProfileAboutTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/28/21.
//

import UIKit

class ProfileAboutTableViewCell: UITableViewCell, UITextViewDelegate, UITextFieldDelegate, IQActionSheetPickerViewDelegate
{
    @IBOutlet weak var athleteDetailsTextView: UITextView!
    @IBOutlet weak var athleteDetailsTextCountLabel: UILabel!
    @IBOutlet weak var facebookTextField: UITextField!
    @IBOutlet weak var twitterTextField: UITextField!
    @IBOutlet weak var classYearTextField: UITextField!
    @IBOutlet weak var saveInfoButton: UIButton!
    
    var athleteDetailsText = ""
    var facebookText = ""
    var twitterText = ""
    var classYearText = ""
    var athleteDetailsTextViewActive = false
    
    private var tickTimer: Timer!
    
    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelectTitles titles: [String])
    {
        classYearTextField.text = titles.first
        classYearText = titles.first!
    }
    
    func actionSheetPickerViewDidCancel(_ pickerView: IQActionSheetPickerView)
    {
        
    }
    
    // MARK: - TextView Delegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        // This is used in the keyboard notification in the parent class to prevent the tableView from scrolling
        athleteDetailsTextViewActive = true
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        textView.textColor = UIColor.mpBlackColor()
        
        if (textView.text == kUserProfileBioTextViewDefaultText)
        {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        athleteDetailsTextViewActive = false
        
        if (textView.text == "")
        {
            textView.text = kUserProfileBioTextViewDefaultText
            textView.textColor = UIColor.mpLightGrayColor()
            
            athleteDetailsText = ""
        }
        else
        {
            let badWords = IODProfanityFilter.rangesOfFilteredWords(in: athleteDetailsTextView.text)
            
            if (badWords!.count > 0)
            {
                MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "Language", message: "The text that you have entered is objectionable and can not be used.", lastItemCancelType: false) { tag in

                    self.athleteDetailsTextView.text = kUserProfileBioTextViewDefaultText
                    self.athleteDetailsTextView.textColor = UIColor.mpLightGrayColor()
                    self.athleteDetailsText = ""
                }
                return
            }
            athleteDetailsText = athleteDetailsTextView.text
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if (text == "\n")
        {
            return false
        }
        
        if (range.location > 499)
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    // MARK: - TextField Delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if (textField == classYearTextField)
        {
            var yearsArray = [] as! Array<String>
            
            // Get the current year
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            let currentYearString = dateFormatter.string(from: Date())
            let currentYear = Int(currentYearString)!
            
            for year in 2004...currentYear + 8
            {
                yearsArray.append(String(year))
            }
            
            let reversedYearsArray = Array(yearsArray.reversed())
            
            let picker = IQActionSheetPickerView(title: "Select Year", delegate: self)
            picker.toolbarButtonColor = UIColor.mpWhiteColor()
            picker.toolbarTintColor = UIColor.mpPickerToolbarColor()
            picker.titlesForComponents = [reversedYearsArray]
            picker.tag = 1
            picker.show()
            
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        let badWords = IODProfanityFilter.rangesOfFilteredWords(in: textField.text)
        
        if (badWords!.count > 0)
        {
            MiscHelper.showAlert(in: kAppKeyWindow.rootViewController, withActionNames: ["OK"], title: "Language", message: "The text that you have entered is objectionable and can not be used.", lastItemCancelType: false) { tag in

                if (textField == self.facebookTextField)
                {
                    self.facebookTextField.text = ""
                    self.facebookText = ""
                }
                
                if (textField == self.twitterTextField)
                {
                    self.twitterTextField.text = ""
                    self.twitterText = ""
                }
            }
            return
        }
        else
        {
            if (textField == self.facebookTextField)
            {
                self.facebookText = self.facebookTextField.text!
            }
            
            if (textField == self.twitterTextField)
            {
                self.twitterText = self.twitterTextField.text!
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()

        return true
    }
    
    // MARK: - Load Data Method
    
    func loadData(data: Dictionary<String,Any>)
    {
        let bio = data["bio"] as? String ?? ""
        
        if (bio.count > 0)
        {
            // Convert the string to a data object, then back to a string using ASCII encoding
            //let data : NSData = bio.data(using: String.Encoding.nonLossyASCII)! as NSData
            //let valueUnicode : String = String(data: data as Data, encoding: String.Encoding.utf8)!
            //let dataA : NSData = valueUnicode.data(using: String.Encoding.utf8)! as NSData
            //let valueEmoji : String = String(data: dataA as Data, encoding: String.Encoding.nonLossyASCII)!
            athleteDetailsTextView.text = bio
            athleteDetailsTextView.textColor = UIColor.mpBlackColor()
        }
        else
        {
            athleteDetailsTextView.text = kUserProfileBioTextViewDefaultText
            athleteDetailsTextView.textColor = UIColor.mpLightGrayColor()
        }
        
        let facebookProfile = data["facebookProfile"] as? String ?? ""
        facebookTextField.text = facebookProfile
        
        let twitterHandle = data["twitterHandle"] as? String ?? ""
        twitterTextField.text = twitterHandle
        
        let graduatingClass = data["graduatingClass"] as? Int ?? -1
        if (graduatingClass != -1)
        {
            classYearTextField.text = String(graduatingClass)
        }
    }
    
    // MARK: - Button Methods
    
    @objc private func athleteDetailsDoneButtonTouched()
    {
        athleteDetailsTextView.resignFirstResponder()
    }
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        // Update the athleteDetailsTextCountLabel
        if (athleteDetailsTextView.text != kUserProfileBioTextViewDefaultText)
        {
            athleteDetailsTextCountLabel.text = String(athleteDetailsTextView.text!.count) + " / 500 Characters"
        }
        else
        {
            athleteDetailsTextCountLabel.text = "0 / 500 Characters"
        }
    }
    
    // MARK: - Keyboard Accessory Views
    
    private func addKeyboardAccessoryView()
    {
        let athleteDetailsAccessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        athleteDetailsAccessoryView.backgroundColor = UIColor.mpRedColor()
        
        let athleteDetailsDoneButton = UIButton(type: .custom)
        athleteDetailsDoneButton.frame = CGRect(x: kDeviceWidth - 85, y: 5, width: 80, height: 30)
        athleteDetailsDoneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        athleteDetailsDoneButton.setTitle("Done", for: .normal)
        athleteDetailsDoneButton.setTitleColor(UIColor.mpWhiteColor(), for: .normal)
        athleteDetailsDoneButton.addTarget(self, action: #selector(athleteDetailsDoneButtonTouched), for: .touchUpInside)
        athleteDetailsAccessoryView.addSubview(athleteDetailsDoneButton)
        athleteDetailsTextView!.inputAccessoryView = athleteDetailsAccessoryView
    
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        athleteDetailsTextView.layer.cornerRadius = 6
        athleteDetailsTextView.layer.borderWidth = 0.5
        athleteDetailsTextView.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        athleteDetailsTextView.clipsToBounds = true
        
        saveInfoButton.layer.cornerRadius = 8
        saveInfoButton.clipsToBounds = true
        
        self.addKeyboardAccessoryView()
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)

    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    deinit
    {
        tickTimer.invalidate()
        tickTimer = nil
    }
}
