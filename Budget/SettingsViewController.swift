//
//  SettingsViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 20/12/2016.
//  Copyright © 2016 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseAuth

let logoutNotification = Notification.Name(rawValue: "logout")
let loginNotification = Notification.Name(rawValue: "login")

class SettingsViewController: UIViewController {

    @IBOutlet weak var o_userEmail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let user = APP.user {
            o_userEmail.text = user.email
        }
    }
    
    @IBAction func didTapLogout(_ sender: UIButton) {
        do {
            try FIRAuth.auth()?.signOut()
        } catch {
            
        }
        APP.user = nil
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "password")
        UserDefaults.standard.synchronize()
        o_userEmail.text = nil
        
        NotificationCenter.default.post(Notification(name: logoutNotification))
        
        let login = LoginViewController()
        login.completion = {
            NotificationCenter.default.post(Notification(name: loginNotification))
        }
        present(login, animated: true, completion: nil)
    }
    
}
