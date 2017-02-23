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
}

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var o_balanceView: BalanceView!
    @IBOutlet weak var o_title: UILabel!
    @IBOutlet weak var o_expandLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var o_expandButton: UIButton!
    @IBOutlet weak var o_balanceLeadingConstraint: NSLayoutConstraint!
    
    weak var delegate: CategoryTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
   
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func populate(with data: Category, isExpanded: Bool, mainColor: UIColor) {
        o_title.text = data.title
        o_title.textColor = mainColor
        
        if let _ = data.subCategories {
            o_expandLeadingConstraint.constant = 0
            o_balanceLeadingConstraint.constant = 7
            o_expandButton.isHidden = false
            setExpanded(isExpanded)
        } else {
            if let _ = data.parent {
                o_expandLeadingConstraint.constant = 16
                o_balanceLeadingConstraint.constant = 52
            } else {
                o_expandLeadingConstraint.constant = -29
                o_balanceLeadingConstraint.constant = 7
            }
            o_expandButton.isHidden = true
        }
       
        o_balanceView.populate(amount: data.calculatedAmount, totalSpent: data.calculatedTotalSpent)
    }
    
    @IBAction func didTapExpand(_ sender: UIButton) {
        setExpanded(o_expandButton.tag == 1)
        if o_expandButton.tag == 2 {
            delegate?.categoryTableViewCellDidExpand(self)
        } else {
            delegate?.categoryTableViewCellDidCollapse(self)
        }
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
    
    func isExpanded() -> Bool {
        return o_expandButton.tag == 2
    }
}
