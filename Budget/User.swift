//
//  User.swift
//  Budget
//
//  Created by Vadik on 27/09/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import Foundation
import Firebase

class BudgetUser: NSObject {
    var firUser: User
     
    init(firUser: User) {
        self.firUser = firUser
    }
}
