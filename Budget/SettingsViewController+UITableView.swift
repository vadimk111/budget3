//
//  SettingsViewController+UITableView.swift
//  Budget
//
//  Created by Vadik on 03/04/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

extension SettingsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if showReminders {
            return 4
        }
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return reminders.count
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountCells", for: indexPath) as! AccountTableViewCell
            cell.delegate = self
            cell.build()
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "remindersCells", for: indexPath) as! RemindersTableViewCell
            cell.delegate = self
            cell.o_switch.isOn = UserDefaults.standard.bool(forKey: showReminderskey)
            return cell
        } else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "scheduledReminderCells", for: indexPath) as! ScheduledReminderTableViewCell
            cell.populate(with: reminders[indexPath.row])
            return cell
        } else if indexPath.section == 3 {
            return tableView.dequeueReusableCell(withIdentifier: "addReminderCells", for: indexPath)
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 || section == 1 ? 48.0 : 0.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 || section == 1 {
            let view = SettingsHeaderView()
            view.backgroundColor = tableView.backgroundColor
            view.o_label.text = section == 0 ? "ACCOUNT" : "REMINDERS"
            return view
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 2
    }
}
