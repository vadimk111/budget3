//
//  IncomeTableViewCell.swift
//  Budget
//
//  Created by Vadik on 30/05/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

protocol IncomeTableViewCellDelegate: class {
    func incomeTableViewCellDeselected(_ cell: IncomeTableViewCell)
}

class IncomeTableViewCell: UITableViewCell {

    @IBOutlet weak var o_title: UILabel!
    @IBOutlet weak var o_amount: UILabel!
    @IBOutlet weak var o_date: UILabel!
    
    weak var delegate: IncomeTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            self.backgroundColor = UIColor(red: 217 / 255, green: 217 / 255, blue: 217 / 255, alpha: 1)
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.backgroundColor = UIColor.clear
            })
            delegate?.incomeTableViewCellDeselected(self)
        }
    }
    
    func fill(with data: Income, mainColor: UIColor) {
        o_title.textColor = mainColor
        update(with: data)
    }

    func update(with data: Income) {
        o_title.text = data.title
        o_date.text = data.date?.toString()
        
        if let amount = data.amount {
            o_amount.text = amount.toString()
        }
    }
}
