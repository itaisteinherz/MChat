//
//  MessagesViewController.swift
//  MChat
//
//  Created by Itai Steinherz on 26/12/2016.
//  Copyright © 2016 Itai Steinherz. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MessagesViewController: UIViewController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonConstraint: NSLayoutConstraint!

    @IBOutlet weak var connectedPeers: UILabel!
    @IBOutlet weak var status: UIImageView!
    
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var messageContents: UITextField!
    
    var nickname: String = ""
    
    var user: User? = nil
    
    var socket: SocketManager? = nil
    var mcAdvertiser: MCAdvertiser? = nil
    var mcBrowser: MCBrowser? = nil
    
    let keychain: KeychainManager = KeychainManager(service: "com.itaist.mchat-credentials") // TODO: Move the service into an external config file.
    
    var availablePeers: [String] = Array()
    var messages: [[String: String]] = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Add observers for the UIKeyboardWillShow and UIKeyboardWillHide events
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasHidden), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Initialize user, socket, mcBrowser and mcAdvertiser
        if let parentController = parent as? TabBarViewController {
            if keychain.isUserStoredInKeychain() { // TODO: Update nickname in necessary
                nickname = parentController.nickname
                
                user = keychain.getUserFromKeychain()
                                
                socket = SocketManager(URL: "https://itaist.ga:1443", User: user!, connectionHandler: handleConnection, successfulConnectionHandler: handleSuccessfulConnect, recievedMessageHandler: handleMessage)
                
                status.layer.cornerRadius = status.bounds.height / 2
                status.layer.masksToBounds = true
                updateStatus()
                Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MessagesViewController.updateStatus), userInfo: nil, repeats: true)
                
                parentController.socket = socket
                parentController.user = user
                parentController.keychain = keychain
            } else if !keychain.isUserStoredInKeychain() && parentController.nickname != "" {
                nickname = parentController.nickname
                
                user = User(nickname: nickname)
                keychain.saveUserToKeychain(user: user!)
                
                socket = SocketManager(URL: "https://itaist.ga:1443", User: user!, connectionHandler: handleConnection, successfulConnectionHandler: handleSuccessfulConnect, recievedMessageHandler: handleMessage)
                
                status.layer.cornerRadius = status.bounds.height / 2
                status.layer.masksToBounds = true
                updateStatus()
                Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MessagesViewController.updateStatus), userInfo: nil, repeats: true)
                
                parentController.socket = socket
                parentController.user = user
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let parentController = parent as? TabBarViewController, !keychain.isUserStoredInKeychain() && parentController.nickname == "" {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Nickname")
            self.present(vc, animated: false, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Handlers
    
    func sendMessage() { // TODO: Make the send button grayed out (disabled) if no content is entered.
        if let text = messageContents.text, text.characters.count > 0, availablePeers.count > 0 {
            messageContents.text = ""
            
            messages.append([
                "nickname": (user?.nickname)!,
                "UUID": (user?.UUID)!,
                "message": text
            ])
            self.messagesTableView.reloadData()
            
            socket?.sendMessage(messageContents: text)
        }
    }
    
    // TODO: Add proper error handling to this function.
    
    func getCell(tableView: UITableView, forRow row: Int) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell")!
        let messageContents = messages[row]
        
        var messageNickname = messageContents["nickname"]!
        let messageUUID = messageContents["UUID"]!
        let message = messageContents["message"]!
        
        messageNickname = messageUUID == user?.UUID ? "Me" : messageNickname
        
        cell.textLabel?.text = "\(messageNickname): \(message)"
        
        return cell
    }
    
    @IBAction func sendButtonTapped() {
        sendMessage()
    }
    
    func handleConnection() {
        socket?.connectDevice()
    }
    
    func handleSuccessfulConnect() {
        // MCBrowser
        mcBrowser = MCBrowser(name: (user?.UUID)!)
        mcBrowser?.delegate = self
        
        // MCAdvertiser
        mcAdvertiser = MCAdvertiser(name: (user?.UUID)!)
    }
    
    func handleMessage(data: [String: String]) {
        messages.append(data)
        self.messagesTableView.reloadData()
    }
    
    // MARK: - Update the status
    
    func getEllipseWithColor(color: UIColor, width: Double, height: Double) -> UIImage {
        let size = CGSize(width: width, height: height)
        
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        
        color.setFill()
        UIRectFill(rect)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func updateConnectedPeers() {
        socket?.getConnectedPeersCount(recieveHandler: gotPeersCount)
    }
    
    func gotPeersCount(count: Int) {
        connectedPeers.text = "\(count) (\(availablePeers.count))" // TODO: Adjust numbers that are wider than the width of the label.
    }
    
    func updateStatus() {
        if let socket = socket {
            switch socket.getStatus() {
            case .connected:
                status.image = getEllipseWithColor(color: UIColor(red: 0, green: 200/255, blue: 0, alpha: 1), width: 30, height: 30)
            case .connecting:
                status.image = getEllipseWithColor(color: UIColor(red: 1, green: (150 / 255), blue: 0, alpha: 1), width: 30, height: 30)
            default:
                status.image = getEllipseWithColor(color: UIColor(red: 1, green: 0, blue: 0, alpha: 1), width: 30.0, height: 30.0)
            }
        }
        
        updateConnectedPeers()
    }
    
    // MARK: - Show connected peers
    
    @IBAction func showConnectedPeersButtonTapped() {
        socket?.getConnectedPeersNicknames(peers: availablePeers, recieveHandler: showConnectedPeers)
    }
    
    func showConnectedPeers(data: [[String]]) { // TODO: Make the "Show connected peers" button grayed out after the button was intially pressed and until the "ok" button of the alert was clicked.
        let dbPeers = data[0]
        let directPeers = data[1]
        
        let message = "Peers seen directly:\n\(directPeers.joined(separator: "\n"))\n\nPeers in your chatroom:\n\(dbPeers.joined(separator: "\n"))"
        
        let alert = UIAlertController(title: "Connected peers", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        // TODO: Indicate which peers you see directly and which peers will get your messages.
        present(alert, animated: true, completion: nil) // TODO: Handle error when this function is called twice, which brings up this error: "Warning: Attempt to present <UIAlertController: 0x7fea5ed801e0>  on <MCTest.MessagesViewController: 0x7fea5ed321c0> which is already presenting <UIAlertController: 0x7fea5ecd0c70> 2016-09-10 14:47:15.927 MCTest[4363:439888] Attempting to load the view of a view controller while it is deallocating is not allowed and may result in undefined behavior (<UIAlertController: 0x7fea5ed801e0>)"
    }

}

extension MessagesViewController: UITextFieldDelegate {
    
    func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let spacingFromKeyboard = keyboardFrame.height - 40
        
        self.bottomConstraint.constant = spacingFromKeyboard
        self.buttonConstraint.constant = spacingFromKeyboard
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWasHidden(notification: NSNotification) {
        let spacingFromBottom = CGFloat(8) * 2 + status.bounds.size.height // 8 for the spacing to the UIImageView, the height of the images view and another 8 for the spacing from the UIImageView to the bottom layout guide
        
        self.bottomConstraint.constant = spacingFromBottom
        self.buttonConstraint.constant = spacingFromBottom
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        sendMessage()
        
        return true
    }
    
}

extension MessagesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCell(tableView: tableView, forRow: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.messages.remove(at: indexPath.row)
            self.messagesTableView.reloadData()
        }
    }
    
}

extension MessagesViewController: MCBrowserDelegate {
    
    func foundPeer(_ peer: MCPeerID) { // TODO: Update the peer count when a peer is found or lost
        // Ignore if the browser founds the advertiser of the same device
        if (peer.displayName != user?.UUID && availablePeers.index(of: peer.displayName) == nil) { // TODO: Check if this is the best solution for ignoring peers that were already seen. Also, fix issue where when the app goes to the background and then returns to an active state, the app still thinks the previous peers are still connected although they may not be.
            availablePeers.append(peer.displayName)
            
            socket?.availablePeersChanged(change: peer.displayName, isAddition: true, availablePeers: availablePeers)
        }
    }
    
    func lostPeer(_ peer: MCPeerID) {
        // Ignore if the browser founds the advertiser of the same device
        if (peer.displayName != user?.UUID) {
            if let index = availablePeers.index(of: peer.displayName) {
                availablePeers.remove(at: index)
            }
            
            socket?.availablePeersChanged(change: peer.displayName, isAddition: false, availablePeers: availablePeers)
        }
    }
    
}
