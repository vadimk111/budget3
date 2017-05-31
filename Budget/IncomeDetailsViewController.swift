//
//  IncomeDetailsViewController.swift
//  Budget
//
//  Created by Vadik on 30/05/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class IncomeDetailsViewController: UIViewController {

    @IBOutlet weak var o_title: UILabel!
    @IBOutlet weak var o_amount: UILabel!
    @IBOutlet weak var o_date: UILabel!
    
    var income: Income? {
        didSet {
            fill()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fill()
    }
    
    func fill() {
        if let income = income {
            view.isHidden = false
            
            o_title.text = income.title
            o_amount.text = income.amount?.toString()
            o_date.text = income.date?.toString()
        } else {
            view.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editIncome" {
            let editVC: AddEditIncomeViewController? = segue.destinationController()
            editVC?.income = income
            editVC?.title = "Edit Income"
        }
    }
}
