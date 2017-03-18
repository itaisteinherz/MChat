//
//  NicknameViewController.swift
//  MChat
//
//  Created by Itai Steinherz on 26/12/2016.
//  Copyright © 2016 Itai Steinherz. All rights reserved.
//

import UIKit

class NicknameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nickname: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Custom methods
    
    func isValidNickname() -> Bool { // TODO: Add input validation to the app and the server.
        if let text = nickname.text, text.characters.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if (isValidNickname()) {
            performSegue(withIdentifier: "NicknameSegue", sender: self)
        }
        
        return true
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) { // TODO: Make the button grayed out when no input is entered.
        nickname.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    
    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "NicknameSegue" {
            return isValidNickname()
        }
        
        return true
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "NicknameSegue" {
            if let dest = segue.destination as? TabBarViewController {
                if let nicknameText = nickname.text {
                    dest.nickname = nicknameText
                }
            }
        }
    }
    

}
