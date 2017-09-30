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
    
    private var ref: DatabaseReference?
    
    override init() {
        
    }
    
    init(snapshot: DataSnapshot) {
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
    func insert(into parent: DatabaseReference) -> String {
        let child = parent.childByAutoId()
        child.setValue(toValues())
        return child.key
    }
    
    func update() {
        ref?.setValue(toValues())
    }

    func removeChild(path: String) {
        ref?.child(path).removeValue()
    }
    
    func getDatabaseReference() -> DatabaseReference? {
        return ref
    }
    
    func setDatabaseReference(ref: DatabaseReference?) {
        self.ref = ref
    }
}
