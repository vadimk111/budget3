//
//  NavBalanceView.swift
//  Budget
//
//  Created by Vadik on 29/09/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class NavBalanceView: CustomView {
    
    @IBOutlet weak var o_title: UILabel!
    @IBOutlet weak var o_progressBar: ProgressBar!
    @IBOutlet weak var o_amount: UILabel!
    @IBOutlet weak var o_amountLeft: UILabel!
    @IBOutlet weak var o_amountSpent: UILabel!
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 240, height: 36)
    }
    
    func populate(amount: Float, totalSpent: Float, title: String?) {
        if let title = title {
            o_title.text = title
        }
        
        o_amountSpent.text = totalSpent.toString()
        o_amount.text = "/ " + amount.toString()
        o_amountLeft.text = (amount - totalSpent).toString()
        o_amountLeft.textColor = totalSpent > amount ? UIColor(red: 214 / 255, green: 74 / 255, blue: 74 / 255, alpha: 1) : UIColor(red: 82 / 255, green: 82 / 255, blue: 82 / 255, alpha: 1)
        
        if amount != 0 {
            o_progressBar.set(value: totalSpent / amount)
        } else if totalSpent != 0 {
            o_progressBar.set(value: 2)
        } else {
            o_progressBar.set(value: 0)
        }
    }
}
