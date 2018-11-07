//
//  ExpensesViewController+Firebase.swift
//  Budget
//
//  Created by Vadik on 30/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseDatabase

extension ExpensesViewController {
    func registerToUpdates(category: Category) {
        let listRef = category.getDatabaseReference()?.child("expenses")
        
        listRef?.observe(.childAdded, with: { [unowned self] snapshot in
            let expense = Expense(snapshot: snapshot)
            if self.group(for: expense.id) == nil {
                self.addExpenseToModel(expense, category: category)
                self.tableView.reloadData()
                ExpensesRecorder.recordExpense(amount: expense.amount ?? 0)
            }
        })
        
        listRef?.observe(.childChanged, with: { [unowned self] snapshot in
            let expense = Expense(snapshot: snapshot)
            let expenseWith = self.removeExpenseFromModel(expense)
            self.addExpenseToModel(expense, category: category)
            self.tableView.reloadData()
            ExpensesRecorder.recordExpense(amount: (expense.amount ?? 0) - (expenseWith?.expense.amount ?? 0))
        })
        
        listRef?.observe(.childRemoved, with: { [unowned self] snapshot in
            let expense = Expense(snapshot: snapshot)
            self.removeExpenseFromModel(expense)
            self.tableView.reloadData()
            if let amount = expense.amount {
                ExpensesRecorder.recordExpense(amount: -amount)
            }
        })
    }
    
    func addExpenseToModel(_ expense: Expense, category: Category) {
        let expenseWithCategory = ExpenseWithCategoryData(expense: expense, category: category)
        if let newGroup = self.group(for: expense.date) {
            newGroup.expenses.append(expenseWithCategory)
        } else if let date = expense.date {
            self.groupedExpensesList?.append(GroupedExpneses(date: date, expenses: [expenseWithCategory]))
            self.sortExpenses()
        }
    }
    
    @discardableResult
    func removeExpenseFromModel(_ expense: Expense) -> ExpenseWithCategoryData? {
        if let group = self.group(for: expense.id) {
            if let index = group.expenses.index(where: { $0.expense.id == expense.id }) {
                return group.expenses.remove(at: index)
            }
        }
        return nil
    }
    
    func unregisterFromUpdates() {
        if let list = groupedExpensesList {
            for item in list {
                for expense in item.expenses {
                    expense.categoryRef?.child("expenses").removeAllObservers()
                }
            }
        }
    }

}
