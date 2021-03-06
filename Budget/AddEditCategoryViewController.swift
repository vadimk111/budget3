//
//  CreateCategoryViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 08/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol AddEditCategoryViewControllerDelegate: class {
    func addEditCategoryViewController(_ addEditCategoryViewController: AddEditCategoryViewController, copyCategoryToFollowingMonths category: Category)
}

class AddEditCategoryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var delegate: AddEditCategoryViewControllerDelegate?
    
    var budgetRef: DatabaseReference?
    var category: Category?
    var parents: [Category] = []
    var highestOrder: Float = 0
    var initialParentSelected = false
    
    @IBOutlet weak var o_billSwitch: UISwitch!
    @IBOutlet weak var o_titleField: UITextField!
    @IBOutlet weak var o_amountField: UITextField!
    @IBOutlet weak var o_pickerView: UIPickerView!
    @IBOutlet weak var o_parentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var o_parentLabel: UILabel!
    @IBOutlet weak var o_cloneSwitch: UISwitch!
    @IBOutlet weak var o_cloneContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let _ = category {
            title = "Edit Category"
            o_cloneContainer.isHidden = true
        } else {
            category = Category()
            category?.order = highestOrder + 100
            title = "Add Category"
        }
        
        o_titleField.text = category?.title
        if let amount = category?.amount {
            o_amountField.text = amount.toString()
        }
        if let isBillValue = category?.isBill {
            o_billSwitch.isOn = isBillValue
        }
        
        if let parent = category?.parent {
            o_parentLabel.text = parents.filter({ $0.id == parent }).first?.title
            o_parentLabel.textColor = UIColor.black
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if o_titleField.text?.count == 0 {
            o_titleField.becomeFirstResponder()
        }
    }
    
    @IBAction func didChangeIsBill(_ sender: UISwitch) {
        category?.isBill = sender.isOn
    }
    
    @IBAction func didTapParent(_ sender: UITapGestureRecognizer) {
        becomeFirstResponder()
        
        if !initialParentSelected {
            initialParentSelected = true
            
            if let parent = parents.filter({ $0.id == category?.parent }).first {
                if let index = parents.index(of: parent) {
                    o_pickerView.selectRow(index + 1, inComponent: 0, animated: false)
                }
            }
        }
        
        let newConstraintValue: CGFloat = o_parentHeightConstraint.constant == 44 ? 260 : 44
        
        UIView.animate(withDuration: 0.3, animations: {
            self.o_parentHeightConstraint.constant = newConstraintValue
            self.view.layoutIfNeeded()
        })
    }
        
    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        if let title = o_titleField.text {
            category?.title = title
            
            if let amountStr = o_amountField.text, let amount = Float(amountStr) {
                category?.amount = amount
            } else {
                category?.amount = 0
            }
            
            if let budgetRef = budgetRef {
                category?.insert(into: budgetRef)
                
                if o_cloneSwitch.isOn {
                    delegate?.addEditCategoryViewController(self, copyCategoryToFollowingMonths: category!)
                }
                
            } else if let category = category {
                category.update()
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return parents.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0 {
            let parent = parents[row - 1]
            o_parentLabel.text = parent.title
            category?.parent = parent.id
            if let subCategories = parent.subCategories, let last = subCategories.last {
                category?.order = last.order + 100
            } else {
                category?.order = 100
            }
            o_parentLabel.textColor = UIColor.black
        } else {
            o_parentLabel.text = "Sub-category of"
            category?.parent = nil
            category?.order = highestOrder + 100
            o_parentLabel.textColor = UIColor(red: 199 / 255, green: 199 / 255, blue: 205 / 255, alpha: 1)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row > 0 ? parents[row - 1].title : "None"
    }
}
