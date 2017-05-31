//
//  CategoriesHeaderView.swift
//  Budget
//
//  Created by Vadim Kononov on 18/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

protocol CategoriesHeaderViewDelegate: class {
    func categoriesHeaderViewDidGoNext(_ categoriesHeaderView: CategoriesHeaderView)
    func categoriesHeaderViewDidGoPrev(_ categoriesHeaderView: CategoriesHeaderView)
}

class CategoriesHeaderView: CustomView, DateChangerDelegate {

    @IBOutlet weak var o_balanceView: BalanceView!
    @IBOutlet weak var o_dateChanger: DateChanger!
    
    weak var delegate: CategoriesHeaderViewDelegate?
    
    override func loadXib() {
        super.loadXib()
        o_dateChanger.delegate = self
    }
    
    func fill(with data: [Category], date: Date) {
        o_dateChanger.date = date
        
        var amount: Float = 0.0
        var totalSpent: Float = 0.0
        
        for category in data {
            amount += category.calculatedAmount
            totalSpent += category.calculatedTotalSpent
        }
        
        o_balanceView.populate(amount: amount, totalSpent: totalSpent)
    }
    
    func updateIncome(with incomes: [Income]) {
        o_dateChanger.updateIncome(with: incomes)
    }
    
    func dateChangerDidGoNext(_ dateChanger: DateChanger) {
        delegate?.categoriesHeaderViewDidGoNext(self)
    }
    
    func dateChangerDidGoPrev(_ dateChanger: DateChanger) {
        delegate?.categoriesHeaderViewDidGoPrev(self)
    }
}
