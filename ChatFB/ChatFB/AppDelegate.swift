//
//  AppDelegate.swift
//  ChatFB
//
//  Created by vvdn on 20/04/23.
//

import Foundation
import UIKit
import Firebase


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        if FirebaseManager.shared.auth.currentUser != nil {
            OnlineOfflineService.online(for: (FirebaseManager.shared.auth.currentUser?.uid)!, status:true){ (success) in
                print("User ==>", success)
                
            }
        }
        return true
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        if FirebaseManager.shared.auth.currentUser != nil {
            OnlineOfflineService.online(for: (FirebaseManager.shared.auth.currentUser?.uid)!, status:true){ (success) in
                
                print("User ==>", success)
                
            }
        }
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        if FirebaseManager.shared.auth.currentUser != nil {
            OnlineOfflineService.online(for: (FirebaseManager.shared.auth.currentUser?.uid)!, status:false){ (success) in
                print("User ==>", success)
            }
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if FirebaseManager.shared.auth.currentUser != nil {
            OnlineOfflineService.online(for: (FirebaseManager.shared.auth.currentUser?.uid)!, status:false){ (success) in
                print("User ==>", success)
            }
        }
    }
}

