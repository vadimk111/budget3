//
//  ExpensesPhoneViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 11/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class ExpensesPhoneViewController: ExpensesBaseDeviceViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "expenses" {
            expensesViewController = segue.destination as? ExpensesViewController
            expensesViewController?.delegate = self
            expensesViewController?.tableSeparatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        } else if segue.identifier == "editExpense" {
            if let expense = sender as? Expense {
                let vc: AddEditExpenseViewController? = segue.destinationController()
                vc?.expense = expense
                vc?.title = "Edit Expense"
            }
        }
    }
    
    //MARK - ExpensesViewControllerDelegate
    override func expensesViewController(_ expensesViewController: ExpensesViewController, didSelect expenseData: ExpenseWithCategoryData) {
        performSegue(withIdentifier: "editExpense", sender: expenseData.expense)
    }
    
    //MARK - DateChangerDelegate
    override func dateChanger(_ dateChanger: DateChanger, didCreateDatePicker datePicker: DatePickerView) {
        presentDatePickerOverCurrentContext(datePicker: datePicker)
    }
        
    override func dateChanger(_ dateChanger: DateChanger, didChangeDate date: Date) {
        super.dateChanger(dateChanger, didChangeDate: date)
        closeDatePicker()
    }
}
