//
//  IncomesViewController+Firebase.swift
//  Budget
//
//  Created by Vadik on 30/05/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import Foundation
import FirebaseDatabase

extension IncomesViewController {
    func registerToUpdates() {
        listRef?.observe(.childAdded, with: { [unowned self] snapshot in
            let income = Income(snapshot: snapshot)
            if !self.incomes.contains(where: { $0.id == income.id } ) {
                self.incomes.append(income)
                self.tableView.insertRows(at: [IndexPath.init(row: self.tableView.numberOfRows(inSection: 0), section: 0)], with: .fade)
            }
        })
        
        listRef?.observe(.childChanged, with: { [unowned self] snapshot in
            let income = Income(snapshot: snapshot)
            if let index = self.incomes.index(where: { $0.id == income.id }) {
                self.incomes.remove(at: index)
                self.incomes.insert(income, at: index)
                if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? IncomeTableViewCell {
                    cell.update(with: income)
                    self.delegate?.incomesViewController(self, didUpdateRowWith: income)
                }
            }

        })
        
        listRef?.observe(.childRemoved, with: { [unowned self] snapshot in
            let income = Income(snapshot: snapshot)
            if let index = self.incomes.index(where: { $0.id == income.id }) {
                self.incomes.remove(at: index)
                self.tableView.deleteRows(at: [IndexPath.init(row: index, section: 0)], with: .fade)
            }
        })
    }
        
    func unregisterFromUpdates() {
        listRef?.removeAllObservers()
    }
}
