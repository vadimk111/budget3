//
//  DatePickerView.swift
//  Budget
//
//  Created by Vadik on 19/07/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

protocol DatePickerViewDelegate: class {
    func datePickerView(_ datePickerView: DatePickerView, didChange date: Date)
}

class DatePickerView: UIView {

    weak var delegate: DatePickerViewDelegate?
    
    var initialDate: Date? {
        didSet {
            if let initialDate = initialDate {
                o_datePicker.date = initialDate
            }
        }
    }
    
    static func loadFromXib() -> DatePickerView {
        return Bundle.main.loadNibNamed("DatePickerView", owner: self, options: nil)?[0] as! DatePickerView
    }
    
    @IBOutlet weak var o_datePicker: UIDatePicker!

    @IBAction func didTapToday(_ sender: UIButton) {
        delegate?.datePickerView(self, didChange: Date())
    }
    
    @IBAction func didTapDone(_ sender: UIButton) {
        delegate?.datePickerView(self, didChange: o_datePicker.date)
    }
}
