//
//  ScheduledReminderTableViewCell.swift
//  Budget
//
//  Created by Vadik on 03/04/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class ScheduledReminderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var o_label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populate(with data: ReminderData) {
        o_label.text = data.date.toString(showTime: true) + (data.repeatType != .none ? ", " + data.repeatType.toString() : "")
    }

}
