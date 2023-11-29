//
//  VideoUploader.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/27/22.
//

import UIKit

protocol VideoUploaderDelegate: AnyObject
{
    func videoUploaderDidFinish(statusCode: Int, error: Bool)
    func videoUploaderProgress(_ progress: Float)
}

class VideoUploader: NSObject, URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate
{
    weak var delegate: VideoUploaderDelegate!
    
    // MARK: - Video Upload Methods
    
    class func uploadTestVideo(videoData: Data, completionHandler: @escaping (_ result: Bool?, _ error: Error?) -> Void)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = String(format: "%@?uploadOnly=true", kUploadVideoHostDev)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = String(format: "%@?uploadOnly=true", kUploadVideoHostDev)
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = String(format: "%@?uploadOnly=true", kUploadVideoHostStaging)
        }
        else
        {
            urlString = String(format: "%@?uploadOnly=true", kUploadVideoHostProduction)
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
        
        let bodyPart2String = "Content-Disposition: form-data; name=\"file\"; filename=\"video.mp4\"\r\n"
        let bodyPart2Data: Data? = bodyPart2String.data(using: .utf8)
        body.append(bodyPart2Data!)
        
        let bodyPart3String = "Content-Type: video/mp4\r\n\r\n"
        let bodyPart3Data: Data? = bodyPart3String.data(using: .utf8)
        body.append(bodyPart3Data!)
        
        // Now we append the actual video data
        body.append(videoData)
        
        // Add an intermediate delimiter
        let bodyPart4String = "\r\n--" + boundary + "\r\n"
        let bodyPart4Data: Data? = bodyPart4String.data(using: .utf8)
        body.append(bodyPart4Data!)
        
        // Build the postObj dictionary
        var postObj = [:] as Dictionary<String,Any>
        postObj["title"] = "Test Title"
        postObj["description"] = "Test Description"
        postObj["uploaderUserId"] = userId
        postObj["careerIds"] = [kEmptyGuid]
        postObj["orientation"] = "Landscape"
        
        // Add the second part of the post
        var json: Data? = nil
        do {
            json = try JSONSerialization.data(withJSONObject: postObj, options: [])
        }
        catch
        {
            let errorDictionary = [NSLocalizedDescriptionKey : "JSON error"]
            let error = NSError.init(domain: kMaxPrepsAppError, code: 999, userInfo: errorDictionary)
            completionHandler(nil, error)
            return
        }
        
        let bodyPart5Data: Data? = "Content-Disposition: form-data; name=\"infoJson\"\r\n".data(using: .utf8)
        body.append(bodyPart5Data!)
        
        let bodyPart6Data: Data? = "Content-Type: application/json\r\n\r\n".data(using: .utf8)
        body.append(bodyPart6Data!)
        
        body.append(json!)
        
        let bodyPart7String = "\r\n--" + boundary + "--\r\n"
        let bodyPart7Data: Data? = bodyPart7String.data(using: .utf8)
        body.append(bodyPart7Data!)
        
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
    
    func uploadCareerVideoWithDelegate(title: String, description: String, careerIds: Array<String>, videoData: Data, orientation: String)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kUploadVideoHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kUploadVideoHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kUploadVideoHostStaging
        }
        else
        {
            urlString = kUploadVideoHostProduction
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
        
        let bodyPart2String = "Content-Disposition: form-data; name=\"file\"; filename=\"video.mp4\"\r\n"
        let bodyPart2Data: Data? = bodyPart2String.data(using: .utf8)
        body.append(bodyPart2Data!)
        
        let bodyPart3String = "Content-Type: video/mp4\r\n\r\n"
        let bodyPart3Data: Data? = bodyPart3String.data(using: .utf8)
        body.append(bodyPart3Data!)
        
        // Now we append the actual video data
        body.append(videoData)
        
        // Add an intermediate delimiter
        let bodyPart4String = "\r\n--" + boundary + "\r\n"
        let bodyPart4Data: Data? = bodyPart4String.data(using: .utf8)
        body.append(bodyPart4Data!)
        
        // Build the postObj dictionary
        var postObj = [:] as Dictionary<String,Any>
        postObj["title"] = title
        postObj["description"] = description
        postObj["uploaderUserId"] = userId
        postObj["careerIds"] = careerIds // Array of careerIds
        
        var orientationInt = 0
        if (orientation.lowercased() == "portrait")
        {
            orientationInt = 1
        }
        postObj["orientation"] = NSNumber.init(integerLiteral: orientationInt)
        
        // Add the second part of the post
        var json: Data? = nil
        do {
            json = try JSONSerialization.data(withJSONObject: postObj, options: [])
        }
        catch
        {
            return
        }
        
        let bodyPart5Data: Data? = "Content-Disposition: form-data; name=\"infoJson\"\r\n".data(using: .utf8)
        body.append(bodyPart5Data!)
        
        let bodyPart6Data: Data? = "Content-Type: application/json\r\n\r\n".data(using: .utf8)
        body.append(bodyPart6Data!)
        
        //let jsonString = "{\"uploaderUserId\":\"c3b23e5b-13ce-4d98-949c-ca41eaa31ab5\",\"title\":\"Xxxx\",\"careerIds\":[\"68824bdc-cd10-e611-bef0-a0369f3c1b4c\"],\"description\":\"Yyyy\"}"
        body.append(json!)
        
        let bodyPart7String = "\r\n--" + boundary + "--\r\n"
        let bodyPart7Data: Data? = bodyPart7String.data(using: .utf8)
        body.append(bodyPart7Data!)
        
        //let logData = String(decoding: body, as: UTF8.self)
        //print(logData)
        
        urlRequest.httpBody = body
        
        //let session = URLSession.shared
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: urlRequest)
        //let task = session.uploadTask(with: urlRequest, from: body)
        
        task.resume()
    }
    
    func uploadTeamVideoWithDelegate(title: String, description: String, careerIds: Array<String>, videoData: Data, schoolId: String, ssid: String, orientation: String)
    {
        var urlString : String
        let userId = kUserDefaults.string(forKey: kUserIdKey)!
        
        if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeBranch)
        {
            urlString = kUploadVideoHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeDev)
        {
            urlString = kUploadVideoHostDev
        }
        else if (kUserDefaults .string(forKey: kServerModeKey) == kServerModeStaging)
        {
            urlString = kUploadVideoHostStaging
        }
        else
        {
            urlString = kUploadVideoHostProduction
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
        
        let bodyPart2String = "Content-Disposition: form-data; name=\"file\"; filename=\"video.mp4\"\r\n"
        let bodyPart2Data: Data? = bodyPart2String.data(using: .utf8)
        body.append(bodyPart2Data!)
        
        let bodyPart3String = "Content-Type: video/mp4\r\n\r\n"
        let bodyPart3Data: Data? = bodyPart3String.data(using: .utf8)
        body.append(bodyPart3Data!)
        
        // Now we append the actual video data
        body.append(videoData)
        
        // Add an intermediate delimiter
        let bodyPart4String = "\r\n--" + boundary + "\r\n"
        let bodyPart4Data: Data? = bodyPart4String.data(using: .utf8)
        body.append(bodyPart4Data!)
        
        // Build the postObj dictionary
        var postObj = [:] as Dictionary<String,Any>
        postObj["title"] = title
        postObj["description"] = description
        postObj["uploaderUserId"] = userId
        postObj["careerIds"] = careerIds // Array of careerIds
        
        var orientationInt = 0
        if (orientation.lowercased() == "portrait")
        {
            orientationInt = 1
        }
        postObj["orientation"] = NSNumber.init(integerLiteral: orientationInt)
        
        let teamObj = ["teamId": schoolId, "sportSeasonId": ssid]
        postObj["teams"] = [teamObj]
        
        // Add the second part of the post
        var json: Data? = nil
        do {
            json = try JSONSerialization.data(withJSONObject: postObj, options: [])
        }
        catch
        {
            return
        }
        
        let bodyPart5Data: Data? = "Content-Disposition: form-data; name=\"infoJson\"\r\n".data(using: .utf8)
        body.append(bodyPart5Data!)
        
        let bodyPart6Data: Data? = "Content-Type: application/json\r\n\r\n".data(using: .utf8)
        body.append(bodyPart6Data!)
        
        //let jsonString = "{\"uploaderUserId\":\"c3b23e5b-13ce-4d98-949c-ca41eaa31ab5\",\"title\":\"Xxxx\",\"careerIds\":[\"68824bdc-cd10-e611-bef0-a0369f3c1b4c\"],\"description\":\"Yyyy\"}"
        body.append(json!)
        
        let bodyPart7String = "\r\n--" + boundary + "--\r\n"
        let bodyPart7Data: Data? = bodyPart7String.data(using: .utf8)
        body.append(bodyPart7Data!)
        
        //let logData = String(decoding: body, as: UTF8.self)
        //print(logData)
        
        urlRequest.httpBody = body
        
        //let session = URLSession.shared
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: urlRequest)
        //let task = session.uploadTask(with: urlRequest, from: body)
        
        task.resume()
    }
    
    // MARK: - URLSession Delegates
    
    func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError: Error?)
    {
        if (didCompleteWithError == nil)
        {
            if let httpResponse = task.response as? HTTPURLResponse
            {
                print("Response: " + task.response!.description)
            
                /*
                if (httpResponse.statusCode == 200)
                {
                    print("200")
                }
                else
                {
                    print("Not 200")
                }
                */
                self.delegate.videoUploaderDidFinish(statusCode: httpResponse.statusCode, error: false)
            }
            print("Done")
        }
        else
        {
            self.delegate.videoUploaderDidFinish(statusCode: -1, error: true)
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)
    {
        let logDataReceived = String(decoding: data, as: UTF8.self)
        print(logDataReceived)
        print("Received Data")
    }
    
    func urlSession(_: URLSession, task: URLSessionTask, didSendBodyData: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
    {
        let uploadProgress:Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        //let progressPercent = Int(uploadProgress*100)
        print("Progress: %1.2f", uploadProgress)
        self.delegate.videoUploaderProgress(uploadProgress)
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?)
    {
        print("Invalid")
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession)
    {
        print("Did Finish")
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
    {
        print("Challenge")
        //completionHandler(.cancelAuthenticationChallenge, .none)
        completionHandler(.performDefaultHandling, nil)
    }
}
