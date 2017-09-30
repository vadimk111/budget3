//
//  CategoriesBaseDeviceViewController.swift
//  Budget
//
//  Created by Vadik on 24/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CategoriesBaseDeviceViewController: UIViewController, CategoriesHeaderViewDelegate, CategoriesViewControllerDelegate, AddEditCategoryViewControllerDelegate {

    var categoriesViewController: CategoriesViewController?
    
    @IBOutlet weak var o_categoriesHeaderView: CategoriesHeaderView!
    
    var incomesRef: DatabaseReference?
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
        
        if let date = categoriesViewController?.date, let ref = ModelHelper.incomeReference(for: date) {
            incomesRef = ref
            incomesRef?.observeSingleEvent(of: .value, with: { snapshot in
                self.incomes = []
                for child in snapshot.children {
                    self.incomes.append(Income(snapshot: child as! DataSnapshot))
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
            vc?.delegate = self
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
    
    func categoriesHeaderView(_ categoriesHeaderView: CategoriesHeaderView, didCreateDatePicker datePicker: DatePickerView) {
    }
        
    func categoriesHeaderView(_ categoriesHeaderView: CategoriesHeaderView, didChangeDate date: Date) {
        categoriesViewController?.changeToDate(date, copyClosestBudget: false)
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
    
    //MARK - AddEditCategoryViewControllerDelegate
    func addEditCategoryViewController(_ addEditCategoryViewController: AddEditCategoryViewController, copyCategoryToFollowingMonths category: Category) {
        if let date = categoriesViewController?.date {
            var parentName: String? = nil
            if let parentId = category.parent {
                parentName = categoriesViewController?.categories.first(where: { $0.id == parentId })?.title
            }
            copyCategory(category, date: date, parentName: parentName)
        }
    }
    
    func copyCategory(_ category: Category, date: Date, parentName: String?) {
        let calendar = Calendar.current
        var year = calendar.component(.year, from: date)
        var month = calendar.component(.month, from: date)
        
        var comp = DateComponents()
        if month == 12 {
            year += 1
            month = 1
        } else {
            month += 1
        }
        
        comp.day = 1
        comp.month = month
        comp.year = year
        
        let nextDate = calendar.date(from: comp)!
        
        if let nextBudgetRef = ModelHelper.budgetReference(for: nextDate) {
            nextBudgetRef.observeSingleEvent(of: .value, with: { [unowned self] snapshot in
                if snapshot.children.allObjects.count > 0 {
                    
                    let categories: [Category] = snapshot.children.map { (child: Any) -> Category in
                        return Category(snapshot: child as! DataSnapshot)
                        }.sorted(by: { (item1: Category, item2: Category) -> Bool in
                            return item1.order < item2.order
                        })
                    
                    if let _ = parentName {
                        category.parent = categories.first(where: { $0.title == parentName && $0.parent == nil })?.id
                    }
                    
                    if let last = categories.filter({ $0.parent == category.parent }).last {
                        category.order = last.order + 100
                    } else {
                        category.order = 100
                    }
                    
                    category.insert(into: nextBudgetRef)
                    self.copyCategory(category, date: nextDate, parentName: parentName)
                }
            })
        }
    }
}
