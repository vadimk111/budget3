//
//  LoginViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 05/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseAuth

let anonymous = "-anonymous-"

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var o_email: UITextField!
    @IBOutlet weak var o_password: UITextField!
    
    var completion: (() -> Void)?
    var insideTheApp = false
    
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
        if o_email.text == "" {
            let a = UIAlertController(title: "Error", message: "Please, fill up the email field", preferredStyle: UIAlertControllerStyle.alert)
            a.addAction(UIAlertAction(title: "Ok", style: .default) { action -> Void in
            })
            present(a, animated: true, completion: nil)
        } else {
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
    
    @IBAction func didTapSkip(_ sender: UIButton) {
        if insideTheApp {
            dismiss(animated: true, completion: self.completion)
        } else {
            let a = UIAlertController(title: "Benefits of Registration", message: "Registered users able to sync their data between devices and restore the data from the backup\nTransition from anonymous mode to registered will not copy your data", preferredStyle: UIAlertControllerStyle.alert)
            a.addAction(UIAlertAction(title: "Back to Login", style: .default) { action -> Void in
            })
            a.addAction(UIAlertAction(title: "Skip", style: .destructive) { action -> Void in
                UserDefaults.standard.set(anonymous + UUID().uuidString, forKey: "email")
                UserDefaults.standard.set("-1", forKey: "password")
                UserDefaults.standard.synchronize()
                self.dismiss(animated: true, completion: self.completion)
            })
            present(a, animated: true, completion: nil)
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
