//
//  CategoriesViewController+TableViews.swift
//  Budget
//
//  Created by Vadim Kononov on 20/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import Foundation

extension CategoriesViewController : CategoryTableViewCellDelegate, CategoriesHeaderViewDelegate {
    
    //MARK: CategoryTableViewCellDelegate
    func categoryTableViewCellDidExpand(_ cell: CategoryTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            self.expandedIndexes[indexPath.row] = true
            let category = categories[indexPath.row]
            if let subCategories = category.subCategories {
                categories.insert(contentsOf: subCategories, at: indexPath.row + 1)
                tableView.insertRows(at: buildChildIndexPaths(from: indexPath, count: subCategories.count), with: .fade)
            }
        }
    }
    
    func categoryTableViewCellDidCollapse(_ cell: CategoryTableViewCell) {
        if let indexPath = tableView.indexPath(for: cell) {
            self.expandedIndexes[indexPath.row] = false
            let category = categories[indexPath.row]
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
    
    //MARK: CategoriesHeaderViewDelegate
    func categoriesHeaderViewDidGoNext(_ categoriesHeaderView: CategoriesHeaderView) {
        changeDate(forward: true)
    }
    
    func categoriesHeaderViewDidGoPrev(_ categoriesHeaderView: CategoriesHeaderView) {
        changeDate(forward: false)
    }
    
    func changeDate(forward: Bool) {
        let calendar = Calendar.current
        var year = calendar.component(.year, from: date)
        var month = calendar.component(.month, from: date)
        
        var comp = DateComponents()
        if forward {
            if month == 12 {
                year += 1
                month = 1
            } else {
                month += 1
            }
        } else {
            if month == 1 {
                year -= 1
                month = 12
            } else {
                month -= 1
            }
        }
        
        comp.day = 1
        comp.month = month
        comp.year = year
        
        date = calendar.date(from: comp)!
        closestBudget = categories
        reload()

    }
}
