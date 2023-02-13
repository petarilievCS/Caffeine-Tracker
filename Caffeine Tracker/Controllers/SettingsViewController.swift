//
//  SettingsViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 13.2.23.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: K.settingsCellIdentifier, bundle: .main), forCellReuseIdentifier: K.settingsCellIdentifier)
        tableView.register(UINib(nibName: K.regularSettingsCellIdentifier, bundle: .main), forCellReuseIdentifier: K.regularSettingsCellIdentifier)

        // Customize UI
        tableView.layer.cornerRadius = 15.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
}

// MARK: - TableView methods

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 1 {
            let alert = UIAlertController(title: "Caffeine Limit", message: "Enter new caffeine limit", preferredStyle: .alert)
            alert.addTextField()
            alert.textFields![0].keyboardType = .numberPad
            
            let actionOK = UIAlertAction(title: "OK", style: .default) { action in
                let newLimit = Int(alert.textFields![0].text!)
                UserDefaults.standard.set(newLimit, forKey: K.dailyLimit)
            }
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(actionOK)
            alert.addAction(actionCancel)
            present(alert, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let switchCell = tableView.dequeueReusableCell(withIdentifier: K.settingsCellIdentifier, for: indexPath) as! SettingsCell
            switchCell.title.text = "Notifications"
            return switchCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.regularSettingsCellIdentifier, for: indexPath) as! RegularSettingsCell
            cell.title.text = "Caffeine Limit"
            cell.icon.image = UIImage(named: "CaffeineLimit.png")!
            return cell
        }
    }
    
}
