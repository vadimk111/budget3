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
            
            if let parent = category.parent {
                if let parentCategory = self.categories.filter({ $0.id == parent }).first {
                    if parentCategory.subCategories == nil {
                        parentCategory.subCategories = []
                    }
                    if !parentCategory.subCategories!.contains(where: { $0.id == category.id } ) {
                        parentCategory.subCategories!.append(category)
                        
                        if let index = self.categories.index(of: parentCategory) {
                            let indexToUpdate = IndexPath.init(row: index, section: 0)
                            if let cell = self.tableView.cellForRow(at: indexToUpdate) as? CategoryTableViewCell {
                                if cell.isExpanded() {
                                    let insertIndex = index + parentCategory.subCategories!.count
                                    self.categories.insert(category, at: insertIndex)
                                    self.tableView.insertRows(at: [IndexPath.init(row: insertIndex, section: 0)], with: .fade)
                                }
                                self.tableView.reloadRows(at: [indexToUpdate], with: .none)
                            }
                        }
                    }
                }
            } else {
                if !self.categories.contains(where: { $0.id == category.id } ) {
                    self.categories.append(category)
                    self.tableView.insertRows(at: [IndexPath.init(row: self.tableView.numberOfRows(inSection: 0), section: 0)], with: .fade)
                }
            }
            self.updateHeaderView()
        })
    }
    
    func observeChildDelete(on budgetRef: FIRDatabaseReference?) {
        budgetRef?.observe(.childRemoved, with: { [unowned self] snapshot in
            let category = Category(snapshot: snapshot)
            if let index = self.categories.index(where: { $0.id == category.id }) {
                self.categories.remove(at: index)
                self.tableView.deleteRows(at: [IndexPath.init(row: index, section: 0)], with: .fade)
                
                if let parent = category.parent {
                    if let parentCategory = self.categories.filter({ $0.id == parent }).first {
                        if let index = parentCategory.subCategories?.index(where: { $0.id == category.id }) {
                            parentCategory.subCategories?.remove(at: index)
                            if parentCategory.subCategories!.count == 0 {
                                parentCategory.subCategories = nil
                            }
                            if let parentIndex = self.categories.index(of: parentCategory) {
                                let indexToUpdate = IndexPath.init(row: parentIndex, section: 0)
                                self.tableView.reloadRows(at: [indexToUpdate], with: .none)
                            }
                        }
                    }
                }
            }
            self.updateHeaderView()
        })
    }
    
    func observeChildUpdate(on budgetRef: FIRDatabaseReference?) {
        budgetRef?.observe(.childChanged, with: { [unowned self] snapshot in
            let category = Category(snapshot: snapshot)
            
            if let origCategory = self.categories.filter({ $0.id == category.id }).first {
                if let index = self.categories.index(of: origCategory) {
                    category.subCategories = origCategory.subCategories
                    self.categories.remove(at: index)
                    self.categories.insert(category, at: index)
                    self.tableView.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: .none)
                }
            }
            
            if let parent = category.parent {
                if let parentCategory = self.categories.filter({ $0.id == parent }).first {
                    if let origCategory = parentCategory.subCategories?.filter({ $0.id == category.id }).first {
                        if let index = parentCategory.subCategories?.index(of: origCategory) {
                            parentCategory.subCategories?.remove(at: index)
                            parentCategory.subCategories?.insert(category, at: index)
                        }
                    }
                    if let index = self.categories.index(of: parentCategory) {
                        self.tableView.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: .none)
                    }
                }
            }
            self.updateHeaderView()
        })
    }
}
