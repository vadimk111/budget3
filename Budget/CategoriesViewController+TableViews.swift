//
//  CategoriesViewController+TableViews.swift
//  Budget
//
//  Created by Vadim Kononov on 20/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import Foundation

extension CategoriesViewController : CategoryTableViewCellDelegate {
    
    //MARK: CategoryTableViewCellDelegate
    func categoryTableViewCellDidExpand(_ cell: CategoryTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let category = categories[indexPath.row]
            expandedCategories[category.id!] = true
            if let subCategories = category.subCategories {
                categories.insert(contentsOf: subCategories, at: indexPath.row + 1)
                tableView.insertRows(at: buildChildIndexPaths(from: indexPath, count: subCategories.count), with: .fade)
            }
        }
    }
    
    func categoryTableViewCellDidCollapse(_ cell: CategoryTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            let category = categories[indexPath.row]
            expandedCategories.removeValue(forKey: category.id!)
            if let subCategories = category.subCategories {
                categories.removeSubrange(indexPath.row + 1..<indexPath.row + 1 + subCategories.count)
                tableView.deleteRows(at: buildChildIndexPaths(from: indexPath, count: subCategories.count), with: .fade)
            }
        }
    }
    
    func buildChildIndexPaths(from: IndexPath, count: Int) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        var index = 0
        while index < count {
            indexPaths.append(IndexPath.init(row: from.row + 1 + index, section: 0))
            index += 1
        }
        return indexPaths
    }
    
    func categoryTableViewCellDeselected(_ cell: CategoryTableViewCell) {
        delegate?.categoriesViewControllerRowDeselected(self)
    }
}
