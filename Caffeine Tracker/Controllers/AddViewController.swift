//
//  ViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 29.12.22.
//

import UIKit
import AudioToolbox
import CoreData

class AddViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var drinkArray = [Drink]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var drinkName: String?
    var drinkCaffeine: String?
    var drinkServing: String?
    var selectedIndex: Int?
    var editVC: Bool {
        return navigationItem.title == "Edit Drink"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: K.drinkNameCellIdentifier, bundle: nil), forCellReuseIdentifier: K.drinkNameCellIdentifier)
        tableView.register(UINib(nibName: K.iconCellIdentifier, bundle: nil), forCellReuseIdentifier: K.iconCellIdentifier)
        tableView.register(UINib(nibName: K.numberCellIdentifier, bundle: nil), forCellReuseIdentifier: K.numberCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        // Customize view
        tableView.layer.cornerRadius = 15.0
        deleteView.layer.cornerRadius = 15.0
        deleteButton.layer.borderWidth = 0.0
        deleteButton.contentHorizontalAlignment = .left
        
        // Hide delete view if adding
        deleteView.isHidden = !editVC
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
        
        if (!name.isEmpty && !caffeineAmount.isEmpty && !servingAmount.isEmpty) {

            loadDrinks()
            if !editVC {
                let newDrink = Drink(context: self.context)
                newDrink.name = name
                newDrink.icon = "Icon.png"
                newDrink.caffeine = Int64(caffeineAmount)!
                newDrink.serving = Int64(servingAmount)!
                newDrink.caffeineOz = calculateCaffeinePerOz(newDrink.caffeine, newDrink.serving)
                drinkArray.append(newDrink)
            } else {
                drinkArray[selectedIndex!].name = name
                drinkArray[selectedIndex!].caffeine = Int64(caffeineAmount)!
                drinkArray[selectedIndex!].serving = Int64(servingAmount)!
                drinkArray[selectedIndex!].caffeineOz = calculateCaffeinePerOz(Int64(caffeineAmount)!, Int64(servingAmount)!)
            }
        
            saveDrinks()
            dismiss(animated: true, completion: nil)
        } else {
            AudioServicesPlaySystemSound(1519)
            shake(tableView)
        }
    }
    
    @IBAction func cancelClicked(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func removeClicked(_ sender: UIButton) {
        
        // Change color
        deleteView.backgroundColor = .systemGray4
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            UIView.animate(withDuration: 0.1) {
                self.deleteView.backgroundColor =  .systemBackground
            }
        })
        
        // Present alert to ask user if they want to delete for sure
        let alert = UIAlertController(title: "", message: "Are you sure you want to remove the drink?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { action in
            self.loadDrinks()
            self.context.delete(self.drinkArray[self.selectedIndex!])
            self.drinkArray.remove(at: self.selectedIndex!)
            self.saveDrinks()
            self.dismiss(animated: true, completion: nil)
        }
        let noAction = UIAlertAction(title: "No", style:. default)
        alert.addAction(noAction)
        alert.addAction(yesAction)
        present(alert, animated: true)
    }
    
    // Creates a basic shake animation for the text fields
    func shake(_ viewToShake: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: viewToShake.center.x - 10, y: viewToShake.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: viewToShake.center.x + 10, y: viewToShake.center.y))
        viewToShake.layer.add(animation, forKey: "position")
    }
    
    // Calculates how much caffeine per oz a drink contains
    func calculateCaffeinePerOz(_ caffeineAmount: Int64, _ servingSize: Int64) -> Int64 {
        return caffeineAmount / servingSize
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
            let nameCell = tableView.dequeueReusableCell(withIdentifier: K.drinkNameCellIdentifier, for: indexPath) as! DrinkNameCell
            if editVC {
                nameCell.textField.text = drinkName
            }
            return nameCell
        case 1:
            return tableView.dequeueReusableCell(withIdentifier: K.iconCellIdentifier, for: indexPath) as! IconCell
        case 2:
            let caffeineCell = tableView.dequeueReusableCell(withIdentifier: K.numberCellIdentifier, for: indexPath) as! NumberCell
            if editVC {
                caffeineCell.textField.text = drinkCaffeine
            }
            return caffeineCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: K.numberCellIdentifier, for: indexPath) as! NumberCell
            cell.titleLabel.text = "Serving Size (fl oz)"
            cell.textField.placeholder = "4"
            if editVC {
                cell.textField.text = drinkServing
            }
            return cell
        }
    }
    
}
