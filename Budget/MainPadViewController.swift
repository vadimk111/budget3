//
//  MainPadViewController.swift
//  Budget
//
//  Created by Vadik on 28/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class MainPadViewController: UIViewController, AuthenticationDelegate, UITabBarControllerDelegate {

    @IBOutlet weak var o_popoverSourceView: UIView!
    @IBOutlet weak var o_navigationItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Authentication.shared.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tabbar" {
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
}
