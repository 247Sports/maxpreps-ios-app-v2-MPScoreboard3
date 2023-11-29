//
//  TeamHomeGameTableViewCell.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/2/22.
//

import UIKit

class TeamHomeGameTableViewCell: UITableViewCell
{
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var liveLabel: UILabel!
    @IBOutlet weak var gameStatusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var homeAwayLabel: UILabel!
    @IBOutlet weak var previewBoxscoreButton: UIButton!
    @IBOutlet weak var largeContestButton: UIButton!
    
    @IBOutlet weak var mascotContainerViewA: UIView!
    @IBOutlet weak var mascotImageViewA: UIImageView!
    @IBOutlet weak var initialLabelA: UILabel!
    @IBOutlet weak var scoreLabelA: UILabel!
    @IBOutlet weak var schoolNameLabelA: UILabel!
    @IBOutlet weak var recordLabelA: UILabel!
    
    @IBOutlet weak var mascotContainerViewB: UIView!
    @IBOutlet weak var mascotImageViewB: UIImageView!
    @IBOutlet weak var initialLabelB: UILabel!
    @IBOutlet weak var scoreLabelB: UILabel!
    @IBOutlet weak var schoolNameLabelB: UILabel!
    @IBOutlet weak var recordLabelB: UILabel!
    
    private var animationActive = false
    
    // MARK: - Animate Live Game View
    
    private func animateLiveGameView(_ enabled: Bool)
    {
        if (enabled == false)
        {
            animationView.isHidden = true
            liveLabel.isHidden = true
        }
        else
        {
            animationView.isHidden = false
            liveLabel.isHidden = false
            
            let width = kDeviceWidth - 184
            
            UIView.animate(withDuration: 1.3, animations:
                            {
                                self.animationView?.transform = CGAffineTransform(translationX: width, y: 0)
                            })
            { (finished) in
                
                UIView.animate(withDuration: 1.3, animations:
                                {
                                    self.animationView?.transform = CGAffineTransform(translationX: 0, y: 0)
                                })
                { (finished) in
                    
                    self.animateLiveGameView(self.animationActive)
                }
            }
        }
    }
    
    // MARK: - Load Data
    
