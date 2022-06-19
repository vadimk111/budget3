//
//  CategoryExpensesViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 10/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

let categoryChangedNotification = Notification.Name(rawValue: "categoryChanged")

protocol CategoryExpensesViewControllerDelegate: class {
    func categoryExpensesViewController(_ categoryExpensesViewController: CategoryExpensesViewController, didSelect expense: Expense)
    func categoryExpensesViewController(_ categoryExpensesViewController: CategoryExpensesViewController, addExpenseTo category: Category)
    func categoryExpensesViewControllerChanged(_ categoryExpensesViewController: CategoryExpensesViewController)
}

class CategoryExpensesViewController: UITableViewController, SubCategoryHeaderViewDelegate {

    var category: Category? {
        willSet {
            unregisterFromUpdates()
        }
        didSet {
            tableView.reloadData()
            registerToUpdates()
        }
    }
    
    weak var delegate: CategoryExpensesViewControllerDelegate?
    
    deinit {
        unregisterFromUpdates()
    }
    
    //MARK - SubCategoryHeaderViewDelegate
    func subCategoryHeaderViewAdd(_ subCategoryHeaderView: SubCategoryHeaderView) {
        if let subCategories = category?.subCategories {
            delegate?.categoryExpensesViewController(self, addExpenseTo: subCategories[subCategoryHeaderView.section - 1])
        }
    }
}
