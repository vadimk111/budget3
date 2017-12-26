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
    func accountTableViewCellWillSignOut(_ accountTableViewCell: AccountTableViewCell) {
        sharings = []
        sharings.append(defaultBudget)
        selectedSharingRow = 0
        tableView.reloadSections([1], with: .none)
    }
}

extension SettingsViewController: RemindersTableViewCellDelegate {
    func remindersTableViewCell(_ reminderTableViewCell: RemindersTableViewCell, didRequest showReminders: Bool) {
        self.showReminders = showReminders
        UserDefaults.standard.set(showReminders, forKey: showReminderskey)
        UserDefaults.standard.synchronize()
        
        tableView.reloadSections([3, 4], with: .fade)
        if showReminders {
            scheduleAllNotifications()
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        
        tableView.reloadSections([2], with: .none)
    }
}

extension SettingsViewController: FacebookTableViewCellDelegate {
    func facebookTableViewCellDidTapConnect(_ facebookTableViewCell: FacebookTableViewCell) {
        let fbm = FBSDKLoginManager()
        fbm.logIn(withReadPermissions: facebookReadPermissions, from: self) { (result: FBSDKLoginManagerLoginResult?, error: Error?) in
            if let error = error {
                let a = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                a.addAction(UIAlertAction(title: "Ok", style: .default) { action -> Void in
                })
                //TODO: self.displayAlert(a)

            } else if result?.isCancelled == true {
                
            } else if let token = result?.token {
                Authentication.shared.connectFacebookAccount(token: token.tokenString)
            }
        }
    }
    
    func facebookTableViewCellDidTapDisconnect(_ facebookTableViewCell: FacebookTableViewCell) {
        Authentication.shared.disconnectFacebookAccount()
    }
}

extension SettingsViewController: BudgetTableViewCellDelegate {
    func budgetTableViewCellDidTap(_ budgetTableViewCell: BudgetTableViewCell) {
        if let indexPath = tableView.indexPath(for: budgetTableViewCell), selectedSharingRow != indexPath.row {
            if let cell = tableView.cellForRow(at: IndexPath(row: selectedSharingRow, section: indexPath.section)) as? BudgetTableViewCell {
                cell.markSelected(false)
            }
            budgetTableViewCell.markSelected(true)
            selectedSharingRow = indexPath.row
            
            let newId = sharings[indexPath.row].dbId
            if newId == defaultBudgetId {
                UserDefaults.standard.removeObject(forKey: APP.currentBudgetKey)
            } else {
                UserDefaults.standard.set(newId, forKey: APP.currentBudgetKey)
            }
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(Notification(name: currentBudgetChangedNotification))
        }
    }
}
