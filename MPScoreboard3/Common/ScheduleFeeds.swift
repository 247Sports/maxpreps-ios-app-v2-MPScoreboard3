//
//  ScheduleFeeds.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/19/21.
//

import UIKit

class ScheduleFeeds: NSObject
{
    class func getSchedule(schoolId: String, ssid: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetScheduleDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetScheduleDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetScheduleStaging, schoolId, ssid)
        }
        else
        {
            urlString = String(format: kGetScheduleProduction, schoolId, ssid)
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
                                    
                                    let schedule = dictionary["data"] as! Dictionary<String,Any>
                                            
                                    completionHandler(schedule, nil)
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
    
    class func getLeaguesForTeam(schoolId: String, ssid:String, completionHandler: @escaping (_ leagues: Array<Dictionary<String,Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetLeaguesForTeamDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetLeaguesForTeamDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetLeaguesForTeamStaging, schoolId, ssid)
        }
        else
        {
            urlString = String(format: kGetLeaguesForTeamProduction, schoolId, ssid)
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
                                    if let leagues = dictionary["data"] as? Array<Dictionary<String,Any>>
                                    {
                                        completionHandler(leagues, nil)
                                    }
                                    else
                                    {
                                        print("Data was nil")
                                        let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                        completionHandler(nil, error)
                                    }
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
    
    class func getTeamsForLeague(leagueId: String, ssid:String, completionHandler: @escaping (_ teams: Array<Dictionary<String,Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetTeamsForLeagueDev, leagueId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetTeamsForLeagueDev, leagueId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetTeamsForLeagueStaging, leagueId, ssid)
        }
        else
        {
            urlString = String(format: kGetTeamsForLeagueProduction, leagueId, ssid)
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
                                    if let teams = dictionary["data"] as? Array<Dictionary<String,Any>>
                                    {
                                        completionHandler(teams, nil)
                                    }
                                    else
                                    {
                                        print("Data was nil")
                                        let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                        completionHandler(nil, error)
                                    }
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
    
    class func getContest(schoolId: String, ssid: String, contestId: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetContestDev, schoolId, ssid, contestId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetContestDev, schoolId, ssid, contestId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetContestStaging, schoolId, ssid, contestId)
        }
        else
        {
            urlString = String(format: kGetContestProduction, schoolId, ssid, contestId)
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
                                    
                                    let schedule = dictionary["data"] as! Dictionary<String,Any>
                                            
                                    completionHandler(schedule, nil)
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
    
    class func addSecureContest(myTeamSchoolId: String, opponentSchoolId: String, opponentTBA: Bool, ssid: String, dateString: String, dateCode: Int, myTeamHomeAway: Int, opponentHomeAway: Int, contestType: Int, location: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ message: String?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kAddSecureContestDev, myTeamSchoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kAddSecureContestDev, myTeamSchoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kAddSecureContestStaging, myTeamSchoolId, ssid)
        }
        else
        {
            urlString = String(format: kAddSecureContestProduction, myTeamSchoolId, ssid)
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
        urlRequest.addValue("MobileApp", forHTTPHeaderField: "mp-sources-contest-source")
        urlRequest.addValue("MobileAppMaxprepsAppIOS", forHTTPHeaderField: "mp-sources-contest-subsource")
        urlRequest.addValue("ContestAddition", forHTTPHeaderField: "mp-sources-contest-type")
        urlRequest.addValue("None", forHTTPHeaderField: "mp-sources-contest-subtype")
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        urlRequest.addValue("maxprepsapp_ios", forHTTPHeaderField: "mp-sources-user-source")
                
        /*
        {
            teams:
            [
            {
                teamId          string (myTeam schoolId)
                sportSeasonId   string (ssid)
                isTeamTBA       bool (always 0)
                homeAwayType    int (0,1,2)
                contestType     int (0,1,2)
                index           int (1,2) 1 = home, 2 = away
            },
            {
                teamId          string (opponent schoolId)
                sportSeasonId   string (same as myTeam's ssid)
                isTeamTBA       bool (0 or 1)
                homeAwayType    int (0,1,2) (opposite of myTeam's HAtype)
                contestType     int (0,1,2)
                index           int (1,2)
            }
            ],
            date        string (UTC format)
            dateCode    int (0,1,2,3)
            location    string (optional)
        }
        */
        
        var parameters = [:] as Dictionary<String,Any>
        var myTeam = [:] as Dictionary<String,Any>
        var opponentTeam = [:] as Dictionary<String,Any>
        
        // Build the index (required)
        var myTeamIndex = 1 // home team is a 1, away is 2
        var opponentIndex = 2

        if (myTeamHomeAway == 1)
        {
            myTeamIndex = 2
            opponentIndex = 1
        }
        
        myTeam["teamId"] = myTeamSchoolId
        myTeam["sportSeasonId"] = ssid
        myTeam["homeAwayType"] = myTeamHomeAway
        myTeam["contestType"] = contestType
        myTeam["isTeamTBA"] = false
        myTeam["index"] = myTeamIndex
        
        opponentTeam["teamId"] = opponentSchoolId
        opponentTeam["sportSeasonId"] = ssid
        opponentTeam["homeAwayType"] = opponentHomeAway
        opponentTeam["contestType"] = contestType
        opponentTeam["isTeamTBA"] = opponentTBA
        opponentTeam["index"] = opponentIndex
        
        let teams = [myTeam, opponentTeam]
        
        parameters["teams"] = teams
        parameters["sportSeasonId"] = ssid
        parameters["dateCode"] = dateCode
        parameters["date"] = dateString

        if (location.count > 0)
        {
            parameters["location"] = location
        }
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(nil, "JSON error", error)
            return
        }
        
        let logOut = String(decoding: postBodyData!, as: UTF8.self)
        print(logOut)

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
                                    completionHandler(data, "", nil)
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, "JSON decode error", compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, "Nil data", error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let message = dictionary["message"] as! String
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, message, error)
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, "JSON decode error", compositeError)
                                }
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, "Unknown error", error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, "Nil response", error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, "Connection error", error)
                }
            }
        }
        
        task.resume()
    }
    
    class func updateSecureContest(myTeamSchoolId: String, opponentSchoolId: String, contestId: String, opponentTBA: Bool, ssid: String, dateString: String, dateCode: Int, myTeamHomeAway: Int, opponentHomeAway: Int, contestType: Int, location: String, myTeamIndex: Int, opponentIndex: Int, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ message: String?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kUpdateSecureContestDev, myTeamSchoolId, ssid, contestId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kUpdateSecureContestDev, myTeamSchoolId, ssid, contestId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kUpdateSecureContestStaging, myTeamSchoolId, ssid, contestId)
        }
        else
        {
            urlString = String(format: kUpdateSecureContestProduction, myTeamSchoolId, ssid, contestId)
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
        urlRequest.addValue("MobileApp", forHTTPHeaderField: "mp-sources-contest-source")
        urlRequest.addValue("MobileAppMaxprepsAppIOS", forHTTPHeaderField: "mp-sources-contest-subsource")
        urlRequest.addValue("ContestUpdate", forHTTPHeaderField: "mp-sources-contest-type")
        urlRequest.addValue("None", forHTTPHeaderField: "mp-sources-contest-subtype")
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        urlRequest.addValue("maxprepsapp_ios", forHTTPHeaderField: "mp-sources-user-source")
                
        /*
        {
            teams:
            [
            {
                teamId          string (myTeam schoolId)
                sportSeasonId   string (ssid)
                isTeamTBA       bool (always 0)
                homeAwayType    int (0,1,2)
                contestType     int (0,1,2)
                index           int (1,2) 1 = home, 2 = away
            },
            {
                teamId          string (opponent schoolId)
                sportSeasonId   string (same as myTeam's ssid)
                isTeamTBA       bool (0 or 1)
                homeAwayType    int (0,1,2) (opposite of myTeam's HAtype)
                contestType     int (0,1,2)
                index           int (1,2)
            }
            ],
            date        string (UTC format)
            dateCode    int (0,1,2,3)
            location    string (optional)
            sportSeasonId    string
        }
        */
        
        var parameters = [:] as Dictionary<String,Any>
        
        //parameters["sportSeasonId"] = ssid (does not change)
        parameters["dateCode"] = dateCode
        parameters["date"] = dateString
        
        if (location.count > 0)
        {
            parameters["location"] = location
        }
        else
        {
            parameters["location"] = NSNull()
        }
        
        // Iterate through the parameters to make a patch array
        var patchArray = [] as! Array<Dictionary<String,Any>>
        
        for item in parameters
        {
            let patchDictionary = ["path": item.key, "value": item.value, "op": "replace"]
            patchArray.append(patchDictionary)
        }
        
        
        // Add the inner team patch items
        
        //myTeam["index"] = myTeamIndex (does not change)
        //myTeam["teamId"] = myTeamSchoolId (does not change)
        //myTeam["sportSeasonId"] = ssid (does not change)
        //myTeam["homeAwayType"] = myTeamHomeAway
        //myTeam["contestType"] = contestType
        //myTeam["isTeamTBA"] = false (does not change)
        
        // Change the indexes to be 1 less for the path values
        let myTeamPathIndex = myTeamIndex - 1
        let opponentPathIndex = opponentIndex - 1
        
        let myTeamHomeAwayKey = String(format: "teams/%d/homeAwayType", myTeamPathIndex)
        patchArray.append(["path": myTeamHomeAwayKey, "value": myTeamHomeAway, "op": "replace"])
        
        let myTeamContestTypeKey = String(format: "teams/%d/contestType", myTeamPathIndex)
        patchArray.append(["path": myTeamContestTypeKey, "value": contestType, "op": "replace"])
        
        //opponentTeam["index"] = opponentIndex (does not change)
        //opponentTeam["teamId"] = opponentSchoolId
        //opponentTeam["sportSeasonId"] = ssid (does not change)
        //opponentTeam["homeAwayType"] = opponentHomeAway
        //opponentTeam["contestType"] = contestType
        //opponentTeam["isTeamTBA"] = opponentTBA
        
        if (opponentTBA == true)
        {
            let opponentSchoolIdKey = String(format: "teams/%d/teamId", opponentPathIndex)
            patchArray.append(["path": opponentSchoolIdKey, "value": NSNull(), "op": "replace"])
        }
        else
        {
            let opponentSchoolIdKey = String(format: "teams/%d/teamId", opponentPathIndex)
            patchArray.append(["path": opponentSchoolIdKey, "value": opponentSchoolId, "op": "replace"])
        }
        
        let opponentHomeAwayKey = String(format: "teams/%d/homeAwayType", opponentPathIndex)
        patchArray.append(["path": opponentHomeAwayKey, "value": opponentHomeAway, "op": "replace"])
        
        let opponentContestTypeKey = String(format: "teams/%d/contestType", opponentPathIndex)
        patchArray.append(["path": opponentContestTypeKey, "value": contestType, "op": "replace"])
        
        let opponentIsTbaKey = String(format: "teams/%d/isTeamTBA", opponentPathIndex)
        patchArray.append(["path": opponentIsTbaKey, "value": opponentTBA, "op": "replace"])
        
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: patchArray, options: [.withoutEscapingSlashes])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(nil, "JSON error", error)
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
                                    completionHandler(data, "", nil)
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, "JSON decode error", compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, "Nil data", error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let message = dictionary["message"] as! String
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, message, error)
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, "JSON decode error", compositeError)
                                }
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil, "Unknown error", error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, "Nil response", error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, "Connection error", error)
                }
            }
        }
        
        task.resume()
    }
    
    class func deleteSecureContest(schoolId: String, ssid: String, contestId: String, completionHandler: @escaping (_ result: Array<Dictionary<String,Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kDeleteSecureContestDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kDeleteSecureContestDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kDeleteSecureContestStaging, schoolId, ssid)
        }
        else
        {
            urlString = String(format: kDeleteSecureContestProduction, schoolId, ssid)
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
        urlRequest.addValue("MobileApp", forHTTPHeaderField: "mp-sources-contest-source")
        urlRequest.addValue("MobileAppMaxprepsAppIOS", forHTTPHeaderField: "mp-sources-contest-subsource")
        urlRequest.addValue("ContestDeletion", forHTTPHeaderField: "mp-sources-contest-type")
        urlRequest.addValue("None", forHTTPHeaderField: "mp-sources-contest-subtype")
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        urlRequest.addValue("maxprepsapp_ios", forHTTPHeaderField: "mp-sources-user-source")
        
        let parameters = [contestId]
        
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
    
    class func restoreSecureContest(schoolId: String, ssid: String, contestId: String, completionHandler: @escaping (_ result: Array<Dictionary<String,Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kRestoreSecureContestDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kRestoreSecureContestDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kRestoreSecureContestStaging, schoolId, ssid)
        }
        else
        {
            urlString = String(format: kRestoreSecureContestProduction, schoolId, ssid)
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
        urlRequest.addValue("MobileApp", forHTTPHeaderField: "mp-sources-contest-source")
        urlRequest.addValue("MobileAppMaxprepsAppIOS", forHTTPHeaderField: "mp-sources-contest-subsource")
        urlRequest.addValue("ContestRestored", forHTTPHeaderField: "mp-sources-contest-type")
        urlRequest.addValue("None", forHTTPHeaderField: "mp-sources-contest-subtype")
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        urlRequest.addValue("maxprepsapp_ios", forHTTPHeaderField: "mp-sources-user-source")
        
        let parameters = [contestId]
        
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
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                                
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
    
    class func copyTeamSchedule(schoolId: String, fromSSID: String, toSSID: String, time: String, completionHandler: @escaping (_ result: Array<Dictionary<String,Any>>?, _ message: String?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kCopyTeamScheduleDev, schoolId, toSSID)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kCopyTeamScheduleDev, schoolId, toSSID)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kCopyTeamScheduleStaging, schoolId, toSSID)
        }
        else
        {
            urlString = String(format: kCopyTeamScheduleProduction, schoolId, toSSID)
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
        urlRequest.addValue("MobileApp", forHTTPHeaderField: "mp-sources-contest-source")
        urlRequest.addValue("MobileAppMaxprepsAppIOS", forHTTPHeaderField: "mp-sources-contest-subsource")
        urlRequest.addValue("ContestAddition", forHTTPHeaderField: "mp-sources-contest-type")
        urlRequest.addValue("None", forHTTPHeaderField: "mp-sources-contest-subtype")
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        urlRequest.addValue("maxprepsapp_ios", forHTTPHeaderField: "mp-sources-user-source")
        
        let parameters = ["fromSportSeasonId": fromSSID, "defaultTime": time]
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(nil, "JSON encode error", error)
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
                                    let data = dictionary["data"] as! Array<Dictionary<String,Any>>
                                    
                                    completionHandler(data, "", nil)
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, "JSON decode error", compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, "Null data", error)
                            }
                        }
                        else
                        {
                            print("Status != 200")
                            
                            if (data != nil)
                            {
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let message = dictionary["message"] as! String
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, message, error)
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, "JSON decode error", compositeError)
                                }
                            }
                            else
                            {
                                let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil, "Unknown error", error)
                            }
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil, "Nil response", error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil, "Connection error", error)
                }
            }
        }
        
        task.resume()
    }
    
    class func getPlayersOfTheGame(schoolId: String, ssid:String, contestId: String, completionHandler: @escaping (_ players: Array<Dictionary<String,Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetPlayersOfTheGameDev, schoolId, ssid, contestId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetPlayersOfTheGameDev, schoolId, ssid, contestId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetPlayersOfTheGameStaging, schoolId, ssid, contestId)
        }
        else
        {
            urlString = String(format: kGetPlayersOfTheGameProduction, schoolId, ssid, contestId)
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
                                    if let players = dictionary["data"] as? Array<Dictionary<String,Any>>
                                    {
                                        completionHandler(players, nil)
                                    }
                                    else
                                    {
                                        print("Data was nil")
                                        let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                        completionHandler(nil, error)
                                    }
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
    
    class func addPlayerOfTheGame(schoolId: String, ssid:String, contestId: String, athleteId: String, type: String, comments: String, completionHandler: @escaping (_ player: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kAddPlayerOfTheGameDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kAddPlayerOfTheGameDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kAddPlayerOfTheGameStaging, schoolId, ssid)
        }
        else
        {
            urlString = String(format: kAddPlayerOfTheGameProduction, schoolId, ssid)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        let parameters = ["teamId": schoolId, "sportSeasonId": ssid, "athleteId": athleteId, "contestId": contestId, "type": type, "comments": comments]
        
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
                                    if let player = dictionary["data"] as? Dictionary<String,Any>
                                    {
                                        completionHandler(player, nil)
                                    }
                                    else
                                    {
                                        print("Data was nil")
                                        let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                        completionHandler(nil, error)
                                    }
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
    
    class func updatePlayerOfTheGame(schoolId: String, ssid:String, pogId: String, contestId: String, athleteId: String, type: String, comments: String, completionHandler: @escaping (_ player: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kUpdatePlayerOfTheGameDev, schoolId, ssid, pogId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kUpdatePlayerOfTheGameDev, schoolId, ssid, pogId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kUpdatePlayerOfTheGameStaging, schoolId, ssid, pogId)
        }
        else
        {
            urlString = String(format: kUpdatePlayerOfTheGameProduction, schoolId, ssid, pogId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "PATCH"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        // These are the only things that can change
        let parameters = ["athleteId": athleteId, "comments": comments]
        
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    if let player = dictionary["data"] as? Dictionary<String,Any>
                                    {
                                        completionHandler(player, nil)
                                    }
                                    else
                                    {
                                        print("Data was nil")
                                        let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                        completionHandler(nil, error)
                                    }
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
    
    class func deletePlayerOfTheGame(schoolId: String, ssid: String, pogId: String, completionHandler: @escaping (_ result: Bool?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kDeletePlayerOfTheGameDev, schoolId, ssid, pogId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kDeletePlayerOfTheGameDev, schoolId, ssid, pogId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kDeletePlayerOfTheGameStaging, schoolId, ssid, pogId)
        }
        else
        {
            urlString = String(format: kDeletePlayerOfTheGameProduction, schoolId, ssid, pogId)
        }
                
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        
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
                            completionHandler(true, nil)
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