    func loadData(_ data: Dictionary<String,Any>, mySchoolId: String)
    {
        animationActive = false
        self.animateLiveGameView(false)
        
        let contest = data["contest"] as! Dictionary<String,Any>
        let dateCode = contest["dateCode"] as! Int
        
        var contestDateString = contest["date"] as? String ?? "1901-01-01T00:00:00"
        contestDateString = contestDateString.replacingOccurrences(of: "Z", with: "")
        let dateFormatter = DateFormatter()
        dateFormatter.isLenient = true
        dateFormatter.dateFormat = kMaxPrepsScheduleDateFormat
        let contestDate = dateFormatter.date(from: contestDateString)
        
        var dayString = ""
        var timeString = ""
        var dateTimeString = ""
        
        switch dateCode
        {
        case 0: // Default
            dateFormatter.dateFormat = "E, MM/dd"
            let dateString = dateFormatter.string(from: contestDate!)
            let todayString = dateFormatter.string(from: Date())
            
            if (todayString == dateString)
            {
                dayString = "Today"
            }
            else
            {
                dayString = dateString
            }
            
            dateFormatter.dateFormat = "h:mm a"
            timeString = dateFormatter.string(from: contestDate!)
            break
            
        case 1: // DateTBA
            dayString = "TBA"
            dateFormatter.dateFormat = "h:mm a"
            timeString = dateFormatter.string(from: contestDate!)
            break
            
        case 2: // TimeTBA
            dateFormatter.dateFormat = "E, MM/dd"
            let dateString = dateFormatter.string(from: contestDate!)
            let todayString = dateFormatter.string(from: Date())
            
            if (todayString == dateString)
            {
                dayString = "Today"
            }
            else
            {
                dayString = dateString
            }
            
            timeString = "TBA"
            break
            
        default:
            dayString = "TBA"
            timeString = "TBA"
            break
        }
        
        dateTimeString = String(format: "%@ @ %@", dayString, timeString)
        
        let teams = contest["teams"] as! Array<Dictionary<String,Any>>
        var teamA = teams[0]
        var teamB = teams[1]
        let haType = teamA["homeAwayType"] as! Int
        
        if (haType == 0) // Home is teamB
        {
            teamA = teams[1]
            teamB = teams[0]
        }
        
        let schoolIdA = teamA["teamId"] as? String ?? ""
        
        var schoolNameA = teamA["name"] as? String ?? "TBA"
        var schoolNameB = teamB["name"] as? String ?? "TBA"
        
        if (schoolNameA.count > 18)
        {
            schoolNameA = teamA["schoolNameAcronym"] as? String ?? "TBA"
        }
        
        if (schoolNameB.count > 18)
        {
            schoolNameB = teamB["schoolNameAcronym"] as? String ?? "TBA"
        }
        
        schoolNameLabelA.text = schoolNameA
        schoolNameLabelB.text = schoolNameB
        
        initialLabelA.text = String(schoolNameA.prefix(1)).uppercased()
        let colorStringA = teamA["color1"] as? String ?? kMissingSchoolColor
        initialLabelA.textColor = ColorHelper.color(fromHexString: colorStringA, colorCorrection: true)
        
        initialLabelB.text = String(schoolNameB.prefix(1)).uppercased()
        let colorStringB = teamB["color1"] as? String ?? kMissingSchoolColor
        initialLabelB.textColor = ColorHelper.color(fromHexString: colorStringB, colorCorrection: true)
        
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
                        self.initialLabelA.isHidden = true
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.mascotImageViewA)!)
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
                        self.initialLabelB.isHidden = true
                        MiscHelper.renderImprovedMascot(sourceImage: image!, destinationImageView: (self.mascotImageViewB)!)
                    }
                }
            }
        }
        
        let contestType = teamA["contestType"] as? Int ?? -1
        var contestTypeString = ""
        
        switch contestType {
        case 0:
            contestTypeString = "Conference"
            break
        case 1:
            contestTypeString = "Non-Conference"
            break
        case 2:
            contestTypeString = "Tournament"
            break
        case 3:
            contestTypeString = "Exhibition"
            break
        case 4:
            contestTypeString = "Playoff"
            break
        case 5:
            contestTypeString = "Conference Tournament"
            break
        default:
            contestTypeString = "Unknown"
            break
        }
        
        // Added for when the feed update occurs
        if (data["contestTypeName"] != nil)
        {
            contestTypeString = data["contestTypeName"] as! String
        }
        
        var homeAwayString = ""
   
        var myTeamHaType = 0
        if (schoolIdA == mySchoolId)
        {
            myTeamHaType = teamA["homeAwayType"] as? Int ?? -1
        }
        else
        {
            myTeamHaType = teamB["homeAwayType"] as? Int ?? -1
        }
        
        switch myTeamHaType
        {
        case 0:
            homeAwayString = "Home"
            break
        case 1:
            homeAwayString = "Away"
            break
        case 2:
            homeAwayString = "Neutral"
            break
        default:
            homeAwayString = "Unknown"
            break
        }
 
        homeAwayLabel.text = String(format: "%@ • %@", homeAwayString, contestTypeString)
        
        // Contest state enums
        // 0: Unknown
        // 1: Deleted
        // 2: Pregame
        // 3: In Progress
        // 4: Boxscore
        // 5: Score not Reported
        
        // Game state dependent labels and button text
        if (data["calculatedFields"] != nil)
        {
            let calculatedFields = data["calculatedFields"] as! Dictionary<String,Any>
            let contestState = calculatedFields["contestState"] as! Int
            let teamsCalculated = calculatedFields["teamsCalculated"] as! Array<Dictionary<String,Any>>
            
            // Determine which teamCalculated teamId matches teamA or teamB
            var teamCalculatedA = teamsCalculated[0]
            var teamCalculatedB = teamsCalculated[1]
            
            let teamCalculatedSchoolIdA = teamCalculatedA["teamId"] as? String ?? ""
            if (schoolIdA != teamCalculatedSchoolIdA)
            {
                teamCalculatedA = teamsCalculated[1]
                teamCalculatedB = teamsCalculated[0]
            }
            
            gameStatusLabel.textColor = UIColor.mpBlackColor()
            dateLabel.textColor = UIColor.mpDarkGrayColor()
            dateLabel.font = UIFont.mpRegularFontWith(size: 15)
            
            switch contestState
            {
            case 2: // Pregame
                gameStatusLabel.text = dayString
                dateLabel.text = timeString
                dateTimeLabel.text = ""
                scoreLabelA.text = ""
                scoreLabelB.text = ""
                previewBoxscoreButton.setTitle("PREVIEW", for: .normal)
                break
                
            case 3: // In Progress
                animationActive = true
                self.animateLiveGameView(true)
                
                dateTimeLabel.text = dateTimeString
                
                let currentLivePeriod = calculatedFields["currentLivePeriod"] as? String ?? ""
                let currentLiveTime = calculatedFields["currentLiveTime"] as? String ?? ""
                
                dateLabel.textColor = UIColor.mpBlackColor()
                dateLabel.font = UIFont.mpBoldFontWith(size: 15)
                
                // Show the currentLivePeriod in the date label if currentLiveTime exists
                if (currentLiveTime != "")
                {
                    gameStatusLabel.text = currentLiveTime
                    dateLabel.text = currentLivePeriod
                }
                else
                {
                    gameStatusLabel.text = currentLivePeriod
                    dateLabel.text = ""
                }
                
                let scoreA = teamCalculatedA["currentLiveScore"] as? Int ?? -1
                let scoreB = teamCalculatedB["currentLiveScore"] as? Int ?? -1
                
                // Changed to show the score if not null
                if (scoreA != -1)
                {
                    scoreLabelA.text = String(scoreA)
                }
                else
                {
                    scoreLabelA.text = ""
                }
                
                if (scoreB != -1)
                {
                    scoreLabelB.text = String(scoreB)
                }
                else
                {
                    scoreLabelB.text = ""
                }
                
                previewBoxscoreButton.setTitle("BOX SCORE", for: .normal)
                break
                
            case 4: // Boxscore
                gameStatusLabel.text = "FINAL"
                dateLabel.text = ""
                dateTimeLabel.text = dateTimeString
                
                let scoreA = teamA["score"] as? Int ?? 0
                let scoreB = teamB["score"] as? Int ?? 0
                scoreLabelA.text = String(scoreA)
                scoreLabelB.text = String(scoreB)
                
                previewBoxscoreButton.setTitle("BOX SCORE", for: .normal)
                break
                
            case 5: // Score not Reported
                gameStatusLabel.text = "Missing Score"
                gameStatusLabel.textColor = UIColor.mpRedColor()
                dateLabel.text = ""
                dateTimeLabel.text = dateTimeString
                scoreLabelA.text = "--"
                scoreLabelB.text = "--"
                
                previewBoxscoreButton.setTitle("REPORT FINAL SCORE", for: .normal)
                break
                
            default:
                gameStatusLabel.text = dayString
                dateLabel.text = timeString
                dateTimeLabel.text = dateTimeString
                break
            }
        }
        else
        {
            gameStatusLabel.text = dayString
            dateLabel.text = timeString
            dateTimeLabel.text = ""
            scoreLabelA.text = ""
            scoreLabelB.text = ""
            previewBoxscoreButton.setTitle("PREVIEW", for: .normal)
        }
        
        // Team Records
        recordLabelA.text = ""
        recordLabelB.text = ""
        
        if (data["contestTeamStandings"] != nil)
        {
            let contestTeamStandings = data["contestTeamStandings"] as! Array<Dictionary<String,Any>>
            var recordTeamA = contestTeamStandings[0]
            var recordTeamB = contestTeamStandings[1]
            
            let recordSchoolIdA = recordTeamA["teamId"] as! String
            
            // Swap if needed
            if (recordSchoolIdA != schoolIdA)
            {
                recordTeamA = contestTeamStandings[1]
                recordTeamB = contestTeamStandings[0]
            }
            let recordA = recordTeamA["overallWinLossTies"] as! String
            let recordB = recordTeamB["overallWinLossTies"] as! String
            
            recordLabelA.text = recordA
            recordLabelB.text = recordB
        }
        
        /*
         ▿ 4 elements
           ▿ 0 : 2 elements
             - key : "hudlInfo"
             ▿ value : 4 elements
               ▿ 0 : 2 elements
                 - key : isHudlConnected
                 - value : 0
               ▿ 1 : 2 elements
                 - key : hasHudlStats
                 - value : 0
               ▿ 2 : 2 elements
                 - key : hasHudlStatsPending
                 - value : 0
               ▿ 3 : 2 elements
                 - key : contestId
                 - value : cd5340da-c8d6-40e0-bd8a-d1799a7bb5c6
           ▿ 1 : 2 elements
             - key : "tournamentInfo"
             - value : <null>
           ▿ 2 : 2 elements
             - key : "calculatedFields"
             ▿ value : 28 elements
               ▿ 0 : 2 elements
                 - key : isLiveScoringEnabled
                 - value : 1
               ▿ 1 : 2 elements
                 - key : currentScorerFirstName
                 - value :
               ▿ 2 : 2 elements
                 - key : currentScorerUserId
                 - value : 00000000-0000-0000-0000-000000000000
               ▿ 3 : 2 elements
                 - key : reasonWhyCannotEnterScores
                 - value :
               ▿ 4 : 2 elements
                 - key : teamsCalculated
                 ▿ value : 2 elements
                   ▿ 0 : 5 elements
                     ▿ 0 : 2 elements
                       - key : hasHudlStatsImported
                       - value : 0
                     ▿ 1 : 2 elements
                       - key : teamId
                       - value : de0050ae-cf37-4ae6-b63d-301c97bd92d8
                     ▿ 2 : 2 elements
                       - key : calculatedTeamContestResult
                       - value : 1
                     ▿ 3 : 2 elements
                       - key : currentLiveScore
                       - value : <null>
                     ▿ 4 : 2 elements
                       - key : contestId
                       - value : cd5340da-c8d6-40e0-bd8a-d1799a7bb5c6
                   ▿ 1 : 5 elements
                     ▿ 0 : 2 elements
                       - key : hasHudlStatsImported
                       - value : 0
                     ▿ 1 : 2 elements
                       - key : teamId
                       - value : 5a9bf7f3-15c1-45e5-beda-6aee1c8fd9f7
                     ▿ 2 : 2 elements
                       - key : calculatedTeamContestResult
                       - value : 1
                     ▿ 3 : 2 elements
                       - key : currentLiveScore
                       - value : <null>
                     ▿ 4 : 2 elements
                       - key : contestId
                       - value : cd5340da-c8d6-40e0-bd8a-d1799a7bb5c6
               ▿ 5 : 2 elements
                 - key : allowReportFinalScore
                 - value : 1
               ▿ 6 : 2 elements
                 - key : isLiveGameInProgress
                 - value : 0
               ▿ 7 : 2 elements
                 - key : calculatedContestResult
                 - value : 1
               ▿ 8 : 2 elements
                 - key : currentScorerLastName
                 - value :
               ▿ 9 : 2 elements
                 - key : bracketGameIndex
                 - value : 0
               ▿ 10 : 2 elements
                 - key : contestId
                 - value : cd5340da-c8d6-40e0-bd8a-d1799a7bb5c6
               ▿ 11 : 2 elements
                 - key : isDateTba
                 - value : 0
               ▿ 12 : 2 elements
                 - key : isTimeTba
                 - value : 0
               ▿ 13 : 2 elements
                 - key : overtimeAlias
                 - value : Overtime
               ▿ 14 : 2 elements
                 - key : isGameChangerConnected
                 - value : 0
               ▿ 15 : 2 elements
                 - key : bracketMatchupID
                 - value : 00000000-0000-0000-0000-000000000000
               ▿ 16 : 2 elements
                 - key : canonicalUrl
                 - value : https://www.maxpreps.com/games/2-22-2022/basketball-21-22/maxpreps-vs-maxpreps-b.htm?c=2kBTzdbI4EC9itF5mnu1xg
               ▿ 17 : 2 elements
                 - key : overtimePeriodsPlayed
                 - value : 0
               ▿ 18 : 2 elements
                 - key : currentLivePeriod
                 - value :
               ▿ 19 : 2 elements
                 - key : contestState
                 - value : 3
               ▿ 20 : 2 elements
                 - key : hasContestPage
                 - value : 1
               ▿ 21 : 2 elements
                 - key : bracketIsPublished
                 - value : 0
               ▿ 22 : 2 elements
                 - key : contestAlias
                 - value : Game
               ▿ 23 : 2 elements
                 - key : allowEditContestResults
                 - value : 0
               ▿ 24 : 2 elements
                 - key : overtimeShortAlias
                 - value : OT
               ▿ 25 : 2 elements
                 - key : rolesWhoCanEnterScores
                 ▿ value : 3 elements
                   - 0 : StandardAdminUser
                   - 1 : HeadCoach
                   - 2 : Any
               ▿ 26 : 2 elements
                 - key : hasGameChangerImportedStats
                 - value : 0
               ▿ 27 : 2 elements
                 - key : bracketGamesInMatchup
                 - value : 0
           ▿ 3 : 2 elements
             - key : "contest"
             ▿ value : 31 elements
               ▿ 0 : 2 elements
                 - key : tournamentId
                 - value : <null>
               ▿ 1 : 2 elements
                 - key : isDeleted
                 - value : 0
               ▿ 2 : 2 elements
                 - key : modifiedOn
                 - value : 2022-02-22T19:19:00
               ▿ 3 : 2 elements
                 - key : location
                 - value : <null>
               ▿ 4 : 2 elements
                 - key : isGow
                 - value : 0
               ▿ 5 : 2 elements
                 - key : scoreSource
                 - value : <null>
               ▿ 6 : 2 elements
                 - key : createdOn
                 - value : 2022-02-22T19:19:00
               ▿ 7 : 2 elements
                 - key : sportSeasonId
                 - value : d2d0ec1a-dffa-4d23-a1e2-8c8510e858ba
               ▿ 8 : 2 elements
                 - key : hasStory
                 - value : 0
               ▿ 9 : 2 elements
                 - key : city
                 - value : <null>
               ▿ 10 : 2 elements
                 - key : isFlagged
                 - value : 0
               ▿ 11 : 2 elements
                 - key : storyPickedupOn
                 - value : <null>
               ▿ 12 : 2 elements
                 - key : contestId
                 - value : cd5340da-c8d6-40e0-bd8a-d1799a7bb5c6
               ▿ 13 : 2 elements
                 - key : name
                 - value : <null>
               ▿ 14 : 2 elements
                 - key : state
                 - value : <null>
               ▿ 15 : 2 elements
                 - key : shouldBuildNewStory
                 - value : 0
               ▿ 16 : 2 elements
                 - key : isScheduleImport
                 - value : 0
               ▿ 17 : 2 elements
                 - key : details
                 - value : <null>
               ▿ 18 : 2 elements
                 - key : date
                 - value : 2022-02-22T11:15:00
               ▿ 19 : 2 elements
                 - key : teams
                 ▿ value : 2 elements
                   ▿ 0 : 65 elements
                     ▿ 0 : 2 elements
                       - key : homeAwayType
                       - value : 0
                     ▿ 1 : 2 elements
                       - key : score
                       - value : <null>
                     ▿ 2 : 2 elements
                       - key : hasStats
                       - value : 0
                     ▿ 3 : 2 elements
                       - key : id
                       - value : baabfb0b-bf95-42e1-990a-69efa5a6b0d0
                     ▿ 4 : 2 elements
                       - key : teamCanonicalUrl
                       - value : https://www.maxpreps.com/high-schools/maxpreps-preppies-(max,ca)/basketball/home.htm
                     ▿ 5 : 2 elements
                       - key : b10
                       - value : <null>
                     ▿ 6 : 2 elements
                       - key : formattedNameWithoutState
                       - value : MaxPreps (Max)
                     ▿ 7 : 2 elements
                       - key : result
                       - value : <null>
                     ▿ 8 : 2 elements
                       - key : statEnteredOn
                       - value : <null>
                     ▿ 9 : 2 elements
                       - key : state
                       - value : CA
                     ▿ 10 : 2 elements
                       - key : b11
                       - value : <null>
                     ▿ 11 : 2 elements
                       - key : color2
                       - value : 108073
                     ▿ 12 : 2 elements
                       - key : color4
                       - value : 754ACC
                     ▿ 13 : 2 elements
                       - key : b12
                       - value : <null>
                     ▿ 14 : 2 elements
                       - key : b1
                       - value : <null>
                     ▿ 15 : 2 elements
                       - key : b2
                       - value : <null>
                     ▿ 16 : 2 elements
                       - key : contestId
                       - value : cd5340da-c8d6-40e0-bd8a-d1799a7bb5c6
                     ▿ 17 : 2 elements
                       - key : b13
                       - value : <null>
                     ▿ 18 : 2 elements
                       - key : b20
                       - value : <null>
                     ▿ 19 : 2 elements
                       - key : b3
                       - value : <null>
                     ▿ 20 : 2 elements
                       - key : teamId
                       - value : de0050ae-cf37-4ae6-b63d-301c97bd92d8
                     ▿ 21 : 2 elements
                       - key : mascotUrl
                       - value : https://dw3jhbqsbya58.cloudfront.net/fit-in/1024x1024/school-mascot/d/e/0/de0050ae-cf37-4ae6-b63d-301c97bd92d8.gif?version=637729525800000000
                     ▿ 22 : 2 elements
                       - key : b4
                       - value : <null>
                     ▿ 23 : 2 elements
                       - key : b14
                       - value : <null>
                     ▿ 24 : 2 elements
                       - key : b21
                       - value : <null>
                     ▿ 25 : 2 elements
                       - key : teamModifiedOn
                       - value : <null>
                     ▿ 26 : 2 elements
                       - key : b5
                       - value : <null>
                     ▿ 27 : 2 elements
                       - key : totalsNeedUpdate
                       - value : 0
                     ▿ 28 : 2 elements
                       - key : b6
                       - value : <null>
                     ▿ 29 : 2 elements
                       - key : b15
                       - value : <null>
                     ▿ 30 : 2 elements
                       - key : b22
                       - value : <null>
                     ▿ 31 : 2 elements
                       - key : b7
                       - value : <null>
                     ▿ 32 : 2 elements
                       - key : b8
                       - value : <null>
                     ▿ 33 : 2 elements
                       - key : b16
                       - value : <null>
                     ▿ 34 : 2 elements
                       - key : b23
                       - value : <null>
                     ▿ 35 : 2 elements
                       - key : b30
                       - value : <null>
                     ▿ 36 : 2 elements
                       - key : name
                       - value : MaxPreps
                     ▿ 37 : 2 elements
                       - key : b9
                       - value : <null>
                     ▿ 38 : 2 elements
                       - key : b17
                       - value : <null>
                     ▿ 39 : 2 elements
                       - key : b24
                       - value : <null>
                     ▿ 40 : 2 elements
                       - key : sportSeasonId
                       - value : d2d0ec1a-dffa-4d23-a1e2-8c8510e858ba
                     ▿ 41 : 2 elements
                       - key : formattedName
                       - value : MaxPreps (Max, CA)
                     ▿ 42 : 2 elements
                       - key : place
                       - value : <null>
                     ▿ 43 : 2 elements
                       - key : b18
                       - value : <null>
                     ▿ 44 : 2 elements
                       - key : b25
                       - value : <null>
                     ▿ 45 : 2 elements
                       - key : contestType
                       - value : 0
                     ▿ 46 : 2 elements
                       - key : color1
                       - value : CC0022
                     ▿ 47 : 2 elements
                       - key : isForfeit
                       - value : 0
                     ▿ 48 : 2 elements
                       - key : color3
                       - value : C8880A
                     ▿ 49 : 2 elements
                       - key : b19
                       - value : <null>
                     ▿ 50 : 2 elements
                       - key : b26
                       - value : <null>
                     ▿ 51 : 2 elements
                       - key : scoresUpdatedOn
                       - value : <null>
                     ▿ 52 : 2 elements
                       - key : resultString
                       - value : <null>
                     ▿ 53 : 2 elements
                       - key : b27
                       - value : <null>
                     ▿ 54 : 2 elements
                       - key : bFieldsUpdatedOn
                       - value : <null>
                     ▿ 55 : 2 elements
                       - key : index
                       - value : 1
                     ▿ 56 : 2 elements
                       - key : scorePrediction
                       - value : <null>
                     ▿ 57 : 2 elements
                       - key : schoolNameAcronym
                       - value : MPHS
                     ▿ 58 : 2 elements
                       - key : b28
                       - value : <null>
                     ▿ 59 : 2 elements
                       - key : dnp
                       - value : 0
                     ▿ 60 : 2 elements
                       - key : isDeleted
                       - value : 0
                     ▿ 61 : 2 elements
                       - key : city
                       - value : Max
                     ▿ 62 : 2 elements
                       - key : statSupplierId
                       - value : <null>
                     ▿ 63 : 2 elements
                       - key : b29
                       - value : <null>
                     ▿ 64 : 2 elements
                       - key : isTeamTBA
                       - value : 0
                   ▿ 1 : 65 elements
                     ▿ 0 : 2 elements
                       - key : homeAwayType
                       - value : 1
                     ▿ 1 : 2 elements
                       - key : score
                       - value : <null>
                     ▿ 2 : 2 elements
                       - key : hasStats
                       - value : 0
                     ▿ 3 : 2 elements
                       - key : id
                       - value : 981b9ee3-37ea-4079-b922-8dd11345623f
                     ▿ 4 : 2 elements
                       - key : teamCanonicalUrl
                       - value : https://www.maxpreps.com/high-schools/maxpreps-b-mascot-(max,ca)/basketball/home.htm
                     ▿ 5 : 2 elements
                       - key : b10
                       - value : <null>
                     ▿ 6 : 2 elements
                       - key : formattedNameWithoutState
                       - value : MaxPreps B (Max)
                     ▿ 7 : 2 elements
                       - key : result
                       - value : <null>
                     ▿ 8 : 2 elements
                       - key : statEnteredOn
                       - value : <null>
                     ▿ 9 : 2 elements
                       - key : state
                       - value : CA
                     ▿ 10 : 2 elements
                       - key : b11
                       - value : <null>
                     ▿ 11 : 2 elements
                       - key : color2
                       - value : CC4E10
                     ▿ 12 : 2 elements
                       - key : color4
                       - value :
                     ▿ 13 : 2 elements
                       - key : b12
                       - value : <null>
                     ▿ 14 : 2 elements
                       - key : b1
                       - value : <null>
                     ▿ 15 : 2 elements
                       - key : b2
                       - value : <null>
                     ▿ 16 : 2 elements
                       - key : contestId
                       - value : cd5340da-c8d6-40e0-bd8a-d1799a7bb5c6
                     ▿ 17 : 2 elements
                       - key : b13
                       - value : <null>
                     ▿ 18 : 2 elements
                       - key : b20
                       - value : <null>
                     ▿ 19 : 2 elements
                       - key : b3
                       - value : <null>
                     ▿ 20 : 2 elements
                       - key : teamId
                       - value : 5a9bf7f3-15c1-45e5-beda-6aee1c8fd9f7
                     ▿ 21 : 2 elements
                       - key : mascotUrl
                       - value : https://dw3jhbqsbya58.cloudfront.net/fit-in/1024x1024/school-mascot/5/a/9/5a9bf7f3-15c1-45e5-beda-6aee1c8fd9f7.gif?version=637729525800000000
                     ▿ 22 : 2 elements
                       - key : b4
                       - value : <null>
                     ▿ 23 : 2 elements
                       - key : b14
                       - value : <null>
                     ▿ 24 : 2 elements
                       - key : b21
                       - value : <null>
                     ▿ 25 : 2 elements
                       - key : teamModifiedOn
                       - value : <null>
                     ▿ 26 : 2 elements
                       - key : b5
                       - value : <null>
                     ▿ 27 : 2 elements
                       - key : totalsNeedUpdate
                       - value : 0
                     ▿ 28 : 2 elements
                       - key : b6
                       - value : <null>
                     ▿ 29 : 2 elements
                       - key : b15
                       - value : <null>
                     ▿ 30 : 2 elements
                       - key : b22
                       - value : <null>
                     ▿ 31 : 2 elements
                       - key : b7
                       - value : <null>
                     ▿ 32 : 2 elements
                       - key : b8
                       - value : <null>
                     ▿ 33 : 2 elements
                       - key : b16
                       - value : <null>
                     ▿ 34 : 2 elements
                       - key : b23
                       - value : <null>
                     ▿ 35 : 2 elements
                       - key : b30
                       - value : <null>
                     ▿ 36 : 2 elements
                       - key : name
                       - value : MaxPreps B
                     ▿ 37 : 2 elements
                       - key : b9
                       - value : <null>
                     ▿ 38 : 2 elements
                       - key : b17
                       - value : <null>
                     ▿ 39 : 2 elements
                       - key : b24
                       - value : <null>
                     ▿ 40 : 2 elements
                       - key : sportSeasonId
                       - value : d2d0ec1a-dffa-4d23-a1e2-8c8510e858ba
                     ▿ 41 : 2 elements
                       - key : formattedName
                       - value : MaxPreps B (Max, CA)
                     ▿ 42 : 2 elements
                       - key : place
                       - value : <null>
                     ▿ 43 : 2 elements
                       - key : b18
                       - value : <null>
                     ▿ 44 : 2 elements
                       - key : b25
                       - value : <null>
                     ▿ 45 : 2 elements
                       - key : contestType
                       - value : 0
                     ▿ 46 : 2 elements
                       - key : color1
                       - value : 52000E
                     ▿ 47 : 2 elements
                       - key : isForfeit
                       - value : 0
                     ▿ 48 : 2 elements
                       - key : color3
                       - value :
                     ▿ 49 : 2 elements
                       - key : b19
                       - value : <null>
                     ▿ 50 : 2 elements
                       - key : b26
                       - value : <null>
                     ▿ 51 : 2 elements
                       - key : scoresUpdatedOn
                       - value : <null>
                     ▿ 52 : 2 elements
                       - key : resultString
                       - value : <null>
                     ▿ 53 : 2 elements
                       - key : b27
                       - value : <null>
                     ▿ 54 : 2 elements
                       - key : bFieldsUpdatedOn
                       - value : <null>
                     ▿ 55 : 2 elements
                       - key : index
                       - value : 2
                     ▿ 56 : 2 elements
                       - key : scorePrediction
                       - value : <null>
                     ▿ 57 : 2 elements
                       - key : schoolNameAcronym
                       - value : MPBHS
                     ▿ 58 : 2 elements
                       - key : b28
                       - value : <null>
                     ▿ 59 : 2 elements
                       - key : dnp
                       - value : 0
                     ▿ 60 : 2 elements
                       - key : isDeleted
                       - value : 0
                     ▿ 61 : 2 elements
                       - key : city
                       - value : Max
                     ▿ 62 : 2 elements
                       - key : statSupplierId
                       - value : <null>
                     ▿ 63 : 2 elements
                       - key : b29
                       - value : <null>
                     ▿ 64 : 2 elements
                       - key : isTeamTBA
                       - value : 0
               ▿ 20 : 2 elements
                 - key : gameSource
                 - value : <null>
               ▿ 21 : 2 elements
                 - key : scoreAddedOn
                 - value : <null>
               ▿ 22 : 2 elements
                 - key : hasResult
                 - value : 0
               ▿ 23 : 2 elements
                 - key : scoresAddedByUserId
                 - value : <null>
               ▿ 24 : 2 elements
                 - key : importedOn
                 - value : <null>
               ▿ 25 : 2 elements
                 - key : isMultiTeam
                 - value : 0
               ▿ 26 : 2 elements
                 - key : shouldOverrideConf
                 - value : 0
               ▿ 27 : 2 elements
                 - key : isScoreImport
                 - value : 0
               ▿ 28 : 2 elements
                 - key : tournamentBracketId
                 - value : <null>
               ▿ 29 : 2 elements
                 - key : dateCode
                 - value : 0
               ▿ 30 : 2 elements
                 - key : scoreStamp
                 - value : <null>
         */
        
    }
    
    // MARK: - Init
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        innerContainerView.layer.cornerRadius = 12
        innerContainerView.clipsToBounds = true
        
        mascotContainerViewA.layer.cornerRadius = mascotContainerViewA.frame.size.width / 2
        mascotContainerViewA.layer.borderWidth = 1
        mascotContainerViewA.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        mascotContainerViewA.clipsToBounds = true
        
        mascotContainerViewB.layer.cornerRadius = mascotContainerViewB.frame.size.width / 2
        mascotContainerViewB.layer.borderWidth = 1
        mascotContainerViewB.layer.borderColor = UIColor.mpHeaderBackgroundColor().cgColor
        mascotContainerViewB.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
