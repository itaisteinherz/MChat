//
//  SettingsViewController.swift
//  MChat
//
//  Created by Itai Steinherz on 26/12/2016.
//  Copyright © 2016 Itai Steinherz. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var nicknameTextField: UITextField!
    
    var user: User? = nil
    var socket: SocketManager? = nil
    var keychain: KeychainManager? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let parentController = parent as? TabBarViewController {
            user = parentController.user
            socket = parentController.socket
            keychain = parentController.keychain
            
            nicknameTextField.text = user?.nickname
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateNickname() {
        if let nickname = nicknameTextField.text, nickname.characters.count > 0, nickname != user?.nickname {
            user?.nickname = nickname
            keychain?.changeNickname(newNickname: nickname)
            socket?.changeNickname(user: user!, newNickname: nickname)
        }
    }
    
    @IBAction func doneButtonTapped() {
        updateNickname()
    }

}

extension SettingsViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        updateNickname()
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}
