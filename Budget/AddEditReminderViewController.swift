//
//  AddEditReminderViewController.swift
//  Budget
//
//  Created by Vadik on 07/04/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

protocol AddEditReminderViewControllerDelegate: class {
    func addEditReminderViewController(_ addEditReminderViewController: AddEditReminderViewController, didSave data: ReminderData)
}

class AddEditReminderViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var o_datePicker: UIDatePicker!
    @IBOutlet weak var o_dateLabel: UILabel!
    @IBOutlet weak var o_dateViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var o_pickerView: UIPickerView!
    @IBOutlet weak var o_pickerViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var o_repeatLabel: UILabel!
    
    var reminderData: ReminderData = ReminderData(date: Date(), repeatType: .none)
    var repeatTypes: [RepeatType] = [.none, .daily, .weekly, .monthly]
    
    weak var delegate: AddEditReminderViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = reminderData.id {
            o_dateLabel.text = reminderData.date.toString(format: dateTimeFormat)
            o_dateLabel.textColor = UIColor.black
            o_datePicker.date = reminderData.date
            
            o_repeatLabel.text = reminderData.repeatType.toString()
            o_repeatLabel.textColor = UIColor.black
            if let index = repeatTypes.index(where: { (rType: RepeatType) -> Bool in rType == reminderData.repeatType }) {
                o_pickerView.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }
    
    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSave(_ sender: UIBarButtonItem) {
        delegate?.addEditReminderViewController(self, didSave: reminderData)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapDate(_ sender: UITapGestureRecognizer) {
        let newConstraintValue: CGFloat = o_dateViewConstraint.constant == 44 ? 260 : 44
        UIView.animate(withDuration: 0.3, animations: {
            self.o_dateViewConstraint.constant = newConstraintValue
            self.view.layoutIfNeeded()
        }, completion: { (Bool) -> Void in
            self.dateChanged(self.o_datePicker)
        })
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        reminderData.date = sender.date
        o_dateLabel.text = sender.date.toString(format: dateTimeFormat)
        o_dateLabel.textColor = UIColor.black
    }

    @IBAction func didTapRepeat(_ sender: UITapGestureRecognizer) {
        let newConstraintValue: CGFloat = o_pickerViewConstraint.constant == 44 ? 260 : 44
        UIView.animate(withDuration: 0.3, animations: {
            self.o_pickerViewConstraint.constant = newConstraintValue
            self.view.layoutIfNeeded()
        })
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return repeatTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        reminderData.repeatType = repeatTypes[row]

        if row > 0 {
            o_repeatLabel.text = repeatTypes[row].toString()
            o_repeatLabel.textColor = UIColor.black
        } else {
            o_repeatLabel.text = "Repeat"
            o_repeatLabel.textColor = UIColor(red: 199 / 255, green: 199 / 255, blue: 205 / 255, alpha: 1)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return repeatTypes[row].toString()
    }

}
