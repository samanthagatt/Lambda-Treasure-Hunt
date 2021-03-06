//
//  APIHelper.swift
//  LambdaMUD Island
//
//  Created by Samantha Gatt on 2/2/19.
//  Copyright © 2019 Samantha Gatt. All rights reserved.
//

import Foundation

class APIHelper {
    
    // MARK: - Properties
    
    /// Shared instance of APIHelper
    static let shared = APIHelper()
    
    /// Base URL for all network requests
    private static let baseURL = URL(string: "https://lambda-treasure-hunt.herokuapp.com/api/adv/")!
    
    
    // MARK: - Network requests
    
    /// Attempts to walk in a specified direction
    func walk(_ dir: String, nextRoomID: Int? = nil, completion: @escaping (_ error: Error?, _ status: AdventureStatus?) -> Void) {
        
        // MARK: URL request set up
        let url = APIHelper.baseURL.appendingPathComponent("move/")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(authToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        var bodyDict = ["direction": dir]
        if let nextRoomID = nextRoomID {
            bodyDict["next_room_id"] = "\(nextRoomID)"
        }
        
        // MARK: Body json encoding
        do {
            let bodyData = try JSONEncoder().encode(bodyDict)
            request.httpBody = bodyData
        } catch {
            NSLog("Error encoding body data: \(error)")
            completion(error, nil)
            return
        }
        
        // MARK: Network request
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            // MARK: Error handling
            if let error = error {
                NSLog("An error occurred trying to travel: \(error)")
                completion(error, nil)
                return
            }
            guard let data = data else {
                NSLog("An error occurred trying to travel: No data was returned")
                completion(NSError(), nil)
                return
            }
            
            // MARK: Data decoding
            do {
                let adventureStatus = try JSONDecoder().decode(AdventureStatus.self, from: data)
                NotificationCenter.default.post(name: .adventureUpdate, object: nil, userInfo: adventureStatus.asDictionary())
                completion(nil, adventureStatus)
                return
            } catch {
                NSLog("An error occurred trying to travel: \(error)")
                completion(error, nil)
                return
            }
            }.resume()
    }
    
    /// Attempts to fly in a specified direction
    func fly(_ dir: String, nextRoomID: Int? = nil, completion: @escaping (_ error: Error?, _ status: AdventureStatus?) -> Void) {
        
        // MARK: URL request set up
        let url = APIHelper.baseURL.appendingPathComponent("fly/")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(authToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        var bodyDict = ["direction": dir]
        if let nextRoomID = nextRoomID {
            bodyDict["next_room_id"] = "\(nextRoomID)"
        }
        
        // MARK: Body json encoding
        do {
            let bodyData = try JSONEncoder().encode(bodyDict)
            request.httpBody = bodyData
        } catch {
            NSLog("Error encoding body data: \(error)")
            completion(error, nil)
            return
        }
        
        // MARK: Network request
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            // MARK: Error handling
            if let error = error {
                NSLog("An error occurred trying to travel: \(error)")
                completion(error, nil)
                return
            }
            guard let data = data else {
                NSLog("An error occurred trying to travel: No data was returned")
                completion(NSError(), nil)
                return
            }
            
            // MARK: Data decoding
            do {
                let adventureStatus = try JSONDecoder().decode(AdventureStatus.self, from: data)
                NotificationCenter.default.post(name: .adventureUpdate, object: nil, userInfo: adventureStatus.asDictionary())
                completion(nil, adventureStatus)
                return
            } catch {
                NSLog("An error occurred trying to travel: \(error)")
                completion(error, nil)
                return
            }
        }.resume()
    }
    
    func dash(_ dir: String, numRooms: Int, nextRoomIDs: String, completion: @escaping (_ error: Error?, _ status: AdventureStatus?) -> Void) {
        
        // MARK: URL request set up
        let url = APIHelper.baseURL.appendingPathComponent("dash/")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(authToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let bodyDict = ["direction": dir, "num_rooms": String(numRooms), "next_room_ids": nextRoomIDs]
        
        // MARK: Body json encoding
        do {
            let bodyData = try JSONEncoder().encode(bodyDict)
            print(String(data: bodyData, encoding: .utf8) ?? "noData")
            request.httpBody = bodyData
        } catch {
            NSLog("Error encoding body data: \(error)")
            completion(error, nil)
            return
        }
        
        // MARK: Network request
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            // MARK: Error handling
            if let error = error {
                NSLog("An error occurred trying to travel: \(error)")
                completion(error, nil)
                return
            }
            guard let data = data else {
                NSLog("An error occurred trying to travel: No data was returned")
                completion(NSError(), nil)
                return
            }
            
            // MARK: Data decoding
            do {
                let adventureStatus = try JSONDecoder().decode(AdventureStatus.self, from: data)
                NotificationCenter.default.post(name: .adventureUpdate, object: nil, userInfo: adventureStatus.asDictionary())
                completion(nil, adventureStatus)
                return
            } catch {
                NSLog("An error occurred trying to travel: \(error)")
                completion(error, nil)
                return
            }
        }.resume()
    }
    
    
    
