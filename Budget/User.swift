//
//  User.swift
//  Budget
//
//  Created by Vadik on 27/09/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import Foundation
import Firebase

class User: NSObject {
    var firUser: FIRUser
    var sharing: Sharing?
    
    init(firUser: FIRUser) {
        self.firUser = firUser
    }
    
    func loadSharing(completion: @escaping () -> Void) {
        if let ref = ModelHelper.sharingReference() {
            ref.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
                if !(snapshot.value is NSNull) {
                    self?.sharing = Sharing(snapshot: snapshot)
                }
                completion()
            })
        }
    }
}
