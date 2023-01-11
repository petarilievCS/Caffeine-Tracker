//
//  DrinkViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 4.1.23.
//

import UIKit

class DrinkViewController: CaffeineViewController {
    
    @IBOutlet weak var newSearchBar: UISearchBar!
    
    var dashboardVC: DashboardViewController? = nil
    
    override func viewDidLoad() {
        self.searchBar = newSearchBar
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        dashboardVC?.viewDidAppear(true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselct all rows
        for index in 0..<tableView.numberOfRows(inSection: 0) {
            tableView.cellForRow(at: IndexPath(row: index, section: 0))?.accessoryType = .disclosureIndicator
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        performSegue(withIdentifier: K.drinksToAmountSegue, sender: self)
    }
    
    func deselectRows() {
        for i in 0...drinkArray.count {
            tableView.cellForRow(at: IndexPath(row: i, section: 0))?.accessoryType = .disclosureIndicator
        }
    }

    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.contentView.superview?.backgroundColor = .white
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! AdjustViewController
        destinationVC.drinksVC = self
        destinationVC.modalPresentationStyle = .overCurrentContext
        let selectedDrink = drinkArray[tableView.indexPathForSelectedRow!.row]
        destinationVC.currentAmount = selectedDrink.serving
        destinationVC.currentDrink = drinkArray[tableView.indexPathForSelectedRow!.row]
    }
}


