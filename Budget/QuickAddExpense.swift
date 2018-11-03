//
//  QuickAddExpense.swift
//  Budget
//
//  Created by Vadim Ko on 30/10/2018.
//  Copyright © 2018 Vadim Kononov. All rights reserved.
//

import UIKit

protocol QuickAddExpenseDelegate: class {
    func quickAddExpense(_ quickAddExpense: QuickAddExpense, didFinishWith title: String, andAmount amount: Float)
}

class QuickAddExpense: UIView {
    weak var delegate: QuickAddExpenseDelegate?
    var category: Category! {
        didSet {
            o_titleField.text = AutoCompleteHelper.getQuickTitleForCategory(category)
        }
    }
    @IBOutlet weak var o_amountField: UITextField!
    @IBOutlet weak var o_titleField: UITextField!
    
    static func loadFromXib() -> QuickAddExpense {
        let view = Bundle.main.loadNibNamed("QuickAddExpense", owner: self, options: nil)?[0] as! QuickAddExpense
        view.layer.cornerRadius = 5
        return view
    }
    
    @IBAction func didTapSave(_ sender: UIButton) {
        if let title = o_titleField.text, let amountStr = o_amountField.text {
            if let amount = Float(amountStr) {
                delegate?.quickAddExpense(self, didFinishWith: title, andAmount: amount)
                AutoCompleteHelper.saveQuickTitle(title, forCategory: category)
            }
        }
    }
}
