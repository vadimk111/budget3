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
    
    var isCompactWidth: Bool {
        get {
            return traitCollection.horizontalSizeClass == .compact
        }
    }
    
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
        createOverlay()
        
        let bottomConstraint = addViewToHierarchy(view, height: height)
        
        UIView.animate(withDuration: 0.4, animations: {
            bottomConstraint.constant = 0
            self.updateViewConstraints()
            self.view.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            NotificationCenter.default.post(Notification(name: viewAddedAtBottomNotification))
        })
    }
    
    func createOverlay() {
        let overlay = UIView()
        overlay.tag = 999
        overlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissViewAtBottom)))
        view.addSubview(overlay)
        
        overlay.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: overlay, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: overlay, attribute: .left, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: overlay, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: overlay, attribute: .right, multiplier: 1, constant: 0))
    }
    
    func addViewToHierarchy(_ viewToAdd: UIView, height: CGFloat) -> NSLayoutConstraint {
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
    
    func dismissViewAtBottom() {
        if let constraint = view.constraints.first(where: { $0.identifier == "viewBottom" }), let viewToDismiss = constraint.secondItem {
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
}
