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

class ModelHelper {
    fileprivate static func uniqueId(for date: Date) -> String? {
        var uid = APP.user?.uid
        if uid == nil && APP.automaticAuthenticationCompleted {
            uid = UserDefaults.standard.string(forKey: "email")
        }
        
        if let uid = uid {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            
            return uid + String(year) + String(month)
        }
        return nil
    }
    
    fileprivate static func databaseReference(for path: String, on date: Date) -> FIRDatabaseReference? {
        if let uniqueId = uniqueId(for: date) {
            return FIRDatabase.database().reference().child(path).child(uniqueId)
        }
        return nil
    }
    
    static func budgetReference(for date: Date) -> FIRDatabaseReference? {
        return databaseReference(for: budgetsKey, on: date)
    }
    
    static func incomeReference(for date: Date) -> FIRDatabaseReference? {
        return databaseReference(for: incomesKey, on: date)
    }
}
