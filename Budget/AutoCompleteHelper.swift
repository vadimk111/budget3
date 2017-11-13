//
//  AutoCompleteHelper.swift
//  Budget
//
//  Created by Vadik on 13/11/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import Foundation

class AutoCompleteHelper {
    static func getItems(for text: String?) -> [String] {
        if let text = text, text.count > 0, let key = getKey(), let arr = UserDefaults.standard.array(forKey: key) as? [String] {
            return arr.filter({ $0.starts(with: text) })
        }
        return []
    }
    
    static func saveText(_ text: String) {
        if let key = getKey() {
            if let arr = UserDefaults.standard.array(forKey: key) as? [String] {
                if arr.filter({ $0 == text }).count == 0 {
                    var newArr = Array(arr)
                    newArr.insert(text, at: 0)
                    UserDefaults.standard.set(Array(newArr.prefix(50)), forKey: key)
                    UserDefaults.standard.synchronize()
                }
            } else {
                UserDefaults.standard.set([text], forKey: key)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    fileprivate static func getKey() -> String? {
        if let userId = APP.user?.uid {
            return "autocomplete-\(userId)"
        }
        return nil
    }
}
