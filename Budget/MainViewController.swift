//
//  MainViewController.swift
//  Budget
//
//  Created by Vadik on 27/07/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController, AuthenticationDelegate {
    
    var authentication: Authentication?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.onSignInStateChanged), name: signInStateChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.onDatePickerAppear), name: datePickerControllerWillAppearNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.onDatePickerDisappear), name: datePickerControllerDidDisappearNotification, object: nil)
    }
    
    func onSignInStateChanged() {
        authentication = nil
        APP.automaticAuthenticationCompleted = true
        NotificationCenter.default.removeObserver(self, name: signInStateChangedNotification, object: nil)
    }
    
    func onDatePickerAppear() {
        tabBar.isHidden = true
    }
    
    func onDatePickerDisappear() {
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
        if isCompactWidth {
            present(viewController, animated: true, completion: nil)
        } else {
            viewController.modalPresentationStyle = .popover
            viewController.popoverPresentationController?.sourceView = view
            present(viewController, animated: true, completion: nil)
        }
    }
    
    func authenticationShouldDismissViewController(_ authentication: Authentication) {
        dismiss(animated: true, completion: nil)
    }
}
