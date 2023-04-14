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
    
    var delegate: CaffeineViewControllerDelegate? = nil
    var drinkArray = [Drink]()
    var frequentlyConsumedDrinkArray = [Drink]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var databaseManager = DataBaseManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        searchBar.delegate = self
        loadDrinks()
        tableView.register(UINib(nibName: K.caffeineCellIdentifier, bundle: nil), forCellReuseIdentifier: K.caffeineCellIdentifier)
        
        // Customize navigation bar
        tabBarController?.navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.navigationController?.navigationBar.isTranslucent = true
        
        // Refresh functionality
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(loadDrinksC), for: .valueChanged)

    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Frequently Consumed Drinks: \(frequentlyConsumedDrinkArray.count)")
        loadDrinks()
    }
    
    // MARK: - TableView methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Add section when frequently consumed drinks are available
        return frequentlyConsumedDrinkArray.count > 0 ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && tableView.numberOfSections == 2 {
            return "Frequently Consumed"
        }
        return "Drinks"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && tableView.numberOfSections == 2 {
            return frequentlyConsumedDrinkArray.count
        }
        return drinkArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return K.UI.drinkCellHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.caffeineCellIdentifier, for: indexPath) as! CaffeineCell
        var currentDrink = Drink()
        if indexPath.section == 0 && tableView.numberOfSections == 2 {
            currentDrink = frequentlyConsumedDrinkArray[indexPath.row]
        } else {
            currentDrink = drinkArray[indexPath.row]
        }
        cell.nameLabel.text = currentDrink.name
        cell.caffeineLabel.text = "\(String(currentDrink.caffeine)) MG"
        cell.icon.image = UIImage(named: currentDrink.icon!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.drinksToAddSegue, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.drinksToAddSegue {
            
            let navigationController = segue.destination as! UINavigationController
            let destinationVC = navigationController.viewControllers[0] as! AddViewController
            destinationVC.caffeineVC = self
            
            if let selectedIndex = tableView.indexPathForSelectedRow {
                destinationVC.navigationItem.title = "Edit Drink"
                var selectedDrink = Drink()
                if selectedIndex.section == 0 && tableView.numberOfSections == 2 {
                    selectedDrink = frequentlyConsumedDrinkArray[selectedIndex.row]
                } else {
                    selectedDrink = drinkArray[selectedIndex.row]
                }
                destinationVC.drinkName = selectedDrink.name
                destinationVC.drinkCaffeine = String(selectedDrink.caffeine)
                destinationVC.drinkServing = String(selectedDrink.serving)
                destinationVC.selectedDrink = selectedDrink
            } else {
                destinationVC.navigationItem.title = "Add Drink"
            }
        }
    }
    
    // MARK: - Core Data methods
    
    func loadDrinks(with request: NSFetchRequest<Drink> = Drink.fetchRequest(), and predicate: NSPredicate? = nil) {
        request.predicate = predicate
        do {
            drinkArray = try context.fetch(request)
            frequentlyConsumedDrinkArray = databaseManager.getFrequentlyConsumedDrinks()
        } catch {
            print("Error while loading data")
        }
        drinkArray = drinkArray.sorted { first, second in
            return first.name!.capitalized < second.name!.capitalized
        }
        frequentlyConsumedDrinkArray = frequentlyConsumedDrinkArray.sorted(by: { first, second in
            return first.name!.capitalized < second.name!.capitalized
        })
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

protocol CaffeineViewControllerDelegate {
    func recordChanged()
}
