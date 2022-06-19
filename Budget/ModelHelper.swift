//
//  GenericHelper.swift
//  Budget
//
//  Created by Vadim Kononov on 06/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import Foundation
import FirebaseDatabase

let budgetsKey = "budgets"
let incomesKey = "incomes"
let sharingKey = "sharings"

class ModelHelper {
    fileprivate static func uniqueId(for date: Date) -> String? {
        var dbId: String? = nil
        
        if let sharingDB = UserDefaults.standard.string(forKey: APP.currentBudgetKey) {
            dbId = sharingDB
        } else {
            dbId = APP.user?.uid
        }
        if let dbId = dbId {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            
            return dbId + String(year) + String(month)
        }
        return nil
    }
    
    fileprivate static func databaseReference(for path: String, on date: Date) -> DatabaseReference? {
        if let uniqueId = uniqueId(for: date) {
            return Database.database().reference().child(path).child(uniqueId)
        }
        return nil
    }
    
    static func budgetReference(for date: Date) -> DatabaseReference? {
        return databaseReference(for: budgetsKey, on: date)
    }
    
    static func incomeReference(for date: Date) -> DatabaseReference? {
        return databaseReference(for: incomesKey, on: date)
    }
    
    static func sharingReference() -> DatabaseReference? {
        if let uid = APP.user?.uid {
            return Database.database().reference().child(sharingKey).child(uid)
        }
        return nil
    }
}
