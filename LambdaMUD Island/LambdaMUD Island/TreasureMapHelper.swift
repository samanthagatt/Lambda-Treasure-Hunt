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
    
    /// Key for the map dict in UserDefaults
    private static let mapGraphKey = "treasureMapGraph"
    
    /// Shared instance of TreasureMapHelper
    static let shared = TreasureMapHelper()

    
    // MARK: - Methods
    
    func updateMapGraph(roomID: Int, lastRoomID: Int, directionTraveled: Direction) {
        guard var mapGraph = UserDefaults.standard.value(forKey: TreasureMapHelper.mapGraphKey) as? [Int : [String : Any]] else {
            UserDefaults.standard.set(TreasureMapHelper.startingMapGraph, forKey: TreasureMapHelper.mapGraphKey)
            return
        }
        
        if mapGraph[roomID] == nil {
            mapGraph[roomID] = ["n": "?", "e": "?", "s": "?", "w": "?"]
        }
        
        let oppositeDir = Direction.opposite(directionTraveled).rawValue
        // map[roomID] should never be nil at this point
        mapGraph[roomID]?[oppositeDir] = lastRoomID
        // map[lastRoomID] shouldn't be nil since it's already been traveled to
        mapGraph[lastRoomID]?[directionTraveled.rawValue] = roomID
    }

    func traverseAllRooms() {
        
    }
}


extension TreasureMapHelper {
    /// Starting map based off of personal exploration
    static let startingMapGraph: [Int: [String: Any]] = [
        0: [
            "n": 10,
            "s": "?",
            "e": "?",
            "w": "?",
            "coord": (60, 60)
        ],
        10: [
            "n": 19,
            "s": 0,
            "w": "?",
            "coord": (60, 61)
        ],
        19: [
            "n": "?",
            "s": 10,
            "w": "?",
            "coord": (60, 62)
        ]
    ]
}
