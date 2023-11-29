//
//  CareerFeeds.swift
//  MPScoreboard3
//
//  Created by David Smith on 9/7/23.
//

import Foundation

class CareerFeeds: NSObject
{
    // MARK: - Athlete Career Feeds
    
    class func getCareerHome(_ careerId: String, completionHandler: @escaping (_ availableItems: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetCareerHomeHostDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetCareerHomeHostDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetCareerHomeHostStaging, careerId)
        }
        else
        {
            urlString = String(format: kGetCareerHomeHostProduction, careerId)
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
    
    class func getCareerProfileBio(_ careerId: String, completionHandler: @escaping (_ availableItems: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetCareerProfileBioHostDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetCareerProfileBioHostDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetCareerProfileBioHostStaging, careerId)
        }
        else
        {
            urlString = String(format: kGetCareerProfileBioHostProduction, careerId)
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
    
    class func getCareerTimeline(_ careerId: String, pageNumber: Int, maxItems: Int, completionHandler: @escaping (_ availableItems: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetCareerTimelineHostDev, careerId, pageNumber, maxItems)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetCareerTimelineHostDev, careerId, pageNumber, maxItems)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetCareerTimelineHostStaging, careerId, pageNumber, maxItems)
        }
        else
        {
            urlString = String(format: kGetCareerTimelineHostProduction, careerId, pageNumber, maxItems)
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
    
    class func getCareerAwards(_ careerId: String, completionHandler: @escaping (_ availableItems: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetCareerAwardsHostDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetCareerAwardsHostDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetCareerAwardsHostStaging, careerId)
        }
        else
        {
            urlString = String(format: kGetCareerAwardsHostProduction, careerId)
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
    
    class func getCareerPhotos(_ careerId: String, completionHandler: @escaping (_ items: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetCareerPhotosHostDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetCareerPhotosHostDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetCareerPhotosHostStaging, careerId)
        }
        else
        {
            urlString = String(format: kGetCareerPhotosHostProduction, careerId)
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
    
    class func getCareerVideos(_ careerId: String, pageNumber: Int, maxItems: Int, sort: String, completionHandler: @escaping (_ availableItems: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetCareerVideosHostDev, careerId, pageNumber, maxItems, sort)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetCareerVideosHostDev, careerId, pageNumber, maxItems, sort)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetCareerVideosHostStaging, careerId, pageNumber, maxItems, sort)
        }
        else
        {
            urlString = String(format: kGetCareerVideosHostProduction, careerId, pageNumber, maxItems, sort)
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
    
    class func getCareerNews(_ careerId: String, completionHandler: @escaping (_ items: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetCareerNewsHostDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetCareerNewsHostDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetCareerNewsHostStaging, careerId)
        }
        else
        {
            urlString = String(format: kGetCareerNewsHostProduction, careerId)
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
    
    class func getCareerStatsHeader(_ careerId: String, completionHandler: @escaping (_ items: Dictionary<String,Any>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetCareerStatsHeaderHostDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetCareerStatsHeaderHostDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetCareerStatsHeaderHostStaging, careerId)
        }
        else
        {
            urlString = String(format: kGetCareerStatsHeaderHostProduction, careerId)
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
    
    class func getCareerStats(_ careerId: String, genderSport:String, completionHandler: @escaping (_ items: Array<Dictionary<String,Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetCareerStatsHostDev, careerId, genderSport)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetCareerStatsHostDev, careerId, genderSport)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetCareerStatsHostStaging, careerId, genderSport)
        }
        else
        {
            urlString = String(format: kGetCareerStatsHostProduction, careerId, genderSport)
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
                                    let statsArray = dictionary["data"] as! Array<Dictionary<String,Any>>
                                    completionHandler(statsArray, nil)
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
    
    class func getSeasonStats(_ athleteId: String, teamId:String, ssid:String, completionHandler: @escaping (_ items: Array<Dictionary<String,Any>>?, _ error: Error?) -> Void)
    {
        var urlString : String
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kGetSeasonStatsHostDev, athleteId, teamId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kGetSeasonStatsHostDev, athleteId, teamId, ssid)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kGetSeasonStatsHostStaging, athleteId, teamId, ssid)
        }
        else
        {
            urlString = String(format: kGetSeasonStatsHostProduction, athleteId, teamId, ssid)
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
                                    let statsArray = dictionary["data"] as! Array<Dictionary<String,Any>>
                                    completionHandler(statsArray, nil)
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
    
    class func updateAthletePlayerInfo(careerId: String, firstName: String, lastName: String, bio: String, twitter: String, instagram: String, snapchat: String, tikTok: String, facebook: String, gameChanger: String, hudl: String, classYear: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
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
        parameters["firstName"] = firstName
        parameters["lastName"] = lastName
        parameters["bio"] = bio
        parameters["twitterHandle"] = twitter
        parameters["instagram"] = instagram
        parameters["snapchat"] = snapchat
        parameters["tikTok"] = tikTok
        parameters["facebookProfile"] = facebook
        parameters["gameChanger"] = gameChanger
        parameters["hudl"] = hudl
        
        /*
         twitterTextField.text = playerInfoDictionary["twitterHandle"] as? String ?? ""
         instagramTextField.text = playerInfoDictionary["instagram"] as? String ?? ""
         snapchatTextField.text = playerInfoDictionary["snapchat"] as? String ?? ""
         tiktokTextField.text = playerInfoDictionary["tikTok"] as? String ?? ""
         facebookTextField.text = playerInfoDictionary["facebookProfile"] as? String ?? ""
         hudlTextField.text = playerInfoDictionary["hudl"] as? String ?? ""
         gameChangerTextField.text = playerInfoDictionary["gameChanger"] as? String ?? ""
         */
        
        if (classYear != "")
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
    
    class func updateAthleteAcademicScores(careerId: String, gpa: String, satScore: String, actScore: String, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kUpdateAthleteAcademicScoresDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kUpdateAthleteAcademicScoresDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kUpdateAthleteAcademicScoresStaging, careerId)
        }
        else
        {
            urlString = String(format: kUpdateAthleteAcademicScoresProduction, careerId)
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
        
        if (gpa != "")
        {
            parameters["highSchoolGpa"] = Double(gpa)!
        }
        else
        {
            parameters["highSchoolGpa"] = NSNull()
        }
        
        if (satScore != "")
        {
            parameters["satScore"] = Int(satScore)!
        }
        else
        {
            parameters["satScore"] = NSNull()
        }
        
        if (actScore != "")
        {
            parameters["actScore"] = Int(actScore)!
        }
        else
        {
            parameters["actScore"] = NSNull()
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
            completionHandler(error)
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
    
    class func saveAthleteAcademicClasses(careerId: String, classType: String, classesArray: Array<Dictionary<String,Any>>, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kSaveAthleteAcademicClassesDev, careerId, classType)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kSaveAthleteAcademicClassesDev, careerId, classType)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kSaveAthleteAcademicClassesStaging, careerId, classType)
        }
        else
        {
            urlString = String(format: kSaveAthleteAcademicClassesProduction, careerId, classType)
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
            postBodyData = try JSONSerialization.data(withJSONObject: classesArray, options: [.withoutEscapingSlashes])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(error)
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
                        else if (httpResponse.statusCode == 400)
                        {
                            // Data input error
                            print("Status == 400")
                            
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
                        }
                        else
                        {
                            print("Status != 200 or 400")
                            
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
    
    class func updateAthleteMeasurements(careerId: String, heightFeet: String, heightInches: String, weight: String, wingspanFeet: String, wingspanInches: String, standingReachFeet: String, standingReachInches: String, dominantHand: String, dominantFoot: String, benchPress: String, squat: String, deadlift: String, shuttle: String, fortyYard: String, verticalJump: String, broadJumpFeet: String, broadJumpInches: String, completionHandler: @escaping (_ result: Dictionary<String,Any>?, _ error: Error?) -> Void)
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
        
        if (heightFeet != "")
        {
            parameters["heightFeet"] = Int(heightFeet)!
        }
        else
        {
            parameters["heightFeet"] = NSNull()
        }
        
        if (heightInches != "")
        {
            parameters["heightInches"] = Int(heightInches)!
        }
        else
        {
            parameters["heightInches"] = NSNull()
        }
        
        if (weight != "")
        {
            parameters["weight"] = Int(weight)!
        }
        else
        {
            parameters["weight"] = NSNull()
        }
        
        if (wingspanFeet != "")
        {
            parameters["wingspanFeet"] = Int(wingspanFeet)!
        }
        else
        {
            parameters["wingspanFeet"] = NSNull()
        }
        
        if (wingspanInches != "")
        {
            parameters["wingspanInches"] = Int(wingspanInches)!
        }
        else
        {
            parameters["wingspanInches"] = NSNull()
        }
        
        if (standingReachFeet != "")
        {
            parameters["standingReachFeet"] = Int(standingReachFeet)!
        }
        else
        {
            parameters["standingReachFeet"] = NSNull()
        }
        
        if (standingReachInches != "")
        {
            parameters["standingReachInches"] = Int(standingReachInches)!
        }
        else
        {
            parameters["standingReachInches"] = NSNull()
        }
        
        if (dominantHand != "")
        {
            parameters["dominantHand"] = dominantHand
        }
        else
        {
            parameters["dominantHand"] = NSNull()
        }
        
        if (dominantFoot != "")
        {
            parameters["dominantFoot"] = dominantFoot
        }
        else
        {
            parameters["dominantFoot"] = NSNull()
        }
        
        if (benchPress != "")
        {
            parameters["benchPress"] = Int(benchPress)!
        }
        else
        {
            parameters["benchPress"] = NSNull()
        }
        
        if (squat != "")
        {
            parameters["squat"] = Int(squat)!
        }
        else
        {
            parameters["squat"] = NSNull()
        }
        
        if (deadlift != "")
        {
            parameters["deadlift"] = Int(deadlift)!
        }
        else
        {
            parameters["deadlift"] = NSNull()
        }
        
        if (shuttle != "")
        {
            parameters["shuttleRunTime"] = Double(shuttle)!
        }
        else
        {
            parameters["shuttleRunTime"] = NSNull()
        }
        
        if (fortyYard != "")
        {
            // The patch misspelled this property!
            parameters["fourtyYardDashTime"] = Double(fortyYard)!
        }
        else
        {
            parameters["fourtyYardDashTime"] = NSNull()
        }
        
        if (verticalJump != "")
        {
            parameters["verticalJump"] = Int(verticalJump)!
        }
        else
        {
            parameters["verticalJump"] = NSNull()
        }
        
        if (broadJumpFeet != "")
        {
            parameters["broadJumpFeet"] = Int(broadJumpFeet)!
        }
        else
        {
            parameters["broadJumpFeet"] = NSNull()
        }
        
        if (broadJumpInches != "")
        {
            parameters["broadJumpInches"] = Int(broadJumpInches)!
        }
        else
        {
            parameters["broadJumpInches"] = NSNull()
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
    
    class func addAthleteAchievementsAwards(careerId: String, title: String, description: String, dateString: String, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kAddAthleteAchievementsAwardsDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kAddAthleteAchievementsAwardsDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kAddAthleteAchievementsAwardsStaging, careerId)
        }
        else
        {
            urlString = String(format: kAddAthleteAchievementsAwardsProduction, careerId)
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
        
        let postObj = ["careerId": careerId, "title": title, "description": description, "achievedon": dateString]
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: postObj, options: [.withoutEscapingSlashes])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(error)
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
                        else if (httpResponse.statusCode == 400)
                        {
                            // Data input error
                            print("Status == 400")
                            
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
                        }
                        else
                        {
                            print("Status != 200 or 400")
                            
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
    
    class func updateAthleteAchievementsAwards(careerId: String, title: String, description: String, dateString: String, awardId: String, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kUpdateOrDeleteAthleteAchievementsAwardsDev, careerId, awardId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kUpdateOrDeleteAthleteAchievementsAwardsDev, careerId, awardId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kUpdateOrDeleteAthleteAchievementsAwardsStaging, careerId, awardId)
        }
        else
        {
            urlString = String(format: kUpdateOrDeleteAthleteAchievementsAwardsProduction, careerId, awardId)
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
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
        var parameters = [:] as Dictionary<String,Any>
        
        parameters["title"] = title
        parameters["achievedOn"] = dateString
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
            completionHandler(error)
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
                        else if (httpResponse.statusCode == 400)
                        {
                            // Data input error
                            print("Status == 400")
                            
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
                        }
                        else
                        {
                            print("Status != 200 or 400")
                            
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
    
    class func deleteAthleteAchievementsAwards(careerId: String, awardId: String, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kUpdateOrDeleteAthleteAchievementsAwardsDev, careerId, awardId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kUpdateOrDeleteAthleteAchievementsAwardsDev, careerId, awardId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kUpdateOrDeleteAthleteAchievementsAwardsStaging, careerId, awardId)
        }
        else
        {
            urlString = String(format: kUpdateOrDeleteAthleteAchievementsAwardsProduction, careerId, awardId)
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
                        else if (httpResponse.statusCode == 400)
                        {
                            // Data input error
                            print("Status == 400")
                            
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
                        }
                        else
                        {
                            print("Status != 200 or 400")
                            
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
    
    class func addAthleteExtracurricular(careerId: String, title: String, description: String, role: String, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kAddAthleteExtracurricularDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kAddAthleteExtracurricularDev, careerId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kAddAthleteExtracurricularStaging, careerId)
        }
        else
        {
            urlString = String(format: kAddAthleteExtracurricularProduction, careerId)
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
        
        let postObj = ["careerId": careerId, "activity": title, "description": description, "role": role]
        
        var postBodyData: Data? = nil
        do {
            postBodyData = try JSONSerialization.data(withJSONObject: postObj, options: [.withoutEscapingSlashes])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(error)
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
                        else if (httpResponse.statusCode == 400)
                        {
                            // Data input error
                            print("Status == 400")
                            
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
                        }
                        else
                        {
                            print("Status != 200 or 400")
                            
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
    
    class func updateAthleteExtracurricular(careerId: String, title: String, description: String, role: String, extracurricularId: String, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kUpdateOrDeleteAthleteExtracurricularDev, careerId, extracurricularId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kUpdateOrDeleteAthleteExtracurricularDev, careerId, extracurricularId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kUpdateOrDeleteAthleteExtracurricularStaging, careerId, extracurricularId)
        }
        else
        {
            urlString = String(format: kUpdateOrDeleteAthleteExtracurricularProduction, careerId, extracurricularId)
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
        urlRequest.addValue("MaxprepsApp_IOS", forHTTPHeaderField: "mp-sources-page-source")
        
        var parameters = [:] as Dictionary<String,Any>
        
        parameters["activity"] = title
        parameters["role"] = role
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
            completionHandler(error)
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
                        else if (httpResponse.statusCode == 400)
                        {
                            // Data input error
                            print("Status == 400")
                            
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
                        }
                        else
                        {
                            print("Status != 200 or 400")
                            
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
    
    class func deleteAthleteExtracurricular(careerId: String, extracurricularId: String, completionHandler: @escaping (_ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: kUpdateOrDeleteAthleteExtracurricularDev, careerId, extracurricularId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: kUpdateOrDeleteAthleteExtracurricularDev, careerId, extracurricularId)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: kUpdateOrDeleteAthleteExtracurricularStaging, careerId, extracurricularId)
        }
        else
        {
            urlString = String(format: kUpdateOrDeleteAthleteExtracurricularProduction, careerId, extracurricularId)
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
                        else if (httpResponse.statusCode == 400)
                        {
                            // Data input error
                            print("Status == 400")
                            
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
                        }
                        else
                        {
                            print("Status != 200 or 400")
                            
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
}
