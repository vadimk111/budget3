//
//  LoginViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 05/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate: class {
    func loginViewControllerCreate(_ loginViewController: LoginViewController)
    func loginViewControllerSignIn(_ loginViewController: LoginViewController)
    func loginViewControllerForgot(_ loginViewController: LoginViewController)
    func loginViewControllerSkip(_ loginViewController: LoginViewController)
}

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var o_email: UITextField!
    @IBOutlet weak var o_password: UITextField!
    
    weak var delegate: LoginViewControllerDelegate?
    
    var email: String {
        get {
            return o_email.text!
        }
    }
    
    var password: String {
        get {
            return o_password.text!
        }
    }
    
    init(delegate: LoginViewControllerDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("deinit login")
    }
    
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
            delegate?.loginViewControllerForgot(self)
        }
    }
    
    @IBAction func didTapCreate(_ sender: UIButton) {
        delegate?.loginViewControllerCreate(self)
    }
    
    @IBAction func didTapSignIn(_ sender: UIButton) {
        delegate?.loginViewControllerSignIn(self)
    }
    
    @IBAction func didTapSkip(_ sender: UIButton) {
        let a = UIAlertController(title: "Benefits of Registration", message: "Registered users able to sync their data between devices and restore the data from the backup\nTransition from anonymous mode to registered will not copy your data", preferredStyle: UIAlertControllerStyle.alert)
        a.addAction(UIAlertAction(title: "Back to Login", style: .default) { action -> Void in
        })
        a.addAction(UIAlertAction(title: "Skip", style: .destructive) { action -> Void in
            self.delegate?.loginViewControllerSkip(self)
        })
        present(a, animated: true, completion: nil)
    }
}
