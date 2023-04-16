//
//  SettingsViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 13.2.23.
//

import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - @IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    private let appStoreUrlString = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1665493398&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software"
    private let appStoreReviewUrlString = "https://itunes.apple.com/app/id1665493398?action=write-review"
    private let email = "petariliev2002@gmail.com"
    
    private var settings: [Setting] = [
        Setting(title: "Notifications", image: UIImage(named: "Notifications.png")!),
        Setting(title: "Caffeine Limit", image: UIImage(named: "CaffeineLimit.png")!),
        Setting(title: "App Store", image: UIImage(named: "AppStore.png")!),
        Setting(title:  "Review", image: UIImage(named: "Favorite.png")!),
        Setting(title: "Email", image: UIImage(named: "Mail.png")!),
        Setting(title: "Share", image:  UIImage(named: "Share.png")!),
    ]
    
    // MARK: - View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: K.ID.switchCell, bundle: .main), forCellReuseIdentifier: K.ID.switchCell)
        tableView.register(UINib(nibName: K.ID.settingCell, bundle: .main), forCellReuseIdentifier: K.ID.settingCell)
        
        // Customize UI
        tableView.layer.cornerRadius = 15.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
}

// MARK: - UITableView methods
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count + 1 // +1 for version cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return K.UI.settingCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 { // Change caffeine limit
            let alert = UIAlertController(title: "Caffeine Limit", message: "Enter new caffeine limit", preferredStyle: .alert)
            alert.addTextField()
            alert.textFields![0].keyboardType = .numberPad
            let actionOK = UIAlertAction(title: "OK", style: .default) { action in
                let newLimit = Int(alert.textFields![0].text!)
                UserDefaults.standard.set(newLimit, forKey: K.defaults.dailyLimit)
            }
            let actionCancel = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(actionOK)
            alert.addAction(actionCancel)
            present(alert, animated: true)
        } else if (indexPath.row == 2) { // Link to App Store
            guard let appStoreURL = URL(string: appStoreUrlString) else {
                fatalError("Coudln't form URL")
            }
            UIApplication.shared.open(appStoreURL)
        } else if (indexPath.row == 3) { // Link to Review
            guard let appStoreURL = URL(string: appStoreReviewUrlString) else {
                fatalError("Coudln't form URL")
            }
            UIApplication.shared.open(appStoreURL)
        } else if (indexPath.row == 4) { // Link to email
            guard let emailURL = URL(string: "mailto:\(email)") else {
                fatalError("Coudln't form URL")
            }
            UIApplication.shared.open(emailURL)
        } else if (indexPath.row == 5) { // Share app
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
        switch indexPath.row {
        case 0: // Notification cell
            let switchCell = tableView.dequeueReusableCell(withIdentifier: K.ID.switchCell, for: indexPath) as! SwitchCell
            switchCell.title.text = "Notifications"
            return switchCell
        case settings.count: // Version cell
            let versionCell = tableView.dequeueReusableCell(withIdentifier: K.ID.detailSettingCell, for: indexPath)
            if let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
                versionCell.detailTextLabel!.text = appVersion
            }
            return versionCell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: K.ID.settingCell, for: indexPath) as! SettingCell
            cell.title.text = settings[indexPath.row].title
            cell.icon.image = settings[indexPath.row].image
            return cell
        }
    }
    
}
