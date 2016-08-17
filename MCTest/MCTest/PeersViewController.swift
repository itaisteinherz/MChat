//
//  ViewController.swift
//  MCTest
//
//  Created by Itai Steinherz on 18/07/2016.
//  Copyright © 2016 StarShell. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class PeersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MCServiceManagerDelegate {
    
    @IBOutlet weak var availablePeers: UITableView!
    
    var wasActive = false
    
    var socket: SocketServiceManager? = nil
    
    var mcService: MCServiceManager? = nil
    var peers: [String: String] = Dictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        wasActive = true
        mcService?.delegate = self
        
        for peer in Array(peers.values) {
            socket?.getNicknameForUUID(peer, requestHandler: handleSentNicknameRequest, recieveHandler: handleRecievedNickname)
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
        availablePeers.reloadData()
        
        socket?.getNicknameForUUID(peer.displayName, requestHandler: handleSentNicknameRequest, recieveHandler: handleRecievedNickname)
        socket?.availablePeersChanged(peer.displayName, isAddition: true, availablePeers: Array(peers.keys))
    }
    
    func lostPeer(peer: MCPeerID) {
        let indexOfPeer = peers.indexForKey(peer.displayName)
        
        if let indexOfPeer = indexOfPeer {
            peers.removeAtIndex(indexOfPeer)
        }
        
        availablePeers.reloadData()
        socket?.availablePeersChanged(peer.displayName, isAddition: false, availablePeers: Array(peers.keys))
    }
    
    // MARK: - SocketServiceManager functions
    
    func handleSentNicknameRequest() {
        print("Asked for nickname...")
    }
    
    func handleRecievedNickname(data: [String: String]) {
        if let peer = data["UUID"] where peers[peer] == peer  {
            peers[data["UUID"]!] = data["nickname"]
            availablePeers.reloadData()
        }
    }

    
}

