//
//  MCServiceManager.swift
//  MCTest
//
//  Created by Itai Steinherz on 18/07/2016.
//  Copyright © 2016 StarShell. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MCServiceManager: NSObject, MCNearbyServiceBrowserDelegate, MCNearbyServiceAdvertiserDelegate {
    
    // MARK: - Variable initialization
    
    private let MCServiceType = "mc-test"
    
    private let myPeerId: MCPeerID

    var delegate: MCServiceManagerDelegate?
    
    private let serviceBrowser : MCNearbyServiceBrowser
    private let serviceAdvertiser : MCNearbyServiceAdvertiser
    
    // MARK: - Initialization and Deinitialization
    
    init(UUID: String) {
        myPeerId = MCPeerID(displayName: UUID)
        
        self.serviceBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: MCServiceType)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: MCServiceType)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
        
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
    }
    
    deinit {
        self.serviceBrowser.stopBrowsingForPeers()
        self.serviceAdvertiser.stopAdvertisingPeer()
    }

    // MARK: - MCNearbyServiceBrowser
    
    func browser(browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: NSError) {
        NSLog("%@", "didNotStartBrowsingForPeers: \(error)")
        browser.startBrowsingForPeers()
    }
    
    func browser(browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "foundPeer: \(peerID)")
        
        self.delegate!.foundPeer(peerID)
    }
    
    func browser(browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "lostPeer: \(peerID)")
        
        self.delegate!.lostPeer(peerID)
    }
    
    // MARK: - MCNearbyServiceAdvertiser
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: NSError) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: NSData?, invitationHandler: (Bool, MCSession) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
    }

}

// MARK: - MCServiceManagerDelegate

protocol MCServiceManagerDelegate {
    
    func foundPeer(peer: MCPeerID)
    
    func lostPeer(peer: MCPeerID)
    
}