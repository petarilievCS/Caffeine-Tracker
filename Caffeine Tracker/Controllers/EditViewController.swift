//
//  EditViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 24.2.23.
//

import UIKit

class EditViewController: UIViewController  {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteView: UIView!
    
    var selectedRecord: ConsumedDrink?
    var selectedDrink: String?
    let drinkTypes: [String] = ["Espresso", "Hot Coffee", "Cold Coffee", "Canned Coffee", "Soft Drink", "Energy Drink", "Energy Shot", "Chocolate", "Supplement", "Tea", "Iced Tea"]
    var databaseManager: DataBaseManager = DataBaseManager()
    var dashboardVC: DashboardViewController?
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: K.drinkNameCellIdentifier, bundle: nil), forCellReuseIdentifier: K.drinkNameCellIdentifier)
        tableView.register(UINib(nibName: K.iconCellIdentifier, bundle: nil), forCellReuseIdentifier: K.iconCellIdentifier)
        tableView.register(UINib(nibName: K.numberCellIdentifier, bundle: nil), forCellReuseIdentifier: K.numberCellIdentifier)
        tableView.register(UINib(nibName: K.dateCellIdentifier, bundle: nil), forCellReuseIdentifier: K.dateCellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        deleteView.layer.cornerRadius = 15.0
        tableView.layer.cornerRadius = 15.0
    }
    
    // MARK: - IBActions
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        // TODO: Update database
        let newName: String = ((tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DrinkNameCell?)?.textField.text)!
        let newType: String = formatImageName((tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! IconCell).iconLabel.text!)
        let newAmount: Int64 = Int64((tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! NumberCell).textField.text!) ?? 0
        let newDate: Date = (tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! DateCell).datePicker.date
        databaseManager.updateRecord(selectedRecord!, name: newName, type: newType, amount: newAmount, time: newDate)
        dashboardVC?.viewDidAppear(true)
        self.dismiss(animated: true)
    }
        
    // Formats the given input string as an image name
    func formatImageName(_ imageName: String) -> String {
        var lowerCaseName = imageName.lowercased()
        lowerCaseName.replace(" ", with: "-")
        return lowerCaseName + ".png"
    }
    
    @IBAction func removeButtonPressed(_ sender: UIButton) {
        databaseManager.removeDrink(selectedRecord!)
        dashboardVC?.viewDidAppear(true)
        self.dismiss(animated: true)
    }
}

// MARK: - UITableView methods
extension EditViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let nameCell = tableView.dequeueReusableCell(withIdentifier: K.drinkNameCellIdentifier, for: indexPath) as! DrinkNameCell
            nameCell.textField.text = selectedRecord!.name
            return nameCell
        } else if indexPath.row == 1 {
            let iconCell = tableView.dequeueReusableCell(withIdentifier: K.iconCellIdentifier, for: indexPath) as! IconCell
            iconCell.iconLabel.text = formatIconName((selectedRecord?.icon)!)
            return iconCell
        } else if indexPath.row == 2 {
            let caffeineCell = tableView.dequeueReusableCell(withIdentifier: K.numberCellIdentifier, for: indexPath) as! NumberCell
            caffeineCell.textField.text = String(selectedRecord!.initialAmount)
            return caffeineCell
        } else  {
            let dateCell = tableView.dequeueReusableCell(withIdentifier: K.dateCellIdentifier, for: indexPath) as! DateCell
            dateCell.datePicker.date = (selectedRecord?.timeConsumed!)!
            return dateCell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let iconCell = self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! IconCell
        
        // Drink type selection
        if indexPath.row == 1 {
            let alert = UIAlertController(title: "Select Drink Type", message: "\n\n\n\n\n", preferredStyle: .alert)
            alert.isModalInPopover = true
            let pickerView = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
            alert.view.addSubview(pickerView)
            pickerView.delegate = self
            pickerView.dataSource = self
            
            let action = UIAlertAction(title: "Done", style: .default) { action in
                let selectedRow = pickerView.selectedRow(inComponent: 0)
                let drinkType = self.drinkTypes[selectedRow]
                iconCell.iconLabel.text = drinkType
            }
            alert.addAction(action)
            present(alert, animated: true)
            pickerView.selectRow(drinkTypes.firstIndex(of: iconCell.iconLabel.text!)!, inComponent: 0, animated: false)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}

// MARK: - UIPickerView methods
extension EditViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return drinkTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return drinkTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let drinkTypeCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! IconCell
        drinkTypeCell.iconLabel.text = drinkTypes[row]
    }
    
    func createPickerView() {
           let pickerView = UIPickerView()
           pickerView.delegate = self
    }
    
    func dismissPickerView() {
       let toolBar = UIToolbar()
       toolBar.sizeToFit()
       let button = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.action))
       toolBar.setItems([button], animated: true)
       toolBar.isUserInteractionEnabled = true
    }
    
    @objc func action() {
          view.endEditing(true)
    }
    
}




