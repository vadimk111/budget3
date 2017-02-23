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
}
