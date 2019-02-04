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
    private var stack: [String] = []
    /// Traversal path
    private var path: [String] = []
    /// Sequence of roomIDs
    private var backlog: [Int] = []

    
    // MARK: - Methods

    func traverseAllRooms() {
        var map = UserDefaults.standard.value(forKey: TreasureMapHelper.mapKey) as? [Int: [String: Any]] ?? TreasureMapHelper.startingMapGraph
        let currentRoomID = UserDefaults.standard.integer(forKey: TreasureMapHelper.currentRoomIDKey)
        
        let currentRoom = map[currentRoomID] ?? map[0]!
        let adjacentRooms = currentRoom["exits"] as? [String: Any] ?? [:]
        var unexplored: [String] = []
        for (dir, id) in adjacentRooms {
            if id as? String == "?" {
                unexplored.append(dir)
            }
        }
        
        if unexplored.count > 0 {
            APIHelper.shared.travel(unexplored[0]) { (_, status) in
                guard let status = status else { return }
                self.updateMap(from: currentRoomID, dir: unexplored[0], status: status)
                self.path.append(unexplored[0])
                self.stack.append(unexplored[0])
                self.backlog.append(currentRoomID)
            }
        } else {
            let dir = stack.popLast() ?? "n"
            let oppositeDir = TreasureMapHelper.oppositeDir[dir] ?? "s"
            let futureID = backlog.popLast() ?? 0
            APIHelper.shared.travel(oppositeDir, nextRoomID: futureID) { (_, status) in
                guard let status = status, status.roomID != currentRoomID else {
                    self.stack.append(dir)
                    self.backlog.append(futureID)
                    return
                }
                self.path.append(oppositeDir)
            }
        }
    }
    
    private func updateMap(from startID: Int, dir: String, status: AdventureStatus) {
        var map = UserDefaults.standard.value(forKey: TreasureMapHelper.mapKey) as? [Int: [String: Any]] ?? TreasureMapHelper.startingMapGraph
        var roomDict: [String: Any]
        if let existingDict = map[status.roomID] {
            roomDict = existingDict
        } else {
            var exitsDict: [String: Any] = [:]
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
        var exits = roomDict["exits"] as? [String: Int] ?? [:]
        exits[oppositeDir] = startID
        roomDict["exits"] = exits
        
        exits = map[startID]?["exits"] as? [String: Int] ?? [:]
        exits[dir] = status.roomID
        map[startID]?["exits"] = exits
        
        map[status.roomID] = roomDict
        UserDefaults.standard.set(map, forKey: TreasureMapHelper.mapKey)
    }
}


extension TreasureMapHelper {
    /// Starting map based off of personal exploration
    private static let startingMapGraph: [Int: [String: Any]] = [
        0: [
            "roomID": 0,
            "title": "Darkness",
            "description": "Dark",
            "coord": "60,60",
            "exits": [
                "n": 10,
                "s": "?",
                "e": "?",
                "w": "?"
            ]
        ]
    ]
}
