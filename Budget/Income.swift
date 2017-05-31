//
//  Income.swift
//  Budget
//
//  Created by Vadik on 30/05/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import Foundation

class Income : MoneyFlow {
    func makeCopy() -> Income {
        let copy = Income()
        copy.id = id
        copy.title = title
        copy.amount = amount
        copy.date = date
        return copy
    }

}
