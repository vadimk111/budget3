//
//  AutoCompleteViewController.swift
//  Budget
//
//  Created by Vadik on 12/11/2017.
//  Copyright © 2017 Vadim Kononov. All rights reserved.
//

import UIKit

protocol AutoCompleteViewControllerDelegate: class {
    func autoCompleteViewController(_ autoCompleteViewController: AutoCompleteViewController, didSelectItem item: String)
}

class AutoCompleteViewController: UITableViewController {

    var items: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var delegate: AutoCompleteViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "autoComplete", for: indexPath)
        cell.textLabel?.text = items[indexPath.row]
        cell.textLabel?.textColor = UIColor(red: 42 / 255, green: 42 / 255, blue: 42 / 255, alpha: 1)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.autoCompleteViewController(self, didSelectItem: items[indexPath.row])
    }

}
