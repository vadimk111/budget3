//
//  CategoryExpensesViewController+UITableView.swift
//  Budget
//
//  Created by Vadik on 26/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

extension CategoryExpensesViewController {
    
    func expense(for indexPath: IndexPath) -> Expense? {
        if indexPath.section == 0 {
            return category?.expenses?[indexPath.row]
        } else if let subExpenses = category?.subCategories?[indexPath.section - 1].expenses {
            return subExpenses[indexPath.row]
        }
        return nil
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
        let delete = UITableViewRowAction.init(style: UITableViewRowAction.Style.normal, title: "Remove", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            self.expense(for: indexPath)?.delete()
        })
        return [delete]
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let expense = expense(for: indexPath) {
            delegate?.categoryExpensesViewController(self, didSelect: expense)
        }
    }
}
