//
//  ViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 29.12.22.
//

import UIKit
import CoreData

class AddViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var drinkArray = [Drink]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
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
    
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        
        // TODO: Fix user input errors
        let nameCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DrinkNameCell
        let name = nameCell.textField.text!
        
        // TODO: Add support for icons
        let caffeineCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! NumberCell
        let servingCell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! NumberCell
        let caffeineAmount = caffeineCell.textField.text!
        let servingAmount = servingCell.textField.text!
        
        let newDrink = Drink(context: self.context)
        newDrink.name = name
        newDrink.icon = "Icon.png"
        newDrink.caffeine = Int64(caffeineAmount)!
        newDrink.serving = Int64(servingAmount)!
        
        loadDrinks()
        drinkArray.append(newDrink)
        saveDrinks()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - CoreData methods
    
    func loadDrinks() {
        do {
            drinkArray = try context.fetch(Drink.fetchRequest())
        } catch {
            print("Error while loading data")
        }
    }
    
    func saveDrinks() {
        do {
            try self.context.save()
        } catch {
            print("Error while saving context")
        }
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
