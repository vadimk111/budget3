//
//  NotiicationsTableViewCell.swift
//  Budget
//
//  Created by Vadik on 03/04/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

protocol RemindersTableViewCellDelegate: class {
    func remindersTableViewCell(_ remindersTableViewCell: RemindersTableViewCell, didRequest showReminders: Bool)
}

class RemindersTableViewCell: UITableViewCell {

    weak var delegate: RemindersTableViewCellDelegate?
    
    @IBOutlet weak var o_switch: UISwitch!
    @IBOutlet weak var o_bottomView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func didTapEnableNotifications(_ sender: UISwitch) {
        delegate?.remindersTableViewCell(self, didRequest: sender.isOn)
    }
}
