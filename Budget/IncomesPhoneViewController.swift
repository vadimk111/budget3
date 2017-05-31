//
//  IncomesPhoneViewController.swift
//  Budget
//
//  Created by Vadik on 31/05/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class IncomesPhoneViewController: IncomesBaseDeviceViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "incomes" {
            incomesViewController = segue.destination as? IncomesViewController
            incomesViewController?.delegate = self
            incomesViewController?.tableSeparatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        } else if segue.identifier == "addIncome" {
            prepareForAddIncome(from: segue)
        } else if segue.identifier == "editIncome" {
            prepareForEditIncome(from: segue, sender: sender)
        }
    }
    
    //MARK - ExpensesViewControllerDelegate
    override func incomesViewController(_ incomesViewController: IncomesViewController, didSelect income: Income) {
        performSegue(withIdentifier: "editIncome", sender: income)
    }
}
