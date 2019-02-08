//
//  AppDelegate.swift
//  LambdaMUD Island
//
//  Created by Samantha Gatt on 2/2/19.
//  Copyright © 2019 Samantha Gatt. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        APIHelper.shared.getInit { (error, status) in
            let start = Date()
            if let error = error {
                print("Error returned: \(error)")
                return
            }
            guard let status = status else {
                print("Status was nil")
                return
            }
            UserDefaults.standard.set(status.roomID, forKey: TreasureMapHelper.currentRoomIDKey)
            
            let timeSince = 0 - start.timeIntervalSinceNow
            let timeLeft = status.cooldown - timeSince
            DispatchQueue.main.asyncAfter(deadline: .now() + timeLeft, execute: {
                APIHelper.shared.getStatus(completion: { _, _ in })
            })
        }
        return true
    }
}

