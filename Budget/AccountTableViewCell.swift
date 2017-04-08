//
//  AccountTableViewCell.swift
//  Budget
//
//  Created by Vadik on 03/04/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

protocol AccountTableViewCellDelegate: class {
    func accountTableViewCell(_ accountTableViewCell: AccountTableViewCell, shouldDisplayViewController viewController: UIViewController)
    func accountTableViewCell(_ accountTableViewCell: AccountTableViewCell, shouldDisplayAlert alert: UIAlertController)
    func accountTableViewCell(_ accountTableViewCell: AccountTableViewCell, shouldDismiss viewController: UIViewController)
}

class AccountTableViewCell: UITableViewCell, AuthenticationDelegate {

    var authentication: Authentication?
    weak var delegate: AccountTableViewCellDelegate?
    
    @IBOutlet weak var o_logoutButton: UIButton!
    @IBOutlet weak var o_loginButton: UIButton!
    @IBOutlet weak var o_label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func build() {
        if let user = APP.user {
            o_label.text = user.email
            o_logoutButton.isHidden = false
            o_loginButton.isHidden = true
        } else {
            o_label.text = "Anonymous"
            o_loginButton.isHidden = false
            o_logoutButton.isHidden = true
        }
    }
    
    @IBAction func didTapLogin(_ sender: UIButton) {
        authentication = Authentication()
        authentication?.delegate = self
        authentication?.manualSignIn()
    }
    
    @IBAction func didTapLogout(_ sender: UIButton) {
        authentication = Authentication()
        authentication?.delegate = self
        authentication?.signOut()
        authentication?.manualSignIn()
    }

    //MARK - AuthenticationDelegate
    func authentication(_ authentication: Authentication, shouldDisplay viewController: UIViewController) {
        delegate?.accountTableViewCell(self, shouldDisplayViewController: viewController)
    }
    
    func authentication(_ authentication: Authentication, shouldDisplay alert: UIAlertController) {
        delegate?.accountTableViewCell(self, shouldDisplayAlert: alert)
    }
    
    func authentication(_ authentication: Authentication, shouldDismiss viewController: UIViewController) {
        delegate?.accountTableViewCell(self, shouldDismiss: viewController)
    }

}