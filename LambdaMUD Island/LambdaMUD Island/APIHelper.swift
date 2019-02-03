//
//  APIHelper.swift
//  LambdaMUD Island
//
//  Created by Samantha Gatt on 2/2/19.
//  Copyright © 2019 Samantha Gatt. All rights reserved.
//

import Foundation

enum Direction: String, Decodable {
    case north = "n"
    case south = "s"
    case east = "e"
    case west = "w"
}

class APIHelper {
    
    /// Shared instance of APIHelper
    static let shared = APIHelper()
    
    /// Base URL for all network requests
    private static let baseURL = URL(string: "https://lambda-treasure-hunt.herokuapp.com/api/adv/")!
    
    /// Attempts to travel in a specified direction
    func travel(_ dir: Direction, nextRoomID: Int? = nil, completion: @escaping (_ error: Error?, _ status: AdventureStatus?) -> Void) {
        let url = APIHelper.baseURL.appendingPathComponent("move/")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(authToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        var bodyDict = ["direction": "\(dir.rawValue)"]
        if let nextRoomID = nextRoomID {
            bodyDict["next_room_id"] = "\(nextRoomID)"
        }
        
        do {
            let bodyData = try JSONEncoder().encode(bodyDict)
            request.httpBody = bodyData
        } catch {
            NSLog("Error encoding body data: \(error)")
            completion(error, nil)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
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
            
            // print(String(data: data, encoding: .utf8) ?? "data to string didn't work")
            
            do {
                let adventureStatus = try JSONDecoder().decode(AdventureStatus.self, from: data)
                completion(nil, adventureStatus)
                return
            } catch {
                NSLog("An error occurred trying to travel: Couldn't decode the user status")
                completion(error, nil)
                return
            }
        }.resume()
    }
}
