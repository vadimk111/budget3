//
//  SettingsViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 20/12/2016.
//  Copyright © 2016 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol SettingsViewControllerDelegate: class {
    func settingsViewController(_ settingsViewController: SettingsViewController, shouldDisplayViewController viewController: UIViewController)
    func settingsViewController(_ settingsViewController: SettingsViewController, shouldDismissViewController viewController: UIViewController)
    func settingsViewController(_ settingsViewController: SettingsViewController, shouldDisplayAlert alert: UIAlertController)
}

class SettingsViewController: UIViewController, AuthenticationDelegate {

    @IBOutlet weak var o_userEmail: UILabel!
    @IBOutlet weak var o_logoutBtn: UIButton!
    @IBOutlet weak var o_loginBtn: UIButton!
    
    var authentication: Authentication?
    weak var delegate: SettingsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: signInStateChangedNotification, object: nil, queue: nil, using: { [weak self] notification in
            self?.reload()
        })
        
        reload()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        if let delegate = delegate {
            delegate.settingsViewController(self, shouldDisplayViewController: viewController)
        } else {
            present(viewController, animated: true, completion: nil)
        }
    }
    
    func authentication(_ authentication: Authentication, shouldDisplay alert: UIAlertController) {
        if let delegate = delegate {
            delegate.settingsViewController(self, shouldDisplayAlert: alert)
        } else {
            present(alert, animated: true, completion: nil)
        }
    }
    
    func authentication(_ authentication: Authentication, shouldDismiss viewController: UIViewController) {
        if let delegate = delegate {
            delegate.settingsViewController(self, shouldDismissViewController: viewController)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}
