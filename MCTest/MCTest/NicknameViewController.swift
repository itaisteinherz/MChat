//
//  NicknameViewController.swift
//  MCTest
//
//  Created by Itai Steinherz on 20/07/2016.
//  Copyright © 2016 StarShell. All rights reserved.
//

import UIKit

class NicknameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.text?.characters.count > 0 {
            nextButton.enabled = true
        } else {
            nextButton.enabled = false
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        performSegueWithIdentifier("NicknameSegue", sender: self)
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if let navVC = segue.destinationViewController as? NavigationController {
            if segue.identifier == "NicknameSegue" {
                if let dest = navVC.topViewController as? MessagesViewController {
                    dest.nickname = nicknameTextField.text!
                    dest.hadAskedForNickname = true
                }
            }
        }
    }
    

}
