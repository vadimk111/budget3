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

        NotificationCenter.default.addObserver(forName: budgetChangedNotification, object: nil, queue: nil, using: { [unowned self] notification in
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (timer) in
                self.reload()
            })
        })
        
        NotificationCenter.default.addObserver(forName: signInStateChangedNotification, object: nil, queue: nil, using: { [unowned self] notification in
            self.reload()
        })
        
        o_dateChanger.delegate = self
        o_dateChanger.date = Date()
        
        reload()
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
