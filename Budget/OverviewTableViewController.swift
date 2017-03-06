//
//  OverviewTableViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 02/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import Firebase

struct ExpenseObj {
    var expense: Expense
    var category: Category
}

class OverviewTableViewController: UITableViewController, DateChangerDelegate, TabBarComponent {

    var expenses: [ExpenseObj]?
    var date: Date = Date()
    var dateChanger: DateChanger!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: logoutNotification, object: nil, queue: nil, using: { [unowned self] notification in
            self.date = Date()
        })
        NotificationCenter.default.addObserver(forName: loginNotification, object: nil, queue: nil, using: { [unowned self] notification in
            self.reload()
        })
        
        dateChanger = DateChanger()
        dateChanger.backgroundColor = UIColor(red: 242 / 255, green: 242 / 255, blue: 242 / 255, alpha: 1)
        dateChanger.delegate = self
        dateChanger.date = date
    }
    
    deinit {
        unregisterFromUpdates()
    }
    
    func reload() {
        if let budgetId = ModelHelper.budgetId(for: date) {
            let ref = FIRDatabase.database().reference().child("budgets")
            ref.child(budgetId).observeSingleEvent(of: .value, with: { snapshot in
                self.prepareExpenses(from: snapshot)
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
            })
        }
    }
    
    func prepareExpenses(from snapshot: FIRDataSnapshot) {
        expenses = []
        
        for child in snapshot.children {
            let category = Category(snapshot: child as! FIRDataSnapshot)
            registerToUpdates(category: category)
            if let cExpenses = category.expenses {
                for item in cExpenses {
                    expenses?.append(ExpenseObj(expense: item, category: category))
                }
            }
        }
        
        sortExpenses()
    }
    
    func sortExpenses() {
        expenses?.sort(by: { (item1: ExpenseObj, item2: ExpenseObj) -> Bool in
            guard let date1 = item1.expense.date else { return true }
            guard let date2 = item2.expense.date else { return true }
            return date1 > date2
        })
    }
    
    func registerToUpdates(category: Category) {
        let listRef = category.getDatabaseReference()?.child("expenses")
        
        listRef?.observe(.childAdded, with: { [unowned self] snapshot in
            let expense = Expense(snapshot: snapshot)
            if category.expenses?.contains(where: { $0.id == expense.id } ) == false {
                self.expenses?.append(ExpenseObj(expense: expense, category: category))
                self.sortExpenses()
                self.tableView.reloadData()
            }
        })
        
        listRef?.observe(.childChanged, with: { [unowned self] snapshot in
            let expense = Expense(snapshot: snapshot)
            if let index = self.expenses?.index(where: { $0.expense.id == expense.id }) {
                self.expenses?.remove(at: index)
            }
            self.expenses?.append(ExpenseObj(expense: expense, category: category))
            self.sortExpenses()
            self.tableView.reloadData()
        })
        
        listRef?.observe(.childRemoved, with: { [unowned self] snapshot in
            let expense = Expense(snapshot: snapshot)
            if let index = self.expenses?.index(where: { $0.expense.id == expense.id }) {
                self.expenses?.remove(at: index)
            }
            self.tableView.reloadData()
        })
    }

    func unregisterFromUpdates() {
        if let expenses = expenses {
            for item in expenses {
                item.category.getDatabaseReference()?.child("expenses").removeAllObservers()
            }
        }
    }
    
    func dateChangerDidGoPrev(_ dateChanger: DateChanger) {
        changeToDate(date.prevMonth())
    }
    
    func dateChangerDidGoNext(_ dateChanger: DateChanger) {
        changeToDate(date.nextMonth())
    }
    
    func changeToDate(_ date: Date) {
        self.date = date
        dateChanger.date = date
        unregisterFromUpdates()
        reload()
    }
    
    @IBAction func didPullToRefresh(_ sender: UIRefreshControl) {
        unregisterFromUpdates()
        reload()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let expenses = expenses {
            return expenses.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "overviewCells", for: indexPath) as! OverviewTableViewCell
        if let expenseObj = expenses?[indexPath.row] {
            cell.fill(with: expenseObj.expense, category: expenseObj.category, mainColor: colors[indexPath.row % colors.count])
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return dateChanger
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction.init(style: UITableViewRowActionStyle.normal, title: "Remove", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            self.expenses?[indexPath.row].expense.delete()
        })
        return [delete]
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = addEditController(from: segue)
        if segue.identifier == "editExpense" {
            if let index = tableView.indexPathForSelectedRow {
                vc?.expense = expenses?[index.row].expense
                vc?.title = "Edit Expense"
            }
        }
    }
    
    func addEditController(from segue: UIStoryboardSegue) -> AddEditExpenseViewController? {
        if let nav = segue.destination as? UINavigationController {
            return nav.viewControllers.first as? AddEditExpenseViewController
        }
        return segue.destination as? AddEditExpenseViewController
    }
    

}
