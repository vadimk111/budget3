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
import FBSDKLoginKit

let signInStateChangedNotification = Notification.Name(rawValue: "signInStateChanged")
let facebookLinkedChangeNotification = Notification.Name(rawValue: "facebookLinkedChange")
let anonymous = "-anonymous-"
let facebookReadPermissions = ["public_profile", "email"]

protocol AuthenticationDelegate: class {
    func authentication(_ authentication: Authentication, shouldDisplayViewController viewController: UIViewController)
    func authentication(_ authentication: Authentication, shouldDisplayAlert alert: UIAlertController)
    func authenticationShouldDismissViewController(_ authentication: Authentication)
}

class Authentication: NSObject {
    
    weak var delegate: AuthenticationDelegate?
    
    var loginViewController: LoginViewController?
    var linkAccountsViewController: LinkAccountsViewController?
    
    func notifyStateChanged() {
        NotificationCenter.default.post(Notification(name: signInStateChangedNotification))
    }
    
    func notifyFacebookLinkedChange() {
        NotificationCenter.default.post(Notification(name: facebookLinkedChangeNotification))
    }
    
    func automaticSignIn() {
        if let email = UserDefaults.standard.string(forKey: "email"), let password = UserDefaults.standard.string(forKey: "password") {
            if email.contains(anonymous) {
                notifyStateChanged()
            } else {
                FIRAuth.auth()?.signIn(withEmail: email, password: password) { [unowned self] (user, error) in
                    if let error = error {
                        self.automaticSignInFailed(with: error)
                    } else if let user = user {
                        APP.user = user
                        self.notifyStateChanged()
                    }
                }
            }
        } else if let authMethod = UserDefaults.standard.string(forKey: "auth_method") {
            if authMethod == "facebook" {
                if let token = FBSDKAccessToken.current().tokenString {
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: token)
                    FIRAuth.auth()?.signIn(with: credential) { [unowned self] (user, error) in
                        if let error = error {
                            self.automaticSignInFailed(with: error)
                        } else if let user = user {
                            APP.user = user
                            self.notifyStateChanged()
                        }
                    }
                }
            } else {
                self.manualSignIn()
            }
        } else {
            self.manualSignIn()
        }
    }
    
    func manualSignIn() {
        loginViewController = LoginViewController(delegate: self, facebookLoginDelegate: self)
        self.delegate?.authentication(self, shouldDisplayViewController: UINavigationController(rootViewController: loginViewController!))
    }
    
    func connectFacebookAccount(token: String) {
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: token)
        APP.user?.link(with: credential) { [unowned self] (user, error) in
            if let error = error {
                self.showErrorOnDelegate(error)
            } else {
                self.notifyFacebookLinkedChange()
            }
        }
    }
    
    func disconnectFacebookAccount() {
        if let providerId = Authentication.facebookProviderID() {
            APP.user?.unlink(fromProvider: providerId) { [unowned self] (user, error) in
                if let error = error {
                    self.showErrorOnDelegate(error)
                } else {
                    self.notifyFacebookLinkedChange()
                    FBSDKLoginManager().logOut()
                    UserDefaults.standard.removeObject(forKey: "auth_method")
                    UserDefaults.standard.synchronize()
                }
            }
        }
    }
    
    static func isFacebookAccountConnected() -> Bool {
        return Authentication.facebookProviderID() != nil
    }
    
    static func canDisconnectFacebookAccount() -> Bool {
        return APP.user != nil && FBSDKAccessToken.current() != nil && APP.user!.providerData.count > 1
    }
    
    static func facebookProviderID() -> String? {
        if let user = APP.user {
            for userInfo in user.providerData {
                if userInfo.providerID.contains("facebook") {
                    return userInfo.providerID
                }
            }
        }
        return nil
    }
    
    func signOut() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch {
            
        }
        
        FBSDKLoginManager().logOut()
        
        APP.user = nil
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "password")
        UserDefaults.standard.removeObject(forKey: "auth_method")
        UserDefaults.standard.synchronize()
        
        notifyStateChanged()
    }
    
    func automaticSignInFailed(with error: Error) {
        let a = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        a.addAction(UIAlertAction(title: "Ok", style: .default) { action -> Void in
            self.manualSignIn()
        })
        delegate?.authentication(self, shouldDisplayAlert: a)
    }
    
    func showError(_ error: Error, on viewController: UIViewController) {
        let a = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        a.addAction(UIAlertAction(title: "Ok", style: .default) { action -> Void in
        })
        viewController.present(a, animated: true, completion: nil)
    }
    
    func showErrorOnDelegate(_ error: Error) {
        let a = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        a.addAction(UIAlertAction(title: "Ok", style: .default) { action -> Void in
        })
        delegate?.authentication(self, shouldDisplayAlert: a)
    }
    
    func passwordSignInSucceded(with user: FIRUser) {
        APP.user = user
        UserDefaults.standard.set(loginViewController?.email, forKey: "email")
        UserDefaults.standard.set(loginViewController?.password, forKey: "password")
        UserDefaults.standard.synchronize()
        delegate?.authenticationShouldDismissViewController(self)
        notifyStateChanged()
    }
    
    func facebookSignInSucceded(with user: FIRUser) {
        APP.user = user
        UserDefaults.standard.set("facebook", forKey: "auth_method")
        UserDefaults.standard.synchronize()
        delegate?.authenticationShouldDismissViewController(self)
        notifyStateChanged()
    }
}

