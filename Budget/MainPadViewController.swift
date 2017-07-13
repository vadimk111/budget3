//
//  MainPadViewController.swift
//  Budget
//
//  Created by Vadik on 28/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class MainPadViewController: UIViewController, AuthenticationDelegate, SettingsViewControllerDelegate, UITabBarControllerDelegate {

    var authentication: Authentication?
    var settingsViewController: SettingsViewController?
    
    @IBOutlet weak var o_popoverSourceView: UIView!
    @IBOutlet weak var o_navigationItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainPadViewController.onSignInStateChanged), name: signInStateChangedNotification, object: nil)
    }
    
    func onSignInStateChanged() {
        authentication = nil
        APP.automaticAuthenticationCompleted = true
        NotificationCenter.default.removeObserver(self, name: signInStateChangedNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.once(token: "signIn", block: {
            self.authentication = Authentication()
            self.authentication?.delegate = self
            self.authentication?.automaticSignIn()
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settings" {
            settingsViewController = segue.destinationController()
            settingsViewController?.delegate = self
        } else if segue.identifier == "tabbar" {
            let tabBarViewController: UITabBarController? = segue.destinationController()
            tabBarViewController?.delegate = self
        }
    }
    
    func authentication(_ authentication: Authentication, shouldDisplayAlert alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    func authentication(_ authentication: Authentication, shouldDisplayViewController viewController: UIViewController) {
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.sourceView = o_popoverSourceView
        present(viewController, animated: true, completion: nil)
    }
    
    func authenticationShouldDismissViewController(_ authentication: Authentication) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK - UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        o_navigationItem.title = viewController.title
    }
    
    //MARK - SettingsViewControllerDelegate
    func settingsViewController(_ settingsViewController: SettingsViewController, shouldDisplayViewController viewController: UIViewController) {
        dismiss(animated: true, completion: { [unowned self] in
            viewController.modalPresentationStyle = .popover
            viewController.popoverPresentationController?.sourceView = self.o_popoverSourceView
            self.present(viewController, animated: true, completion: nil)
        })
    }

    func settingsViewController(_ settingsViewController: SettingsViewController, shouldDisplayAlert alert: UIAlertController) {
        settingsViewController.present(alert, animated: true, completion: nil)
    }
    
    func settingsViewControllerShouldDismissViewController(_ settingsViewController: SettingsViewController) {
        dismiss(animated: true, completion: nil)
    }
}
