//
//  BudgetTableViewCell.swift
//  Budget
//
//  Created by Vadik on 30/09/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

protocol BudgetTableViewCellDelegate: class {
    func budgetTableViewCellDidTap(_ budgetTableViewCell: BudgetTableViewCell)
}

class BudgetTableViewCell: UITableViewCell {

    weak var delegate: BudgetTableViewCellDelegate?
    
    @IBOutlet weak var o_label: UILabel!
    @IBOutlet weak var o_image: UIImageView!
    @IBOutlet weak var o_separator: UIView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
    }

    @IBAction func didTapCell(_ sender: UIButton) {
        delegate?.budgetTableViewCellDidTap(self)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func populate(with data: Sharing, isSelected: Bool, hideSeparator: Bool) {
        o_label.text = data.title
        o_separator.isHidden = hideSeparator
        markSelected(isSelected)
    }
    
    func markSelected(_ isSelected: Bool) {
        o_image.isHidden = !isSelected
    }
}
