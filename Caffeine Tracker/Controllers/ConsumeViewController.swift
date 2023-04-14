//
//  ConsumeViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 4.1.23.
//

import UIKit

class ConsumeViewController: CaffeineViewController {
    
    // MARK: - @IBOutlets
    @IBOutlet weak var newSearchBar: UISearchBar!
    
    // MARK: - View Lifecycle methods
    override func viewDidLoad() {
        self.searchBar = newSearchBar
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Add Drink"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.drinkChanged()
    }
    
    // MARK: - @IBActions
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! AdjustViewController
        destinationVC.delegate = self
        destinationVC.modalPresentationStyle = .overCurrentContext
        let selectedDrink = (tableView.numberOfSections == 2 && tableView.indexPathForSelectedRow?.section == 0) ? frequentlyConsumedDrinkArray[tableView.indexPathForSelectedRow!.row] : drinkArray[tableView.indexPathForSelectedRow!.row]
        destinationVC.selectedDrink = selectedDrink
    }
}

// MARK: - UITableView methods
extension ConsumeViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        deselectRows()
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        tableView.cellForRow(at: indexPath)?.accessoryView?.backgroundColor = .systemBackground
        performSegue(withIdentifier: K.ID.segues.drinksToAdjust, sender: self)
    }
    
    func deselectRows() {
        for index in 0..<tableView.numberOfRows(inSection: 0) {
            tableView.cellForRow(at: IndexPath(row: index, section: 0))?.accessoryType = .disclosureIndicator
        }
        if tableView.numberOfSections > 1 {
            for index in 0..<tableView.numberOfRows(inSection: 1) {
                tableView.cellForRow(at: IndexPath(row: index, section: 1))?.accessoryType = .disclosureIndicator
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.contentView.superview?.backgroundColor = .white
    }
}

// MARK: - AdjustViewController Delegate methods
extension ConsumeViewController: AdjustViewControllerDelegate {
    func finishedAdding() {
        deselectRows()
    }
}
