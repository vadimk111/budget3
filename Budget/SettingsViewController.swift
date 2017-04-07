//
//  SettingsViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 20/12/2016.
//  Copyright © 2016 Vadim Kononov. All rights reserved.
//

import UIKit
import UserNotifications

let showReminderskey = "showReminders"
let remindersDatakey = "remindersData"

protocol SettingsViewControllerDelegate: class {
    func settingsViewController(_ settingsViewController: SettingsViewController, shouldDisplayViewController viewController: UIViewController)
    func settingsViewController(_ settingsViewController: SettingsViewController, shouldDismissViewController viewController: UIViewController)
    func settingsViewController(_ settingsViewController: SettingsViewController, shouldDisplayAlert alert: UIAlertController)
}

class SettingsViewController: UITableViewController, AddEditReminderViewControllerDelegate {

    weak var delegate: SettingsViewControllerDelegate?
    var reminders: [ReminderData] = []
    var showReminders = UserDefaults.standard.bool(forKey: showReminderskey)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.onSignInStateChanged), name: signInStateChangedNotification, object: nil)
        
        if let data = UserDefaults.standard.data(forKey: remindersDatakey),
            let remindersArr = NSKeyedUnarchiver.unarchiveObject(with: data) as? [ReminderData] {
            reminders = remindersArr
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let isEdit = segue.identifier == "editReminder"
        if isEdit || segue.identifier == "addReminder" {
            let vc: AddEditReminderViewController? = segue.destinationController()
            vc?.delegate = self
            
            if isEdit {
                if let indexPath = tableView.indexPathForSelectedRow {
                    vc?.reminderData = reminders[indexPath.row]
                }
            }
        }
    }
    
    func onSignInStateChanged() {
        reload()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func reload() {
        tableView.reloadData()
    }
    
    func saveReminders() {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: reminders)
        UserDefaults.standard.set(encodedData, forKey: remindersDatakey)
        UserDefaults.standard.synchronize()
    }
            
    func addEditReminderViewController(_ addEditReminderViewController: AddEditReminderViewController, didSave data: ReminderData) {
        if let id = data.id {
            if let index = reminders.index(where: { (reminderData: ReminderData) -> Bool in id == reminderData.id }) {
                reminders.remove(at: index)
                reminders.insert(data, at: index)
                tableView.reloadRows(at: [IndexPath.init(row: index, section: 2)], with: .fade)
            }
        } else {
            data.id = UUID().uuidString
            reminders.append(data)
            tableView.insertRows(at: [IndexPath.init(row: reminders.count - 1, section: 2)], with: .fade)
        }
        saveReminders()
    }
}
