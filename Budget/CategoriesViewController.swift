//
//  CategoriesViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 20/12/2016.
//  Copyright © 2016 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CategoriesViewController: UITableViewController, TabBarComponent {

    var budgetRef: FIRDatabaseReference?
    var categories: [Category] = []
    var date: Date = Date()
    var dateChanged = false
    var isRefreshing = false
    var closestBudget: [Category]?
    var expandedCategories: [String : Bool] = [:]
    var headerView: CategoriesHeaderView!
    
    @IBOutlet weak var o_editButton: UIBarButtonItem!
    
    var availableParents: [Category] {
        return categories.filter({ $0.parent == nil })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: logoutNotification, object: nil, queue: nil, using: { [unowned self] notification in
            self.closestBudget = nil
            self.date = Date()
        })
        NotificationCenter.default.addObserver(forName: loginNotification, object: nil, queue: nil, using: { [unowned self] notification in
            self.reload()
        })
        
        headerView = CategoriesHeaderView()
        headerView.delegate = self
        headerView.fill(with: availableParents, date: date)
    }
    
    deinit {
        unregisterFromUpdates(budgetRef: budgetRef)
    }
    
    func reload() {
        let ref = FIRDatabase.database().reference().child("budgets")
        if let budgetId = ModelHelper.budgetId(for: date) {
            budgetRef = ref.child(budgetId)
            budgetRef?.observeSingleEvent(of: .value, with: { [unowned self] snapshot in
                if !self.prepareBudget(from: snapshot) && !self.isRefreshing {
                    if !self.copyClosestBudget() && !self.dateChanged {
                        self.tryPrevBudgetAndCopy()
                    }
                }
                self.registerToUpdates(budgetRef: self.budgetRef)
                self.tableView.reloadData()
                self.updateHeaderView()
                
                if self.isRefreshing {
                    self.isRefreshing = false
                    self.tableView.refreshControl?.endRefreshing()
                }
            })
        }
    }
    
    func updateHeaderView() {
        headerView.fill(with: availableParents, date: date)
    }
    
    func prepareBudget(from snapshot: FIRDataSnapshot) -> Bool {
        categories = []
        var subCategories: [String : [Category]] = [:]
        var budgetExist = false
        
        for child in snapshot.children {
            budgetExist = true
            
            let category = Category(snapshot: child as! FIRDataSnapshot)
            if let parent = category.parent {
                var mutableArr = [Category]()
                if let arr = subCategories[parent] {
                    mutableArr.append(contentsOf: arr)
                }
                mutableArr.append(category)
                subCategories[parent] = mutableArr
            } else {
                categories.append(category)
            }
        }
        
        if budgetExist {
            categories.sort(by: { (item1: Category, item2: Category) -> Bool in
                return item1.order < item2.order
            })
            
            for key in subCategories.keys {
                if let parentCategory = categories.filter({ $0.id == key }).first {
                    parentCategory.subCategories = subCategories[key]?.sorted(by: { (item1: Category, item2: Category) -> Bool in
                        return item1.order < item2.order
                    })
                }
            }
        }
        
        return budgetExist
    }
    
    @discardableResult
    func copyClosestBudget() -> Bool {
        if let closestBudget = closestBudget, let budgetRef = budgetRef {
            for category in closestBudget {
                let newCategory = category.makeCopy()
                newCategory.id = nil
                newCategory.expenses = nil
                let newCategoryId = newCategory.insert(into: budgetRef)
                
                if let subCategories = category.subCategories {
                    for subCategory in subCategories {
                        let newSubCategory = subCategory.makeCopy()
                        newSubCategory.id = nil
                        newSubCategory.expenses = nil
                        newSubCategory.parent = newCategoryId
                        newSubCategory.insert(into: budgetRef)
                    }
                }
            }
            return true
        }
        return false
    }
    
    func tryPrevBudgetAndCopy() {
        let calendar = Calendar.current
        var year = calendar.component(.year, from: date)
        var month = calendar.component(.month, from: date)
        
        var comp = DateComponents()
        if month == 1 {
            year -= 1
            month = 12
        } else {
            month -= 1
        }
        
        comp.day = 1
        comp.month = month
        comp.year = year
        
        let prevDate = calendar.date(from: comp)!
        
        let ref = FIRDatabase.database().reference().child("budgets")
        if let budgetId = ModelHelper.budgetId(for: prevDate) {
            let prevBudgetRef = ref.child(budgetId)
            prevBudgetRef.observeSingleEvent(of: .value, with: { [unowned self] snapshot in
                if self.prepareBudget(from: snapshot) {
                    self.closestBudget = self.categories
                    self.categories = []
                    self.copyClosestBudget()
                }
            })
        }
    }
    
    @IBAction func didPullToRefresh(_ sender: UIRefreshControl) {
        isRefreshing = true
        expandedCategories = [:]
        unregisterFromUpdates(budgetRef: budgetRef)
        reload()
    }
    
    @IBAction func didTapEdit(_ sender: UIBarButtonItem) {
        if tableView.isEditing {
            o_editButton.image = UIImage(named: "edit-tool")
            tableView.setEditing(false, animated: true)
        } else {
            tableView.setEditing(true, animated: true)
            o_editButton.image = UIImage(named: "checked")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCategory" {
            let vc = addEditController(from: segue)
            vc?.parents = availableParents
            if let last = availableParents.last {
                vc?.highestOrder = last.order
            }
            vc?.budgetRef = budgetRef
        } else if segue.identifier == "editCategory" {
            if let index = sender as? IndexPath {
                let category = categories[index.row]
                
                let vc = addEditController(from: segue)
                vc?.category = category.makeCopy()
                
                if category.subCategories == nil {
                    vc?.parents = availableParents.filter({ $0.id != category.id })
                }
                if let last = availableParents.last {
                    vc?.highestOrder = last.order
                }
            }
        } else if segue.identifier == "drillDown" {
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            if let index = tableView.indexPathForSelectedRow {
                (segue.destination as? CategoryViewController)?.category = categories[index.row]
                (segue.destination as? CategoryViewController)?.currentDate = date
            }
        }
    }
    
    func addEditController(from segue: UIStoryboardSegue) -> AddEditCategoryViewController? {
        if let nav = segue.destination as? UINavigationController {
            return nav.viewControllers.first as? AddEditCategoryViewController
        }
        return segue.destination as? AddEditCategoryViewController
    }    
}
