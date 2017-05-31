//
//  IncomesPadViewController.swift
//  Budget
//
//  Created by Vadik on 31/05/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class IncomesPadViewController: IncomesBaseDeviceViewController {
    
    @IBOutlet weak var o_incomesContainer: UIView!
    
    var incomeDetailsViewController: IncomeDetailsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        o_incomesContainer.layer.shadowRadius = 2
        o_incomesContainer.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        o_incomesContainer.layer.shadowOpacity = 1
        o_incomesContainer.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        o_dateChanger.layer.shadowRadius = 2
        o_dateChanger.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        o_dateChanger.layer.shadowOpacity = 1
        o_dateChanger.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "incomes" {
            incomesViewController = segue.destination as? IncomesViewController
            incomesViewController?.delegate = self
            incomesViewController?.tableSeparatorInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        } else if segue.identifier == "incomeDetails" {
            incomeDetailsViewController = segue.destination as? IncomeDetailsViewController
        } else if segue.identifier == "addIncome" {
            prepareForAddIncome(from: segue)
        }
    }
    
    override func onDateChanged() {
        incomeDetailsViewController?.income = nil
    }
    
    //MARK - IncomesViewControllerDelegate
    override func incomesViewControllerRowDeselected(_ incomesViewController: IncomesViewController) {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (Timer) -> Void in
            if incomesViewController.tableView.indexPathForSelectedRow == nil {
                self.incomeDetailsViewController?.income = nil
            }
        })
    }
    
    override func incomesViewController(_ incomesViewController: IncomesViewController, didSelect income: Income) {
        incomeDetailsViewController?.income = income
    }
    
    override func incomesViewController(_ incomesViewController: IncomesViewController, didUpdateRowWith income: Income) {
        incomeDetailsViewController?.income = income
    }
}
