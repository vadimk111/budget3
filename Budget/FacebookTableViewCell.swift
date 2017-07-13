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
    
    @IBOutlet weak var o_disconnectButton: UIButton!
    @IBOutlet weak var o_label: UILabel!
    @IBOutlet weak var o_facebookImage: UIImageView! {
        didSet {
            o_facebookImage.layer.cornerRadius = o_facebookImage.frame.width / 2
        }
    }
    @IBOutlet weak var o_connectedView: UIView!
    @IBOutlet weak var o_disconnectedView: UIView!
    
    var isConnected: Bool = false {
        didSet {
            o_connectedView.isHidden = !isConnected
            o_disconnectedView.isHidden = isConnected
            
            if isConnected {
                FacebookHelper.loadUserData(onLabel: o_label, andImage: o_facebookImage)
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didTapConnect(_ sender: UIButton) {
            delegate?.facebookTableViewCellDidTapConnect(self)
    }
    
    @IBAction func didTapDisconnect(_ sender: UIButton) {
        delegate?.facebookTableViewCellDidTapDisconnect(self)
    }
}
