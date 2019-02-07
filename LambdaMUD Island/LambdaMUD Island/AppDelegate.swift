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
            if let error = error {
                print("Error returned: \(error)")
                return
            }
            guard let status = status else {
                print("Status was nil")
                return
            }
            UserDefaults.standard.set(status.roomID, forKey: TreasureMapHelper.currentRoomIDKey)
            
            
//            let file = "mapFile.json" //this is the file. we will write to and read from it
//            
//            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//                
//                let fileURL = dir.appendingPathComponent(file)
//                
//                //reading
//                do {
//                    let data = try Data(contentsOf: fileURL)
//                    let obj = try JSONSerialization.jsonObject(with:data, options:[])
//                    if let dict = obj as? [String: [String: Any]] {
//                        UserDefaults.standard.set(dict, forKey: TreasureMapHelper.mapKey)
//                    } else {
//                        print("Oh no! dict wasn't a [String: String: [Any]]!")
//                    }
//                }
//                catch {
//                    print("Oh no!")
//                    return
//                }
//            }
        }
        
        return true
    }
}

