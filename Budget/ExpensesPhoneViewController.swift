//
//  ExpensesPhoneViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 11/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class ExpensesPhoneViewController: ExpensesBaseDeviceViewController, AddEditExpenseViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: viewRemovedAtBottomNotification, object: nil, queue: nil, using: { (notification) -> Void in
            NotificationCenter.default.post(Notification(name: datePickerControllerDidDisappearNotification))
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "expenses" {
            expensesViewController = segue.destination as? ExpensesViewController
            expensesViewController?.delegate = self
            expensesViewController?.tableSeparatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        } else if segue.identifier == "editExpense" {
            if let expense = sender as? Expense {
                let vc: AddEditExpenseViewController? = segue.destinationController()
                vc?.expense = expense.makeCopy()
                vc?.expense?.setDatabaseReference(ref: expense.getDatabaseReference())
                vc?.title = "Edit Expense"
                vc?.delegate = self
            }
        }
    }
    
    //MARK - AddEditExpenseViewControllerDelegate
    func addEditExpenseViewControllerWillDismiss(_ addEditExpenseViewController: AddEditExpenseViewController) {
        o_activityIndicator.stopAnimating()
    }
    
    //MARK - ExpensesViewControllerDelegate
    override func expensesViewController(_ expensesViewController: ExpensesViewController, didSelect expenseData: ExpenseWithCategoryData) {
        o_activityIndicator.startAnimating()
        performSegue(withIdentifier: "editExpense", sender: expenseData.expense)
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
}
