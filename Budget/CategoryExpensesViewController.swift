//
//  CategoryExpensesViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 10/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseDatabase

let categoryChangedNotification = Notification.Name(rawValue: "categoryChanged")

protocol CategoryExpensesViewControllerDelegate: class {
    func categoryExpensesViewController(_ categoryExpensesViewController: CategoryExpensesViewController, didSelect expense: Expense)
    func categoryExpensesViewController(_ categoryExpensesViewController: CategoryExpensesViewController, addExpenseTo category: Category)
    func categoryExpensesViewControllerChanged(_ categoryExpensesViewController: CategoryExpensesViewController)
}

class CategoryExpensesViewController: UITableViewController, SubCategoryHeaderViewDelegate {

    var category: Category? {
        willSet {
            unregisterFromUpdates()
        }
        didSet {
            tableView.reloadData()
            registerToUpdates()
        }
    }
    
    weak var delegate: CategoryExpensesViewControllerDelegate?
    
    deinit {
        unregisterFromUpdates()
    }

    func registerToUpdates() {
        registerToUpdates(expensesRef: category?.getDatabaseReference()?.child("expenses"), section: 0)
        
        if let subCategories = category?.subCategories {
            var index = 1
            for item in subCategories {
                registerToUpdates(expensesRef: item.getDatabaseReference()?.child("expenses"), section: index)
                index += 1
            }
        }
    }
    
    func unregisterFromUpdates() {
        category?.getDatabaseReference()?.child("expenses").removeAllObservers()
        if let subCategories = category?.subCategories {
            for item in subCategories {
                item.getDatabaseReference()?.child("expenses").removeAllObservers()
            }
        }
    }
        
    func registerToUpdates(expensesRef: FIRDatabaseReference?, section: Int) {
        if let _ = category {
            expensesRef?.observe(.childAdded, with: { [unowned self] snapshot in
                let category = section == 0 ? self.category! : self.category!.subCategories![section - 1]
                if category.expenses == nil {
                    category.expenses = []
                }
                let expense = Expense(snapshot: snapshot)
                if !category.expenses!.contains(where: { $0.id == expense.id } ) {
                    category.expenses!.append(expense)
                    self.tableView.insertRows(at: [IndexPath.init(row: category.expenses!.count - 1, section: section)], with: .fade)
                    self.delegate?.categoryExpensesViewControllerChanged(self)
                }
            })
            
            expensesRef?.observe(.childChanged, with: { [unowned self] snapshot in
                let category = section == 0 ? self.category! : self.category!.subCategories![section - 1]
                let expense = Expense(snapshot: snapshot)
                if let index = category.expenses?.index(where: { $0.id == snapshot.key } ) {
                    category.expenses?.remove(at: index)
                    category.expenses?.insert(expense, at: index)
                    self.tableView.reloadRows(at: [IndexPath.init(row: index, section: section)], with: .none)
                    self.delegate?.categoryExpensesViewControllerChanged(self)
                }
            })
            
            expensesRef?.observe(.childRemoved, with: { [unowned self] snapshot in
                let category = section == 0 ? self.category! : self.category!.subCategories![section - 1]
                let expense = Expense(snapshot: snapshot)
                if let index = category.expenses?.index(where: { $0.id == expense.id }) {
                    category.expenses?.remove(at: index)
                    self.tableView.deleteRows(at: [IndexPath.init(row: index, section: section)], with: .fade)
                    self.delegate?.categoryExpensesViewControllerChanged(self)
                }
            })
        }
    }
    
    func expense(for indexPath: IndexPath) -> Expense? {
        if indexPath.section == 0 {
            return category?.expenses?[indexPath.row]
        } else if let subExpenses = category?.subCategories?[indexPath.section - 1].expenses {
            return subExpenses[indexPath.row]
        }
        return nil
    }
    
    //MARK - SubCategoryHeaderViewDelegate
    func subCategoryHeaderViewAdd(_ subCategoryHeaderView: SubCategoryHeaderView) {
        if let subCategories = category?.subCategories {
            delegate?.categoryExpensesViewController(self, addExpenseTo: subCategories[subCategoryHeaderView.section - 1])
        }
    }
}
