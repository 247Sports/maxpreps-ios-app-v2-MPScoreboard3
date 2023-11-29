//
//  BoxScoreViewController.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/13/21.
//

import UIKit
import AVFoundation

class BoxScoreViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, LandscapeKeyboardViewDelegate
{
    @IBOutlet weak var fakeStatusBar: UIView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var portraitBaseView: UIView!
    @IBOutlet weak var portraitHeaderContainerView: UIView!
    @IBOutlet weak var portraitSchoolNameLabelA: UILabel!
    @IBOutlet weak var portraitHomeAwayLabelA: UILabel!
    @IBOutlet weak var portraitMascotContainerViewA: UIView!
    @IBOutlet weak var portraitMascotImageViewA: UIImageView!
    @IBOutlet weak var portraitInitialLabelA: UILabel!
    @IBOutlet weak var portraitScoreLabelA: UILabel!
    @IBOutlet weak var portraitSchoolNameLabelB: UILabel!
    @IBOutlet weak var portraitHomeAwayLabelB: UILabel!
    @IBOutlet weak var portraitMascotContainerViewB: UIView!
    @IBOutlet weak var portraitMascotImageViewB: UIImageView!
    @IBOutlet weak var portraitInitialLabelB: UILabel!
    @IBOutlet weak var portraitScoreLabelB: UILabel!
    @IBOutlet weak var portraitContestStateLabel: UILabel!
    @IBOutlet weak var portraitDateLabel: UILabel!
    
    @IBOutlet weak var landscapeBaseView: UIView!
    @IBOutlet weak var landscapeHeaderContainerView: UIView!
    @IBOutlet weak var landscapeSchoolNameLabelA: UILabel!
    @IBOutlet weak var landscapeHomeAwayLabelA: UILabel!
    @IBOutlet weak var landscapeMascotContainerViewA: UIView!
    @IBOutlet weak var landscapeMascotImageViewA: UIImageView!
    @IBOutlet weak var landscapeInitialLabelA: UILabel!
    @IBOutlet weak var landscapeScoreLabelA: UILabel!
    @IBOutlet weak var landscapeSchoolNameLabelB: UILabel!
    @IBOutlet weak var landscapeHomeAwayLabelB: UILabel!
    @IBOutlet weak var landscapeMascotContainerViewB: UIView!
    @IBOutlet weak var landscapeMascotImageViewB: UIImageView!
    @IBOutlet weak var landscapeInitialLabelB: UILabel!
    @IBOutlet weak var landscapeScoreLabelB: UILabel!
    @IBOutlet weak var landscapeContestStateLabel: UILabel!
    @IBOutlet weak var landscapeDateLabel: UILabel!
    
    @IBOutlet weak var scoreEntryView: UIView!
    @IBOutlet weak var scoreEntryScrollView: UIScrollView!
    @IBOutlet weak var scoreEntrySchoolNameLabelA: UILabel!
    @IBOutlet weak var scoreEntryHomeAwayLabelA: UILabel!
    @IBOutlet weak var scoreEntryMascotImageViewA: UIImageView!
    @IBOutlet weak var scoreEntryInitialLabelA: UILabel!
    @IBOutlet weak var scoreEntryScoreTextFieldA: UITextField!
    @IBOutlet weak var scoreEntrySchoolNameLabelB: UILabel!
    @IBOutlet weak var scoreEntryHomeAwayLabelB: UILabel!
    @IBOutlet weak var scoreEntryMascotImageViewB: UIImageView!
    @IBOutlet weak var scoreEntryInitialLabelB: UILabel!
    @IBOutlet weak var scoreEntryScoreTextFieldB: UITextField!
    @IBOutlet weak var scoreEntryContestStateLabel: UILabel!
    @IBOutlet weak var leftShadow : UIImageView!
    @IBOutlet weak var rightShadow : UIImageView!
    @IBOutlet weak var verticalLine : UIView!
    
    @IBOutlet weak var forfeitView: UIView!
    @IBOutlet weak var forfeitSchoolNameLabelA: UILabel!
    @IBOutlet weak var forfeitSwitchA: UISwitch!
    @IBOutlet weak var forfeitSchoolNameLabelB: UILabel!
    @IBOutlet weak var forfeitSwitchB: UISwitch!
    
    @IBOutlet weak var winnerView: UIView!
    @IBOutlet weak var winnerSchoolNameLabelA: UILabel!
    @IBOutlet weak var winnerSwitchA: UISwitch!
    @IBOutlet weak var winnerSchoolNameLabelB: UILabel!
    @IBOutlet weak var winnerSwitchB: UISwitch!
    
    var selectedTeam : Team?
    var selectedContest : Dictionary<String,Any>?
    var ssid : String?
    var contestState = 0
    
    private var teamColorA = UIColor.mpRedColor()
    private var teamColorB = UIColor.mpRedColor()
    private var tickTimer: Timer!
    
    private var landscapeKeyboardView: LandscapeKeyboardView!
    private var activeTextField: UITextField!
    private var nativeKeyboardVisible = false
    private var landscapeKeyboardVisible = false
    private var landscapeMode = false

    private var teamScoresA = [] as! Array<Dictionary<String,Any>>
    private var teamScoresB = [] as! Array<Dictionary<String,Any>>
    private var bFieldArray = [] as! Array<String>
    
    let kSmallPad = 8.0
    let kLargePad = 12.0
    let kLandscapeKeyboardHeight = kDeviceWidth - 375.0 + 88.0 // Taller on larger devices
    
    private var progressOverlay: ProgressHUD!
    
    // MARK: - Update Box Scores
    
    private func updateBoxScores()
    {
        // Get the teamId for each team
        let teams = selectedContest!["teams"] as! Array<Dictionary<String,Any>>
        var teamA = [:] as Dictionary<String,Any>
        var teamB = [:] as Dictionary<String,Any>
        
        // The home team is the bottom row of scores
        let haTypeFirst = teams.first!["homeAwayType"] as! Int
        
        if (haTypeFirst == 0) // Home
        {
            teamA = teams.last!
            teamB = teams.first!
        }
        else
        {
            teamA = teams.first!
            teamB = teams.last!
        }
        
        let teamIdA = teamA["teamId"] as! String
        let teamIdB = teamB["teamId"] as! String
        
        // Build the teams array for the post
        var teamScores = [] as Array<Dictionary<String,Any>>
        var teamObjA = [:] as Dictionary<String,Any>
        var teamObjB = [:] as Dictionary<String,Any>
        var scoreA = 0
        var scoreB = 0
        var teamResultA = ""
        var teamResultB = ""
        
        // Set the teamId, isWinner, isForfeit, and score for each teamObj
        teamObjA["teamId"] = teamIdA
        teamObjA["isWinner"] = winnerSwitchA.isOn
        teamObjA["isForfeit"] = forfeitSwitchA.isOn
        
        if (scoreEntryScoreTextFieldA.text!.count > 0)
        {
            teamObjA["score"] = Int(scoreEntryScoreTextFieldA.text!)
            scoreA = Int(scoreEntryScoreTextFieldA.text!)!
        }
        else
        {
            teamObjA["score"] = 0
        }
        
        teamObjB["teamId"] = teamIdB
        teamObjB["isWinner"] = winnerSwitchB.isOn
        teamObjB["isForfeit"] = forfeitSwitchB.isOn
        
        if (scoreEntryScoreTextFieldB.text!.count > 0)
        {
            teamObjB["score"] = Int(scoreEntryScoreTextFieldB.text!)
            scoreB = Int(scoreEntryScoreTextFieldB.text!)!
        }
        else
        {
            teamObjB["score"] = 0
        }
        
        if (scoreA > scoreB)
        {
            teamResultA = "W"
            teamResultB = "L"
        }
        else if (scoreB > scoreA)
        {
            teamResultA = "L"
            teamResultB = "W"
        }
        else
        {
            teamResultA = "T"
            teamResultB = "T"
        }
        
        // Override the result if one team forfeited
        if (forfeitSwitchA.isOn == true) || (forfeitSwitchB.isOn == true)
        {
            teamResultA = "F"
            teamResultB = "F"
        }
        
        teamObjA["result"] = teamResultA
        teamObjB["result"] = teamResultB
        
        // Gather the scores
        for subview in scoreEntryScrollView.subviews
        {
            if (subview.tag >= 100) && (subview.tag < 199)
            {
                let index = subview.tag - 100
                let bField = bFieldArray[index]
                
                let subViewTextField = subview as! UITextField
                if ( subViewTextField.text!.count > 0)
                {
                    teamObjA[bField] = Int(subViewTextField.text!)
                }
            }
            
            if (subview.tag >= 200) && (subview.tag < 299)
            {
                let index = subview.tag - 200
                let bField = bFieldArray[index]
                
                let subViewTextField = subview as! UITextField
                if ( subViewTextField.text!.count > 0)
                {
                    teamObjB[bField] = Int(subViewTextField.text!)
                }
            }
        }
        
        teamScores.append(teamObjA)
        teamScores.append(teamObjB)
        
        let overrideResultWithWinner = winnerSwitchA.isOn || winnerSwitchB.isOn
        let contestId = selectedContest!["contestId"] as! String
        
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.updateBoxScore(schoolId: selectedTeam!.schoolId, ssid: self.ssid!, contestId: contestId, overrideResultWithWinner: overrideResultWithWinner, teamScores: teamScores) { result, error in
            
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
                print("Update Box Score Success")
                
                OverlayView.showPopupOverlay(withMessage: "Box Score Updated")
                {
                    self.landscapeKeyboardView.removeFromSuperview()
                    self.navigationController?.popViewController(animated: true)
                } 
            }
            else
            {
                print("Update Box Score Failed")
            }
        }
        
