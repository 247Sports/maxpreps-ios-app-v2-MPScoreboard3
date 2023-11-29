//
//  NewFeeds.swift
//  MPScoreboard3
//
//  Created by David Smith on 3/18/21.
//

import UIKit
import BranchSDK

class NewFeeds: NSObject
{
    class func getUTCTime( completionHandler: @escaping (_ timeOffset: TimeInterval?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kUtcTimeHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kUtcTimeHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kUtcTimeHostStaging
        }
        else
        {
            urlString = kUtcTimeHostProduction
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
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let timeString = dictionary["data"] as? String
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
    
    // MARK: - Login User Feed
    
    class func loginUser(email: String, password: String, completionHandler: @escaping (_ userInfo: Dictionary<String, Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kLoginUserWithEmailHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kLoginUserWithEmailHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kLoginUserWithEmailHostStaging
        }
        else
        {
            urlString = kLoginUserWithEmailHostProduction
        }
        
        // Get the latest server time. This is required on the validate user API because it is called very early in the startup and the global timeOffset might not be updated yet
        NewFeeds.getUTCTime { (timeOffset, error) in
            if (error == nil)
            {
                SharedData.utcTimeOffset = timeOffset!
                
                var urlRequest = URLRequest(url: URL(string: urlString)!)
                urlRequest.timeoutInterval = 30
                urlRequest.httpMethod = "POST"
                urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                // Calculate the DT and HH values using the FeedsHelper
                let dt = FeedsHelper.getDateCode(timeOffset!)
                let hh = FeedsHelper.getHashCode(withPassword: "-Score$Board#APPS-", andDate: dt)
                
                urlRequest.addValue(dt, forHTTPHeaderField:"DT")
                urlRequest.addValue(hh, forHTTPHeaderField:"HH")
                
                let jsonDict = ["email": email, "password": password]
                
                var postBodyData: Data? = nil
                do {
                    postBodyData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
                    
                    //let logDataReceived = String(decoding: postBodyData!, as: UTF8.self)
                    //print(logDataReceived)
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
                                        //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                        //print(logDataReceived)
                                        
                                        // Decompose the JSON data
                                        var dictionary : Dictionary<String, Any> = [:]
                                          
                                        do {
                                            dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                            
                                            let data = dictionary["data"] as! Dictionary<String, Any>
                                            
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
                                        completionHandler(nil,error)
                                    }
                                }
                                else if (httpResponse.statusCode == 400)
                                {
                                    // Wrong email/password error
                                    print("Status == 400")
                                    
                                    // Decompose the JSON data to get the message
                                    var dictionary : Dictionary<String, Any> = [:]
                                      
                                    do {
                                        dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                        
                                        let message = dictionary["message"] as! String
                                        
                                        let messageDictionary = [NSLocalizedDescriptionKey : message]
                                        let error = NSError.init(domain: kMaxPrepsAppError, code: 400, userInfo: messageDictionary)
                                        completionHandler(nil,error)
                                        
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
                                else if (httpResponse.statusCode == 500)
                                {
                                    // Misc Server login error
                                    print("Status == 500")
                                    
                                    // Decompose the JSON data to get the message
                                    var dictionary : Dictionary<String, Any> = [:]
                                      
                                    do {
                                        dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                        
                                        let message = dictionary["message"] as! String
                                        
                                        let messageDictionary = [NSLocalizedDescriptionKey : message]
                                        let error = NSError.init(domain: kMaxPrepsAppError, code: 500, userInfo: messageDictionary)
                                        completionHandler(nil,error)
                                        
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
                                    print("Status = " + String(httpResponse.statusCode))
                                    
                                    if (data != nil)
                                    {
                                        let logDataReceived = String(decoding: data!, as: UTF8.self)
                                        print(logDataReceived)
                                    }
                                    
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Status = " + String(httpResponse.statusCode)]
                                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil,error)
                                }
                            }
                            else
                            {
                                print("Response was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil,error)
                            }
                        }
                        else
                        {
                            print("Connection Error")
                            let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil,error)
                        }
                    }
                }
                
                task.resume()
            }
            else
            {
                print("UTC Time Error")
                SharedData.utcTimeOffset = 0
                
                if (kUserDefaults.bool(forKey: kDebugDialogsKey) == true)
                {
                    let errorDictionary = [NSLocalizedDescriptionKey : "Get UTC Time Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil,error)
                }
            }
        }
    }
    
    // MARK: - Validate User Feed
    
    class func validateUser(completionHandler: @escaping (_ userInfo: Dictionary<String, Any>?, _ error: Error?) -> Void)
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kValidateUserWithUserIdHostDev, userId!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kValidateUserWithUserIdHostDev, userId!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kValidateUserWithUserIdHostStaging, userId!)
        }
        else
        {
            urlString = String(format: kValidateUserWithUserIdHostProduction, userId!)
        }
        
        // Get the latest server time. This is required on the validate user API because it is called very early in the startup and the global timeOffset might not be updated yet
        NewFeeds.getUTCTime { (timeOffset, error) in
            if (error == nil)
            {
                SharedData.utcTimeOffset = timeOffset!
                
                var urlRequest = URLRequest(url: URL(string: urlString)!)
                urlRequest.timeoutInterval = 30
                urlRequest.httpMethod = "POST"
                urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
                urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                
                // Calculate the DT and HH values using the FeedsHelper
                let dt = FeedsHelper.getDateCode(timeOffset!)
                let hh = FeedsHelper.getHashCode(withPassword: "-Score$Board#APPS-", andDate: dt)
                
                urlRequest.addValue(dt, forHTTPHeaderField:"DT")
                urlRequest.addValue(hh, forHTTPHeaderField:"HH")
                
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
                                            
                                            let data = dictionary["data"] as! Dictionary<String, Any>
                                            
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
                                        completionHandler(nil,error)
                                    }
                                }
                                else if (httpResponse.statusCode == 400)
                                {
                                    // Wrong email/password error
                                    print("Status == 400")
                                    
                                    // Decompose the JSON data to get the message
                                    var dictionary : Dictionary<String, Any> = [:]
                                      
                                    do {
                                        dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                        
                                        let message = dictionary["message"] as! String
                                        
                                        let messageDictionary = [NSLocalizedDescriptionKey : message]
                                        let error = NSError.init(domain: kMaxPrepsAppError, code: 400, userInfo: messageDictionary)
                                        completionHandler(nil,error)
                                        
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
                                else if (httpResponse.statusCode == 500)
                                {
                                    // Misc Server login error
                                    print("Status == 500")
                                    
                                    // Decompose the JSON data to get the message
                                    var dictionary : Dictionary<String, Any> = [:]
                                      
                                    do {
                                        dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                        
                                        let message = dictionary["message"] as! String
                                        
                                        let messageDictionary = [NSLocalizedDescriptionKey : message]
                                        let error = NSError.init(domain: kMaxPrepsAppError, code: 500, userInfo: messageDictionary)
                                        completionHandler(nil,error)
                                        
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
                                    print("Status = " + String(httpResponse.statusCode))
                                    
                                    if (data != nil)
                                    {
                                        let logDataReceived = String(decoding: data!, as: UTF8.self)
                                        print(logDataReceived)
                                    }
                                    
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Status = " + String(httpResponse.statusCode)]
                                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                        completionHandler(nil,error)
                                }
                            }
                            else
                            {
                                print("Response was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(nil,error)
                            }
                        }
                        else
                        {
                            print("Connection Error")
                            let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(nil,error)
                        }
                    }
                }
                
                task.resume()
            }
            else
            {
                print("UTC Time Error")
                SharedData.utcTimeOffset = 0
                
                if (kUserDefaults.bool(forKey: kDebugDialogsKey) == true)
                {
                    let errorDictionary = [NSLocalizedDescriptionKey : "Get UTC Time Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil,error)
                }
            }
        }
    }
    
    // MARK: - Reset Password Feed
    
    class func resetUserPassword(email: String, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        
        // Replace the @ character with %40
        let fixedEmail = email.replacingOccurrences(of: "@", with: "%40")
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kResetPasswordHostDev, fixedEmail)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kResetPasswordHostDev, fixedEmail)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kResetPasswordHostStaging, fixedEmail)
        }
        else
        {
            urlString = String(format: kResetPasswordHostProduction, fixedEmail)
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
                                
                                completionHandler(nil)
                                
                                /*
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let dataString = dictionary["data"] as! String
                                    completionHandler(dataString, nil)
                                    
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(nil, compositeError)
                                }
                                */
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(error)
                            }
                        }
                        else if (httpResponse.statusCode == 400)
                        {
                            // Wrong email error
                            print("Status == 400")
                            
                            let message = "An account with this email could not be found."
                            
                            let messageDictionary = [NSLocalizedDescriptionKey : message]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 400, userInfo: messageDictionary)
                            completionHandler(error)
                            
                            /*
                            // Decompose the JSON data to get the message
                            var dictionary : Dictionary<String, Any> = [:]
                              
                            do {
                                dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                
                                let message = dictionary["message"] as! String
                                
                                let messageDictionary = [NSLocalizedDescriptionKey : message]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 400, userInfo: messageDictionary)
                                completionHandler(error)
                                
                            }
                            catch let error as NSError
                            {
                                print(error)
                                print("Json Error: " + error.localizedDescription)
                                let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(compositeError)
                            }
                            */
                        }
                        else
                        {
                            print("Status != 200 or 400")
                            
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Something went wrong when submitting your request. Please try again."]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
        
    }
    
    // MARK: - Delete User Account Feed
    
    class func deleteUserAccount(completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kDeleteUserAccountHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kDeleteUserAccountHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kDeleteUserAccountHostStaging, userId)
        }
        else
        {
            urlString = String(format: kDeleteUserAccountHostProduction, userId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "DELETE"
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
                            completionHandler(nil)
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
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Validate Account Email Feed
    
    class func validateAccountEmail(email: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kValidateEmailHostDev, email)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kValidateEmailHostDev, email)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kValidateEmailHostStaging, email)
        }
        else
        {
            urlString = String(format: kValidateEmailHostProduction, email)
        }

        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Calculate the DT and HH values using the FeedsHelper
        let dt = FeedsHelper.getDateCode(SharedData.utcTimeOffset)
        let hh = FeedsHelper.getHashCode(withPassword: "-Score$Board#APPS-", andDate: dt)
        
        urlRequest.addValue(dt, forHTTPHeaderField:"DT")
        urlRequest.addValue(hh, forHTTPHeaderField:"HH")
        
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
    
    class func validateZipcode(zipcode: String, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kValidateZipcodeHostDev, zipcode)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kValidateZipcodeHostDev, zipcode)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kValidateZipcodeHostStaging, zipcode)
        }
        else
        {
            urlString = String(format: kValidateZipcodeHostProduction, zipcode)
        }

        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Calculate the DT and HH values using the FeedsHelper
        //let dt = FeedsHelper.getDateCode(SharedData.utcTimeOffset)
        //let hh = FeedsHelper.getHashCode(withPassword: "-Score$Board#APPS-", andDate: dt)
        
        //urlRequest.addValue(dt, forHTTPHeaderField:"DT")
        //urlRequest.addValue(hh, forHTTPHeaderField:"HH")
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { (data, response, connectionError) in
            
            DispatchQueue.main.async
            {
                if (connectionError == nil)
                {
                    if let httpResponse = response as? HTTPURLResponse
                    {
                        print("Response: " + response!.description)
                        
                        // Returns a 500 for unsupported zipcodes
                        if (httpResponse.statusCode == 200)
                        {
                            completionHandler(nil)
                        }
                        else
                        {
                            print("Status != 200")
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
        
    }
    
    // MARK: - Create New User Account Feed
    
    class func createUserAccount(email: String, password: String, firstName: String, lastName: String, birthdate: String, genderAlias: String, zipcode: String, role: String, allowMessaging: Bool, allowPartner: Bool, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        var allowMessagingString = "false"
        var allowPartnerString = "false"
        
        if (allowMessaging == true)
        {
            allowMessagingString = "true"
        }
        
        if (allowPartner == true)
        {
            allowPartnerString = "true"
        }
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kCreateUserAccountHostDev, allowMessagingString, allowPartnerString)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kCreateUserAccountHostDev, allowMessagingString, allowPartnerString)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kCreateUserAccountHostStaging, allowMessagingString, allowPartnerString)
        }
        else
        {
            urlString = String(format: kCreateUserAccountHostProduction, allowMessagingString, allowPartnerString)
        }
   
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Calculate the DT and HH values using the FeedsHelper
        print("Local Time Offset: " + String(SharedData.utcTimeOffset))
        let dt = FeedsHelper.getDateCode(SharedData.utcTimeOffset)
        let hh = FeedsHelper.getHashCode(withPassword: "-Score$Board#APPS-", andDate: dt)
        
        urlRequest.addValue(dt, forHTTPHeaderField:"DT")
        urlRequest.addValue(hh, forHTTPHeaderField:"HH")
        
        // Build the POST body
        var parameters = [:] as Dictionary<String,Any>
        
        parameters["email"] = email
        parameters["password"] = password
        parameters["firstName"] = firstName
        parameters["lastName"] = lastName
        parameters["gender"] = genderAlias
        parameters["zipCode"] = zipcode
        parameters["type"] = role
        parameters["userSource"] = "maxprepsapp_ios"
        
        // Only set the "bornOn" property if the birthdate is not "xxxx"
        if (birthdate != "")
        {
            parameters["bornOn"] = birthdate
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
    
    // MARK: - Update User Info Feeds
    
    class func updateUserEmail(currentEmail: String, newEmail: String, password: String, completionHandler: @escaping (_ statusCode: Int?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kUpdateUserEmailHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kUpdateUserEmailHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kUpdateUserEmailHostStaging
        }
        else
        {
            urlString = kUpdateUserEmailHostProduction
        }
   
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
        // Build the POST body
        var parameters = [:] as Dictionary<String,Any>
        
        parameters["currentEmail"] = currentEmail
        parameters["newEmail"] = newEmail
        parameters["password"] = password
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(0, error)
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
                        
                        if (data != nil)
                        {
                            let logDataReceived = String(decoding: data!, as: UTF8.self)
                            print(logDataReceived)
                        }
                        completionHandler(httpResponse.statusCode, nil)
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(0, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(0, error)
                }
            }
        }
        
        task.resume()

    }
    
    class func updateUserPassword(oldPassword: String, newPassword: String, confirmPassword: String, completionHandler: @escaping (_ statusCode: Int?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kUpdateUserPasswordHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kUpdateUserPasswordHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kUpdateUserPasswordHostStaging
        }
        else
        {
            urlString = kUpdateUserPasswordHostProduction
        }
   
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
        // Build the POST body
        var parameters = [:] as Dictionary<String,Any>
        
        parameters["userId"] = userId
        parameters["currentPassword"] = oldPassword
        parameters["newPassword"] = newPassword
        parameters["confirmPassword"] = confirmPassword
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(0, error)
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
                        completionHandler(httpResponse.statusCode, nil)
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(0, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(0, error)
                }
            }
        }
        
        task.resume()

    }
    
    class func updateUserInfo(firstName: String, lastName: String, birthdate: String, gender: String, zipcode: String, userType: String, completionHandler: @escaping (_ statusCode: Int?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kUpdateUserAccountHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kUpdateUserAccountHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kUpdateUserAccountHostStaging, userId)
        }
        else
        {
            urlString = String(format: kUpdateUserAccountHostProduction, userId)
        }
   
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "PATCH"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
        var parameters = [:] as Dictionary<String,Any>
        
        if (firstName.count > 0)
        {
            parameters["FirstName"] = firstName
        }
        
        if (lastName.count > 0)
        {
            parameters["LastName"] = lastName
        }
        
        if (zipcode.count > 0)
        {
            parameters["ZipCode"] = zipcode
        }
        
        if (userType.count > 0)
        {
            parameters["Type"] = userType
        }
        
        if (birthdate.count > 0)
        {
            parameters["BornOn"] = birthdate
        }
        
        if (gender.count > 0)
        {
            parameters["Gender"] = gender
        }
        
        // Iterate through the parameters to make a patch array
        var patchArray: Array<Dictionary<String,Any>> = []
        
        for item in parameters
        {
            let patchDictionary = ["path": item.key, "value": item.value, "op": "replace"]
            patchArray.append(patchDictionary)
        }
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: patchArray, options: [.withoutEscapingSlashes])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(0, error)
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
                        /*
                        if (data != nil)
                        {
                            let logDataReceived = String(decoding: data!, as: UTF8.self)
                            print(logDataReceived)
                        }
                        */
                        completionHandler(httpResponse.statusCode, nil)
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(0, error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(0, error)
                }
            }
        }
        
        task.resume()

    }
    
    // MARK: - Get User Subscriptions
    
    class func getUserEligibleSubscriptionCategories(completionHandler: @escaping (_ categories: Array<Dictionary<String, Any>>?, _ error: Error?) -> Void)
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetUserEligibleSubscriptionCategoriesHostDev, userId!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetUserEligibleSubscriptionCategoriesHostDev, userId!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetUserEligibleSubscriptionCategoriesHostStaging, userId!)
        }
        else
        {
            urlString = String(format: kGetUserEligibleSubscriptionCategoriesHostProduction, userId!)
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
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let categories = dictionary["data"] as! Array<Dictionary<String, Any>>
                                    completionHandler(categories, nil)
                                    
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
    
    class func getUserSubscriptionTopics(completionHandler: @escaping (_ topics: Array<Dictionary<String, Any>>?, _ error: Error?) -> Void)
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetUserSubscriptionTopicsHostDev, userId!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetUserSubscriptionTopicsHostDev, userId!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetUserSubscriptionTopicsHostStaging, userId!)
        }
        else
        {
            urlString = String(format: kGetUserSubscriptionTopicsHostProduction, userId!)
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
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let topics = dictionary["data"] as! Array<Dictionary<String, Any>>
                                    completionHandler(topics, nil)
                                    
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
    
    class func updateUserSubscription(topicId: String, enabled: Bool, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        var urlString : String
        
        if (enabled == true)
        {
            if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
            {
                urlString = String(format: kCreateUserSubscriptionHostDev, userId!)
            }
            else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
            {
                urlString = String(format: kCreateUserSubscriptionHostDev, userId!)
            }
            else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
            {
                urlString = String(format: kCreateUserSubscriptionHostStaging, userId!)
            }
            else
            {
                urlString = String(format: kCreateUserSubscriptionHostProduction, userId!)
            }
        }
        else
        {
            if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
            {
                urlString = String(format: kDeleteUserSubscriptionHostDev, userId!)
            }
            else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
            {
                urlString = String(format: kDeleteUserSubscriptionHostDev, userId!)
            }
            else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
            {
                urlString = String(format: kDeleteUserSubscriptionHostStaging, userId!)
            }
            else
            {
                urlString = String(format: kDeleteUserSubscriptionHostProduction, userId!)
            }
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId!)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        // Build the header dictionary for Exact Target Emails
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
        let jsonDict = [topicId]
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(error)
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                completionHandler(nil)
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(error)
                            }
                            
                        }
                        else
                        {
                            print("Status != 200")
                            /*
                            if (data != nil)
                            {
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                            }
                            */
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - User Special Offers
    
    class func getUserSpecialOffers(completionHandler: @escaping (_ offers: Array<Dictionary<String, Any>>?, _ error: Error?) -> Void)
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetUserSpecialOffersHostDev, userId!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetUserSpecialOffersHostDev, userId!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetUserSpecialOffersHostStaging, userId!)
        }
        else
        {
            urlString = String(format: kGetUserSpecialOffersHostProduction, userId!)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId!)
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
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let offers = dictionary["data"] as! Array<Dictionary<String, Any>>
                                    completionHandler(offers, nil)
                                    
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
    
    class func updateUserSpecialOfferType(_ type: Int, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kUpdateUserSpecialOffersHostDev, userId, type)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kUpdateUserSpecialOffersHostDev, userId, type)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kUpdateUserSpecialOffersHostStaging, userId, type)
        }
        else
        {
            urlString = String(format: kUpdateUserSpecialOffersHostProduction, userId, type)
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
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
        /*
         POST data:
         {
             "careerProfileId": "597a0efd-7622-4291-88a9-ef72bf99cdc2",
             "userId": "74c1621c-e0cf-4821-b5e1-3c8170c8125a",
         }
         */
        
        //let jsonDict = ["careerProfileId": careerProfileId, "userId": userId]
        
        // Post an empty array
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: [], options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(error)
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
                            completionHandler(nil)
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
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    class func submitNCSAType(_ type: Int, postDataArray: Array<Dictionary<String,Any>>, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kUpdateUserSpecialOffersHostDev, userId, type)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kUpdateUserSpecialOffersHostDev, userId, type)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kUpdateUserSpecialOffersHostStaging, userId, type)
        }
        else
        {
            urlString = String(format: kUpdateUserSpecialOffersHostProduction, userId, type)
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
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: postDataArray, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(error)
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
                            completionHandler(nil)
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
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - User Favorite Teams Feeds
    
    class func getUserFavoriteTeams(completionHandler: @escaping (_ error: Error?) -> Void)
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kNewGetUserFavoriteTeamsHostDev, userId!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kNewGetUserFavoriteTeamsHostDev, userId!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kNewGetUserFavoriteTeamsHostStaging, userId!)
        }
        else
        {
            urlString = String(format: kNewGetUserFavoriteTeamsHostProduction, userId!)
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
                                    
                                    // Old API
                                    /*
                                    let data = dictionary["data"] as! Dictionary<String, Any>
                                    
                                    let favorites = data["teams"] as! Array<Dictionary<String, Any>>
                                    */
                                    // New API
                                    let favorites = dictionary["data"] as! Array<Dictionary<String, Any>>
                                    
                                    if (favorites.count > 0)
                                    {
                                        // Sort the teams as Admin first, Member second, and the rest last
                                        var admins = [] as! Array<Dictionary<String,Any>>
                                        var members = [] as! Array<Dictionary<String,Any>>
                                        var followers = [] as! Array<Dictionary<String,Any>>
                                        
                                        for favorite in favorites
                                        {
                                            let schoolId = favorite[kNewSchoolIdKey] as! String
                                            let allSeasonId = favorite[kNewAllSeasonIdKey] as! String
                                            
                                            // Look at the roles dictionary for a match
                                            let adminRoles = kUserDefaults.dictionary(forKey: kUserAdminRolesDictionaryKey)
                                            let roleKey = schoolId + "_" + allSeasonId
                                            
                                            if (adminRoles != nil) && (adminRoles![roleKey] != nil)
                                            {
                                                let adminRole = adminRoles![roleKey] as! Dictionary<String,Any>
                                                let roleName = adminRole[kRoleNameKey] as! String
                                                
                                                if ((roleName == "Head Coach") || (roleName == "Assistant Coach") || (roleName == "Statistician"))
                                                {
                                                    admins.append(favorite )
                                                }
                                                else if (roleName == "Team Community")
                                                {
                                                    members.append(favorite)
                                                }
                                            }
                                            else
                                            {
                                                followers.append(favorite)
                                            }
                                        }
                                        
                                        var sortedFavorites = [] as! Array<Dictionary<String,Any>>
                                        
                                        for item in admins
                                        {
                                            sortedFavorites.append(item)
                                        }
                                        
                                        for item in members
                                        {
                                            sortedFavorites.append(item)
                                        }
                                        
                                        for item in followers
                                        {
                                            sortedFavorites.append(item)
                                        }
                                        
                                        
                                        // Update the prefs
                                        kUserDefaults.setValue(sortedFavorites, forKey: kNewUserFavoriteTeamsArrayKey)
                                    }
                                    else
                                    {
                                        // Create an empty favorites array to save to prefs
                                        let emptyFavs = [] as Array<Any>
                                        kUserDefaults.setValue(emptyFavs, forKey: kNewUserFavoriteTeamsArrayKey)
                                        //kUserDefaults.removeObject(forKey: kNewUserFavoriteTeamsArrayKey)
                                    }
                                    
                                    // Load the notifications after a little delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
                                    {
                                        NotificationManager.loadAirshipNotifications()
                                    }
                                    
                                    // Finish the call
                                    completionHandler(nil)
                                    
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(error)
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
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    class func deleteUserFavoriteTeam(favorite: Dictionary<String, Any>, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        let teamIdNumber = favorite[kNewUserfavoriteTeamIdKey] as! Int
        let teamId = String(teamIdNumber)
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kNewDeleteUserFavoriteTeamHostDev, userId, teamId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kNewDeleteUserFavoriteTeamHostDev, userId, teamId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kNewDeleteUserFavoriteTeamHostStaging, userId, teamId)
        }
        else
        {
            urlString = String(format: kNewDeleteUserFavoriteTeamHostProduction, userId, teamId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "DELETE"
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
                            completionHandler(nil)
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
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    class func saveUserFavoriteTeam(_ favorite: Dictionary<String,Any>, completionHandler: @escaping (_ items: Array<Dictionary<String,Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kNewSaveUserFavoriteTeamHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kNewSaveUserFavoriteTeamHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kNewSaveUserFavoriteTeamHostStaging, userId)
        }
        else
        {
            urlString = String(format: kNewSaveUserFavoriteTeamHostProduction, userId)
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
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
        /*
         POST data:
         {
             "userId": "597a0efd-7622-4291-88a9-ef72bf99cdc2",
             "schoolId": "74c1621c-e0cf-4821-b5e1-3c8170c8125a",
             "allSeasonId": "A42C7EA4-0907-491E-B56F-A2D31A45BF19",
             "seasonName": "Winter",
             "source": "MaxprepsApp_IOS"
         }
         */
        
        let schoolId = favorite[kNewSchoolIdKey]
        let allSeasonId = favorite[kNewAllSeasonIdKey]
        let season = favorite[kNewSeasonKey]
        
        let jsonDict = [kNewSchoolIdKey: schoolId, kNewAllSeasonIdKey: allSeasonId, "userId": userId, "seasonName": season, "source": "MaxprepsApp_IOS"]
        
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
                                let logDataReceived = String(decoding: data!, as: UTF8.self)
                                print(logDataReceived)
                                // userFavoriteTeamRefId
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                  
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    let items = dictionary["data"] as! Array<Dictionary<String, Any>>
                                    
                                    // Call Branch event tracking
                                    let userType = kUserDefaults.string(forKey: kUserTypeKey)!
                                    let event = BranchEvent.customEvent(withName:"FOLLOW_TEAM")
                                    event.customData["userId"] = userId
                                    event.customData["userRole"] = userType
                                    event.alias = "FOLLOW TEAM"
                                    event.logEvent()
                                    
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
                                completionHandler(nil,error)
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
    
    class func updateTeamNotificationSetting(_ settingId: Int, switchValue: Bool, isEmail: Bool, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let settingId = String(settingId)
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kNewUpdateUserFavoriteTeamNotificationHostDev, settingId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kNewUpdateUserFavoriteTeamNotificationHostDev, settingId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kNewUpdateUserFavoriteTeamNotificationHostStaging, settingId)
        }
        else
        {
            urlString = String(format: kNewUpdateUserFavoriteTeamNotificationHostProduction, settingId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "PATCH"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        //urlRequest.addValue("application/json-patch+json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        /*
         PATCH data:
         {
             "value": true,
             "path": "IsEnabledForApp" or "IsEnabledForEmail",
             "op": "Replace",
         }
         */
        var path = "isEnabledForApp"
        if (isEmail == true)
        {
            path = "isEnabledForEmail"
        }
        let jsonDict = ["value": switchValue, "path": path, "op": "replace"] as [String : Any]
        let jsonArray = [jsonDict]
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
            
            let logDataReceived = String(decoding: postBodyData!, as: UTF8.self)
            print(logDataReceived)
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(error)
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
                            completionHandler(nil)
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
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - User Favorite Athletes Feeds
    
    class func getUserFavoriteAthletes(completionHandler: @escaping (_ error: Error?) -> Void)
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetUserFavoriteAthletesHostDev, userId!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetUserFavoriteAthletesHostDev, userId!)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetUserFavoriteAthletesHostStaging, userId!)
        }
        else
        {
            urlString = String(format: kGetUserFavoriteAthletesHostProduction, userId!)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token no longer needed with the new gateway API
        //let encryptedUserId = FeedsHelper.encryptString(userId!)
        //urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
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
                                    
                                    if (dictionary["data"] is NSNull)
                                    {
                                        let errorDictionary = [NSLocalizedDescriptionKey : "Data was null"]
                                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                        completionHandler(error)
                                        return
                                    }
                                    
                                    let athletes = dictionary["data"] as! Array<Dictionary<String,Any>>
        
                                    if (athletes.count > 0)
                                    {
                                        /*
                                        New notifications object
                                         "notificationSettings": [
                                                 {
                                                   "userId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                                                   "careerId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
                                                   "shortName": 0,
                                                   "name": "string",
                                                   "sortOrder": 0,
                                                   "isEnabledForApp": true,
                                                   "isEnabledForEmail": true,
                                                   "isEnabledForSms": true,
                                                   "isEnabledForWeb": true
                                                 }
                                               ]
                                        */
                                        
                                        // Look for a NULL schoolId and fix it
                                        var fixedAthletes : Array<Dictionary<String,Any>> = []
                                        
                                        for athlete in athletes
                                        {
                                            let allKeys = athlete.keys
                                            var replacementAthlete = [:] as Dictionary<String,Any>
                                            
                                            for key in allKeys
                                            {
                                                if (key == "schoolId")
                                                {
                                                    let fixedSchoolId = athlete["schoolId"] as? String ?? ""
                                                    replacementAthlete["schoolId"] = fixedSchoolId
                                                }
                                                else
                                                {
                                                    let value = athlete[key]
                                                    replacementAthlete[key] = value
                                                }
                                            }
                                            
                                            fixedAthletes.append(replacementAthlete)
                                        }
                                        
                                        // Update the prefs
                                        kUserDefaults.setValue(fixedAthletes, forKey: kUserFavoriteAthletesArrayKey)
                                    }
                                    else
                                    {
                                        // Create an empty favorites array to save to prefs
                                        let emptyFavs = [] as Array<Any>
                                        kUserDefaults.setValue(emptyFavs, forKey: kUserFavoriteAthletesArrayKey)
                                    }
                                    
                                    /*
                                    // This is handled in the getFavoriteTeams API since they are almost always called together
                                    // Load the notifications after a little delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0)
                                    {
                                        NotificationManager.loadAirshipNotifications()
                                    }
                                    */
                                    // Finish the call
                                    completionHandler(nil)
                
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(compositeError)
                                }
                                
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(error)
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
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    class func saveUserFavoriteAthlete(_ careerProfileId: String, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kAddUserFavoriteAthleteHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kAddUserFavoriteAthleteHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kAddUserFavoriteAthleteHostStaging, userId)
        }
        else
        {
            urlString = String(format: kAddUserFavoriteAthleteHostProduction, userId)
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
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
        /*
         POST data:
         {
             "careerProfileId": "597a0efd-7622-4291-88a9-ef72bf99cdc2",
             "userId": "74c1621c-e0cf-4821-b5e1-3c8170c8125a",
         }
         */
        
        let jsonDict = ["careerProfileId": careerProfileId, "userId": userId]
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(error)
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
                            // Call Branch event tracking
                            let userType = kUserDefaults.string(forKey: kUserTypeKey)!
                            let event = BranchEvent.customEvent(withName:"FOLLOW_ATHLETE")
                            event.customData["userId"] = userId
                            event.customData["userRole"] = userType
                            event.alias = "FOLLOW ATHLETE"
                            event.logEvent()
                            
                            completionHandler(nil)
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
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    class func deleteUserFavoriteAthlete(_ careerProfileId: String, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kDeleteUserFavoriteAthleteHostDev, userId, careerProfileId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kDeleteUserFavoriteAthleteHostDev, userId, careerProfileId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kDeleteUserFavoriteAthleteHostStaging, userId, careerProfileId)
        }
        else
        {
            urlString = String(format: kDeleteUserFavoriteAthleteHostProduction, userId, careerProfileId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "DELETE"
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
                            completionHandler(nil)
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
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    class func updateCareerNotificationSetting(careerId: String, switchValue: Bool, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kUpdateUserFavoriteAthleteNotificationHostDev, userId, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kUpdateUserFavoriteAthleteNotificationHostDev, userId, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kUpdateUserFavoriteAthleteNotificationHostStaging, userId, careerId)
        }
        else
        {
            urlString = String(format: kUpdateUserFavoriteAthleteNotificationHostProduction, userId, careerId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "PATCH"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        //urlRequest.addValue("application/json-patch+json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        /*
         PATCH data:
         {
             "value": true,
             "path": "IsEnabledForApp",
             "op": "Replace",
         }
         */

        let jsonDict = ["value": switchValue, "path": "isEnabledForApp", "op": "replace"] as [String : Any]
        let jsonArray = [jsonDict]
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
            
            let logDataReceived = String(decoding: postBodyData!, as: UTF8.self)
            print(logDataReceived)
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(error)
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
                            completionHandler(nil)
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
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Get School Info for School Ids
    
    class func getSchoolInfoForSchoolIds(_ schoolIdArray: Array<String>, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kNewGetInfoForSchoolsHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kNewGetInfoForSchoolsHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kNewGetInfoForSchoolsHostStaging
        }
        else
        {
            urlString = kNewGetInfoForSchoolsHostProduction
        }

        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: schoolIdArray, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(error)
            return
        }

        let logDataReceived = String(decoding: postBodyData!, as: UTF8.self)
        print(logDataReceived)

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
                                    
                                    let schoolInfos = dictionary["data"] as! Array<Any>
                                            
                                    if (schoolInfos.count > 0)
                                    {
                                        var schoolInfo : Dictionary<String, Any> = [:]
                                                
                                        for info in schoolInfos
                                        {
                                            let item = info as! Dictionary<String, Any>
                                            let schoolId = item[kNewSchoolInfoSchoolIdKey] as! String
                                            let mascotUrl = item[kNewSchoolInfoMascotUrlKey] as! String
                                            let schoolColor = item[kNewSchoolInfoColor1Key] as? String ?? "808080"
                                            let schoolName = item[kNewSchoolInfoNameKey] as! String
                                            let schoolFullName = item[kNewSchoolInfoFullNameKey] as! String
                                            
                                            let schoolData = [kNewSchoolInfoSchoolIdKey:schoolId, kNewSchoolInfoMascotUrlKey:mascotUrl, kNewSchoolInfoColor1Key:schoolColor, kNewSchoolInfoNameKey:schoolName, kNewSchoolInfoFullNameKey:schoolFullName]
                                                    
                                            schoolInfo.updateValue(schoolData, forKey: schoolId)
                                        }
                                                
                                        // Update prefs with the data
                                        kUserDefaults.setValue(schoolInfo, forKey: kNewSchoolInfoDictionaryKey)
                                    }
                                    else
                                    {
                                        kUserDefaults.removeObject(forKey: kNewSchoolInfoDictionaryKey)
                                    }
                                            
                                    completionHandler(nil)
                                }
                                catch let error as NSError
                                {
                                    print(error)
                                    print("Json Error: " + error.localizedDescription)
                                    let errorDictionary = [NSLocalizedDescriptionKey : "Json Decode Error: " + error.localizedDescription]
                                    let compositeError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                    completionHandler(compositeError)
                                }
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(error)
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
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Get Available Teams
    
    class func getAvailableTeamsForSchool(schoolId: String, completionHandler: @escaping (_ availableTeams: Dictionary<String, Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kNewGetTeamsForSchoolHostDev, schoolId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kNewGetTeamsForSchoolHostDev, schoolId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kNewGetTeamsForSchoolHostStaging, schoolId)
        }
        else
        {
            urlString = String(format: kNewGetTeamsForSchoolHostProduction, schoolId)
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
                                    
                                    let availableTeams = dictionary["data"] as! Dictionary<String, Any>
                                    completionHandler(availableTeams, nil)
                                    
                                    /*
                                      {
                                      "teamId": "cbd85b5c-91e4-46cf-9849-b1cd0b78972c",
                                      "sportSeasonId": "b2e164af-cc17-44b1-a3f3-c4798695f001",
                                      "hasTeamRoster": false,
                                      "hasContests": true,
                                      "hasLeagueStandings": false,
                                      "hasStats": false,
                                      "hasRankings": false,
                                      "hasVideos": false,
                                      "hasProPhotos": true,
                                      "hasArticles": false,
                                      "isPrepsSportsEnabled": false,
                                      "updatedOn": "2020-12-10T22:16:38.1823174Z"
                                      }
                                     */
                                
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
    
    // MARK: - Get SSID's for Team
    
    class func getSSIDsForTeam(_ allSeasonId: String, schoolId: String, completionHandler: @escaping (_ availableItems: Array<Dictionary<String, Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetSSIDsForTeamHostDev, schoolId, allSeasonId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetSSIDsForTeamHostDev, schoolId, allSeasonId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetSSIDsForTeamHostStaging, schoolId, allSeasonId)
        }
        else
        {
            urlString = String(format: kGetSSIDsForTeamHostProduction, schoolId, allSeasonId)
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
                                    
                                    let items = dictionary["data"] as! Array<Dictionary<String, Any>>
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
    
    // MARK: - Get Team Record
    
    class func getTeamRecord(_ teamId: String, schoolId: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetTeamRecordHostDev, schoolId, teamId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetTeamRecordHostDev, schoolId, teamId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetTeamRecordHostStaging, schoolId, teamId)
        }
        else
        {
            urlString = String(format: kGetTeamRecordHostProduction, schoolId, teamId)
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
    
    // MARK: - Get Available Item for Team
    
    class func getAvailableItemsForTeam(_ ssid: String, schoolId: String, completionHandler: @escaping (_ availableItems: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetTeamAvailabilityHostDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetTeamAvailabilityHostDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetTeamAvailabilityHostStaging, schoolId, ssid)
        }
        else
        {
            urlString = String(format: kGetTeamAvailabilityHostProduction, schoolId, ssid)
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
    
    // MARK: - Get Bitly URL Feed
    
    class func getBitlyUrl(_ urlString: String, completionHandler: @escaping (_ dictionary: Dictionary<String, Any>?, _ error: Error?) -> Void)
    {
        var bitlyUrlString : String
        
        // Replace the URL Host unfriendly characters
        let hostSet = NSCharacterSet.urlHostAllowed
        var fixedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: hostSet as CharacterSet)!
        
        // Replace any & with %26
        fixedUrlString = fixedUrlString.replacingOccurrences(of: "&", with: "%26")
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            bitlyUrlString = String(format: kBitlyUrlConverterHostDev, fixedUrlString)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            bitlyUrlString = String(format: kBitlyUrlConverterHostDev, fixedUrlString)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            bitlyUrlString = String(format: kBitlyUrlConverterHostStaging, fixedUrlString)
        }
        else
        {
            bitlyUrlString = String(format: kBitlyUrlConverterHostProduction, fixedUrlString)
        }

        var urlRequest = URLRequest(url: URL(string: bitlyUrlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
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
    
    // MARK: - Get Video Info
    
    class func getVideoInfo(videoId: String, completionHandler: @escaping (_ videoInfo: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetVideoInfoDev, videoId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetVideoInfoDev, videoId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetVideoInfoStaging, videoId)
        }
        else
        {
            urlString = String(format: kGetVideoInfoProduction, videoId)
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
    
    class func getContestVideos(contestId: String, count: Int, completionHandler: @escaping (_ videos: Array<Dictionary<String,Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        var fixedContestId = ""
        
        if (contestId == "")
        {
            fixedContestId = kEmptyGuid
        }
        else
        {
            fixedContestId = contestId
        }
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetContestVideosDev, count, fixedContestId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetContestVideosDev, count, fixedContestId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetContestVideosStaging, count, fixedContestId)
        }
        else
        {
            urlString = String(format: kGetContestVideosProduction, count, fixedContestId)
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
                                    
                                    let videos = dictionary["data"] as! Array<Dictionary<String, Any>>
                                    completionHandler(videos, nil)
                                
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
    
    // MARK: - Get Team Detail Card Feed
    
    class func getDetailCardDataForTeams(_ teams: Array<Dictionary<String,Any>>, completionHandler: @escaping (_ results: Array<Dictionary<String, Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kGetTeamDetailCardHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kGetTeamDetailCardHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kGetTeamDetailCardHostStaging
        }
        else
        {
            urlString = kGetTeamDetailCardHostProduction
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: teams, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let jsonError = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(nil,jsonError)
            return
        }

        let logDataReceived = String(decoding: postBodyData!, as: UTF8.self)
        print(logDataReceived)

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
                                    
                                    let results = dictionary["data"] as! Array<Dictionary<String,Any>>
                                            
                                    completionHandler(results, nil)
                                    
                                    /*
                                     {
                                         "status": 200,
                                         "message": "Success",
                                         "cacheResult": "Unknown",
                                         "data": [
                                             {
                                                 "teamId": "d9622df1-9a90-49e7-b219-d6c380c566fe",
                                                 "allSeasonId": "22e2b335-334e-4d4d-9f67-a0f716bb1ccd",
                                                 "cardItems": [
                                                     {
                                                         "record": {
                                                             "overallStanding": {
                                                                 "winningPercentage": 0.000,
                                                                 "overallWinLossTies": "0-0",
                                                                 "homeWinLossTies": "0-0",
                                                                 "awayWinLossTies": "0-0",
                                                                 "neutralWinLossTies": "0-0",
                                                                 "points": 0,
                                                                 "pointsAgainst": 0,
                                                                 "streak": 0,
                                                                 "streakResult": "0"
                                                             },
                                                             "leagueStanding": {
                                                                 "leagueName": "Foothill Valley",
                                                                 "canonicalUrl": "https://z.maxpreps.com/league/vIKP_ANcBEeRvG9E5Ztn4Q/standings-foothill-valley.htm",
                                                                 "conferenceWinningPercentage": 0.000,
                                                                 "conferenceWinLossTies": "0-0",
                                                                 "conferenceStandingPlacement": "1st"
                                                             }
                                                         }
                                                     },
                                                     {
                                                         "schedules": [
                                                             {
                                                                 "hasResult": false,
                                                                 "resultString": "",
                                                                 "dateString": "3/19",
                                                                 "timeString": "7:00 PM",
                                                                 "opponentMascotUrl": "https://d1yf833igi2o06.cloudfront.net/fit-in/1024x1024/school-mascot/6/1/5/61563c75-3efb-427f-8329-767978b469df.gif?version=636520747200000000",
                                                                 "opponentName": "Rio Linda",
                                                                 "opponentNameAcronym": "RLHS",
                                                                 "opponentUrl": "https://dev.maxpreps.com/high-schools/rio-linda-knights-(rio-linda,ca)/football/home.htm",
                                                    "opponentColor1": "000080",
                                                                 "homeAwayType": "Home",
                                                                 "contestIsLive": false,
                                                                 "canonicalUrl": "https://dev.maxpreps.com/games/3-19-21/football-fall-20/ponderosa-vs-rio-linda.htm?c=OIRYlXxgWEaHfK7OipEITQ"
                                                             },
                                                             {
                                                                 "hasResult": false,
                                                                 "resultString": "",
                                                                 "dateString": "3/25",
                                                                 "timeString": "12:00 PM",
                                                                 "opponentMascotUrl": "https://d1yf833igi2o06.cloudfront.net/fit-in/1024x1024/school-mascot/6/1/5/61563c75-3efb-427f-8329-767978b469df.gif?version=636520747200000000",
                                                                 "opponentName": "Rio Linda",
                                                                 "opponentNameAcronym": "RLHS",
                                                                 "opponentUrl": "https://dev.maxpreps.com/high-schools/rio-linda-knights-(rio-linda,ca)/football/home.htm",
                                                    "opponentColor1": "000080",
                                                                 "homeAwayType": "Neutral",
                                                                 "contestIsLive": false,
                                                                 "canonicalUrl": "https://dev.maxpreps.com/games/3-25-21/football-fall-20/ponderosa-vs-rio-linda.htm?c=ZLpSnJTDFUSEscaGO3BsYQ"
                                                             }
                                                         ]
                                                     },
                                                     {
                                                         "latestItems": [
                                                             {
                                                                 "type": "Article",
                                                                 "title": "State officials, CIF, coaches meet",
                                                                 "text": "Dr. Mark Ghaly enters discussion; California coaches group calls meeting 'cooperative,  positive, and open,' but student-athletes are running out of time. ",
                                                                 "thumbnailUrl": "https://images.maxpreps.com/editorial/article/c/b/8/cb8ee48f-fe58-44dc-baec-f00d7ccf7692/3a4ed84d-c366-eb11-80ce-a444a33a3a97_original.jpg?version=637481180400000000",
                                                                 "thumbnailWidth": null,
                                                                 "thumbnailHeight": null,
                                                                 "canonicalUrl": "https://dev.maxpreps.com/news/j-SOy1j-3ES67PANfM92kg/california-high-school-sports--state-officials,-cif,-coaches-find-common-ground,-talks-to-resume-next-week.htm"
                                                             },
                                                             {
                                                                 "type": "Article",
                                                                 "title": "New hope for California sports",
                                                                 "text": "Teams slotted in purple tier now allowed to compete; four Sac-Joaquin Section cross country teams ran in Monday meet.",
                                                                 "thumbnailUrl": "https://images.maxpreps.com/editorial/article/5/0/7/507b80b1-d75a-4909-b52c-474eef259269/e618f53f-745f-eb11-80ce-a444a33a3a97_original.jpg?version=637471932600000000",
                                                                 "thumbnailWidth": null,
                                                                 "thumbnailHeight": null,
                                                                 "canonicalUrl": "https://dev.maxpreps.com/news/sYB7UFrXCUm1LEdO7yWSaQ/new-hope-for-california-high-school-sports-after-stay-home-orders-lifted.htm"
                                                             },
                                                             {
                                                                 "type": "Article",
                                                                 "title": "SJS releases new play for Season 1 in 2021",
                                                                 "text": "State's second-largest section will forego traditional postseason to allow schools chance to participate in more games. ",
                                                                 "thumbnailUrl": "https://images.maxpreps.com/editorial/article/d/2/9/d298908e-0c1c-46aa-861c-96e4fa76ffad/07b358d0-8941-eb11-80ce-a444a33a3a97_original.jpg?version=637439061000000000",
                                                                 "thumbnailWidth": null,
                                                                 "thumbnailHeight": null,
                                                                 "canonicalUrl": "https://dev.maxpreps.com/news/jpCY0hwMqkaGHJbk-nb_rQ/sac-joaquin-section-releases-new-plan-for-season-1-in-2021.htm"
                                                             },
                                                             {
                                                                 "type": "Article",
                                                                 "title": "Video: When will California sports return?",
                                                                 "text": "Health and Human Services agency provides an update as state grapples with COVID-19 guidelines, tiers.",
                                                                 "thumbnailUrl": "https://images.maxpreps.com/editorial/article/a/9/a/a9a554a4-6e1b-4835-828a-4b989d7a79a9/2cf9a134-d723-eb11-80ce-a444a33a3a97_original.jpg?version=637409524200000000",
                                                                 "thumbnailWidth": null,
                                                                 "thumbnailHeight": null,
                                                                 "canonicalUrl": "https://dev.maxpreps.com/news/pFSlqRtuNUiCikuYnXp5qQ/video--when-will-california-high-school-and-youth-sports-return.htm"
                                                             },
                                                             {
                                                                 "type": "Article",
                                                                 "title": "Map: Where NFL QBs went to high school",
                                                                 "text": "Patrick Mahomes, Kyler Murray join 18 other quarterbacks who played high school football in Texas.",
                                                                 "thumbnailUrl": "https://images.maxpreps.com/editorial/article/a/e/0/ae0a7fa5-86bc-4082-91e3-4cf67d094940/29d89c6e-d17d-ea11-80ce-a444a33a3a97_original.jpg?version=637223926200000000",
                                                                 "thumbnailWidth": null,
                                                                 "thumbnailHeight": null,
                                                                 "canonicalUrl": "https://dev.maxpreps.com/news/pX8KrryGgkCR40z2fQlJQA/map--where-every-nfl-quarterback-drafted-in-the-past-10-years-played-high-school-football.htm"
                                                             }
                                                         ]
                                                     }
                                                 ]
                                             }
                                         ],
                                         "warnings": [],
                                         "errors": []
                                     }
                                     */
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
    
    // MARK: - Get Team Videos and Tagged Careers
    
    class func getTeamVideos(schoolId: String, allSeasonId: String, sortOrder: Int, completionHandler: @escaping (_ videos: Array<Dictionary<String,Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetTeamVideosHostDev, schoolId, allSeasonId, sortOrder)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetTeamVideosHostDev, schoolId, allSeasonId, sortOrder)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetTeamVideosHostStaging, schoolId, allSeasonId, sortOrder)
        }
        else
        {
            urlString = String(format: kGetTeamVideosHostProduction, schoolId, allSeasonId, sortOrder)
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
                                    
                                    let items = dictionary["data"] as! Array<Dictionary<String, Any>>
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
    
    class func getVideoTaggedCareers(videoId: String, completionHandler: @escaping (_ items: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetVideoTaggedCareersHostDev, videoId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetVideoTaggedCareersHostDev, videoId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetVideoTaggedCareersHostStaging, videoId)
        }
        else
        {
            urlString = String(format: kGetVideoTaggedCareersHostProduction, videoId)
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
    
    // MARK: - Search for Athlete Feed
    
    class func searchForAthlete(name: String, gender: String, sport: String, state: String, completionHandler: @escaping (_ athletes: Array<Dictionary<String, Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        // Clean up the name
        let escapedName = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.lowercased()
        
        // Replace the ampersands in the sport with %26
        let escapedSport = sport.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?.lowercased()
        let fixedSport = escapedSport!.replacingOccurrences(of: "&", with: "%26")
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kAthleteSearchHostDev, escapedName!, gender.lowercased(), fixedSport)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kAthleteSearchHostDev, escapedName!, gender.lowercased(), fixedSport)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kAthleteSearchHostStaging, escapedName!, gender.lowercased(), fixedSport)
        }
        else
        {
            urlString = String(format: kAthleteSearchHostProduction, escapedName!, gender.lowercased(), fixedSport)
        }
        
        // optional "&maxresults=%@&state=%@&year=%@"
        // state = "" //All States
        // state = "ca" // California
        if (state != "")
        {
            let stateQueryParameter = String(format: "&state=%@", state)
            urlString = urlString + stateQueryParameter
        }
        
        // Clean up the URL with escape characters
        //let escapedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let url = URL(string: urlString)!
        var urlRequest = URLRequest(url: url)
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
                                    
                                    let data = dictionary["data"] as! Array< Dictionary<String, Any>>
                                    
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
                                completionHandler(nil,error)
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
                            completionHandler(nil,error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil,error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil,error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - User Image Feeds
    
    class func saveUserImage(imageData: Data, completionHandler: @escaping (_ post: String?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kSaveUserImageHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kSaveUserImageHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kSaveUserImageHostStaging, userId)
        }
        else
        {
            urlString = String(format: kSaveUserImageHostProduction, userId)
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
                                    
                                    let urlString = dictionary["data"] as! String
                                    
                                    // Finish the call
                                    completionHandler(urlString,nil)
                                    
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
    
    class func deleteUserImage(completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kDeleteUserImageHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kDeleteUserImageHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kDeleteUserImageHostStaging, userId)
        }
        else
        {
            urlString = String(format: kDeleteUserImageHostProduction, userId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "DELETE"
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
                            completionHandler(nil)
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
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Career Image Feeds
        
    class func saveCareerImage(careerId: String, imageData: Data, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kSaveCareerImageHostDev, careerId, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kSaveCareerImageHostDev, careerId, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kSaveCareerImageHostStaging, careerId, userId)
        }
        else
        {
            urlString = String(format: kSaveCareerImageHostProduction, careerId, userId)
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
                                    
                                // Finish the call
                                completionHandler(nil)
                            }
                            else
                            {
                                print("Data was nil")
                                let errorDictionary = [NSLocalizedDescriptionKey : "Data was nil"]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                                completionHandler(error)
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
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
        
    }
    
    class func deleteCareerImage(careerId: String, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kDeleteCareerImageHostDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kDeleteCareerImageHostDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kDeleteCareerImageHostStaging, careerId)
        }
        else
        {
            urlString = String(format: kDeleteCareerImageHostProduction, careerId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "DELETE"
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
                            completionHandler(nil)
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
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }

    // MARK: - FMS Feed
    
    class func getFMSData(appInfo: Dictionary<String,Any>, deviceInfo: Dictionary<String,Any>, identifiers: Dictionary<String,Any>, completionHandler: @escaping (_ results: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        let urlString = "https://fms.viacomcbs.digital/lookup"
        let params = ["app":appInfo, "device":deviceInfo, "identifiers":identifiers]
    
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var postBodyData: Data? = nil
        do
        {
            postBodyData = try JSONSerialization.data(withJSONObject: params, options: [])
            
            //let logData = String(decoding: postBodyData!, as: UTF8.self)
            //print(logData)
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
                                //let logDataReceived = String(decoding: data!, as: UTF8.self)
                                //print(logDataReceived)
                                
                                // Decompose the JSON data
                                var dictionary : Dictionary<String, Any> = [:]
                                
                                do {
                                    dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                    
                                    // Finish the call
                                    completionHandler(dictionary,nil)
                                    
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
                                completionHandler(nil,error)
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
                            completionHandler(nil,error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(nil,error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(nil,error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Get Favorite Team Contest Feeds
    
    class func getFavoriteTeamContests(_ teamsArray: Array<Dictionary<String,String>>, completionHandler: @escaping (_ result: Array<Dictionary<String,Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kGetFavoriteTeamContestsDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kGetFavoriteTeamContestsDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kGetFavoriteTeamContestsStaging
        }
        else
        {
            urlString = kGetFavoriteTeamContestsProduction
        }

        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: teamsArray, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(nil, error)
            return
        }

        let logDataReceived = String(decoding: postBodyData!, as: UTF8.self)
        print(logDataReceived)

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
                                    
                                    let contests = dictionary["data"] as! Array<Dictionary<String,Any>>
                                            
                                    completionHandler(contests, nil)
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
    
    class func getFavoriteTeamContestResults(contests: Array<String>, completionHandler: @escaping (_ result: Array<Dictionary<String,Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetFavoriteTeamContestResultsDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetFavoriteTeamContestResultsDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetFavoriteTeamContestResultsStaging, userId)
        }
        else
        {
            urlString = String(format: kGetFavoriteTeamContestResultsProduction, userId)
        }

        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: contests, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(nil, error)
            return
        }

        let logDataReceived = String(decoding: postBodyData!, as: UTF8.self)
        print(logDataReceived)

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
                                    
                                    let contests = dictionary["data"] as! Array<Dictionary<String,Any>>
                                            
                                    completionHandler(contests, nil)
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
    
    // MARK: - Get Scoreboard Feeds
    
    class func getScoreboardEntities(stateCode: String, genderCommaSport:String, year: String, season: String, completionHandler: @escaping (_ items: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetScoreboardEntitiesDev, stateCode, genderCommaSport)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetScoreboardEntitiesDev, stateCode, genderCommaSport)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetScoreboardEntitiesStaging, stateCode, genderCommaSport)
        }
        else
        {
            urlString = String(format: kGetScoreboardEntitiesProduction, stateCode, genderCommaSport)
        }
        
        if (year != "") && (season != "")
        {
            // Append the year and state to the query parameter
            let extraQueryParameter = String(format: "&year=%@&season=%@", year, season)
            urlString = urlString + extraQueryParameter
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
                                    if let scoreboards = dictionary["data"] as? Dictionary<String,Any>
                                    {
                                        completionHandler(scoreboards, nil)
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
    
    class func getScoreboardContests(context: String, id: String, genderCommaSport: String, completionHandler: @escaping (_ result: Array<Dictionary<String,Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetScoreboardContestsDev, context, id, genderCommaSport)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetScoreboardContestsDev, context, id, genderCommaSport)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetScoreboardContestsStaging, context, id, genderCommaSport)
        }
        else
        {
            urlString = String(format: kGetScoreboardContestsProduction, context, id, genderCommaSport)
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
                                    
                                    let contests = dictionary["data"] as! Array<Dictionary<String,Any>>
                                            
                                    completionHandler(contests, nil)
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
    
    class func getScoreboardContestResults(contests: Array<String>, includeRankings: Bool, completionHandler: @escaping (_ result: Array<Dictionary<String,Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (includeRankings == true)
        {
            if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
            {
                urlString = String(format: "%@?context=national", kGetScoreboardContestResultsDev)
            }
            else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
            {
                urlString = String(format: "%@?context=national", kGetScoreboardContestResultsDev)
            }
            else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
            {
                urlString = String(format: "%@?context=national", kGetScoreboardContestResultsStaging)
            }
            else
            {
                urlString = String(format: "%@?context=national", kGetScoreboardContestResultsProduction)
            }
        }
        else
        {
            if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
            {
                urlString = kGetScoreboardContestResultsDev
            }
            else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
            {
                urlString = kGetScoreboardContestResultsDev
            }
            else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
            {
                urlString = kGetScoreboardContestResultsStaging
            }
            else
            {
                urlString = kGetScoreboardContestResultsProduction
            }
        }

        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: contests, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(nil, error)
            return
        }

        let logDataReceived = String(decoding: postBodyData!, as: UTF8.self)
        print(logDataReceived)

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
                                    
                                    let contests = dictionary["data"] as! Array<Dictionary<String,Any>>
                                            
                                    completionHandler(contests, nil)
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
    
    // MARK: - Box Score Feeds
    
    class func getBoxScores(schoolId: String, ssid: String, contestId: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetBoxScoresDev, schoolId, ssid, contestId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetBoxScoresDev, schoolId, ssid, contestId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetBoxScoresStaging, schoolId, ssid, contestId)
        }
        else
        {
            urlString = String(format: kGetBoxScoresProduction, schoolId, ssid, contestId)
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
    
    class func updateBoxScore(schoolId: String, ssid: String, contestId: String, overrideResultWithWinner: Bool, teamScores: Array<Dictionary<String,Any>>, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kUpdateBoxScoreDev, schoolId, ssid, contestId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kUpdateBoxScoreDev, schoolId, ssid, contestId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kUpdateBoxScoreStaging, schoolId, ssid, contestId)
        }
        else
        {
            urlString = String(format: kUpdateBoxScoreProduction, schoolId, ssid, contestId)
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
        urlRequest.addValue("MobileApp", forHTTPHeaderField: "mp-sources-score-source")
        urlRequest.addValue("MobileAppMaxprepsAppIOS", forHTTPHeaderField: "mp-sources-score-subsource")
        urlRequest.addValue("ScoreUpdate", forHTTPHeaderField: "mp-sources-score-type")
        urlRequest.addValue("BoxScore", forHTTPHeaderField: "mp-sources-score-subtype")
                
        /*
         The following headers/sources were not sent with the current request: mp-sources-score-subtype,mp-sources-score-subsource,mp-sources-score-type,mp-sources-score-source"]}
        */
        
        var parameters = [:] as Dictionary<String,Any>
        
        parameters["contestId"] = contestId
        parameters["overrideResultWithWinnerBox"] = overrideResultWithWinner
        parameters["teamScores"] = teamScores
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: parameters, options: [.withoutEscapingSlashes])
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
                                    let data = dictionary["data"] as! Dictionary<String,Any>
                                    
                                    // Call Branch event tracking
                                    let userType = kUserDefaults.string(forKey: kUserTypeKey)!
                                    let event = BranchEvent.customEvent(withName:"SCORE_ENTRY")
                                    event.customData["userId"] = userId
                                    event.customData["userRole"] = userType
                                    event.alias = "SCORE ENTRY"
                                    event.logEvent()
                                    
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
    
    // MARK: - User Profile Feeds
    
    class func getAthleteUserProfile(careerId: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetAthleteUserProfileDev, userId, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetAthleteUserProfileDev, userId, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetAthleteUserProfileStaging, userId, careerId)
        }
        else
        {
            urlString = String(format: kGetAthleteUserProfileProduction, userId, careerId)
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
    
    class func updateAthleteUserProfile(careerId: String, bio: String, faceBookProfile: String, twitterHandle: String, classYear: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kUpdateAthleteUserProfileDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kUpdateAthleteUserProfileDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kUpdateAthleteUserProfileStaging, careerId)
        }
        else
        {
            urlString = String(format: kUpdateAthleteUserProfileProduction, careerId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "PATCH"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        var parameters = [:] as Dictionary<String,Any>
        
        //parameters["sportSeasonId"] = ssid (does not change)
        parameters["bio"] = bio
        parameters["facebookProfile"] = faceBookProfile
        parameters["twitterHandle"] = twitterHandle
        
        if (classYear.count > 0)
        {
            parameters["graduatingClass"] = Int(classYear)!
        }
        else
        {
            parameters["graduatingClass"] = NSNull()
        }
        
        // Iterate through the parameters to make a patch array
        var patchArray: Array<Dictionary<String,Any>> = []
        
        for item in parameters
        {
            let patchDictionary = ["path": item.key, "value": item.value, "op": "replace"]
            patchArray.append(patchDictionary)
        }
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: patchArray, options: [.withoutEscapingSlashes])
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
                        else if (httpResponse.statusCode == 400)
                        {
                            // Wrong email/password error
                            print("Status == 400")
                            
                            // Decompose the JSON data to get the message
                            var dictionary : Dictionary<String, Any> = [:]
                              
                            do {
                                dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                
                                let message = dictionary["message"] as! String
                                
                                let messageDictionary = [NSLocalizedDescriptionKey : message]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 400, userInfo: messageDictionary)
                                completionHandler(nil,error)
                                
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
    
    class func getFanUserProfile(completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetFanUserProfileDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetFanUserProfileDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetFanUserProfileStaging, userId)
        }
        else
        {
            urlString = String(format: kGetFanUserProfileProduction, userId)
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
    
    class func getParentUserProfile(careerId: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetParentUserProfileDev, userId, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetParentUserProfileDev, userId, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetParentUserProfileStaging, userId, careerId)
        }
        else
        {
            urlString = String(format: kGetParentUserProfileProduction, userId, careerId)
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
    
    class func getCoachUserProfile(schoolId: String, ssid: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetCoachUserProfileDev, userId, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetCoachUserProfileDev, userId, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetCoachUserProfileStaging, userId, schoolId, ssid)
        }
        else
        {
            urlString = String(format: kGetCoachUserProfileProduction, userId, schoolId, ssid)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token using the coach's userId
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
    
    class func getADUserProfile(schoolId: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetADUserProfileDev, userId, schoolId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetADUserProfileDev, userId, schoolId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetADUserProfileStaging, userId, schoolId)
        }
        else
        {
            urlString = String(format: kGetADUserProfileProduction, userId, schoolId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token using the coach's userId
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
    
    class func updateCoachUserProfile(bio: String, faceBookProfile: String, twitterHandle: String, firstName: String, lastName: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kUpdateCoachUserProfileDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kUpdateCoachUserProfileDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kUpdateCoachUserProfileStaging, userId)
        }
        else
        {
            urlString = String(format: kUpdateCoachUserProfileProduction, userId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "PATCH"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        var parameters = [:] as Dictionary<String,Any>
        
        //parameters["sportSeasonId"] = ssid (does not change)
        parameters["bio"] = bio
        parameters["facebookUrl"] = faceBookProfile
        parameters["twitterHandle"] = twitterHandle
        
        if (firstName != "")
        {
            parameters["userFirstName"] = firstName
        }
        
        if (lastName != "")
        {
            parameters["userLastName"] = lastName
        }
        
        // Iterate through the parameters to make a patch array
        var patchArray: Array<Dictionary<String,Any>> = []
        
        for item in parameters
        {
            let patchDictionary = ["path": item.key, "value": item.value, "op": "replace"]
            patchArray.append(patchDictionary)
        }
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: patchArray, options: [.withoutEscapingSlashes])
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
                        else if (httpResponse.statusCode == 400)
                        {
                            // Wrong email/password error
                            print("Status == 400")
                            
                            // Decompose the JSON data to get the message
                            var dictionary : Dictionary<String, Any> = [:]
                              
                            do {
                                dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                
                                let message = dictionary["message"] as! String
                                
                                let messageDictionary = [NSLocalizedDescriptionKey : message]
                                let error = NSError.init(domain: kMaxPrepsAppError, code: 400, userInfo: messageDictionary)
                                completionHandler(nil,error)
                                
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
    
    class func getCoachUserProfileTeamSummaries(completionHandler: @escaping (_ results: Array<Dictionary<String,Any>>?, _ error: Error?) -> Void) {
        
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetCoachUserProfileTeamSummariesDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetCoachUserProfileTeamSummariesDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetCoachUserProfileTeamSummariesStaging, userId)
        }
        else
        {
            urlString = String(format: kGetCoachUserProfileTeamSummariesProduction, userId)
        }
   
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
        /*
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        
        // Build the POST body
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: teams, options: [])
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
        */
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { (data, response, connectionError) in
            
            DispatchQueue.main.async
            {
                if (connectionError == nil)
                {
                    if let httpResponse = response as? HTTPURLResponse
                    {
                        print("Response: " + response!.description)
                        
                        if (data != nil)
                        {
                            let logDataReceived = String(decoding: data!, as: UTF8.self)
                            print(logDataReceived)
                            
                            // Decompose the JSON data
                            var dictionary : Dictionary<String, Any> = [:]
                              
                            do {
                                dictionary =  try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                                
                                let teams = dictionary["data"] as! Array<Dictionary<String,Any>>
                                        
                                completionHandler(teams, nil)
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
    
    // MARK: - Claim Athlete Profile Feeds
    
    class func getCareerContacts(careerId: String, completionHandler: @escaping (_ result: Array<Dictionary<String,Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetCareerContactsDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetCareerContactsDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetCareerContactsStaging, careerId)
        }
        else
        {
            urlString = String(format: kGetCareerContactsProduction, careerId)
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
                                    
                                    let items = dictionary["data"] as! Array<Dictionary<String, Any>>
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
    
    class func getUserCareerAdminContacts(completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetUserCareerAdminContactsDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetUserCareerAdminContactsDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetUserCareerAdminContactsStaging, userId)
        }
        else
        {
            urlString = String(format: kGetUserCareerAdminContactsProduction, userId)
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
                                    
                                    if (dictionary["data"] is NSNull)
                                    {
                                        completionHandler([:], nil)
                                    }
                                    else
                                    {
                                        let items = dictionary["data"] as! Dictionary<String, Any>
                                        completionHandler(items, nil)
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
    
    class func getAthleteClaimEligibility(careerId: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetAthleteClaimEligibilityDev, careerId, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetAthleteClaimEligibilityDev, careerId, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetAthleteClaimEligibilityStaging, careerId, userId)
        }
        else
        {
            urlString = String(format: kGetAthleteClaimEligibilityProduction, careerId, userId)
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
    
    class func claimCareerProfile(careerId: String, relationship: String, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kClaimCareerProfileDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kClaimCareerProfileDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kClaimCareerProfileStaging, userId)
        }
        else
        {
            urlString = String(format: kClaimCareerProfileProduction, userId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")

        // Minimum required for this API
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        urlRequest.addValue("maxprepsapp_ios", forHTTPHeaderField: "mp-sources-user-source")
        
        /*
         // Athlete:
         {
                 "userId": "{userId}",
                 "roleId": "35D1CA54-4CA9-4C17-81A5-70FDE642D3A1",
                 "accessId1": "{careerId}",
                 "accessId2": null,
                 "position": "Athlete",
                 "permissions": [
                     { "permissionFeatureId" : "D400AB66-AF4D-40B8-AA2B-F3C8BE736446" }
                 ]
             }
         
         // Parent:
         {
                 "userId": "{userId}",
                 "roleId": "35D1CA54-4CA9-4C17-81A5-70FDE642D3A1",
                 "accessId1": "{careerId}",
                 "accessId2": null,
                 "position": "Parent",
                 "permissions": [
                     { "permissionFeatureId" : "D2495E20-0C41-4409-8811-C85B360AD96E" }
                 ]
             }
         */
        
        var parameters = [:] as Dictionary<String,Any>
        
        parameters["userId"] = userId
        parameters["roleId"] = "35D1CA54-4CA9-4C17-81A5-70FDE642D3A1"
        parameters["accessId1"] = careerId
        parameters["accessId2"] = NSNull()
        parameters["position"] = relationship
        
        if (relationship == "Athlete")
        {
            parameters["permissions"] = [["permissionFeatureId":"D400AB66-AF4D-40B8-AA2B-F3C8BE736446"]]
        }
        else
        {
            parameters["permissions"] = [["permissionFeatureId":"D2495E20-0C41-4409-8811-C85B360AD96E"]]
        }
                
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(error)
            return
        }
        
        let logOut = String(decoding: postBodyData!, as: UTF8.self)
        print("Career Profile Log: " + logOut)

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
                            // Call Branch event tracking
                            let userType = kUserDefaults.string(forKey: kUserTypeKey)!
                            let event = BranchEvent.customEvent(withName:"CLAIMED_PROFILE")
                            event.customData["userId"] = userId
                            event.customData["userRole"] = userType
                            event.alias = "CLAIMED PROFILE"
                            event.logEvent()
                            
                            completionHandler(nil)
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
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Latest Tab Feeds
    
    class func getLatestTabItems(favorites: Array<Dictionary<String,String>>, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        //let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kGetLatestTabItemsDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kGetLatestTabItemsDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kGetLatestTabItemsStaging
        }
        else
        {
            urlString = kGetLatestTabItemsProduction
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        //let encryptedUserId = FeedsHelper.encryptString(userId)
        //urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        let parameters = ["filters" : favorites]
        
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
        print("Latest Tab Log: " + logOut)

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
    
    class func getNationalCompetitiveSeasons(gender: String, sport: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        let sport = sport.replacingOccurrences(of: " ", with: "")
        let genderCommaSport = String(format: "%@,%@", gender, sport)
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetNationalCompetitiveSeasonsDev, genderCommaSport)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetNationalCompetitiveSeasonsDev, genderCommaSport)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetNationalCompetitiveSeasonsStaging, genderCommaSport)
        }
        else
        {
            urlString = String(format: kGetNationalCompetitiveSeasonsProduction, genderCommaSport)
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
    
    class func getStateCompetitiveSeasons(state: String, completionHandler: @escaping (_ result: Array<Dictionary<String,Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        //let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        let stateCode = kShortStateLookupDictionary[state]!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetStateCompetitiveSeasonsDev, stateCode)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetStateCompetitiveSeasonsDev, stateCode)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetStateCompetitiveSeasonsStaging, stateCode)
        }
        else
        {
            urlString = String(format: kGetStateCompetitiveSeasonsProduction, stateCode)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        //let encryptedUserId = FeedsHelper.encryptString(userId)
        //urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
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
                                    
                                    let items = dictionary["data"] as! Array<Dictionary<String, Any>>
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
    
    class func getPlayerStatLeaders(gender: String, sport: String, year: String, season: String, context: String, contextId: String, state: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        //let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        let sport = sport.replacingOccurrences(of: " ", with: "")
        let genderCommaSport = String(format: "%@,%@", gender, sport)
        
        var queryParam = ""
        
        if (context == "National")
        {
            queryParam = String(format: "context=national&gendersport=%@&year=%@&season=%@", genderCommaSport, year, season)
        }
        else if (context == "State")
        {
            let stateCode = kShortStateLookupDictionary[state]!
            queryParam = String(format: "context=state&id=%@&gendersport=%@&year=%@&season=%@", stateCode, genderCommaSport, year, season)
        }
        else
        {
            queryParam = String(format: "context=%@&id=%@&gendersport=%@&year=%@&season=%@", context, contextId, genderCommaSport, year, season)
        }
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetAthleteStatLeadersDev, queryParam)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetAthleteStatLeadersDev, queryParam)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetAthleteStatLeadersStaging, queryParam)
        }
        else
        {
            urlString = String(format: kGetAthleteStatLeadersProduction, queryParam)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        //let encryptedUserId = FeedsHelper.encryptString(userId)
        //urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
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
    
    class func getTeamStatLeaders(gender: String, sport: String, year: String, season: String, context: String, contextId: String, state: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        //let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        let sport = sport.replacingOccurrences(of: " ", with: "")
        let genderCommaSport = String(format: "%@,%@", gender, sport)
        
        var queryParam = ""
        
        if (context == "National")
        {
            queryParam = String(format: "context=national&gendersport=%@&year=%@&season=%@", genderCommaSport, year, season)
        }
        else if (context == "State")
        {
            let stateCode = kShortStateLookupDictionary[state]!
            queryParam = String(format: "context=state&id=%@&gendersport=%@&year=%@&season=%@", stateCode, genderCommaSport, year, season)
        }
        else
        {
            queryParam = String(format: "context=%@&id=%@&gendersport=%@&year=%@&season=%@", context, contextId, genderCommaSport, year, season)
        }
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetTeamStatLeadersDev, queryParam)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetTeamStatLeadersDev, queryParam)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetTeamStatLeadersStaging, queryParam)
        }
        else
        {
            urlString = String(format: kGetTeamStatLeadersProduction, queryParam)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        //let encryptedUserId = FeedsHelper.encryptString(userId)
        //urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
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
    
    class func getTeamRankingsLeaders(gender: String, sport: String, year: String, season: String, context: String, contextId: String, state: String, teamSize: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        //let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        let sport = sport.replacingOccurrences(of: " ", with: "")
        let genderCommaSport = String(format: "%@,%@", gender, sport)
        
        var queryParam = ""
        
        if (sport == "Football")
        {
            if (context == "National")
            {
                queryParam = String(format: "context=national&gendersport=%@&year=%@&season=%@&count=25&teamSize=%@", genderCommaSport, year, season, teamSize)
            }
            else if (context == "State")
            {
                let stateCode = kShortStateLookupDictionary[state]!
                queryParam = String(format: "context=state&id=%@&gendersport=%@&year=%@&season=%@&count=25&teamSize=%@", stateCode, genderCommaSport, year, season, teamSize)
            }
            else
            {
                queryParam = String(format: "context=%@&id=%@&gendersport=%@&year=%@&season=%@&count=25&teamSize=%@", context, contextId, genderCommaSport, year, season, teamSize)
            }
        }
        else
        {
            if (context == "National")
            {
                queryParam = String(format: "context=national&gendersport=%@&year=%@&season=%@&count=25&", genderCommaSport, year, season)
            }
            else if (context == "State")
            {
                let stateCode = kShortStateLookupDictionary[state]!
                queryParam = String(format: "context=state&id=%@&gendersport=%@&year=%@&season=%@&count=25", stateCode, genderCommaSport, year, season)
            }
            else
            {
                queryParam = String(format: "context=%@&id=%@&gendersport=%@&year=%@&season=%@&count=25", context, contextId, genderCommaSport, year, season)
            }
        }
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetTeamRankingsLeadersDev, queryParam)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetTeamRankingsLeadersDev, queryParam)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetTeamRankingsLeadersStaging, queryParam)
        }
        else
        {
            urlString = String(format: kGetTeamRankingsLeadersProduction, queryParam)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        //let encryptedUserId = FeedsHelper.encryptString(userId)
        //urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
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
    
    class func getSportsArenaPlayoffStateSeasons(gender: String, sport: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        //let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        let sport = sport.replacingOccurrences(of: " ", with: "")
        let genderCommaSport = String(format: "%@,%@", gender, sport)
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetSportsArenaPlayoffStateSeasonsDev, genderCommaSport)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetSportsArenaPlayoffStateSeasonsDev, genderCommaSport)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetSportsArenaPlayoffStateSeasonsStaging, genderCommaSport)
        }
        else
        {
            urlString = String(format: kGetSportsArenaPlayoffStateSeasonsProduction, genderCommaSport)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        //let encryptedUserId = FeedsHelper.encryptString(userId)
        //urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
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
    
    class func getSportsArenaPlayoffBrackets(gender: String, sport: String, state: String, season: String, year: String, completionHandler: @escaping (_ result: Array<Dictionary<String,Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        //let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        let sport = sport.replacingOccurrences(of: " ", with: "")
        let genderCommaSport = String(format: "%@,%@", gender, sport)
        let stateCode = kShortStateLookupDictionary[state]!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetSportsArenaPlayoffsDev, stateCode, genderCommaSport, year, season)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetSportsArenaPlayoffsDev, stateCode, genderCommaSport, year, season)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetSportsArenaPlayoffsStaging, stateCode, genderCommaSport, year, season)
        }
        else
        {
            urlString = String(format: kGetSportsArenaPlayoffsProduction, stateCode, genderCommaSport, year, season)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        //let encryptedUserId = FeedsHelper.encryptString(userId)
        //urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
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
                                    
                                    let items = dictionary["data"] as! Array<Dictionary<String,Any>>
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
    
    // MARK: - Native Team Home
    
    class func getNativeTeamHome(schoolId: String, ssid: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetNativeTeamHomeDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetNativeTeamHomeDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetNativeTeamHomeStaging, schoolId, ssid)
        }
        else
        {
            urlString = String(format: kGetNativeTeamHomeProduction, schoolId, ssid)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        //let encryptedUserId = FeedsHelper.encryptString(userId)
        //urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
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
    
    // MARK: - Coach and Volunteer Access Feeds
    
    class func requestCoachAccess(schoolId: String, allSeasonId: String, position: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kRequestCoachAccessHostDev)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kRequestCoachAccessHostDev)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kRequestCoachAccessHostStaging)
        }
        else
        {
            urlString = String(format: kRequestCoachAccessHostProduction)
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
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
        /*
         {
             "UserId": "bed5265b-d27d-4447-b0d9-06e165374135",
             "TeamId": "de0050ae-cf37-4ae6-b63d-301c97bd92d8",
             "AllSeasonId": "22e2b335-334e-4d4d-9f67-a0f716bb1ccd",
             "Position": "Assistant Coach",
             "SourceUrl": "",
             "PhoneExt": "",
             "AdditionalInformation": ""
         }
        */
        
        var parameters = [:] as Dictionary<String,Any>
        
        parameters["userId"] = userId
        parameters["teamId"] = schoolId
        parameters["allSeasonId"] = allSeasonId
        parameters["position"] = position
        parameters["sourceUrl"] = ""
        parameters["phoneExt"] = ""
        parameters["additionalInformation"] = ""
        
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
    
    class func requestVolunteerAccess(schoolId: String, allSeasonId: String, season: String, message: String, coachUserId: String, coachFirstName: String, coachLastName: String, coachEmail: String, coachPhone: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kRequestVolunteerAccessHostDev)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kRequestVolunteerAccessHostDev)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kRequestVolunteerAccessHostStaging)
        }
        else
        {
            urlString = String(format: kRequestVolunteerAccessHostProduction)
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
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
        /*
         {
             "userId": "597a0efd-7622-4291-88a9-ef72bf99cdc2",
             "teamId": "de0050ae-cf37-4ae6-b63d-301c97bd92d8",
             "allSeasonId": "22e2b335-334e-4d4d-9f67-a0f716bb1ccd",
             "season": "",
             "requestMessage": "This is a test",
             "coachUserId": "244564df-40fd-4cc6-b692-7698a5618000",
             "coachFirstName": "",
             "coachLastName": "",
             "coachEmail": "",
             "coachPhone": ""
         }
        */
        
        var parameters = [:] as Dictionary<String,Any>
        
        parameters["userId"] = userId
        parameters["teamId"] = schoolId
        parameters["allSeasonId"] = allSeasonId
        parameters["season"] = season
        parameters["requestMessage"] = message
        parameters["coachUserId"] = coachUserId
        parameters["coachFirstName"] = coachFirstName
        parameters["coachLastName"] = coachLastName
        parameters["coachEmail"] = coachEmail
        parameters["coachPhone"] = coachPhone
        
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
    
    //  MARK: - Deep Link Info Feeds
    
    class func getCareerDeepLinkInfo(careerId: String, completionHandler: @escaping (_ careerInfo: Dictionary<String, Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetCareerDeepLinkInfoHostDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetCareerDeepLinkInfoHostDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetCareerDeepLinkInfoHostStaging, careerId)
        }
        else
        {
            urlString = String(format: kGetCareerDeepLinkInfoHostProduction, careerId)
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
                                    
                                    let careerInfo = dictionary["data"] as! Dictionary<String, Any>
                                    completionHandler(careerInfo, nil)
                                
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
    
    class func getTeamDeepLinkInfo(schoolId: String, ssid: String, completionHandler: @escaping (_ teamInfo: Dictionary<String, Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetTeamDeepLinkInfoHostDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetTeamDeepLinkInfoHostDev, schoolId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetTeamDeepLinkInfoHostStaging, schoolId, ssid)
        }
        else
        {
            urlString = String(format: kGetTeamDeepLinkInfoHostProduction, schoolId, ssid)
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
                                    
                                    let teamInfo = dictionary["data"] as! Dictionary<String, Any>
                                    completionHandler(teamInfo, nil)
                                
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
    
    // MARK: - Career Teams Feed
    
    class func getCareerTeams(careerId: String, completionHandler: @escaping (_ teams: Array<Dictionary<String, Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetCareerTeamsHostDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetCareerTeamsHostDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetCareerTeamsHostStaging, careerId)
        }
        else
        {
            urlString = String(format: kGetCareerTeamsHostProduction, careerId)
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
                                    
                                    let teams = dictionary["data"] as! Array<Dictionary<String, Any>>
                                    completionHandler(teams, nil)
                                
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
    
    // MARK: - Video View Count
    
    class func incrementVideoViewCount(videoId: String, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kIncrementVideoViewCountHostDev, videoId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kIncrementVideoViewCountHostDev, videoId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kIncrementVideoViewCountHostStaging, videoId)
        }
        else
        {
            urlString = String(format: kIncrementVideoViewCountHostProduction, videoId)
        }
                
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("octet/stream", forHTTPHeaderField: "Content-Type")
        
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
                            completionHandler(nil)
                        }
                        else
                        {
                            print("Status != 200")
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Video Contibutions Feeds
    
    class func getUserVideoContributions(completionHandler: @escaping (_ videos: Array<Dictionary<String,Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetUserVideoContributionsHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetUserVideoContributionsHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetUserVideoContributionsHostStaging, userId)
        }
        else
        {
            urlString = String(format: kGetUserVideoContributionsHostProduction, userId)
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
                                    
                                    let items = dictionary["data"] as! Array<Dictionary<String, Any>>
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
    
    class func updateUserVideoDetails(videoId: String, title: String, description: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kUpdateUserVideoDetailsDev, videoId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kUpdateUserVideoDetailsDev, videoId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kUpdateUserVideoDetailsStaging, videoId)
        }
        else
        {
            urlString = String(format: kUpdateUserVideoDetailsProduction, videoId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "PATCH"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        var parameters = [:] as Dictionary<String,Any>
        
        parameters["title"] = title
        parameters["description"] = description
        
        // Iterate through the parameters to make a patch array
        var patchArray: Array<Dictionary<String,Any>> = []
        
        for item in parameters
        {
            let patchDictionary = ["path": item.key, "value": item.value, "op": "replace"]
            patchArray.append(patchDictionary)
        }
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: patchArray, options: [.withoutEscapingSlashes])
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
    
    class func deleteUserContributionsVideo(videoId: String, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kDeleteUserContributionsVideoDev, videoId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kDeleteUserContributionsVideoDev, videoId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kDeleteUserContributionsVideoStaging, videoId)
        }
        else
        {
            urlString = String(format: kDeleteUserContributionsVideoProduction, videoId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "DELETE"
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
                            completionHandler(nil)
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
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    class func untagAthleteFomVideo(videoId: String, careerId: String, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kUntagAthleteFromVideoDev, videoId, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kUntagAthleteFromVideoDev, videoId, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kUntagAthleteFromVideoStaging, videoId, careerId)
        }
        else
        {
            urlString = String(format: kUntagAthleteFromVideoProduction, videoId, careerId)
        }
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "DELETE"
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
                            completionHandler(nil)
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
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    class func reportVideo(videoId: String, message: String, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kReportVideoHostDev, videoId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kReportVideoHostDev, videoId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kReportVideoHostStaging, videoId)
        }
        else
        {
            urlString = String(format: kReportVideoHostProduction, videoId)
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
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
        /*
         POST data:
         {
             "videoId": "597a0efd-7622-4291-88a9-ef72bf99cdc2",
             "userId": "74c1621c-e0cf-4821-b5e1-3c8170c8125a",
             "message": "Blah blah"
         }
         */
        
        let jsonDict = ["videoId": videoId, "userId": userId, "message": message]
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(error)
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
                            completionHandler(nil)
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
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Test Cookie Feed
    
    class func loadCookie(_ favorite: Dictionary<String,Any>, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kNewSaveUserFavoriteTeamHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kNewSaveUserFavoriteTeamHostDev, userId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kNewSaveUserFavoriteTeamHostStaging, userId)
        }
        else
        {
            urlString = String(format: kNewSaveUserFavoriteTeamHostProduction, userId)
        }
        
        urlString = "https://dev.api.maxpreps.com/utilities/testing/cookie/v1"
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")
        
        // Build the header dictionary for Exact Target Emails
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
        /*
         POST data:
         {
             "userId": "597a0efd-7622-4291-88a9-ef72bf99cdc2",
             "schoolId": "74c1621c-e0cf-4821-b5e1-3c8170c8125a",
             "allSeasonId": "A42C7EA4-0907-491E-B56F-A2D31A45BF19",
             "seasonName": "Winter",
             "source": "MaxprepsApp_IOS"
         }
         */
        
        //let schoolId = favorite[kNewSchoolIdKey]
        //let allSeasonId = favorite[kNewAllSeasonIdKey]
        //let season = favorite[kNewSeasonKey]
        
        //let jsonDict = [kNewSchoolIdKey: schoolId, kNewAllSeasonIdKey: allSeasonId, "userId": userId, "seasonName": season, "source": "MaxprepsApp_IOS"]
        let jsonDict = ["email": kDaveEmail, "password": kDavePassword]
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: jsonDict, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(error)
            return
        }

        let logData = String(decoding: postBodyData!, as: UTF8.self)
        print(logData)

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
                            completionHandler(nil)
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
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Notification Test Feed
    
    class func sendUserTestNotification(message: String, server: String, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        let urlString = String(format: kSendUserNotificationHost, message, userId, server)
        
        var urlRequest = URLRequest(url: URL(string: urlString)!)
        urlRequest.timeoutInterval = 30
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("iphone", forHTTPHeaderField: "appplatform")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Get the encrypted token
        let encryptedUserId = FeedsHelper.encryptString(userId)
        urlRequest.addValue(encryptedUserId, forHTTPHeaderField: "X-MP-UserToken")

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
                            completionHandler(nil)
                        }
                        else
                        {
                            print("Status != 200")
                            
                            let errorDictionary = [NSLocalizedDescriptionKey : "Status != 200"]
                            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                            completionHandler(error)
                        }
                    }
                    else
                    {
                        print("Response was nil")
                        let errorDictionary = [NSLocalizedDescriptionKey : "Response was nil"]
                        let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                        completionHandler(error)
                    }
                }
                else
                {
                    print("Connection Error")
                    let errorDictionary = [NSLocalizedDescriptionKey : "Connection Error"]
                    let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
                    completionHandler(error)
                }
            }
        }
        
        task.resume()
    }
    
}
