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
    private static let mapKey = "treasureMap"
    
    /// Shared instance of TreasureMapHelper
    static let shared = TreasureMapHelper()

    
    // MARK: - Methods
    
    func updateMap(roomID: Int, lastRoomID: Int, directionTraveled: Direction) {
        guard var map = UserDefaults.standard.value(forKey: TreasureMapHelper.mapKey) as? [Int : [String : Any]] else {
            UserDefaults.standard.set(TreasureMapHelper.startingMap, forKey: TreasureMapHelper.mapKey)
            return
        }
        
        if map[roomID] == nil {
            map[roomID] = ["n": "?", "e": "?", "s": "?", "w": "?"]
        }
        
        let oppositeDir = Direction.opposite(directionTraveled).rawValue
        // map[roomID] should never be nil at this point
        map[roomID]?[oppositeDir] = lastRoomID
        // map[lastRoomID] shouldn't be nil since it's already been traveled to
        map[lastRoomID]?[directionTraveled.rawValue] = roomID
    }

}


extension TreasureMapHelper {
    /// Starting map based off of personal exploration
    static let startingMap: [Int: [String: Any]] = [
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
