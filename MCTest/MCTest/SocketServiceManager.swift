//
//  SocketServiceManager.swift
//  MCTest
//
//  Created by Itai Steinherz on 29/07/2016.
//  Copyright © 2016 StarShell. All rights reserved.
//

import Foundation

class SocketServiceManager: SocketIOClient {
    
    // MARK: - Variable initialization
    
    private var user: User
    
    private var handledEvents: [String] = Array()
    private var updateVersion = 1 // Note: Need to check if this is supposed to be declared in here or as a part of the User class
    
    // MARK: - Initialization and Deinitialization
    
    init(URL url: String, User user: User) {
        self.user = user
        super.init(socketURL: NSURL(string: url)!)
        
        self.connect() // When I add support for reconnection, I should implement the other connect() method, which lets you use a handler adter the timeout and specify a timeout, e.g: self.connect(timeoutAfter: 5) { print("Connection failed, reconnecting") self.reconnect() }
        self.on("connect") { data, ack in
            self.emit("device_connected", user.serialize())
        }
    }
    
    deinit {
        self.disconnect()
    }
    
    // MARK: - Object functions
    
    func getNicknameForUUID(UUID: String, requestHandler: (() -> Void), recieveHandler: ([String: String] -> Void)) {
        if self.status == .Connected {
            self.emit("get_nickname_for_uuid", UUID)
            requestHandler()
        } else {
            self.once("connect", callback: { data, ack in
                self.emit("get_nickname_for_uuid", UUID)
                requestHandler()
            })
        }
        
        if handledEvents.indexOf("resolved_nickname") == nil {
            self.on("resolved_nickname") { data, ack in
                recieveHandler(data[0] as! [String: String])
            }
            handledEvents.append("resolved_nickname")
        }
    }
    
    func availablePeersChanged(change: String, isAddition: Bool, availablePeers: [String]) {
        if self.status == .Connected {
            self.emit("available_peers_changed", [
                "UUID": user.UUID,
                "passphrase": user.passphrase,
                "change": change,
                "isAddition": isAddition,
                "availablePeers": availablePeers,
                "updateVersion": updateVersion])
            updateVersion += 1
        } else {
            self.once("connect", callback: { data, ack in
                self.emit("available_peers_changed", [
                    "UUID": self.user.UUID,
                    "passphrase": self.user.passphrase,
                    "change": change,
                    "isAddition": isAddition,
                    "availablePeers": availablePeers,
                    "updateVersion": self.updateVersion])
                self.updateVersion += 1
            })
        }
    }
    
}


// MARK: - Test code for debugging purposes

//    private var count = 0;
//    func updateStatus() {
//        self.emit("event", "yo")
//        print("Emitted event time \(count) in status \(self.status.stringValue())")
//        count += 1
//    }

//extension SocketIOClientStatus {
//
//    func stringValue() -> String {
//        switch self {
//        case .Connecting:
//            return "Connecting"
//        case .Connected:
//            return "Connected"
//        case .NotConnected:
//            return "Not Connected"
//        case .Disconnected:
//            return "Disconnected"
//        }
//    }
//
//}
