//
//  MainViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 05/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class MainPhoneViewController: UITabBarController, AuthenticationDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Authentication.shared.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(MainPhoneViewController.onDatePickerAppear), name: datePickerControllerWillAppearNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainPhoneViewController.onDatePickerDisappear), name: datePickerControllerDidDisappearNotification, object: nil)
    }
    
    @objc func onDatePickerAppear() {
        tabBar.isHidden = true
    }
    
    @objc func onDatePickerDisappear() {
        tabBar.isHidden = false
    }
    
    func authentication(_ authentication: Authentication, needsDisplay viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
}
