//
//  Extensions.swift
//  Budget
//
//  Created by Vadim Kononov on 14/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import Foundation
import UIKit

let dateFormat = "dd-MM-yyyy"
let dateTimeFormat = "dd-MM-yyyy', 'HH:mm"
let timeFormat = "HH:mm"
let weekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

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
    func toString(format: String = dateFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
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
    
    func weekDay() -> String {
        return weekDays[Calendar.current.component(.weekday, from: self) - 1]
    }
    
    func dayOfMonth() -> Int {
        return Calendar.current.component(.day, from: self)
    }
}

extension Float {
    func toString() -> String {
        return String(format: "%0.2f", self)
    }
}

extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    public class func once(token: String, block: @escaping () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if _onceTracker.contains(token) {
            return
        }
        
        _onceTracker.append(token)
        block()
    }
}

extension UIStoryboardSegue {
    
    func destinationController<T>() -> T? {
        if let nav = destination as? UINavigationController {
            return nav.viewControllers.first as? T
        }
        return destination as? T
    }
}


