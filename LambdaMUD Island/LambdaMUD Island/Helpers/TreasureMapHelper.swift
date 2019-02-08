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
    static let mapKey = "treasureMap"
    /// Key for the user's current room id in UserDefaults
    static let currentRoomIDKey = "currentRoomID"
    
    /// Dict of opposite cardinal directions
    static let oppositeDir = ["n": "s", "s": "n", "e": "w", "w": "e"]
    
    static var isEncumbered = false

    private static var shouldTreasureHunt = false {
        didSet {
            if shouldTreasureHunt {
                TreasureMapHelper.treasureHunt()
            }
        }
    }

    
    // MARK: - Methods
    
    static func getMap() -> [String: [String: Any]]{
        return UserDefaults.standard.value(forKey: TreasureMapHelper.mapKey) as? [String: [String: Any]] ?? TreasureMapHelper.startingMap
    }

    static func getPath(from start: Int = UserDefaults.standard.integer(forKey: TreasureMapHelper.currentRoomIDKey), to dest: Int, _ queue: [(roomID: Int, path: [(dir: String, room: Int)])] = [], _ visited: Set<Int> = [], _ path: [(dir: String, room: Int)] = []) -> [(dir: String, room: Int)] {
        var q = queue
        var v = visited
        v.insert(start)
        let map = TreasureMapHelper.getMap()
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
    
    static func toggleTreasureHunting() -> Bool {
        TreasureMapHelper.shouldTreasureHunt = !TreasureMapHelper.shouldTreasureHunt
        return TreasureMapHelper.shouldTreasureHunt
    }
    
    private static func treasureHunt(s: [Int] = [], v: Set<Int> = [], completion: @escaping (_ cooldown: TimeInterval?, _ goToStore: Bool) -> Void = { _, _ in }) {
        if TreasureMapHelper.shouldTreasureHunt {
            var stack = s
            var visited = v
            
            var map = TreasureMapHelper.getMap()
            let currentRoomID = UserDefaults.standard.value(forKey: TreasureMapHelper.currentRoomIDKey) as? Int ?? 0
            
            let currentRoom = map[String(currentRoomID)] ?? map["0"]!
            let adjacentRooms = currentRoom["exits"] as? [String: Any] ?? [:]
            
            var rooms: [Int] = []
            for (_, id) in adjacentRooms {
                guard let id = id as? Int else { fatalError() }
                if !visited.contains(id) {
                    rooms.append(id)
                }
            }
            rooms.shuffle()
            for room in rooms {
                stack.append(room)
            }
            
            if stack.count > 0 {
                let nextRoomID = stack.removeLast()
                let path = TreasureMapHelper.getPath(to: nextRoomID)
                visited.insert(nextRoomID)
                TreasureMapHelper.travelTo(path: path, isTreasureHunting: true) { status in
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
                                    self.treasureHunt(s: stack, v: visited, completion: completion)
                                } else {
                                    let path = TreasureMapHelper.getPath(from: status.roomID, to: 1)
                                    TreasureMapHelper.travelTo(path: path, isTreasureHunting: true) { _ in
                                        var count = 0
                                        for item in inventory {
                                            if item.contains("treasure") {
                                                count += 1
                                            }
                                        }
                                        self.sell(count: count) {
                                            self.treasureHunt(s: [], v: [], completion: completion)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        self.treasureHunt(s: stack, v: visited, completion: completion)
                    }
                }
            }
        }
    }
    
    
    static func sell(count: Int, completion: @escaping () -> Void) {
        if TreasureMapHelper.shouldTreasureHunt {
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
    }
    
    static func takeTreasure(count: Int, inv: [String] = [], completion: @escaping (_ goToStore: Bool, _ inventory: [String]) -> Void) {
        if TreasureMapHelper.shouldTreasureHunt {
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
                            if playerStatus.encumbrance < playerStatus.strength - 2 {
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
    }
    
    static func travelMultiple(_ rooms: [Int]) {
        
    }
    
    static func travelTo(path: [(dir: String, room: Int)], s: AdventureStatus? = nil, isTreasureHunting: Bool = false, completion: @escaping (AdventureStatus?) -> Void = { _ in }) {
        if !isTreasureHunting || TreasureMapHelper.shouldTreasureHunt {
            var status = s
            if path.count > 0 {
                var p = path
                
                var minElev = Int.max
                
                let dashDir = path[0].dir
                var dashRooms: [Int] = []
                // want to dash or walk (not fly)
                var hasCaves = false
                // don't want to dash, want to fly unless encumbered
                var isUpHill = false
                
                for room in path {
                    let roomDict = TreasureMapHelper.getMap()[String(room.room)]
                    if room.dir == dashDir && !isEncumbered {
                        if roomDict?["terrain"] as? String == "CAVE" {
                            hasCaves = true
                        }
                        if dashRooms.count > 0 {
                            if roomDict?["elevation"] as? Int ?? 1 > minElev {
                                isUpHill = true
                            }
                        }
                        dashRooms.append(room.room)
                        minElev = roomDict?["elevation"] as? Int ?? Int.max
                    } else if isEncumbered && dashRooms.count == 0 {
                        dashRooms.append(room.room)
                        break
                    } else {
                        break
                    }
                }
                
                var nextMoves: [(dir: String, room: Int)] = []
                for _ in dashRooms {
                    nextMoves.append(p.removeFirst())
                }
                
                let internalCompletion: (Error?, AdventureStatus?) -> Void = { (error, advStatus) in
                    let start = Date()
                    if let _ = error, status == nil {
                        for move in nextMoves {
                            p.insert(move, at: 0)
                        }
                        print("ERRORRRRRRR")
                    }
                    guard let advStatus = advStatus else { fatalError() }
                    status = advStatus
                    
                    var map = TreasureMapHelper.getMap()
                    map[String(advStatus.roomID)]?["title"] = advStatus.title
                    map[String(advStatus.roomID)]?["roomDescription"] = advStatus.roomDescription
                    map[String(advStatus.roomID)]?["coordinates"] = advStatus.coordinates
                    map[String(advStatus.roomID)]?["elevation"] = advStatus.elevation
                    map[String(advStatus.roomID)]?["terrain"] = advStatus.terrain
                    
                    let dirs = map[String(advStatus.roomID)]?["exits"] as? [String: Int]
                    let dirsArray = dirs?.keys
                    for dir in advStatus.exits {
                        let bool = dirsArray?.contains(dir) ?? false
                        if !bool {
                            print("Go explore \(dir)!")
                        }
                    }
                    
                    UserDefaults.standard.set(map, forKey: TreasureMapHelper.mapKey)
                    
                    
                    UserDefaults.standard.set(advStatus.roomID, forKey: TreasureMapHelper.currentRoomIDKey)
                    print("Traveled to room \(advStatus.roomID)")
                    let timePassed = 0 - start.timeIntervalSinceNow
                    let waitTime = advStatus.cooldown > timePassed ? advStatus.cooldown - timePassed : 0.0
                    DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
                        self.travelTo(path: p, s: status, isTreasureHunting: isTreasureHunting, completion: completion)
                    }
                }
                
                // always walk if encumbered (unless a trap but we'll get to that later)
                if isEncumbered {
                    APIHelper.shared.walk(nextMoves[0].dir, nextRoomID: nextMoves[0].room, completion: internalCompletion)
                } else {
                    // always dash if more than one (unless encumbered - above, or isUpHill)
                    if dashRooms.count > 1 && !isUpHill {
                        let numRooms = dashRooms.count
                        // could use reduce if I took a little while longer
                        var nextRoomIDs: String = ""
                        for room in dashRooms {
                            nextRoomIDs += String(room) + ","
                        }
                        nextRoomIDs.removeLast()
                        APIHelper.shared.dash(dashDir, numRooms: numRooms, nextRoomIDs: nextRoomIDs, completion: internalCompletion)
                    // if there's only one but there isn't caves we want to fly (don't care if it's uphill or downhill)
                    } else if !hasCaves {
                        APIHelper.shared.fly(nextMoves[0].dir, nextRoomID: nextMoves[0].room, completion: internalCompletion)
                    // we're in a cave so walk
                    } else {
                        APIHelper.shared.walk(nextMoves[0].dir, nextRoomID: nextMoves[0].room, completion: internalCompletion)
                    }
                }
            } else {
                completion(status)
            }
        }
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
