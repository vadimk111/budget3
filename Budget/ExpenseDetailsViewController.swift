//
//  ExpenseDetailsViewController.swift
//  Budget
//
//  Created by Vadik on 02/04/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class ExpenseDetailsViewController: UIViewController {

    @IBOutlet weak var o_title: UILabel!
    @IBOutlet weak var o_amount: UILabel!
    @IBOutlet weak var o_category: UILabel!
    @IBOutlet weak var o_date: UILabel!
    
    var expenseData: ExpenseWithCategoryData? {
        didSet {
            fill()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fill()
    }

    func fill() {
        if let expenseData = expenseData {
            view.isHidden = false

            o_title.text = expenseData.expense.title
            o_amount.text = expenseData.expense.amount?.toString()
            o_date.text = expenseData.expense.date?.toString()
            o_category.text = expenseData.categoryTitle
        } else {
            view.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editExpense" {
            let editVC: AddEditExpenseViewController? = segue.destinationController()
            editVC?.expense = expenseData?.expense
        }
    }
}
