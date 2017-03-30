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
        }
    }
    
    //MARK - ExpensesViewControllerDelegate
    override func expensesViewController(_ expensesViewController: ExpensesViewController, didSelect expense: Expense) {
        
    }
}
