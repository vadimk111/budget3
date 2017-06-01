//
//  CategoriesBaseDeviceViewController.swift
//  Budget
//
//  Created by Vadik on 24/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CategoriesBaseDeviceViewController: UIViewController, CategoriesHeaderViewDelegate, CategoriesViewControllerDelegate {

    var categoriesViewController: CategoriesViewController?
    
    @IBOutlet weak var o_categoriesHeaderView: CategoriesHeaderView!
    
    var incomesRef: FIRDatabaseReference?
    var incomes: [Income] = [Income]()
    var incomesAddHandler: UInt?
    var incomesChangeHandler: UInt?
    var incomesRemoveHandler: UInt?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(CategoriesBaseDeviceViewController.onSignInStateChanged), name: signInStateChangedNotification, object: nil)
        
        o_categoriesHeaderView.delegate = self
        o_categoriesHeaderView.fill(with: [], date: Date())
        
        reload()
    }
    
    func onSignInStateChanged() {
        reload()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        unregisterFromUpdates()
    }
    
    func reload() {
        categoriesViewController?.reload()
    }
    
    func reloadIncomes() {
        unregisterFromUpdates()
        
        let ref = FIRDatabase.database().reference().child("incomes")
        if let date = categoriesViewController?.date, let listId = ModelHelper.budgetId(for: date) {
            incomesRef = ref.child(listId)
            incomesRef?.observeSingleEvent(of: .value, with: { snapshot in
                self.incomes = []
                for child in snapshot.children {
                    self.incomes.append(Income(snapshot: child as! FIRDataSnapshot))
                }
                self.registerToUpdates()
                self.o_categoriesHeaderView.updateIncome(with: self.incomes)
            })
        } else {
            incomes = []
            self.o_categoriesHeaderView.updateIncome(with: self.incomes)
        }
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
        reloadIncomes()
        o_categoriesHeaderView?.fill(with: categoriesViewController.availableParents, date: categoriesViewController.date)
    }
    
    func categoriesViewControllerRowDeselected(_ categoriesViewController: CategoriesViewController) {
        
    }
}
