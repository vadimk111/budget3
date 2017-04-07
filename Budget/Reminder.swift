//
//  Reminder.swift
//  Budget
//
//  Created by Vadik on 07/04/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import Foundation

enum RepeatType: Int {
    case none = 0
    case daily = 1
    case weekly = 2
    case monthly = 3
    
    func toString() -> String {
        switch self {
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        default:
            return "None"
        }
    }
}

class ReminderData: NSObject, NSCoding {
    var id: String?
    var date: Date
    var repeatType: RepeatType
    
    init(date: Date, repeatType: RepeatType) {
        self.date = date
        self.repeatType = repeatType
    }
    
    func makeCopy() -> ReminderData {
        let copy = ReminderData(date: self.date, repeatType: self.repeatType)
        copy.id = self.id
        return copy
    }
        
    required init(coder decoder: NSCoder) {
        self.id = decoder.decodeObject(forKey: "id") as? String ?? ""
        self.date = Date.init(timeIntervalSince1970: decoder.decodeDouble(forKey: "date"))
        self.repeatType = RepeatType(rawValue: decoder.decodeInteger(forKey: "repeatType"))!
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: "id")
        coder.encode(date.timeIntervalSince1970, forKey: "date")
        coder.encode(repeatType.rawValue, forKey: "repeatType")
    }
}
