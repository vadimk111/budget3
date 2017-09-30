//
//  IncomesViewController.swift
//  Budget
//
//  Created by Vadik on 30/05/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol IncomesViewControllerDelegate: class {
    func incomesViewController(_ incomesViewController: IncomesViewController, didSelect income: Income)
    func incomesViewControllerRowDeselected(_ incomesViewController: IncomesViewController)
    func incomesViewController(_ incomesViewController: IncomesViewController, didUpdateRowWith income: Income)
    func incomesViewControllerChanged(_ incomesViewController: IncomesViewController)
}

class IncomesViewController: UITableViewController, IncomeTableViewCellDelegate {

    var date: Date = Date()
    var incomes: [Income] = [Income]()
    var listRef: DatabaseReference?
    var addHandler: UInt?
    var changeHandler: UInt?
    var removeHandler: UInt?
    
    weak var delegate: IncomesViewControllerDelegate?

    var tableSeparatorInset: UIEdgeInsets? {
        didSet {
            if let tableSeparatorInset = tableSeparatorInset {
                tableView.separatorInset = tableSeparatorInset
            }
        }
    }
    
    deinit {
        unregisterFromUpdates()
    }
    
    @IBAction func didPullToRefresh(_ sender: UIRefreshControl) {
        reload()
    }
    
    func reload() {
        unregisterFromUpdates()
        
        listRef = ModelHelper.incomeReference(for: date)
        if listRef != nil {
            listRef?.observeSingleEvent(of: .value, with: { snapshot in
                self.incomes = []
                for child in snapshot.children {
                    self.incomes.append(Income(snapshot: child as! DataSnapshot))
                }
                self.registerToUpdates()
                
                self.tableView.reloadData()
                self.tableView.refreshControl?.endRefreshing()
                self.delegate?.incomesViewControllerChanged(self)
            })
        } else {
            date = Date()
            incomes = []
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: false)
            }
            tableView.reloadData()
            self.delegate?.incomesViewControllerChanged(self)
        }
    }
    
    func goNextMonth() -> Date {
        let newDate = date.nextMonth()
        changeToDate(newDate)
        return newDate
    }
    
    func goPrevMonth() -> Date {
        let newDate = date.prevMonth()
        changeToDate(newDate)
        return newDate
    }
    
    func changeToDate(_ date: Date) {
        self.date = date
        reload()
    }
    
    func incomeTableViewCellDeselected(_ cell: IncomeTableViewCell) {
        delegate?.incomesViewControllerRowDeselected(self)
    }
}
