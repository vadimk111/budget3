//
//  ViewController+DatePicker.swift
//  Budget
//
//  Created by Vadik on 17/07/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

let viewAddedAtBottomNotification = Notification.Name(rawValue: "viewAddedAtBottomNotification")
let viewRemovedAtBottomNotification = Notification.Name(rawValue: "viewRemovedAtBottomNotification")

extension UIViewController {
    
    func presentViewAsPopover(_ view: UIView, viewSize: CGSize, sourceView: UIView, sourceRect: CGRect) {
        view.translatesAutoresizingMaskIntoConstraints = false

        let vc = UIViewController()
        vc.view.addSubview(view)
        
        vc.view.addConstraint(NSLayoutConstraint(item: vc.view, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
        vc.view.addConstraint(NSLayoutConstraint(item: vc.view, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0))
        vc.view.addConstraint(NSLayoutConstraint(item: vc.view, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
        vc.view.addConstraint(NSLayoutConstraint(item: vc.view, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0))
     
        vc.preferredContentSize = viewSize
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.permittedArrowDirections = .up
        vc.popoverPresentationController?.sourceView = sourceView
        vc.popoverPresentationController?.sourceRect = sourceRect
        
        present(vc, animated: true)
    }
    
    func presentViewAtBottom(_ view: UIView, height: CGFloat) {
        createOverlay(#selector(dismissViewAtBottom))
        
        let bottomConstraint = addBottomViewToHierarchy(view, height: height)
        
        UIView.animate(withDuration: 0.4, animations: {
            bottomConstraint.constant = 0
            self.updateViewConstraints()
            self.view.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            NotificationCenter.default.post(Notification(name: viewAddedAtBottomNotification))
        })
    }
    
    func presentViewAtCenter(_ view: UIView) {
        createOverlay(#selector(dismissViewAtCenter))
        
        view.alpha = 0
        addCenterViewToHierarchy(view)
        
        UIView.animate(withDuration: 0.4, animations: {
            view.alpha = 1
        })
    }
    
    func createOverlay(_ action: Selector?) {
        let overlay = UIView()
        overlay.tag = 999
        overlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        overlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
        view.addSubview(overlay)
        
        overlay.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: overlay, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: overlay, attribute: .left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: overlay, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: overlay, attribute: .right, multiplier: 1, constant: 0))
    }
    
    func addBottomViewToHierarchy(_ viewToAdd: UIView, height: CGFloat) -> NSLayoutConstraint {
        viewToAdd.translatesAutoresizingMaskIntoConstraints = false
        
        viewToAdd.addConstraint(NSLayoutConstraint(item: viewToAdd, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
        
        view.addSubview(viewToAdd)
        
        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: viewToAdd, attribute: .bottom, multiplier: 1, constant: -viewToAdd.frame.height)
        bottomConstraint.identifier = "viewBottom"
        view.addConstraint(bottomConstraint)
        
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: viewToAdd, attribute: .left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: viewToAdd, attribute: .right, multiplier: 1, constant: 0))
        
        updateViewConstraints()
        view.layoutIfNeeded()
        
        return bottomConstraint
    }
    
    func addCenterViewToHierarchy(_ viewToAdd: UIView) {
        viewToAdd.tag = 888
        viewToAdd.translatesAutoresizingMaskIntoConstraints = false
        
        viewToAdd.addConstraint(NSLayoutConstraint(item: viewToAdd, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewToAdd.frame.height))
        
        viewToAdd.addConstraint(NSLayoutConstraint(item: viewToAdd, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: viewToAdd.frame.width))
        
        view.addSubview(viewToAdd)
        
        view.addConstraint(NSLayoutConstraint(item: viewToAdd, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: viewToAdd, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: -40))
        
        updateViewConstraints()
        view.layoutIfNeeded()
    }
    
    @objc func dismissViewAtBottom() {
        if let constraint = view.constraints.first(where: { $0.identifier == "viewBottom" }), let viewToDismiss = constraint.secondItem as? UIView {
            UIView.animate(withDuration: 0.4, animations: {
                constraint.constant = -viewToDismiss.frame.height
                self.updateViewConstraints()
                self.view.layoutIfNeeded()
            }, completion: { (finished) in
                viewToDismiss.removeFromSuperview()
                if let overlay = self.view.subviews.first(where: { $0.tag == 999 }) {
                    overlay.removeFromSuperview()
                }
                NotificationCenter.default.post(Notification(name: viewRemovedAtBottomNotification))
            })
        }
    }
    
    @objc func dismissViewAtCenter() {
        if let viewToDismiss = view.subviews.first(where: { $0.tag == 888 }) {
            UIView.animate(withDuration: 0.4, animations: {
                viewToDismiss.alpha = 0
            }, completion: { (finished) in
                viewToDismiss.removeFromSuperview()
                if let overlay = self.view.subviews.first(where: { $0.tag == 999 }) {
                    overlay.removeFromSuperview()
                }
            })
        }
    }
    
    func getRecordingAlert(button: UIBarButtonItem) -> UIAlertController {
        let isRecording = ExpensesRecorder.isRecording()
        let message = isRecording ? "Stop split recording?" : "Start recording expenses for split?"
        
        let a = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        a.addAction(UIAlertAction(title: "Yes", style: .default) { (action) in
            if isRecording {
                UIPasteboard.general.string = "\(ExpensesRecorder.getTotalRecorded())"
                let message = "Total recorded of \(ExpensesRecorder.getTotalRecorded()) is copied to clipboard"
                let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Close", style: .default) { (action) in
                    ExpensesRecorder.stopRecording()
                    button.tintColor = nil
                })
                self.present(alert, animated: true)
            } else {
                ExpensesRecorder.startRecording()
                button.tintColor = recordingColor
            }
        })
        a.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        return a
    }
}
