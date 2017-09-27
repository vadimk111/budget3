//
//  User.swift
//  Budget
//
//  Created by Vadik on 27/09/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Sharing: ModelBaseObject {
    
    private let dbIdKey = "dbId"
    
    var id: String?
    var dbId: String?
    
    override init() {
        super.init()
    }
    
    override init(snapshot: FIRDataSnapshot) {
        super.init(snapshot: snapshot)
        
        id = snapshot.key
        let snapshotValue = snapshot.value as! [String : AnyObject]
        dbId = snapshotValue[dbIdKey] as? String
    }
    
    @discardableResult
    override func insert(into parent: FIRDatabaseReference) -> String {
        parent.setValue(toValues())
        return parent.key
    }
    
    override func toValues() -> [AnyHashable : Any] {
        var result = [AnyHashable : Any]()
        
        if let _ = dbId {
            result[dbIdKey] = dbId!
        }

        return result
    }
}
