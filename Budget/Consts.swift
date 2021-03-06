//
//  Consts.swift
//  Budget
//
//  Created by Vadim Kononov on 14/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

let colors: [UIColor] = [UIColor(red: 103 / 255, green: 171 / 255, blue: 87 / 255, alpha: 1),
                         UIColor(red: 252 / 255, green: 208 / 255, blue: 13 / 255, alpha: 1),
                         UIColor(red: 167 / 255, green: 117 / 255, blue: 242 / 255, alpha: 1),
                         UIColor(red: 89 / 255, green: 186 / 255, blue: 243 / 255, alpha: 1),
                         UIColor(red: 66 / 255, green: 66 / 255, blue: 66 / 255, alpha: 1),
                         UIColor(red: 255 / 255, green: 124 / 255, blue: 16 / 255, alpha: 1)]

let months: [String] = ["January", "February", "March", "April", "May", "June",
                        "July", "August", "September", "October", "November", "December"]

let datePickerControllerWillAppearNotification = Notification.Name(rawValue: "datePickerControllerWillAppearNotification")
let datePickerControllerDidDisappearNotification = Notification.Name(rawValue: "datePickerControllerDidDisappearNotification")

let recordingColor =  UIColor(red: 214 / 255, green: 74 / 255, blue: 74 / 255, alpha: 1)
