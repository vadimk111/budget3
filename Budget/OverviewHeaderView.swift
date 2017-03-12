//
//  OverviewHeaderView.swift
//  Budget
//
//  Created by Vadim Kononov on 11/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class OverviewHeaderView: CustomView {

    @IBOutlet weak var o_spent: UILabel!
    @IBOutlet weak var o_date: UILabel!
    
    func fill(with date: Date, expenses: [Expense]) {
        o_date.text = date.toString()
        
        var amount: Float = 0
        for item in expenses {
            if let _ = item.amount {
                amount += item.amount!
            }
        }
        o_spent.text = String(amount)
    }
}
