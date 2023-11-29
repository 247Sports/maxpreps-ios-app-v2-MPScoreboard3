//
//  LegacyFeeds.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/10/21.
//

import UIKit

class LegacyFeeds: NSObject
{
    // MARK: - Web Login Feed
    
    class func webLogin(completionHandler: @escaping (_ post: String?, _ error: Error?) -> Void)
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kOldLoginUserWithIdHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kOldLoginUserWithIdHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kOldLoginUserWithIdHostProduction // The staging URL doesn't work
        }
        else
        {
            urlString = kOldLoginUserWithIdHostProduction
        }
        
        // Get the time from 1/1/2001 in integer form
        let sessionId = Date.timeIntervalSinceReferenceDate
        let intSessionId = Int(sessionId)
        
        let urlWithSessionId = urlString + "?sessionId=" + String(sessionId)

        var urlRequest = URLRequest(url: URL(string: urlWithSessionId)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let jsonDict = [kRequestKey : [kUserIdKey : userId as Any, kSessionIdKey : NSNumber(value: intSessionId)]]
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(nil, error)
            return
        }

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
                                
                                completionHandler(logDataReceived, nil)
                                
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
    
    // MARK: - Get Video Info
    
    class func getVideoInfo(videoId: String, completionHandler: @escaping (_ videoObj: Dictionary<String, Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        // Select which URL to use (Video needs to use the prod server because the data is fragmented)
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kGetVideoInfoLegacyHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kGetVideoInfoLegacyHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kGetVideoInfoLegacyHostStaging
        }
        else
        {
            urlString = kGetVideoInfoLegacyHostProduction
        }
       
        let urlWithVideoId = urlString + "?videoid=" + videoId + "&useelasticsearch=1"
        //[NSString stringWithFormat:@"%@?videoid=%@", urlString, videoId];
        
        var urlRequest = URLRequest(url: URL(string: urlWithVideoId)!)
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
                                    
                                    // Check for Failure
                                    if let feedStatus = dictionary["success"] as? Bool
                                    {
                                        if (feedStatus == false)
                                        {
                                            print("Get Video Info Failed")
                                            let errorDictionary = [NSLocalizedDescriptionKey : "Get Video Info Failed"]
                                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                            completionHandler(nil, error)
                                        }
                                        else
                                        {
                                            let result = dictionary
                                            completionHandler(result, nil)
                                        }
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
                                
                                /*
                                 // Returned Data
                                 
                                 
                                 */
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
    
    // MARK: - Get UTC Time
    
    class func getUTCTime( completionHandler: @escaping (_ timeOffset: TimeInterval?, _ error: Error?) -> Void)
    {
        var urlRequest = URLRequest(url: URL(string: kUtcLegacyTimeHostProduction)!)
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
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let timeString = dictionary["utctime"] as? String
                                    let serverTimeFormat = DateFormatter()
                                    serverTimeFormat.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
                                    serverTimeFormat.dateFormat = "MM.dd.yyyy.HH.mm"
                                    
                                    let serverTime = serverTimeFormat.date(from: timeString ?? "")
                                    
                                    // Get the delta time
                                    let deltaTime = serverTime?.timeIntervalSinceNow ?? 0.0
                                    
                                    completionHandler(deltaTime, nil)
                                    
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
    
    // MARK: - User Image Feeds
    
    class func getUserImage(userId: String, completionHandler: @escaping (_ post: Data?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kGetUserImageUrlDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kGetUserImageUrlDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kGetUserImageUrlStaging
        }
        else
        {
            urlString = kGetUserImageUrlProduction
        }
                
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("octet/stream", forHTTPHeaderField: "Content-Type")
        
        // Calculate the DT and HH values using the FeedsHelper
        let dt = FeedsHelper.getDateCode(SharedData.utcTimeOffset)
        let hh = FeedsHelper.getHashCode(withPassword: "-Score$Board#APPS-", andDate: dt)
        
        urlRequest.addValue(dt, forHTTPHeaderField:"DT")
        urlRequest.addValue(hh, forHTTPHeaderField:"HH")
        
        // Set the UserId
        urlRequest.addValue(userId, forHTTPHeaderField:"UserId")
        
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
                                
                                completionHandler(data, nil)
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
    
    // MARK: - PBP Status Feed
    
    class func getPlayByPlayStatus(completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kGetPlayByPlayStatusDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kGetPlayByPlayStatusDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kGetPlayByPlayStatusStaging
        }
        else
        {
            urlString = kGetPlayByPlayStatusProduction
        }
                
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Calculate the DT and HH values using the FeedsHelper
        let dt = FeedsHelper.getDateCode(SharedData.utcTimeOffset)
        let hh = FeedsHelper.getHashCode(withPassword: "-Score$Board#APPS-", andDate: dt)
        
        urlRequest.addValue(dt, forHTTPHeaderField:"DT")
        urlRequest.addValue(hh, forHTTPHeaderField:"HH")
        
        let parameters = ["membershipId": userId]
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
                                    
                                    completionHandler(dictionary, nil)
                                
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
    
    /*
     Successful Response = 200 - 204
     
     "total":1,
     "took":1,
     "timedOut":false,
     "game":
     {
     "Id": "1fd0a47f-869b-4bed-bdd0-0df27a35efce",
     "Date": "2017-07-15T00:09:12.3848038Z",
     "UpdateStamp": "2017-07-14T23:09:12.3848038Z",
     "Duration": 95,
     "ContestState": 2,
     "HasScorer": true,
     "MinsRemainingInGame": 106.81312826,
     "MinsUntilGameTime": -11.813128260000001,
     "Scorers": [
     {
     "MembershipId": "1fd0a47f-869b-4bed-bdd0-0df27a35efce",
     "ScoringUrl": "http://www.maxpreps.com/abcd"
     }
     ]
     }
     */

    /*
     Server Failure Response
     
     Successful:404
     Status:xxxxx
     Message:xxxxx
     */

    /*
     Connection Failure Response
     
     Successful:-1
     Message:xxxxx
     */
}