        /*
         {
             "contestId": "d0a164af-353e-47a0-87ff-f791c565a327",
             "overrideResultWithWinnerBox": false,
             "teamScores": [
                 {
                     "teamId": "d9622df1-9a90-49e7-b219-d6c380c566fe",
                     "isWinner": true,
                     "isForfeit": false,
                     "result": "W",
                     "score": 27,
                     "b1": null,
                     "b2": null,
                     "b3": null,
                     "b4": null,
                     "b5": null,
                     "b6": null,
                     "b7": null,
                     "b8": null,
                     "b9": null,
                     "b10": null,
                     "b11": null,
                     "b12": null,
                     "b13": null,
                     "b14": null,
                     "b15": null,
                     "b16": null,
                     "b17": null,
                     "b18": null,
                     "b19": null,
                     "b20": null,
                     "b21": null,
                     "b22": null,
                     "b23": null,
                     "b24": null,
                     "b25": null,
                     "b26": null,
                     "b27": null,
                     "b28": null,
                     "b29": null,
                     "b30": null
                 },
                 {
                     •
                     •
                     •
                 }
             ]
         }
         */
    }
    
    // MARK: - Get Box Scores
    
    private func getBoxScores()
    {
        let contestId = selectedContest!["contestId"] as! String
        
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        if (progressOverlay == nil)
        {
            progressOverlay = ProgressHUD()
            progressOverlay.show(animated: false)
        }
        
        NewFeeds.getBoxScores(schoolId: selectedTeam!.schoolId, ssid: self.ssid!, contestId: contestId) {result, error in
            
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
                print("Get Box Score Success")
                let teamBoxScore = result!["teamBoxScore"] as! Dictionary<String,Any>
                let opponentBoxScore = result!["opponentBoxScore"] as! Dictionary<String,Any>
                
                // Decide which should be teamScoresA and teamScoresB
                let teamBoxScoreTeamId = teamBoxScore["teamId"] as! String
                let teams = self.selectedContest!["teams"] as! Array<Dictionary<String,Any>>
                var teamA = [:] as Dictionary<String,Any>
                
                // The home team is on the bottom
                let haTypeFirst = teams.first!["homeAwayType"] as! Int
                
                if (haTypeFirst == 0) // Home
                {
                    teamA = teams.last!
                }
                else
                {
                    teamA = teams.first!
                }
                
                let schoolIdA = teamA["teamId"] as? String ?? ""
                
                var tempScoresA = [] as! Array<Dictionary<String,Any>>
                var tempScoresB = [] as! Array<Dictionary<String,Any>>
                
                if (teamBoxScoreTeamId == schoolIdA)
                {
                    tempScoresA = teamBoxScore["scores"] as! Array<Dictionary<String,Any>>
                    tempScoresB = opponentBoxScore["scores"] as! Array<Dictionary<String,Any>>
                    
                    // Load the winner switches
                    self.winnerSwitchA.isOn = teamBoxScore["isWinner"] as! Bool
                    self.winnerSwitchB.isOn = opponentBoxScore["isWinner"] as! Bool
                }
                else
                {
                    tempScoresA = opponentBoxScore["scores"] as! Array<Dictionary<String,Any>>
                    tempScoresB = teamBoxScore["scores"] as! Array<Dictionary<String,Any>>
                    
                    // Load the winner switches
                    self.winnerSwitchA.isOn = opponentBoxScore["isWinner"] as! Bool
                    self.winnerSwitchB.isOn = teamBoxScore["isWinner"] as! Bool
                }
                
                // Filter out the Final Score object
                for score in tempScoresA
                {
                    let fieldName = score["field"] as! String
                    
                    if (fieldName != "Score")
                    {
                        self.teamScoresA.append(score)
                        self.bFieldArray.append(fieldName)
                    }
                    else
                    {
                        // Update the scoreEntryGameStateLabel with the header property
                        let displayName = score["displayName"] as? String ?? ""
                        let headerName = score["header"] as? String ?? ""
                        
                        if (displayName.count > 6)
                        {
                            self.scoreEntryContestStateLabel.text = headerName.uppercased()
                        }
                        else
                        {
                            self.scoreEntryContestStateLabel.text = displayName.uppercased()
                        }
                    }
                }
                
                for score in tempScoresB
                {
                    let fieldName = score["field"] as! String
                    
                    if (fieldName != "Score")
                    {
                        self.teamScoresB.append(score)
                    }
                }
                
                self.buildScoreEntryCells()
            }
            else
            {
                print("Get Box Score Failed")
            }
        }
    }
    
    // MARK: - Calculate Score
    
    private func calculateScore(top: Bool)
    {
        if (selectedTeam!.sport == "Volleyball") || (selectedTeam!.sport == "Sand Volleyball") || (selectedTeam!.sport == "Beach Volleyball")
        {
            var topTotalScore = 0
            var bottomTotalScore = 0
            
            // Iterate through the top fields to find the individual set winners
            for topSubview in scoreEntryScrollView.subviews
            {
                if (topSubview.tag >= 100) && (topSubview.tag < 199)
                {
                    let topSubViewTextField = topSubview as! UITextField
                    if (topSubViewTextField.text!.count > 0)
                    {
                        let topValue = Int(topSubViewTextField.text!)
                        let topTag = topSubview.tag - 100
                        
                        // Now find the matching tag in the bottom
                        for bottomSubview in scoreEntryScrollView.subviews
                        {
                            if (bottomSubview.tag >= 200) && (bottomSubview.tag < 299)
                            {
                                let bottomSubViewTextField = bottomSubview as! UITextField
                                if (bottomSubViewTextField.text!.count > 0)
                                {
                                    let bottomValue = Int(bottomSubViewTextField.text!)
                                    let bottomTag = bottomSubview.tag - 200
                                    
                                    if (topTag == bottomTag)
                                    {
                                        // Matching set found
                                        if (topValue! > bottomValue!)
                                        {
                                            topTotalScore += 1
                                        }
                                        else if (topValue! < bottomValue!)
                                        {
                                            bottomTotalScore += 1
                                        }
                                        else
                                        {
                                            // Show an alert
                                            MiscHelper.showAlert(in: self, withActionNames: ["OK"], title: "Oops", message: "Both scores can not be the same.", lastItemCancelType: false) { tag in
                                                topSubViewTextField.text = ""
                                                bottomSubViewTextField.text = ""
                                            }
                                            return
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            //if (topTotalScore > 0)
            //{
                scoreEntryScoreTextFieldA.text = String(topTotalScore)
            //}
            
            //if (bottomTotalScore > 0)
            //{
                scoreEntryScoreTextFieldB.text = String(bottomTotalScore)
            //}
        }
        else
        {
            // The rest of the sports just add up the cells
            if (top == true)
            {
                var score = 0
                
                for subview in scoreEntryScrollView.subviews
                {
                    if (subview.tag >= 100) && (subview.tag < 199)
                    {
                        let index = subview.tag - 100
                        let scoreItem = teamScoresA[index]
                        let normalCell = scoreItem["useToCalculateScore"] as! Bool
                    
                        // Skip the cells that shouldn't be used in the calculation
                        if (normalCell == true)
                        {
                            let subViewTextField = subview as! UITextField
                            if (subViewTextField.text!.count > 0)
                            {
                                let value = Int(subViewTextField.text!)
                                score += value!
                            }
                        }
                    }
                    
                }
                
                //if (score > 0)
                //{
                    scoreEntryScoreTextFieldA.text = String(score)
                //}
            }
            else
            {
                var score = 0
                
                for subview in scoreEntryScrollView.subviews
                {
                    if (subview.tag >= 200) && (subview.tag < 299)
                    {
                        let index = subview.tag - 200
                        let scoreItem = teamScoresB[index]
                        let normalCell = scoreItem["useToCalculateScore"] as! Bool
                    
                        // Skip the cells that shouldn't be used in the calculation
                        if (normalCell == true)
                        {
                            let subViewTextField = subview as! UITextField
                            if (subViewTextField.text!.count > 0)
                            {
                                let value = Int(subViewTextField.text!)
                                score += value!
                            }
                        }
                    }
                }
                
                //if (score > 0)
                //{
                    scoreEntryScoreTextFieldB.text = String(score)
                //}
            }
        }
    }
    
    // MARK: - Build Score Entry Cells
    
    private func buildScoreEntryCells()
    {
        // Tags for teamA are 100-198, teamB are 200-298
        
        // In order to have extra spacing for the special cells and to add a vertical line, the transition index needs to be found
        var i = 0
        var transitionIndex = 99
        for scoreItemA in teamScoresA
        {
            let normalCell = scoreItemA["useToCalculateScore"] as! Bool
            
            if (normalCell == false)
            {
                transitionIndex = i
                break
            }
            i += 1
        }
        
        let leftPad = 8
        let spacing = 4
        let rightPad = 8
        let cellWidth = 50
        var index = 0
        var xStart = spacing
        var transitionSpacing = 0
  
        // Iterate though the teamAScores
        for scoreItemA in teamScoresA
        {
            // The Final Scores object is already removed
            let headerName = scoreItemA["header"] as! String
            let displayName = scoreItemA["displayName"] as! String
            let normalCell = scoreItemA["useToCalculateScore"] as! Bool

            if (index == 0)
            {
                xStart = leftPad
            }
            
            if (index >= transitionIndex)
            {
                transitionSpacing = 7
            }
            else
            {
                transitionSpacing = 0
            }
            
            if (index == transitionIndex)
            {
                // Add a vertical line
                let vertLine = UIView(frame: CGRect(x: xStart + ((cellWidth + spacing) * index) + 1, y: 0, width: 1, height: Int(scoreEntryScrollView.frame.size.height)))
                vertLine.backgroundColor = UIColor.mpGrayButtonBorderColor()
                scoreEntryScrollView.addSubview(vertLine)
            }
            
            let headerLabel = UILabel(frame: CGRect(x: xStart + ((cellWidth + spacing) * index) + transitionSpacing, y: 12, width: cellWidth, height: 16))
            headerLabel.font = UIFont.mpBoldFontWith(size: 12)
            headerLabel.textColor = UIColor.mpGrayColor()
            headerLabel.textAlignment = NSTextAlignment.center
            headerLabel.adjustsFontSizeToFitWidth = true
            headerLabel.minimumScaleFactor = 0.5
            scoreEntryScrollView.addSubview(headerLabel)

            if (normalCell == true)
            {
                headerLabel.text = headerName.uppercased()
            }
            else
            {
                // Use the header name if the display name is too long
                if (displayName.count > 6)
                {
                    headerLabel.text = headerName.uppercased()
                }
                else
                {
                    headerLabel.text = displayName.uppercased()
                }
            }
            
            // Top Cells
            let topValue = scoreItemA["value"] as! String
            
            let topTextField = UITextField(frame: CGRect(x: xStart + ((cellWidth + spacing) * index) + transitionSpacing, y: 33, width: cellWidth, height: 40))
            topTextField.borderStyle = .none
            //topTextField.tintColor = .clear
            //topTextField.tintColorDidChange()
            topTextField.layer.cornerRadius = 5
            topTextField.layer.borderWidth = 1
            topTextField.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
            topTextField.clipsToBounds = true
            topTextField.textAlignment = NSTextAlignment.center
            topTextField.textColor = UIColor.mpBlackColor()
            topTextField.font = UIFont.mpBoldFontWith(size: 14)
            topTextField.keyboardType = .numberPad
            topTextField.autocorrectionType = .no
            topTextField.autocapitalizationType = .none
            topTextField.smartDashesType = .no
            topTextField.smartQuotesType = .no
            topTextField.smartInsertDeleteType = .no
            topTextField.spellCheckingType = .no
            topTextField.text = topValue
            topTextField.delegate = self
            topTextField.tag = 100 + index
            
            // Change the background colors for the overtime cells
            let overtimeCell = scoreItemA["isOvertime"] as! Bool
            if (overtimeCell == true)
            {
                topTextField.backgroundColor = UIColor.mpOffWhiteNavColor()
            }
            
            // Special Cells
            if (normalCell == false)
            {
                // Baseball and softball are white, other sports are off white
                if ((selectedTeam!.sport != "Baseball") && (selectedTeam!.sport != "Softball"))
                {
                    topTextField.backgroundColor = UIColor.mpOffWhiteNavColor()
                }
            }
            
            
            if (index == 0)
            {
                topTextField.inputAccessoryView = self.buildKeyboardAccessoryView(tag: 100 + index, showNavButtons: true, isFirstAccessoryView: true, isLastAccessoryView: false)
            }
            else if (index == (teamScoresA.count - 1))
            {
                topTextField.inputAccessoryView = self.buildKeyboardAccessoryView(tag: 100 + index, showNavButtons: true, isFirstAccessoryView: false, isLastAccessoryView: true)
            }
            else
            {
                topTextField.inputAccessoryView = self.buildKeyboardAccessoryView(tag: 100 + index, showNavButtons: true, isFirstAccessoryView: false, isLastAccessoryView: false)
            }
            scoreEntryScrollView.addSubview(topTextField)
            
            
            // Bottom Cells
            let scoreItemB = teamScoresB[index]
            let bottomValue = scoreItemB["value"] as! String
                        
            let bottomTextField = UITextField(frame: CGRect(x: xStart + ((cellWidth + spacing) * index) + transitionSpacing, y: 77, width: cellWidth, height: 40))
            bottomTextField.borderStyle = .none
            //bottomTextField.tintColor = .clear
           // bottomTextField.tintColorDidChange()
            bottomTextField.layer.cornerRadius = 4
            bottomTextField.layer.borderWidth = 1
            bottomTextField.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
            bottomTextField.clipsToBounds = true
            bottomTextField.textAlignment = NSTextAlignment.center
            bottomTextField.textColor = UIColor.mpBlackColor()
            bottomTextField.font = UIFont.mpBoldFontWith(size: 14)
            bottomTextField.keyboardType = .numberPad
            bottomTextField.autocorrectionType = .no
            bottomTextField.autocapitalizationType = .none
            bottomTextField.smartDashesType = .no
            bottomTextField.smartQuotesType = .no
            bottomTextField.smartInsertDeleteType = .no
            bottomTextField.spellCheckingType = .no
            bottomTextField.text = bottomValue
            bottomTextField.delegate = self
            bottomTextField.tag = 200 + index
            
            // Change the background colors for the overtime cells
            if (overtimeCell == true)
            {
                bottomTextField.backgroundColor = UIColor.mpOffWhiteNavColor()
            }
            
            // Special Cells
            if (normalCell == false)
            {
                // Baseball and softball are white, other sports are off white
                if ((selectedTeam!.sport != "Baseball") && (selectedTeam!.sport != "Softball"))
                {
                    bottomTextField.backgroundColor = UIColor.mpOffWhiteNavColor()
                }
            }
            
            if (index == 0)
            {
                bottomTextField.inputAccessoryView = self.buildKeyboardAccessoryView(tag: 200 + index, showNavButtons: true, isFirstAccessoryView: true, isLastAccessoryView: false)
            }
            else if (index == (teamScoresB.count - 1))
            {
                bottomTextField.inputAccessoryView = self.buildKeyboardAccessoryView(tag: 200 + index, showNavButtons: true, isFirstAccessoryView: false, isLastAccessoryView: true)
            }
            else
            {
                bottomTextField.inputAccessoryView = self.buildKeyboardAccessoryView(tag: 200 + index, showNavButtons: true, isFirstAccessoryView: false, isLastAccessoryView: false)
            }
            scoreEntryScrollView.addSubview(bottomTextField)
            
            index += 1
        }
        
        // Set the scrollView's size
        var extraSpace = 7
        if (transitionIndex == 99)
        {
            extraSpace = 0
        }
        let overallWidth = ((teamScoresA.count) * (cellWidth + spacing)) + leftPad + rightPad + extraSpace
        scoreEntryScrollView.contentSize = CGSize(width: overallWidth, height: Int(scoreEntryScrollView.frame.size.height))
        
    }
    
    // MARK: - Reset Background Colors
    
    private func resetBackgroundColors()
    {
        for subview in scoreEntryScrollView.subviews
        {
            if (subview.tag >= 100) && (subview.tag < 199)
            {
                let index = subview.tag - 100
                let scoreItemA = teamScoresA[index]
                let normalCell = scoreItemA["useToCalculateScore"] as! Bool
                let overtimeCell = scoreItemA["isOvertime"] as! Bool
                
                let subViewTextField = subview as! UITextField
                subViewTextField.backgroundColor = UIColor.mpWhiteColor()
                
                if (overtimeCell == true)
                {
                    subViewTextField.backgroundColor = UIColor.mpOffWhiteNavColor()
                }
                
                if (normalCell == false)
                {
                    // Baseball and softball are white, other sports are off white
                    if ((selectedTeam!.sport != "Baseball") && (selectedTeam!.sport != "Softball"))
                    {
                        subViewTextField.backgroundColor = UIColor.mpOffWhiteNavColor()
                    }
                }
            }
            
            if (subview.tag >= 200) && (subview.tag < 299)
            {
                let index = subview.tag - 200
                let scoreItemB = teamScoresB[index]
                let normalCell = scoreItemB["useToCalculateScore"] as! Bool
                let overtimeCell = scoreItemB["isOvertime"] as! Bool
                
                let subViewTextField = subview as! UITextField
                subViewTextField.backgroundColor = UIColor.mpWhiteColor()
                
                if (overtimeCell == true)
                {
                    subViewTextField.backgroundColor = UIColor.mpOffWhiteNavColor()
                }
                
                if (normalCell == false)
                {
                    // Baseball and softball are white, other sports are off white
                    if ((selectedTeam!.sport != "Baseball") && (selectedTeam!.sport != "Softball"))
                    {
                        subViewTextField.backgroundColor = UIColor.mpOffWhiteNavColor()
                    }
                }
            }
        }
        
        if (selectedTeam!.sport == "Volleyball") || (selectedTeam!.sport == "Sand Volleyball") || (selectedTeam!.sport == "Beach Volleyball")
        {
            scoreEntryScoreTextFieldA.backgroundColor = UIColor.mpOffWhiteNavColor()
            scoreEntryScoreTextFieldB.backgroundColor = UIColor.mpOffWhiteNavColor()
        }
        else
        {
            scoreEntryScoreTextFieldA.backgroundColor = UIColor.mpWhiteColor()
            scoreEntryScoreTextFieldB.backgroundColor = UIColor.mpWhiteColor()
        }
    }
    
    // MARK: - TextField Delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        // Reset out the cell backgrounds (needed for landscape mode)
        self.resetBackgroundColors()
        
        // This is used when the landscape keyboard is used
        activeTextField = textField
        
        if (landscapeMode == true)
        {
            // Show the custom keyboard
            self.showLandscapeKeyboard(true)
            
            textField.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 215.0/255.0, alpha: 1)
            
            if (textField.tag >= 100) && (textField.tag < 199)
            {
                let index = textField.tag - 100
                
                if (index == 0)
                {
                    landscapeKeyboardView.enableLeftKeyboardButton(false)
                    landscapeKeyboardView.enableRightKeyboardButton(true)
                }
                else if (index == (teamScoresA.count - 1))
                {
                    landscapeKeyboardView.enableLeftKeyboardButton(true)
                    landscapeKeyboardView.enableRightKeyboardButton(false)
                }
                else
                {
                    landscapeKeyboardView.enableLeftKeyboardButton(true)
                    landscapeKeyboardView.enableRightKeyboardButton(true)
                }
            }
            
            if (textField.tag >= 200) && (textField.tag < 299)
            {
                let index = textField.tag - 200
                
                if (index == 0)
                {
                    landscapeKeyboardView.enableLeftKeyboardButton(false)
                    landscapeKeyboardView.enableRightKeyboardButton(true)
                }
                else if (index == (teamScoresA.count - 1))
                {
                    landscapeKeyboardView.enableLeftKeyboardButton(true)
                    landscapeKeyboardView.enableRightKeyboardButton(false)
                }
                else
                {
                    landscapeKeyboardView.enableLeftKeyboardButton(true)
                    landscapeKeyboardView.enableRightKeyboardButton(true)
                }
            }
            
            if (textField.tag == 199)
            {
                // Clear out the top text fields
                for subview in scoreEntryScrollView.subviews
                {
                    if (subview.tag >= 100) && (subview.tag < 199)
                    {
                        let subViewTextField = subview as! UITextField
                        let index = subViewTextField.tag - 100
                        let scoreItemA = teamScoresA[index]
                        let normalCell = scoreItemA["useToCalculateScore"] as! Bool
                        if (normalCell == true)
                        {
                            subViewTextField.text = ""
                        }
                    }
                }
            }
            
            if (textField.tag == 299)
            {
                // Clear out the bottom text fields
                for subview in scoreEntryScrollView.subviews
                {
                    if (subview.tag >= 200) && (subview.tag < 299)
                    {
                        let subViewTextField = subview as! UITextField
                        let index = subViewTextField.tag - 200
                        let scoreItemA = teamScoresB[index]
                        let normalCell = scoreItemA["useToCalculateScore"] as! Bool
                        if (normalCell == true)
                        {
                            subViewTextField.text = ""
                        }
                    }
                }
            }
            

            return false
        }
        else
        {
            textField.backgroundColor = UIColor.mpWhiteColor()
            /*
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
            {
                textField.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 215.0/255.0, alpha: 1)
            }
            */
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason)
    {
        self.resetBackgroundColors()
        
        /*
        // Top scores
        if (textField.tag >= 100) && (textField.tag < 199)
        {
            // Add up the scores only if the total textField is empty
            if (scoreEntryScoreTextFieldA.text == "")
            {
                self.calculateScore(top: true)
            }
        }
        
        // Top scores
        if (textField.tag >= 200) && (textField.tag < 299)
        {
            // Add up the scores only if the total textField is empty
            if (scoreEntryScoreTextFieldB.text == "")
            {
                self.calculateScore(top: false)
            }
        }
        */
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        // Only allow up to 3 characters for the final score, 2 for all others
        if (textField.tag == 199)
        {
            if (range.location > 2)
            {
                return false
            }
            else
            {
                // Clear out the top text fields
                for subview in scoreEntryScrollView.subviews
                {
                    if (subview.tag >= 100) && (subview.tag < 199)
                    {
                        let subViewTextField = subview as! UITextField
                        let index = subViewTextField.tag - 100
                        let scoreItemA = teamScoresA[index]
                        let normalCell = scoreItemA["useToCalculateScore"] as! Bool
                        if (normalCell == true)
                        {
                            subViewTextField.text = ""
                        }
                    }
                }
                return true
            }
        }
        else if (textField.tag == 299)
        {
            if (range.location > 2)
            {
                return false
            }
            else
            {
                // Clear out the bottom text fields
                for subview in scoreEntryScrollView.subviews
                {
                    if (subview.tag >= 200) && (subview.tag < 299)
                    {
                        let subViewTextField = subview as! UITextField
                        let index = subViewTextField.tag - 200
                        let scoreItemA = teamScoresB[index]
                        let normalCell = scoreItemA["useToCalculateScore"] as! Bool
                        if (normalCell == true)
                        {
                            subViewTextField.text = ""
                        }
                    }
                }
                return true
            }
        }
        else
        {
            if (range.location > 1)
            {
                return false
            }
            else
            {
                if (textField.tag >= 100) && (textField.tag < 199)
                {
                    // Only clear the score if the cell should be used for calculation
                    let index = textField.tag - 100
                    let scoreItem = teamScoresA[index]
                    let normalCell = scoreItem["useToCalculateScore"] as! Bool
                    
                    if (normalCell == true)
                    {
                        scoreEntryScoreTextFieldA.text = ""
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                    { [self] in
                        
                        self.calculateScore(top: true)
                    }
                }
                
                if (textField.tag >= 200) && (textField.tag < 299)
                {
                    // Only clear the score if the cell should be used for calculation
                    let index = textField.tag - 200
                    let scoreItem = teamScoresB[index]
                    let normalCell = scoreItem["useToCalculateScore"] as! Bool
                    
                    if (normalCell == true)
                    {
                        scoreEntryScoreTextFieldB.text = ""
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1)
                    { [self] in
                        
                        self.calculateScore(top: false)
                    }
                }
                return true
            }
        }
    }
    
    // MARK: - Load Header and Footer Data
    
    private func loadHeaderAndFooterData()
    {
        // Load the font for the two textFields. Interface Builder has issues!
        scoreEntryScoreTextFieldA.font = UIFont.mpBoldFontWith(size: 14)
        scoreEntryScoreTextFieldB.font = UIFont.mpBoldFontWith(size: 14)
        scoreEntryScoreTextFieldA.layer.cornerRadius = 4
        scoreEntryScoreTextFieldA.layer.borderWidth = 1
        scoreEntryScoreTextFieldA.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        scoreEntryScoreTextFieldA.clipsToBounds = true
        
        scoreEntryScoreTextFieldB.layer.cornerRadius = 4
        scoreEntryScoreTextFieldB.layer.borderWidth = 1
        scoreEntryScoreTextFieldB.layer.borderColor = UIColor.mpGrayButtonBorderColor().cgColor
        scoreEntryScoreTextFieldB.clipsToBounds = true
        
        // The tags were set in Interface Builder
        scoreEntryScoreTextFieldA.inputAccessoryView = self.buildKeyboardAccessoryView(tag: 199, showNavButtons: false, isFirstAccessoryView: false, isLastAccessoryView: false)
        scoreEntryScoreTextFieldB.inputAccessoryView = self.buildKeyboardAccessoryView(tag: 299, showNavButtons: false, isFirstAccessoryView: false, isLastAccessoryView: false)
        
        let teams = selectedContest!["teams"] as! Array<Dictionary<String,Any>>
        var teamA = [:] as Dictionary<String,Any>
        var teamB = [:] as Dictionary<String,Any>
        
        // The home team is on the right
        let haTypeFirst = teams.first!["homeAwayType"] as! Int
        
        if (haTypeFirst == 0) // Home
        {
            teamA = teams.last!
            teamB = teams.first!
        }
        else
        {
            teamA = teams.first!
            teamB = teams.last!
        }
        
        let tbaTeamA = teamA["isTeamTBA"] as! Bool
        if (tbaTeamA == true)
        {
            portraitInitialLabelA.text = "T"
            landscapeInitialLabelA.text = "T"
            scoreEntryInitialLabelA.text = "T"
            
            portraitSchoolNameLabelA.text = "TBA"
            landscapeSchoolNameLabelA.text = "TBA"
            scoreEntrySchoolNameLabelA.text = "TBA"
            forfeitSchoolNameLabelA.text = "TBA"
            winnerSchoolNameLabelA.text = "TBA"
        }
        else
        {
            let schoolNameA = teamA["name"] as! String
            portraitInitialLabelA.text = schoolNameA.first?.uppercased()
            landscapeInitialLabelA.text = schoolNameA.first?.uppercased()
            
            landscapeSchoolNameLabelA.text = schoolNameA
            
            // Use the acronym on the portrait view if the name is too long
            if (schoolNameA.count > 25)
            {
                let acronymName = teamA["schoolNameAcronym"] as! String
                if (acronymName.count > 25)
                {
                    portraitSchoolNameLabelA.text = String(acronymName.prefix(25))
                    forfeitSchoolNameLabelA.text = String(acronymName.prefix(25))
                    winnerSchoolNameLabelA.text = String(acronymName.prefix(25))
                }
                else
                {
                    portraitSchoolNameLabelA.text = acronymName
                    forfeitSchoolNameLabelA.text = acronymName
                    winnerSchoolNameLabelA.text = acronymName
                }
                
                if (acronymName.count > 5)
                {
                    scoreEntrySchoolNameLabelA.text = String(acronymName.prefix(5))
                }
                else
                {
                    scoreEntrySchoolNameLabelA.text = acronymName
                }
            }
            else
            {
                portraitSchoolNameLabelA.text = schoolNameA
                forfeitSchoolNameLabelA.text = schoolNameA
                winnerSchoolNameLabelA.text = schoolNameA
                
                let acronymName = teamA["schoolNameAcronym"] as! String
                
                if (acronymName.count > 5)
                {
                    scoreEntrySchoolNameLabelA.text = String(acronymName.prefix(5))
                }
                else
                {
                    scoreEntrySchoolNameLabelA.text = acronymName
                }
            }
        }
        
        let tbaTeamB = teamB["isTeamTBA"] as! Bool
        if (tbaTeamB == true)
        {
            portraitInitialLabelB.text = "T"
            landscapeInitialLabelB.text = "T"
            scoreEntryInitialLabelB.text = "T"
            
            portraitSchoolNameLabelB.text = "TBA"
            landscapeSchoolNameLabelB.text = "TBA"
            scoreEntrySchoolNameLabelB.text = "TBA"
            forfeitSchoolNameLabelB.text = "TBA"
            winnerSchoolNameLabelB.text = "TBA"
        }
        else
        {
            let schoolNameB = teamB["name"] as! String
            portraitInitialLabelB.text = schoolNameB.first?.uppercased()
            landscapeInitialLabelB.text = schoolNameB.first?.uppercased()
            
            landscapeSchoolNameLabelB.text = schoolNameB
            
            // Use the acronym on the portrait view if the name is too long
            if (schoolNameB.count > 25)
            {
                let acronymName = teamB["schoolNameAcronym"] as! String
                if (acronymName.count > 25)
                {
                    portraitSchoolNameLabelB.text = String(acronymName.prefix(25))
                    forfeitSchoolNameLabelB.text = String(acronymName.prefix(25))
                    winnerSchoolNameLabelB.text = String(acronymName.prefix(25))
                }
                else
                {
                    portraitSchoolNameLabelB.text = acronymName
                    forfeitSchoolNameLabelB.text = acronymName
                    winnerSchoolNameLabelB.text = acronymName
                }
                
                if (acronymName.count > 5)
                {
                    scoreEntrySchoolNameLabelB.text = String(acronymName.prefix(5))
                }
                else
                {
                    scoreEntrySchoolNameLabelB.text = acronymName
                }
            }
            else
            {
                portraitSchoolNameLabelB.text = schoolNameB
                forfeitSchoolNameLabelB.text = schoolNameB
                winnerSchoolNameLabelB.text = schoolNameB
                
                let acronymName = teamB["schoolNameAcronym"] as! String
                
                if (acronymName.count > 5)
                {
                    scoreEntrySchoolNameLabelB.text = String(acronymName.prefix(5))
                }
                else
                {
                    scoreEntrySchoolNameLabelB.text = acronymName
                }
            }
        }
        
        // Load the homeAwayLabels
        let haTypeA = teamA["homeAwayType"] as! Int
        
        switch haTypeA
        {
        case 0:
            portraitHomeAwayLabelA.text = "(Home)"
            landscapeHomeAwayLabelA.text = "(Home)"
            scoreEntryHomeAwayLabelA.text = "(Home)"
            portraitHomeAwayLabelB.text = "(Away)"
            landscapeHomeAwayLabelB.text = "(Away)"
            scoreEntryHomeAwayLabelB.text = "(Away)"
        case 1:
            portraitHomeAwayLabelA.text = "(Away)"
            landscapeHomeAwayLabelA.text = "(Away)"
            scoreEntryHomeAwayLabelA.text = "(Away)"
            portraitHomeAwayLabelB.text = "(Home)"
            landscapeHomeAwayLabelB.text = "(Home)"
            scoreEntryHomeAwayLabelB.text = "(Home)"
        case 2:
            portraitHomeAwayLabelA.text = "(Neutral)"
            landscapeHomeAwayLabelA.text = "(Neutral)"
            scoreEntryHomeAwayLabelA.text = "(Neutral)"
            portraitHomeAwayLabelB.text = "(Neutral)"
            landscapeHomeAwayLabelB.text = "(Neutral)"
            scoreEntryHomeAwayLabelB.text = "(Neutral)"
        default:
            portraitHomeAwayLabelA.text = "(Unknown)"
            landscapeHomeAwayLabelA.text = "(Unknown)"
            scoreEntryHomeAwayLabelA.text = "(Unknown)"
            portraitHomeAwayLabelB.text = "(Unknown)"
            landscapeHomeAwayLabelB.text = "(Unknown)"
            scoreEntryHomeAwayLabelB.text = "(Unknown)"
        }
        

        // Load the scores (checking for nulls)
        let teamAScore = teamA["score"] as? Int ?? -1
        let teamBScore = teamB["score"] as? Int ?? -1
            
        if (teamAScore != -1)
        {
            portraitScoreLabelA.text = String(teamAScore)
            landscapeScoreLabelA.text = String(teamAScore)
            scoreEntryScoreTextFieldA.text = String(teamAScore)
        }
        else
        {
            portraitScoreLabelA.text = ""
            landscapeScoreLabelA.text = ""
            scoreEntryScoreTextFieldA.text = ""
        }
        
        if (teamBScore != -1)
        {
            portraitScoreLabelB.text = String(teamBScore)
            landscapeScoreLabelB.text = String(teamBScore)
            scoreEntryScoreTextFieldB.text = String(teamBScore)
        }
        else
        {
            portraitScoreLabelB.text = ""
            landscapeScoreLabelB.text = ""
            scoreEntryScoreTextFieldB.text = ""
        }
        
        // Load the forfeit switches
        forfeitSwitchA.onTintColor = navView.backgroundColor
        forfeitSwitchB.onTintColor = navView.backgroundColor
        
        forfeitSwitchA.isOn = teamA["isForfeit"] as! Bool
        forfeitSwitchB.isOn = teamB["isForfeit"] as! Bool
        
        // Load the winner switch colors. The switch state comes from the box score feed
        winnerSwitchA.onTintColor = navView.backgroundColor
        winnerSwitchB.onTintColor = navView.backgroundColor
        
        /*
        // Load the gameStateLabel
    
        // 0: Unknown (TBA Date games)
        // 1: Deleted
        // 2: Pregame
        // 3: In Progress
        // 4: Boxscore
        // 5: Score not Reported
        
        if (self.contestState == 3)
        {
            portraitContestStateLabel.text = "LIVE"
            landscapeContestStateLabel.text = "LIVE"
            scoreEntryContestStateLabel.text = "LIVE"
        }
        else
        {
            portraitContestStateLabel.text = "FINAL"
            landscapeContestStateLabel.text = "FINAL"
            scoreEntryContestStateLabel.text = "FINAL"
        }
        */
        
        // Load the date labels
        let dateCode = selectedContest!["dateCode"] as! Int
        /*
         Default = 0,
         DateTBA = 1,
         TimeTBA = 2,
         DateTimeTBA = 4
         */
        
        var contestDateString = selectedContest!["date"] as? String ?? "1901-01-01T00:00:00"
        contestDateString = contestDateString.replacingOccurrences(of: "Z", with: "")
        let dateFormatter = DateFormatter()
        dateFormatter.isLenient = true
        dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
        let contestDate = dateFormatter.date(from: contestDateString)
        
        switch dateCode
        {
        case 0: // Default
            if (contestDate != nil)
            {
                dateFormatter.dateFormat = "M/d"
                let dateString = dateFormatter.string(from: contestDate!)
                let todayString = dateFormatter.string(from: Date())
                
                if (todayString == dateString)
                {
                    portraitDateLabel.text = "Today"
                    landscapeDateLabel.text = "Today"
                }
                else
                {
                    portraitDateLabel.text = dateString
                    landscapeDateLabel.text = dateString
                }
            }
            else
            {
                portraitDateLabel.text = ""
                landscapeDateLabel.text = ""
            }
            
        case 1: // DateTBA
            portraitDateLabel.text = "TBA"
            landscapeDateLabel.text = "TBA"
            
        case 2: // TimeTBA
            if (contestDate != nil)
            {
                dateFormatter.dateFormat = "M/d"
                let dateString = dateFormatter.string(from: contestDate!)
                let todayString = dateFormatter.string(from: Date())
                
                if (todayString == dateString)
                {
                    portraitDateLabel.text = "Today"
                    landscapeDateLabel.text = "Today"
                }
                else
                {
                    portraitDateLabel.text = dateString
                    landscapeDateLabel.text = dateString
                }
            }
            else
            {
                portraitDateLabel.text = ""
                landscapeDateLabel.text = ""
            }
            
        default:
            portraitDateLabel.text = "TBA"
            landscapeDateLabel.text = "TBA"
        }
        
        // Set the initial color
        portraitInitialLabelA.textColor = teamColorA
        portraitInitialLabelB.textColor = teamColorB
        landscapeInitialLabelA.textColor = teamColorA
        landscapeInitialLabelB.textColor = teamColorB
        scoreEntryInitialLabelA.textColor = teamColorA
        scoreEntryInitialLabelB.textColor = teamColorB
        
        // Load the mascots
        let mascotUrlA = teamA["mascotUrl"] as? String ?? ""
        let mascotUrlB = teamB["mascotUrl"] as? String ?? ""
        
        if (mascotUrlA.count > 0)
        {
            // Get the data and make an image
            let url = URL(string: mascotUrlA)
            
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        self.portraitInitialLabelA.isHidden = true
                        self.landscapeInitialLabelA.isHidden = true
                        self.scoreEntryInitialLabelA.isHidden = true
                        
                        // Render the mascot using this helper
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.portraitMascotImageViewA)!)
                        
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.landscapeMascotImageViewA)!)
                        
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.scoreEntryMascotImageViewA)!)
                    }
                }
            }
        }
        
        if (mascotUrlB.count > 0)
        {
            // Get the data and make an image
            let url = URL(string: mascotUrlB)
            
            MiscHelper.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }

                DispatchQueue.main.async()
                {
                    let image = UIImage(data: data)
                    
                    if (image != nil)
                    {
                        self.portraitInitialLabelB.isHidden = true
                        self.landscapeInitialLabelB.isHidden = true
                        self.scoreEntryInitialLabelB.isHidden = true
                        
                        // Render the mascot using this helper
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.portraitMascotImageViewB)!)
                        
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.landscapeMascotImageViewB)!)
                        
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.scoreEntryMascotImageViewB)!)
                    }
                }
            }
        }
        
        // Add a timer to check for valid fields
        tickTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(checkValidFields), userInfo: nil, repeats: true)
        
        self.getBoxScores()
        
    }
    
    // MARK: - Draw Shape Layers
    
    func addLeftPortraitShapeLayers()
    {
        // Left Side
        
        // Create a new path for the rear light part
        let rearPath = UIBezierPath()

        // Starting point for the path
        rearPath.move(to: CGPoint(x: 0, y: 0))
        rearPath.addLine(to: CGPoint(x: 30, y: 0))
        rearPath.addLine(to: CGPoint(x: 60, y: portraitHeaderContainerView.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: portraitHeaderContainerView.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: 0))
        rearPath.close()
        
        // Create a CAShapeLayer
        let lightColor = teamColorA.withAlphaComponent(0.3)
        let rearShapeLayer = CAShapeLayer()
        rearShapeLayer.path = rearPath.cgPath
        rearShapeLayer.fillColor = lightColor.cgColor
        rearShapeLayer.position = CGPoint(x: 0, y: 0)

        portraitHeaderContainerView.layer.insertSublayer(rearShapeLayer, below: portraitMascotContainerViewA.layer)
        
        
        // Create a new path for the dark front part
        let frontPath = UIBezierPath()

        // Starting point for the path
        frontPath.move(to: CGPoint(x: 0, y: 0))
        frontPath.addLine(to: CGPoint(x: 26, y: 0))
        frontPath.addLine(to: CGPoint(x: 47, y: portraitHeaderContainerView.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: portraitHeaderContainerView.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: 0))
        frontPath.close()
        
        // Create a CAShapeLayer
        let frontShapeLayer = CAShapeLayer()
        frontShapeLayer.path = frontPath.cgPath
        frontShapeLayer.fillColor = teamColorA.cgColor
        frontShapeLayer.position = CGPoint(x: 0, y: 0)

        portraitHeaderContainerView.layer.insertSublayer(frontShapeLayer, above: rearShapeLayer)
        
    }
    
    func addRightPortraitShapeLayers()
    {
        // Right Side
        
        // Create a new path for the rear light part
        let rearPath = UIBezierPath()

        let width = portraitHeaderContainerView.frame.size.width
        
        // Starting point for the path
        rearPath.move(to: CGPoint(x: width, y: 0))
        rearPath.addLine(to: CGPoint(x: width - 30, y: 0))
        rearPath.addLine(to: CGPoint(x: width - 60, y: portraitHeaderContainerView.frame.size.height))
        rearPath.addLine(to: CGPoint(x: width, y: portraitHeaderContainerView.frame.size.height))
        rearPath.addLine(to: CGPoint(x: width, y: 0))
        rearPath.close()
        
        // Create a CAShapeLayer
        let lightColor = teamColorB.withAlphaComponent(0.3)
        let rearShapeLayer = CAShapeLayer()
        rearShapeLayer.path = rearPath.cgPath
        rearShapeLayer.fillColor = lightColor.cgColor
        rearShapeLayer.position = CGPoint(x: 0, y: 0)

        portraitHeaderContainerView.layer.insertSublayer(rearShapeLayer, below: portraitMascotContainerViewB.layer)
        
        
        // Create a new path for the dark front part
        let frontPath = UIBezierPath()

        // Starting point for the path
        frontPath.move(to: CGPoint(x: width, y: 0))
        frontPath.addLine(to: CGPoint(x: width - 26, y: 0))
        frontPath.addLine(to: CGPoint(x: width - 47, y: portraitHeaderContainerView.frame.size.height))
        frontPath.addLine(to: CGPoint(x: width, y: portraitHeaderContainerView.frame.size.height))
        frontPath.addLine(to: CGPoint(x: width, y: 0))
        frontPath.close()
        
        // Create a CAShapeLayer
        let frontShapeLayer = CAShapeLayer()
        frontShapeLayer.path = frontPath.cgPath
        frontShapeLayer.fillColor = teamColorB.cgColor
        frontShapeLayer.position = CGPoint(x: 0, y: 0)

        portraitHeaderContainerView.layer.insertSublayer(frontShapeLayer, above: rearShapeLayer)
        
    }
    
    func addLeftLandscapeShapeLayers()
    {
        // Left Side
        
        // Create a new path for the rear light part
        let rearPath = UIBezierPath()

        // Starting point for the path
        rearPath.move(to: CGPoint(x: 0, y: 0))
        rearPath.addLine(to: CGPoint(x: 30, y: 0))
        rearPath.addLine(to: CGPoint(x: 60, y: landscapeHeaderContainerView.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: landscapeHeaderContainerView.frame.size.height))
        rearPath.addLine(to: CGPoint(x: 0, y: 0))
        rearPath.close()
        
        // Create a CAShapeLayer
        let lightColor = teamColorA.withAlphaComponent(0.3)
        let rearShapeLayer = CAShapeLayer()
        rearShapeLayer.path = rearPath.cgPath
        rearShapeLayer.fillColor = lightColor.cgColor
        rearShapeLayer.position = CGPoint(x: 0, y: 0)

        landscapeHeaderContainerView.layer.insertSublayer(rearShapeLayer, below: landscapeMascotContainerViewA.layer)
        
        
        // Create a new path for the dark front part
        let frontPath = UIBezierPath()

        // Starting point for the path
        frontPath.move(to: CGPoint(x: 0, y: 0))
        frontPath.addLine(to: CGPoint(x: 26, y: 0))
        frontPath.addLine(to: CGPoint(x: 47, y: landscapeHeaderContainerView.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: landscapeHeaderContainerView.frame.size.height))
        frontPath.addLine(to: CGPoint(x: 0, y: 0))
        frontPath.close()
        
        // Create a CAShapeLayer
        let frontShapeLayer = CAShapeLayer()
        frontShapeLayer.path = frontPath.cgPath
        frontShapeLayer.fillColor = teamColorA.cgColor
        frontShapeLayer.position = CGPoint(x: 0, y: 0)

        landscapeHeaderContainerView.layer.insertSublayer(frontShapeLayer, above: rearShapeLayer)
        
    }
    
    func addRightLandscapeShapeLayers()
    {
        // Right Side
        
        // Create a new path for the rear light part
        let rearPath = UIBezierPath()

        // Size the landscape header container to handle the notch
        var topNotch = 0.0
        var pad1 = 0.0
        var pad2 = 0.0
        if (SharedData.topNotchHeight > 0)
        {
            topNotch = CGFloat(SharedData.topNotchHeight)
            pad1 = kSmallPad
            pad2 = kLargePad
        }
        let width = kDeviceHeight - topNotch - pad1 - pad2
        
        // Starting point for the path
        rearPath.move(to: CGPoint(x: width, y: 0))
        rearPath.addLine(to: CGPoint(x: width - 30, y: 0))
        rearPath.addLine(to: CGPoint(x: width - 60, y: landscapeHeaderContainerView.frame.size.height))
        rearPath.addLine(to: CGPoint(x: width, y: landscapeHeaderContainerView.frame.size.height))
        rearPath.addLine(to: CGPoint(x: width, y: 0))
        rearPath.close()
        
        // Create a CAShapeLayer
        let lightColor = teamColorB.withAlphaComponent(0.3)
        let rearShapeLayer = CAShapeLayer()
        rearShapeLayer.path = rearPath.cgPath
        rearShapeLayer.fillColor = lightColor.cgColor
        rearShapeLayer.position = CGPoint(x: 0, y: 0)

        landscapeHeaderContainerView.layer.insertSublayer(rearShapeLayer, below: landscapeMascotContainerViewB.layer)
        
        
        // Create a new path for the dark front part
        let frontPath = UIBezierPath()

        // Starting point for the path
        frontPath.move(to: CGPoint(x: width, y: 0))
        frontPath.addLine(to: CGPoint(x: width - 26, y: 0))
        frontPath.addLine(to: CGPoint(x: width - 47, y: landscapeHeaderContainerView.frame.size.height))
        frontPath.addLine(to: CGPoint(x: width, y: landscapeHeaderContainerView.frame.size.height))
        frontPath.addLine(to: CGPoint(x: width, y: 0))
        frontPath.close()
        
        // Create a CAShapeLayer
        let frontShapeLayer = CAShapeLayer()
        frontShapeLayer.path = frontPath.cgPath
        frontShapeLayer.fillColor = teamColorB.cgColor
        frontShapeLayer.position = CGPoint(x: 0, y: 0)

        landscapeHeaderContainerView.layer.insertSublayer(frontShapeLayer, above: rearShapeLayer)
        
    }
    
    // MARK: - Build Headers
    
    private func buildPortraitHeader()
    {
        portraitHeaderContainerView.backgroundColor = UIColor.mpWhiteColor()
        portraitHeaderContainerView.layer.cornerRadius = 12
        portraitHeaderContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        portraitHeaderContainerView.clipsToBounds = true
        
        portraitMascotContainerViewA.layer.cornerRadius = portraitMascotContainerViewA.frame.size.width / 2.0
        portraitMascotContainerViewA.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        portraitMascotContainerViewA.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        portraitMascotContainerViewA.layer.shadowOpacity = 1.0
        portraitMascotContainerViewA.layer.shadowRadius = 4.0
        portraitMascotContainerViewA.clipsToBounds = false
        
        portraitMascotContainerViewB.layer.cornerRadius = portraitMascotContainerViewB.frame.size.width / 2.0
        portraitMascotContainerViewB.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        portraitMascotContainerViewB.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        portraitMascotContainerViewB.layer.shadowOpacity = 1.0
        portraitMascotContainerViewB.layer.shadowRadius = 4.0
        portraitMascotContainerViewB.clipsToBounds = false
        
        self.addLeftPortraitShapeLayers()
        self.addRightPortraitShapeLayers()
    }
    
    private func buildLandscapeHeader()
    {
        landscapeHeaderContainerView.backgroundColor = UIColor.mpWhiteColor()
        landscapeHeaderContainerView.layer.cornerRadius = 12
        landscapeHeaderContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        landscapeHeaderContainerView.clipsToBounds = true
        
        landscapeMascotContainerViewA.layer.cornerRadius = landscapeMascotContainerViewA.frame.size.width / 2.0
        landscapeMascotContainerViewA.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        landscapeMascotContainerViewA.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        landscapeMascotContainerViewA.layer.shadowOpacity = 1.0
        landscapeMascotContainerViewA.layer.shadowRadius = 4.0
        landscapeMascotContainerViewA.clipsToBounds = false
        
        landscapeMascotContainerViewB.layer.cornerRadius = portraitMascotContainerViewB.frame.size.width / 2.0
        landscapeMascotContainerViewB.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        landscapeMascotContainerViewB.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        landscapeMascotContainerViewB.layer.shadowOpacity = 1.0
        landscapeMascotContainerViewB.layer.shadowRadius = 4.0
        landscapeMascotContainerViewB.clipsToBounds = false
        
        self.addLeftLandscapeShapeLayers()
        self.addRightLandscapeShapeLayers()
    }
    
    // MARK: - Check Valid Fields
    
    @objc private func checkValidFields()
    {
        portraitScoreLabelA.text = scoreEntryScoreTextFieldA.text
        landscapeScoreLabelA.text = scoreEntryScoreTextFieldA.text
        portraitScoreLabelB.text = scoreEntryScoreTextFieldB.text
        landscapeScoreLabelB.text = scoreEntryScoreTextFieldB.text
        
        // Block the save button if the keyboard is showing
        if (nativeKeyboardVisible == true) || (landscapeKeyboardVisible == true)
        {
            saveButton.isEnabled = false
            saveButton.alpha = 0.5
            return
        }
        
        if ((selectedTeam!.sport == "Volleyball") || (selectedTeam!.sport == "Sand Volleyball") || (selectedTeam!.sport == "Beach Volleyball"))
        {
            // Final score is not required for Volleyball, just needs a forfeit
            if ((scoreEntryScoreTextFieldA.text!.count > 0) && (scoreEntryScoreTextFieldB.text!.count > 0))
            {
                saveButton.isEnabled = true
                saveButton.alpha = 1
            }
            else
            {
                if ((forfeitSwitchA.isOn == true) || (forfeitSwitchB.isOn == true))
                {
                    saveButton.isEnabled = true
                    saveButton.alpha = 1
                }
                else
                {
                    saveButton.isEnabled = false
                    saveButton.alpha = 0.5
                }
            }
        }
        else
        {
            if ((scoreEntryScoreTextFieldA.text!.count > 0) && (scoreEntryScoreTextFieldB.text!.count > 0))
            {
                saveButton.isEnabled = true
                saveButton.alpha = 1
            }
            else
            {
                saveButton.isEnabled = false
                saveButton.alpha = 0.5
            }
        }
    }
    
    // MARK: - Rotation Method
    
    @objc private func deviceRotated()
    {
        let orientation = UIDevice.current.orientation
        
        if (orientation == .landscapeLeft) || (orientation == .landscapeRight)
        {
            print("Landscape")
            
            // Skip if already in landscape mode
            if (landscapeMode == true)
            {
                return
            }
            
            // Dismiss/hide the keyboards
            self.view.endEditing(true)
            self.showLandscapeKeyboard(false)
            
            portraitBaseView.isHidden = true
            landscapeBaseView.isHidden = false
            landscapeMode = true
            
            // Reset out the cell backgrounds (came from portrait mode)
            //self.resetBackgroundColors()
            
            // Size the landscape header container to handle the notch
            var topNotch = 0.0
            var pad1 = 0.0
            var pad2 = 0.0
            if (SharedData.topNotchHeight > 0)
            {
                topNotch = CGFloat(SharedData.topNotchHeight)
                pad1 = kSmallPad
                pad2 = kLargePad
            }
            
            if (UIDevice.current.orientation == .landscapeRight)
            {
                // Notch is on the right
                landscapeHeaderContainerView.frame = CGRect(x: pad1, y: landscapeHeaderContainerView.frame.origin.y, width: kDeviceHeight - topNotch - pad1 - pad2, height: landscapeHeaderContainerView.frame.size.height)
                
                scoreEntryView.removeFromSuperview()
                forfeitView.removeFromSuperview()
                winnerView.removeFromSuperview()
                landscapeBaseView.addSubview(scoreEntryView)
                landscapeBaseView.addSubview(forfeitView)
                landscapeBaseView.addSubview(winnerView)
                
                scoreEntryView.frame = CGRect(x: pad1, y: landscapeHeaderContainerView.frame.origin.y + landscapeHeaderContainerView.frame.size.height, width: kDeviceHeight - topNotch - pad1 - pad2, height: scoreEntryView.frame.size.height)
                
                if (winnerView.isHidden)
                {
                    forfeitView.frame = CGRect(x: pad1, y: scoreEntryView.frame.origin.y + scoreEntryView.frame.size.height + 8.0, width: kDeviceHeight - topNotch - pad1 - pad2, height: forfeitView.frame.size.height)
                }
                else
                {
                    forfeitView.frame = CGRect(x: pad1, y: scoreEntryView.frame.origin.y + scoreEntryView.frame.size.height + 8.0, width: (kDeviceHeight - topNotch) / 2.0, height: forfeitView.frame.size.height)
                    
                    winnerView.frame = CGRect(x: pad1 + forfeitView.frame.size.width + 1, y: scoreEntryView.frame.origin.y + scoreEntryView.frame.size.height + 8.0, width: (kDeviceHeight - topNotch) / 2.0 - pad1 - pad2, height: winnerView.frame.size.height)
                }
                
                // Reset the ScrollView to the left
                scoreEntryScrollView.contentOffset = CGPoint(x: 0, y: 0)
                
                let contentWidth = Int(scoreEntryScrollView!.contentSize.width)
                let scrollViewWidth = Int(scoreEntryView.frame.size.width) - 144
                if (scrollViewWidth >= contentWidth)
                {
                    leftShadow.isHidden = true
                    rightShadow.isHidden = true
                    verticalLine.isHidden = false
                }
                else
                {
                    leftShadow.isHidden = true
                    rightShadow.isHidden = false
                    verticalLine.isHidden = true
                }
                
            }
            else
            {
                // Notch is on the left
                landscapeHeaderContainerView.frame = CGRect(x: topNotch + pad2, y: landscapeHeaderContainerView.frame.origin.y, width: kDeviceHeight - topNotch - pad1 - pad2, height: landscapeHeaderContainerView.frame.size.height)
                
                scoreEntryView.removeFromSuperview()
                forfeitView.removeFromSuperview()
                winnerView.removeFromSuperview()
                landscapeBaseView.addSubview(scoreEntryView)
                landscapeBaseView.addSubview(forfeitView)
                landscapeBaseView.addSubview(winnerView)
                
                scoreEntryView.frame = CGRect(x: topNotch + pad2, y: landscapeHeaderContainerView.frame.origin.y + landscapeHeaderContainerView.frame.size.height, width: kDeviceHeight - topNotch - pad1 - pad2, height: scoreEntryView.frame.size.height)
                
                if (winnerView.isHidden)
                {
                    forfeitView.frame = CGRect(x: topNotch + pad2, y: scoreEntryView.frame.origin.y + scoreEntryView.frame.size.height + 8.0, width: kDeviceHeight - topNotch - pad1 - pad2, height: forfeitView.frame.size.height)
                }
                else
                {
                    forfeitView.frame = CGRect(x: topNotch + pad2, y: scoreEntryView.frame.origin.y + scoreEntryView.frame.size.height + 8.0, width: (kDeviceHeight - topNotch) / 2.0, height: forfeitView.frame.size.height)
                    
                    winnerView.frame = CGRect(x: topNotch + pad2 + forfeitView.frame.size.width + 1, y: scoreEntryView.frame.origin.y + scoreEntryView.frame.size.height + 8.0, width: (kDeviceHeight - topNotch) / 2.0 - pad1 - pad2, height: winnerView.frame.size.height)
                }
                
                // Reset the ScrollView to the left
                scoreEntryScrollView.contentOffset = CGPoint(x: 0, y: 0)
                
                let contentWidth = Int(scoreEntryScrollView!.contentSize.width)
                let scrollViewWidth = Int(scoreEntryView.frame.size.width) - 144
                if (scrollViewWidth >= contentWidth)
                {
                    leftShadow.isHidden = true
                    rightShadow.isHidden = true
                    verticalLine.isHidden = false
                }
                else
                {
                    leftShadow.isHidden = true
                    rightShadow.isHidden = false
                    verticalLine.isHidden = true
                }
            }
            
        }
        else if (UIDevice.current.orientation == .portrait)
        {
            print("Portrait")
            
            // Skip if already in portrait mode
            if (landscapeMode == false)
            {
                return
            }
            
            // Reset out the cell backgrounds (came from landscape mode)
            self.resetBackgroundColors()
            
            // Dismiss/hide the keyboards
            self.view.endEditing(true)
            self.showLandscapeKeyboard(false)
            
            portraitBaseView.isHidden = false
            landscapeBaseView.isHidden = true
            landscapeMode = false
            
            scoreEntryView.removeFromSuperview()
            forfeitView.removeFromSuperview()
            winnerView.removeFromSuperview()
            portraitBaseView.addSubview(scoreEntryView)
            portraitBaseView.addSubview(forfeitView)
            portraitBaseView.addSubview(winnerView)
            
            scoreEntryView.frame = CGRect(x: 0, y: portraitHeaderContainerView.frame.origin.y + portraitHeaderContainerView.frame.size.height, width: kDeviceWidth, height: scoreEntryView.frame.size.height)
            
            forfeitView.frame = CGRect(x: 0, y: scoreEntryView.frame.origin.y + scoreEntryView.frame.size.height + 8.0, width: kDeviceWidth, height: forfeitView.frame.size.height)
            
            winnerView.frame = CGRect(x: 0, y: forfeitView.frame.origin.y + forfeitView.frame.size.height + 1.0, width: kDeviceWidth, height: winnerView.frame.size.height)
            
            // Reset the ScrollView to the left
            scoreEntryScrollView.contentOffset = CGPoint(x: 0, y: 0)
            
            let contentWidth = Int(scoreEntryScrollView!.contentSize.width)
            let scrollViewWidth = Int(scoreEntryView.frame.size.width) - 144
            if (scrollViewWidth >= contentWidth)
            {
                leftShadow.isHidden = true
                rightShadow.isHidden = true
                verticalLine.isHidden = false
            }
            else
            {
                leftShadow.isHidden = true
                rightShadow.isHidden = false
                verticalLine.isHidden = true
            }
            
        }
    }
    
    // MARK: - Landscape Keyboard Methods
    
    private func showLandscapeKeyboard(_ show: Bool)
    {
        if (show == true)
        {
            landscapeKeyboardView.isHidden = false
            
            UIView.animate(withDuration: 0.24, animations:
            {
                self.landscapeKeyboardView.transform = .identity
            })
            { (finished) in
                
            }
        }
        else
        {
            landscapeKeyboardView.isHidden = true
            
            UIView.animate(withDuration: 0.24, animations:
            {
                self.landscapeKeyboardView.transform = CGAffineTransform(translationX: 0, y: self.kLandscapeKeyboardHeight)
            })
            { (finished) in
                
            }
        }
    }
    
    func landscapeKeyboardDoneButtonTouched()
    {
        activeTextField.resignFirstResponder()
        self.showLandscapeKeyboard(false)
        
        self.resetBackgroundColors()
        
        if (activeTextField.tag >= 100) && (activeTextField.tag < 199)
        {
            self.calculateScore(top: true)
        }
        
        if (activeTextField.tag >= 200) && (activeTextField.tag < 299)
        {
            self.calculateScore(top: false)
        }
    } 
    
    func landscapeKeyboardNumberButtonTouched(value: Int)
    {
        print("Active tag:" + String(activeTextField.tag))
        
        let existingText = activeTextField.text
        if (activeTextField.tag == 199) || (activeTextField.tag == 299)
        {
            if (existingText!.count < 3)
            {
                activeTextField.text = existingText! + String(value)
            }
        }
        else
        {
            if (existingText!.count < 2)
            {
                activeTextField.text = existingText! + String(value)
            }
            
            
            if (activeTextField.tag >= 100) && (activeTextField.tag < 199)
            {
                self.calculateScore(top: true)
            }
            
            if (activeTextField.tag >= 200) && (activeTextField.tag < 299)
            {
                self.calculateScore(top: false)
            }
        }
    }
    
    func landscapeKeyboardBackspaceButtonTouched()
    {
        let existingText = activeTextField.text
        let count = existingText!.count
        if (count > 0)
        {
            let newText = String(existingText!.prefix(count - 1))
            activeTextField.text = newText
        }
        
        if (activeTextField.tag >= 100) && (activeTextField.tag < 199)
        {
            self.calculateScore(top: true)
        }
        
        if (activeTextField.tag >= 200) && (activeTextField.tag < 299)
        {
            self.calculateScore(top: false)
        }
    }
    
    func landscapeKeyboardLeftButtonTouched()
    {
        let tag = activeTextField.tag
        activeTextField.resignFirstResponder()
        
        for subview in scoreEntryScrollView.subviews
        {
            if (subview.tag >= 100) && (subview.tag < 199)
            {
                if (subview.tag == tag - 1)
                {
                    let subViewTextField = subview as! UITextField
                    subViewTextField.becomeFirstResponder()
                    break
                }
            }
            
            if (subview.tag >= 200) && (subview.tag < 299)
            {
                if (subview.tag == tag - 1)
                {
                    let subViewTextField = subview as! UITextField
                    subViewTextField.becomeFirstResponder()
                    break
                }
            }
        }
    }
    
    func landscapeKeyboardRightButtonTouched()
    {
        let tag = activeTextField.tag
        activeTextField.resignFirstResponder()
        
        for subview in scoreEntryScrollView.subviews
        {
            if (subview.tag >= 100) && (subview.tag < 199)
            {
                if (subview.tag == tag + 1)
                {
                    let subViewTextField = subview as! UITextField
                    subViewTextField.becomeFirstResponder()
                    break
                }
            }
            
            if (subview.tag >= 200) && (subview.tag < 299)
            {
                if (subview.tag == tag + 1)
                {
                    let subViewTextField = subview as! UITextField
                    subViewTextField.becomeFirstResponder()
                    break
                }
            }
        }
    }
    
    // MARK: - Button Methods
    
    @IBAction func backButtonTouched()
    {
        landscapeKeyboardView.removeFromSuperview()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonTouched()
    {
        self.updateBoxScores()
    }
    
    @objc private func systemKeyboardDoneButtonTouched()
    {
        self.view.endEditing(true)
    }
    
    @objc private func portraitKeyboardLeftButtonTouched(_ sender: UIButton)
    {
        // Iterate through the scoreEntryScrollView to find the previous textField
        for subview in scoreEntryScrollView.subviews
        {
            if ((subview.tag >= 100) && (subview.tag < 299))
            {
                let previousTextField = subview as! UITextField
                
                if (previousTextField.tag == (activeTextField.tag - 1))
                {
                    previousTextField.becomeFirstResponder()
                    break
                }
            }
        }
    }
    
    @objc private func portraitKeyboardRightButtonTouched(_ sender: UIButton)
    {
        // Iterate through the scoreEntryScrollView to find the next textField
        for subview in scoreEntryScrollView.subviews
        {
            if ((subview.tag >= 100) && (subview.tag < 299))
            {
                let nextTextField = subview as! UITextField
                
                if (nextTextField.tag == (activeTextField.tag + 1))
                {
                    nextTextField.becomeFirstResponder()
                    break
                }
            }
        }
    }
    
    // MARK: - Switch Methods
    
    @IBAction func winnerSwitchChangedA()
    {
        if (winnerSwitchA.isOn == true)
        {
            winnerSwitchB.isOn = false
        }
    }
    
    @IBAction func winnerSwitchChangedB()
    {
        if (winnerSwitchB.isOn == true)
        {
            winnerSwitchA.isOn = false
        }
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let xScroll = Int(scrollView.contentOffset.x)
        let contentWidth = Int(scoreEntryScrollView!.contentSize.width)
        let scrollViewWidth = Int(scoreEntryScrollView.frame.size.width)
        //print("ContentWidth: " + String(contentWidth))
        //print("ScrollViewWidth: " + String(scrollViewWidth))
        
        if (xScroll <= 0)
        {
            leftShadow.isHidden = true
            rightShadow.isHidden = false
            verticalLine.isHidden = true
        }
        else if ((xScroll > 0) && (xScroll < (contentWidth - scrollViewWidth)))
        {
            leftShadow.isHidden = false
            rightShadow.isHidden = false
            verticalLine.isHidden = true
        }
        else
        {
            leftShadow.isHidden = false
            rightShadow.isHidden = true
            verticalLine.isHidden = false
        }
    }
    
    // MARK: - Keyboard Accessory Views
    
    private func buildKeyboardAccessoryView(tag: Int, showNavButtons: Bool, isFirstAccessoryView: Bool, isLastAccessoryView: Bool) -> UIView
    {
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: kDeviceWidth, height: 40))
        accessoryView.backgroundColor = UIColor.mpWhiteColor()
        
        if (showNavButtons == true)
        {
            let portraitKeyboardLeftButton = UIButton(type: .custom)
            portraitKeyboardLeftButton.frame = CGRect(x: 5, y: 0, width: 40, height: 40)
            portraitKeyboardLeftButton.tag = tag
            
            if (isFirstAccessoryView == true)
            {
                portraitKeyboardLeftButton.setImage(UIImage(named: "AccessoryLeftGray"), for: .normal)
                portraitKeyboardLeftButton.isUserInteractionEnabled = false
            }
            else
            {
                portraitKeyboardLeftButton.setImage(UIImage(named: "AccessoryLeftRed"), for: .normal)
                portraitKeyboardLeftButton.addTarget(self, action: #selector(portraitKeyboardLeftButtonTouched(_:)), for: .touchUpInside)
            }
            accessoryView.addSubview(portraitKeyboardLeftButton)
            
            
            let portraitKeyboardRightButton = UIButton(type: .custom)
            portraitKeyboardRightButton.frame = CGRect(x: 50, y: 0, width: 40, height: 40)
            portraitKeyboardRightButton.addTarget(self, action: #selector(portraitKeyboardRightButtonTouched(_:)), for: .touchUpInside)
            portraitKeyboardRightButton.tag = tag
            
            if (isLastAccessoryView == true)
            {
                portraitKeyboardRightButton.setImage(UIImage(named: "AccessoryRightGray"), for: .normal)
                portraitKeyboardRightButton.isUserInteractionEnabled = false
            }
            else
            {
                portraitKeyboardRightButton.setImage(UIImage(named: "AccessoryRightRed"), for: .normal)
                portraitKeyboardRightButton.addTarget(self, action: #selector(portraitKeyboardRightButtonTouched(_:)), for: .touchUpInside)
            }
            accessoryView.addSubview(portraitKeyboardRightButton)
        }
        
        
        let doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: kDeviceWidth - 85, y: 5, width: 80, height: 30)
        doneButton.titleLabel?.font = UIFont.mpSemiBoldFontWith(size: 19)
        doneButton.setTitle("Done", for: .normal)
        doneButton.setTitleColor(UIColor.mpRedColor(), for: .normal)
        doneButton.addTarget(self, action: #selector(systemKeyboardDoneButtonTouched), for: .touchUpInside)
        doneButton.tag = tag
        accessoryView.addSubview(doneButton)
        
        return accessoryView
    }
    
    // MARK: - Keyboard Notifications
    
    @objc private func keyboardDidShow(notification: Notification)
    {
        nativeKeyboardVisible = true
    }
    
    @objc private func keyboardDidHide(notification: Notification)
    {
        nativeKeyboardVisible = false
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        let hexColorString = self.selectedTeam?.teamColor
        let currentTeamColor = ColorHelper.color(fromHexString: hexColorString, colorCorrection: true)!
        navView.backgroundColor = currentTeamColor
        fakeStatusBar.backgroundColor = currentTeamColor
        
        portraitBaseView.frame = CGRect(x: 0, y: kStatusBarHeight + SharedData.topNotchHeight + 40, width: Int(kDeviceWidth), height: Int(kDeviceHeight) - kStatusBarHeight - SharedData.topNotchHeight - 40)
        self.view.addSubview(portraitBaseView)
        
        landscapeBaseView.frame = CGRect(x: 0, y: 40, width: Int(kDeviceHeight), height: Int(kDeviceWidth) - 40)
        self.view.addSubview(landscapeBaseView)
        landscapeBaseView.isHidden = true
        
        scoreEntryView.frame = CGRect(x: 0, y: portraitHeaderContainerView.frame.origin.y + portraitHeaderContainerView.frame.size.height, width: kDeviceWidth, height: scoreEntryView.frame.size.height)
        portraitBaseView.addSubview(scoreEntryView)
        
        forfeitView.frame = CGRect(x: 0, y: scoreEntryView.frame.origin.y + scoreEntryView.frame.size.height + 8, width: kDeviceWidth, height: forfeitView.frame.size.height)
        portraitBaseView.addSubview(forfeitView)
        
        winnerView.frame = CGRect(x: 0, y: forfeitView.frame.origin.y + forfeitView.frame.size.height + 1.0, width: kDeviceWidth, height: winnerView.frame.size.height)
        portraitBaseView.addSubview(winnerView)
        winnerView.isHidden = true
        
        // Add the landscape keyboard and hide and move it
        landscapeKeyboardView = LandscapeKeyboardView(frame: CGRect(x: 0, y: kDeviceWidth - kLandscapeKeyboardHeight, width: kDeviceHeight, height: kLandscapeKeyboardHeight))
        landscapeKeyboardView.delegate = self
        landscapeKeyboardView.isHidden = true
        landscapeKeyboardView.transform = CGAffineTransform(translationX: 0, y: kLandscapeKeyboardHeight)
        
        self.view.addSubview(landscapeKeyboardView)
        
        if (SharedData.deviceType as! DeviceType == DeviceType.iphone)
        {
            NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        }
        
        // The left team is away
        let teams = selectedContest!["teams"] as! Array<Dictionary<String,Any>>
        var teamA = [:] as Dictionary<String,Any>
        var teamB = [:] as Dictionary<String,Any>
        
        // The home team is on the right
        let haTypeFirst = teams.first!["homeAwayType"] as! Int
        
        if (haTypeFirst == 0) // Home
        {
            teamA = teams.last!
            teamB = teams.first!
        }
        else
        {
            teamA = teams.first!
            teamB = teams.last!
        }
        
        if (teamA["color1"] is NSNull)
        {
            teamColorA = UIColor.mpRedColor()
        }
        else
        {
            let teamColorStringA = teamA["color1"] as! String
            teamColorA = ColorHelper.color(fromHexString: teamColorStringA, colorCorrection: true)
        }
        
        if (teamB["color1"] is NSNull)
        {
            teamColorB = UIColor.mpRedColor()
        }
        else
        {
            let teamColorStringB = teamB["color1"] as! String
            teamColorB = ColorHelper.color(fromHexString: teamColorStringB, colorCorrection: true)
        }
        
        saveButton.isEnabled = false
        saveButton.alpha = 0.5
        
        if ((selectedTeam?.sport == "Soccer") || (selectedTeam?.sport == "Water Polo"))
        {
            winnerView.isHidden = false
        }
        
        // This gets updated from the feed
        scoreEntryContestStateLabel.text = ""
        //scoreEntryScoreTextFieldA.tintColor = .clear // This gets rid of the I-beam
        //scoreEntryScoreTextFieldB.tintColor = .clear
        //scoreEntryScoreTextFieldA.tintColorDidChange()
        //scoreEntryScoreTextFieldB.tintColorDidChange()
        
        if (selectedTeam!.sport == "Volleyball") || (selectedTeam!.sport == "Sand Volleyball") || (selectedTeam!.sport == "Beach Volleyball")
        {
            // Disable the final score textFields and set thier background to offWhite
            scoreEntryScoreTextFieldA.isEnabled = false
            scoreEntryScoreTextFieldB.isEnabled = false
            scoreEntryScoreTextFieldA.backgroundColor = UIColor.mpOffWhiteNavColor()
            scoreEntryScoreTextFieldB.backgroundColor = UIColor.mpOffWhiteNavColor()
            //scoreEntryContestStateLabel.text = "Wins"
        }
        
        leftShadow.isHidden = true
        verticalLine.isHidden = true
        
        // Add the keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.buildPortraitHeader()
        self.buildLandscapeHeader()
        self.loadHeaderAndFooterData()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        setNeedsStatusBarAppearanceUpdate()

    }

    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return UIStatusBarStyle.lightContent
    }
    /*
    override var prefersHomeIndicatorAutoHidden: Bool
    {
        return true
    }
    
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge
    {
        return .bottom
    }
    */
    override var shouldAutorotate: Bool
    {
        if (SharedData.deviceType as! DeviceType == DeviceType.iphone)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation
    {
        return UIInterfaceOrientation.portrait
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        if (SharedData.deviceType as! DeviceType == DeviceType.iphone)
        {
            return .allButUpsideDown
        }
        else
        {
            return .portrait
        }
    }
    
    deinit
    {
        if (tickTimer != nil)
        {
            tickTimer.invalidate()
            tickTimer = nil
        }
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if (UIDevice.current.userInterfaceIdiom == .phone)
        {
            NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        }
    }
}
