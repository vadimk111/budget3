//
//  MainViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 05/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class MainPhoneViewController: UITabBarController, AuthenticationDelegate {

    var authentication: Authentication?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainPhoneViewController.onSignInStateChanged), name: signInStateChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainPhoneViewController.onDatePickerAppear), name: datePickerControllerWillAppearNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainPhoneViewController.onDatePickerDisappear), name: datePickerControllerDidDisappearNotification, object: nil)
    }
    
    @objc func onSignInStateChanged() {
        authentication = nil
        APP.automaticAuthenticationCompleted = true
        NotificationCenter.default.removeObserver(self, name: signInStateChangedNotification, object: nil)
    }
    
    @objc func onDatePickerAppear() {
        tabBar.isHidden = true
    }
    
    @objc func onDatePickerDisappear() {
        tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.once(token: "signIn", block: {
            self.authentication = Authentication()
            self.authentication?.delegate = self
            self.authentication?.automaticSignIn()
        })
    }
    
    func authentication(_ authentication: Authentication, shouldDisplayAlert alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    func authentication(_ authentication: Authentication, shouldDisplayViewController viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    func authenticationShouldDismissViewController(_ authentication: Authentication) {
        dismiss(animated: true, completion: nil)
    }
}
