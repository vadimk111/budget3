//
//  AddEditIncomeViewController.swift
//  Budget
//
//  Created by Vadik on 30/05/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AddEditIncomeViewController: UIViewController {

    var listRef: FIRDatabaseReference?
    var income: Income?
    
    @IBOutlet weak var o_titleField: UITextField!
    @IBOutlet weak var o_amountField: UITextField!
    @IBOutlet weak var o_dateLabel: UILabel!
    @IBOutlet weak var o_datePicker: UIDatePicker!
    @IBOutlet weak var o_dateViewConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = income {
            title = "Edit Income"
        } else {
            income = Income()
            income?.date = Date()
            title = "Add Income"
        }
        
        o_titleField.text = income?.title
        if let amount = income?.amount {
            o_amountField.text = amount.toString()
        }
        if let date = income?.date {
            o_dateLabel.text = date.toString()
            o_datePicker.date = date
        }
    }
        
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if o_titleField.text?.characters.count == 0 {
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
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        if let title = o_titleField.text, let amountStr = o_amountField.text, let amount = Float(amountStr)  {
            income?.title = title
            income?.amount = amount
            income?.date = o_datePicker.date
            
            if let listRef = listRef {
                income?.insert(into: listRef)
            } else if let income = income {
                income.update()
            }
            dismiss(animated: true, completion: nil)
        }
    }
}
