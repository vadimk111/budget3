//
//  SettingsViewController+UITableView.swift
//  Budget
//
//  Created by Vadik on 03/04/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import UserNotifications

extension SettingsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if showReminders {
            return 4
        }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if APP.user == nil {
                return 1
            }
            if !Authentication.isFacebookAccountConnected() {
                return 2
            }
            if Authentication.canDisconnectFacebookAccount() {
                return 2
            }
            return 1
        }
        if section == 2 {
            return reminders.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "accountCells", for: indexPath) as! AccountTableViewCell
                cell.delegate = self
                cell.build()
                return cell
            }
            if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "facebookCells", for: indexPath) as! FacebookTableViewCell
                cell.delegate = self
                cell.isConnected = Authentication.isFacebookAccountConnected()
                return cell
            }
            return UITableViewCell()
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "remindersCells", for: indexPath) as! RemindersTableViewCell
            cell.delegate = self
            cell.o_switch.isOn = UserDefaults.standard.bool(forKey: showReminderskey)
            cell.o_bottomView.isHidden = showReminders
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "scheduledReminderCells", for: indexPath) as! ScheduledReminderTableViewCell
            cell.populate(with: reminders[indexPath.row], showSeparator: indexPath.row > 0)
            return cell
        } else if indexPath.section == 3 {
            return tableView.dequeueReusableCell(withIdentifier: "addReminderCells", for: indexPath)
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 48
        }
        if section == 1 {
            return APP.notificationsAllowed ? 80 : 130
        }
        if section == 2 {
            return 1
        }
        if section == 3 {
            return reminders.count > 0 ? 1 : 0
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 || section == 3 {
            let view = UIView()
            view.backgroundColor = UIColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1)
            return view
        } else {
            let view = SettingsHeaderView()
            view.backgroundColor = tableView.backgroundColor
            view.o_label.text = section == 0 ? "ACCOUNT" : "REMINDERS"
            view.o_topView.isHidden = section == 0
            view.o_textView.isHidden = section == 0 || APP.notificationsAllowed
            return view
        }
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 2
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction.init(style: UITableViewRowActionStyle.normal, title: "Remove", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            
            if let id = self.reminders[indexPath.row].id {
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
            }
            
            self.reminders.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            
            if indexPath.row == 0 && self.reminders.count > 0 {
                self.tableView.reloadRows(at: [IndexPath.init(row: 0, section: 2)], with: .none)
            }
            if self.reminders.count == 0 {
                self.tableView.reloadSections([2], with: .none)
            }
            
            self.saveReminders()
        })
        return [delete]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 2
    }
}
