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
                self.addCategoryToParentView(category)
            } else {
                self.addCategoryToView(category)
            }
            self.updateHeaderView()
        })
    }
    
    func observeChildDelete(on budgetRef: FIRDatabaseReference?) {
        budgetRef?.observe(.childRemoved, with: { [unowned self] snapshot in
            let category = Category(snapshot: snapshot)
            self.deleteCategoryFromView(category)
            self.updateHeaderView()
        })
    }
    
    func observeChildUpdate(on budgetRef: FIRDatabaseReference?) {
        budgetRef?.observe(.childChanged, with: { [unowned self] snapshot in
            if let updatedCategory = self.categories.filter({ $0.id == snapshot.key }).first {
                if let origCategory = self.categoryBeforeUpdate {
                    if origCategory.parent != updatedCategory.parent {
                        if updatedCategory.parent == nil {
                            self.deleteCategoryFromView(origCategory)
                            self.addCategoryToView(updatedCategory)
                        } else {
                            self.deleteCategoryFromView(origCategory)
                            self.addCategoryToParentView(updatedCategory)
                        }
                    } else {
                        self.updateCategoryInView(updatedCategory)
                    }
                    self.categoryBeforeUpdate = nil
                } else {
                    self.updateCategoryInView(updatedCategory)
                }
                self.updateHeaderView()
            }
        })
    }
    
    func addCategoryToView(_ category: Category) {
        if !categories.contains(where: { $0.id == category.id } ) {
            categories.append(category)
            tableView.insertRows(at: [IndexPath.init(row: tableView.numberOfRows(inSection: 0), section: 0)], with: .fade)
        }
    }
    
    func addCategoryToParentView(_ category: Category) {
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
            }
        }
    }
    
    func deleteCategoryFromView(_ category: Category) {
        if let index = categories.index(where: { $0.id == category.id }) {
            categories.remove(at: index)
            tableView.deleteRows(at: [IndexPath.init(row: index, section: 0)], with: .fade)
            
            if let _ = category.parent {
                deleteCategoryFromParentData(category)
            }
        }
    }
    
    func deleteCategoryFromParentData(_ category: Category) {
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
    
    func updateCategoryInView(_ category: Category) {
        if let index = categories.index(where: { $0.id == category.id }) {
            tableView.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: .none)
        }
        
        if let parent = category.parent {
            if let parentCategory = categories.filter({ $0.id == parent }).first {
                if let index = categories.index(of: parentCategory) {
                    tableView.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: .none)
                }
            }
        }
    }
}
