//
//  AnonymousTableViewCell.swift
//  Budget
//
//  Created by VadimKo on 26/12/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class AnonymousTableViewCell: UITableViewCell {

    @IBAction func didTapSignUp(_ sender: UIButton) {
        Authentication.shared.showSignInView()
    }
}
