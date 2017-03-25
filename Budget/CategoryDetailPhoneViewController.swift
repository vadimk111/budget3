//
//  CategoryDetailPhoneViewController.swift
//  Budget
//
//  Created by Vadik on 24/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class CategoryDetailPhoneViewController: UIViewController, CategoryExpensesViewControllerDelegate {
    
    @IBOutlet weak var o_balanceNavView: BalanceView!
    
    var expensesViewController: CategoryExpensesViewController?
    var category: Category?
    var currentDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: signInStateChangedNotification, object: nil, queue: nil, using: { [unowned self] notification in
            _ = self.navigationController?.popViewController(animated: false)
        })
        
        updateBalanceNavView()
    }
    
    func updateBalanceNavView() {
        if let category = category {
            o_balanceNavView.populate(amount: category.calculatedAmount, totalSpent: category.calculatedTotalSpent, title: category.title)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "expenses" {
            expensesViewController = segue.destination as? CategoryExpensesViewController
            expensesViewController?.category = category
            expensesViewController?.currentDate = currentDate
        } else if segue.identifier == "addExpense" {
            prepareForAddExpense(from: segue, sender: sender)
        } else if segue.identifier == "editExpense" {
            prepareForEditExpense(from: segue, sender: sender)
        }
    }
    
    func prepareForAddExpense(from segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.addEditExpenseViewController()
        var parentCategory: Category?
        if sender is SubCategoryHeaderView {
            if let subCategories = category?.subCategories {
                parentCategory = subCategories[(sender as! SubCategoryHeaderView).section - 1]
            }
        } else {
            parentCategory = category
        }
        vc?.parentRef = parentCategory?.getDatabaseReference()?.child("expenses")
        vc?.expense = Expense()
        vc?.expense?.date = currentDate
        vc?.title = "Add Expense"
    }
    
    func prepareForEditExpense(from segue: UIStoryboardSegue, sender: Any?) {
        if let expense = sender as? Expense {
            let vc = segue.addEditExpenseViewController()
            vc?.expense = expense
            vc?.title = "Edit Expense"
        }
    }
    
    func categoryExpensesViewControllerChanged(_ categoryExpensesViewController: CategoryExpensesViewController) {
        updateBalanceNavView()
    }
    
    func categoryExpensesViewController(_ categoryExpensesViewController: CategoryExpensesViewController, didSelect expense: Expense) {
        performSegue(withIdentifier: "editExpense", sender: expense)
    }
}
