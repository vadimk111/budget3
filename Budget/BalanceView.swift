//
//  BalanceView.swift
//  Budget
//
//  Created by Vadim Kononov on 18/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class BalanceView: CustomView {

    @IBOutlet weak var o_title: UILabel!
    @IBOutlet weak var o_progressBar: ProgressBar!
    @IBOutlet weak var o_amount: UILabel!
    @IBOutlet weak var o_amountLeft: UILabel!
    @IBOutlet weak var o_amountSpent: UILabel!
    @IBOutlet weak var o_barHeightConstraint: NSLayoutConstraint!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let viewHeight = frame.height
        o_amount.font = UIFont(name: o_amount.font.fontName, size: viewHeight / 3)
        o_amountLeft.font = UIFont(name: o_amountLeft.font.fontName, size: viewHeight / 3)
        o_amountSpent.font = UIFont(name: o_amountSpent.font.fontName, size: viewHeight / 3)
        o_barHeightConstraint.constant = viewHeight / 9
    }
    
    func populate(amount: Float, totalSpent: Float, title: String? = nil) {
        o_title.text = title
        o_amountSpent.text = String(totalSpent)
        o_amount.text = " / \(amount)"
        o_amountLeft.text = "\(amount - totalSpent)"
        o_amountLeft.textColor = totalSpent > amount ? UIColor(red: 214 / 255, green: 74 / 255, blue: 74 / 255, alpha: 1) : UIColor(red: 82 / 255, green: 82 / 255, blue: 82 / 255, alpha: 1)
        
        if amount != 0 {
            o_progressBar.set(value: totalSpent / amount)
        } 
    }
}
