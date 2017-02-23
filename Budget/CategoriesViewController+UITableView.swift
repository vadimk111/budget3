//
//  CategoriesViewController+UITableView.swift
//  Budget
//
//  Created by Vadim Kononov on 18/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

extension CategoriesViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCells", for: indexPath) as! CategoryTableViewCell
        var isExpanded = false
        if let isExpandedValue = expandedIndexes[indexPath.row] {
            isExpanded = isExpandedValue
        }
        cell.populate(with: categories[indexPath.row], isExpanded: isExpanded, mainColor: colors[indexPath.row % colors.count])
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction.init(style: UITableViewRowActionStyle.normal, title: "Edit", handler: { [unowned self] (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            self.performSegue(withIdentifier: "editCategory", sender: indexPath)
        })
        let delete = UITableViewRowAction.init(style: UITableViewRowActionStyle.normal, title: "Remove", handler: { [unowned self] (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            let a = UIAlertController(title: "Remove category and all its sub categories ?", message: "", preferredStyle: UIAlertControllerStyle.alert)
            a.addAction(UIAlertAction(title: "Remove", style: .default) { [unowned self] action -> Void in
                self.categories[indexPath.row].delete()
            })
            a.addAction(UIAlertAction(title: "Cancel", style: .default) { action -> Void in })
            self.present(a, animated: true, completion: nil)
        })
        return [delete, edit]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let category = categories[sourceIndexPath.row]
         
        categories.remove(at: sourceIndexPath.row)
        categories.insert(category, at: destinationIndexPath.row)
        
        let hasParent = category.parent != nil
        
        if hasParent {
            if let parentCategory = categories.filter({ $0.id == category.parent! }).first {
                if let subSourceIndex = parentCategory.subCategories?.index(of: category) {
                    parentCategory.subCategories?.remove(at: subSourceIndex)
                    parentCategory.subCategories?.insert(category, at: subSourceIndex + destinationIndexPath.row - sourceIndexPath.row)
                }
            }
        }
        
        if isFirstInRow(dest: destinationIndexPath, hasParent: hasParent) {
            category.order = categories[destinationIndexPath.row + 1].order - 100
        } else if isLastInRow(dest: destinationIndexPath, hasParent: hasParent) {
            category.order = categories[destinationIndexPath.row - 1].order + 100
        } else {
            let prev = categories[destinationIndexPath.row - 1]
            let next = categories[destinationIndexPath.row + 1]
            category.order = prev.order + (next.order - prev.order) / 2
        }
        
        category.update()
    }
    
    func isFirstInRow(dest: IndexPath, hasParent: Bool) -> Bool {
        if hasParent {
            return categories[dest.row - 1].parent == nil
        }
        return dest.row == 0
    }
    
    func isLastInRow(dest: IndexPath, hasParent: Bool) -> Bool {
        if hasParent {
            return dest.row == categories.count - 1 || categories[dest.row + 1].parent == nil
        }
        return dest.row == categories.count - 1
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if categories[sourceIndexPath.row].parent == categories[proposedDestinationIndexPath.row].parent {
            return proposedDestinationIndexPath
        }
        return sourceIndexPath
    }
}
