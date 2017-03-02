//
//  OverviewTableViewCell.swift
//  Budget
//
//  Created by Vadim Kononov on 02/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class OverviewTableViewCell: UITableViewCell {

    @IBOutlet weak var o_title: UILabel!
    @IBOutlet weak var o_date: UILabel!
    @IBOutlet weak var o_amount: UILabel!
    @IBOutlet weak var o_category: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func fill(with data: Expense, category: Category, mainColor: UIColor) {
        o_title.text = data.title
        o_title.textColor = mainColor
        
        o_category.text = category.title
        
        if let amount = data.amount {
            o_amount.text = String(amount)
        }
        if let date = data.date {
            o_date.text = date.toString()
        }
    }
}
