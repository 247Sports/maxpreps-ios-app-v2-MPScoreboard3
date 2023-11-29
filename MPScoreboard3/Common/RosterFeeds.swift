//
//  RosterFeeds.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/19/21.
//

import UIKit

class RosterFeeds: NSObject
{
    // MARK: - Roster Feeds
    
    class func getPublicRosters(teamId:String, ssid:String, sort: String, completionHandler: @escaping (_ athletes: Array<RosterAthlete>?, _ deletedAthletes: Array<RosterAthlete>?, _ staff: Array<RosterStaff>?, _ teamPhotoUrl: String?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetPublicRostersDev, teamId, ssid, sort)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetPublicRostersDev, teamId, ssid, sort)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetPublicRostersStaging, teamId, ssid, sort)
        }
        else
        {
            urlString = String(format: kGetPublicRostersProduction, teamId, ssid, sort)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    let data = dictionary["data"] as! Dictionary<String,Any>
                                    
                                    // Get the teamPhotoUrl and rosterCorrectionUrl
                                    let teamPhotoUrl = data["teamPhotoUrl"] as! String
                                    //let rosterCorrectionUrl = data["rosterCorrectionUrl"] as! String
                                    
                                    // Athletes
                                    let athleteData = data["athleteRoster"] as! Array<Dictionary<String, Any>>
                                    
                                    // Build an RosterAthlete object for deleted and non-deleted athletes
                                    var athleteRoster = [] as! Array<RosterAthlete>
                                    var deletedRoster = [] as! Array<RosterAthlete>
                                    
                                    for athlete in athleteData
                                    {
                                        let isDeleted = athlete["isDeleted"] as? Bool ?? false
                                        let athleteId = athlete["athleteId"] as? String ?? ""
                                        let firstName = athlete["firstName"] as? String ?? ""
                                        let lastName = athlete["lastName"] as? String ?? ""
                                        var classYear = String(athlete["classYear"] as? Int ?? -1)
                                        let jersey = athlete["jersey"] as? String ?? ""
                                        var heightInches = String(athlete["heightInches"] as? Int ?? -1)
                                        var heightFeet = String(athlete["heightFeet"] as? Int ?? -1)
                                        var weight = String(athlete["weight"] as? Int ?? -1)
                                        var weightClass = String(athlete["weightClass"] as? Int ?? -1)
                                        let position1 = athlete["position1"] as? String ?? ""
                                        let position2 = athlete["position2"] as? String ?? ""
                                        let position3 = athlete["position3"] as? String ?? ""
                                        let hasStats = athlete["hasStats"] as? Bool ?? false
                                        let isCaptain = athlete["isCaptain"] as? Bool ?? false
                                        let photoUrl = athlete["photoUrl"] as? String ?? ""
                                        let isPlayerOfTheGame = athlete["isPlayerOfTheGame"] as? Bool ?? false
                                        let isFemale = athlete["isFemale"] as? Bool ?? false
                                        let bio = athlete["bio"] as? String ?? ""
                                        let hasPhoto = athlete["hasPhoto"] as? Bool ?? false
                                        let rosterId = athlete["rosterId"] as? String ?? ""
                                        let careerId = athlete["careerProfileId"] as? String ?? ""
                                        
                                        if (classYear == "-1")
                                        {
                                            classYear = ""
                                        }
                                        
                                        if (heightInches == "-1")
                                        {
                                            heightInches = ""
                                        }
                                        
                                        if (heightFeet == "-1")
                                        {
                                            heightFeet = ""
                                        }
                                        
                                        if (weight == "-1")
                                        {
                                            weight = ""
                                        }
                                        
                                        if (weightClass == "-1")
                                        {
                                            weightClass = ""
                                        }
                                        
                                        let rosterAthlete = RosterAthlete(athleteId: athleteId, firstName: firstName, lastName: lastName, classYear: classYear, jersey: jersey, heightInches: heightInches, heightFeet: heightFeet, weight: weight, position1: position1, position2: position2, position3: position3, hasStats: hasStats, isCaptain: isCaptain, isDeleted: isDeleted, photoUrl: photoUrl, weightClass: weightClass, isPlayerOfTheGame: isPlayerOfTheGame, isFemale: isFemale, bio: bio, hasPhoto:hasPhoto, rosterId: rosterId, careerId: careerId)
                                                                                
                                        if (isDeleted == false)
                                        {
                                            athleteRoster.append(rosterAthlete)
                                        }
                                        else
                                        {
                                            deletedRoster.append(rosterAthlete)
                                        }
                                        
                                        /*
                                        "AthleteId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                                        "FirstName": "string",
                                        "LastName": "string",
                                        "ClassYear": 0,
                                        "Jersey": "string",
                                        "HeightInches": 0,
                                        "HeightFeet": 0,
                                        "Weight": 0,
                                        "WeightClass": 0,
                                        "Position1": "string",
                                        "Position2": "string",
                                        "Position3": "string",
                                        "HasStats": true,
                                        "IsCaptain": true,
                                        "IsDeleted": true,
                                        "PhotoUrl": "string",
                                        "SecondaryPhotoUrl": "string",
                                        "IsPlayerOfTheGame": true,
                                        "IsFemale": true,
                                        "Bio": "string",
                                        "HasPhoto": true,
                                        "RosterId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                                        "SchoolId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                                        "SportSeasonId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                                        "SportSeasonName": "string",
                                        "CareerProfileId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                                        "CreatedOn": "2021-08-09T18:15:55.481Z",
                                        "CanonicalUrl": "string"
                                        */
                                    }
                                    
                                    // Staff
                                    let staffData = data["staffRoster"] as! Array<Dictionary<String, Any>>
                                    
                                    // Build a RosterStaff object
                                    var staffRoster = [] as! Array<RosterStaff>
                                    
                                    for staff in staffData
                                    {
                                        let contactId = staff["contactId"] as? String ?? ""
                                        let userId = staff["userId"] as? String ?? ""
                                        let roleId = staff["roleId"] as? String ?? ""
                                        let firstName = staff["userFirstName"] as? String ?? ""
                                        let lastName = staff["userLastName"] as? String ?? ""
                                        let email = staff["userEmail"] as? String ?? ""
                                        let position = staff["position"] as? String ?? ""
                                        let roleName = staff["roleName"] as? String ?? ""
                                        let photoUrl = staff["photoUrl"] as? String ?? ""
                                        
                                        /*
                                         var contactId: String
                                         var userId: String
                                         var roleId: String
                                         var userFirstName: String
                                         var userFirstName: String
                                         var userEmail: String
                                         var position: String
                                         var roleName: String
                                         */
                                        
                                        let rosterStaff = RosterStaff(contactId: contactId, userId: userId, roleId: roleId, userFirstName: firstName, userLastName: lastName, userEmail: email, position: position, roleName: roleName, photoUrl: photoUrl)
                                        
                                        staffRoster.append(rosterStaff)
                                    }
                                    
                                    completionHandler(athleteRoster, deletedRoster, staffRoster, teamPhotoUrl, nil)
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, nil, nil, nil, compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, nil, nil, nil, error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, nil, nil, nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, nil, nil, nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, nil, nil, nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    class func getSecureRosters(teamId:String, ssid:String, sort: String, completionHandler: @escaping (_ athletes: Array<RosterAthlete>?, _ deletedAthletes: Array<RosterAthlete>?, _ staff: Array<RosterStaff>?, _ teamPhotoUrl: String?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetSecureRostersDev, teamId, ssid, sort)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetSecureRostersDev, teamId, ssid, sort)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetSecureRostersStaging, teamId, ssid, sort)
        }
        else
        {
            urlString = String(format: kGetSecureRostersProduction, teamId, ssid, sort)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    let data = dictionary["data"] as! Dictionary<String,Any>
                                    
                                    // Get the teamPhotoUrl and rosterCorrectionUrl
                                    let teamPhotoUrl = data["teamPhotoUrl"] as! String
                                    //let rosterCorrectionUrl = data["rosterCorrectionUrl"] as! String
                                    
                                    // Athletes
                                    let athleteData = data["athleteRoster"] as! Array<Dictionary<String, Any>>
                                    
                                    // Build an RosterAthlete object for deleted and non-deleted athletes
                                    var athleteRoster = [] as! Array<RosterAthlete>
                                    var deletedRoster = [] as! Array<RosterAthlete>
                                    
                                    for athlete in athleteData
                                    {
                                        let isDeleted = athlete["isDeleted"] as? Bool ?? false
                                        let athleteId = athlete["athleteId"] as? String ?? ""
                                        let firstName = athlete["firstName"] as? String ?? ""
                                        let lastName = athlete["lastName"] as? String ?? ""
                                        var classYear = String(athlete["classYear"] as? Int ?? -1)
                                        let jersey = athlete["jersey"] as? String ?? ""
                                        var heightInches = String(athlete["heightInches"] as? Int ?? -1)
                                        var heightFeet = String(athlete["heightFeet"] as? Int ?? -1)
                                        var weight = String(athlete["weight"] as? Int ?? -1)
                                        var weightClass = String(athlete["weightClass"] as? Int ?? -1)
                                        let position1 = athlete["position1"] as? String ?? ""
                                        let position2 = athlete["position2"] as? String ?? ""
                                        let position3 = athlete["position3"] as? String ?? ""
                                        let hasStats = athlete["hasStats"] as? Bool ?? false
                                        let isCaptain = athlete["isCaptain"] as? Bool ?? false
                                        let photoUrl = athlete["photoUrl"] as? String ?? ""
                                        let isPlayerOfTheGame = athlete["isPlayerOfTheGame"] as? Bool ?? false
                                        let isFemale = athlete["isFemale"] as? Bool ?? false
                                        let bio = athlete["bio"] as? String ?? ""
                                        let hasPhoto = athlete["hasPhoto"] as? Bool ?? false
                                        let rosterId = athlete["rosterId"] as? String ?? ""
                                        let careerId = athlete["careerProfileId"] as? String ?? ""
                                        
                                        if (classYear == "-1")
                                        {
                                            classYear = ""
                                        }
                                        
                                        if (heightInches == "-1")
                                        {
                                            heightInches = ""
                                        }
                                        
                                        if (heightFeet == "-1")
                                        {
                                            heightFeet = ""
                                        }
                                        
                                        if (weight == "-1")
                                        {
                                            weight = ""
                                        }
                                        
                                        if (weightClass == "-1")
                                        {
                                            weightClass = ""
                                        }
                                        
                                        let rosterAthlete = RosterAthlete(athleteId: athleteId, firstName: firstName, lastName: lastName, classYear: classYear, jersey: jersey, heightInches: heightInches, heightFeet: heightFeet, weight: weight, position1: position1, position2: position2, position3: position3, hasStats: hasStats, isCaptain: isCaptain, isDeleted: isDeleted, photoUrl: photoUrl, weightClass: weightClass, isPlayerOfTheGame: isPlayerOfTheGame, isFemale: isFemale, bio: bio, hasPhoto:hasPhoto, rosterId: rosterId, careerId: careerId)
                                                                                
                                        if (isDeleted == false)
                                        {
                                            athleteRoster.append(rosterAthlete)
                                        }
                                        else
                                        {
                                            deletedRoster.append(rosterAthlete)
                                        }
                                        
                                        /*
                                        "AthleteId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                                        "FirstName": "string",
                                        "LastName": "string",
                                        "ClassYear": 0,
                                        "Jersey": "string",
                                        "HeightInches": 0,
                                        "HeightFeet": 0,
                                        "Weight": 0,
                                        "WeightClass": 0,
                                        "Position1": "string",
                                        "Position2": "string",
                                        "Position3": "string",
                                        "HasStats": true,
                                        "IsCaptain": true,
                                        "IsDeleted": true,
                                        "PhotoUrl": "string",
                                        "SecondaryPhotoUrl": "string",
                                        "IsPlayerOfTheGame": true,
                                        "IsFemale": true,
                                        "Bio": "string",
                                        "HasPhoto": true,
                                        "RosterId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                                        "SchoolId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                                        "SportSeasonId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                                        "SportSeasonName": "string",
                                        "CareerProfileId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                                        "CreatedOn": "2021-08-09T18:15:55.481Z",
                                        "CanonicalUrl": "string"
                                        */
                                    }
                                    
                                    // Staff
                                    let staffData = data["staffRoster"] as! Array<Dictionary<String, Any>>
                                    
                                    // Build a RosterStaff object
                                    var staffRoster = [] as! Array<RosterStaff>
                                    
                                    for staff in staffData
                                    {
                                        let contactId = staff["contactId"] as? String ?? ""
                                        let userId = staff["userId"] as? String ?? ""
                                        let roleId = staff["roleId"] as? String ?? ""
                                        let firstName = staff["userFirstName"] as? String ?? ""
                                        let lastName = staff["userLastName"] as? String ?? ""
                                        let email = staff["userEmail"] as? String ?? ""
                                        let position = staff["position"] as? String ?? ""
                                        let roleName = staff["roleName"] as? String ?? ""
                                        let photoUrl = staff["photoUrl"] as? String ?? ""
                                        
                                        /*
                                         var contactId: String
                                         var userId: String
                                         var roleId: String
                                         var userFirstName: String
                                         var userFirstName: String
                                         var userEmail: String
                                         var position: String
                                         var roleName: String
                                         */
                                        
                                        let rosterStaff = RosterStaff(contactId: contactId, userId: userId, roleId: roleId, userFirstName: firstName, userLastName: lastName, userEmail: email, position: position, roleName: roleName, photoUrl: photoUrl)
                                        
                                        staffRoster.append(rosterStaff)
                                    }
                                    
                                    completionHandler(athleteRoster, deletedRoster, staffRoster, teamPhotoUrl, nil)
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, nil, nil, nil, compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, nil, nil, nil, error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, nil, nil, nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, nil, nil, nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, nil, nil, nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    class func addSecureAthlete(schoolId: String, ssid: String, firstName: String, lastName: String, classYear: String, jersey: String, heightFeet: String, heightInches: String, weight: String, weightClass: String, positions: String, gender: String, isCaptain: Bool, bio: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kAddSecureAthleteDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kAddSecureAthleteDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kAddSecureAthleteStaging, schoolId, ssid)
        }
        else
        {
            urlString = String(format: kAddSecureAthleteProduction, schoolId, ssid)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        // Build the header dictionary for Exact Target Emails
        urlRequest.addValue("iOS", forHTTPHeaderField: "mp-sources-roster-source")
        urlRequest.addValue("MaxPrepsApp", forHTTPHeaderField: "mp-sources-roster-subsource")
        urlRequest.addValue("Added", forHTTPHeaderField: "mp-sources-roster-type")
        urlRequest.addValue("None", forHTTPHeaderField: "mp-sources-roster-subtype")
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        urlRequest.addValue("maxprepsapp_ios", forHTTPHeaderField: "mp-sources-user-source")
                
        /*
        firstName      string
        lastName       string
        classYear      integer($int32)
                       nullable: true
        jersey         string
        heightInches   integer($int32)
                       nullable: true
        heightFeet     integer($int32)
                       nullable: true
        weight         integer($int32)
                       nullable: true
        position1      string
        position2      string
        position3      string
        isCaptain      boolean
        weightClass    integer($int32)
                       nullable: true
        isFemale       boolean
        bio            string
        */
        
        var parameters = [:] as Dictionary<String,Any>
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        parameters["firstName"] = firstName
        parameters["lastName"] = lastName
        parameters["jersey"] = jersey
        parameters["bio"] = bio
        parameters["isCaptain"] = isCaptain
        
        // Class Year
        if (classYear.count > 0)
        {
            let classYearNumber = formatter.number(from: classYear)
            parameters["classYear"] = classYearNumber
        }
        else
        {
            parameters["classYear"] = NSNull()
        }
        
        // Height
        if (heightFeet.count > 0) && (heightInches.count > 0)
        {
            let heightFeetNumber = formatter.number(from: heightFeet)
            let heightInchesNumber = formatter.number(from: heightInches)
            parameters["heightFeet"] = heightFeetNumber
            parameters["heightInches"] = heightInchesNumber
        }
        else
        {
            parameters["heightFeet"] = NSNull()
            parameters["heightInches"] = NSNull()
        }
        
        // Weight
        if (weight.count > 0)
        {
            let weightNumber = formatter.number(from: weight)
            parameters["weight"] = weightNumber
        }
        else
        {
            parameters["weight"] = NSNull()
        }
        
        // Weight Class
        if (weightClass.count > 0)
        {
            let weightClassNumber = formatter.number(from: weightClass)
            parameters["weightClass"] = weightClassNumber
        }
        else
        {
            parameters["weightClass"] = NSNull()
        }
        
        // Positions
        parameters["position1"] = ""
        parameters["position2"] = ""
        parameters["position3"] = ""
        
        if (positions != "")
        {
            let positionsArray = positions.components(separatedBy: ",")
            
            if (positionsArray.count == 1)
            {
                parameters["position1"] = positionsArray[0]
            }
            else if (positionsArray.count == 2)
            {
                parameters["position1"] = positionsArray[0]
                parameters["position2"] = positionsArray[1]
            }
            else if (positionsArray.count == 3)
            {
                parameters["position1"] = positionsArray[0]
                parameters["position2"] = positionsArray[1]
                parameters["position3"] = positionsArray[2]
            }
        }
        
        // This parameter is only looked at when the sport is wrestling
        parameters["isFemale"] = false
        
        if (gender.count > 0)
        {
            if (gender == "Female")
            {
                parameters["isFemale"] = true
            }
        }
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(nil, error)
            return
        }

        //let logOut = String(decoding: postBodyData!, as: UTF8.self)
        //print(logOut)

        urlRequest.httpBody = postBodyData
        
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    let data = dictionary["data"] as! Dictionary<String,Any>
                                    completionHandler(data, nil)
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    class func updateSecureAthlete(athleteId: String, firstName: String, lastName: String, classYear: String, jersey: String, heightFeet: String, heightInches: String, weight: String, weightClass: String, positions: String, gender: String, isCaptain: Bool, bio: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kUpdateSecureAthleteDev, athleteId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kUpdateSecureAthleteDev, athleteId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kUpdateSecureAthleteStaging, athleteId)
        }
        else
        {
            urlString = String(format: kUpdateSecureAthleteProduction, athleteId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "PATCH"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        // Build the header dictionary for Exact Target Emails
        urlRequest.addValue("iOS", forHTTPHeaderField: "mp-sources-roster-source")
        urlRequest.addValue("MaxPrepsApp", forHTTPHeaderField: "mp-sources-roster-subsource")
        urlRequest.addValue("Updated", forHTTPHeaderField: "mp-sources-roster-type")
        urlRequest.addValue("None", forHTTPHeaderField: "mp-sources-roster-subtype")
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        urlRequest.addValue("maxprepsapp_ios", forHTTPHeaderField: "mp-sources-user-source")
                
        /*
        firstName      string
        lastName       string
        classYear      integer($int32)
                       nullable: true
        jersey         string
        heightInches   integer($int32)
                       nullable: true
        heightFeet     integer($int32)
                       nullable: true
        weight         integer($int32)
                       nullable: true
        position1      string
        position2      string
        position3      string
        isCaptain      boolean
        weightClass    integer($int32)
                       nullable: true
        isFemale       boolean
        bio            string
        */
        
        var parameters = [:] as Dictionary<String,Any>
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        parameters["firstName"] = firstName
        parameters["lastName"] = lastName
        parameters["jersey"] = jersey
        parameters["bio"] = bio
        parameters["isCaptain"] = isCaptain
        
        // Class Year
        if (classYear.count > 0)
        {
            let classYearNumber = formatter.number(from: classYear)
            parameters["classYear"] = classYearNumber
        }
        else
        {
            parameters["classYear"] = NSNull()
        }
        
        // Height
        if (heightFeet.count > 0) && (heightInches.count > 0)
        {
            let heightFeetNumber = formatter.number(from: heightFeet)
            let heightInchesNumber = formatter.number(from: heightInches)
            parameters["heightFeet"] = heightFeetNumber
            parameters["heightInches"] = heightInchesNumber
        }
        else
        {
            parameters["heightFeet"] = NSNull()
            parameters["heightInches"] = NSNull()
        }
        
        // Weight
        if (weight.count > 0)
        {
            let weightNumber = formatter.number(from: weight)
            parameters["weight"] = weightNumber
        }
        else
        {
            parameters["weight"] = NSNull()
        }
        
        // Weight Class
        if (weightClass.count > 0)
        {
            let weightClassNumber = formatter.number(from: weightClass)
            parameters["weightClass"] = weightClassNumber
        }
        else
        {
            parameters["weightClass"] = NSNull()
        }
        
        // Positions
        parameters["position1"] = ""
        parameters["position2"] = ""
        parameters["position3"] = ""
        
        if (positions != "")
        {
            let positionsArray = positions.components(separatedBy: ",")
            
            if (positionsArray.count == 1)
            {
                parameters["position1"] = positionsArray[0]
            }
            else if (positionsArray.count == 2)
            {
                parameters["position1"] = positionsArray[0]
                parameters["position2"] = positionsArray[1]
            }
            else if (positionsArray.count == 3)
            {
                parameters["position1"] = positionsArray[0]
                parameters["position2"] = positionsArray[1]
                parameters["position3"] = positionsArray[2]
            }
        }
        
        // This parameter is only looked at when the sport is wrestling
        parameters["isFemale"] = false
        
        if (gender.count > 0)
        {
            if (gender == "Female")
            {
                parameters["isFemale"] = true
            }
        }
        
        // Iterate through the parameters to make a patch array
        var patchArray = [] as! Array<Dictionary<String,Any>>
        
        for item in parameters
        {
            let patchDictionary = ["path": item.key, "value": item.value, "op": "replace"]
            patchArray.append(patchDictionary)
        }
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: patchArray, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(nil, error)
            return
        }

        //let logOut = String(decoding: postBodyData!, as: UTF8.self)
        //print(logOut)

        urlRequest.httpBody = postBodyData
        
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
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    let data = dictionary["data"] as! Dictionary<String,Any>
                                    completionHandler(data, nil)
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    class func deleteSecureAthlete(schoolId: String, ssid: String, athleteId: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kDeleteSecureAthleteDev, schoolId, ssid, athleteId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kDeleteSecureAthleteDev, schoolId, ssid, athleteId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kDeleteSecureAthleteStaging, schoolId, ssid, athleteId)
        }
        else
        {
            urlString = String(format: kDeleteSecureAthleteProduction, schoolId, ssid, athleteId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        // Build the header dictionary for Exact Target Emails
        urlRequest.addValue("iOS", forHTTPHeaderField: "mp-sources-roster-source")
        urlRequest.addValue("MaxPrepsApp", forHTTPHeaderField: "mp-sources-roster-subsource")
        urlRequest.addValue("Removed", forHTTPHeaderField: "mp-sources-roster-type")
        urlRequest.addValue("None", forHTTPHeaderField: "mp-sources-roster-subtype")
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        urlRequest.addValue("maxprepsapp_ios", forHTTPHeaderField: "mp-sources-user-source")
        
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    let data = dictionary["data"] as! Dictionary<String,Any>
                                    completionHandler(data, nil)
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    class func restoreSecureAthlete(schoolId: String, ssid: String, athleteId: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kRestoreAthleteSecureDev, schoolId, ssid, athleteId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kRestoreAthleteSecureDev, schoolId, ssid, athleteId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kRestoreAthleteSecureStaging, schoolId, ssid, athleteId)
        }
        else
        {
            urlString = String(format: kRestoreAthleteSecureProduction, schoolId, ssid, athleteId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        // Build the header dictionary for Exact Target Emails
        urlRequest.addValue("iOS", forHTTPHeaderField: "mp-sources-roster-source")
        urlRequest.addValue("MaxPrepsApp", forHTTPHeaderField: "mp-sources-roster-subsource")
        urlRequest.addValue("Restored", forHTTPHeaderField: "mp-sources-roster-type")
        urlRequest.addValue("None", forHTTPHeaderField: "mp-sources-roster-subtype")
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        urlRequest.addValue("maxprepsapp_ios", forHTTPHeaderField: "mp-sources-user-source")
        
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    let data = dictionary["data"] as! Dictionary<String,Any>
                                    completionHandler(data, nil)
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    class func copyRosterSecure(schoolId: String, ssid: String, completionHandler: @escaping (_ result: Array<Dictionary<String,Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kCopyRosterSecureDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kCopyRosterSecureDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kCopyRosterSecureStaging, schoolId, ssid)
        }
        else
        {
            urlString = String(format: kCopyRosterSecureProduction, schoolId, ssid)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        // Build the header dictionary for Exact Target Emails
        urlRequest.addValue("iOS", forHTTPHeaderField: "mp-sources-roster-source")
        urlRequest.addValue("MaxPrepsApp", forHTTPHeaderField: "mp-sources-roster-subsource")
        urlRequest.addValue("Added", forHTTPHeaderField: "mp-sources-roster-type")
        urlRequest.addValue("None", forHTTPHeaderField: "mp-sources-roster-subtype")
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        urlRequest.addValue("maxprepsapp_ios", forHTTPHeaderField: "mp-sources-user-source")
        
        // Make an empty http body. The feed required this.
        urlRequest.httpBody = "{\"\":\"\"}".data(using: .utf8)
        
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    let data = dictionary["data"] as! Array<Dictionary<String,Any>>
                                    completionHandler(data, nil)
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    class func addSecureStaff(schoolId: String, ssid: String, firstName: String, lastName: String, email: String, position: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kAddSecureStaffDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kAddSecureStaffDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kAddSecureStaffStaging, schoolId, ssid)
        }
        else
        {
            urlString = String(format: kAddSecureStaffProduction, schoolId, ssid)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        // Build the header dictionary for Exact Target Emails
        urlRequest.addValue("iOS", forHTTPHeaderField: "mp-sources-roster-source")
        urlRequest.addValue("MaxPrepsApp", forHTTPHeaderField: "mp-sources-roster-subsource")
        urlRequest.addValue("Added", forHTTPHeaderField: "mp-sources-roster-type")
        urlRequest.addValue("None", forHTTPHeaderField: "mp-sources-roster-subtype")
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        urlRequest.addValue("maxprepsapp_ios", forHTTPHeaderField: "mp-sources-user-source")
                
        /*
         {
             "userFirstName": "Ken",
             "userLastName": "Singh",
             "position": "Statistician",
             "userEmail": "ksingh@maxpreps.com",
             "createdByUserId": null,
             "createdByPosition": null,
             "permissions": [
                     { "permissionFeatureId" : "20B19769-89E9-45D3-947D-95FCFE3AD4DC" },
                     { "permissionFeatureId" : "B1B50AC7-56C2-4CEE-B177-E6EAE284817F" },
                     { "permissionFeatureId" : "A80C8E18-F4E0-46C8-A509-6D47489D512D" }
             ]
         }
        */
        
        var parameters = [:] as Dictionary<String,Any>
        let permissions = [["permissionFeatureId":kCoachAllAccessPermissionId], ["permissionFeatureId":kCoachDataPermissionId], ["permissionFeatureId":kCoachCommunicationPermissionId]]
        
        parameters["userFirstName"] = firstName
        parameters["userLastName"] = lastName
        parameters["userEmail"] = email
        parameters["position"] = position
        parameters["permissions"] = permissions
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(nil, error)
            return
        }

        //NSString *logOut = [[NSString alloc]initWithData:postBodyData encoding:NSUTF8StringEncoding];
        //NSLog(@"Body data: %@", logOut);

        urlRequest.httpBody = postBodyData
        
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    let data = dictionary["data"] as! Dictionary<String,Any>
                                    completionHandler(data, nil)
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    class func updateSecureStaff(schoolId: String, ssid: String, staffId: String, firstName: String, lastName: String, email: String, position: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kUpdateOrDeleteSecureStaffDev, schoolId, ssid, staffId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kUpdateOrDeleteSecureStaffDev, schoolId, ssid, staffId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kUpdateOrDeleteSecureStaffStaging, schoolId, ssid, staffId)
        }
        else
        {
            urlString = String(format: kUpdateOrDeleteSecureStaffProduction, schoolId, ssid, staffId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "PATCH"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        // Build the header dictionary for Exact Target Emails
        urlRequest.addValue("iOS", forHTTPHeaderField: "mp-sources-roster-source")
        urlRequest.addValue("MaxPrepsApp", forHTTPHeaderField: "mp-sources-roster-subsource")
        urlRequest.addValue("Updated", forHTTPHeaderField: "mp-sources-roster-type")
        urlRequest.addValue("None", forHTTPHeaderField: "mp-sources-roster-subtype")
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        urlRequest.addValue("maxprepsapp_ios", forHTTPHeaderField: "mp-sources-user-source")
                
        /*
         {
             "userFirstName": "Ken",
             "userLastName": "Singh",
             "position": "Statistician",
             "userEmail": "ksingh@maxpreps.com",
             "createdByUserId": null,
             "createdByPosition": null,
             "permissions": [
                     { "permissionFeatureId" : "20B19769-89E9-45D3-947D-95FCFE3AD4DC" },
                     { "permissionFeatureId" : "B1B50AC7-56C2-4CEE-B177-E6EAE284817F" },
                     { "permissionFeatureId" : "A80C8E18-F4E0-46C8-A509-6D47489D512D" }
             ]
         }
        */
        
        var parameters = [:] as Dictionary<String,Any>
        let permissions = [["permissionFeatureId":kCoachAllAccessPermissionId], ["permissionFeatureId":kCoachDataPermissionId], ["permissionFeatureId":kCoachCommunicationPermissionId]]
        
        parameters["userFirstName"] = firstName
        parameters["userLastName"] = lastName
        parameters["userEmail"] = email
        parameters["position"] = position
        parameters["permissions"] = permissions
        
        // Iterate through the parameters to make a patch array
        var patchArray = [] as! Array<Dictionary<String,Any>>
        
        for item in parameters
        {
            let patchDictionary = ["path": item.key, "value": item.value, "op": "replace"]
            patchArray.append(patchDictionary)
        }
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: patchArray, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(nil, error)
            return
        }

        //NSString *logOut = [[NSString alloc]initWithData:postBodyData encoding:NSUTF8StringEncoding];
        //NSLog(@"Body data: %@", logOut);

        urlRequest.httpBody = postBodyData
        
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    let data = dictionary["data"] as! Dictionary<String,Any>
                                    completionHandler(data, nil)
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    class func deleteSecureStaff(schoolId: String, ssid: String, staffId: String, completionHandler: @escaping (_ success: Bool?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kUpdateOrDeleteSecureStaffDev, schoolId, ssid, staffId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kUpdateOrDeleteSecureStaffDev, schoolId, ssid, staffId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kUpdateOrDeleteSecureStaffStaging, schoolId, ssid, staffId)
        }
        else
        {
            urlString = String(format: kUpdateOrDeleteSecureStaffProduction, schoolId, ssid, staffId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        // Build the header dictionary for Exact Target Emails
        urlRequest.addValue("iOS", forHTTPHeaderField: "mp-sources-roster-source")
        urlRequest.addValue("MaxPrepsApp", forHTTPHeaderField: "mp-sources-roster-subsource")
        urlRequest.addValue("Removed", forHTTPHeaderField: "mp-sources-roster-type")
        urlRequest.addValue("None", forHTTPHeaderField: "mp-sources-roster-subtype")
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        urlRequest.addValue("maxprepsapp_ios", forHTTPHeaderField: "mp-sources-user-source")
        
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
                                completionHandler(true, nil)
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    class func getStaffDetails(staffUserId: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetStaffDetailsDev, staffUserId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetStaffDetailsDev, staffUserId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetStaffDetailsStaging, staffUserId)
        }
        else
        {
            urlString = String(format: kGetStaffDetailsProduction, staffUserId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token using the userId
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let items = dictionary["data"] as! Dictionary<String, Any>
                                    completionHandler(items, nil)
                                
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    class func getPublicStaffRoster(teamId:String, allSeasonId:String, season:String, completionHandler: @escaping (_ staff: Array<RosterStaff>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetPublicStaffRosterDev, teamId, allSeasonId, season)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetPublicStaffRosterDev, teamId, allSeasonId, season)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetPublicStaffRosterStaging, teamId, allSeasonId, season)
        }
        else
        {
            urlString = String(format: kGetPublicStaffRosterProduction, teamId, allSeasonId, season)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    let data = dictionary["data"] as! Array<Dictionary<String, Any>>
                                    
                                    // Build a RosterStaff object
                                    var staffRoster = [] as! Array<RosterStaff>
                                    
                                    for staff in data
                                    {
                                        let contactId = staff["contactId"] as? String ?? ""
                                        let userId = staff["userId"] as? String ?? ""
                                        let roleId = staff["roleId"] as? String ?? ""
                                        let firstName = staff["userFirstName"] as? String ?? ""
                                        let lastName = staff["userLastName"] as? String ?? ""
                                        let email = staff["userEmail"] as? String ?? ""
                                        let position = staff["position"] as? String ?? ""
                                        let roleName = staff["roleName"] as? String ?? ""
                                        let photoUrl = staff["photoUrl"] as? String ?? ""
                                        
                                        /*
                                         var contactId: String
                                         var userId: String
                                         var roleId: String
                                         var userFirstName: String
                                         var userFirstName: String
                                         var userEmail: String
                                         var position: String
                                         var roleName: String
                                         */
                                        
                                        let rosterStaff = RosterStaff(contactId: contactId, userId: userId, roleId: roleId, userFirstName: firstName, userLastName: lastName, userEmail: email, position: position, roleName: roleName, photoUrl: photoUrl)
                                        
                                        staffRoster.append(rosterStaff)
                                    }
                                    
                                    completionHandler(staffRoster, nil)
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Athlete and Team Photo Feeds
    
    class func addAthletePhoto(schoolId: String, ssid: String, athleteId: String, imageData: Data, completionHandler: @escaping (_ data: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kAddOrDeleteAthletePhotoDev, schoolId, ssid, athleteId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kAddOrDeleteAthletePhotoDev, schoolId, ssid, athleteId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kAddOrDeleteAthletePhotoStaging, schoolId, ssid, athleteId)
        }
        else
        {
            urlString = String(format: kAddOrDeleteAthletePhotoProduction, schoolId, ssid, athleteId)
        }
                
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        // Build the header dictionary for Exact Target Emails
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
        // Build the ContentType
        let boundary = FeedsHelper.generateBoundaryString()
        let contentType = "multipart/form-data; boundary=" + boundary
        urlRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")

        var body = Data()
        
        // Add the delimiting starting boundary
        let bodyPart1String = "\r\n--" + boundary + "\r\n"
        let bodyPart1Data: Data? = bodyPart1String.data(using: .utf8)
        body.append(bodyPart1Data!)
        
        //let bodyPart2String = "Content-Disposition: form-data; name=\"profilepic.jpeg\"; filename=\"picture.jpeg\"\r\n"
        let bodyPart2String = "Content-Disposition: form-data; name=\"file\"; filename=\"picture.jpeg\"\r\n"
        let bodyPart2Data: Data? = bodyPart2String.data(using: .utf8)
        body.append(bodyPart2Data!)
        
        let bodyPart3String = "Content-Type: image/jpeg\r\n\r\n"
        let bodyPart3Data: Data? = bodyPart3String.data(using: .utf8)
        body.append(bodyPart3Data!)
        
        // Now we append the actual image data
        body.append(imageData)
        
        // And the delimiting end boundary
        let bodyPart4String = "\r\n--" + boundary + "--\r\n"
        let bodyPart4Data: Data? = bodyPart4String.data(using: .utf8)
        body.append(bodyPart4Data!)
        
        urlRequest.httpBody = body
        
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let data = dictionary["data"] as! Dictionary<String,Any>
                                    
                                    // Finish the call
                                    completionHandler(data,nil)
                                    
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil,compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
        
    }
    
    class func deleteAthletePhoto(schoolId: String, ssid: String, athleteId: String, completionHandler: @escaping (_ data: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kAddOrDeleteAthletePhotoDev, schoolId, ssid, athleteId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kAddOrDeleteAthletePhotoDev, schoolId, ssid, athleteId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kAddOrDeleteAthletePhotoStaging, schoolId, ssid, athleteId)
        }
        else
        {
            urlString = String(format: kAddOrDeleteAthletePhotoProduction, schoolId, ssid, athleteId)
        }
                
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        // Build the header dictionary for Exact Target Emails
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let data = dictionary["data"] as! Dictionary<String,Any>
                                    
                                    // Finish the call
                                    completionHandler(data,nil)
                                    
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil,compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
        
    }
    
    class func getTeamPhoto(schoolId: String, ssid: String, completionHandler: @escaping (_ data: String?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetOrDeleteTeamPhotoDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetOrDeleteTeamPhotoDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetOrDeleteTeamPhotoStaging, schoolId, ssid)
        }
        else
        {
            urlString = String(format: kGetOrDeleteTeamPhotoProduction, schoolId, ssid)
        }
                
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        
        // Build the header dictionary for Exact Target Emails
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let data = dictionary["data"] as! String
                                    
                                    // Finish the call
                                    completionHandler(data, nil)
                                    
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil,compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
        
    }
    
    class func addTeamPhoto(schoolId: String, ssid: String, imageData: Data, completionHandler: @escaping (_ result: Bool?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kAddTeamPhotoDev, schoolId, ssid, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kAddTeamPhotoDev, schoolId, ssid, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kAddTeamPhotoStaging, schoolId, ssid, userId)
        }
        else
        {
            urlString = String(format: kAddTeamPhotoProduction, schoolId, ssid, userId)
        }
                
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        // Build the header dictionary for Exact Target Emails
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
        // Build the ContentType
        let boundary = FeedsHelper.generateBoundaryString()
        let contentType = "multipart/form-data; boundary=" + boundary
        urlRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")

        var body = Data()
        
        // Add the delimiting starting boundary
        let bodyPart1String = "\r\n--" + boundary + "\r\n"
        let bodyPart1Data: Data? = bodyPart1String.data(using: .utf8)
        body.append(bodyPart1Data!)
        
        let bodyPart2String = "Content-Disposition: form-data; name=\"image\"; filename=\"picture.jpg\"\r\n"
        let bodyPart2Data: Data? = bodyPart2String.data(using: .utf8)
        body.append(bodyPart2Data!)
        
        let bodyPart3String = "Content-Type: image/jpeg\r\n\r\n"
        let bodyPart3Data: Data? = bodyPart3String.data(using: .utf8)
        body.append(bodyPart3Data!)
        
        // Now we append the actual image data
        body.append(imageData)
        
        /*
        // Add an intermediate delimiter
        let bodyPart4Data: Data? = "\r\n".data(using: .utf8)
        body.append(bodyPart4Data!)
        
        // Add the second part of the post
        var json: Data? = nil
        do {
            json = try JSONSerialization.data(withJSONObject: ["userid":userId], options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(nil, error)
            return
        }
        
        let jsonString = String(data: json!, encoding: .utf8)
        
        let bodyPart5String = "--" + boundary + "\r\n"
        let bodyPart5Data: Data? = bodyPart5String.data(using: .utf8)
        body.append(bodyPart5Data!)
        
        let bodyPart6Data: Data? = "Content-Disposition: form-data; name=\"JSON\"".data(using: .utf8)
        body.append(bodyPart6Data!)
        
        let bodyPart7Data: Data? = "Content-Type: application/json\r\n".data(using: .utf8)
        body.append(bodyPart7Data!)
        
        let bodyPart8Data: Data? = (jsonString! + "\r\n").data(using: .utf8)
        body.append(bodyPart8Data!)
        */
        
        // And the final delimiting end boundary
        let bodyPart9String = "\r\n--" + boundary + "--\r\n"
        let bodyPart9Data: Data? = bodyPart9String.data(using: .utf8)
        body.append(bodyPart9Data!)
        
        /*
         //Add Json code from Red app
         [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

         [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", @"JSON"] dataUsingEncoding:NSUTF8StringEncoding]];

         [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", @"application/json"] dataUsingEncoding:NSUTF8StringEncoding]];

         
         [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n",json] dataUsingEncoding:NSUTF8StringEncoding]];

         
         [httpBody appendData:[[NSString stringWithFormat:@"--%@--", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
         */
        
        //let logData = String(decoding: body, as: UTF8.self)
        //print(logData)
        
        urlRequest.httpBody = body
        
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
                            completionHandler(true, nil)
                            /*
                            if (data != nil)
                            {
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let data = dictionary["data"] as! Dictionary<String,Any>
                                    
                                    // Finish the call
                                    completionHandler(data,nil)
                                    
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil,compositeError)
                                }
                                
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, error)
                            }
                            */
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
        
    }
    
    class func deleteTeamPhoto(schoolId: String, ssid: String, completionHandler: @escaping (_ result: Bool?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetOrDeleteTeamPhotoDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetOrDeleteTeamPhotoDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetOrDeleteTeamPhotoStaging, schoolId, ssid)
        }
        else
        {
            urlString = String(format: kGetOrDeleteTeamPhotoProduction, schoolId, ssid)
        }
                
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        // Build the header dictionary for Exact Target Emails
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
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
                            completionHandler(true, nil)
                            
                            /*
                            if (data != nil)
                            {
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let data = dictionary["data"] as! Dictionary<String,Any>
                                    
                                    // Finish the call
                                    completionHandler(data,nil)
                                    
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil,compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, error)
                            }
                            */
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
        
    }
}
