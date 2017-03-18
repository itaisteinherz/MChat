//
//  TabBarViewController.swift
//  MChat
//
//  Created by Itai Steinherz on 26/12/2016.
//  Copyright © 2016 Itai Steinherz. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    var nickname: String = ""
    
    var user: User? = nil
    var socket: SocketManager? = nil
    var keychain: KeychainManager? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
