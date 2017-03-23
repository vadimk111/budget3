//
//  MainViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 05/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController, AuthenticationDelegate {

    var authentication: Authentication?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: signInStateChangedNotification, object: nil, queue: nil, using: { [unowned self] notification in
            self.authentication = nil
            APP.automaticAuthenticationCompleted = true
            NotificationCenter.default.removeObserver(self, name: signInStateChangedNotification, object: nil)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.once(token: "signIn", block: {
            self.authentication = Authentication()
            self.authentication?.delegate = self
            self.authentication?.automaticSignIn()
        })
    }
    
    func authentication(_ authentication: Authentication, shouldDisplay alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    func authentication(_ authentication: Authentication, shouldDisplay viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
}
