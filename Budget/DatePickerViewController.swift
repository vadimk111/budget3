//
//  DatePickerViewController.swift
//  Budget
//
//  Created by Vadik on 17/07/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

protocol DatePickerViewControllerDelegate: class {
    func datePickerViewController(_ datePickerViewController: DatePickerViewController, didChange date: Date)
    func datePickerViewControllerShouldDismiss(_ datePickerViewController: DatePickerViewController)
}

class DatePickerViewController: UIViewController {

    weak var delegate: DatePickerViewControllerDelegate?
    var initialDate: Date?
    var pickerBackgroundColor: UIColor?
    
    @IBOutlet weak var o_pickerContainer: UIView!
    @IBOutlet weak var o_buttonsContainer: UIView!
    @IBOutlet weak var o_datePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let initialDate = initialDate {
            o_datePicker.date = initialDate
        }
        if let pickerBackgroundColor = pickerBackgroundColor {
            o_buttonsContainer.backgroundColor = pickerBackgroundColor
            o_pickerContainer.backgroundColor = pickerBackgroundColor
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapOutside(_ sender: UITapGestureRecognizer) {
        delegate?.datePickerViewControllerShouldDismiss(self)
    }
    
    @IBAction func didTapToday(_ sender: UIButton) {
        delegate?.datePickerViewController(self, didChange: Date())
    }
    
    @IBAction func didTapDone(_ sender: UIButton) {
        delegate?.datePickerViewController(self, didChange: o_datePicker.date)
    }
}
