//
//  ViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 29.12.22.
//

import UIKit

class AddViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: K.drinkNameCellIdentifier, bundle: nil), forCellReuseIdentifier: K.drinkNameCellIdentifier)
        tableView.register(UINib(nibName: K.iconCellIdentifier, bundle: nil), forCellReuseIdentifier: K.iconCellIdentifier)
        tableView.register(UINib(nibName: K.numberCellIdentifier, bundle: nil), forCellReuseIdentifier: K.numberCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        // Customize view
        tableView.layer.cornerRadius = 15.0
    }

}

// MARK: - Table View methods

extension AddViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: K.drinkNameCellIdentifier, for: indexPath) as! DrinkNameCell
        case 1:
            return tableView.dequeueReusableCell(withIdentifier: K.iconCellIdentifier, for: indexPath) as! IconCell
        case 2:
            return tableView.dequeueReusableCell(withIdentifier: K.numberCellIdentifier, for: indexPath) as! NumberCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: K.numberCellIdentifier, for: indexPath) as! NumberCell
            cell.titleLabel.text = "Serving Size (fl oz)"
            cell.textField.placeholder = "4"
            return cell
        }
    }
    
}
