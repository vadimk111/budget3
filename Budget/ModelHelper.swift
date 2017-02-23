//
//  GenericHelper.swift
//  Budget
//
//  Created by Vadim Kononov on 06/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import Foundation

class ModelHelper {
    static func budgetId(for date: Date) -> String? {
        if let uid = APP.user?.uid {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            
            return uid + String(year) + String(month)
        }
        return nil
    }
    
}
