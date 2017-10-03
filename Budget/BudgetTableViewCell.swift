//
//  BudgetTableViewCell.swift
//  Budget
//
//  Created by Vadik on 30/09/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class BudgetTableViewCell: UITableViewCell {

    @IBOutlet weak var o_label: UILabel!
    @IBOutlet weak var o_image: UIImageView!
    @IBOutlet weak var o_separator: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        o_image.isHidden = !selected
    }

}
