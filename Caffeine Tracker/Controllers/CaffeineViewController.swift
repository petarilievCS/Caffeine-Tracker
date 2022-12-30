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

        // Customize navigation bar
        tabBarController?.navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.navigationController?.navigationBar.isTranslucent = true
    }
}
