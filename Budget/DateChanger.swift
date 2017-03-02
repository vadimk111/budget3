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
}

class DateChanger: CustomView {

    @IBOutlet weak var o_title: UILabel!
    
    weak var delegate: DateChangerDelegate?
    
    var date: Date! {
        didSet {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            
            o_title.text = "\(months[month - 1]), \(year)"
        }
    }
    
    @IBAction func didTapNext(_ sender: UIButton) {
        delegate?.dateChangerDidGoNext(self)
    }
    
    @IBAction func didTapPrev(_ sender: UIButton) {
        delegate?.dateChangerDidGoPrev(self)
    }
}
