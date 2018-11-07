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
        if APP.user == nil {
            return 0
        }
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if APP.user?.isAnonymous == true {
                return 2
            }
            if !Authentication.isFacebookAccountConnected() {
                return 2
            }
            if Authentication.canDisconnectFacebookAccount() {
                return 2
            }
            return 1
        }
        if section == 1 {
            return sharings.count
        }
        if section == 2 {
            return 1
        }
        if section == 3 {
            return showReminders ? reminders.count : 0
        }
        if section == 4 {
            return showReminders ? 1 : 0
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "accountCells", for: indexPath) as! AccountTableViewCell
                cell.build()
                return cell
            }
            if indexPath.row == 1 {
                if APP.user?.isAnonymous == true {
                    return tableView.dequeueReusableCell(withIdentifier: "anonymousCells", for: indexPath) as! AnonymousTableViewCell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "facebookCells", for: indexPath) as! FacebookTableViewCell
                    cell.delegate = self
                    cell.isConnected = Authentication.isFacebookAccountConnected()
                    return cell
                }
            }
            return UITableViewCell()
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "budgetCells", for: indexPath) as! BudgetTableViewCell
            var isSelected = false
            if let sharingDbId = UserDefaults.standard.string(forKey: APP.currentBudgetKey) {
                isSelected = sharingDbId == sharings[indexPath.row].dbId
            } else {
                isSelected = sharings[indexPath.row].dbId == defaultBudgetId
            }
            if isSelected {
                selectedSharingRow = indexPath.row
            }
            cell.populate(with: sharings[indexPath.row], isSelected: isSelected, hideSeparator: indexPath.row == sharings.count - 1)
            cell.delegate = self
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "remindersCells", for: indexPath) as! RemindersTableViewCell
            cell.delegate = self
            cell.o_switch.isOn = UserDefaults.standard.bool(forKey: showReminderskey)
            return cell
        } else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "scheduledReminderCells", for: indexPath) as! ScheduledReminderTableViewCell
            cell.populate(with: reminders[indexPath.row], showSeparator: indexPath.row > 0)
            return cell
        } else if indexPath.section == 4 {
            return tableView.dequeueReusableCell(withIdentifier: "addReminderCells", for: indexPath)
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 48
        }
        if section == 1 {
            return 80
        }
        if section == 2 {
            return APP.notificationsAllowed ? 80 : 130
        }
        if section == 4 && showReminders {
            return reminders.count > 0 ? 1 : 0
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let view = SettingsHeaderView()
            view.backgroundColor = tableView.backgroundColor
            view.o_label.text = "ACCOUNT"
            view.o_topView.isHidden = true
            view.o_textView.isHidden = true
            return view
        }
        if section == 1 {
            let view = SettingsHeaderView()
            view.backgroundColor = tableView.backgroundColor
            view.o_label.text = "BUDGETS"
            view.o_topView.isHidden = false
            view.o_textView.isHidden = true
            return view
            
        }
        if section == 2 {
            let view = SettingsHeaderView()
            view.backgroundColor = tableView.backgroundColor
            view.o_label.text = "REMINDERS"
            view.o_topView.isHidden = false
            view.o_textView.isHidden = APP.notificationsAllowed
            return view
        }
        if section == 4 {
            let view = UIView()
            view.backgroundColor = UIColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1)
            return view
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 3
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1 || indexPath.section == 3
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedReminderRow = indexPath
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 3 {
            let delete = UITableViewRowAction.init(style: UITableViewRowAction.Style.normal, title: "Remove", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
                
                if let id = self.reminders[indexPath.row].id {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
                }
                
                self.reminders.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                
                if indexPath.row == 0 && self.reminders.count > 0 {
                    self.tableView.reloadRows(at: [IndexPath.init(row: 0, section: indexPath.section)], with: .none)
                }
                if self.reminders.count == 0 {
                    self.tableView.reloadSections([indexPath.section], with: .none)
                }
                
                self.saveReminders()
            })
            return [delete]
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let share = UITableViewRowAction.init(style: UITableViewRowAction.Style.normal, title: "Share", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
                    if let user = APP.user, let url = URL(string: "\(appPrefix + user.uid)") {
                        let objectsToShare = ["Join my Budget Doctor:", url] as [Any]
                        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                        activityVC.excludedActivityTypes = [.airDrop, .saveToCameraRoll, .addToReadingList, .openInIBooks]
                        self.present(activityVC, animated: true, completion: nil)
                    }
                })
                return [share]
            } else {
                let delete = UITableViewRowAction.init(style: UITableViewRowAction.Style.normal, title: "Remove", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
                    let sharingToDelete = self.sharings[indexPath.row]
                    sharingToDelete.delete()
                    self.sharings.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    
                    if sharingToDelete.dbId == UserDefaults.standard.string(forKey: APP.currentBudgetKey) {
                        UserDefaults.standard.removeObject(forKey: APP.currentBudgetKey)
                        UserDefaults.standard.synchronize()
                        self.selectedSharingRow = 0
                        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: indexPath.section)) as? BudgetTableViewCell {
                            cell.markSelected(true)
                        }
                        NotificationCenter.default.post(Notification(name: currentBudgetChangedNotification))
                    }
                    if self.sharings.count == 1 {
                        self.tableView.reloadSections([indexPath.section], with: .none)
                    }
                })
                return [delete]
            }
        }
        return nil
    }
}
