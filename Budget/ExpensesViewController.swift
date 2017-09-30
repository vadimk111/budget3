//
//  ExpensesViewController.swift
//  Budget
//
//  Created by Vadik on 30/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ExpenseWithCategoryData {
    var expense: Expense
    var categoryId: String?
    var categoryTitle: String?
    var categoryRef: DatabaseReference?
    
    init(expense: Expense, category: Category) {
        self.expense = expense
        categoryId = category.id
        categoryTitle = category.title
        categoryRef = category.getDatabaseReference()
    }
}

class GroupedExpneses {
    var date: Date
    var expenses: [ExpenseWithCategoryData]
    
    init(date: Date, expenses: [ExpenseWithCategoryData]) {
        self.date = date
        self.expenses = expenses
    }
}

protocol ExpensesViewControllerDelegate: class {
    func expensesViewController(_ expensesViewController: ExpensesViewController, didSelect expenseData: ExpenseWithCategoryData)
    func expensesViewControllerRowDeselected(_ expensesViewController: ExpensesViewController)
}

class ExpensesViewController: UITableViewController, OverviewTableViewCellDelegate {

    var groupedExpensesList: [GroupedExpneses]?
    var date: Date = Date()
    var delegate: ExpensesViewControllerDelegate?
    
    var tableSeparatorInset: UIEdgeInsets? {
        didSet {
            if let tableSeparatorInset = tableSeparatorInset {
                tableView.separatorInset = tableSeparatorInset
            }
        }
    }

    deinit {
        unregisterFromUpdates()
    }
    
    @IBAction func didPullToRefresh(_ sender: UIRefreshControl) {
        reload()
    }
    
    func reload() {
        unregisterFromUpdates()
        
        if let ref = ModelHelper.budgetReference(for: date) {
            ref.observeSingleEvent(of: .value, with: { snapshot in
                self.prepareExpenses(from: snapshot)
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            })
        } else {
            date = Date()
            groupedExpensesList = nil
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: false)
            }
            tableView.reloadData()
        }
    }
    
    func prepareExpenses(from snapshot: DataSnapshot) {
        var groupsByDate = [Date : [ExpenseWithCategoryData]]()
        
        for child in snapshot.children {
            let category = Category(snapshot: child as! DataSnapshot)
            registerToUpdates(category: category)
            
            if let cExpenses = category.expenses {
                for item in cExpenses {
                    if let date = item.date {
                        
                        if groupsByDate[date] == nil {
                            groupsByDate[date] = [ExpenseWithCategoryData]()
                        }
                        
                        groupsByDate[date]?.append(ExpenseWithCategoryData(expense: item, category: category))
                    }
                }
            }
        }
        
        groupedExpensesList = groupsByDate.map({
            return GroupedExpneses(date: $0.key, expenses: $0.value)
        })
        
        sortExpenses()
    }
    
    func sortExpenses() {
        groupedExpensesList?.sort(by: { (item1: GroupedExpneses, item2: GroupedExpneses) -> Bool in
            return item1.date > item2.date
        })
    }
    
    func group(for date: Date?) -> GroupedExpneses? {
        return groupedExpensesList?.filter({ $0.date == date }).first
    }
    
    func group(for expenseId: String?) -> GroupedExpneses? {
        if let list = groupedExpensesList {
            for collection in list {
                for expenseObj in collection.expenses {
                    if expenseObj.expense.id == expenseId {
                        return collection
                    }
                }
            }
        }
        return nil
    }

    func goNextMonth() -> Date {
        let newDate = date.nextMonth()
        changeToDate(newDate)
        return newDate
    }
    
    func goPrevMonth() -> Date {
        let newDate = date.prevMonth()
        changeToDate(newDate)
        return newDate
    }
    
    func changeToDate(_ date: Date) {
        self.date = date
        reload()
    }

    func overviewTableViewCellDeselected(_ cell: OverviewTableViewCell) {
        delegate?.expensesViewControllerRowDeselected(self)
    }
}
