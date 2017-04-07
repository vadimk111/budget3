//
//  SettingsViewController+CellsDelegate.swift
//  Budget
//
//  Created by Vadik on 04/04/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import UserNotifications

extension SettingsViewController: AccountTableViewCellDelegate {
    func accountTableViewCell(_ accountTableViewCell: AccountTableViewCell, shouldDisplayAlert alert: UIAlertController) {
        if let delegate = delegate {
            delegate.settingsViewController(self, shouldDisplayAlert: alert)
        } else {
            present(alert, animated: true, completion: nil)
        }
    }
    
    func accountTableViewCell(_ accountTableViewCell: AccountTableViewCell, shouldDismiss viewController: UIViewController) {
        if let delegate = delegate {
            delegate.settingsViewController(self, shouldDismissViewController: viewController)
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
        } else {
            tableView.deleteSections([2, 3], with: .fade)
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        
        tableView.reloadSections([1], with: .none)
    }
}
