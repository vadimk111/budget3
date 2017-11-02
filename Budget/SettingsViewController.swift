//
//  SettingsViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 20/12/2016.
//  Copyright © 2016 Vadim Kononov. All rights reserved.
//

import UIKit
import UserNotifications
import FirebaseDatabase

let showReminderskey = "showReminders"
let remindersDatakey = "remindersData"
let reminderNotification = "REMINDERNOTIFICATION"
let defaultBudgetId = "---default---"

protocol SettingsViewControllerDelegate: class {
    func settingsViewController(_ settingsViewController: SettingsViewController, shouldDisplayViewController viewController: UIViewController)
    func settingsViewControllerShouldDismissViewController(_ settingsViewController: SettingsViewController)
    func settingsViewController(_ settingsViewController: SettingsViewController, shouldDisplayAlert alert: UIAlertController)
}

class SettingsViewController: UITableViewController, AddEditReminderViewControllerDelegate {

    weak var delegate: SettingsViewControllerDelegate?
    var authentication: Authentication?
    var reminders: [ReminderData] = []
    var selectedReminderRow: IndexPath?
    var showReminders = UserDefaults.standard.bool(forKey: showReminderskey)
    var sharings: [Sharing] = []
    var selectedSharingRow: Int = 0
    
    var defaultBudget: Sharing {
        let budget = Sharing()
        budget.dbId = defaultBudgetId
        budget.title = "Default"
        return budget
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(onSignInStateChanged), name: signInStateChangedNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onFacebookLinkedChange), name: facebookLinkedChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onUserNotificationCenterChanged), name: userNotificationCenterAuthorizationChangedNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadSharings), name: sharedBudgetAddedNotification, object: nil)
        
        if let data = UserDefaults.standard.data(forKey: remindersDatakey),
            let remindersArr = NSKeyedUnarchiver.unarchiveObject(with: data) as? [ReminderData] {
            reminders = remindersArr
        }
        
        loadSharings()
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
    
    @objc func onSignInStateChanged() {
        loadSharings()
        tableView.reloadSections([0], with: .none)
    }
    
    @objc func onFacebookLinkedChange() {
        tableView.reloadSections([0], with: .none)
    }
    
    @objc func onUserNotificationCenterChanged() {
        tableView.reloadSections([2], with: .automatic)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func loadSharings() {
        sharings = []
        sharings.append(defaultBudget)
        
        ModelHelper.sharingReference()?.observeSingleEvent(of: .value, with: { [unowned self] (snapshot) in
            for child in snapshot.children {
                self.sharings.append(Sharing(snapshot: child as! DataSnapshot))
            }
            
            self.tableView.reloadSections([1], with: .fade)
        })
    }
    
    func saveReminders() {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: reminders)
        UserDefaults.standard.set(encodedData, forKey: remindersDatakey)
        UserDefaults.standard.synchronize()
    }
    
    func deselectSelectedReminder() {
        if let _ = selectedReminderRow {
            tableView.deselectRow(at: selectedReminderRow!, animated: true)
            selectedReminderRow = nil
        }
    }
    
    func addEditReminderViewControllerDidCancel(_ addEditReminderViewController: AddEditReminderViewController) {
        deselectSelectedReminder()
    }
    
    func addEditReminderViewController(_ addEditReminderViewController: AddEditReminderViewController, didSave data: ReminderData) {
        if let id = data.id {
            if let index = reminders.index(where: { (reminderData: ReminderData) -> Bool in id == reminderData.id }) {
                reminders.remove(at: index)
                reminders.insert(data, at: index)
                tableView.reloadRows(at: [IndexPath.init(row: index, section: 3)], with: .fade)
            }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        } else {
            data.id = UUID().uuidString
            reminders.append(data)
            tableView.insertRows(at: [IndexPath.init(row: reminders.count - 1, section: 3)], with: .fade)
        }
        
        saveReminders()
        scheduleNotification(for: data)
        deselectSelectedReminder()
    }
    
    func scheduleAllNotifications() {
        for reminder in reminders {
            scheduleNotification(for: reminder)
        }
    }
    
    func scheduleNotification(for reminder: ReminderData) {
        if let identifier = reminder.id {
            
            let content = UNMutableNotificationContent()
            content.body = "Time to update your expenses"
            content.sound = UNNotificationSound.default()
            content.categoryIdentifier = reminderNotification
            
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: reminder.date)
            let minute = calendar.component(.minute, from: reminder.date)
            let weekDay = calendar.component(.weekday, from: reminder.date)
            let day = calendar.component(.day, from: reminder.date)
            
            var comp = DateComponents()
            comp.hour = hour
            comp.minute = minute
            
            switch reminder.repeatType {
            case .weekly:
                comp.weekday = weekDay
                break
            case .monthly:
                comp.day = day
            default:
                break
            }
            
            let trigger = UNCalendarNotificationTrigger.init(dateMatching: comp, repeats: reminder.repeatType != .none)
            
            let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            })
        }
    }
    
    func displayAlert(_ alert: UIAlertController) {
        if let delegate = delegate {
            delegate.settingsViewController(self, shouldDisplayAlert: alert)
        } else {
            present(alert, animated: true, completion: nil)
        }
    }
}
