//
//  MCAdvertiserManager.swift
//  MChat
//
//  Created by Itai Steinherz on 16/12/2016.
//  Copyright © 2016 Itai Steinherz. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class MCAdvertiser: NSObject, MCNearbyServiceAdvertiserDelegate {
    
    private let serviceType = "mchat"
    private let peer: MCPeerID
    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    
    init(name: String) {
        peer = MCPeerID(displayName: name)
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peer, discoveryInfo: nil, serviceType: serviceType)
        
        super.init()
        
        self.serviceAdvertiser.delegate = self
        self.serviceAdvertiser.startAdvertisingPeer()
    }
    
    deinit {
        self.serviceAdvertiser.stopAdvertisingPeer()
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        // Retry to start advertising
        self.serviceAdvertiser.startAdvertisingPeer()
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
    }
    
}
