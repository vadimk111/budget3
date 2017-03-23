//
//  CategoriesSplitViewController.swift
//  Budget
//
//  Created by Vadik on 15/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseAuth

class CategoriesSplitViewController: UIViewController, CategoriesHeaderViewDelegate, CategoriesViewControllerDelegate {

    @IBOutlet weak var o_categoriesHeaderView: CategoriesHeaderView!
    
    var categoriesViewController: CategoriesViewController?
    var expensesViewController: CategoryViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let email = UserDefaults.standard.string(forKey: "email"), let password = UserDefaults.standard.string(forKey: "password") {
            if email.contains(anonymous) {
                self.reload()
            } else {
                FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
                    if let _ = error {
                        let a = UIAlertController(title: "Error", message: error!.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                        a.addAction(UIAlertAction(title: "Ok", style: .default) { action -> Void in
                            self.present(LoginViewController(), animated: true, completion: nil)
                        })
                        self.present(a, animated: true, completion: nil)
                    } else if let user = user {
                        APP.user = user
                        self.reload()
                    }
                }
            }
        }
        
        o_categoriesHeaderView.delegate = self
        o_categoriesHeaderView.fill(with: [], date: Date())
    }

    func reload() {
        categoriesViewController?.reload()
    }
    

    func categoriesHeaderViewDidGoNext(_ categoriesHeaderView: CategoriesHeaderView) {
        
    }

    func categoriesHeaderViewDidGoPrev(_ categoriesHeaderView: CategoriesHeaderView) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categories" {
            categoriesViewController = segue.destination as? CategoriesViewController
            categoriesViewController?.delegate = self
        } else if segue.identifier == "expenses" {
            expensesViewController = segue.destination as? CategoryViewController
        }
    }
    
    func categoriesViewController(_ categoriesViewController: CategoriesViewController, didSelect category: Category) {
        expensesViewController?.reload(with: category)
    }
}
