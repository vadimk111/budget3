//
//  SettingsViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 20/12/2016.
//  Copyright © 2016 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController, AuthenticationDelegate {

    @IBOutlet weak var o_userEmail: UILabel!
    @IBOutlet weak var o_logoutBtn: UIButton!
    @IBOutlet weak var o_loginBtn: UIButton!
    
    var authentication: Authentication?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: signInStateChangedNotification, object: nil, queue: nil, using: { [unowned self] notification in
            self.reload()
        })
        
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
        authentication = Authentication()
        authentication?.delegate = self
        authentication?.manualSignIn()
    }

    @IBAction func didTapLogout(_ sender: UIButton) {
        authentication = Authentication()
        authentication?.delegate = self
        authentication?.signOut()
        authentication?.manualSignIn()
    }
    
    func authentication(_ authentication: Authentication, shouldDisplay viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    func authentication(_ authentication: Authentication, shouldDisplay alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
}
