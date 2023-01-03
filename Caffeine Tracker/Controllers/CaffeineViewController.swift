//
//  AddViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 29.12.22.
//

import UIKit
import CoreData

class CaffeineViewController: UITableViewController {
    
    var drinkArray = [Drink]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadDrinks()
        tableView.register(UINib(nibName: K.caffeineCellIdentifier, bundle: nil), forCellReuseIdentifier: K.caffeineCellIdentifier)
        
        // Customize navigation bar
        tabBarController?.navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadDrinks()
    }
    
    // MARK: - TableView methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drinkArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.caffeineCellIdentifier, for: indexPath) as! CaffeineCell
        let currentDrink = drinkArray[indexPath.row]
        cell.nameLabel.text = currentDrink.name
        cell.caffeineLabel.text = "\(String(currentDrink.caffeine)) MG"
        return cell
    }
    
    // MARK: - Core Data methods
    
    func loadDrinks() {
        do {
            drinkArray = try context.fetch(Drink.fetchRequest())
        } catch {
            print("Error while loading data")
        }
        tableView.reloadData()
    }
}
