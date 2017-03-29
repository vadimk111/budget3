//
//  CategoriesPhoneViewController.swift
//  Budget
//
//  Created by Vadik on 23/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class CategoriesPhoneViewController: BaseDeviceViewController {

    @IBAction func didTapEdit(_ sender: UIBarButtonItem) {
        if let categoriesViewController = categoriesViewController {
            if categoriesViewController.tableView.isEditing {
                sender.image = UIImage(named: "edit-tool")
                categoriesViewController.tableView.setEditing(false, animated: true)
            } else {
                categoriesViewController.tableView.setEditing(true, animated: true)
                sender.image = UIImage(named: "checked")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categories" {
            categoriesViewController = segue.destination as? CategoriesViewController
            categoriesViewController?.delegate = self
            categoriesViewController?.tableSeparatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        } else if segue.identifier == "addCategory" {
            prepareForAddCategory(from: segue)
        } else if segue.identifier == "editCategory" {
            prepareForEditCategory(from: segue, sender: sender)
        } else if segue.identifier == "drillDown" {
            if let categoriesViewController = categoriesViewController {
                let backItem = UIBarButtonItem()
                backItem.title = ""
                navigationItem.backBarButtonItem = backItem
                
                if let category = sender as? Category {
                    (segue.destination as? CategoryDetailPhoneViewController)?.category = category
                    (segue.destination as? CategoryDetailPhoneViewController)?.currentDate = categoriesViewController.date
                }
            }
        }
    }
    
    //MARK - CategoriesViewControllerDelegate
    override func categoriesViewController(_ categoriesViewController: CategoriesViewController, didSelect category: Category) {
        performSegue(withIdentifier: "drillDown", sender: category)
    }
}
