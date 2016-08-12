//
//  User.swift
//  MCTest
//
//  Created by Itai Steinherz on 20/07/2016.
//  Copyright © 2016 StarShell. All rights reserved.
//

import Foundation
import UIKit

class User: CustomStringConvertible, CustomDebugStringConvertible {
    
    // MARK: - Variable initialization
    
    var nickname = ""
    var UUID = ""
    var passphrase = ""
    
    // MARK: - CustomStringConvertible and CustomDebugStringConvertible
    
    var description: String {
        return "<User: nickname = \(nickname) UUID = \(UUID) passphrase = \(passphrase)>"
    }
    
    var debugDescription: String {
        return "<User: nickname = \(nickname) UUID = \(UUID) passphrase = \(passphrase)>"
    }
    
    // MARK: - Initializors
    
    init(nickname: String) { // Initializor for creation of user with given nickname (The rest is generated by the following code)
        self.nickname = nickname
        UUID = "\(UIDevice.currentDevice().name)-\(NSUUID().UUIDString)"
        passphrase = NSUUID().UUIDString
    }
    
    init(nickname: String, UUID: String, passphrase: String) { // Initializor for creation of user with given nickname, UUID and passphrase
        self.nickname = nickname
        self.UUID = UUID
        self.passphrase = passphrase
    }
    
    // MARK: - Object functions
    
    func serialize() -> [String: String] {
        return [
            "nickname": self.nickname,
            "UUID": self.UUID,
            "passphrase": self.passphrase
        ]
    }
    
}