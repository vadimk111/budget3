//
//  IncomesViewController+UITableView.swift
//  Budget
//
//  Created by Vadik on 30/05/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

extension IncomesViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return incomes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "incomeCells", for: indexPath) as! IncomeTableViewCell
        cell.delegate = self
        cell.fill(with: incomes[indexPath.row], mainColor: colors[indexPath.row % colors.count])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction.init(style: UITableViewRowActionStyle.normal, title: "Remove", handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            self.incomes[indexPath.row].delete()
        })
        return [delete]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.incomesViewController(self, didSelect: incomes[indexPath.row])
    }
}
