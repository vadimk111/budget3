//
//  ExpensesBaseDeviceViewController.swift
//  Budget
//
//  Created by Vadik on 30/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class ExpensesBaseDeviceViewController: UIViewController, DateChangerDelegate, ExpensesViewControllerDelegate {

    var expensesViewController: ExpensesViewController?
    var timer: Timer?
    
    @IBOutlet weak var o_dateChanger: DateChanger!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(ExpensesBaseDeviceViewController.onBudgetChanged), name: budgetChangedNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: signInStateChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: currentBudgetChangedNotification, object: nil)
        
        o_dateChanger.delegate = self
        o_dateChanger.date = Date()
        
        reload()
    }
    
    func onBudgetChanged() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [unowned self] (timer) in
            self.timer = nil
            self.reload()
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func reload() {
        expensesViewController?.reload()
    }
    
    func onDateChanged() {
        
    }
    
    //MARK - DateChangerDelegate
    func dateChangerDidGoNext(_ dateChanger: DateChanger) {
        o_dateChanger.date = expensesViewController?.goNextMonth()
        onDateChanged()
    }
    
    func dateChangerDidGoPrev(_ dateChanger: DateChanger) {
        o_dateChanger.date = expensesViewController?.goPrevMonth()
        onDateChanged()
    }
    
    func dateChanger(_ dateChanger: DateChanger, didCreateDatePicker datePicker: DatePickerView) {
    }
    
    func dateChanger(_ dateChanger: DateChanger, didChangeDate date: Date) {
        expensesViewController?.changeToDate(date)
        o_dateChanger.date = date
        onDateChanged()
    }

    //MARK - ExpensesViewControllerDelegate
    func expensesViewControllerRowDeselected(_ expensesViewController: ExpensesViewController) {
        
    }
    
    func expensesViewController(_ expensesViewController: ExpensesViewController, didSelect expenseData: ExpenseWithCategoryData) {
        
    }
}
