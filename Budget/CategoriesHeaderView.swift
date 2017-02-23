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

class CategoriesHeaderView: CustomView {

    @IBOutlet weak var o_title: UILabel!
    @IBOutlet weak var o_balanceView: BalanceView!
    
    weak var delegate: CategoriesHeaderViewDelegate?
    
    @IBAction func didTapNext(_ sender: UIButton) {
        delegate?.categoriesHeaderViewDidGoNext(self)
    }
    
    @IBAction func didTapPrev(_ sender: UIButton) {
        delegate?.categoriesHeaderViewDidGoPrev(self)
    }
    
    func fill(with data: [Category], date: Date) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        o_title.text = "\(months[month - 1]), \(year)"
        
        var amount: Float = 0.0
        var totalSpent: Float = 0.0
        
        for category in data {
            amount += category.calculatedAmount
            totalSpent += category.calculatedTotalSpent
        }
        
        o_balanceView.populate(amount: amount, totalSpent: totalSpent)
    }
}
