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
    let cooldown: Int
    let encumbrance: Int
    let strength: Int
    let speed: Int
    let gold: Int
    let inventory: [String]
    let status: [String]
    let errors: [String]
    let messages: [String]

//    var debugDescription: String {
//        return """
//        UserStatus = {
//            name: '\(name)',
//            cooldown: \(cooldown),
//            encumbrance: \(encumbrance),
//            strength: \(strength),
//            speed: \(speed),
//            gold: \(gold),
//            inventory: \(inventory),
//            status: \(status),
//            errors: \(errors),
//            messages: \(messages)
//        }
//        """
//    }
}
