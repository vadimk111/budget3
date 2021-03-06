//
//  CategoriesViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 20/12/2016.
//  Copyright © 2016 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseDatabase

let budgetChangedNotification = Notification.Name(rawValue: "budgetChanged")

protocol CategoriesViewControllerDelegate: class {
    func categoriesViewController(_ categoriesViewController: CategoriesViewController, didSelect category: Category)
    func categoriesViewController(_ categoriesViewController: CategoriesViewController, didEdit category: Category)
    func categoriesViewController(_ categoriesViewController: CategoriesViewController, didCreateQuickAdd view: QuickAddExpense)
    func categoriesViewControllerDidFinishQuickAdd(_ categoriesViewController: CategoriesViewController)
    func categoriesViewControllerChanged(_ categoriesViewController: CategoriesViewController)
    func categoriesViewControllerWillReload(_ categoriesViewController: CategoriesViewController)
    func categoriesViewControllerDidReload(_ categoriesViewController: CategoriesViewController)
    func categoriesViewControllerRowDeselected(_ categoriesViewController: CategoriesViewController)
}

class CategoriesViewController: UITableViewController {

    var budgetRef: DatabaseReference?
    var categories: [Category] = []
    var date: Date = Date()
    var dateChanged = false
    var isRefreshing = false
    var closestBudget: [Category]?
    var expandedCategories: [String : Bool] = [:]
    weak var delegate: CategoriesViewControllerDelegate?
    
    var tableSeparatorInset: UIEdgeInsets? {
        didSet {
            if let tableSeparatorInset = tableSeparatorInset {
                tableView.separatorInset = tableSeparatorInset
            }
        }
    }
    var availableParents: [Category] {
        return categories.filter({ $0.parent == nil })
    }
    
    deinit {
        unregisterFromUpdates(budgetRef: budgetRef)
    }
    
    func reload() {
        unregisterFromUpdates(budgetRef: budgetRef)
        
        budgetRef = ModelHelper.budgetReference(for: date)
        if budgetRef != nil {
            if !isRefreshing {
                delegate?.categoriesViewControllerWillReload(self)
            }
            
            budgetRef?.observeSingleEvent(of: .value, with: { [unowned self] snapshot in
                if !self.prepareBudget(from: snapshot) && !self.isRefreshing {
                    if !self.copyClosestBudget() && !self.dateChanged {
                        self.tryPrevBudgetAndCopy()
                    }
                }
                self.registerToUpdates(budgetRef: self.budgetRef)
                self.tableView.reloadData()
                self.delegate?.categoriesViewControllerChanged(self)
                
                if self.isRefreshing {
                    self.isRefreshing = false
                    self.tableView.refreshControl?.endRefreshing()
                } else {
                    self.delegate?.categoriesViewControllerDidReload(self)
                }
            })
        } else {
            date = Date()
            budgetRef = nil
            closestBudget = nil
            expandedCategories = [:]
            categories = []
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: false)
            }
            tableView.reloadData()
            delegate?.categoriesViewControllerChanged(self)
        }
    }
        
    func prepareBudget(from snapshot: DataSnapshot) -> Bool {
        categories = []
        var subCategories: [String : [Category]] = [:]
        var budgetExist = false
        
        for child in snapshot.children {
            budgetExist = true
            
            let category = Category(snapshot: child as! DataSnapshot)
            if let parent = category.parent {
                var mutableArr = [Category]()
                if let arr = subCategories[parent] {
                    mutableArr.append(contentsOf: arr)
                }
                mutableArr.append(category)
                subCategories[parent] = mutableArr
            } else {
                categories.append(category)
            }
        }
        
        if budgetExist {
            categories.sort(by: { (item1: Category, item2: Category) -> Bool in
                return item1.order < item2.order
            })
            
            for key in subCategories.keys {
                if let parentCategory = categories.filter({ $0.id == key }).first {
                    parentCategory.subCategories = subCategories[key]?.sorted(by: { (item1: Category, item2: Category) -> Bool in
                        return item1.order < item2.order
                    })
                } else if let subCats = subCategories[key] {
                    for subCategory in subCats {
                        subCategory.delete()
                    }
                }
            }
        }
        
        return budgetExist
    }
    
    @discardableResult
    func copyClosestBudget() -> Bool {
        if let closestBudget = closestBudget, let budgetRef = budgetRef {
            for category in closestBudget {
                let newCategory = category.makeCopy()
                newCategory.id = nil
                newCategory.expenses = nil
                let newCategoryId = newCategory.insert(into: budgetRef)
                
                if let subCategories = category.subCategories {
                    for subCategory in subCategories {
                        let newSubCategory = subCategory.makeCopy()
                        newSubCategory.id = nil
                        newSubCategory.expenses = nil
                        newSubCategory.parent = newCategoryId
                        newSubCategory.insert(into: budgetRef)
                    }
                }
            }
            return true
        }
        return false
    }
    
    func tryPrevBudgetAndCopy() {
        let calendar = Calendar.current
        var year = calendar.component(.year, from: date)
        var month = calendar.component(.month, from: date)
        
        var comp = DateComponents()
        if month == 1 {
            year -= 1
            month = 12
        } else {
            month -= 1
        }
        
        comp.day = 1
        comp.month = month
        comp.year = year
        
        let prevDate = calendar.date(from: comp)!
        
        if let prevBudgetRef = ModelHelper.budgetReference(for: prevDate) {
            prevBudgetRef.observeSingleEvent(of: .value, with: { [unowned self] snapshot in
                if self.prepareBudget(from: snapshot) {
                    self.closestBudget = self.categories
                    self.categories = []
                    self.copyClosestBudget()
                }
            })
        }
    }
    
    @IBAction func didPullToRefresh(_ sender: UIRefreshControl) {
        isRefreshing = true
        expandedCategories = [:]
        reload()
    }
    
    func goNextMonth() {
        changeToDate(date.nextMonth())
    }
    
    func goPrevMonth() {
        changeToDate(date.prevMonth())
    }
    
    func changeToDate(_ date: Date, copyClosestBudget: Bool = true) {
        let calendar = Calendar.current
        let today = Date()
        if calendar.component(.month, from: date) == calendar.component(.month, from: today) && calendar.component(.year, from: date) == calendar.component(.year, from: today) {
            self.date = Date()
        } else {
            self.date = date
        }
        
        dateChanged = true
        closestBudget = copyClosestBudget ? categories : nil
        expandedCategories = [:]
        
        reload()
    }
    
    func clearBudget() {
        for item in categories {
            item.delete()
        }
    }
}
