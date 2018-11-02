//
//  QuickAddExpense.swift
//  Budget
//
//  Created by Vadim Ko on 30/10/2018.
//  Copyright © 2018 Vadim Kononov. All rights reserved.
//

import UIKit

protocol QuickAddExpenseDelegate: class {
    func quickAddExpense(quickAddExpense: QuickAddExpense, didFinishWith data: Float)
}

class QuickAddExpense: UIView {
    weak var delegate: QuickAddExpenseDelegate?
    var category: Category!
    @IBOutlet weak var o_amountField: UITextField!
    
    static func loadFromXib() -> QuickAddExpense {
        let view = Bundle.main.loadNibNamed("QuickAddExpense", owner: self, options: nil)?[0] as! QuickAddExpense
        view.layer.cornerRadius = 5
        return view
    }
    
    @IBAction func didTapSave(_ sender: UIButton) {
        if /*let title = o_titleField.text, */let amountStr = o_amountField.text {
            if let amount = Float(amountStr) {
                delegate?.quickAddExpense(quickAddExpense: self, didFinishWith: amount)
            }
        }
    }
}
