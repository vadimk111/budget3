//
//  AddEditExpenseViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 10/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol AddEditExpenseViewControllerDelegate {
    func addEditExpenseViewControllerWillDismiss(_ addEditExpenseViewController: AddEditExpenseViewController)
}

class AddEditExpenseViewController: UIViewController {

    var parentRef: DatabaseReference?
    var expense: Expense?
    var delegate: AddEditExpenseViewControllerDelegate?
    
    @IBOutlet weak var o_titleField: UITextField!
    @IBOutlet weak var o_amountField: UITextField!
    @IBOutlet weak var o_dateLabel: UILabel!
    @IBOutlet weak var o_datePicker: UIDatePicker!
    @IBOutlet weak var o_dateViewConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        o_titleField.text = expense?.title
        if let amount = expense?.amount {
            o_amountField.text = amount.toString()
        }
        if let date = expense?.date {
            o_dateLabel.text = date.toString()
            o_datePicker.date = date
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
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        o_dateLabel.text = sender.date.toString()
    }
    
    @IBAction func didTapDate(_ sender: UITapGestureRecognizer) {
        becomeFirstResponder()
        
        let newConstraintValue: CGFloat = o_dateViewConstraint.constant == 44 ? 260 : 44
        
        UIView.animate(withDuration: 0.3, animations: {
            self.o_dateViewConstraint.constant = newConstraintValue
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        delegate?.addEditExpenseViewControllerWillDismiss(self)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        if let title = o_titleField.text, let amountStr = o_amountField.text, let amount = Float(amountStr)  {
            expense?.title = title
            expense?.amount = amount
            expense?.date = o_datePicker.date
            
            if let parentRef = parentRef {
                expense?.insert(into: parentRef)
            } else if let expense = expense {
                expense.update()
            }
            delegate?.addEditExpenseViewControllerWillDismiss(self)
            dismiss(animated: true, completion: nil)
        }
    }
}
