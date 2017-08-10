//
//  CategoriesUniversalViewController+Segues.swift
//  Budget
//
//  Created by Vadik on 27/07/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

extension CategoriesUniversalViewController {
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "addCategory" && (isCompactWidth ? o_addBarButton.tag == 1 : o_addCategoryBtn.tag == 1) {
            let a = UIAlertController(title: "Delete all categories ?", message: nil, preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "Delete", style: .default) { action -> Void in
                self.categoriesViewController?.clearBudget()
                self.didTapEdit(self.isCompactWidth ? self.o_editBarButton : self.o_editCategoryBtn)
            })
            a.addAction(UIAlertAction(title: "Cancel", style: .default) { action -> Void in })
            self.present(a, animated: true, completion: nil)
            return false
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categories" {
            categoriesViewController = segue.destination as? CategoriesViewController
            categoriesViewController?.delegate = self
            categoriesViewController?.tableSeparatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: isCompactWidth ? 15 : 5)
        } else if segue.identifier == "addCategory" {
            prepareForAddCategory(from: segue)
        } else if segue.identifier == "editCategoryPad" || segue.identifier == "editCategoryPhone" {
            prepareForEditCategory(from: segue, sender: sender)
        } else if segue.identifier == "drillDown" {
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            if let category = sender as? Category {
                (segue.destination as? CategoryDetailPhoneViewController)?.category = category
            }
        } else if segue.identifier == "categoryExpenses" {
            categoryExpensesViewController = segue.destination as? CategoryExpensesViewController
            categoryExpensesViewController?.delegate = self
        } else if segue.identifier == "addExpense" {
            prepareForAddExpense(from: segue, sender: sender)
        } else if segue.identifier == "editExpense" {
            prepareForEditExpense(from: segue, sender: sender)
        }
    }

    
    func prepareForAddCategory(from segue: UIStoryboardSegue) {
        if let categoriesViewController = categoriesViewController {
            let vc: AddEditCategoryViewController? = segue.destinationController()
            vc?.delegate = self
            vc?.parents = categoriesViewController.availableParents
            if let last = categoriesViewController.availableParents.last {
                vc?.highestOrder = last.order
            }
            vc?.budgetRef = categoriesViewController.budgetRef
        }
    }
    
    func prepareForEditCategory(from segue: UIStoryboardSegue, sender: Any?) {
        if let categoriesViewController = categoriesViewController {
            if let category = sender as? Category {
                let vc: AddEditCategoryViewController? = segue.destinationController()
                vc?.category = category.makeCopy()
                vc?.category?.setDatabaseReference(ref: category.getDatabaseReference())
                
                if category.subCategories == nil {
                    vc?.parents = categoriesViewController.availableParents.filter({ $0.id != category.id })
                }
                if let last = categoriesViewController.availableParents.last {
                    vc?.highestOrder = last.order
                }
            }
        }
    }
    
    func prepareForAddExpense(from segue: UIStoryboardSegue, sender: Any?) {
        let vc: AddEditExpenseViewController? = segue.destinationController()
        var parentCategory: Category? = sender as? Category
        if parentCategory == nil {
            parentCategory = categoryExpensesViewController?.category
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

}
