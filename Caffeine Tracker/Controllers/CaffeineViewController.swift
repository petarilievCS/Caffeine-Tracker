//
//  AddViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 29.12.22.
//

import UIKit

class CaffeineViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: K.caffeineCellIdentifier, bundle: nil), forCellReuseIdentifier: K.caffeineCellIdentifier)

        // Customize navigation bar
        tabBarController?.navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.navigationController?.navigationBar.isTranslucent = true
    }
    
    // MARK: - TableView methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.caffeineCellIdentifier, for: indexPath) as! CaffeineCell
        return cell
    }
}
