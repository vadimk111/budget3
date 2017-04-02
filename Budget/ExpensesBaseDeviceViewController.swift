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
        
        NotificationCenter.default.addObserver(self, selector: #selector(ExpensesBaseDeviceViewController.onSignInStateChanged), name: signInStateChangedNotification, object: nil)
        
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
    
    func onSignInStateChanged() {
        reload()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func reload() {
        expensesViewController?.reload()
    }
        
    //MARK - DateChangerDelegate
    func dateChangerDidGoNext(_ dateChanger: DateChanger) {
        o_dateChanger.date = expensesViewController?.goNextMonth()
    }
    
    func dateChangerDidGoPrev(_ dateChanger: DateChanger) {
        o_dateChanger.date = expensesViewController?.goPrevMonth()
    }
    
    //MARK - ExpensesViewControllerDelegate
    func expensesViewControllerRowDeselected(_ expensesViewController: ExpensesViewController) {
        
    }
    
    func expensesViewController(_ expensesViewController: ExpensesViewController, didSelect expense: Expense) {
        
    }
}
