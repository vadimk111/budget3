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
let reminderNotification = "REMINDERNOTIFICATION"

protocol SettingsViewControllerDelegate: class {
    func settingsViewController(_ settingsViewController: SettingsViewController, shouldDisplayViewController viewController: UIViewController)
    func settingsViewControllerShouldDismissViewController(_ settingsViewController: SettingsViewController)
    func settingsViewController(_ settingsViewController: SettingsViewController, shouldDisplayAlert alert: UIAlertController)
}

class SettingsViewController: UITableViewController, AddEditReminderViewControllerDelegate {

    weak var delegate: SettingsViewControllerDelegate?
    var authentication: Authentication?
    var reminders: [ReminderData] = []
    var showReminders = UserDefaults.standard.bool(forKey: showReminderskey)
    
    @IBOutlet weak var o_shareButton: UIBarButtonItem!
    
    @IBAction func didTapShare(_ sender: UIBarButtonItem) {
        if let sharing = APP.user?.sharing {
            let a = UIAlertController(title: "Remove shared budget?", message: "", preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "Remove", style: .default) { action -> Void in
                sharing.delete()
                APP.user?.sharing = nil
                NotificationCenter.default.post(Notification(name: signInStateChangedNotification))
            })
            a.addAction(UIAlertAction(title: "Cancel", style: .default) { action -> Void in })
            self.present(a, animated: true, completion: nil)
        } else if let id = APP.user?.firUser.uid, let url = URL(string: "\(appPrefix + id)") {
            let objectsToShare = ["Join my Budget Doctor:", url] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.barButtonItem = sender
            activityVC.excludedActivityTypes = [.airDrop, .saveToCameraRoll, . addToReadingList, .openInIBooks]
            present(activityVC, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.onSignInStateChanged), name: signInStateChangedNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.onFacebookLinkedChange), name: facebookLinkedChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SettingsViewController.onUserNotificationCenterChanged), name: userNotificationCenterAuthorizationChangedNotification, object: nil)
        
        if let data = UserDefaults.standard.data(forKey: remindersDatakey),
            let remindersArr = NSKeyedUnarchiver.unarchiveObject(with: data) as? [ReminderData] {
            reminders = remindersArr
        }
        
        configureShareButton()
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
    
    func configureShareButton() {
        if let _ = APP.user {
            o_shareButton.isEnabled = true
            o_shareButton.image = APP.user?.sharing?.dbId != nil ? #imageLiteral(resourceName: "unlink") : #imageLiteral(resourceName: "share")
        } else {
            o_shareButton.isEnabled = false
            o_shareButton.image = nil
        }
    }
    
    func onSignInStateChanged() {
        configureShareButton()
        tableView.reloadSections([0], with: .none)
    }
    
    func onFacebookLinkedChange() {
        tableView.reloadSections([0], with: .none)
    }
    
    func onUserNotificationCenterChanged() {
        tableView.reloadSections([1], with: .automatic)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        } else {
            data.id = UUID().uuidString
            reminders.append(data)
            tableView.insertRows(at: [IndexPath.init(row: reminders.count - 1, section: 2)], with: .fade)
        }
        
        saveReminders()
        scheduleNotification(for: data)
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
