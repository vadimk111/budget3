//
//  Category.swift
//  Budget
//
//  Created by Vadim Kononov on 04/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Category: ModelBaseObject {
    
    private let titleKey = "title"
    private let amountKey = "amount"
    private let parentKey = "parent"
    private let expensesKey = "expenses"
    private let orderKey = "order"
    
    var id: String?
    var title: String?
    var parent: String?
    var amount: Float?
    var order: Float = 0.0
    var expenses: [Expense]?
    
    var subCategories: [Category]?
    
    var calculatedAmount: Float {
        var m_amount: Float = 0.0
        
        guard (subCategories != nil) else {
            if let amount = amount {
                return amount
            }
            return m_amount
        }
        for item in subCategories! {
            if let subAmount = item.amount {
                m_amount += subAmount
            }
        }
        return m_amount
    }
    
    var calculatedTotalSpent: Float {
        var totalSpent: Float = 0.0
        
        if let expenses = expenses {
            for item in expenses {
                if let amount = item.amount {
                    totalSpent += amount
                }
            }
        }
        
        guard (subCategories != nil) else {
            return totalSpent
        }
        
        for item in subCategories! {
            totalSpent += item.calculatedTotalSpent
        }
        
        return totalSpent
    }
    
    override init() {
        super.init()
    }
    
    override init(snapshot: FIRDataSnapshot) {
        super.init(snapshot: snapshot)
        
        id = snapshot.key
        
        let snapshotValue = snapshot.value as! [String : AnyObject]
        title = snapshotValue[titleKey] as? String
        amount = snapshotValue[amountKey] as? Float
        parent = snapshotValue[parentKey] as? String
        order = snapshotValue[orderKey] as! Float
        
        for child in snapshot.children {
            let childSnapshot = child as! FIRDataSnapshot
            if childSnapshot.key == expensesKey {
                expenses = []
                for child in childSnapshot.children {
                    expenses?.append(Expense(snapshot: child as! FIRDataSnapshot))
                }
            }
        }
    }
    
    func makeCopy() -> Category {
        let copy = Category()
        copy.id = id
        copy.title = title
        copy.amount = amount
        copy.order = order
        copy.parent = parent
        copy.expenses = expenses
        return copy
    }
    
    override func toValues() -> [AnyHashable : Any] {
        var result = [AnyHashable : Any]()
        
        if let _ = title {
            result[titleKey] = title!
        }
        if let _ = amount {
            result[amountKey] = amount!
        }
        if let _ = parent {
            result[parentKey] = parent!
        }
        result[orderKey] = order
        
        var expensesObj = [String : [AnyHashable : Any]]()
        if let expenses = expenses {
            for expense in expenses {
                if let id = expense.id {
                    expensesObj[id] = expense.toValues()
                }
            }
            if expensesObj.keys.count > 0 {
                result[expensesKey] = expensesObj
            }
        }
        
        return result
    }
    

    override func delete() {
        super.delete()
        
        if let subCategories = subCategories {
            for item in subCategories {
                item.delete()
            }
        }
    }
}
