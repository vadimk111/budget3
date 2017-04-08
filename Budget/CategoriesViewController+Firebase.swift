//
//  CategoriesViewController+Firebase.swift
//  Budget
//
//  Created by Vadim Kononov on 22/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseDatabase

extension CategoriesViewController {
    
    func unregisterFromUpdates(budgetRef: FIRDatabaseReference?) {
        budgetRef?.removeAllObservers()
    }
    
    func registerToUpdates(budgetRef: FIRDatabaseReference?) {
        observeChildAdd(on: budgetRef)
        observeChildDelete(on: budgetRef)
        observeChildUpdate(on: budgetRef)
    }
    
    func observeChildAdd(on budgetRef: FIRDatabaseReference?) {
        budgetRef?.observe(.childAdded, with: { [unowned self] snapshot in
            let category = Category(snapshot: snapshot)
            if let _ = category.parent {
                if self.addCategoryToParentView(category) {
                    NotificationCenter.default.post(Notification(name: budgetChangedNotification))
                }
            } else {
                if self.addCategoryToView(category) {
                    NotificationCenter.default.post(Notification(name: budgetChangedNotification))
                }
            }
            self.delegate?.categoriesViewControllerChanged(self)
        })
    }
    
    func observeChildDelete(on budgetRef: FIRDatabaseReference?) {
        budgetRef?.observe(.childRemoved, with: { [unowned self] snapshot in
            let category = Category(snapshot: snapshot)
            self.deleteCategoryFromView(category)
            self.delegate?.categoriesViewControllerChanged(self)
            NotificationCenter.default.post(Notification(name: budgetChangedNotification))
        })
    }
    
    func observeChildUpdate(on budgetRef: FIRDatabaseReference?) {
        budgetRef?.observe(.childChanged, with: { [unowned self] snapshot in
            let category = Category(snapshot: snapshot)
            
            if let originalCategory = self.categories.filter({ $0.id == category.id }).first {
                if originalCategory.parent != category.parent {
                    if category.parent == nil {
                        self.deleteCategoryFromView(originalCategory)
                        self.addCategoryToView(category)
                    } else {
                        self.deleteCategoryFromView(originalCategory)
                        self.addCategoryToParentView(category)
                    }
                } else {
                    self.replaceCategoryInView(originalCategory, with: category)
                }
            } else {
                self.updateCategoryNotInView(category)
            }
            self.delegate?.categoriesViewControllerChanged(self)
        })
    }
    
    @discardableResult
    func addCategoryToView(_ category: Category) -> Bool {
        if !categories.contains(where: { $0.id == category.id } ) {
            categories.append(category)
            tableView.insertRows(at: [IndexPath.init(row: tableView.numberOfRows(inSection: 0), section: 0)], with: .fade)
            return true
        }
        return false
    }
    
    @discardableResult
    func addCategoryToParentView(_ category: Category) -> Bool {
        if let parentCategory = categories.filter({ $0.id == category.parent }).first {
            if parentCategory.subCategories == nil {
                parentCategory.subCategories = []
            }
            if !parentCategory.subCategories!.contains(where: { $0.id == category.id } ) {
                parentCategory.subCategories!.append(category)
                
                if let index = categories.index(of: parentCategory) {
                    let indexToUpdate = IndexPath.init(row: index, section: 0)
                    if expandedCategories.keys.index(of: parentCategory.id!) != nil {
                        let insertIndex = index + parentCategory.subCategories!.count
                        categories.insert(category, at: insertIndex)
                        tableView.insertRows(at: [IndexPath.init(row: insertIndex, section: 0)], with: .fade)
                    }
                    tableView.reloadRows(at: [indexToUpdate], with: .none)
                }
                return true
            }
        }
        return false
    }
    
    func deleteCategoryFromView(_ category: Category) {
        if let index = categories.index(where: { $0.id == category.id }) {
            categories.remove(at: index)
            tableView.deleteRows(at: [IndexPath.init(row: index, section: 0)], with: .fade)
            
            if let _ = category.parent {
                deleteCategoryFromParentView(category)
            }
        }
    }
    
    func deleteCategoryFromParentView(_ category: Category) {
        if let parentCategory = categories.filter({ $0.id == category.parent }).first {
            if let index = parentCategory.subCategories?.index(where: { $0.id == category.id }) {
                parentCategory.subCategories?.remove(at: index)
                if parentCategory.subCategories!.count == 0 {
                    parentCategory.subCategories = nil
                    expandedCategories.removeValue(forKey: parentCategory.id!)
                }
                if let parentIndex = categories.index(of: parentCategory) {
                    let indexToUpdate = IndexPath.init(row: parentIndex, section: 0)
                    tableView.reloadRows(at: [indexToUpdate], with: .none)
                }
            }
        }
    }
    
    func replaceCategoryInView(_ originalCategory: Category, with category: Category) {
        if let index = categories.index(of: originalCategory) {
            category.subCategories = originalCategory.subCategories
            categories.remove(at: index)
            categories.insert(category, at: index)
            if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? CategoryTableViewCell {
                cell.update(with: category)
            }
        }
        
        if let parent = category.parent, let parentCategory = categories.filter({ $0.id == parent }).first {
            if let subIndex = parentCategory.subCategories?.index(of: originalCategory) {
                parentCategory.subCategories?.remove(at: subIndex)
                parentCategory.subCategories?.insert(category, at: subIndex)
            }
            if let index = categories.index(of: parentCategory) {
                if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? CategoryTableViewCell {
                    cell.update(with: parentCategory)
                }
            }
        }
    }
    
    func updateCategoryNotInView(_ category: Category) {
        var originalSubCategory: Category? = nil
        var originalParent: Category? = nil
        
        for item in categories {
            if let subCategories = item.subCategories {
                for subItem in subCategories {
                    if subItem.id == category.id {
                        originalSubCategory = subItem
                        break
                    }
                }
                if let _ = originalSubCategory {
                    originalParent = item
                    break
                }
            }
        }
        
        if let _ = originalSubCategory, let index = originalParent?.subCategories?.index(of: originalSubCategory!) {
            originalParent?.subCategories?.remove(at: index)
            
            if originalParent?.id == category.parent {
                originalParent?.subCategories?.insert(category, at: index)
            } else {
                if originalParent?.subCategories?.count == 0 {
                    originalParent?.subCategories = nil
                }
                if category.parent == nil {
                    addCategoryToView(category)
                } else {
                    addCategoryToParentView(category)
                }
            }
            
            if let originalParent = originalParent, let index = categories.index(of: originalParent) {
                if let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? CategoryTableViewCell {
                    cell.update(with: originalParent)
                }
            }
        }
    }
}
