//
//  KeychainServicesManager.swift
//  MCTest
//
//  Created by Itai Steinherz on 20/07/2016.
//  Copyright © 2016 StarShell. All rights reserved.
//

import Foundation

class KeychainServiceManager: KeychainWrapper {
    
    // MARK: - Initialization
    
    init() {
        super.init(serviceName: "mc-test")
    }
    
    // MARK: - Object functions
    
    func hasCreatedUser() -> Bool {
        if self.stringForKey(kSecAttrCreator as String) != nil {
            return true
        } else {
            return false
        }
    }
    
    func createUser(user: User) {
        let savedNickname = self.setString(user.nickname, forKey: kSecAttrCreator as String)
        let savedUUID = self.setString(user.UUID, forKey: kSecAttrGeneric as String)
        let savedPassphrase = self.setString(user.passphrase, forKey: kSecValueData as String)
        
        if savedNickname && savedUUID && savedPassphrase {
            print("Saved all items successfully")
        } else {
            print("Error saving user items")
        }
    }
    
    func getUser() -> User {
        let savedNickname = self.stringForKey(kSecAttrCreator as String)
        let savedUUID = self.stringForKey(kSecAttrGeneric as String)
        let savedPassphrase = self.stringForKey(kSecValueData as String)
        
        let user = User(nickname: savedNickname!, UUID: savedUUID!, passphrase: savedPassphrase!)
        
        return user
    }
    
}