//
//  SubCategoryHeaderView.swift
//  Budget
//
//  Created by Vadim Kononov on 20/02/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

protocol SubCategoryHeaderViewDelegate: class {
    func subCategoryHeaderViewAdd(_ subCategoryHeaderView: SubCategoryHeaderView)
}

class SubCategoryHeaderView: CustomView {

    weak var delegate: SubCategoryHeaderViewDelegate?
    var section: Int = 0
    
    @IBOutlet weak var o_title: UILabel!

    @IBAction func didTapAdd(_ sender: UIButton) {
        delegate?.subCategoryHeaderViewAdd(self)
    }

}
