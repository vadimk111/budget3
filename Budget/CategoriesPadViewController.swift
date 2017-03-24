//
//  CategoriesPadViewController.swift
//  Budget
//
//  Created by Vadik on 15/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseAuth

class CategoriesPadViewController: BaseDeviceViewController {

    var expensesViewController: CategoryExpensesViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
        
    @IBAction func didTapEdit(_ sender: UIButton) {
        if let categoriesViewController = categoriesViewController {
            if categoriesViewController.tableView.isEditing {
                sender.setImage(UIImage(named: "edit-tool"), for: .normal)
                categoriesViewController.tableView.setEditing(false, animated: true)
            } else {
                categoriesViewController.tableView.setEditing(true, animated: true)
                sender.setImage(UIImage(named: "checked"), for: .normal)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categories" {
            categoriesViewController = segue.destination as? CategoriesViewController
            categoriesViewController?.delegate = self
        } else if segue.identifier == "expenses" {
            expensesViewController = segue.destination as? CategoryExpensesViewController
        } else if segue.identifier == "addCategory" {
            prepareForAddCategory(from: segue)
        } else if segue.identifier == "editCategory" {
            prepareForEditCategory(from: segue, sender: sender)
        }
    }
    
    override func categoriesViewController(_ categoriesViewController: CategoriesViewController, didSelect category: Category) {
        expensesViewController?.reload(with: category)
    }
}
