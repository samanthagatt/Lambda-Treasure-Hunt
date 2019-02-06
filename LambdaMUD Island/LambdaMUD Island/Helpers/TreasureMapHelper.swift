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
    static let mapKey = "treasureMap"
    /// Key for the user's current room id in UserDefaults
    static let currentRoomIDKey = "currentRoomID"
    static let pathKey = "traversalPath"
    
    /// Dict of opposite cardinal directions
    static let oppositeDir = ["n": "s", "s": "n", "e": "w", "w": "e"]
    
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
                
                completion(status.cooldown)
            }
        } else {
            if stack.count > 0 && backlog.count > 0 {
                let dir = stack.removeLast()
                let oppositeDir = TreasureMapHelper.oppositeDir[dir] ?? "s"
                let futureID = backlog.removeLast()
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
                    
                    completion(status.cooldown)
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
        var exits = roomDict["exits"] as? [String: Any] ?? [:]
        exits[oppositeDir] = startID
        roomDict["exits"] = exits
        
        exits = map[String(startID)]?["exits"] as? [String: Any] ?? [:]
        exits[dir] = status.roomID
        map[String(startID)]?["exits"] = exits
        
        map[String(status.roomID)] = roomDict
        UserDefaults.standard.set(map, forKey: TreasureMapHelper.mapKey)
    }
    
    
    
    static func getPath(from start: Int, to dest: Int, _ queue: [(roomID: Int, path: [(dir: String, room: Int)])] = [], _ visited: Set<Int> = [], _ path: [(dir: String, room: Int)] = []) -> [(dir: String, room: Int)] {
        var q = queue
        var v = visited
        v.insert(start)
        let map = TreasureMapHelper.shared.getMap()
        let exits = map[String(start)]?["exits"] as? [String: Any]
        for (dir, id) in exits! {
            guard let id = id as? Int else { continue }
            var p = path
            p.append((dir: dir, room: id))
            if id == dest {
                return p
            }
            if !v.contains(Int(id)) {
                q.append((roomID: id, path: p))
            }
        }
        if q.count > 0 {
            let nextRoom = q.removeFirst()
            return TreasureMapHelper.getPath(from: nextRoom.roomID, to: dest, q, v, nextRoom.path)
        } else {
            print("")
        }
        return []
    }
    
    
    
    func getRandomTreasure(completion: @escaping (_ cooldown: TimeInterval?, _ goToStore: Bool) -> Void) {
        
        var map = UserDefaults.standard.value(forKey: TreasureMapHelper.mapKey) as? [String: [String: Any]] ?? TreasureMapHelper.startingMap
        let currentRoomID = UserDefaults.standard.value(forKey: TreasureMapHelper.currentRoomIDKey) as? Int ?? 0
        
        let currentRoom = map[String(currentRoomID)] ?? map["0"]!
        let adjacentRooms = currentRoom["exits"] as? [String: Any] ?? [:]
    
        guard let random = adjacentRooms.randomElement() else { return }
        let value = random.value as? Int
        
        APIHelper.shared.travel(random.key, nextRoomID: value) { (_, status) in
            let startTime = Date()
            
            guard let status = status else {
                completion(nil, false)
                return
            }
            
            print("Traveled to room \(status.roomID)")
            
            UserDefaults.standard.set(status.roomID, forKey: TreasureMapHelper.currentRoomIDKey)
            
            if status.items.count > 0 {
                let bestTreasures = self.pickBestTreasures(status.items)
                
                if bestTreasures.count > 0 {
                    var bestTreasure = bestTreasures[0]
                    let timeSince = Date().timeIntervalSince(startTime)
                    let timeRemaining = status.cooldown > timeSince ? status.cooldown - timeSince : 0.0
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + timeRemaining) {
                        APIHelper.shared.handleTreasure(bestTreasure.name) { (error, status) in
                            let startTime = Date()
                            
                            guard let status = status else {
                                completion(nil, false)
                                return
                            }
                            
                            print(status.messages)
                        }
                    }
                }
            } else {
                self.getRandomTreasure(completion: completion)
            }
       
            completion(status.cooldown, false)
        }
    }
    
    private func pickBestTreasures(_ array: [String]) -> [(name: String, weight: Int)] {
        var typesOfItems: [String: Int] = [:]
        for item in array {
            var itemCount = typesOfItems[item] ?? 0
            itemCount += 1
            typesOfItems[item] = itemCount
        }
        var bestTreasures: [(name: String, weight: Int)] = []
        if let _ = typesOfItems["sparkling treasure"] {
            bestTreasures.append(("sparkling treasure", 1))
        }
        if let _ = typesOfItems["brilliant treasure"] {
            bestTreasures.append(("brilliant treasure", 2))
        }
        if let _ = typesOfItems["dazzling treasure"] {
            bestTreasures.append(("dazzling treasure", 2))
        }
        if let _ = typesOfItems["spectacular treasure"] {
            bestTreasures.append(("spectacular treasure", 3))
        }
        if let _ = typesOfItems["amazing treasure"] {
            bestTreasures.append(("amazing treasure", 3))
        }
        if let _ = typesOfItems["great treasure"] {
            bestTreasures.append(("great treasure", 4))
        }
        if let _ = typesOfItems["shiny treasure"] {
            bestTreasures.append(("shiny treasure", 4))
        }
        if let _ = typesOfItems["small treasure"] {
            bestTreasures.append(("small treasure", 5))
        }
        if let _ = typesOfItems["tiny treasure"] {
            bestTreasures.append(("tiny treasure", 5))
        }
        
        return bestTreasures
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
                "w": "?"
            ]
        ]
    ]
    static let pathSoFar = [""]
}
