//
//  LinkAccountsViewController.swift
//  Budget
//
//  Created by Vadik on 11/07/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FBSDKLoginKit

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
        
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields" : "picture, name"]).start(completionHandler: { (connection, result, error) in
            if let result = result as? NSDictionary {
                self.o_facebookLabel.text = result["name"] as? String
                
                if let picture = result["picture"] as? NSDictionary,
                    let data = picture["data"] as? NSDictionary,
                    let urlStr = data["url"] as? String,
                    let url = URL.init(string: urlStr) {
                    do {
                        let data = try Data.init(contentsOf: url)
                        self.o_facebookImage.image = UIImage.init(data: data)
                    } catch {
                        
                    }
                }
            }
        })
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
