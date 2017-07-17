//
//  IncomesBaseDeviceViewController.swift
//  Budget
//
//  Created by Vadik on 31/05/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

class IncomesBaseDeviceViewController: UIViewController, DateChangerDelegate, IncomesViewControllerDelegate {
    
    var incomesViewController: IncomesViewController?
    var timer: Timer?
    
    @IBOutlet weak var o_dateChanger: DateChanger!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(IncomesBaseDeviceViewController.onSignInStateChanged), name: signInStateChangedNotification, object: nil)
        
        o_dateChanger.delegate = self
        o_dateChanger.date = Date()
        
        reload()
    }
    
    func prepareForAddIncome(from segue: UIStoryboardSegue) {
        if let incomesViewController = incomesViewController {
            let vc: AddEditIncomeViewController? = segue.destinationController()
            vc?.listRef = incomesViewController.listRef
        }
    }
    
    func prepareForEditIncome(from segue: UIStoryboardSegue, sender: Any?) {
        if let income = sender as? Income {
            let vc: AddEditIncomeViewController? = segue.destinationController()
            vc?.income = income
        }
    }
        
    func onSignInStateChanged() {
        reload()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func reload() {
        incomesViewController?.reload()
    }
    
    func onDateChanged() {
        
    }
    
    //MARK - DateChangerDelegate
    func dateChangerDidGoNext(_ dateChanger: DateChanger) {
        o_dateChanger.date = incomesViewController?.goNextMonth()
        onDateChanged()
    }
    
    func dateChangerDidGoPrev(_ dateChanger: DateChanger) {
        o_dateChanger.date = incomesViewController?.goPrevMonth()
        onDateChanged()
    }
    
    func dateChanger(_ dateChanger: DateChanger, didCreateDatePicker datePicker: DatePickerViewController) {
    }
    
    func dateChanger(_ dateChanger: DateChanger, shouldDismiss datePicker: DatePickerViewController) {
    }
    
    func dateChanger(_ dateChanger: DateChanger, didChangeDate date: Date) {
        incomesViewController?.changeToDate(date)
        o_dateChanger.date = date
        onDateChanged()
    }
    
    //MARK - IncomesViewControllerDelegate
    func incomesViewControllerRowDeselected(_ incomesViewController: IncomesViewController) {
        
    }
    
    func incomesViewController(_ incomesViewController: IncomesViewController, didSelect income: Income) {
        
    }

    func incomesViewController(_ incomesViewController: IncomesViewController, didUpdateRowWith income: Income) {
        
    }
    
    func incomesViewControllerChanged(_ incomesViewController: IncomesViewController) {
        o_dateChanger.updateIncome(with: incomesViewController.incomes)
    }
}