extension Authentication: LoginViewControllerDelegate {
    func loginViewControllerCreate(_ loginViewController: LoginViewController) {
        FIRAuth.auth()?.createUser(withEmail: loginViewController.email, password: loginViewController.password) { (user, error) in
            if let error = error {
                self.showError(error, on: loginViewController)
            } else if let user = user {
                self.passwordSignInSucceded(with: user)
            }
        }
    }
    
    func loginViewControllerSignIn(_ loginViewController: LoginViewController) {
        FIRAuth.auth()?.signIn(withEmail: loginViewController.email, password: loginViewController.password) { (user, error) in
            if let error = error {
                self.showError(error, on: loginViewController)
            } else if let user = user {
                self.passwordSignInSucceded(with: user)
            }
        }
    }
    
    func loginViewControllerForgot(_ loginViewController: LoginViewController) {
        FIRAuth.auth()?.sendPasswordReset(withEmail: loginViewController.email) { (error) in
            if let error = error {
                self.showError(error, on: loginViewController)
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
        UserDefaults.standard.removeObject(forKey: "auth_method")
        UserDefaults.standard.synchronize()
        delegate?.authenticationShouldDismissViewController(self)
        notifyStateChanged()
    }
}

extension Authentication: FBSDKLoginButtonDelegate {
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            if let _ = loginViewController {
                showError(error, on: loginViewController!)
            }
        } else if let token = result.token {
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: token.tokenString)
            FIRAuth.auth()?.signIn(with: credential) { [unowned self] (user, error) in
                if let error = error {
                    if let error_name = (error as NSError?)?.userInfo["error_name"] as? String, error_name ==  "ERROR_EMAIL_ALREADY_IN_USE" {
                        self.linkAccountsViewController = LinkAccountsViewController()
                        self.linkAccountsViewController?.delegate = self
                        self.linkAccountsViewController?.email = (error as NSError?)?.userInfo["FIRAuthErrorUserInfoEmailKey"] as? String
                        self.loginViewController?.navigationController?.pushViewController(self.linkAccountsViewController!, animated: true)
                    } else {
                        if let _ = self.loginViewController {
                            self.showError(error, on: self.loginViewController!)
                        }
                    }
                } else if let user = user {
                    self.facebookSignInSucceded(with: user)
                }
            }
        }
    }
    
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }

}

extension Authentication: LinkAccountsViewControllerDelegate {
    func linkAccountsViewController(_ linkAccountsViewController: LinkAccountsViewController, linkWithPassword password: String?) {
        FIRAuth.auth()?.signIn(withEmail: linkAccountsViewController.email ?? "", password: password ?? "") { (user, error) in
            if let error = error {
                self.showError(error, on: linkAccountsViewController)
            } else if let user = user {
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                user.link(with: credential) { [unowned self] (user, error) in
                    if let error = error {
                        self.showError(error, on: linkAccountsViewController)
                    } else if let user = user {
                        self.facebookSignInSucceded(with: user)
                    }
                }
            }
        }
    }
}
