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
    var caffeineVC: CaffeineViewController? = nil
    let drinkTypes: [String] = ["Esspresso", "Coffee", "Soda", "Energy Drink", "Chocolate", "Supplement", "Tea"]
    
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
    
    override func viewDidDisappear(_ animated: Bool) {
        caffeineVC?.viewDidAppear(true)
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
        let iconCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! IconCell
        
        if (!name.isEmpty && !caffeineAmount.isEmpty && !servingAmount.isEmpty) {
            
            loadDrinks()
            if !editVC {
                let newDrink = Drink(context: self.context)
                newDrink.name = name
                newDrink.icon = formatImageName(iconCell.iconLabel.text!)
                newDrink.caffeine = Int64(caffeineAmount)!
                newDrink.serving = Int64(servingAmount)!
                newDrink.caffeineOz = calculateCaffeinePerOz(newDrink.caffeine, newDrink.serving)
                drinkArray.append(newDrink)
            } else {
                drinkArray[selectedIndex!].name = name
                drinkArray[selectedIndex!].icon = formatImageName(iconCell.iconLabel.text!)
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
    
    // Formats the given input string as an image name
    func formatImageName(_ imageName: String) -> String {
        var lowerCaseName = imageName.lowercased()
        lowerCaseName.replace(" ", with: "-")
        return lowerCaseName + ".png"
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
    func calculateCaffeinePerOz(_ caffeineAmount: Int64, _ servingSize: Int64) -> Double {
        return Double(caffeineAmount) / Double(servingSize)
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
        loadDrinks() 
        switch indexPath.row {
        case 0:
            let nameCell = tableView.dequeueReusableCell(withIdentifier: K.drinkNameCellIdentifier, for: indexPath) as! DrinkNameCell
            if editVC {
                nameCell.textField.text = drinkName
            }
            return nameCell
        case 1:
            let iconCell = tableView.dequeueReusableCell(withIdentifier: K.iconCellIdentifier, for: indexPath) as! IconCell
            if editVC {
                iconCell.iconLabel.text = formatIconName(drinkArray[selectedIndex!].icon!)
            }
            return iconCell
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
    
    // Returns drink type from icon name
    func formatIconName(_ iconName: String) -> String {
        var formattedName = iconName
        for _ in 0...3 {
            formattedName.removeLast()
        }
        formattedName.replace("-", with: " ")
        return formattedName.capitalized
    }
    
    // Present UIPickerView when user selects type of beverage
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let alert = UIAlertController(title: "Select Drink Type", message: "", preferredStyle: .alert)
            let pickerView = UIPickerView(frame: CGRect(x: 0, y: -40, width: 200, height: 150))
            let action = UIAlertAction(title: "Done", style: .default) { action in
                let selectedRow = pickerView.selectedRow(inComponent: 0)
                let drinkType = self.drinkTypes[selectedRow]
                let iconCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! IconCell
                iconCell.iconLabel.text = drinkType
            }
            alert.addAction(action)
            alert.view.tintColor = UIColor(named: "Green")
            
            let viewController = UIViewController()
            viewController.preferredContentSize = CGSize(width: 200, height: 150)
            
            pickerView.delegate = self
            pickerView.dataSource = self
            // pickerView.selectRow(currentCurrencyRow(), inComponent: 0, animated: false)
            viewController.view.addSubview(pickerView)
            alert.setValue(viewController, forKey: "contentViewController")
            
            present(alert, animated: true)
        }
    }
}

// MARK: - Picker View methods

extension AddViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return drinkTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return drinkTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 200.0
    }
    
}
