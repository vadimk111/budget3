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
    var budgetRef: FIRDatabaseReference?
    var date: Date = Date()
    var isRefreshing = false
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
        //unregisterFromUpdates(budgetRef: budgetRef)
    }
    
    func reload() {
        let ref = FIRDatabase.database().reference().child("budgets")
        if let budgetId = ModelHelper.budgetId(for: date) {
            budgetRef = ref.child(budgetId)
            budgetRef?.observeSingleEvent(of: .value, with: { [unowned self] snapshot in
                self.prepareExpenses(from: snapshot)
                //self.registerToUpdates(budgetRef: self.budgetRef)
                self.tableView.reloadData()
                
                if self.isRefreshing {
                    self.isRefreshing = false
                    self.tableView.refreshControl?.endRefreshing()
                }
            })
        }
    }
    
    func prepareExpenses(from snapshot: FIRDataSnapshot) {
        expenses = []
        
        for child in snapshot.children {
            let category = Category(snapshot: child as! FIRDataSnapshot)
            if let cExpenses = category.expenses {
                for item in cExpenses {
                    expenses?.append(ExpenseObj(expense: item, category: category))
                }
            }
        }
        
        expenses?.sort(by: { (item1: ExpenseObj, item2: ExpenseObj) -> Bool in
            guard let date1 = item1.expense.date else { return true }
            guard let date2 = item2.expense.date else { return true }
            return date1 > date2
        })
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
        //unregisterFromUpdates(budgetRef: budgetRef)
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