    /// Checks user status
    func getStatus(completion: @escaping (_ error: Error?, _ status: UserStatus?) -> Void) {
        
        // MARK: URL request set up
        let url = APIHelper.baseURL.appendingPathComponent("status/")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(authToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // MARK: Network request
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            // MARK: Error handling
            if let error = error {
                NSLog("An error occurred trying to check status: \(error)")
                completion(error, nil)
                return
            }
            guard let data = data else {
                NSLog("An error occurred trying to check status: No data was returned")
                completion(NSError(), nil)
                return
            }
            
            // MARK: Data decoding
            do {
                let userStatus = try JSONDecoder().decode(UserStatus.self, from: data)
                TreasureMapHelper.isEncumbered = userStatus.encumbrance >= userStatus.strength ? true : false
                NotificationCenter.default.post(name: .userUpdate, object: nil, userInfo: userStatus.asDictionary())
                completion(nil, userStatus)
                return
            } catch {
                NSLog("An error occurred trying to check status: \(error)")
                completion(error, nil)
                return
            }
        }.resume()
    }
    
    /// Picks up or drops specified treasure
    func handleTreasure(_ treasure: String = "treasure", isDropping: Bool = false, completion: @escaping (_ error: Error?, _ status: AdventureStatus?) -> Void) {
        
        // MARK: URL request set up
        let url: URL
        if isDropping {
            url = APIHelper.baseURL.appendingPathComponent("drop/")
        } else {
            url = APIHelper.baseURL.appendingPathComponent("take/")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(authToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let bodyDict = ["name": treasure]

        // MARK: Body json encoding
        do {
            let bodyData = try JSONEncoder().encode(bodyDict)
            request.httpBody = bodyData
        } catch {
            NSLog("Error encoding body data: \(error)")
            completion(error, nil)
            return
        }
        
        // MARK: Network request
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            // MARK: Error handling
            if let error = error {
                NSLog("An error occurred trying to \(isDropping ? "drop" : "take") '\(treasure)': \(error)")
                completion(error, nil)
                return
            }
            guard let data = data else {
                NSLog("")
                completion(NSError(), nil)
                return
            }
            
            // MARK: Data decoding
            do {
                let adventureStatus = try JSONDecoder().decode(AdventureStatus.self, from: data)
                NotificationCenter.default.post(name: .adventureUpdate, object: nil, userInfo: adventureStatus.asDictionary())
                completion(nil, adventureStatus)
                return
            } catch {
                NSLog("An error occurred trying to check status: \(error)")
                completion(error, nil)
                return
            }
        }.resume()
    }
    
    /// Sells a specified treasure
    func sell(_ treasure: String, isConfirming: Bool = false, completion: @escaping (_ error: Error?, _ status: AdventureStatus?) -> Void) {
     
        // MARK: URL request set up
        let url = APIHelper.baseURL.appendingPathComponent("sell/")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(authToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        var bodyDict = ["name": treasure]
        if isConfirming {
            bodyDict["confirm"] = "yes"
        }
        
        // MARK: Body json encoding
        do {
            let bodyData = try JSONEncoder().encode(bodyDict)
            request.httpBody = bodyData
        } catch {
            NSLog("Error encoding body data: \(error)")
            completion(error, nil)
            return
        }
        
        // MARK: Network request
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            // MARK: Error handling
            if let error = error {
                NSLog("An error occurred trying to sell '\(treasure)': \(error)")
                completion(error, nil)
                return
            }
            guard let data = data else {
                NSLog("An error occurred trying to sell '\(treasure)': No data was returned")
                completion(NSError(), nil)
                return
            }
            
            // MARK: Data decoding
            do {
                let adventureStatus = try JSONDecoder().decode(AdventureStatus.self, from: data)
                NotificationCenter.default.post(name: .adventureUpdate, object: nil, userInfo: adventureStatus.asDictionary())
                completion(nil, adventureStatus)
                return
            } catch {
                NSLog("An error occurred trying to sell '\(treasure)': \(error)")
                completion(error, nil)
                return
            }
        }.resume()
    }
    
    
    func getInit(completion: @escaping (Error?, AdventureStatus?) -> Void) {
        // MARK: URL request set up
        let url = APIHelper.baseURL.appendingPathComponent("init/")
        var request = URLRequest(url: url)
        request.addValue(authToken, forHTTPHeaderField: "Authorization")
        
        // MARK: Network request
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            // MARK: Error handling
            if let error = error {
                NSLog("An error occurred trying to get init: \(error)")
                completion(error, nil)
                return
            }
            guard let data = data else {
                NSLog("An error occurred trying to get init: No data was returned")
                completion(NSError(), nil)
                return
            }
            
            // MARK: Data decoding
            do {
                let adventureStatus = try JSONDecoder().decode(AdventureStatus.self, from: data)
                NotificationCenter.default.post(name: .adventureUpdate, object: nil, userInfo: adventureStatus.asDictionary())
                completion(nil, adventureStatus)
                return
            } catch {
                NSLog("An error occurred trying to decode get init AdventureStatus: \(error)")
                completion(error, nil)
                return
            }
        }.resume()
    }
}
