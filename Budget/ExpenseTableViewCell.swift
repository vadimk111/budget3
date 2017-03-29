//
//  ExpenseTableViewCell.swift
//  Budget
//
//  Created by Vadim Kononov on 10/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {

    @IBOutlet weak var o_title: UILabel!
    @IBOutlet weak var o_date: UILabel!
    @IBOutlet weak var o_amount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            backgroundColor = UIColor(red: 217 / 255, green: 217 / 255, blue: 217 / 255, alpha: 1)
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.backgroundColor = UIColor.clear
            })
        }
    }

    func fill(with data: Expense, mainColor: UIColor) {
        o_title.text = data.title
        o_title.textColor = mainColor
        
        if let amount = data.amount {
            o_amount.text = amount.toString()
        }
        if let date = data.date {
            o_date.text = date.toString()
        }
    }
}
