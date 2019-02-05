//
//  UserStatus.swift
//  LambdaMUD Island
//
//  Created by Samantha Gatt on 2/3/19.
//  Copyright © 2019 Samantha Gatt. All rights reserved.
//

import Foundation

/// User status object returned when a call to API /status endpoint is made
struct UserStatus: Decodable {
    
    let name: String
    let cooldown: Double
    let encumbrance: Int
    let strength: Int
    let speed: Int
    let gold: Int
    let inventory: [String]
    let status: [String]
    let errors: [String]
    let messages: [String]
}
