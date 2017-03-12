//
//  MCBrowserManager.swift
//  MChat
//
//  Created by Itai Steinherz on 16/12/2016.
//  Copyright © 2016 Itai Steinherz. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MCBrowser: NSObject, MCNearbyServiceBrowserDelegate {
    
    private let serviceType = "mchat"
    private let peer: MCPeerID
    private let serviceBrowser: MCNearbyServiceBrowser
    
    var delegate: MCBrowserDelegate?
    
    init(name: String) {
        peer = MCPeerID(displayName: name)
        self.serviceBrowser = MCNearbyServiceBrowser(peer: peer, serviceType: serviceType)
        
        super.init()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceBrowser.stopBrowsingForPeers()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        // Retry to start browsing for peers
        browser.startBrowsingForPeers()
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        self.delegate?.foundPeer(peerID)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        self.delegate?.lostPeer(peerID)
    }

}

// MARK: - MCBrowserDelegate

protocol MCBrowserDelegate  {
    
    func foundPeer(_ peer: MCPeerID)
    
    func lostPeer(_ peer: MCPeerID)
    
}
