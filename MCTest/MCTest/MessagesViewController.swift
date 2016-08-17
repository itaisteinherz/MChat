//
//  MessagesViewController.swift
//  MCTest
//
//  Created by Itai Steinherz on 12/08/2016.
//  Copyright © 2016 StarShell. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MessagesViewController: UIViewController, MCServiceManagerDelegate {
    
    @IBOutlet weak var messageContents: UITextField!
    @IBOutlet weak var messages: UITableView!
    @IBOutlet weak var connectedPeers: UILabel!
    @IBOutlet weak var status: UIImageView!
    
    var wasActive = false
    var hadAskedForNickname: Bool = false
    var nickname: String?
    var user: User?
    var connectedPeersFromDB: Int?
    
    var socket: SocketServiceManager? = nil
    var mcService: MCServiceManager? = nil
    var peers: [String: String] = Dictionary()
    let keychain = KeychainServiceManager()
    
    // MARK: - Creating the user if first run or loading the user if isn't
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let hasCreatedUser = keychain.hasCreatedUser()
        
        if hasCreatedUser == false && self.hadAskedForNickname {
            user = User(nickname: self.nickname!)
            keychain.createUser(user!)
        } else if hasCreatedUser {
            user = keychain.getUser()
        }
        
        if let user = user where (self.hadAskedForNickname || hasCreatedUser) {
            wasActive = true
            
            socket = SocketServiceManager(URL: "http://192.168.1.105:3000", User: user)
            
            status.layer.cornerRadius = status.bounds.height / 2
            status.layer.masksToBounds = true
            updateStatus()
            NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: #selector(MessagesViewController.updateStatus), userInfo: nil, repeats: true)
            
            mcService = MCServiceManager(UUID: user.UUID)
            mcService!.delegate = self
            
            print("User is \(user)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    // MARK: - Update the status
    
    func getEllipseWithColor(color: UIColor, width: Double, height: Double) -> UIImage {
        let size = CGSize(width: width, height: height)
        
        let rect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        
        color.setFill()
        UIRectFill(rect)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func updateConnectedPeers() {
        socket?.getConnectedPeers(askedForPeers, recieveHandler: gotPeers)
    }
    
    func updateStatus() {
        switch socket!.status {
        case .Connected:
            status.image = getEllipseWithColor(UIColor(red: 0, green: 200/255, blue: 0, alpha: 1), width: 30, height: 30)
        case .Connecting:
            status.image = getEllipseWithColor(UIColor(red: 1, green: (150 / 255), blue: 0, alpha: 1), width: 30, height: 30)
        default:
            status.image = getEllipseWithColor(UIColor(red: 1, green: 0, blue: 0, alpha: 1), width: 30.0, height: 30.0)
        }
        
        updateConnectedPeers()
    }
    
    // MARK: - MCServiceManagerDelegate
    
    func foundPeer(peer: MCPeerID) {
        let indexOfPeer = peers.indexForKey(peer.displayName)
        
        if let indexOfPeer = indexOfPeer {
            peers.removeAtIndex(indexOfPeer)
        }
        
        peers[peer.displayName] = peer.displayName
        socket?.availablePeersChanged(peer.displayName, isAddition: true, availablePeers: Array(peers.keys))
    }
    
    func lostPeer(peer: MCPeerID) {
        let indexOfPeer = peers.indexForKey(peer.displayName)
        
        if let indexOfPeer = indexOfPeer {
            peers.removeAtIndex(indexOfPeer)
        }
        
        socket?.availablePeersChanged(peer.displayName, isAddition: false, availablePeers: Array(peers.keys))
    }
    
    // MARK: - SocketServiceManager functions
    
    func askedForPeers() {
        print("Asked for peers...")
    }
    
    func gotPeers(peers: Int) {
        connectedPeers.text = "\(peers) (\(self.peers.count))"
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "PeersSegue" {
            if let dest = segue.destinationViewController as? PeersViewController {
                dest.socket = socket
                dest.mcService = mcService
                dest.peers = peers
            }
        }
    }


}
