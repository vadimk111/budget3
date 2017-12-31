//
//  AccountTableViewCell.swift
//  Budget
//
//  Created by Vadik on 03/04/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {
 
    @IBOutlet weak var o_label: UILabel!
    @IBOutlet weak var o_facebookImage: UIImageView! {
        didSet {
            o_facebookImage.layer.cornerRadius = o_facebookImage.frame.width / 2
        }
    }

    @IBOutlet weak var o_imageLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func build() {
        if APP.user?.isAnonymous == false {
            o_label.text = ""
            if Authentication.isOnlyFacebookAccountRegistered() {
                FacebookHelper.loadUserData(onLabel: o_label, andImage: o_facebookImage)
                o_imageLeadingConstraint.constant = 20
                o_facebookImage.isHidden = false
            } else {
                o_label.text = APP.user?.email
                o_imageLeadingConstraint.constant = -24
                o_facebookImage.isHidden = true
            }
        } else {
            o_label.text = "Anonymous"
            o_imageLeadingConstraint.constant = -24
            o_facebookImage.isHidden = true
        }
    }
    
    @IBAction func didTapLogout(_ sender: UIButton) {
        Authentication.shared.signOut()
    }
}
