//
//  MainViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 05/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol TabBarComponent {
    func reload()
}

class MainViewController: UITabBarController {

    var isReady: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !isReady {
            isReady = true
            
            if let email = UserDefaults.standard.string(forKey: "email"), let password = UserDefaults.standard.string(forKey: "password") {
                if email.contains(anonymous) {
                    self.reload()
                } else {
                    FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
                        if let _ = error {
                            let a = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            a.addAction(UIAlertAction(title: "Ok", style: .default) { action -> Void in
                                self.present(LoginViewController(), animated: true, completion: nil)
                            })
                            self.present(a, animated: true, completion: nil)
                        } else if let user = user {
                            APP.user = user
                            self.reload()
                        }
                    }
                }
            } else {
                let login = LoginViewController()
                login.completion = {
                    self.reload()
                }
                present(login, animated: true, completion: nil)
            }
        }
    }
    
    func reload() {
        if let viewControllers = self.viewControllers {
            for item in viewControllers {
                if item.isViewLoaded {
                    if let vc = item as? TabBarComponent {
                        vc.reload()
                    }
                }
            }
        }
    }
}
