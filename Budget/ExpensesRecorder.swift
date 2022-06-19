//
//  ExpensesRecorder.swift
//  Budget
//
//  Created by Vadim Ko on 03/11/2018.
//  Copyright © 2018 Vadim Kononov. All rights reserved.
//

import Foundation

let splittingKey = "splitting"

class ExpensesRecorder {
    static func startRecording() {
        UserDefaults.standard.set(0.0, forKey: splittingKey)
        UserDefaults.standard.synchronize()
    }
    
    static func stopRecording() {
        UserDefaults.standard.removeObject(forKey: splittingKey)
    }
    
    static func isRecording() -> Bool {
        return UserDefaults.standard.object(forKey: splittingKey) != nil
    }
    
    static func getTotalRecorded() -> Float {
        return UserDefaults.standard.float(forKey: splittingKey)
    }
    
    static func recordExpense(amount: Float) {
        if let _ = UserDefaults.standard.object(forKey: splittingKey) {
            let current = UserDefaults.standard.float(forKey: splittingKey)
            UserDefaults.standard.set(current + amount, forKey: splittingKey)
            UserDefaults.standard.synchronize()
        }
    }
}
