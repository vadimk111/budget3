//
//  BalanceView.swift
//  Budget
//
//  Created by Vadim Kononov on 18/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

protocol BalanceViewDelegate: class {
    func balanceViewDidExpand(_ view: BalanceView)
    func balanceViewDidCollapse(_ view: BalanceView)
}

class BalanceView: CustomView {

    @IBOutlet weak var o_title: UILabel!
    @IBOutlet weak var o_progressBar: ProgressBar!
    @IBOutlet weak var o_amount: UILabel!
    @IBOutlet weak var o_amountLeft: UILabel!
    @IBOutlet weak var o_amountSpent: UILabel!
    @IBOutlet weak var o_barHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var o_expandButton: UIButton!
    @IBOutlet weak var o_expandLeadingConstraint: NSLayoutConstraint!
    
    @IBInspectable var titleSize: CGFloat = 16
    @IBInspectable var amountSize: CGFloat = 12
    @IBInspectable var progressBarSize: CGFloat = 4
    
    weak var delegate: BalanceViewDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        o_title.font = UIFont(name: o_title.font.fontName, size: titleSize)
        o_amount.font = UIFont(name: o_amount.font.fontName, size: amountSize)
        o_amountLeft.font = UIFont(name: o_amountLeft.font.fontName, size: amountSize)
        o_amountSpent.font = UIFont(name: o_amountSpent.font.fontName, size: amountSize)
        o_barHeightConstraint.constant = progressBarSize
    }
    
    @IBAction func didTapExpand(_ sender: UIButton) {
        setExpanded(o_expandButton.tag == 1)
        if o_expandButton.tag == 2 {
            delegate?.balanceViewDidExpand(self)
        } else {
            delegate?.balanceViewDidCollapse(self)
        }
    }
    
    func isExpanded() -> Bool {
        return o_expandButton.tag == 2
    }
    
    func setExpanded(_ isExpanded: Bool) {
        if isExpanded {
            o_expandButton.tag = 2
            o_expandButton.setImage(UIImage.init(named: "arrow_up"), for: .normal)
        } else {
            o_expandButton.tag = 1
            o_expandButton.setImage(UIImage.init(named: "arrow_down"), for: .normal)
        }
    }
    
    func populate(amount: Float, totalSpent: Float, title: String? = nil, titleColor: UIColor? = nil, showExpand: Bool = false, isExpanded: Bool = false) {
        
        if showExpand {
            o_expandLeadingConstraint.constant = 0
            o_expandButton.isHidden = false
            setExpanded(isExpanded)
        } else {
            o_expandLeadingConstraint.constant = -26
            o_expandButton.isHidden = true
        }
        
        if let title = title {
            o_title.text = title
        }
        if let titleColor = titleColor {
            o_title.textColor = titleColor
        }
        o_amountSpent.text = String(totalSpent)
        o_amount.text = " / \(amount)"
        o_amountLeft.text = "\(amount - totalSpent)"
        o_amountLeft.textColor = totalSpent > amount ? UIColor(red: 214 / 255, green: 74 / 255, blue: 74 / 255, alpha: 1) : UIColor(red: 82 / 255, green: 82 / 255, blue: 82 / 255, alpha: 1)
        
        if amount != 0 {
            o_progressBar.set(value: totalSpent / amount)
        } 
    }
}
