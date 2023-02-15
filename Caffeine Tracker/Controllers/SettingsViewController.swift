//
//  SettingsViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 13.2.23.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let appStoreUrlString = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1665493398&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"
    let appStoreReviewUrlString = "https://itunes.apple.com/app/id1665493398?action=write-review"
    let email = "petariliev2002@gmail.com"
    
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
        return 7
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
        } else if (indexPath.row == 2) {
            guard let appStoreURL = URL(string: appStoreUrlString) else {
                fatalError("Coudln't form URL")
            }
            UIApplication.shared.open(appStoreURL)
        } else if (indexPath.row == 3) {
            guard let appStoreURL = URL(string: appStoreReviewUrlString) else {
                fatalError("Coudln't form URL")
            }
            UIApplication.shared.open(appStoreURL)
        } else if (indexPath.row == 4) {
            guard let emailURL = URL(string: "mailto:\(email)") else {
                fatalError("Coudln't form URL")
            }
            UIApplication.shared.open(emailURL)
        } else if (indexPath.row == 5) {
            let someText = "Share Caffeine Up"
            let objectsToShare:URL = URL(string: "https://apps.apple.com/us/app/caffeine-up/id1665493398?uo=2")!
            let sharedObjects:[AnyObject] = [objectsToShare as AnyObject,someText as AnyObject]
            let activityViewController = UIActivityViewController(activityItems : sharedObjects, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let switchCell = tableView.dequeueReusableCell(withIdentifier: K.settingsCellIdentifier, for: indexPath) as! SettingsCell
            switchCell.title.text = "Notifications"
            return switchCell
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.regularSettingsCellIdentifier, for: indexPath) as! RegularSettingsCell
            cell.title.text = "Caffeine Limit"
            cell.icon.image = UIImage(named: "CaffeineLimit.png")!
            return cell
        } else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.regularSettingsCellIdentifier, for: indexPath) as! RegularSettingsCell
            cell.title.text = "App Store"
            cell.icon.image = UIImage(named: "AppStore.png")!
            return cell
        } else if indexPath.row == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.regularSettingsCellIdentifier, for: indexPath) as! RegularSettingsCell
            cell.title.text = "Review"
            cell.icon.image = UIImage(named: "Favorite.png")!
            return cell
        } else if indexPath.row == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.regularSettingsCellIdentifier, for: indexPath) as! RegularSettingsCell
            cell.title.text = "Email"
            cell.icon.image = UIImage(named: "Mail.png")!
            return cell
        } else if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.regularSettingsCellIdentifier, for: indexPath) as! RegularSettingsCell
            cell.title.text = "Share"
            cell.icon.image = UIImage(named: "Share.png")!
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.versionSettingsCellIdentifier, for: indexPath)
            return cell
        }
    }
    
}
