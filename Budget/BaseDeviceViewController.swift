//
//  BaseDeviceViewController.swift
//  Budget
//
//  Created by Vadik on 24/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class BaseDeviceViewController: UIViewController, CategoriesHeaderViewDelegate, CategoriesViewControllerDelegate {

    var categoriesViewController: CategoriesViewController?
    
    @IBOutlet weak var o_categoriesHeaderView: CategoriesHeaderView!
    
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
    
    func prepareForAddCategory(from segue: UIStoryboardSegue) {
        if let categoriesViewController = categoriesViewController {
            let vc = addEditController(from: segue)
            vc?.parents = categoriesViewController.availableParents
            if let last = categoriesViewController.availableParents.last {
                vc?.highestOrder = last.order
            }
            vc?.budgetRef = categoriesViewController.budgetRef
        }
    }
    
    func prepareForEditCategory(from segue: UIStoryboardSegue, sender: Any?) {
        if let categoriesViewController = categoriesViewController {
            if let category = sender as? Category {
                let vc = addEditController(from: segue)
                vc?.category = category.makeCopy()
                vc?.category?.setDatabaseReference(ref: category.getDatabaseReference())
                
                if category.subCategories == nil {
                    vc?.parents = categoriesViewController.availableParents.filter({ $0.id != category.id })
                }
                if let last = categoriesViewController.availableParents.last {
                    vc?.highestOrder = last.order
                }
            }
        }
    }

    func categoriesHeaderViewDidGoNext(_ categoriesHeaderView: CategoriesHeaderView) {
        
    }
    
    func categoriesHeaderViewDidGoPrev(_ categoriesHeaderView: CategoriesHeaderView) {
        
    }

    func addEditController(from segue: UIStoryboardSegue) -> AddEditCategoryViewController? {
        if let nav = segue.destination as? UINavigationController {
            return nav.viewControllers.first as? AddEditCategoryViewController
        }
        return segue.destination as? AddEditCategoryViewController
    }
    
    func categoriesViewController(_ categoriesViewController: CategoriesViewController, didSelect category: Category) {
        
    }
    
    func categoriesViewController(_ categoriesViewController: CategoriesViewController, didEdit category: Category) {
        performSegue(withIdentifier: "editCategory", sender: category)
    }
    
    func categoriesViewControllerChanged(_ categoriesViewController: CategoriesViewController) {
        o_categoriesHeaderView?.fill(with: categoriesViewController.availableParents, date: categoriesViewController.date)
    }
}
