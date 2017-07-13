//
//  FacebookTableViewCell.swift
//  Budget
//
//  Created by Vadik on 10/07/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

protocol FacebookTableViewCellDelegate: class {
    func facebookTableViewCellDidTapConnect(_ facebookTableViewCell: FacebookTableViewCell)
    func facebookTableViewCellDidTapDisconnect(_ facebookTableViewCell: FacebookTableViewCell)
}

class FacebookTableViewCell: UITableViewCell {

    weak var delegate: FacebookTableViewCellDelegate?
    
    @IBOutlet weak var o_button: UIButton!
    
    var isConnected: Bool = false {
        didSet {
            if isConnected {
                o_button.setTitle("Disconnect Facebook Account", for: .normal)
                o_button.tag = 1
            } else {
                o_button.setTitle("Connect Facebook Account", for: .normal)
                o_button.tag = 0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didTapButton(_ sender: UIButton) {
        if sender.tag == 0 {
            delegate?.facebookTableViewCellDidTapConnect(self)
        } else {
            delegate?.facebookTableViewCellDidTapDisconnect(self)
        }
    }
}
