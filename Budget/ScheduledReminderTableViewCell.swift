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
    @IBOutlet weak var o_separator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populate(with data: ReminderData, showSeparator: Bool) {
        switch data.repeatType {
        case .daily:
            o_label.text = "every day, \(data.date.toString(format: timeFormat))"
            break
        case .weekly:
            o_label.text = "every \(data.date.weekDay()), \(data.date.toString(format: timeFormat))"
            break
        case .monthly:
            o_label.text = "on day \(data.date.dayOfMonth()) of every month, \(data.date.toString(format: timeFormat))"
            break
        default:
            o_label.text = "on \(data.date.toString(format: dateTimeFormat))"
        }
        
        o_separator.isHidden = !showSeparator
    }

}
