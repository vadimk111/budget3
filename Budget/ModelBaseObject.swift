//
//  ModelBaseObject.swift
//  Budget
//
//  Created by Vadim Kononov on 10/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import Foundation
import FirebaseDatabase

class ModelBaseObject : NSObject {
    
    private var ref: FIRDatabaseReference?
    
    override init() {
        
    }
    
    init(snapshot: FIRDataSnapshot) {
        super.init()
        ref = snapshot.ref
    }
    
    func toValues() -> [AnyHashable : Any] {
        return [:]
    }
    
    func delete() {
        ref?.removeValue()
    }
    
    @discardableResult
    func insert(into parent: FIRDatabaseReference) -> String {
        let child = parent.childByAutoId()
        child.setValue(toValues())
        return child.key
    }
    
    func update() {
        ref?.updateChildValues(toValues())
    }

    func removeChild(path: String) {
        ref?.child(path).removeValue()
    }
    
    func getDatabaseReference() -> FIRDatabaseReference? {
        return ref
    }
}
