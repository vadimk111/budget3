//
//  ExpensesPadViewController.swift
//  Budget
//
//  Created by Vadik on 30/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class ExpensesPadViewController: UIViewController, DateChangerDelegate {

    var expensesViewController: ExpensesViewController?
    var timer: Timer?
    
    @IBOutlet weak var o_dateChanger: DateChanger!
    @IBOutlet weak var o_expensesContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        o_expensesContainer.layer.shadowRadius = 2
        o_expensesContainer.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        o_expensesContainer.layer.shadowOpacity = 1
        o_expensesContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "expenses" {
            expensesViewController = segue.destination as? ExpensesViewController
        }
    }
    
    //MARK - DateChangerDelegate
    func dateChangerDidGoNext(_ dateChanger: DateChanger) {
        o_dateChanger.date = expensesViewController?.goNextMonth()
    }
    
    func dateChangerDidGoPrev(_ dateChanger: DateChanger) {
        o_dateChanger.date = expensesViewController?.goPrevMonth()
    }
}
