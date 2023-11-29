//
//  SceneDelegate.swift
//  MPScoreboard3
//
//  Created by David Smith on 2/1/21.
//

import UIKit
import AirshipCore
import BranchSDK
import Avia

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    // MARK: - Tool Tip Update
    
    private func updateAppLaunchCount()
    {
        // App Launch Count
        if (kUserDefaults.object(forKey: kAppLaunchCountKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(integerLiteral: 0), forKey: kAppLaunchCountKey)
        }
        
        // Tool Tips
        if (kUserDefaults.object(forKey: kToolTipOneShownKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipOneShownKey)
        }
        
        if (kUserDefaults.object(forKey: kToolTipTwoShownKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipTwoShownKey)
        }
        
        if (kUserDefaults.object(forKey: kToolTipThreeShownKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipThreeShownKey)
        }
        
        if (kUserDefaults.object(forKey: kToolTipFourShownKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipFourShownKey)
        }
        
        if (kUserDefaults.object(forKey: kToolTipFiveShownKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipFiveShownKey)
        }
        
        if (kUserDefaults.object(forKey: kToolTipSixShownKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipSixShownKey)
        }
        
        if (kUserDefaults.object(forKey: kToolTipSevenShownKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipSevenShownKey)
        }
        
        if (kUserDefaults.object(forKey: kToolTipEightShownKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipEightShownKey)
        }
        
        if (kUserDefaults.object(forKey: kToolTipNineShownKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kToolTipNineShownKey)
        }
        
        if (kUserDefaults.object(forKey: kVideoUploadToolTipShownKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kVideoUploadToolTipShownKey)
        }
        
        if (kUserDefaults.object(forKey: kTeamVideoToolTipShownKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kTeamVideoToolTipShownKey)
        }
        
        if (kUserDefaults.object(forKey: kCareerVideoToolTipShownKey) == nil)
        {
            kUserDefaults.setValue(NSNumber.init(booleanLiteral: false), forKey: kCareerVideoToolTipShownKey)
        }
        
        // Increment the app launch count (if logged in)
        if (kUserDefaults.string(forKey: kUserIdKey) != kEmptyGuid)
        {
            var currentLaunchCount = kUserDefaults.object(forKey: kAppLaunchCountKey) as! Int
            if (currentLaunchCount >= 10)
            {
                currentLaunchCount = 10
            }
            else
            {
                currentLaunchCount += 1
            }
            kUserDefaults.setValue(NSNumber.init(integerLiteral: currentLaunchCount), forKey: kAppLaunchCountKey)
        }
        else
        {
            kUserDefaults.setValue(NSNumber.init(integerLiteral: 0), forKey: kAppLaunchCountKey)
        }
        
        // Notify the rest of the app that the app launched (used for choosing the correct tool tip)
        let launchCount = kUserDefaults.object(forKey: kAppLaunchCountKey) as! Int
        if (launchCount > 0)
        {
            // Skip the first app launch
            NotificationCenter.default.post(name: Notification.Name("AppActiveNotification"), object: nil)
        }
    }

    // MARK: - Basse Functions

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions)
    {
        // Calculate the top and bottom safe areas for use elsewhere in the app
        if (window!.safeAreaInsets.top > 0)
        {
            SharedData.topNotchHeight = Int(window!.safeAreaInsets.top) - kStatusBarHeight;
        }
        else
        {
            SharedData.topNotchHeight = 0;
        }
        
        SharedData.bottomSafeAreaHeight = Int(window!.safeAreaInsets.bottom)
        
        print("Top Pad: " + String(SharedData.topNotchHeight) + ", Bottom Pad: " + String( SharedData.bottomSafeAreaHeight))
        
        // Set the overall window background color so navigation looks better
        window!.backgroundColor = UIColor.mpWhiteColor()
        
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        // workaround for SceneDelegate continueUserActivity not getting called on cold start
        if let userActivity = connectionOptions.userActivities.first
        {
            BranchScene.shared().scene(scene, continue: userActivity)
        }
        else if !connectionOptions.urlContexts.isEmpty
        {
            BranchScene.shared().scene(scene, openURLContexts: connectionOptions.urlContexts)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene)
    {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        // Load the app id cookie
        MiscHelper.setAppIdCookie()
        
        // Reset the badge
        Airship.push.resetBadge()
        
        // Initialize an update the app launch count
        self.updateAppLaunchCount()
        
        // Track app launches after a little delay so the Omniture init could happen
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0)
        {
            let trackingGuid = NSUUID().uuidString
            TrackingManager.trackState(featureName: "splash", trackingGuid: trackingGuid, cData: kEmptyTrackingContextData)
        }
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
        // Get the UTC time from the server
        MiscHelper.getUTCTimeOffset()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Reset the audio
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity)
    {
        BranchScene.shared().scene(scene, continue: userActivity)
        
        /*
        // Not needed
        let latestParams = Branch.getInstance().getLatestReferringParams()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showDeepLink(parameters: latestParams!)
        */
        
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>)
    {
        BranchScene.shared().scene(scene, openURLContexts: URLContexts)
        
        /*
        let latestParams = Branch.getInstance().getLatestReferringParams()
        let canonicalUrl = latestParams!["$canonical_url"] as! String
        
        self.showWebDeepLink(urlString: canonicalUrl)
        */
        print("Done")
        
    }
}

