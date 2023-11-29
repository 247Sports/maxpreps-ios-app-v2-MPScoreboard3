//
//  NewEditMeasurementsViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 8/15/23.
//

import UIKit

protocol NewEditMeasurementsViewControllerDelegate: AnyObject
{
    func editMeasurementsViewControllerDidCancel()
    func editMeasurementsViewControllerDidSave()
}

class NewEditMeasurementsViewController: UIViewController, UITextFieldDelegate, IQActionSheetPickerViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var wingspanTextField: UITextField!
    @IBOutlet weak var standingReachTextField: UITextField!
    @IBOutlet weak var dominantHandTextField: UITextField!
    @IBOutlet weak var dominantFootTextField: UITextField!
    @IBOutlet weak var benchTextField: UITextField!
    @IBOutlet weak var squatTextField: UITextField!
    @IBOutlet weak var deadliftTextField: UITextField!
    @IBOutlet weak var shuttleTextField: UITextField!
    @IBOutlet weak var fortyYardDashTextField: UITextField!
    @IBOutlet weak var verticalJumpTextField: UITextField!
    @IBOutlet weak var broadJumpTextField: UITextField!
    @IBOutlet weak var benchContainerView: UIView!
    @IBOutlet weak var squatContainerView: UIView!
    @IBOutlet weak var deadliftContainerView: UIView!
    @IBOutlet weak var shuttleContainerView: UIView!
    @IBOutlet weak var fortyYardDashContainerView: UIView!
    
    weak var delegate: NewEditMeasurementsViewControllerDelegate?
    
    var careerId = ""
    var measurementsDictionary: Dictionary<String,Any> = [:]
    
    private var kContainerHeight = 1094.0
    private var containerViewHeight = 0.0
    private var editAttempted = false
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Save Data
    
    private func saveData()
    {
        // Remove the unneeded text from the various fields
        
        var heightFeet = ""
        var heightInches = ""
        if (heightTextField.text! != "")
        {
            let array = heightTextField.text!.components(separatedBy: "'")
            heightFeet = array.first!
            heightInches = array.last!.replacingOccurrences(of: "\"", with: "")
        }
        
        var weight = ""
        if (weightTextField.text! != "")
        {
            weight = weightTextField.text!.replacingOccurrences(of: " lbs", with: "")
        }
        
        var wingspanFeet = ""
        var wingspanInches = ""
        if (wingspanTextField.text! != "")
        {
            let array = wingspanTextField.text!.components(separatedBy: "'")
            wingspanFeet = array.first!
            wingspanInches = array.last!.replacingOccurrences(of: "\"", with: "")
        }
        
        var standingReachFeet = ""
        var standingReachInches = ""
        if (standingReachTextField.text! != "")
        {
            let array = standingReachTextField.text!.components(separatedBy: "'")
            standingReachFeet = array.first!
            standingReachInches = array.last!.replacingOccurrences(of: "\"", with: "")
        }
        
        let dominantHand = dominantHandTextField.text!.lowercased()
        let dominantFoot = dominantFootTextField.text!.lowercased()
        
        var benchPress = ""
        if (benchTextField.text! != "")
        {
            benchPress = benchTextField.text!.replacingOccurrences(of: " lbs", with: "")
        }
        
        var squat = ""
        if (squatTextField.text! != "")
        {
            squat = squatTextField.text!.replacingOccurrences(of: " lbs", with: "")
        }
        
        var deadlift = ""
        if (deadliftTextField.text! != "")
        {
            deadlift = deadliftTextField.text!.replacingOccurrences(of: " lbs", with: "")
        }
        
        var shuttle = ""
        if (shuttleTextField.text! != "")
        {
            shuttle = shuttleTextField.text!.replacingOccurrences(of: " secs", with: "")
        }
        
        var fortyYard = ""
        if (fortyYardDashTextField.text! != "")
        {
            fortyYard = fortyYardDashTextField.text!.replacingOccurrences(of: " secs", with: "")
        }
        
        var verticalJump = ""
        if (verticalJumpTextField.text! != "")
        {
            verticalJump = verticalJumpTextField.text!.replacingOccurrences(of: "\"", with: "")
        }
        
        var broadJumpFeet = ""
        var broadJumpInches = ""
        if (broadJumpTextField.text! != "")
        {
            let array = broadJumpTextField.text!.components(separatedBy: "'")
            broadJumpFeet = array.first!
            broadJumpInches = array.last!.replacingOccurrences(of: "\"", with: "")
        }
        
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        CareerFeeds.updateAthleteMeasurements(careerId: self.careerId, heightFeet: heightFeet, heightInches: heightInches, weight: weight, wingspanFeet: wingspanFeet, wingspanInches: wingspanInches, standingReachFeet: standingReachFeet, standingReachInches: standingReachInches, dominantHand: dominantHand, dominantFoot: dominantFoot, benchPress: benchPress, squat: squat, deadlift: deadlift, shuttle: shuttle, fortyYard: fortyYard, verticalJump: verticalJump, broadJumpFeet: broadJumpFeet, broadJumpInches: broadJumpInches) { result, error in
            
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
                print("Update Athlete Measurements Success")
                
                OverlayView.showTwoLinePopupOverlay(withMessage: "Success! Your changes will take a few minutes to be reflected on your profile.", boldText: "Success!", withDismissHandler: {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
                    {
                        self.delegate?.editMeasurementsViewControllerDidSave()
                    }
                })
            }
            else
            {
                print("Update Athlete Measurements Failed")
                
                let errorMessage = error?.localizedDescription
                MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "We're Sorry", message: errorMessage, lastItemCancelType: false) { tag in
                    
                }
            }
        }
    }
    
    // MARK: - Load Data
    
    private func loadData()
    {
        if let heightFeet = measurementsDictionary["heightFeet"] as? Double
        {
            if let heightInches = measurementsDictionary["heightInches"] as? Double
            {
                heightTextField.text = String(format: "%d'%d\"", Int(heightFeet), Int(heightInches))
            }
        }
        
        if let weight = measurementsDictionary["weight"] as? Double
        {
            weightTextField.text = String(format: "%d lbs", Int(weight))
        }
        
        if let wingspanFeet = measurementsDictionary["wingspanFeet"] as? Double
        {
            if let wingspanInches = measurementsDictionary["wingspanInches"] as? Double
            {
                wingspanTextField.text = String(format: "%d'%d\"", Int(wingspanFeet), Int(wingspanInches))
            }
        }
        
        if let standingReachFeet = measurementsDictionary["standingReachFeet"] as? Double
        {
            if let standingReachInches = measurementsDictionary["standingReachInches"] as? Double
            {
                standingReachTextField.text = String(format: "%d'%d\"", Int(standingReachFeet), Int(standingReachInches))
            }
        }
        
        if let dominantHand = measurementsDictionary["dominantHand"] as? String
        {
            dominantHandTextField.text = dominantHand.capitalized
        }
        
        if let dominantFoot = measurementsDictionary["dominantFoot"] as? String
        {
            dominantFootTextField.text = dominantFoot.capitalized
        }
        
        if let benchPress = measurementsDictionary["benchPress"] as? Double
        {
            benchTextField.text = String(format: "%d lbs", Int(benchPress))
        }
        
        if let squat = measurementsDictionary["squat"] as? Double
        {
            squatTextField.text = String(format: "%d lbs", Int(squat))
        }
        
        if let deadlift = measurementsDictionary["deadlift"] as? Double
        {
            deadliftTextField.text = String(format: "%d lbs", Int(deadlift))
        }
        
        if let shutttle = measurementsDictionary["shuttleRunTime"] as? Double
        {
            shuttleTextField.text = String(format: "%1.3f secs", Float(shutttle))
        }
        
        if let fortyYard = measurementsDictionary["fortyYardDashTime"] as? Double
        {
            fortyYardDashTextField.text = String(format: "%1.3f secs", Float(fortyYard))
        }
        
        if let verticalJump = measurementsDictionary["verticalJump"] as? Double
        {
            verticalJumpTextField.text = String(format: "%d\"", Int(verticalJump))
        }
        
        if let broadJumpFeet = measurementsDictionary["broadJumpFeet"] as? Double
        {
            if let broadJumpInches = measurementsDictionary["broadJumpInches"] as? Double
            {
                broadJumpTextField.text = String(format: "%d'%d\"", Int(broadJumpFeet), Int(broadJumpInches))
            }
        }
    }
    
    // MARK: - TextField Delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        editAttempted = true
        
        if (textField == heightTextField)
        {
            let feetArray = ["--","4'","5'","6'","7'"]
            let inchArray = ["0\"","1\"","2\"","3\"","4\"","5\"","6\"","7\"","8\"","9\"", "10\"","11\""]
            
            let picker = IQActionSheetPickerView(title: "Select Height", delegate: self)
            picker.toolbarButtonColor = UIColor.mpDarkGrayColor()
            picker.toolbarTintColor = UIColor.mpGrayButtonBorderColor()
            picker.titlesForComponents = [feetArray, inchArray]
            picker.tag = 1
            
            // Preload the index if possible
            if (heightTextField.text! != "")
            {
                let array = heightTextField.text!.components(separatedBy: "'")
                let heightFeet = array.first! + "'"
                let heightInches = array.last!
                
                // Preload the starting index if possible
                if let feetIndex = feetArray.firstIndex(of: heightFeet)
                {
                    if let inchIndex = inchArray.firstIndex(of: heightInches)
                    {
                        picker.selectIndexes([NSNumber(integerLiteral: feetIndex), NSNumber(integerLiteral: inchIndex)], animated: false)
                    }
                }
            }
            
            picker.show()
            return false
        }
        else if (textField == wingspanTextField)
        {
            let feetArray = ["--","4'","5'","6'","7'"]
            let inchArray = ["0\"","1\"","2\"","3\"","4\"","5\"","6\"","7\"","8\"","9\"", "10\"","11\""]
            
            let picker = IQActionSheetPickerView(title: "Select Height", delegate: self)
            picker.toolbarButtonColor = UIColor.mpDarkGrayColor()
            picker.toolbarTintColor = UIColor.mpGrayButtonBorderColor()
            picker.titlesForComponents = [feetArray, inchArray]
            picker.tag = 2
            
            // Preload the index if possible
            if (wingspanTextField.text! != "")
            {
                let array = wingspanTextField.text!.components(separatedBy: "'")
                let heightFeet = array.first! + "'"
                let heightInches = array.last!
                
                // Preload the starting index if possible
                if let feetIndex = feetArray.firstIndex(of: heightFeet)
                {
                    if let inchIndex = inchArray.firstIndex(of: heightInches)
                    {
                        picker.selectIndexes([NSNumber(integerLiteral: feetIndex), NSNumber(integerLiteral: inchIndex)], animated: false)
                    }
                }
            }
            
            picker.show()
            return false
        }
        else if (textField == standingReachTextField)
        {
            let feetArray = ["--","5'","6'","7'","8'","9'"]
            let inchArray = ["0\"","1\"","2\"","3\"","4\"","5\"","6\"","7\"","8\"","9\"", "10\"","11\""]
            
            let picker = IQActionSheetPickerView(title: "Select Height", delegate: self)
            picker.toolbarButtonColor = UIColor.mpDarkGrayColor()
            picker.toolbarTintColor = UIColor.mpGrayButtonBorderColor()
            picker.titlesForComponents = [feetArray, inchArray]
            picker.tag = 3
            
            // Preload the index if possible
            if (standingReachTextField.text! != "")
            {
                let array = standingReachTextField.text!.components(separatedBy: "'")
                let heightFeet = array.first! + "'"
                let heightInches = array.last!
                
                // Preload the starting index if possible
                if let feetIndex = feetArray.firstIndex(of: heightFeet)
                {
                    if let inchIndex = inchArray.firstIndex(of: heightInches)
                    {
                        picker.selectIndexes([NSNumber(integerLiteral: feetIndex), NSNumber(integerLiteral: inchIndex)], animated: false)
                    }
                }
            }
            
            picker.show()
            return false
        }
        else if (textField == dominantHandTextField)
        {
            let itemArray = ["--","Left","Right","Both"]
            
            let picker = IQActionSheetPickerView(title: "Select Height", delegate: self)
            picker.toolbarButtonColor = UIColor.mpDarkGrayColor()
            picker.toolbarTintColor = UIColor.mpGrayButtonBorderColor()
            picker.titlesForComponents = [itemArray]
            picker.tag = 4
            
            // Preload the starting index if possible
            if (dominantHandTextField.text! != "")
            {
                if let startingIndex = itemArray.firstIndex(of: dominantHandTextField.text!)
                {
                    picker.selectIndexes([NSNumber(integerLiteral: startingIndex)], animated: false)
                }
            }
            
            picker.show()
            return false
        }
        else if (textField == dominantFootTextField)
        {
            let itemArray = ["--","Left","Right","Both"]
            
            let picker = IQActionSheetPickerView(title: "Select Height", delegate: self)
            picker.toolbarButtonColor = UIColor.mpDarkGrayColor()
            picker.toolbarTintColor = UIColor.mpGrayButtonBorderColor()
            picker.titlesForComponents = [itemArray]
            picker.tag = 5
            
            // Preload the starting index if possible
            if (dominantFootTextField.text! != "")
            {
                if let startingIndex = itemArray.firstIndex(of: dominantFootTextField.text!)
                {
                    picker.selectIndexes([NSNumber(integerLiteral: startingIndex)], animated: false)
                }
            }
            
            picker.show()
            return false
        }
        else if (textField == verticalJumpTextField)
        {
            // Buld an array with values from 4" to 48"
            var inchArray = ["--"]
            for i in 4 ... 48
            {
                inchArray.append(String(i) + "\"")
            }
            
            let picker = IQActionSheetPickerView(title: "Select Height", delegate: self)
            picker.toolbarButtonColor = UIColor.mpDarkGrayColor()
            picker.toolbarTintColor = UIColor.mpGrayButtonBorderColor()
            picker.titlesForComponents = [inchArray]
            picker.tag = 6
            
            // Preload the starting index if possible
            if (verticalJumpTextField.text! != "")
            {
                if let startingIndex = inchArray.firstIndex(of: verticalJumpTextField.text!)
                {
                    picker.selectIndexes([NSNumber(integerLiteral: startingIndex)], animated: false)
                }
            }
            
            picker.show()
            
            return false
        }
        else if (textField == broadJumpTextField)
        {
            let feetArray = ["--","2'","3'","4'","5'","6'","7'","8'","9'","10'","11'","12'"]
            let inchArray = ["0\"","1\"","2\"","3\"","4\"","5\"","6\"","7\"","8\"","9\"","10\"","11\""]
            
            let picker = IQActionSheetPickerView(title: "Select Height", delegate: self)
            picker.toolbarButtonColor = UIColor.mpDarkGrayColor()
            picker.toolbarTintColor = UIColor.mpGrayButtonBorderColor()
            picker.titlesForComponents = [feetArray, inchArray]
            picker.tag = 7
            
            // Preload the index if possible
            if (broadJumpTextField.text! != "")
            {
                let array = broadJumpTextField.text!.components(separatedBy: "'")
                let heightFeet = array.first! + "'"
                let heightInches = array.last!
                
                // Preload the starting index if possible
                if let feetIndex = feetArray.firstIndex(of: heightFeet)
                {
                    if let inchIndex = inchArray.firstIndex(of: heightInches)
                    {
                        picker.selectIndexes([NSNumber(integerLiteral: feetIndex), NSNumber(integerLiteral: inchIndex)], animated: false)
                    }
                }
            }
            
            picker.show()
            return false
        }
        else if (textField == weightTextField)
        {
            weightTextField.text! = ""
            return true
        }
        else if (textField == benchTextField)
        {
            benchTextField.text! = ""
            return true
        }
        else if (textField == squatTextField)
        {
            squatTextField.text! = ""
            return true
        }
        else if (textField == deadliftTextField)
        {
            deadliftTextField.text! = ""
            return true
        }
        else if (textField == shuttleTextField)
        {
            shuttleTextField.text! = ""
            return true
        }
        else if (textField == fortyYardDashTextField)
        {
            fortyYardDashTextField.text! = ""
            return true
        }
        else
        {
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        if (textField == weightTextField)
        {
            if (weightTextField.text! != "")
            {
                // Convert the weight into an integer so any leading zeroes will be removed
                let integerWeight = Int(weightTextField.text!)
                if (integerWeight! == 0)
                {
                    weightTextField.text! = ""
                }
                else if ((integerWeight! < 80) || (integerWeight! > 400))
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Weight Error", message: "Weight must be from 80 to 400 lbs.", lastItemCancelType: false) { tag in
                        
                        self.weightTextField.text! = ""
                    }
                }
                else
                {
                    // Append lbs to the value
                    weightTextField.text! = String(integerWeight!) + " lbs"
                }
            }
        }
        else if (textField == benchTextField)
        {
            if (benchTextField.text! != "")
            {
                // Convert the weight into an integer so any leading zeroes will be removed
                let integerWeight = Int(benchTextField.text!)
                if (integerWeight! == 0)
                {
                    benchTextField.text! = ""
                }
                else if ((integerWeight! < 50) || (integerWeight! > 700))
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Bench Press Error", message: "Bench press must be from 50 to 700 lbs.", lastItemCancelType: false) { tag in
                        
                        self.benchTextField.text! = ""
                    }
                }
                else
                {
                    // Append lbs to the value
                    benchTextField.text! = String(integerWeight!) + " lbs"
                }
            }
        }
        else if (textField == squatTextField)
        {
            if (squatTextField.text! != "")
            {
                // Convert the weight into an integer so any leading zeroes will be removed
                let integerWeight = Int(squatTextField.text!)
                if (integerWeight! == 0)
                {
                    squatTextField.text! = ""
                }
                else if ((integerWeight! < 50) || (integerWeight! > 800))
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Squat Error", message: "Squat must be from 50 to 800 lbs.", lastItemCancelType: false) { tag in
                        
                        self.squatTextField.text! = ""
                    }
                }
                else
                {
                    // Append lbs to the value
                    squatTextField.text! = String(integerWeight!) + " lbs"
                }
            }
        }
        else if (textField == deadliftTextField)
        {
            if (deadliftTextField.text! != "")
            {
                // Convert the weight into an integer so any leading zeroes will be removed
                let integerWeight = Int(deadliftTextField.text!)
                if (integerWeight! == 0)
                {
                    deadliftTextField.text! = ""
                }
                else if ((integerWeight! < 50) || (integerWeight! > 800))
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Deadlift Error", message: "Deadlift must be from 50 to 800 lbs.", lastItemCancelType: false) { tag in
                        
                        self.deadliftTextField.text! = ""
                    }
                }
                else
                {
                    // Append lbs to the value
                    deadliftTextField.text! = String(integerWeight!) + " lbs"
                }
            }
        }
        else if (textField == shuttleTextField)
        {
            if (textField.text != "")
            {
                // Check if this is a number from 3.8 to 12.0
                let double = Double(textField.text!) ?? -1.0
                
                if (((double < 3.8) || (double > 12)) || (double == -1.0))
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Shuttle Error", message: "Shuttle must be a number from 3.8 to 12 secs.", lastItemCancelType: false) { tag in
                        
                        self.shuttleTextField.text = ""
                    }
                }
                else
                {
                    // Append secs to the value
                    shuttleTextField.text! = String(format: "%1.3f secs", Float(double))
                }
            }
        }
        else if (textField == fortyYardDashTextField)
        {
            if (textField.text != "")
            {
                // Check if this is a number from 4.2 to 15.0
                let double = Double(textField.text!) ?? -1.0
                
                if (((double < 4.2) || (double > 15)) || (double == -1.0))
                {
                    MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "40-Yard Error", message: "40-yard dash time must be a number from 4.2 to 15 secs.", lastItemCancelType: false) { tag in
                        
                        self.fortyYardDashTextField.text = ""
                    }
                }
                else
                {
                    // Append secs to the value
                    fortyYardDashTextField.text! = String(format: "%1.3f secs", Float(double))
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
        if ((textField == weightTextField) ||  (textField == benchTextField) || (textField == squatTextField) || (textField == deadliftTextField))
        {
            // Only allow up to 3 numbers
            if (range.location > 2)
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
        else if (textField == shuttleTextField) // Only allow up to 6 characters
        {
            if (range.location > 5)
            {
                return false
            }
            else
            {
                if ((string == ".") && (shuttleTextField.text?.contains(".") == true))
                {
                    return false
                }
                else
                {
                    return true
                }
            }
        }
        else if (textField == fortyYardDashTextField) // Only allow up to 6 characters
        {
            if (range.location > 5)
            {
                return false
            }
            else
            {
                if ((string == ".") && (fortyYardDashTextField.text?.contains(".") == true))
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
    
    // MARK: - IQActionPickerView Delegate
    
    func actionSheetPickerView(_ pickerView: IQActionSheetPickerView, didSelectTitles titles: [String])
    {
        switch pickerView.tag
        {
        case 1: // Height
            if (titles.first == "--")
            {
                heightTextField.text = ""
            }
            else
            {
                heightTextField.text = titles.first! + titles.last!
            }
            break
            
        case 2: // Wingspan
            if (titles.first == "--")
            {
                wingspanTextField.text = ""
            }
            else
            {
                wingspanTextField.text = titles.first! + titles.last!
            }
            break
            
        case 3: // Standing Reach
            if (titles.first == "--")
            {
                standingReachTextField.text = ""
            }
            else
            {
                standingReachTextField.text = titles.first! + titles.last!
            }
            break
            
        case 4: // Dominant Hand
            if (titles.first == "--")
            {
                dominantHandTextField.text = ""
            }
            else
            {
                dominantHandTextField.text = titles.first!
            }
            break
            
        case 5: // Dominant Foot
            if (titles.first == "--")
            {
                dominantFootTextField.text = ""
            }
            else
            {
                dominantFootTextField.text = titles.first!
            }
            break
            
        case 6: // Vertical Jump
            if (titles.first == "--")
            {
                verticalJumpTextField.text = ""
            }
            else
            {
                verticalJumpTextField.text = titles.first!
            }
            break
            
        case 7: // Broad Jump
            if (titles.first == "--")
            {
                broadJumpTextField.text = ""
            }
            else
            {
                broadJumpTextField.text = titles.first! + titles.last!
            }
            break
            
        default:
            break
        }
        
    }
    
    func actionSheetPickerViewDidCancel(_ pickerView: IQActionSheetPickerView)
    {
        if (pickerView.tag == 5)
        {
            containerScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func cancelButtonTouched()
    {
        if (editAttempted == false)
        {
            self.delegate?.editMeasurementsViewControllerDidCancel()
        }
        else
        {
            MiscHelper.showAlert(in: self, withActionNames: ["Cancel", "Discard"], title: "Discard Changes?", message: "By choosing to discard, you will lose the edits you just made.", lastItemCancelType: false) { tag in
                
                if (tag == 1)
                {
                    self.delegate?.editMeasurementsViewControllerDidCancel()
                }
            }
        } 
    }
    
    @IBAction func saveButtonTouched()
    {
        self.saveData()
    }
    
    @objc private func weightDoneButtonTouched()
    {
        weightTextField.resignFirstResponder()
    }
    
    @objc private func benchDoneButtonTouched()
    {
        benchTextField.resignFirstResponder()
    }
    
    @objc private func squatDoneButtonTouched()
    {
        squatTextField.resignFirstResponder()
    }
    
    @objc private func deadliftDoneButtonTouched()
    {
        deadliftTextField.resignFirstResponder()
    }
    
    @objc private func shuttleDoneButtonTouched()
    {
        shuttleTextField.resignFirstResponder()
    }
    
    @objc private func fortyYardDashDoneButtonTouched()
    {
        fortyYardDashTextField.resignFirstResponder()
    }
    
    // MARK: - Keyboard Accessory Views
    
    private func addWeightKeyboardAccessoryView()
    {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        accessoryView.backgroundColor = UIColor.mpGrayButtonBorderColor()
        
        let doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: kDeviceWidth - 85, y: 6, width: 80, height: 30)
        doneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        doneButton.addTarget(self, action: #selector(weightDoneButtonTouched), for: .touchUpInside)
        accessoryView.addSubview(doneButton)
        weightTextField!.inputAccessoryView = accessoryView
    }
    
    private func addBenchKeyboardAccessoryView()
    {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        accessoryView.backgroundColor = UIColor.mpGrayButtonBorderColor()
        
        let doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: kDeviceWidth - 85, y: 6, width: 80, height: 30)
        doneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        doneButton.addTarget(self, action: #selector(benchDoneButtonTouched), for: .touchUpInside)
        accessoryView.addSubview(doneButton)
        benchTextField!.inputAccessoryView = accessoryView
    }
    
    private func addSquatKeyboardAccessoryView()
    {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        accessoryView.backgroundColor = UIColor.mpGrayButtonBorderColor()
        
        let doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: kDeviceWidth - 85, y: 6, width: 80, height: 30)
        doneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        doneButton.addTarget(self, action: #selector(squatDoneButtonTouched), for: .touchUpInside)
        accessoryView.addSubview(doneButton)
        squatTextField!.inputAccessoryView = accessoryView
    }
    
    private func addDeadliftKeyboardAccessoryView()
    {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        accessoryView.backgroundColor = UIColor.mpGrayButtonBorderColor()
        
        let doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: kDeviceWidth - 85, y: 6, width: 80, height: 30)
        doneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        doneButton.addTarget(self, action: #selector(deadliftDoneButtonTouched), for: .touchUpInside)
        accessoryView.addSubview(doneButton)
        deadliftTextField!.inputAccessoryView = accessoryView
    }
    
    private func addShuttleKeyboardAccessoryView()
    {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        accessoryView.backgroundColor = UIColor.mpGrayButtonBorderColor()
        
        let doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: kDeviceWidth - 85, y: 6, width: 80, height: 30)
        doneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        doneButton.addTarget(self, action: #selector(shuttleDoneButtonTouched), for: .touchUpInside)
        accessoryView.addSubview(doneButton)
        shuttleTextField!.inputAccessoryView = accessoryView
    }
    
    private func addFortyYardDashKeyboardAccessoryView()
    {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        accessoryView.backgroundColor = UIColor.mpGrayButtonBorderColor()
        
        let doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: kDeviceWidth - 85, y: 6, width: 80, height: 30)
        doneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.mpDarkGrayColor(), for: .normal)
        doneButton.addTarget(self, action: #selector(fortyYardDashDoneButtonTouched), for: .touchUpInside)
        accessoryView.addSubview(doneButton)
        fortyYardDashTextField!.inputAccessoryView = accessoryView
    }
    
    // MARK: - Keyboard Notifications
    
    @objc private func keyboardDidShow(notification: Notification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            //print("Keyboard Height: " + String(Int(keyboardSize.size.height)))
            
            // Need to use the device coordinates for this calculation
            var innerContainerViewBottom = 0
            
            if (benchTextField.isFirstResponder == true)
            {
                innerContainerViewBottom = Int(containerScrollView.frame.origin.y) + Int(benchContainerView.frame.origin.y) + Int(benchContainerView.frame.size.height)
            }
            else if (squatTextField.isFirstResponder == true)
            {
                innerContainerViewBottom = Int(containerScrollView.frame.origin.y) + Int(squatContainerView.frame.origin.y) + Int(squatContainerView.frame.size.height)
            }
            else if (deadliftTextField.isFirstResponder == true)
            {
                innerContainerViewBottom = Int(containerScrollView.frame.origin.y) + Int(deadliftContainerView.frame.origin.y) + Int(deadliftContainerView.frame.size.height)
            }
            else if (shuttleTextField.isFirstResponder == true)
            {
                innerContainerViewBottom = Int(containerScrollView.frame.origin.y) + Int(shuttleContainerView.frame.origin.y) + Int(shuttleContainerView.frame.size.height)
            }
            else if (fortyYardDashTextField.isFirstResponder == true)
            {
                innerContainerViewBottom = Int(containerScrollView.frame.origin.y) + Int(fortyYardDashContainerView.frame.origin.y) + Int(fortyYardDashContainerView.frame.size.height)
            }
            
            let keyboardTop = Int(kDeviceHeight) - Int(keyboardSize.size.height)
            
            if (keyboardTop < innerContainerViewBottom)
            {
                let difference = innerContainerViewBottom - keyboardTop
                containerScrollView.contentOffset = CGPoint(x: 0, y: difference)
            }
            
            // Increase the scroll size
            containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: kContainerHeight + keyboardSize.size.height - 20.0)
        }
    }
    
    @objc private func keyboardDidHide(notification: Notification)
    {
        //print("Keyboard will hide")
        //containerScrollView.contentOffset = CGPoint(x: 0, y: 0)
        
        // Set the scroll size
        containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: kContainerHeight)
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        fakeStatusBar.backgroundColor = .clear

        // Size the fakeStatusBar, navBar, and containerScrollView
        fakeStatusBar.frame = CGRect(x: 0, y: 0, width: Int(kDeviceWidth), height: kStatusBarHeight + SharedData.topNotchHeight)
        navView.frame = CGRect(x: 0, y: fakeStatusBar.frame.size.height, width: CGFloat(kDeviceWidth), height: navView.frame.size.height)
        bottomContainerView.frame = CGRect(x: 0, y: Int(kDeviceHeight) - 70 - SharedData.bottomSafeAreaHeight, width: Int(kDeviceWidth), height: 70 + SharedData.bottomSafeAreaHeight)
        
        containerViewHeight = kDeviceHeight - navView.frame.origin.y - navView.frame.size.height - bottomContainerView.frame.size.height
        containerScrollView.frame = CGRect(x: 0, y: navView.frame.origin.y + navView.frame.size.height, width: kDeviceWidth, height: containerViewHeight)
        
        saveButton.layer.cornerRadius = 8
        saveButton.clipsToBounds = true
        
        // Set the scroll size
        containerScrollView.contentSize = CGSize(width: kDeviceWidth, height: kContainerHeight)
        
        self.addWeightKeyboardAccessoryView()
        self.addBenchKeyboardAccessoryView()
        self.addSquatKeyboardAccessoryView()
        self.addDeadliftKeyboardAccessoryView()
        self.addShuttleKeyboardAccessoryView()
        self.addFortyYardDashKeyboardAccessoryView()
        
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
