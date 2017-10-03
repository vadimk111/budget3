//
//  ShareBudgetTableViewCell.swift
//  Budget
//
//  Created by Vadik on 30/09/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

protocol ShareBudgetTableViewCellDelegate: class {
    func shareBudgetTableViewCellDidTapShare(_ shareBudgetTableViewCell: ShareBudgetTableViewCell)
}

class ShareBudgetTableViewCell: UITableViewCell {

    weak var delegate: ShareBudgetTableViewCellDelegate?
    
    @IBAction func didTapShare(_ sender: UIButton) {
        delegate?.shareBudgetTableViewCellDidTapShare(self)
    }
}
