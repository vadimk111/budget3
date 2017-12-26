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
    
    public static let shared = Authentication()
    
    override init() {
        super.init()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            APP.user = user
            self.notifyStateChanged()

            if user == nil {
                self.showSignInView()
            }
        }
    }
    
    func notifyStateChanged() {
        NotificationCenter.default.post(Notification(name: signInStateChangedNotification))
    }
    
    func notifyFacebookLinkedChange() {
        NotificationCenter.default.post(Notification(name: facebookLinkedChangeNotification))
    }
    
    func showSignInView() {
        loginViewController = LoginViewController(delegate: self, facebookLoginDelegate: self)
        self.delegate?.authentication(self, shouldDisplayViewController: UINavigationController(rootViewController: loginViewController!))
    }
    
    func connectFacebookAccount(token: String) {
        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        APP.user?.link(with: credential) { [weak self] (user, error) in
            if let error = error {
                self?.showErrorOnDelegate(error)
            } else {
                self?.notifyFacebookLinkedChange()
            }
        }
    }
    
    func disconnectFacebookAccount() {
        if let providerId = Authentication.facebookProviderID() {
            APP.user?.unlink(fromProvider: providerId) { [weak self] (user, error) in
                if let error = error {
                    self?.showErrorOnDelegate(error)
                } else {
                    self?.notifyFacebookLinkedChange()
                    FBSDKLoginManager().logOut()
                }
            }
        }
    }
    
    static func isFacebookAccountConnected() -> Bool {
        return Authentication.facebookProviderID() != nil
    }
    
    static func canDisconnectFacebookAccount() -> Bool {
        if let user = APP.user {
            return FBSDKAccessToken.current() != nil && user.providerData.count > 1
        }
        return false
    }
    
    static func isOnlyFacebookAccountRegistered() -> Bool {
        return isFacebookAccountConnected() && APP.user?.providerData.count == 1
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
        if APP.user?.isAnonymous == true {
            let a = UIAlertController(title: "Attention", message: "Sign out of anonymous account will loose all your data", preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            a.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) in
                self.signOutInt()
            }))
            self.delegate?.authentication(self, shouldDisplayAlert: a)
        } else {
            signOutInt()
        }
    }
    
    private func signOutInt() {
        do {
            try Auth.auth().signOut()
        } catch {
        }
        FBSDKLoginManager().logOut()
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
}

extension Authentication: LoginViewControllerDelegate {
    func loginViewControllerCreate(_ loginViewController: LoginViewController) {
        let email = loginViewController.email
        let password = loginViewController.password

        if let anonymousUser = APP.user {
            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
            anonymousUser.link(with: credential, completion: { (user, error) in
                if let error = error {
                    self.showError(error, on: loginViewController)
                } else {
                    self.notifyStateChanged()
                    self.delegate?.authenticationShouldDismissViewController(self)
                }
            })
        } else {
            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                if let error = error {
                    self.showError(error, on: loginViewController)
                } else {
                    self.delegate?.authenticationShouldDismissViewController(self)
                }
            }
        }
    }
    
    func loginViewControllerSignIn(_ loginViewController: LoginViewController) {
        Auth.auth().signIn(withEmail: loginViewController.email, password: loginViewController.password) { (user, error) in
            if let error = error {
                self.showError(error, on: loginViewController)
            } else {
                self.delegate?.authenticationShouldDismissViewController(self)
            }
        }
    }
    
    func loginViewControllerForgot(_ loginViewController: LoginViewController) {
        Auth.auth().sendPasswordReset(withEmail: loginViewController.email) { (error) in
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
        if APP.user == nil {
            Auth.auth().signInAnonymously { (user, error) in
                if let error = error {
                    self.showError(error, on: loginViewController)
                } else {
                    self.delegate?.authenticationShouldDismissViewController(self)
                }
            }
        } else {
            self.delegate?.authenticationShouldDismissViewController(self)
        }
    }
}

extension Authentication: FBSDKLoginButtonDelegate {
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            if let _ = loginViewController {
                showError(error, on: loginViewController!)
            }
        } else if let token = result.token {
            let credential = FacebookAuthProvider.credential(withAccessToken: token.tokenString)
            if let anonymousUser = APP.user {
                anonymousUser.link(with: credential, completion: { (user, error) in
                    if let error = error {
                        if let _ = self.loginViewController {
                            self.showError(error, on: self.loginViewController!)
                        }
                    } else {
                        self.notifyStateChanged()
                        self.delegate?.authenticationShouldDismissViewController(self)
                    }
                })
            } else {
                Auth.auth().signIn(with: credential) { (user, error) in
                    if let error = error {
                        if let error_name = (error as NSError?)?.userInfo["error_name"] as? String, error_name == "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL" {
                            self.linkAccountsViewController = LinkAccountsViewController()
                            self.linkAccountsViewController?.delegate = self
                            self.linkAccountsViewController?.email = (error as NSError?)?.userInfo["FIRAuthErrorUserInfoEmailKey"] as? String
                            self.loginViewController?.navigationController?.pushViewController(self.linkAccountsViewController!, animated: true)
                        } else if let _ = self.loginViewController {
                            self.showError(error, on: self.loginViewController!)
                        }
                    } else {
                        self.delegate?.authenticationShouldDismissViewController(self)
                    }
                }
            }
        }
    }
    
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }

}

extension Authentication: LinkAccountsViewControllerDelegate {
    func linkAccountsViewController(_ linkAccountsViewController: LinkAccountsViewController, linkWithPassword password: String?) {
        Auth.auth().signIn(withEmail: linkAccountsViewController.email ?? "", password: password ?? "") { (user, error) in
            if let error = error {
                self.showError(error, on: linkAccountsViewController)
            } else if let user = user {
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                user.link(with: credential) { (user, error) in
                    if let error = error {
                        self.showError(error, on: linkAccountsViewController)
                    } else {
                        self.delegate?.authenticationShouldDismissViewController(self)
                    }
                }
            }
        }
    }
}
