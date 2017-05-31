//
//  MoneyFlow.swift
//  Budget
//
//  Created by Vadik on 30/05/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import Foundation
import FirebaseDatabase

class MoneyFlow : ModelBaseObject {
    
    private let titleKey = "title"
    private let amountKey = "amount"
    private let dateKey = "date"
    
    var title: String?
    var amount: Float?
    var date: Date?
    var id: String?
    
    override init() {
        super.init()
    }
    
    override init(snapshot: FIRDataSnapshot) {
        super.init(snapshot: snapshot)
        
        id = snapshot.key
        
        let snapshotValue = snapshot.value as! [String: AnyObject]
        title = snapshotValue[titleKey] as? String
        amount = snapshotValue[amountKey] as? Float
        date = (snapshotValue[dateKey] as? String)?.toDate()
    }
    
    override func toValues() -> [AnyHashable : Any] {
        var result = [AnyHashable : Any]()
        
        if let _ = title {
            result[titleKey] = title!
        }
        if let _ = amount {
            result[amountKey] = amount!
        }
        if let _ = date {
            result[dateKey] = date!.toString()
        }
        
        return result
    }
}
