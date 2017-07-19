//
//  CategoriesPhoneViewController.swift
//  Budget
//
//  Created by Vadik on 23/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class CategoriesPhoneViewController: CategoriesBaseDeviceViewController {

    @IBOutlet weak var o_editBarButton: UIBarButtonItem!
    @IBOutlet weak var o_addBarButton: UIBarButtonItem!
    
    @IBAction func didTapEdit(_ sender: UIBarButtonItem) {
        if let categoriesViewController = categoriesViewController {
            if categoriesViewController.tableView.isEditing {
                sender.image = #imageLiteral(resourceName: "edit-tool")
                o_addBarButton.image = #imageLiteral(resourceName: "plus")
                o_addBarButton.tag = 0
                categoriesViewController.tableView.setEditing(false, animated: true)
            } else {
                categoriesViewController.tableView.setEditing(true, animated: true)
                sender.image = #imageLiteral(resourceName: "checked")
                o_addBarButton.image = #imageLiteral(resourceName: "delete-button")
                o_addBarButton.tag = 1
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "addCategory" && o_addBarButton.tag == 1 {
            let a = UIAlertController(title: "Delete all categories ?", message: nil, preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "Delete", style: .default) { action -> Void in
                self.categoriesViewController?.clearBudget()
                self.didTapEdit(self.o_editBarButton)
            })
            a.addAction(UIAlertAction(title: "Cancel", style: .default) { action -> Void in })
            self.present(a, animated: true, completion: nil)
            return false
        }
        return true
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
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            if let category = sender as? Category {
                (segue.destination as? CategoryDetailPhoneViewController)?.category = category
            }
        }
    }
    
    //MARK - CategoriesViewControllerDelegate
    override func categoriesViewController(_ categoriesViewController: CategoriesViewController, didSelect category: Category) {
        performSegue(withIdentifier: "drillDown", sender: category)
    }
    
    override func categoriesViewControllerChanged(_ categoriesViewController: CategoriesViewController) {
        super.categoriesViewControllerChanged(categoriesViewController)
        o_editBarButton.isEnabled = categoriesViewController.categories.count > 0
    }
    
    //MARK: CategoriesHeaderViewDelegate
    override func categoriesHeaderView(_ categoriesHeaderView: CategoriesHeaderView, didCreateDatePicker datePicker: DatePickerView) {
        presentDatePickerOverCurrentContext(datePicker: datePicker)
    }

    override func categoriesHeaderView(_ categoriesHeaderView: CategoriesHeaderView, didChangeDate date: Date) {
        super.categoriesHeaderView(categoriesHeaderView, didChangeDate: date)
        closeDatePicker()
    }
}
