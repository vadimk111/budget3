//
//  CategoryDetailPhoneViewController.swift
//  Budget
//
//  Created by Vadik on 24/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class CategoryDetailPhoneViewController: UIViewController, CategoryExpensesViewControllerDelegate {
    
    var expensesViewController: CategoryExpensesViewController?
    var category: Category?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(CategoryDetailPhoneViewController.onSignInStateChanged), name: signInStateChangedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CategoryDetailPhoneViewController.onSignInStateChanged), name: currentBudgetChangedNotification, object: nil)
        
        updateBalanceNavView()
    }
    
    func onSignInStateChanged() {
        _ = navigationController?.popViewController(animated: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateBalanceNavView() {
        if let category = category {
            let balanceView = NavBalanceView(frame: CGRect(x: 0, y: 0, width: 240, height: 36))
            balanceView.populate(amount: category.calculatedAmount, totalSpent: category.calculatedTotalSpent, title: category.title)
            balanceView.backgroundColor = UIColor.clear
            navigationItem.titleView = balanceView
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "expenses" {
            expensesViewController = segue.destination as? CategoryExpensesViewController
            expensesViewController?.delegate = self
            expensesViewController?.category = category
        } else if segue.identifier == "addExpense" {
            prepareForAddExpense(from: segue, sender: sender)
        } else if segue.identifier == "editExpense" {
            prepareForEditExpense(from: segue, sender: sender)
        }
    }
    
    func prepareForAddExpense(from segue: UIStoryboardSegue, sender: Any?) {
        let vc: AddEditExpenseViewController? = segue.destinationController()
        var parentCategory: Category? = sender as? Category
        if parentCategory == nil {
            parentCategory = category
        }
        vc?.parentRef = parentCategory?.getDatabaseReference()?.child("expenses")
        vc?.expense = Expense()
        vc?.expense?.date = Date()
        vc?.title = "Add Expense"
    }
    
    func prepareForEditExpense(from segue: UIStoryboardSegue, sender: Any?) {
        if let expense = sender as? Expense {
            let vc: AddEditExpenseViewController? = segue.destinationController()
            vc?.expense = expense
            vc?.title = "Edit Expense"
        }
    }
    
    //MARK - CategoryExpensesViewControllerDelegate
    func categoryExpensesViewControllerChanged(_ categoryExpensesViewController: CategoryExpensesViewController) {
        updateBalanceNavView()
    }
    
    func categoryExpensesViewController(_ categoryExpensesViewController: CategoryExpensesViewController, didSelect expense: Expense) {
        performSegue(withIdentifier: "editExpense", sender: expense)
    }
    
    func categoryExpensesViewController(_ categoryExpensesViewController: CategoryExpensesViewController, addExpenseTo category: Category) {
        performSegue(withIdentifier: "addExpense", sender: category)
    }
}
