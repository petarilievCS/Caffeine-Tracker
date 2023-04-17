//
//  ViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 29.12.22.
//

import UIKit
import AudioToolbox
import CoreData

class DrinkViewController: UIViewController {
    
    // MARK: - @IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var delegate: AddViewControllerDelegate? = nil
    var selectedDrink: Drink?
    var editDrink: Bool = false
    
    private var db = DataBaseManager()
    private var frequentlyConsumedDrink: Bool = false
    
    // MARK: - View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: K.ID.nameCell, bundle: nil), forCellReuseIdentifier: K.ID.nameCell)
        tableView.register(UINib(nibName: K.ID.iconCell, bundle: nil), forCellReuseIdentifier: K.ID.iconCell)
        tableView.register(UINib(nibName: K.ID.numberCell, bundle: nil), forCellReuseIdentifier: K.ID.numberCell)
        tableView.delegate = self
        tableView.dataSource = self
        
        // Customize view
        tableView.layer.cornerRadius = K.UI.cornerRadius
        deleteView.layer.cornerRadius = K.UI.cornerRadius
        deleteButton.layer.borderWidth = 0.0
        deleteButton.contentHorizontalAlignment = .left
        
        // Hide delete view if adding
        deleteView.isHidden = !editDrink
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = editDrink ? "Edit Drink" : "Add Drink"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        delegate?.drinkChanged()
    }
    
    // MARK: - @IBActions
    @IBAction func doneClicked(_ sender: UIBarButtonItem) {
        let nameCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DrinkNameCell
        let caffeineCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! NumberCell
        let servingCell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! NumberCell
        let iconCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! IconCell
        
        let name = nameCell.textField.text!
        let caffeine = caffeineCell.textField.text!
        let serving = servingCell.textField.text!
        let icon = Utilities.formatImageName(iconCell.iconLabel.text!)
        
        if (!name.isEmpty && !caffeine.isEmpty && !serving.isEmpty) {
            if !editDrink {
                db.addDrink(name: name, icon: icon, caffeine: Int64(caffeine)!, serving:  Int64(serving)!, caffeineOz: calculateCaffeinePerOz(Int64(caffeine)!, Int64(serving)!))
            } else {
                db.editDrink(selectedDrink!, name: name, icon: icon, caffeine: Int64(caffeine)!, serving: Int64(serving)!, caffeineOz: calculateCaffeinePerOz(Int64(caffeine)!, Int64(serving)!))
            }
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
        deleteView.backgroundColor = .systemBackground
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            UIView.animate(withDuration: 0.1) {
                self.deleteView.backgroundColor = .secondarySystemBackground
            }
        })
        
        // Present alert to ask user if they want to delete for sure
        let alert = UIAlertController(title: "", message: "Are you sure you want to remove the drink?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { action in
            self.db.removeDrinnk(self.selectedDrink!)
            self.dismiss(animated: true, completion: nil)
        }
        let noAction = UIAlertAction(title: "No", style:. default)
        alert.addAction(noAction)
        alert.addAction(yesAction)
        present(alert, animated: true)
    }
}

// MARK: - Table View methods

extension DrinkViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let nameCell = tableView.dequeueReusableCell(withIdentifier: K.ID.nameCell, for: indexPath) as! DrinkNameCell
            if editDrink {
                nameCell.textField.text = selectedDrink?.name
            }
            return nameCell
        case 1:
            let iconCell = tableView.dequeueReusableCell(withIdentifier: K.ID.iconCell, for: indexPath) as! IconCell
            if editDrink {
                iconCell.iconLabel.text = Utilities.formatIconName(selectedDrink!.icon!)
            }
            return iconCell
        case 2:
            let caffeineCell = tableView.dequeueReusableCell(withIdentifier: K.ID.numberCell, for: indexPath) as! NumberCell
            if editDrink {
                caffeineCell.textField.text = String(selectedDrink!.caffeine)
            }
            return caffeineCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: K.ID.numberCell, for: indexPath) as! NumberCell
            cell.titleLabel.text = "Serving Size (fl oz)"
            cell.textField.placeholder = "4"
            if editDrink {
                cell.textField.text = String(selectedDrink!.serving)
            }
            return cell
        }
    }
    
    // Present UIPickerView when user selects type of beverage
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let iconCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! IconCell
        if indexPath.row == 1 {
            let alert = UIAlertController(title: "Select Drink Type", message: "\n\n\n\n", preferredStyle: .alert)
            alert.isModalInPresentation = true
            let pickerView = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
            alert.view.addSubview(pickerView)
            pickerView.delegate = self
            pickerView.dataSource = self
            let action = UIAlertAction(title: "Done", style: .default) { action in
                let selectedRow = pickerView.selectedRow(inComponent: 0)
                let drinkType = K.data.drinkTypes[selectedRow]
                iconCell.iconLabel.text = drinkType
            }
            alert.addAction(action)
            present(alert, animated: true)
            pickerView.selectRow(K.data.drinkTypes.firstIndex(of: iconCell.iconLabel.text!)!, inComponent: 0, animated: false)
        }
    }
}

// MARK: - UIPickerView methods
extension DrinkViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return K.data.drinkTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return K.data.drinkTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 200.0
    }
}

// MARK: - Helper methods
extension DrinkViewController {
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
}

protocol AddViewControllerDelegate {
    func drinkChanged()
}
