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

    
    // MARK: - Methods
    
    func updateAfterTravel(roomID: Int, lastRoomID: Int, directionTraveled: String) {
        var map = UserDefaults.standard.value(forKey: TreasureMapHelper.mapKey) as? [Int: [String: Any]] ?? TreasureMapHelper.startingMapGraph
        
        guard let _ = map[roomID] else { return }
        
        // hopefully this never fails because it'll default to .north
        let dir = Direction(rawValue: directionTraveled) ?? .north
        let oppositeDir = Direction.opposite(dir).rawValue
        // map[roomID] should never be nil at this point
        map[roomID]?[oppositeDir] = lastRoomID
        // map[lastRoomID] shouldn't be nil since it's already been traveled to
        map[lastRoomID]?[directionTraveled] = roomID
    }

    func traverseAllRooms() {
        var map = UserDefaults.standard.value(forKey: TreasureMapHelper.mapKey) as? [Int: [String: Any]] ?? TreasureMapHelper.startingMapGraph
        let currentRoomID = UserDefaults.standard.integer(forKey: TreasureMapHelper.currentRoomIDKey)
        
        let beginningRoom = map[currentRoomID] ?? map[0]!
        let adjacentRooms = beginningRoom["exits"] as? [String: Any] ?? [:]
        var unexplored: [String] = []
        for (dir, id) in adjacentRooms {
            if id as? String == "?" {
                unexplored.append(dir)
            }
        }
        
        if unexplored.count > 0 {
            APIHelper.shared.travel(unexplored[0]) { (_, status) in
                guard let status = status else { return }
                self.updateNewRoom(status)
                self.updateAfterTravel(roomID: status.roomID, lastRoomID: beginningRoom["roomID"] as! Int, directionTraveled: unexplored[0])
            }
        } else {
            // pop from a stack i haven't made yet
        }
    }
    
    private func updateNewRoom(_ status: AdventureStatus) {
        var map = UserDefaults.standard.value(forKey: TreasureMapHelper.mapKey) as? [Int: [String: Any]] ?? TreasureMapHelper.startingMapGraph
        var exitsDict: [String: Any] = [:]
        for dir in status.exits {
            exitsDict[dir] = "?"
        }
        let roomDict: [String : Any] = [
            "roomID": status.roomID,
            "title": status.title,
            "roomDescription": status.roomDescription,
            "coordinates": status.coordinates,
            "exits": exitsDict
        ]
        map[status.roomID] = roomDict
        UserDefaults.standard.set(map, forKey: TreasureMapHelper.mapKey)
    }
}


extension TreasureMapHelper {
    /// Starting map based off of personal exploration
    static let startingMapGraph: [Int: [String: Any]] = [
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
