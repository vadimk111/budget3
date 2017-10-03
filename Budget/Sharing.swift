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
    private let titleKey = "title"
    
    var id: String?
    var dbId: String?
    var title: String?
    
    override init() {
        super.init()
    }
    
    override init(snapshot: DataSnapshot) {
        super.init(snapshot: snapshot)
        
        id = snapshot.key
        let snapshotValue = snapshot.value as! [String : AnyObject]
        dbId = snapshotValue[dbIdKey] as? String
        title = snapshotValue[titleKey] as? String
    }
    
    override func toValues() -> [AnyHashable : Any] {
        var result = [AnyHashable : Any]()
        
        if let _ = dbId {
            result[dbIdKey] = dbId!
        }
        if let _ = title {
            result[titleKey] = title!
        }

        return result
    }
}
