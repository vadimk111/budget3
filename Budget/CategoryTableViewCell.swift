//
//  CategoryTableViewCell.swift
//  Budget
//
//  Created by Vadim Kononov on 10/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

protocol CategoryTableViewCellDelegate: class {
    func categoryTableViewCellDidExpand(_ cell: CategoryTableViewCell)
    func categoryTableViewCellDidCollapse(_ cell: CategoryTableViewCell)
    func categoryTableViewCellDeselected(_ cell: CategoryTableViewCell)
}

class CategoryTableViewCell: UITableViewCell, BalanceViewDelegate {

    @IBOutlet weak var o_balanceView: BalanceView!
    @IBOutlet weak var o_balanceLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var o_balanceTrailingConstraint: NSLayoutConstraint!
    
    var trailingConstant: CGFloat?
    weak var delegate: CategoryTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        o_balanceView.delegate = self
        selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            self.backgroundColor = UIColor(red: 217 / 255, green: 217 / 255, blue: 217 / 255, alpha: 1)
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.backgroundColor = UIColor.clear
            })
            delegate?.categoryTableViewCellDeselected(self)
        }
    }

    func populate(with data: Category, isExpanded: Bool, mainColor: UIColor) {
        o_balanceLeadingConstraint.constant = data.parent != nil ? 32 : 0
        if let trailingConstant = trailingConstant {
            o_balanceTrailingConstraint.constant = trailingConstant
        }
        o_balanceView.populate(amount: data.calculatedAmount, totalSpent: data.calculatedTotalSpent, title: data.title, titleColor: mainColor, showExpand: data.subCategories != nil, isExpanded: isExpanded)
    }

    func isExpanded() -> Bool {
        return o_balanceView.isExpanded()
    }
    
    func balanceViewDidExpand(_ view: BalanceView) {
        delegate?.categoryTableViewCellDidExpand(self)
    }
    
    func balanceViewDidCollapse(_ view: BalanceView) {
        delegate?.categoryTableViewCellDidCollapse(self)
    }
}
