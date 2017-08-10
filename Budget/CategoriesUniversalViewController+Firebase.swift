//
//  CategoriesUniversalViewController+Firebase.swift
//  Budget
//
//  Created by Vadik on 27/07/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import Foundation
import FirebaseDatabase

extension CategoriesUniversalViewController {
    func registerToUpdates() {
        incomesAddHandler = incomesRef?.observe(.childAdded, with: { [unowned self] snapshot in
            let income = Income(snapshot: snapshot)
            if !self.incomes.contains(where: { $0.id == income.id } ) {
                self.incomes.append(income)
                self.o_categoriesHeaderView.updateIncome(with: self.incomes)
            }
        })
        
        incomesChangeHandler = incomesRef?.observe(.childChanged, with: { [unowned self] snapshot in
            let income = Income(snapshot: snapshot)
            if let index = self.incomes.index(where: { $0.id == income.id }) {
                self.incomes.remove(at: index)
                self.incomes.insert(income, at: index)
                self.o_categoriesHeaderView.updateIncome(with: self.incomes)
            }
            
        })
        
        incomesRemoveHandler = incomesRef?.observe(.childRemoved, with: { [unowned self] snapshot in
            let income = Income(snapshot: snapshot)
            if let index = self.incomes.index(where: { $0.id == income.id }) {
                self.incomes.remove(at: index)
                self.o_categoriesHeaderView.updateIncome(with: self.incomes)
            }
        })
    }
    
    func unregisterFromUpdates() {
        if let handler = incomesAddHandler {
            incomesRef?.removeObserver(withHandle: handler)
        }
        if let handler = incomesChangeHandler {
            incomesRef?.removeObserver(withHandle: handler)
        }
        if let handler = incomesRemoveHandler {
            incomesRef?.removeObserver(withHandle: handler)
        }
    }
    
}
