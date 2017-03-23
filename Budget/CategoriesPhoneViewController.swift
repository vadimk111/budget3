//
//  CategoriesPhoneViewController.swift
//  Budget
//
//  Created by Vadik on 23/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class CategoriesPhoneViewController: UIViewController, CategoriesViewControllerDelegate, CategoriesHeaderViewDelegate {

    @IBOutlet weak var o_headerView: CategoriesHeaderView!
    
    var categoriesViewController: CategoriesViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: signInStateChangedNotification, object: nil, queue: nil, using: { [unowned self] notification in
            self.reload()
        })
        
        o_headerView.delegate = self
        o_headerView.fill(with: [], date: Date())
        
        reload()
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
        }
    }
    
    func categoriesViewController(_ categoriesViewController: CategoriesViewController, didSelect category: Category) {
        
    }
    
    func categoriesViewControllerChanged(_ categoriesViewController: CategoriesViewController) {
        o_headerView?.fill(with: categoriesViewController.availableParents, date: categoriesViewController.date)
    }
}
