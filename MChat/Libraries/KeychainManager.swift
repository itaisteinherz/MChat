//
//  KeychainManager.swift
//  MChat
//
//  Created by Itai Steinherz on 12/03/2017.
//  Copyright © 2017 ItaiSt. All rights reserved.
//

import Foundation
import KeychainAccess

class KeychainManager: NSObject {
    
    // MARK: - Variable initialization

    private var keychain: Keychain
    
    // MARK: - Initialization
    
    init(service: String) {
        keychain = Keychain(service: service)
    }
    
    // MARK: - Object functions

    func saveUserToKeychain(user: User) {
        keychain["nickname"] = user.nickname
        keychain["UUID"] = user.UUID
        keychain["passphrase"] = user.passphrase
    }
    
    func changeNickname(newNickname: String) {
        keychain["nickname"] = newNickname
    }
    
    func getUserFromKeychain() -> User? {
        if let nickname = keychain["nickname"], let UUID = keychain["UUID"], let passphrase = keychain["passphrase"] {
            return User(nickname: nickname, UUID: UUID, passphrase: passphrase)
        }
        
        return nil
    }
    
    func isUserStoredInKeychain() -> Bool {
        if let UUID = keychain["UUID"], UUID != "" {
            return true
        }
        
        return false
    }
    
}
