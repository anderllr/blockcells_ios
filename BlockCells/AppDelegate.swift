//
//  AppDelegate.swift
//  BlockCells
//
//  Created by Anderson Rocha on 18/09/17.
//  Copyright © 2017 BlockCells. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseAuth
import UserNotifications


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
 //       Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.prod)
        Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        let skipChoice = UserDefaults.standard
        let skipApresentacao = skipChoice.bool(forKey:"skipApresentacao")
        
        if skipApresentacao
        {
            let mainStoryBoard: UIStoryboard = UIStoryboard(name:"Main", bundle:nil)
            
            let autenticaView: NavAutenticaViewController = mainStoryBoard.instantiateViewController(withIdentifier: "NavAutenticaViewController") as! NavAutenticaViewController
            
            window?.rootViewController = autenticaView
            
        }
        return true
    }
    


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

