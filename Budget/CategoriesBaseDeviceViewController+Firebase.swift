//
//  CategoriesBaseDeviceViewController+Firebase.swift
//  Budget
//
//  Created by Vadik on 31/05/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import Foundation
import FirebaseDatabase

extension CategoriesBaseDeviceViewController {
    func registerToUpdates() {
        incomesRef?.observe(.childAdded, with: { [unowned self] snapshot in
            let income = Income(snapshot: snapshot)
            if !self.incomes.contains(where: { $0.id == income.id } ) {
                self.incomes.append(income)
                self.o_categoriesHeaderView.updateIncome(with: self.incomes)
            }
        })
        
        incomesRef?.observe(.childChanged, with: { [unowned self] snapshot in
            let income = Income(snapshot: snapshot)
            if let index = self.incomes.index(where: { $0.id == income.id }) {
                self.incomes.remove(at: index)
                self.incomes.insert(income, at: index)
                self.o_categoriesHeaderView.updateIncome(with: self.incomes)
            }
            
        })
        
        incomesRef?.observe(.childRemoved, with: { [unowned self] snapshot in
            let income = Income(snapshot: snapshot)
            if let index = self.incomes.index(where: { $0.id == income.id }) {
                self.incomes.remove(at: index)
                self.o_categoriesHeaderView.updateIncome(with: self.incomes)
            }
        })
    }
    
    func unregisterFromUpdates() {
        incomesRef?.removeAllObservers()
    }

}
