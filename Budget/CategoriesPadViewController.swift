//
//  CategoriesPadViewController.swift
//  Budget
//
//  Created by Vadik on 15/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseAuth

class CategoriesPadViewController: BaseDeviceViewController, CategoryExpensesViewControllerDelegate {

    var expensesViewController: CategoryExpensesViewController?
    var currentDate: Date?
    
    @IBAction func didTapEdit(_ sender: UIButton) {
        if let categoriesViewController = categoriesViewController {
            if categoriesViewController.tableView.isEditing {
                sender.setImage(UIImage(named: "edit-tool"), for: .normal)
                categoriesViewController.tableView.setEditing(false, animated: true)
            } else {
                categoriesViewController.tableView.setEditing(true, animated: true)
                sender.setImage(UIImage(named: "checked"), for: .normal)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categories" {
            categoriesViewController = segue.destination as? CategoriesViewController
            categoriesViewController?.delegate = self
        } else if segue.identifier == "expenses" {
            expensesViewController = segue.destination as? CategoryExpensesViewController
            expensesViewController?.delegate = self
        } else if segue.identifier == "addCategory" {
            prepareForAddCategory(from: segue)
        } else if segue.identifier == "editCategory" {
            prepareForEditCategory(from: segue, sender: sender)
        } else if segue.identifier == "addExpense" {
            prepareForAddExpense(from: segue, sender: sender)
        } else if segue.identifier == "editExpense" {
            prepareForEditExpense(from: segue, sender: sender)
        }
    }
    
    func prepareForAddExpense(from segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.addEditExpenseViewController()
        var parentCategory: Category? = sender as? Category
        if parentCategory == nil {
            parentCategory = expensesViewController?.category
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
    
    //MARK - CategoriesViewControllerDelegate
    override func categoriesViewController(_ categoriesViewController: CategoriesViewController, didSelect category: Category) {
        expensesViewController?.category = category
    }
    
    //MARK - CategoryExpensesViewControllerDelegate
    func categoryExpensesViewControllerChanged(_ categoryExpensesViewController: CategoryExpensesViewController) {

    }
    
    func categoryExpensesViewController(_ categoryExpensesViewController: CategoryExpensesViewController, didSelect expense: Expense) {
        performSegue(withIdentifier: "editExpense", sender: expense)
    }
    
    func categoryExpensesViewController(_ categoryExpensesViewController: CategoryExpensesViewController, addExpenseTo category: Category) {
        performSegue(withIdentifier: "addExpense", sender: category)
    }
}
