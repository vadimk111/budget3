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
        return 6
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
        if section == 1 {
            return 1
        }
        if section == 2 {
            return showReminders ? reminders.count : 0
        }
        if section == 3 {
            return showReminders ? 1 : 0
        }
        if section == 4 {
            return sharings.count
        }
        if section == 5 {
            return 1
        }
        return 0
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
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "scheduledReminderCells", for: indexPath) as! ScheduledReminderTableViewCell
            cell.populate(with: reminders[indexPath.row], showSeparator: indexPath.row > 0)
            return cell
        } else if indexPath.section == 3 {
            return tableView.dequeueReusableCell(withIdentifier: "addReminderCells", for: indexPath)
        } else if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "budgetCells", for: indexPath) as! BudgetTableViewCell
            cell.populate(with: sharings[indexPath.row], hideSeparator: indexPath.row == sharings.count - 1)
            if let sharingDbId = UserDefaults.standard.string(forKey: currentBudgetKey) {
                if sharingDbId == sharings[indexPath.row].dbId {
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
            } else if sharings[indexPath.row].dbId == defaultBudgetId {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
            return cell
        } else if indexPath.section == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "shareBudgetCells", for: indexPath) as! ShareBudgetTableViewCell
            cell.delegate = self
            return cell
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
        if section == 3 && showReminders {
            return reminders.count > 0 ? 1 : 0
        }
        if section == 4 {
            return 80
        }
        if section == 5 {
            return 1
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
            view.o_label.text = "REMINDERS"
            view.o_topView.isHidden = false
            view.o_textView.isHidden = APP.notificationsAllowed
            return view
        }
        if section == 2 || section == 3 || section == 5 {
            let view = UIView()
            view.backgroundColor = UIColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1)
            return view
        }
        if section == 4 {
            let view = SettingsHeaderView()
            view.backgroundColor = tableView.backgroundColor
            view.o_label.text = "BUDGETS"
            view.o_topView.isHidden = true
            view.o_textView.isHidden = true
            return view
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 2 || indexPath.section == 4
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 2 || (indexPath.section == 4 && indexPath.row != 0)
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 4 {
            if let selected = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selected, animated: true)
            }
        }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        return tableView.indexPathForSelectedRow != indexPath ? indexPath : nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 4 {
            let newId = sharings[indexPath.row].dbId
            if newId == defaultBudgetId {
                UserDefaults.standard.removeObject(forKey: currentBudgetKey)
            } else {
                UserDefaults.standard.set(newId, forKey: currentBudgetKey)
            }
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(Notification(name: currentBudgetChangedNotification))
        } else if indexPath.section == 2 {
            selectedReminderRow = indexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 2 {
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
        } else if indexPath.section == 4 && sharings[indexPath.row].dbId != defaultBudgetId {
            let delete = UITableViewRowAction.init(style: UITableViewRowActionStyle.normal, title: "Remove", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
                let sharingToDelete = self.sharings[indexPath.row]
                
                sharingToDelete.delete()
                self.sharings.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
                if sharingToDelete.dbId == UserDefaults.standard.string(forKey: currentBudgetKey) {
                    UserDefaults.standard.removeObject(forKey: currentBudgetKey)
                    UserDefaults.standard.synchronize()
                    tableView.selectRow(at: IndexPath.init(row: 0, section: indexPath.section), animated: false, scrollPosition: .none)
                    NotificationCenter.default.post(Notification(name: currentBudgetChangedNotification))
                }
            })
            return [delete]
        }
        return nil
    }
}
