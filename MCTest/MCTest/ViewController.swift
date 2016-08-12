//
//  ViewController.swift
//  MCTest
//
//  Created by Itai Steinherz on 18/07/2016.
//  Copyright © 2016 StarShell. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MCServiceManagerDelegate {
    
    var wasActive = false
    
    var hadAskedForNickname: Bool = false
    
    var nickname: String?
    var user: User?
    
    @IBOutlet weak var availablePeers: UITableView!
    
    var socket: SocketServiceManager? = nil
    
    var mcService: MCServiceManager? = nil
    var peers: [String: String] = Dictionary()
    
    let keychain = KeychainServiceManager()
    
    // MARK: - Creating the user if first run or loading the user if isn't
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let hasCreatedUser = keychain.hasCreatedUser()
        
        if hasCreatedUser == false && self.hadAskedForNickname {
            user = User(nickname: self.nickname!)
            keychain.createUser(user!)
        } else if hasCreatedUser {
            user = keychain.getUser()
        }
        
        if let user = user where (self.hadAskedForNickname || hasCreatedUser) {
            wasActive = true
            
            socket = SocketServiceManager(URL: "http://192.168.1.102:3000", User: user) // Need to implement better solution for inputting the nickname recieve handler, such as sending it as an input for a seperate function or something else
            
            mcService = MCServiceManager(UUID: user.UUID)
            mcService!.delegate = self
            
            print("User is \(user)")
            
        }
    }
    
    // MARK: - Checking for first run and asking for nickname
    
    override func viewDidAppear(animated: Bool) {
        let hasCreatedUser = keychain.hasCreatedUser()
        
        if !hasCreatedUser && !self.hadAskedForNickname {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Nickname")
            self.presentViewController(vc, animated: false, completion: nil)
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PeerCell", forIndexPath: indexPath) 
        
        cell.textLabel?.text = Array(peers.values)[indexPath.row]
        cell.editing = false
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.selected = false
    }
    
    // MARK: - MCServiceManagerDelegate
    
    func foundPeer(peer: MCPeerID) {
        let indexOfPeer = peers.indexForKey(peer.displayName)
        
        if let indexOfPeer = indexOfPeer {
            peers.removeAtIndex(indexOfPeer)
        }
        
        peers[peer.displayName] = peer.displayName
        
        socket?.getNicknameForUUID(peer.displayName, requestHandler: handleSentNicknameRequest, recieveHandler: handleRecievedNickname)
        socket?.availablePeersChanged(peer.displayName, isAddition: true, availablePeers: Array(peers.keys))
        
        availablePeers.reloadData()
    }
    
    func lostPeer(peer: MCPeerID) {
        let indexOfPeer = peers.indexForKey(peer.displayName)
        
        if let indexOfPeer = indexOfPeer {
            peers.removeAtIndex(indexOfPeer)
        }
        
        socket?.availablePeersChanged(peer.displayName, isAddition: false, availablePeers: Array(peers.keys))
        
        availablePeers.reloadData()
    }
    
    // MARK: - SocketServiceManager functions
    
    func handleSentNicknameRequest() {
        print("Asked for nickname...")
    }
    
    func handleRecievedNickname(data: [String: String]) {
        peers[data["UUID"]!] = data["nickname"]
        availablePeers.reloadData()
    }
    
}

