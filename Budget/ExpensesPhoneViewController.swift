//
//  ExpensesPhoneViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 11/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import Firebase

class ExpenseWithCategoryData {
    var expense: Expense
    var categoryId: String?
    var categoryTitle: String?
    var categoryRef: FIRDatabaseReference?
    
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

class ExpensesPhoneViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DateChangerDelegate {

    @IBOutlet weak var o_dateChanger: DateChanger!
    @IBOutlet weak var o_tableView: UITableView!
    
    var groupedExpensesList: [GroupedExpneses]?
    var date: Date = Date()

    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: budgetChangedNotification, object: nil, queue: nil, using: { [unowned self] notification in
            self.timer?.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (timer) in
                self.reload()
            })
        })
        
        o_dateChanger.delegate = self
        o_dateChanger.date = date
        
        o_tableView.refreshControl = UIRefreshControl()
        o_tableView.refreshControl?.addTarget(self, action: #selector(ExpensesPhoneViewController.refresh(_:)), for: .valueChanged)
        
        NotificationCenter.default.addObserver(forName: signInStateChangedNotification, object: nil, queue: nil, using: { [unowned self] notification in
            self.date = Date()
            self.reload()
        })
        
        reload()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = o_tableView.indexPathForSelectedRow {
            o_tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    deinit {
        unregisterFromUpdates()
    }
    
    func refresh(_ refreshControl: UIRefreshControl) {
        reload()
    }
    
    func reload() {
        unregisterFromUpdates()
        
        if let budgetId = ModelHelper.budgetId(for: date) {
            let ref = FIRDatabase.database().reference().child("budgets")
            ref.child(budgetId).observeSingleEvent(of: .value, with: { snapshot in
                self.prepareExpenses(from: snapshot)
                self.o_tableView.reloadData()
                self.o_tableView.refreshControl?.endRefreshing()
            })
        } else {
            date = Date()
            groupedExpensesList = nil
            o_tableView.reloadData()
        }
    }
    
    func prepareExpenses(from snapshot: FIRDataSnapshot) {
        var groupsByDate = [Date : [ExpenseWithCategoryData]]()
        
        for child in snapshot.children {
            let category = Category(snapshot: child as! FIRDataSnapshot)
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
    
    func registerToUpdates(category: Category) {
        let listRef = category.getDatabaseReference()?.child("expenses")
        
        listRef?.observe(.childAdded, with: { [unowned self] snapshot in
            let expense = Expense(snapshot: snapshot)
            if self.group(for: expense.id) == nil {
                self.addExpenseToModel(expense, category: category)
                self.o_tableView.reloadData()
            }
        })
        
        listRef?.observe(.childChanged, with: { [unowned self] snapshot in
            let expense = Expense(snapshot: snapshot)
            self.removeExpenseFromModel(expense)
            self.addExpenseToModel(expense, category: category)
            self.o_tableView.reloadData()
        })
        
        listRef?.observe(.childRemoved, with: { [unowned self] snapshot in
            let expense = Expense(snapshot: snapshot)
            self.removeExpenseFromModel(expense)
            self.o_tableView.reloadData()
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
    
    func removeExpenseFromModel(_ expense: Expense) {
        if let group = self.group(for: expense.id) {
            if let index = group.expenses.index(where: { $0.expense.id == expense.id }) {
                group.expenses.remove(at: index)
            }
        }
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
    
    func dateChangerDidGoPrev(_ dateChanger: DateChanger) {
        changeToDate(date.prevMonth())
    }
    
    func dateChangerDidGoNext(_ dateChanger: DateChanger) {
        changeToDate(date.nextMonth())
    }
    
    func changeToDate(_ date: Date) {
        self.date = date
        o_dateChanger.date = date
        reload()
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedExpensesList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = OverviewHeaderView()
        if let group = groupedExpensesList?[section] {
            view.fill(with: group.date, expenses: group.expenses.map({$0.expense}))
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedExpensesList?[section].expenses.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCells", for: indexPath) as! OverviewTableViewCell
        if let expenseWithCategory = groupedExpensesList?[indexPath.section].expenses[indexPath.row] {
            cell.fill(with: expenseWithCategory.expense, categoryTitle: expenseWithCategory.categoryTitle, mainColor: colors[indexPath.row % colors.count])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction.init(style: UITableViewRowActionStyle.normal, title: "Remove", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            self.groupedExpensesList?[indexPath.section].expenses[indexPath.row].expense.delete()
        })
        return [delete]
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc: AddEditExpenseViewController? = segue.destinationController()
        if segue.identifier == "editExpense" {
            if let index = o_tableView.indexPathForSelectedRow {
                vc?.expense = groupedExpensesList?[index.section].expenses[index.row].expense
                vc?.title = "Edit Expense"
            }
        }
    }
}
