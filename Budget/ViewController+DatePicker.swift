//
//  ViewController+DatePicker.swift
//  Budget
//
//  Created by Vadik on 17/07/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func presentDatePickerAsPopover(datePicker: DatePickerView, sourceView: UIView, sourceRect: CGRect) {
        datePicker.backgroundColor = UIColor.white
        datePicker.translatesAutoresizingMaskIntoConstraints = false

        let vc = UIViewController()
        vc.view.addSubview(datePicker)
        
        vc.view.addConstraint(NSLayoutConstraint(item: vc.view, attribute: .bottom, relatedBy: .equal, toItem: datePicker, attribute: .bottom, multiplier: 1, constant: 0))
        vc.view.addConstraint(NSLayoutConstraint(item: vc.view, attribute: .left, relatedBy: .equal, toItem: datePicker, attribute: .left, multiplier: 1, constant: 0))
        vc.view.addConstraint(NSLayoutConstraint(item: vc.view, attribute: .top, relatedBy: .equal, toItem: datePicker, attribute: .top, multiplier: 1, constant: 0))
        vc.view.addConstraint(NSLayoutConstraint(item: vc.view, attribute: .right, relatedBy: .equal, toItem: datePicker, attribute: .right, multiplier: 1, constant: 0))
     
        vc.preferredContentSize = CGSize(width: 320, height: 236)
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.permittedArrowDirections = .up
        vc.popoverPresentationController?.sourceView = sourceView
        vc.popoverPresentationController?.sourceRect = sourceRect
        
        present(vc, animated: true)
    }
    
    func presentDatePickerOverCurrentContext(datePicker: DatePickerView) {
        createOverlay()
        
        let bottomConstraint = addDatePicker(datePicker)
        
        NotificationCenter.default.post(Notification(name: datePickerControllerDidAppearNotification))
        UIView.animate(withDuration: 0.4, animations: {
            bottomConstraint.constant = 0
            self.updateViewConstraints()
            self.view.layoutIfNeeded()
        })
    }
    
    func createOverlay() {
        let overlay = UIView()
        overlay.tag = 999
        overlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeDatePicker)))
        view.addSubview(overlay)
        
        overlay.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: overlay, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: overlay, attribute: .left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: overlay, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: overlay, attribute: .right, multiplier: 1, constant: 0))
    }
    
    func addDatePicker(_ datePicker: DatePickerView) -> NSLayoutConstraint {
        datePicker.backgroundColor = UIColor(red: 242 / 255, green: 242 / 255, blue: 242 / 255, alpha: 1)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.addConstraint(NSLayoutConstraint(item: datePicker, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 236))
        
        view.addSubview(datePicker)
        
        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: datePicker, attribute: .bottom, multiplier: 1, constant: -datePicker.frame.height)
        bottomConstraint.identifier = "pickerBottom"
        view.addConstraint(bottomConstraint)
        
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: datePicker, attribute: .left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: datePicker, attribute: .right, multiplier: 1, constant: 0))
        
        updateViewConstraints()
        view.layoutIfNeeded()
        
        return bottomConstraint
    }
    
    func closeDatePicker() {
        if let constraint = view.constraints.first(where: { $0.identifier == "pickerBottom" }), let datePicker = constraint.secondItem {
            UIView.animate(withDuration: 0.4, animations: {
                constraint.constant = -datePicker.frame.height
                self.updateViewConstraints()
                self.view.layoutIfNeeded()
            }, completion: { (finished) in
                datePicker.removeFromSuperview()
                if let overlay = self.view.subviews.first(where: { $0.tag == 999 }) {
                    overlay.removeFromSuperview()
                }
                NotificationCenter.default.post(Notification(name: datePickerControllerDidDisappearNotification))
            })
        }
    }
}
