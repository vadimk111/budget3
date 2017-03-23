//
//  CategoriesPadViewController.swift
//  Budget
//
//  Created by Vadik on 15/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseAuth

class CategoriesPadViewController: UIViewController, CategoriesHeaderViewDelegate, CategoriesViewControllerDelegate {

    @IBOutlet weak var o_categoriesHeaderView: CategoriesHeaderView!
    
    var categoriesViewController: CategoriesViewController?
    var expensesViewController: CategoryExpensesViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: signInStateChangedNotification, object: nil, queue: nil, using: { [unowned self] notification in
            self.reload()
        })
        
        o_categoriesHeaderView.delegate = self
        o_categoriesHeaderView.fill(with: [], date: Date())
        
        reload()
    }

    func reload() {
        categoriesViewController?.reload()
    }
    
    func categoriesHeaderViewDidGoNext(_ categoriesHeaderView: CategoriesHeaderView) {
        
    }

    func categoriesHeaderViewDidGoPrev(_ categoriesHeaderView: CategoriesHeaderView) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categories" {
            categoriesViewController = segue.destination as? CategoriesViewController
            categoriesViewController?.delegate = self
        } else if segue.identifier == "expenses" {
            expensesViewController = segue.destination as? CategoryExpensesViewController
        }
    }
    
    func categoriesViewController(_ categoriesViewController: CategoriesViewController, didSelect category: Category) {
        expensesViewController?.reload(with: category)
    }
    
    func categoriesViewControllerChanged(_ categoriesViewController: CategoriesViewController) {
        o_categoriesHeaderView?.fill(with: categoriesViewController.availableParents, date: categoriesViewController.date)
    }
}
