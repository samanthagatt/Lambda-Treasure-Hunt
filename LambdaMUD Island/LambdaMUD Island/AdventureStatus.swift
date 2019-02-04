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
    var coordinates: (x: Int, y: Int)
    var players: [String]
    var items: [String]
    var exits: [Direction]
    var cooldown: Float
    var errors: [String]
    var messages: [String]
    
    
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
    }
    
    
    // MARK: - Decodable protocol
    
    init(from decoder: Decoder) throws {
                
        let container = try decoder.container(keyedBy: AdventureStatus.CodingKeys.self)
        
        let roomID = try container.decode(Int.self, forKey: .roomID)
        let title = try container.decode(String.self, forKey: .title)
        let room_description = try container.decode(String.self, forKey: .roomDescription)
        let coordString = try container.decode(String.self, forKey: .coordinates)
        
        let coordArray = coordString.split(separator: ",")
        _ = coordArray.first?.dropFirst()
        _ = coordArray.last?.dropLast()
        var coordinates = (x: 0, y: 0)
        if let x = coordArray.first, let y = coordArray.last {
            coordinates.x = Int(x) ?? 0
            coordinates.y = Int(y) ?? 0
        }
        
        let players = try container.decode([String].self, forKey: .players)
        let items = try container.decode([String].self, forKey: .items)
        let exits = try container.decode([Direction].self, forKey: .exits)
        let cooldown = try container.decode(Float.self, forKey: .cooldown)
        let errors = try container.decode([String].self, forKey: .errors)
        let messages = try container.decode([String].self, forKey: .messages)
        
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
    }
    
    
    // MARK: - Example JSON
    
    /*
     json = {
         "room_id": 10,
         "title": "Room 10",
         "description": "You are standing in an empty room.",
         "coordinates": "(60,61)",
         "players": [],
         "items": [],
         "exits": ["n", "s", "w"],
         "cooldown": 60.0,
         "errors": [],
         "messages": ["You have walked north."]
     }
     */
}
