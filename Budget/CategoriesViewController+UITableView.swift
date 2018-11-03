//
//  CategoriesViewController+UITableView.swift
//  Budget
//
//  Created by Vadim Kononov on 18/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

extension CategoriesViewController: QuickAddExpenseDelegate {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCells", for: indexPath) as! CategoryTableViewCell
        let category = categories[indexPath.row]
        cell.trailingConstant = tableSeparatorInset?.right
        cell.populate(with: category, isExpanded: expandedCategories.keys.index(of: category.id!) != nil, mainColor: colors[indexPath.row % colors.count])
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var actions = [UITableViewRowAction]()
        
        let edit = UITableViewRowAction.init(style: UITableViewRowActionStyle.normal, title: "Edit", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            self.tableView.setEditing(false, animated: true)
            self.delegate?.categoriesViewController(self, didEdit: self.categories[indexPath.row])
        })
        actions.append(edit)
        
        let delete = UITableViewRowAction.init(style: UITableViewRowActionStyle.normal, title: "Remove", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            let title = self.categories[indexPath.row].subCategories != nil ? "Remove category, all its sub categories and all related expenses ?" : "Remove category and all related expenses ?"
            let a = UIAlertController(title: title, message: "", preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "Remove", style: .default) { action -> Void in
                self.categories[indexPath.row].delete()
            })
            a.addAction(UIAlertAction(title: "Cancel", style: .default) { action -> Void in })
            self.present(a, animated: true, completion: nil)
        })
        actions.insert(delete, at: 0)
        
        return actions
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.row != destinationIndexPath.row {
            let category = categories[sourceIndexPath.row]
            
            categories.remove(at: sourceIndexPath.row)
            categories.insert(category, at: destinationIndexPath.row)
            
            let hasParent = category.parent != nil
            
            if hasParent {
                if let parentCategory = categories.filter({ $0.id == category.parent! }).first {
                    if let subSourceIndex = parentCategory.subCategories?.index(of: category) {
                        parentCategory.subCategories?.remove(at: subSourceIndex)
                        parentCategory.subCategories?.insert(category, at: subSourceIndex + destinationIndexPath.row - sourceIndexPath.row)
                    }
                }
            }
            
            if isFirstInRow(dest: destinationIndexPath, hasParent: hasParent) {
                category.order = categories[destinationIndexPath.row + 1].order - 100
            } else if isLastInRow(dest: destinationIndexPath, hasParent: hasParent) {
                category.order = categories[destinationIndexPath.row - 1].order + 100
            } else {
                let prev = categories[destinationIndexPath.row - 1]
                let next = categories[destinationIndexPath.row + 1]
                category.order = prev.order + (next.order - prev.order) / 2
            }
            
            category.update()
        }
    }
    
    func isFirstInRow(dest: IndexPath, hasParent: Bool) -> Bool {
        if hasParent {
            return categories[dest.row - 1].parent == nil
        }
        return dest.row == 0
    }
    
    func isLastInRow(dest: IndexPath, hasParent: Bool) -> Bool {
        if hasParent {
            return dest.row == categories.count - 1 || categories[dest.row + 1].parent == nil
        }
        return dest.row == categories.count - 1
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        
        let categoryOnSource = categories[sourceIndexPath.row]
        let categoryOnDest = categories[proposedDestinationIndexPath.row]

        //do not allow to drag expanded category
        if expandedCategories.keys.index(of: categoryOnSource.id!) != nil {
            return sourceIndexPath
        }
        
        let parentOnSource = categoryOnSource.parent
        let parentOnDest = categoryOnDest.parent
        
        //do not allow drag sub category outside its parent
        if parentOnSource != nil && parentOnDest != nil {
            return parentOnDest == parentOnSource ? proposedDestinationIndexPath : sourceIndexPath
        }
        
        if parentOnSource == nil && parentOnDest == nil {
            if proposedDestinationIndexPath.row == categories.count - 1 {
                return proposedDestinationIndexPath
            } else {
                let nextToDestCategory = categories[proposedDestinationIndexPath.row + 1]
                return nextToDestCategory.parent != nil ? sourceIndexPath : proposedDestinationIndexPath
            }
        }

        return sourceIndexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.categoriesViewController(self, didSelect: categories[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let payAction = self.payAction(forRowAtIndexPath: indexPath)
        let addExpenseAction = self.addExpenseAction(forRowAtIndexPath: indexPath)
        let swipeConfig = UISwipeActionsConfiguration(actions: [addExpenseAction, payAction])
        return swipeConfig
    }

    func payAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let payAction = UIContextualAction(style: .normal, title: "Pay") { (action, view, (Bool) -> Void) in
            self.tableView.setEditing(false, animated: true)
            
            let categoryToPay = self.categories[indexPath.row]
            if let expensesRef = categoryToPay.getDatabaseReference()?.child("expenses") {
                let expense = Expense()
                expense.amount = categoryToPay.amount
                expense.date = Date()
                if let title = categoryToPay.title {
                    expense.title = "\(title) - payment"
                } else {
                    expense.title = "Payment"
                }
                expense.insert(into: expensesRef)
                
                ExpensesRecorder.recordExpense(amount: categoryToPay.amount ?? 0)
            }
        }

        return payAction
    }
    
    func addExpenseAction(forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        let addAction = UIContextualAction(style: .normal, title: "Add") { (action, view, (Bool) -> Void) in
            self.tableView.setEditing(false, animated: true)
            
            let quickAdd = QuickAddExpense.loadFromXib()
            quickAdd.delegate = self
            quickAdd.category = self.categories[indexPath.row]
            quickAdd.o_amountField.becomeFirstResponder()
            self.delegate?.categoriesViewController(self, didCreateQuickAdd: quickAdd)
        }

        return addAction
    }
    
    func quickAddExpense(_ quickAddExpense: QuickAddExpense, didFinishWith title: String, andAmount amount: Float) {
        if let parentRef = quickAddExpense.category.getDatabaseReference()?.child("expenses") {
            let expense = Expense()
            expense.date = Date()
            expense.title = title
            expense.amount = amount
            expense.insert(into: parentRef)
            
            ExpensesRecorder.recordExpense(amount: amount)
        }
        
        delegate?.categoriesViewControllerDidFinishQuickAdd(self)
    }
}
