//
//  AddViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 29.12.22.
//

import UIKit
import CoreData

class CaffeineViewController: UITableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var drinkArray = [Drink]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        loadDrinks()
        tableView.register(UINib(nibName: K.caffeineCellIdentifier, bundle: nil), forCellReuseIdentifier: K.caffeineCellIdentifier)
        
        // Customize navigation bar
        tabBarController?.navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.navigationController?.navigationBar.isTranslucent = true
        
        // Refresh functionality
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(loadDrinksC), for: .valueChanged)
        
        // Remove keyboard when tapping
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
        print(currentDrink.caffeineOz)
        return cell
    }
    
    // MARK: - Core Data methods
    
    func loadDrinks(with request: NSFetchRequest<Drink> = Drink.fetchRequest(), and predicate: NSPredicate? = nil) {
        request.predicate = predicate
        do {
            drinkArray = try context.fetch(request)
        } catch {
            print("Error while loading data")
        }
        tableView.reloadData()
    }
    
    // Refresh information
    @objc func loadDrinksC() {
        searchBar.text = ""
        loadDrinks()
        DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
    }
}

extension CaffeineViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // create request
        let request: NSFetchRequest<Drink> = Drink.fetchRequest()
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        
        // sort data
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // perform request/query
        loadDrinks(with: request, and: predicate)
    }
    
    // reset list to original when "x" is pressed
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text!.count == 0) {
            loadDrinks()
            
            // make sure the process doesn't get sent to background thread
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
