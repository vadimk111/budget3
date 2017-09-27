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
        
        if let sharingDB = APP.user?.sharing?.dbId {
            dbId = sharingDB
        } else {
            dbId = APP.user?.firUser.uid
            if dbId == nil && APP.automaticAuthenticationCompleted {
                dbId = UserDefaults.standard.string(forKey: "email")
            }
        }
        if let dbId = dbId {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            
            return dbId + String(year) + String(month)
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
    
    static func sharingReference() -> FIRDatabaseReference? {
        if let uid = APP.user?.firUser.uid {
            return FIRDatabase.database().reference().child(sharingKey).child(uid)
        }
        return nil
    }
}
