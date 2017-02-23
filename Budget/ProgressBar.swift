//
//  ProgressBar.swift
//  Budget
//
//  Created by Vadim Kononov on 10/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class ProgressBar: CustomView {

    @IBOutlet weak var o_redConstraint: NSLayoutConstraint!
    @IBOutlet weak var o_blueConstraint: NSLayoutConstraint!
    
    var value: Float = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        view.layer.cornerRadius = frame.height / 2
        setInternal()
    }
    
    func set(value: Float) {
        self.value = value
        setInternal()
    }
    
    private func setInternal() {
        if value == 0 {
            o_redConstraint.constant = 0
            o_blueConstraint.constant = 0
        } else if value > 1 {
            o_blueConstraint.constant = frame.width
            o_redConstraint.constant = frame.width * CGFloat(1 - min(2, value))
        } else {
            o_blueConstraint.constant = frame.width * CGFloat(value)
            o_redConstraint.constant = 0
        }

    }
}
