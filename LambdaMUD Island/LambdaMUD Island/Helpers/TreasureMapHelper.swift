//
//  TreasureMapHelper.swift
//  LambdaMUD Island
//
//  Created by Samantha Gatt on 2/3/19.
//  Copyright © 2019 Samantha Gatt. All rights reserved.
//

import Foundation

class TreasureMapHelper {
    
    // MARK: - Properties
    
    /// Shared instance of TreasureMapHelper
    static let shared = TreasureMapHelper()
    
    /// Key for the map dict in UserDefaults
    private static let mapKey = "treasureMap"
    /// Key for the user's current room id in UserDefaults
    private static let currentRoomIDKey = "currentRoomID"
    
    /// Dict of opposite cardinal directions
    private static let oppositeDir = ["n": "s", "s": "n", "e": "w", "w": "e"]
    
    /// Stack for reverse traversal
    var stack: [String] = []
    /// Traversal path
    var path: [String] = []
    /// Sequence of roomIDs
    var backlog: [Int] = []

    
    // MARK: - Methods
    
    func getMap() -> [String: [String: Any]]{
        return UserDefaults.standard.value(forKey: TreasureMapHelper.mapKey) as? [String: [String: Any]] ?? TreasureMapHelper.startingMap
    }

    func travel(completion: @escaping (TimeInterval?) -> Void) {
        
        var map = UserDefaults.standard.value(forKey: TreasureMapHelper.mapKey) as? [String: [String: Any]] ?? TreasureMapHelper.startingMap
        let currentRoomID = UserDefaults.standard.value(forKey: TreasureMapHelper.currentRoomIDKey) as? Int ?? 0
        
        let currentRoom = map[String(currentRoomID)] ?? map["0"]!
        let adjacentRooms = currentRoom["exits"] as? [String: Any] ?? [:]
        var unexplored: [String] = []
        for (dir, id) in adjacentRooms {
            if id as? String == "?" {
                unexplored.append(dir)
            }
        }
        
        if unexplored.count > 0 {
            APIHelper.shared.travel(unexplored[0]) { (_, status) in
                guard let status = status else {
                    completion(nil)
                    return
                }
                self.updateMap(from: currentRoomID, dir: unexplored[0], status: status)
                self.path.append(unexplored[0])
                self.stack.append(unexplored[0])
                self.backlog.append(currentRoomID)
                UserDefaults.standard.set(status.roomID, forKey: TreasureMapHelper.currentRoomIDKey)
                
                // Debugging
                if self.path.count % 10 == 0 {
                    print(self.path)
                }
                print("Traveled to an unexplored room: \(status.roomID)")
                
                completion(20.0)
            }
        } else {
            if stack.count > 0 {
                let dir = stack.removeLast()
                let oppositeDir = TreasureMapHelper.oppositeDir[dir] ?? "s"
                let futureID = backlog.popLast() ?? 0
                APIHelper.shared.travel(oppositeDir, nextRoomID: futureID) { (_, status) in
                    guard let status = status, status.roomID != currentRoomID else {
                        self.stack.append(dir)
                        self.backlog.append(futureID)
                        completion(nil)
                        return
                    }
                    self.path.append(oppositeDir)
                    UserDefaults.standard.set(status.roomID, forKey: TreasureMapHelper.currentRoomIDKey)
                    
                    // Debugging
                    if self.path.count % 10 == 0 {
                        print(self.path)
                    }
                    print("Traveled backwards to room: \(status.roomID)")
                    
                    completion(10.0)
                }
            }
        }
    }
    
    private func updateMap(from startID: Int, dir: String, status: AdventureStatus) {
        var map = UserDefaults.standard.value(forKey: TreasureMapHelper.mapKey) as? [String: [String: Any]] ?? TreasureMapHelper.startingMap
        var roomDict: [String: Any]
        if let existingDict = map[String(status.roomID)] {
            roomDict = existingDict
        } else {
            var exitsDict: [String: String] = [:]
            for dir in status.exits {
                exitsDict[dir] = "?"
            }
            roomDict = [
                "roomID": status.roomID,
                "title": status.title,
                "roomDescription": status.roomDescription,
                "coordinates": status.coordinates,
                "exits": exitsDict
            ]
        }
        
        let oppositeDir = TreasureMapHelper.oppositeDir[dir] ?? "n"
        // Should never be nil
        var exits = roomDict["exits"] as? [String: String] ?? [:]
        exits[oppositeDir] = String(startID)
        roomDict["exits"] = exits
        
        exits = map[String(startID)]?["exits"] as? [String: String] ?? [:]
        exits[dir] = String(status.roomID)
        map[String(startID)]?["exits"] = exits
        
        map[String(status.roomID)] = roomDict
        UserDefaults.standard.set(map, forKey: TreasureMapHelper.mapKey)
    }
}


extension TreasureMapHelper {
    /// Starting map based off of personal exploration
    static let startingMap: [String: [String: Any]] = [
        "0": [
            "roomID": 0,
            "title": "Darkness",
            "roomDescription": "It is too dark to see anything.",
            "coord": "60,60",
            "exits": [
                "n": "?",
                "s": "?",
                "e": "?",
                "w": "1"
            ]
        ],
        "1": [
            "roomID": 1,
            "title": "Darkness",
            "roomDescription": "It is too dark to see anything.",
            "coord": "59,60",
            "exits": [
                "e": "0"
            ]
        ]
    ]
}
