//
//  CategoryExpensesViewController+Firebase.swift
//  Budget
//
//  Created by Vadik on 02/04/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import Foundation
import FirebaseDatabase

extension CategoryExpensesViewController {
    
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
    
    func registerToUpdates(expensesRef: DatabaseReference?, section: Int) {
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
                    ExpensesRecorder.recordExpense(amount: expense.amount ?? 0)
                }
            })
            
            expensesRef?.observe(.childChanged, with: { [unowned self] snapshot in
                let category = section == 0 ? self.category! : self.category!.subCategories![section - 1]
                let expense = Expense(snapshot: snapshot)
                if let index = category.expenses?.index(where: { $0.id == expense.id } ) {
                    let oldExpense = category.expenses?.remove(at: index)
                    category.expenses?.insert(expense, at: index)
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: section)) as? ExpenseTableViewCell {
                        cell.update(with: expense)
                    }
                    self.delegate?.categoryExpensesViewControllerChanged(self)
                    ExpensesRecorder.recordExpense(amount: (expense.amount ?? 0) - (oldExpense?.amount ?? 0))
                }
            })
            
            expensesRef?.observe(.childRemoved, with: { [unowned self] snapshot in
                let category = section == 0 ? self.category! : self.category!.subCategories![section - 1]
                let expense = Expense(snapshot: snapshot)
                if let index = category.expenses?.index(where: { $0.id == expense.id }) {
                    category.expenses?.remove(at: index)
                    self.tableView.deleteRows(at: [IndexPath.init(row: index, section: section)], with: .fade)
                    self.delegate?.categoryExpensesViewControllerChanged(self)
                    if let amount = expense.amount {
                        ExpensesRecorder.recordExpense(amount: -amount)
                    }
                }
            })
        }
    }
}
