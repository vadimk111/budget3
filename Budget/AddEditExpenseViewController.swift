//
//  AddEditExpenseViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 10/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Expression

protocol AddEditExpenseViewControllerDelegate: class {
    func addEditExpenseViewControllerWillDismiss(_ addEditExpenseViewController: AddEditExpenseViewController)
}

class AddEditExpenseViewController: UIViewController, AutoCompleteViewControllerDelegate {

    var parentRef: DatabaseReference?
    var expense: Expense?
    var autoCompleteViewController: AutoCompleteViewController?
    weak var delegate: AddEditExpenseViewControllerDelegate?
    
    @IBOutlet weak var o_plusButton: UIButton!
    @IBOutlet weak var o_titleField: UITextField!
    @IBOutlet weak var o_amountField: UITextField!
    @IBOutlet weak var o_dateLabel: UILabel!
    @IBOutlet weak var o_datePicker: UIDatePicker!
    @IBOutlet weak var o_dateViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var o_autoCompleteContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        o_titleField.addTarget(self, action: #selector(titleChanged), for: .editingChanged)
        o_titleField.text = expense?.title
        
        o_autoCompleteContainer.layer.borderWidth = 1
        o_autoCompleteContainer.layer.borderColor = UIColor(red: 224 / 255, green: 224 / 255, blue: 224 / 255, alpha: 1).cgColor
        
        if let amount = expense?.amount {
            o_amountField.text = amount.toString()
        }
        if let date = expense?.date {
            o_dateLabel.text = date.toString()
            o_datePicker.date = date
        }
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(AddEditExpenseViewController.longPressOnPlusButton))
        o_plusButton.addGestureRecognizer(gesture)
    }
    
    @objc func longPressOnPlusButton(sender: UILongPressGestureRecognizer) {
        if sender.state == .ended {
            o_amountField.text = (o_amountField.text ?? "") + "-"
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.addEditExpenseViewControllerWillDismiss(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "autoComplete" {
            autoCompleteViewController = segue.destinationController()
            autoCompleteViewController?.delegate = self
        }
    }
    
    @objc func titleChanged() {
        let items = AutoCompleteHelper.getItems(for: o_titleField.text).prefix(5)
        autoCompleteViewController?.items = Array(items)
        o_autoCompleteContainer.isHidden = items.count == 0
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
    
    @IBAction func didTapPlus(_ sender: UIButton) {
        o_amountField.text = (o_amountField.text ?? "") + "+"
    }
    
    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        if let title = o_titleField.text, let amountStr = o_amountField.text {
            var amount: Double?
            let expression = Expression(amountStr)
            do {
                amount = try expression.evaluate()
            } catch {
                amount = nil
            }
            
            if let _ = amount {
                expense?.title = title
                expense?.amount = Float(amount!)
                expense?.date = o_datePicker.date
                
                if let parentRef = parentRef {
                    expense?.insert(into: parentRef)
                } else if let expense = expense {
                    expense.update()
                }
                
                AutoCompleteHelper.saveText(title)
                dismiss(animated: true, completion: nil)
            } else {
                let a = UIAlertController(title: "Amount is not a number", message: nil, preferredStyle: .alert)
                a.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                present(a, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func didTapOutsideAutocomplete(_ sender: UIButton) {
        o_autoCompleteContainer.isHidden = true
    }
    
    func autoCompleteViewController(_ autoCompleteViewController: AutoCompleteViewController, didSelectItem item: String) {
        o_titleField.text = item
        o_autoCompleteContainer.isHidden = true
    }
}
