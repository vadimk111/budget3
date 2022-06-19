//
//  OverviewTableViewCell.swift
//  Budget
//
//  Created by Vadim Kononov on 02/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

protocol OverviewTableViewCellDelegate: class {
    func overviewTableViewCellDeselected(_ cell: OverviewTableViewCell)
}

class OverviewTableViewCell: UITableViewCell {

    @IBOutlet weak var o_title: UILabel!
    @IBOutlet weak var o_amount: UILabel!
    @IBOutlet weak var o_category: UILabel!
    
    weak var delegate: OverviewTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
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
            delegate?.overviewTableViewCellDeselected(self)
        }
    }
    
    func fill(with data: Expense, categoryTitle: String?, mainColor: UIColor) {
        o_title.text = data.title
        o_title.textColor = mainColor
        
        o_category.text = categoryTitle
        
        if let amount = data.amount {
            o_amount.text = amount.toString()
        }
    }
}
