//
//  CategoriesUniversalViewController.swift
//  Budget
//
//  Created by Vadik on 27/07/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CategoriesUniversalViewController: UIViewController {

    var categoriesViewController: CategoriesViewController?
    var categoryExpensesViewController: CategoryExpensesViewController?
    
    @IBOutlet weak var o_categoriesContainer: UIView!
    @IBOutlet weak var o_addExpenseBtn: UIButton!
    @IBOutlet weak var o_editCategoryBtn: UIButton!
    @IBOutlet weak var o_addCategoryBtn: UIButton!
    @IBOutlet weak var o_categoriesHeaderView: CategoriesHeaderView!
    @IBOutlet weak var o_editBarButton: UIBarButtonItem!
    @IBOutlet weak var o_addBarButton: UIBarButtonItem!
    
    var incomesRef: FIRDatabaseReference?
    var incomes: [Income] = [Income]()
    var incomesAddHandler: UInt?
    var incomesChangeHandler: UInt?
    var incomesRemoveHandler: UInt?
    
    var datePickerIsShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: signInStateChangedNotification, object: nil, queue: nil, using: { [weak self] (notification) -> Void in
            self?.reload()
        })
        
        NotificationCenter.default.addObserver(forName: viewRemovedAtBottomNotification, object: nil, queue: nil, using: { (notification) -> Void in
            NotificationCenter.default.post(Notification(name: datePickerControllerDidDisappearNotification))
        })
        
        o_categoriesHeaderView.delegate = self
        o_categoriesHeaderView.fill(with: [], date: Date())
        
        updateLayout()
        
        reload()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateLayout()
    }
    
    deinit {
        unregisterFromUpdates()
    }
    
    func updateLayout() {
        if isCompactWidth {
            o_categoriesContainer.layer.shadowRadius = 0
            o_categoriesContainer.layer.shadowColor = UIColor.clear.cgColor
            o_categoriesContainer.layer.shadowOpacity = 0
            o_categoriesContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
            
            o_categoriesHeaderView.layer.shadowRadius = 0
            o_categoriesHeaderView.layer.shadowColor = UIColor.clear.cgColor
            o_categoriesHeaderView.layer.shadowOpacity = 0
            o_categoriesHeaderView.layer.shadowOffset = CGSize(width: 0, height: 0)
            
            o_addBarButton.isEnabled = true
            o_editBarButton.isEnabled = true

            if let categoriesViewController = categoriesViewController {
                if categoriesViewController.tableView.isEditing {
                    o_editBarButton.image = #imageLiteral(resourceName: "checked")
                    o_addBarButton.image = #imageLiteral(resourceName: "delete-button")
                } else {
                    o_addBarButton.image = #imageLiteral(resourceName: "plus")
                    o_editBarButton.image = #imageLiteral(resourceName: "edit-tool")
                }
            }
            if datePickerIsShown {
                dismiss(animated: false)
            }
        } else {
            o_categoriesContainer.layer.shadowRadius = 2
            o_categoriesContainer.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
            o_categoriesContainer.layer.shadowOpacity = 1
            o_categoriesContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
            
            o_categoriesHeaderView.layer.shadowRadius = 2
            o_categoriesHeaderView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
            o_categoriesHeaderView.layer.shadowOpacity = 1
            o_categoriesHeaderView.layer.shadowOffset = CGSize(width: 0, height: 0)
            
            o_addBarButton.isEnabled = false
            o_addBarButton.image = nil
            
            o_editBarButton.isEnabled = false
            o_editBarButton.image = nil
            
            if datePickerIsShown {
                dismissViewAtBottom()
            }
        }
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
    
    @IBAction func didTapEdit(_ sender: Any) {
        if let categoriesViewController = categoriesViewController {
            if categoriesViewController.tableView.isEditing {
                if isCompactWidth {
                    o_editBarButton.image = #imageLiteral(resourceName: "edit-tool")
                    o_addBarButton.image = #imageLiteral(resourceName: "plus")
                }
                o_addBarButton.tag = 0
                
                o_editCategoryBtn.setTitle("Edit", for: .normal)
                o_addCategoryBtn.setTitle("Add Category", for: .normal)
                o_addCategoryBtn.tag = 0

                categoriesViewController.tableView.setEditing(false, animated: true)
            } else {
                categoriesViewController.tableView.setEditing(true, animated: true)
                
                if isCompactWidth {
                    o_editBarButton.image = #imageLiteral(resourceName: "checked")
                    o_addBarButton.image = #imageLiteral(resourceName: "delete-button")
                }
                o_addBarButton.tag = 1
                
                o_editCategoryBtn.setTitle("Done", for: .normal)
                o_addCategoryBtn.setTitle("Clear", for: .normal)
                o_addCategoryBtn.tag = 1
            }
        }
    }

}
