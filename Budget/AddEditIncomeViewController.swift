//
//  AddEditIncomeViewController.swift
//  Budget
//
//  Created by Vadik on 30/05/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol AddEditIncomeViewControllerDelegate {
    func addEditIncomeViewControllerWillDismiss(_ addEditIncomeViewController: AddEditIncomeViewController)
}

class AddEditIncomeViewController: UIViewController, AutoCompleteViewControllerDelegate {

    var listRef: DatabaseReference?
    var income: Income?
    var delegate: AddEditIncomeViewControllerDelegate?
    var autoCompleteViewController: AutoCompleteViewController?
    
    @IBOutlet weak var o_titleField: UITextField!
    @IBOutlet weak var o_amountField: UITextField!
    @IBOutlet weak var o_dateLabel: UILabel!
    @IBOutlet weak var o_datePicker: UIDatePicker!
    @IBOutlet weak var o_dateViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var o_autoCompleteContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        o_autoCompleteContainer.layer.borderWidth = 1
        o_autoCompleteContainer.layer.borderColor = UIColor(red: 224 / 255, green: 224 / 255, blue: 224 / 255, alpha: 1).cgColor
        
        if let _ = income {
            title = "Edit Income"
        } else {
            income = Income()
            income?.date = Date()
            title = "Add Income"
        }
        
        o_titleField.addTarget(self, action: #selector(titleChanged), for: .editingChanged)
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
        
        if o_titleField.text?.count == 0 {
            o_titleField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.addEditIncomeViewControllerWillDismiss(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "autoComplete" {
            autoCompleteViewController = segue.destinationController()
            autoCompleteViewController?.delegate = self
        }
    }
    
    @objc func titleChanged() {
        let items = AutoCompleteHelper.getItems(for: o_titleField.text).prefix(3)
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
            AutoCompleteHelper.saveText(title)
            dismiss(animated: true, completion: nil)
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
