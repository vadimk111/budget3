//
//  LoginViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 05/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var o_email: UITextField!
    @IBOutlet weak var o_password: UITextField!
    
    var completion: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        o_email.delegate = self
        o_password.delegate = self
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == o_email {
            o_password.becomeFirstResponder()
        } else {
            o_password.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func didTapForgot(_ sender: UIButton) {
        FIRAuth.auth()?.sendPasswordReset(withEmail: o_email.text!) { (error) in
            if let error = error {
                self.loginFailed(with: error)
            } else {
                let a = UIAlertController(title: nil, message: "An email was sent to your mailbox from which you will be able to reset your password", preferredStyle: UIAlertControllerStyle.alert)
                a.addAction(UIAlertAction(title: "Ok", style: .default) { action -> Void in
                })
                self.present(a, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func didTapCreate(_ sender: UIButton) {
        FIRAuth.auth()?.createUser(withEmail: o_email.text!, password: o_password.text!) { (user, error) in
            if let error = error {
                self.loginFailed(with: error)
            } else if let user = user {
                self.loginSuccessed(with: user)
            }
        }
    }
    
    @IBAction func didTapSignIn(_ sender: UIButton) {
        FIRAuth.auth()?.signIn(withEmail: o_email.text!, password: o_password.text!) { (user, error) in
            if let error = error {
                self.loginFailed(with: error)
            } else if let user = user {
                self.loginSuccessed(with: user)
            }
        }
    }
    
    func loginFailed(with error: Error) {
        let a = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        a.addAction(UIAlertAction(title: "Ok", style: .default) { action -> Void in
        })
        present(a, animated: true, completion: nil)
    }
    
    func loginSuccessed(with user: FIRUser) {
        APP.user = user
        UserDefaults.standard.set(o_email.text!, forKey: "email")
        UserDefaults.standard.set(o_password.text!, forKey: "password")
        UserDefaults.standard.synchronize()
        dismiss(animated: true, completion: completion)
    }
}
