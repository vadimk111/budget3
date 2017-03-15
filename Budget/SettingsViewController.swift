//
//  SettingsViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 20/12/2016.
//  Copyright © 2016 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseAuth

let signInStateChangedNotification = Notification.Name(rawValue: "signInStateChanged")

class SettingsViewController: UIViewController, TabBarComponent {

    @IBOutlet weak var o_userEmail: UILabel!
    @IBOutlet weak var o_logoutBtn: UIButton!
    @IBOutlet weak var o_loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reload()
    }
    
    func reload() {
        if let user = APP.user {
            o_userEmail.text = user.email
            o_logoutBtn.isHidden = false
            o_loginBtn.isHidden = true
        } else {
            o_userEmail.text = "Anonymous"
            o_loginBtn.isHidden = false
            o_logoutBtn.isHidden = true
        }
    }

    @IBAction func didTapLogin(_ sender: UIButton) {
        let login = LoginViewController()
        login.insideTheApp = true
        login.completion = { [unowned self] in
            if let _ = APP.user {
                self.reload()
                NotificationCenter.default.post(Notification(name: signInStateChangedNotification))
            }
        }
        present(login, animated: true, completion: nil)
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
        
        let login = LoginViewController()
        login.completion = { [unowned self] in
            self.reload()
            NotificationCenter.default.post(Notification(name: signInStateChangedNotification))
        }
        present(login, animated: true, completion: nil)
    }
}
