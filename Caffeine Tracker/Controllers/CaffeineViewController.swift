//
//  DrinksViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 29.12.22.
//

import UIKit
import CoreData

class CaffeineViewController: UITableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    
    var delegate: CaffeineViewControllerDelegate? = nil
    
    var drinkArray = [Drink]()
    var frequentlyConsumedDrinkArray = [Drink]()
    private var db = DataBaseManager()

    // MARK: - View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.register(UINib(nibName: K.ID.caffeineCell, bundle: nil), forCellReuseIdentifier: K.ID.caffeineCell)
        searchBar.delegate = self

        // Customize navigation bar
        tabBarController?.navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.navigationController?.navigationBar.isTranslucent = true
        
        // Refresh functionality
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(loadDrinksC), for: .valueChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadDrinks()
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.ID.segues.drinksToAdd {
            let navigationController = segue.destination as! UINavigationController
            let destinationVC = navigationController.viewControllers[0] as! DrinkViewController
            destinationVC.delegate = self
            if let selectedIndex = tableView.indexPathForSelectedRow {
                destinationVC.editDrink = true
                destinationVC.selectedDrink = (selectedIndex.section == 0 && tableView.numberOfSections == 2) ? frequentlyConsumedDrinkArray[selectedIndex.row] : drinkArray[selectedIndex.row]
            }
        }
    }
}

// MARK: - CoreData methods
extension CaffeineViewController {
    func loadDrinks(with request: NSFetchRequest<Drink> = Drink.fetchRequest(), and predicate: NSPredicate? = nil) {
        drinkArray = db.getDrinks(with: request, and: predicate)
        frequentlyConsumedDrinkArray = db.getFrequentlyConsumedDrinks()
        tableView.reloadData()
    }
    
    // Refresh information
    @objc func loadDrinksC() {
        searchBar.text = ""
        loadDrinks()
        DispatchQueue.main.async { self.refreshControl?.endRefreshing() }
    }
}

// MARK: - TableView methods
extension CaffeineViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return frequentlyConsumedDrinkArray.count > 0 ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section == 0 && tableView.numberOfSections == 2) ? "Frequently Consumed" : "Drinks"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section == 0 && tableView.numberOfSections == 2) ? frequentlyConsumedDrinkArray.count : drinkArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return K.UI.drinkCellHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.ID.caffeineCell, for: indexPath) as! CaffeineCell
        let currentDrink = (indexPath.section == 0 && tableView.numberOfSections == 2) ? frequentlyConsumedDrinkArray[indexPath.row] : drinkArray[indexPath.row]
        cell.nameLabel.text = currentDrink.name
        cell.caffeineLabel.text = "\(String(currentDrink.caffeine)) MG"
        cell.icon.image = UIImage(named: currentDrink.icon!)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.ID.segues.drinksToAdd, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - SearchBarDelegte methods
extension CaffeineViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Drink> = Drink.fetchRequest()
        let predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
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

extension CaffeineViewController: AddViewControllerDelegate {
    func drinkChanged() {
        loadDrinks()
    }
}

protocol CaffeineViewControllerDelegate {
    func drinkChanged()
}
