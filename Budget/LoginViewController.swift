//
//  LoginViewController.swift
//  Budget
//
//  Created by Vadim Kononov on 05/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FBSDKLoginKit

protocol LoginViewControllerDelegate: class {
    func loginViewControllerCreate(_ loginViewController: LoginViewController)
    func loginViewControllerSignIn(_ loginViewController: LoginViewController)
    func loginViewControllerForgot(_ loginViewController: LoginViewController)
    func loginViewControllerSkip(_ loginViewController: LoginViewController)
}

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var o_email: UITextField!
    @IBOutlet weak var o_password: UITextField!
    @IBOutlet weak var o_fbLoginButton: FBLoginButton!
    @IBOutlet weak var o_sigInButton: UIButton!
    @IBOutlet weak var o_resetPasswordButton: UIButton!
    @IBOutlet weak var o_skipButton: UIButton!
    @IBOutlet weak var o_signInTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var o_resetTopConstraint: NSLayoutConstraint!
    
    weak var delegate: LoginViewControllerDelegate?
    weak var facebookLoginDelegate: LoginButtonDelegate?
    
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
        
        //o_fbLoginButton.readPermissions = facebookReadPermissions
        o_fbLoginButton.delegate = facebookLoginDelegate
        
        if let _ = APP.user {
            o_sigInButton.isHidden = true
            o_signInTopConstraint.constant = -o_sigInButton.frame.height
            
            o_resetPasswordButton.isHidden = true
            o_resetTopConstraint.constant = -o_resetPasswordButton.frame.height
            
            o_skipButton.setTitle("Continue as Anonymous", for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.isNavigationBarHidden = true
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
            let a = UIAlertController(title: "Error", message: "Please, fill up the email field", preferredStyle: UIAlertController.Style.alert)
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
        self.delegate?.loginViewControllerSkip(self)
    }
}
