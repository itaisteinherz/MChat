//
//  SocketManager.swift
//  MChat
//
//  Created by Itai Steinherz on 27/12/2016.
//  Copyright © 2016 Itai Steinherz. All rights reserved.
//

import Foundation

class SocketManager: NSObject {
    
    // MARK: - Variable initialization
    
    private var socket: SocketIOClient
    
    private var user: User
    
    private var handledEvents: [String] = Array()
    private var updateVersion = 1 // Note: Need to check if this is supposed to be declared in here or as a part of the User class
    
    // MARK: - Initialization and Deinitialization
    
    init(URL url: String, User user: User, connectionHandler: @escaping (() -> Void), successfulConnectionHandler: @escaping (() -> Void), recievedMessageHandler: @escaping (([String: String]) -> Void)) {
        self.user = user
        
        socket = SocketIOClient(socketURL: URL(string: url)!, config: [
            .secure(true)
//            .log(true)
            ])
            
        socket.connect() // When I add support for reconnection, I should implement the other connect() method, which lets you use a handler adter the timeout and specify a timeout, e.g: socket.connect(timeoutAfter: 5) { print("Connection failed, reconnecting") socket.reconnect() }
        socket.once("connect") { (data, ack) in
            connectionHandler()
        }
        
        socket.once("connect_status", callback: { (data, ack) in
            if let data = data[0] as? [String: Bool] {
                if let success = data["success"], success == true {
                    successfulConnectionHandler()
                }
            }
        })

        socket.on("receive_message", callback: { messageData, ack in
            let data = messageData[0] as! [String: String]
            recievedMessageHandler([
                "nickname": data["nickname"]!,
                "UUID": data["UUID"]!,
                "message": data["message"]!
                ])
        })
        handledEvents.append("receive_message")
    }
    
    deinit {
        socket.disconnect()
    }
    
    func connectDevice() {
        socket.emit("device_connected", user.serialize())
    }
    
    // MARK: - Object functions
    
    func getStatus() -> SocketIOClientStatus {
        return socket.status
    }
    
    func sendMessage(messageContents: String) { // TODO: Make all request handlers optional
        _runOnConnect { 
            self.socket.emit("send_message", [ // TODO: Use the user.serialize function instead of writing it manually
                "nickname": self.user.nickname,
                "UUID": self.user.UUID,
                "passphrase": self.user.passphrase,
                "message": messageContents
                ])
        }
    }

    func getConnectedPeersCount(recieveHandler: @escaping ((Int) -> Void)) {
        _runOnConnect { 
            self.socket.emit("get_connected_peers_count", self.user.serializeForAuthentication())
        }
        
        if handledEvents.index(of: "resolved_peers_count") == nil {
            socket.on("resolved_peers_count") { data, ack in
                recieveHandler(data[0] as! Int)
            }
            handledEvents.append("resolved_peers_count")
        }
    }
    
    func getConnectedPeersNicknames(peers: [String], recieveHandler: @escaping (([[String]]) -> Void)) {
        _runOnConnect { 
            self.socket.emit("get_connected_peers_nicknames", self.user.serializeForAuthentication())
            self.socket.emit("get_nicknames_of_peers", [
                "UUID": self.user.UUID,
                "passphrase": self.user.passphrase,
                "peers": peers
                ])
        }
        
        var dbData: [String]? = nil
        var directData: [String]? = nil
        
        let dbHandler = { (data: [Any], ack: SocketAckEmitter) in
            dbData = data[0] as? [String]
            
            if directData != nil {
                recieveHandler([dbData!, directData!])
            }
        }
        
        let directHandler = { (data: [Any], ack: SocketAckEmitter) in
            directData = data[0] as? [String]
            
            if dbData != nil {
                recieveHandler([dbData!, directData!])
            }
        }
        
        if handledEvents.index(of: "resolved_nicknames") == nil {
            socket.on("resolved_nicknames", callback: dbHandler)

            handledEvents.append("resolved_nicknames")
        }
        
        if handledEvents.index(of: "resolved_nicknames_of_peers") == nil {
            socket.on("resolved_nicknames_of_peers", callback: directHandler)
            handledEvents.append("resolved_nicknames_of_peers")
        }
    }
    
    func changeNickname(user: User, newNickname: String) {
        user.nickname = newNickname
        
        _runOnConnect {
            self.socket.emit("change_nickname", [
                "UUID": user.UUID,
                "passphrase": user.passphrase,
                "newNickname": newNickname
                ])
        }
    }
    
    func availablePeersChanged(change: String, isAddition: Bool, availablePeers: [String]) {
        _runOnConnect {
            self.socket.emit("available_peers_changed", [
                "UUID": self.user.UUID,
                "passphrase": self.user.passphrase,
                "change": change,
                "isAddition": isAddition,
                "fullList": availablePeers,
                "updateVersion": self.updateVersion])
            self.updateVersion += 1
        }
    }
    
    // MARK: - Private functions
    
    private func _runOnConnect(callback: @escaping (() -> Void)) {
        if socket.status == .connected {
            callback()
        } else {
            socket.once("connect", callback: { (data, ack) in
                self.socket.once("connect_status") { (data, ack) in
                    if let data = data[0] as? [String: Bool] {
                        if let success = data["success"], success == true {
                            callback()
                        }
                    }
                }
            })
        }
    }
    
}
