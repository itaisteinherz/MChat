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
    
    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var messageContents: UITextField!
    
    var nickname: String = ""
    
    var user: User? = nil
    
    var socket: SocketManager? = nil
    var mcAdvertiser: MCAdvertiser? = nil
    var mcBrowser: MCBrowser? = nil
    
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
            nickname = parentController.nickname
            
            user = User(nickname: nickname)

            socket = SocketManager(URL: "https://itaist.ga:1443", User: user!, connectionHandler: handleConnection, recievedMessageHandler: handleMessage)
            
            parentController.socket = socket
            parentController.user = user
            
            // MCBrowser
            mcBrowser = MCBrowser(name: (user?.UUID)!)
            mcBrowser?.delegate = self
            
            // MCAdvertiser
            mcAdvertiser = MCAdvertiser(name: (user?.UUID)!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Handlers
    
    func sendMessage() {
        if let text = messageContents.text, text.characters.count > 0 {
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
    
    func handleMessage(data: [String: String]) {
        messages.append(data)
        self.messagesTableView.reloadData()
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
        let spacingFromBottom = CGFloat(8)
            
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
    
    func foundPeer(_ peer: MCPeerID) {
        // Ignore if the browser founds the advertiser of the same device
        if (peer.displayName != user?.UUID) {
            availablePeers.append(peer.displayName)
            
            socket?.availablePeersChanged(change: peer.displayName, isAddition: true, availablePeers: availablePeers)
        }
    }
    
    func lostPeer(_ peer: MCPeerID) {
        // Ignore if the browser founds the advertiser of the same device
        if (peer.displayName != user?.UUID) {
            availablePeers.append(peer.displayName)
            
            if let index = availablePeers.index(of: peer.displayName) {
                availablePeers.remove(at: index)
            }
            
            socket?.availablePeersChanged(change: peer.displayName, isAddition: false, availablePeers: availablePeers)
        }
    }
    
}
