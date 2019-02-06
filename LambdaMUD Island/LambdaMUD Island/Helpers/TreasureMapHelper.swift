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
    
    
    
    static func getPath(from start: Int = UserDefaults.standard.integer(forKey: TreasureMapHelper.currentRoomIDKey), to dest: Int, _ queue: [(roomID: Int, path: [(dir: String, room: Int)])] = [], _ visited: Set<Int> = [], _ path: [(dir: String, room: Int)] = []) -> [(dir: String, room: Int)] {
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
    
    
    
    func getRandomTreasure(s: [Int] = [], v: Set<Int> = [], completion: @escaping (_ cooldown: TimeInterval?, _ goToStore: Bool) -> Void) {
        
        var stack = s
        var visited = v
        
        var map = UserDefaults.standard.value(forKey: TreasureMapHelper.mapKey) as? [String: [String: Any]] ?? TreasureMapHelper.startingMap
        let currentRoomID = UserDefaults.standard.value(forKey: TreasureMapHelper.currentRoomIDKey) as? Int ?? 0
        
        let currentRoom = map[String(currentRoomID)] ?? map["0"]!
        let adjacentRooms = currentRoom["exits"] as? [String: Any] ?? [:]
        
        for (_, id) in adjacentRooms {
            guard let id = id as? Int else { fatalError() }
            if !visited.contains(id) {
                stack.append(id)
            }
        }
        
        if stack.count > 0 {
            let nextRoomID = stack.removeLast()
            let path = TreasureMapHelper.getPath(to: nextRoomID)
            visited.insert(nextRoomID)
            TreasureMapHelper.travelTo(path: path) { status in
                guard let status = status else {
                    completion(nil, false)
                    return
                }
                
                if status.items.count > 0 {
                    var treasures: [String] = []
                    for item in status.items {
                        if item.contains("treasure") {
                            treasures.append(item)
                        } else {
                            print("Found something new!!!!!")
                        }
                    }
                    if treasures.count > 0 {
                        self.takeTreasure(count: treasures.count) { goToStore, inventory in
                            if !goToStore {
                                self.getRandomTreasure(s: stack, v: visited, completion: completion)
                            } else {
                                let path = TreasureMapHelper.getPath(from: status.roomID, to: 1)
                                TreasureMapHelper.travelTo(path: path) { _ in
                                    var count = 0
                                    for item in inventory {
                                        if item.contains("treasure") {
                                            count += 1
                                        }
                                    }
                                    self.sell(count: count) {
                                        self.getRandomTreasure(completion: completion)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    self.getRandomTreasure(s: stack, v: visited, completion: completion)
                }
            }
        }
    }
    
    
    func sell(count: Int, completion: @escaping () -> Void) {
        if count > 0 {
            APIHelper.shared.sell("treasure", isConfirming: true) { error, status in
                let start = Date()
                guard let status = status else { fatalError("Ahhhhh") }
                print("Sold treasure!")
                let timePassed = 0 - start.timeIntervalSinceNow
                let waitTime = status.cooldown > timePassed ? status.cooldown - timePassed : 0.0
                DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
                    self.sell(count: count - 1, completion: completion)
                }
            }
        } else {
            completion()
        }
    }
    
    func takeTreasure(count: Int, inv: [String] = [], completion: @escaping (_ goToStore: Bool, _ inventory: [String]) -> Void) {
        var inventory = inv
        if count > 0 {
            APIHelper.shared.handleTreasure() { error, status in
                let start = Date()
                guard let status = status else { fatalError("No status returned or whatever") }
                print("Picked up treasure")
                let timePassed = 0 - start.timeIntervalSinceNow
                let waitTime = status.cooldown > timePassed ? status.cooldown - timePassed : 0.0
                DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
                    APIHelper.shared.getStatus() { (error, playerStatus) in
                        guard let playerStatus = playerStatus else { fatalError() }
                        inventory = playerStatus.inventory
                        print("encumbrance/strength: \(playerStatus.encumbrance)/\(playerStatus.strength)")
                        if playerStatus.encumbrance < playerStatus.strength - 1 {
                            self.takeTreasure(count: count - 1, inv: inventory, completion: completion)
                        } else {
                            completion(true, inventory)
                        }
                    }
                }
            }
        } else {
            completion(false, inventory)
        }
    }
    
    
    static func travelTo(path: [(dir: String, room: Int)], s: AdventureStatus? = nil, completion: @escaping (AdventureStatus?) -> Void = { _ in }) {
        var status = s
        if path.count > 0 {
            var p = path
            let nextMove = p.removeFirst()
            APIHelper.shared.travel(nextMove.dir, nextRoomID: nextMove.room) { (error, advStatus) in
                let start = Date()
                if let _ = error, status == nil {
                    p.insert(nextMove, at: 0)
                    print("ERRORRRRRRR")
                }
                guard let advStatus = advStatus else { fatalError() }
                status = advStatus
                UserDefaults.standard.set(advStatus.roomID, forKey: TreasureMapHelper.currentRoomIDKey)
                print("Traveled to room \(advStatus.roomID)")
                let timePassed = 0 - start.timeIntervalSinceNow
                let waitTime = advStatus.cooldown > timePassed ? advStatus.cooldown - timePassed : 0.0
                DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
                    self.travelTo(path: p, s: status, completion: completion)
                }
            }
        } else {
            completion(status)
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
