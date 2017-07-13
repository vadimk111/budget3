//
//  SettingsViewController+CellsDelegate.swift
//  Budget
//
//  Created by Vadik on 04/04/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import UserNotifications
import FBSDKLoginKit

extension SettingsViewController: AccountTableViewCellDelegate {
    func accountTableViewCell(_ accountTableViewCell: AccountTableViewCell, shouldDisplayAlert alert: UIAlertController) {
        displayAlert(alert)
    }
    
    func accountTableViewCellShouldDismissViewController(_ accountTableViewCell: AccountTableViewCell) {
        if let delegate = delegate {
            delegate.settingsViewControllerShouldDismissViewController(self)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func accountTableViewCell(_ accountTableViewCell: AccountTableViewCell, shouldDisplayViewController viewController: UIViewController) {
        if let delegate = delegate {
            delegate.settingsViewController(self, shouldDisplayViewController: viewController)
        } else {
            present(viewController, animated: true, completion: nil)
        }
    }
}

extension SettingsViewController: RemindersTableViewCellDelegate {
    func remindersTableViewCell(_ reminderTableViewCell: RemindersTableViewCell, didRequest showReminders: Bool) {
        self.showReminders = showReminders
        UserDefaults.standard.set(showReminders, forKey: showReminderskey)
        UserDefaults.standard.synchronize()
        
        if showReminders {
            tableView.insertSections([2, 3], with: .fade)
            scheduleAllNotifications()
        } else {
            tableView.deleteSections([2, 3], with: .fade)
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        
        tableView.reloadSections([1], with: .none)
    }
}

extension SettingsViewController: FacebookTableViewCellDelegate {
    func facebookTableViewCellDidTapConnect(_ facebookTableViewCell: FacebookTableViewCell) {
        let fbm = FBSDKLoginManager()
        fbm.logIn(withReadPermissions: facebookReadPermissions, from: self) { [unowned self] (result: FBSDKLoginManagerLoginResult?, error: Error?) in
            if let error = error {
                let a = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                a.addAction(UIAlertAction(title: "Ok", style: .default) { action -> Void in
                })
                self.displayAlert(a)

            } else if result?.isCancelled == true {
                
            } else if let token = result?.token {
                self.authentication = Authentication()
                self.authentication?.delegate = self
                self.authentication?.connectFacebookAccount(token: token.tokenString)
            }
        }
    }
    
    func facebookTableViewCellDidTapDisconnect(_ facebookTableViewCell: FacebookTableViewCell) {
        authentication = Authentication()
        authentication?.delegate = self
        authentication?.disconnectFacebookAccount()
    }
}

extension SettingsViewController: AuthenticationDelegate {
    func authentication(_ authentication: Authentication, shouldDisplayViewController viewController: UIViewController) {
        
    }
    
    func authentication(_ authentication: Authentication, shouldDisplayAlert alert: UIAlertController) {
        displayAlert(alert)
    }
    
    func authenticationShouldDismissViewController(_ authentication: Authentication) {
        
    }
}
