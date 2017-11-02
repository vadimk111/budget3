//
//  DateChanger.swift
//  Budget
//
//  Created by Vadim Kononov on 02/03/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

protocol DateChangerDelegate: class {
    func dateChangerDidGoNext(_ dateChanger: DateChanger)
    func dateChangerDidGoPrev(_ dateChanger: DateChanger)
    func dateChanger(_ dateChanger: DateChanger, didCreateDatePicker datePicker: DatePickerView)
    func dateChanger(_ dateChanger: DateChanger, didChangeDate date: Date)
}

class DateChanger: CustomView, DatePickerViewDelegate {

    var dateText: String?
    var totalIncome: Float?
    var datePicker: DatePickerView?
    
    @IBOutlet weak var o_title: UILabel!
    
    weak var delegate: DateChangerDelegate?
    
    var date: Date! {
        didSet {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            
            dateText = "\(months[month - 1]), \(year)"
            updateTitle()
        }
    }
    
    func updateTitle() {
        if let dateText = dateText {
            
            let attributedTitle = NSMutableAttributedString()
            attributedTitle.append(NSAttributedString(string: dateText, attributes: [NSAttributedStringKey.font: UIFont.init(name: "HelveticaNeue", size: 16)!, NSAttributedStringKey.foregroundColor: UIColor.black]))
            
            if let total = totalIncome {
                attributedTitle.append(NSAttributedString(string: " • Income = \(total)", attributes: [NSAttributedStringKey.font: UIFont.init(name: "HelveticaNeue-Bold", size: 12)!, NSAttributedStringKey.foregroundColor: UIColor(red: 103 / 255, green: 171 / 255, blue: 87 / 255, alpha: 1)]))
            }
            o_title.attributedText = attributedTitle
        }
    }
    
    @IBAction func didTapLabel(_ sender: UITapGestureRecognizer) {
        datePicker = DatePickerView.loadFromXib()
        datePicker?.delegate = self
        datePicker?.initialDate = date
        delegate?.dateChanger(self, didCreateDatePicker: datePicker!)
    }
    
    func datePickerView(_ datePickerView: DatePickerView, didChange date: Date) {
        delegate?.dateChanger(self, didChangeDate: date)
    }
        
    @IBAction func didTapNext(_ sender: UIButton) {
        delegate?.dateChangerDidGoNext(self)
    }
    
    @IBAction func didTapPrev(_ sender: UIButton) {
        delegate?.dateChangerDidGoPrev(self)
    }
    
    func updateIncome(with incomes: [Income]) {
        var total: Float = 0.0
        for item in incomes {
            if let amount = item.amount {
                total += amount
            }
        }
        if total > 0 {
            totalIncome = total
        } else {
            totalIncome = nil
        }
        
        updateTitle()
    }
}
