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
    @IBOutlet weak var o_recordButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Authentication.shared.delegate = self
        
        o_recordButton.tintColor = ExpensesRecorder.isRecording() ? recordingColor : nil
    }
    
    @IBAction func didTapRecord(_ sender: UIBarButtonItem) {
        let a = getRecordingAlert(button: o_recordButton)
        a.popoverPresentationController?.barButtonItem = o_recordButton
        present(a, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tabbar" {
            let tabBarViewController: UITabBarController? = segue.destinationController()
            tabBarViewController?.delegate = self
        }
    }
    
    func authentication(_ authentication: Authentication, needsDisplay viewController: UIViewController) {
        if !(viewController is UIAlertController) {
            viewController.modalPresentationStyle = .popover
            viewController.isModalInPopover = true
            viewController.popoverPresentationController?.sourceView = o_popoverSourceView
        }
        (presentedViewController ?? self).present(viewController, animated: true)
    }

    //MARK - UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        o_navigationItem.title = viewController.title
    }
}
