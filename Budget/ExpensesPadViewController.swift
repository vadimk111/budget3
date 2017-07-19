//
//  ExpensesPadViewController.swift
//  Budget
//
//  Created by Vadik on 30/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class ExpensesPadViewController: ExpensesBaseDeviceViewController {

    @IBOutlet weak var o_expensesContainer: UIView!
    
    var expenseDetailsViewController: ExpenseDetailsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        o_expensesContainer.layer.shadowRadius = 2
        o_expensesContainer.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        o_expensesContainer.layer.shadowOpacity = 1
        o_expensesContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "expenses" {
            expensesViewController = segue.destination as? ExpensesViewController
            expensesViewController?.delegate = self
            expensesViewController?.tableSeparatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        } else if segue.identifier == "expenseDetails" {
            expenseDetailsViewController = segue.destination as? ExpenseDetailsViewController
        } 
    }
    
    override func onDateChanged() {
        expenseDetailsViewController?.expenseData = nil
    }
    
    //MARK - ExpensesViewControllerDelegate
    override func expensesViewController(_ expensesViewController: ExpensesViewController, didSelect expenseData: ExpenseWithCategoryData) {
        expenseDetailsViewController?.expenseData = expenseData
    }
    
    override func expensesViewControllerRowDeselected(_ expensesViewController: ExpensesViewController) {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (Timer) -> Void in
            if expensesViewController.tableView.indexPathForSelectedRow == nil {
                self.expenseDetailsViewController?.expenseData = nil
            }
        })
    }
    
    //MARK - DateChangerDelegate
    override func dateChanger(_ dateChanger: DateChanger, didCreateDatePicker datePicker: DatePickerView) {
        datePicker.backgroundColor = UIColor.white
        presentViewAsPopover(datePicker, viewSize: CGSize(width: 320, height: 236), sourceView: o_dateChanger, sourceRect: o_dateChanger.o_title.frame)
    }
    
    override func dateChanger(_ dateChanger: DateChanger, didChangeDate date: Date) {
        super.dateChanger(dateChanger, didChangeDate: date)
        dismiss(animated: true)
    }
}
