//
//  EditViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 24.2.23.
//

import UIKit

class EditViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteView: UIView!
    
    var selectedRecord: ConsumedDrink?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: K.drinkNameCellIdentifier, bundle: nil), forCellReuseIdentifier: K.drinkNameCellIdentifier)
        tableView.register(UINib(nibName: K.iconCellIdentifier, bundle: nil), forCellReuseIdentifier: K.iconCellIdentifier)
        tableView.register(UINib(nibName: K.numberCellIdentifier, bundle: nil), forCellReuseIdentifier: K.numberCellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        deleteView.layer.cornerRadius = 15.0
        tableView.layer.cornerRadius = 15.0
    }
}

// MARK: - UITableView methods
extension EditViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let nameCell = tableView.dequeueReusableCell(withIdentifier: K.drinkNameCellIdentifier, for: indexPath) as! DrinkNameCell
            nameCell.textField.text = selectedRecord!.name
            return nameCell
        case 1:
            let iconCell = tableView.dequeueReusableCell(withIdentifier: K.iconCellIdentifier, for: indexPath) as! IconCell
            iconCell.iconLabel.text = formatIconName((selectedRecord?.icon)!)
            return iconCell
        case 2:
            let caffeineCell = tableView.dequeueReusableCell(withIdentifier: K.numberCellIdentifier, for: indexPath) as! NumberCell
            caffeineCell.textField.text = String(selectedRecord!.initialAmount) + " mg"
            return caffeineCell
        case 3:
            let caffeineCell = tableView.dequeueReusableCell(withIdentifier: K.numberCellIdentifier, for: indexPath) as! NumberCell
            return caffeineCell
        default:
            let caffeineCell = tableView.dequeueReusableCell(withIdentifier: K.numberCellIdentifier, for: indexPath) as! NumberCell
            return caffeineCell
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
    
}


