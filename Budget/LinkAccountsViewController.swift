//
//  LinkAccountsViewController.swift
//  Budget
//
//  Created by Vadik on 11/07/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

protocol LinkAccountsViewControllerDelegate: class {
    func linkAccountsViewController(_ linkAccountsViewController: LinkAccountsViewController, linkWithPassword password: String?)
}

class LinkAccountsViewController: UIViewController {

    @IBOutlet weak var o_facebookImage: UIImageView!
    @IBOutlet weak var o_facebookLabel: UILabel!
    @IBOutlet weak var o_emailLabel: UILabel!
    
    var email: String?
    
    weak var delegate: LinkAccountsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        o_facebookImage.layer.cornerRadius = o_facebookImage.frame.width / 2
        
        navigationItem.title = "Link Accounts"
        
        o_emailLabel.text = email
        
        FacebookHelper.loadUserData(onLabel: o_facebookLabel, andImage: o_facebookImage)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }

    @IBAction func didTapLink(_ sender: UIButton) {
        let a = UIAlertController(title: "Budget Doctor", message: "Please, enter password for \(email ?? "")", preferredStyle: UIAlertControllerStyle.alert)
        a.addTextField(configurationHandler: { (textField) -> Void in
            textField.isSecureTextEntry = true
        })
        a.addAction(UIAlertAction(title: "Ok", style: .default) { action -> Void in
            let password = a.textFields?.first?.text
            self.delegate?.linkAccountsViewController(self, linkWithPassword: password)
        })
        a.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
        })
        present(a, animated: true, completion: nil)
    }
}
