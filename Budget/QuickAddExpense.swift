//
//  QuickAddExpense.swift
//  Budget
//
//  Created by Vadim Ko on 30/10/2018.
//  Copyright © 2018 Vadim Kononov. All rights reserved.
//

import UIKit

class QuickAddExpense: UIView {

    @IBOutlet weak var o_amountField: UITextField!
    
    static func loadFromXib() -> QuickAddExpense {
        let view = Bundle.main.loadNibNamed("QuickAddExpense", owner: self, options: nil)?[0] as! QuickAddExpense
        view.layer.cornerRadius = 5
        return view
    }
}
