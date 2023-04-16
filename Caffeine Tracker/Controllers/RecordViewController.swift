//
//  EditViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 24.2.23.
//

import UIKit

class RecordViewController: UIViewController  {

    // MARK: - @IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteView: UIView!
    
    var selectedRecord: ConsumedDrink?
    var delegate: EditViewControllerDelegate? = nil

    private var db: DataBaseManager = DataBaseManager()
    
    // MARK: - View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: K.ID.nameCell, bundle: nil), forCellReuseIdentifier: K.ID.nameCell)
        tableView.register(UINib(nibName: K.ID.iconCell, bundle: nil), forCellReuseIdentifier: K.ID.iconCell)
        tableView.register(UINib(nibName: K.ID.numberCell, bundle: nil), forCellReuseIdentifier: K.ID.numberCell)
        tableView.register(UINib(nibName: K.ID.dateCell, bundle: nil), forCellReuseIdentifier: K.ID.dateCell)
        tableView.dataSource = self
        tableView.delegate = self
        
        deleteView.layer.cornerRadius = K.UI.cornerRadius
        tableView.layer.cornerRadius = K.UI.cornerRadius
    }
    
    // MARK: - @IBActions
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        let newName: String = ((tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! DrinkNameCell?)?.textField.text)!
        let newType: String = Utilities.formatImageName((tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! IconCell).iconLabel.text!)
        let newAmount: Int64 = Int64((tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as! NumberCell).textField.text!) ?? 0
        let newDate: Date = (tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as! DateCell).datePicker.date
        db.updateRecord(selectedRecord!, name: newName, type: newType, amount: newAmount, time: newDate)
        delegate?.recordChanged()
        self.dismiss(animated: true)
    }
    
    @IBAction func removeButtonPressed(_ sender: UIButton) {
        db.removeRecord(selectedRecord!)
        delegate?.recordChanged()
        self.dismiss(animated: true)
    }
}

// MARK: - UITableView methods
extension RecordViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let nameCell = tableView.dequeueReusableCell(withIdentifier: K.ID.nameCell, for: indexPath) as! DrinkNameCell
            nameCell.textField.text = selectedRecord!.name
            return nameCell
        } else if indexPath.row == 1 {
            let iconCell = tableView.dequeueReusableCell(withIdentifier: K.ID.iconCell, for: indexPath) as! IconCell
            iconCell.iconLabel.text = Utilities.formatIconName((selectedRecord?.icon)!)
            return iconCell
        } else if indexPath.row == 2 {
            let caffeineCell = tableView.dequeueReusableCell(withIdentifier: K.ID.numberCell, for: indexPath) as! NumberCell
            caffeineCell.textField.text = String(selectedRecord!.initialAmount)
            return caffeineCell
        } else  {
            let dateCell = tableView.dequeueReusableCell(withIdentifier: K.ID.dateCell, for: indexPath) as! DateCell
            dateCell.datePicker.date = (selectedRecord?.timeConsumed!)!
            return dateCell
        }
        
    }
    
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
extension RecordViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return K.data.drinkTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return K.data.drinkTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let drinkTypeCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as! IconCell
        drinkTypeCell.iconLabel.text = K.data.drinkTypes[row]
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

protocol EditViewControllerDelegate {
    func recordChanged()
}


