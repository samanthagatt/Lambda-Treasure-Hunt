//
//  AdventureStatus.swift
//  LambdaMUD Island
//
//  Created by Samantha Gatt on 2/2/19.
//  Copyright © 2019 Samantha Gatt. All rights reserved.
//

import Foundation


struct AdventureStatus: Decodable {
    
    // MARK: - Properties
    
    var roomID: Int
    var title: String
    var roomDescription: String
    var coordinates: String
    var players: [String]
    var items: [String]
    var exits: [String]
    var cooldown: Double
    var errors: [String]
    var messages: [String]
    var terrain: String
    var elevation: Int
    
    
    // MARK: - Keys for decoding
    
    enum CodingKeys: String, CodingKey {
        case roomID = "room_id"
        case title
        case roomDescription = "description"
        case coordinates
        case players
        case items
        case exits
        case cooldown
        case errors
        case messages
        case terrain
        case elevation
    }
    
    
    // MARK: - Decodable protocol
    
    init(from decoder: Decoder) throws {
                
        let container = try decoder.container(keyedBy: AdventureStatus.CodingKeys.self)
        
        let roomID = try container.decode(Int.self, forKey: .roomID)
        let title = try container.decode(String.self, forKey: .title)
        let room_description = try container.decode(String.self, forKey: .roomDescription)
        var coordinates = try container.decode(String.self, forKey: .coordinates)
        _ = coordinates.removeFirst()
        _ = coordinates.removeLast()
        let players = try container.decodeIfPresent([String].self, forKey: .players) ?? []
        let items = try container.decodeIfPresent([String].self, forKey: .items) ?? []
        let exits = try container.decode([String].self, forKey: .exits)
        let cooldown = try container.decode(Double.self, forKey: .cooldown)
        let errors = try container.decode([String].self, forKey: .errors)
        let messages = try container.decode([String].self, forKey: .messages)
        let terrain = try container.decode(String.self, forKey: .terrain)
        let elevation = try container.decode(Int.self, forKey: .elevation)
        
        self.roomID = roomID
        self.title = title
        self.roomDescription = room_description
        self.coordinates = coordinates
        self.players = players
        self.items = items
        self.exits = exits
        self.cooldown = cooldown
        self.errors = errors
        self.messages = messages
        self.terrain = terrain
        self.elevation = elevation
    }
    
    
    func asDictionary() -> [String: Any] {
        return [
            "roomID": self.roomID,
            "title": self.title,
            "roomDescription": self.roomDescription,
            "coordinates": self.coordinates,
            "players": self.players,
            "items": self.items,
            "exits": self.exits,
            "cooldown": self.cooldown,
            "errors": self.errors,
            "messages": self.messages
        ]
    }
}
