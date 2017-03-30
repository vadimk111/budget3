//
//  CategoriesBaseDeviceViewController.swift
//  Budget
//
//  Created by Vadik on 24/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class CategoriesBaseDeviceViewController: UIViewController, CategoriesHeaderViewDelegate, CategoriesViewControllerDelegate {

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
            let vc: AddEditCategoryViewController? = segue.destinationController()
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
                let vc: AddEditCategoryViewController? = segue.destinationController()
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
    
    //MARK: CategoriesHeaderViewDelegate
    func categoriesHeaderViewDidGoNext(_ categoriesHeaderView: CategoriesHeaderView) {
        categoriesViewController?.goNextMonth()
    }
    
    func categoriesHeaderViewDidGoPrev(_ categoriesHeaderView: CategoriesHeaderView) {
        categoriesViewController?.goPrevMonth()
    }
    
    //MARK - CategoriesViewControllerDelegate
    func categoriesViewController(_ categoriesViewController: CategoriesViewController, didSelect category: Category) {
        
    }
    
    func categoriesViewController(_ categoriesViewController: CategoriesViewController, didEdit category: Category) {
        performSegue(withIdentifier: "editCategory", sender: category)
    }
    
    func categoriesViewControllerChanged(_ categoriesViewController: CategoriesViewController) {
        o_categoriesHeaderView?.fill(with: categoriesViewController.availableParents, date: categoriesViewController.date)
    }
    
    func categoriesViewControllerRowDeselected(_ categoriesViewController: CategoriesViewController) {
        
    }
}
