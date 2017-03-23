//
//  AuthenticationManager.swift
//  Budget
//
//  Created by Vadik on 23/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit

let signInStateChangedNotification = Notification.Name(rawValue: "signInStateChanged")
let anonymous = "-anonymous-"

protocol AuthenticationDelegate: class {
    func authentication(_ authentication: Authentication, shouldDisplay viewController: UIViewController)
    func authentication(_ authentication: Authentication, shouldDisplay alert: UIAlertController)
}

class Authentication: LoginViewControllerDelegate {
    
    weak var delegate: AuthenticationDelegate?
    
    func notifyStateChanged() {
        NotificationCenter.default.post(Notification(name: signInStateChangedNotification))
    }
    
    func automaticSignIn() {
        if let email = UserDefaults.standard.string(forKey: "email"), let password = UserDefaults.standard.string(forKey: "password") {
            if email.contains(anonymous) {
                notifyStateChanged()
            } else {
                FIRAuth.auth()?.signIn(withEmail: email, password: password) { [unowned self] (user, error) in
                    if let _ = error {
                        let a = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        a.addAction(UIAlertAction(title: "Ok", style: .default) { action -> Void in
                            self.manualSignIn()
                        })
                        self.delegate?.authentication(self, shouldDisplay: a)
                    } else if let user = user {
                        APP.user = user
                        self.notifyStateChanged()
                    }
                }
            }
        } else {
            self.manualSignIn()
        }
    }
    
    func manualSignIn() {
        self.delegate?.authentication(self, shouldDisplay: LoginViewController(delegate: self))
    }
    
    func signOut() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch {
            
        }
        APP.user = nil
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "password")
        UserDefaults.standard.synchronize()
        
        notifyStateChanged()
    }
    
    func loginFailed(with error: Error, on loginViewController: LoginViewController) {
        let a = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        a.addAction(UIAlertAction(title: "Ok", style: .default) { action -> Void in
        })
        loginViewController.present(a, animated: true, completion: nil)
    }
    
    func loginSucceded(with user: FIRUser, on loginViewController: LoginViewController) {
        APP.user = user
        UserDefaults.standard.set(loginViewController.email, forKey: "email")
        UserDefaults.standard.set(loginViewController.password, forKey: "password")
        UserDefaults.standard.synchronize()
        loginViewController.dismiss(animated: true, completion: nil)
        notifyStateChanged()
    }
    
    func loginViewControllerCreate(_ loginViewController: LoginViewController) {
        FIRAuth.auth()?.createUser(withEmail: loginViewController.email, password: loginViewController.password) { (user, error) in
            if let error = error {
                self.loginFailed(with: error, on: loginViewController)
            } else if let user = user {
                self.loginSucceded(with: user, on: loginViewController)
            }
        }
    }
    
    func loginViewControllerSignIn(_ loginViewController: LoginViewController) {
        FIRAuth.auth()?.signIn(withEmail: loginViewController.email, password: loginViewController.password) { (user, error) in
            if let error = error {
                self.loginFailed(with: error, on: loginViewController)
            } else if let user = user {
                self.loginSucceded(with: user, on: loginViewController)
            }
        }
    }
    
    func loginViewControllerForgot(_ loginViewController: LoginViewController) {
        FIRAuth.auth()?.sendPasswordReset(withEmail: loginViewController.email) { (error) in
            if let error = error {
                self.loginFailed(with: error, on: loginViewController)
            } else {
                let a = UIAlertController(title: nil, message: "An email was sent to your mailbox from which you will be able to reset your password", preferredStyle: UIAlertControllerStyle.alert)
                a.addAction(UIAlertAction(title: "Ok", style: .default) { action -> Void in
                })
                loginViewController.present(a, animated: true, completion: nil)
            }
        }
    }
    
    func loginViewControllerSkip(_ loginViewController: LoginViewController) {
        UserDefaults.standard.set(anonymous + UUID().uuidString, forKey: "email")
        UserDefaults.standard.set("-1", forKey: "password")
        UserDefaults.standard.synchronize()
        loginViewController.dismiss(animated: true, completion: nil)
        notifyStateChanged()
    }
}
