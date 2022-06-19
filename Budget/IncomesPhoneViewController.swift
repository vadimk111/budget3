//
//  IncomesPhoneViewController.swift
//  Budget
//
//  Created by Vadik on 31/05/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class IncomesPhoneViewController: IncomesBaseDeviceViewController, AddEditIncomeViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: viewRemovedAtBottomNotification, object: nil, queue: nil, using: { (notification) -> Void in
            NotificationCenter.default.post(Notification(name: datePickerControllerDidDisappearNotification))
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "incomes" {
            incomesViewController = segue.destination as? IncomesViewController
            incomesViewController?.delegate = self
            incomesViewController?.tableSeparatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        } else if segue.identifier == "addIncome" {
            prepareForAddIncome(from: segue)
        } else if segue.identifier == "editIncome" {
            if let income = sender as? Income {
                let vc: AddEditIncomeViewController? = segue.destinationController()
                vc?.income = income
                vc?.delegate = self
            }
        }
    }
    
    //MARK - ExpensesViewControllerDelegate
    override func incomesViewController(_ incomesViewController: IncomesViewController, didSelect income: Income) {
        o_activityIndicator.startAnimating()
        performSegue(withIdentifier: "editIncome", sender: income)
    }
    
    //MARK - DateChangerDelegate
    override func dateChanger(_ dateChanger: DateChanger, didCreateDatePicker datePicker: DatePickerView) {
        NotificationCenter.default.post(Notification(name: datePickerControllerWillAppearNotification))
        datePicker.backgroundColor = UIColor(red: 242 / 255, green: 242 / 255, blue: 242 / 255, alpha: 1)
        presentViewAtBottom(datePicker, height: 236)
    }
    
    override func dateChanger(_ dateChanger: DateChanger, didChangeDate date: Date) {
        super.dateChanger(dateChanger, didChangeDate: date)
        dismissViewAtBottom()
    }
    
    //MARK - AddEditIncomeViewControllerDelegate
    func addEditIncomeViewControllerWillDismiss(_ addEditIncomeViewController: AddEditIncomeViewController) {
        o_activityIndicator.stopAnimating()
    }
}
