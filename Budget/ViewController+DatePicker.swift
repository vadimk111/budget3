//
//  ViewController+DatePicker.swift
//  Budget
//
//  Created by Vadik on 17/07/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

extension UIViewController {
    func presentDatePickerOverCurrentContext(datePicker: DatePickerViewController) {
        providesPresentationContextTransitionStyle = true
        definesPresentationContext = true
        datePicker.pickerBackgroundColor = UIColor(red: 242 / 255, green: 242 / 255, blue: 242 / 255, alpha: 1)
        datePicker.modalPresentationStyle = .overCurrentContext
        datePicker.view.backgroundColor = UIColor.clear
        
        present(datePicker, animated: true) {
            NotificationCenter.default.post(Notification(name: datePickerControllerDidAppearNotification))
        }
    }
    
    func presentDatePickerAsPopover(datePicker: DatePickerViewController, sourceView: UIView, sourceRect: CGRect) {
        datePicker.pickerBackgroundColor = UIColor.white
        datePicker.preferredContentSize = CGSize(width: 320, height: 236)
        datePicker.modalPresentationStyle = .popover
        datePicker.popoverPresentationController?.permittedArrowDirections = .up
        datePicker.popoverPresentationController?.sourceView = sourceView
        datePicker.popoverPresentationController?.sourceRect = sourceRect
        present(datePicker, animated: true)
    }
    
    func closeDatePicker() {
        NotificationCenter.default.post(Notification(name: datePickerControllerDidDisappearNotification))
        dismiss(animated: true)
    }
}
