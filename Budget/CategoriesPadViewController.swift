//
//  CategoriesPadViewController.swift
//  Budget
//
//  Created by Vadik on 15/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class CategoriesPadViewController: CategoriesBaseDeviceViewController, CategoryExpensesViewControllerDelegate {

    var expensesViewController: CategoryExpensesViewController?
    
    @IBOutlet weak var o_categoriesContainer: UIView!
    @IBOutlet weak var o_addExpenseBtn: UIButton!
    @IBOutlet weak var o_editCategoryBtn: UIButton!
    @IBOutlet weak var o_addCategoryBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        o_categoriesContainer.layer.shadowRadius = 2
        o_categoriesContainer.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        o_categoriesContainer.layer.shadowOpacity = 1
        o_categoriesContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        o_categoriesHeaderView.layer.shadowRadius = 2
        o_categoriesHeaderView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        o_categoriesHeaderView.layer.shadowOpacity = 1
        o_categoriesHeaderView.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
        
    @IBAction func didTapEdit(_ sender: UIButton) {
        if let categoriesViewController = categoriesViewController {
            if categoriesViewController.tableView.isEditing {
                sender.setTitle("Edit", for: .normal)
                o_addCategoryBtn.setTitle("Add Category", for: .normal)
                o_addCategoryBtn.tag = 0
                categoriesViewController.tableView.setEditing(false, animated: true)
            } else {
                categoriesViewController.tableView.setEditing(true, animated: true)
                sender.setTitle("Done", for: .normal)
                o_addCategoryBtn.setTitle("Clear", for: .normal)
                o_addCategoryBtn.tag = 1
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "addCategory" && o_addCategoryBtn.tag == 1 {
            let a = UIAlertController(title: "Delete all categories ?", message: nil, preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "Delete", style: .default) { action -> Void in
                self.categoriesViewController?.clearBudget()
                self.didTapEdit(self.o_editCategoryBtn)
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
            categoriesViewController?.tableSeparatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 5)
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
        let vc: AddEditExpenseViewController? = segue.destinationController()
        var parentCategory: Category? = sender as? Category
        if parentCategory == nil {
            parentCategory = expensesViewController?.category
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
    
    //MARK - CategoriesViewControllerDelegate
    override func categoriesViewController(_ categoriesViewController: CategoriesViewController, didSelect category: Category) {
        o_addExpenseBtn.isEnabled = true
        expensesViewController?.category = category
    }
    
    override func categoriesViewControllerRowDeselected(_ categoriesViewController: CategoriesViewController) {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (Timer) -> Void in
            if categoriesViewController.tableView.indexPathForSelectedRow == nil {
                self.expensesViewController?.category = nil
                self.o_addExpenseBtn.isEnabled = false
            }
        })
    }
    
    override func categoriesViewControllerChanged(_ categoriesViewController: CategoriesViewController) {
        super.categoriesViewControllerChanged(categoriesViewController)
        o_editCategoryBtn.isEnabled = categoriesViewController.categories.count > 0
    }
    
    //MARK - CategoryExpensesViewControllerDelegate
    func categoryExpensesViewControllerChanged(_ categoryExpensesViewController: CategoryExpensesViewController) {

    }
    
    func categoryExpensesViewController(_ categoryExpensesViewController: CategoryExpensesViewController, didSelect expense: Expense) {
        performSegue(withIdentifier: "editExpense", sender: expense)
        if let indexPath = categoryExpensesViewController.tableView.indexPathForSelectedRow {
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { (Timer) -> Void in
                categoryExpensesViewController.tableView.deselectRow(at: indexPath, animated: true)
            })
        }
    }
    
    func categoryExpensesViewController(_ categoryExpensesViewController: CategoryExpensesViewController, addExpenseTo category: Category) {
        performSegue(withIdentifier: "addExpense", sender: category)
    }
}
