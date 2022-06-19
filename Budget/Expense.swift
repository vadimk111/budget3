//
//  Expense.swift
//  Budget
//
//  Created by Vadim Kononov on 10/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import Foundation

class Expense : MoneyFlow {
    func makeCopy() -> Expense {
        let copy = Expense()
        copy.id = id
        copy.title = title
        copy.amount = amount
        copy.date = date
        return copy
    }
}
