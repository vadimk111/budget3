//
//  ExpensesViewController+UITableView.swift
//  Budget
//
//  Created by Vadik on 30/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

extension ExpensesViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return groupedExpensesList?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = OverviewHeaderView()
        if let group = groupedExpensesList?[section] {
            view.fill(with: group.date, expenses: group.expenses.map({$0.expense}))
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupedExpensesList?[section].expenses.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCells", for: indexPath) as! OverviewTableViewCell
        cell.delegate = self
        if let expenseWithCategory = groupedExpensesList?[indexPath.section].expenses[indexPath.row] {
            cell.fill(with: expenseWithCategory.expense, categoryTitle: expenseWithCategory.categoryTitle, mainColor: colors[indexPath.row % colors.count])
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction.init(style: UITableViewRowActionStyle.normal, title: "Remove", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            self.groupedExpensesList?[indexPath.section].expenses[indexPath.row].expense.delete()
        })
        return [delete]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let groupedExpensesList = groupedExpensesList {
            delegate?.expensesViewController(self, didSelect: groupedExpensesList[indexPath.section].expenses[indexPath.row])
        }
    }
}
