//
//  Extensions.swift
//  Budget
//
//  Created by Vadim Kononov on 14/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import Foundation

let dateFormat = "dd-MM-yyyy"

extension String {
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        if let res = dateFormatter.date(from: self) {
            return res
        }
        return Date()
    }
}

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
    
    func nextMonth() -> Date {
        return changeDate(forward: true)
    }
    
    func prevMonth() -> Date {
        return changeDate(forward: false)
    }
    
    private func changeDate(forward: Bool) -> Date {
        let calendar = Calendar.current
        var year = calendar.component(.year, from: self)
        var month = calendar.component(.month, from: self)
        
        var comp = DateComponents()
        if forward {
            if month == 12 {
                year += 1
                month = 1
            } else {
                month += 1
            }
        } else {
            if month == 1 {
                year -= 1
                month = 12
            } else {
                month -= 1
            }
        }
        
        comp.day = 1
        comp.month = month
        comp.year = year
        
        return calendar.date(from: comp)!
    }
}

extension Float {
    func toString() -> String {
        return String(format: "%0.2f", self)
    }
}
