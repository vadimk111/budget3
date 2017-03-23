//
//  CategoryViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 10/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CategoryViewController: UITableViewController, SubCategoryHeaderViewDelegate {

    @IBOutlet weak var o_balanceNavView: BalanceView!
    
    var category: Category?
    var currentDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: signInStateChangedNotification, object: nil, queue: nil, using: { [unowned self] notification in
            _ = self.navigationController?.popViewController(animated: false)
        })
        
        updateBalanceNavView()
        registerToUpdates(expensesRef: category?.getDatabaseReference()?.child("expenses"), section: 0)
        
        if let subCategories = category?.subCategories {
            var index = 1
            for item in subCategories {
                registerToUpdates(expensesRef: item.getDatabaseReference()?.child("expenses"), section: index)
                index += 1
            }
        }
    }
    
    deinit {
        category?.getDatabaseReference()?.child("expenses").removeAllObservers()
        if let subCategories = category?.subCategories {
            for item in subCategories {
                item.getDatabaseReference()?.child("expenses").removeAllObservers()
            }
        }
    }
    
    func reload(with category: Category) {
        self.category = category
        tableView.reloadData()
    }
    
    func updateBalanceNavView() {
        if let category = category {
            o_balanceNavView.populate(amount: category.calculatedAmount, totalSpent: category.calculatedTotalSpent, title: category.title)
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
                    self.updateBalanceNavView()
                }
            })
            
            expensesRef?.observe(.childChanged, with: { [unowned self] snapshot in
                let category = section == 0 ? self.category! : self.category!.subCategories![section - 1]
                let expense = Expense(snapshot: snapshot)
                if let index = category.expenses?.index(where: { $0.id == snapshot.key } ) {
                    category.expenses?.remove(at: index)
                    category.expenses?.insert(expense, at: index)
                    self.tableView.reloadRows(at: [IndexPath.init(row: index, section: section)], with: .none)
                    self.updateBalanceNavView()
                }
            })
            
            expensesRef?.observe(.childRemoved, with: { [unowned self] snapshot in
                let category = section == 0 ? self.category! : self.category!.subCategories![section - 1]
                let expense = Expense(snapshot: snapshot)
                if let index = category.expenses?.index(where: { $0.id == expense.id }) {
                    category.expenses?.remove(at: index)
                    self.tableView.deleteRows(at: [IndexPath.init(row: index, section: section)], with: .fade)
                    self.updateBalanceNavView()
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = addEditController(from: segue)
        if segue.identifier == "addExpense" {
            var parentCategory: Category?
            if sender is SubCategoryHeaderView {
                if let subCategories = category?.subCategories {
                    parentCategory = subCategories[(sender as! SubCategoryHeaderView).section - 1]
                }
            } else {
                parentCategory = category
            }
            vc?.parentRef = parentCategory?.getDatabaseReference()?.child("expenses")
            vc?.expense = Expense()
            vc?.expense?.date = currentDate
            vc?.title = "Add Expense"
        } else if segue.identifier == "editExpense" {
            if let index = tableView.indexPathForSelectedRow {
                vc?.expense = expense(for: index)
                vc?.title = "Edit Expense"
            }
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
    
    func addEditController(from segue: UIStoryboardSegue) -> AddEditExpenseViewController? {
        if let nav = segue.destination as? UINavigationController {
            return nav.viewControllers.first as? AddEditExpenseViewController
        }
        return segue.destination as? AddEditExpenseViewController
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let subCategories = category?.subCategories {
            return subCategories.count + 1
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if let expenses = category?.expenses {
                return expenses.count
            }
            return 0
        } else {
            if let subExpenses = category?.subCategories?[section - 1].expenses {
                return subExpenses.count
            }
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 44
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section > 0 {
            let view = SubCategoryHeaderView()
            view.delegate = self
            view.section = section
            if let subCategory = category?.subCategories?[section - 1] {
                view.o_title.text = subCategory.title
            }
            return view
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCells", for: indexPath) as! ExpenseTableViewCell
        
        if let expense = expense(for: indexPath) {
            cell.fill(with: expense, mainColor: colors[indexPath.row % colors.count])
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction.init(style: UITableViewRowActionStyle.normal, title: "Remove", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            self.expense(for: indexPath)?.delete()
        })
        return [delete]
    }

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func subCategoryHeaderViewAdd(_ subCategoryHeaderView: SubCategoryHeaderView) {
        performSegue(withIdentifier: "addExpense", sender: subCategoryHeaderView)
    }
}
