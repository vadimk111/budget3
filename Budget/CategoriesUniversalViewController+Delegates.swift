//
//  CategoriesUniversalViewController+Delegates.swift
//  Budget
//
//  Created by Vadik on 27/07/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseDatabase

extension CategoriesUniversalViewController: CategoriesHeaderViewDelegate {
    func categoriesHeaderViewDidGoNext(_ categoriesHeaderView: CategoriesHeaderView) {
        categoriesViewController?.goNextMonth()
    }
    
    func categoriesHeaderViewDidGoPrev(_ categoriesHeaderView: CategoriesHeaderView) {
        categoriesViewController?.goPrevMonth()
    }
    
    func categoriesHeaderView(_ categoriesHeaderView: CategoriesHeaderView, didCreateDatePicker datePicker: DatePickerView) {
        if isCompactWidth {
            NotificationCenter.default.post(Notification(name: datePickerControllerWillAppearNotification))
            datePicker.backgroundColor = UIColor(red: 242 / 255, green: 242 / 255, blue: 242 / 255, alpha: 1)
            presentViewAtBottom(datePicker, height: 236)
        } else {
            datePicker.backgroundColor = UIColor.white
            presentViewAsPopover(datePicker, viewSize: CGSize(width: 320, height: 236), sourceView: o_categoriesHeaderView, sourceRect: o_categoriesHeaderView.o_dateChanger.o_title.frame)
        }
        datePickerIsShown = true
    }
    
    func categoriesHeaderView(_ categoriesHeaderView: CategoriesHeaderView, didChangeDate date: Date) {
        categoriesViewController?.changeToDate(date, copyClosestBudget: false)
        if isCompactWidth {
            dismissViewAtBottom()
        } else {
            dismiss(animated: true)
        }
        datePickerIsShown = false
    }
}

extension CategoriesUniversalViewController: CategoriesViewControllerDelegate {
    func categoriesViewController(_ categoriesViewController: CategoriesViewController, didSelect category: Category) {
        if isCompactWidth {
            performSegue(withIdentifier: "drillDown", sender: category)
        } else {
            o_addExpenseBtn.isEnabled = true
            if categoryExpensesViewController?.category != category {
                categoryExpensesViewController?.category = category
            }
        }
    }
    
    func categoriesViewController(_ categoriesViewController: CategoriesViewController, didEdit category: Category) {
        performSegue(withIdentifier: isCompactWidth ? "editCategoryPhone" : "editCategoryPad", sender: category)
    }
    
    func categoriesViewControllerChanged(_ categoriesViewController: CategoriesViewController) {
        reloadIncomes()
        o_categoriesHeaderView?.fill(with: categoriesViewController.availableParents, date: categoriesViewController.date)
        
        if isCompactWidth {
            o_editBarButton.isEnabled = categoriesViewController.categories.count > 0
        } else {
            o_editCategoryBtn.isEnabled = categoriesViewController.categories.count > 0
        }
    }
    
    func categoriesViewControllerRowDeselected(_ categoriesViewController: CategoriesViewController) {
        if !isCompactWidth {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (Timer) -> Void in
                if categoriesViewController.tableView.indexPathForSelectedRow == nil {
                    self.categoryExpensesViewController?.category = nil
                    self.o_addExpenseBtn.isEnabled = false
                }
            })
        }
    }
}

extension CategoriesUniversalViewController: CategoryExpensesViewControllerDelegate {
    func categoryExpensesViewControllerChanged(_ categoryExpensesViewController: CategoryExpensesViewController) {
        
    }
    
    func categoryExpensesViewController(_ categoryExpensesViewController: CategoryExpensesViewController, didSelect expense: Expense) {
        performSegue(withIdentifier: "editExpense", sender: expense)
        if let indexPath = categoryExpensesViewController.tableView.indexPathForSelectedRow {
            Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { (Timer) -> Void in
                categoryExpensesViewController.tableView.deselectRow(at: indexPath, animated: true)
            })
        }
    }
    
    func categoryExpensesViewController(_ categoryExpensesViewController: CategoryExpensesViewController, addExpenseTo category: Category) {
        performSegue(withIdentifier: "addExpense", sender: category)
    }
}

extension CategoriesUniversalViewController: AddEditCategoryViewControllerDelegate {
    func addEditCategoryViewController(_ addEditCategoryViewController: AddEditCategoryViewController, copyCategoryToFollowingMonths category: Category) {
        if let date = categoriesViewController?.date {
            var parentName: String? = nil
            if let parentId = category.parent {
                parentName = categoriesViewController?.categories.first(where: { $0.id == parentId })?.title
            }
            copyCategory(category, date: date, parentName: parentName)
        }
    }
    
    func copyCategory(_ category: Category, date: Date, parentName: String?) {
        let calendar = Calendar.current
        var year = calendar.component(.year, from: date)
        var month = calendar.component(.month, from: date)
        
        var comp = DateComponents()
        if month == 12 {
            year += 1
            month = 1
        } else {
            month += 1
        }
        
        comp.day = 1
        comp.month = month
        comp.year = year
        
        let nextDate = calendar.date(from: comp)!
        
        if let nextBudgetRef = ModelHelper.budgetReference(for: nextDate) {
            nextBudgetRef.observeSingleEvent(of: .value, with: { [unowned self] snapshot in
                if snapshot.children.allObjects.count > 0 {
                    
                    let categories: [Category] = snapshot.children.map { (child: Any) -> Category in
                        return Category(snapshot: child as! FIRDataSnapshot)
                        }.sorted(by: { (item1: Category, item2: Category) -> Bool in
                            return item1.order < item2.order
                        })
                    
                    if let _ = parentName {
                        category.parent = categories.first(where: { $0.title == parentName && $0.parent == nil })?.id
                    }
                    
                    if let last = categories.filter({ $0.parent == category.parent }).last {
                        category.order = last.order + 100
                    } else {
                        category.order = 100
                    }
                    
                    category.insert(into: nextBudgetRef)
                    self.copyCategory(category, date: nextDate, parentName: parentName)
                }
            })
        }
    }
}
