//
//  ViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 29.12.22.
//

import UIKit
import MKRingProgressView
import SwipeCellKit
import AudioToolbox
import TinyConstraints

class DashboardViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dailyIntakeView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var currentAmountView: UIView!
    @IBOutlet weak var drinkButton: UIButton!
    @IBOutlet weak var dailyAmountLabel: UILabel!
    @IBOutlet weak var drinkNumberLabel: UILabel!
    @IBOutlet weak var metabolismAmountLabel: UILabel!
    @IBOutlet weak var ringView: UIView!
    @IBOutlet weak var drinksLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    private let ringProgressView = RingProgressView(frame: CGRect(x: 0, y: 0, width: 110, height: 110))
    private var consumedDrinksArray = [ConsumedDrink]()
    private var metabolismCalculator = MetabolismCalculator()
    private var db = DataBaseManager()
    
    // MARK: - View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add default drinks if first run
        if !UserDefaults.standard.bool(forKey: K.defaults.firstRun) {
            db.addDefaultDrinks()
        }
        UserDefaults.standard.set(true, forKey: K.defaults.firstRun)
        
        loadConsumedDrinks()
        tableView.register(UINib(nibName:  K.ID.consumedDrinkCell, bundle: nil), forCellReuseIdentifier:  K.ID.consumedDrinkCell)
        tableView.delegate = self
        tableView.dataSource = self
        UNUserNotificationCenter.current().delegate = self
        
        // Customization
        scrollView.showsVerticalScrollIndicator = false
        tabBarController?.navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.navigationController?.navigationBar.isTranslucent = true
        dailyIntakeView.layer.cornerRadius = K.UI.cornerRadius
        currentAmountView.layer.cornerRadius = K.UI.cornerRadius
        drinkButton.layer.cornerRadius = K.UI.cornerRadius
        tableView.layer.cornerRadius = K.UI.cornerRadius
        setupRingProgressView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        recordChanged()
    }
    
    // MARK: - @IBActions
    @IBAction func drinkButtonPressed(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        performSegue(withIdentifier: K.ID.segues.dashboardToDrinks, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.ID.segues.dashboardToRecord {
            let destinationNC = segue.destination as! UINavigationController
            let destinationVC = destinationNC.topViewController as! RecordViewController
            destinationVC.selectedRecord = consumedDrinksArray[tableView.indexPathForSelectedRow!.row]
            destinationVC.delegate = self
        } else {
            let destinationNC = segue.destination as! UINavigationController
            let destinationVC = destinationNC.topViewController as! ConsumeViewController
            destinationVC.delegate = self
        }
    }
    
    func loadConsumedDrinks() {
        consumedDrinksArray = db.getTodayDrinks()
        tableView.reloadData()
    }
}

// MARK: - Table View methods
extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return consumedDrinksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:  K.ID.consumedDrinkCell, for: indexPath) as! ConsumedDrinkCell
        cell.delegate = self
        let consumedDrink = consumedDrinksArray[indexPath.row]
        cell.title.text = consumedDrink.name
        cell.icon.image = UIImage(named: consumedDrink.icon!)
        cell.detail.text = "\(consumedDrink.initialAmount) mg"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: K.ID.segues.dashboardToRecord, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return K.UI.consumedDrinkCellHeight
    }
    
}

// MARK: - SwipeTableView methods
extension DashboardViewController: SwipeTableViewCellDelegate {
    // Add delete action on swipe
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeCellKit.SwipeActionsOrientation) -> [SwipeCellKit.SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.removeDrink(at: indexPath)
        }
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        return [deleteAction]
    }
    
    func removeDrink(at indexPath: IndexPath) {
        loadConsumedDrinks()
        db.removeRecord(consumedDrinksArray[indexPath.row])
        self.consumedDrinksArray.remove(at: indexPath.row)
        recordChanged()
    }
    
}

// MARK: - UserNotificationCenterDelegate Methods
extension DashboardViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .list, .banner])
    }
}

// MARK: - UI Helper Methods
extension DashboardViewController {
    // Updates constraints to account for the number of consumed drinks
    func updateConstraints() {
        drinksLabel.isHidden = consumedDrinksArray.isEmpty
        for constraint in tableView.constraints {
            if constraint.identifier == "tableViewHeight" {
                constraint.constant = CGFloat(consumedDrinksArray.count) * K.UI.consumedDrinkCellHeight
            }
        }
        
        // Expand scroll view
        let extraCells = consumedDrinksArray.count - 3
        for constraint in contentView.constraints {
            if constraint.identifier == "contentViewHeight" {
                if extraCells > 0 {
                    constraint.constant = 675.0 + (CGFloat(extraCells) * K.UI.consumedDrinkCellHeight)
                } else {
                    constraint.constant = 675.0
                }
            }
        }
    }
        
    // Creates ring progress view
    func setupRingProgressView() {
        ringProgressView.ringWidth = 25
        updateProgressView()
        ringView.addSubview(ringProgressView)
    }
    
    
    // Gets the current percentage of the allowed daily caffeine amount that the user has consumed
    func getProgress() -> Double {
        return Double(metabolismCalculator.calculateTotalAmount()) / Double(UserDefaults.standard.integer(forKey: K.defaults.dailyLimit))
    }
    
    // Updates the ring progress view
    func updateProgressView() {
        UIView.animate(withDuration: 0.5) {
            self.ringProgressView.progress = self.getProgress()
            self.ringProgressView.startColor = self.getProgress() > 1.0 ? UIColor(named: "Red")! : UIColor(named: "Green")!
            self.ringProgressView.endColor = self.getProgress() > 1.0 ? UIColor(named: "Red")! : UIColor(named: "Green")!
        }
    }
        
    // Updates the information on the dashboard when the caffeine log changes
    func updateInfo() {
        let dailyAmount = metabolismCalculator.calculateTotalAmount()
        let dailyLimit = UserDefaults.standard.integer(forKey: K.defaults.dailyLimit)
        dailyAmountLabel.text = "\(dailyAmount)/\(UserDefaults.standard.integer(forKey: K.defaults.dailyLimit)) mg"
        drinkNumberLabel.text = String(metabolismCalculator.getNumberOfDrinks())
        metabolismAmountLabel.text = "\(metabolismCalculator.calculateMetabolismAmount()) mg"
        if dailyAmount > UserDefaults.standard.integer(forKey: K.defaults.dailyLimit) {
            dailyAmountLabel.textColor = UIColor(named: "Red")
        } else {
            dailyAmountLabel.textColor = UIColor(named: "Green")
        }
        sendNotification(dailyLimit, dailyAmount)
    }
    
    // Notifies user that their caffeine intake is too high if needed
    func sendNotification(_ dailyLimit: Int, _ dailyAmount: Int) {
        if dailyAmount > dailyLimit && UserDefaults.standard.bool(forKey: K.defaults.notificationPermission) && !UserDefaults.standard.bool(forKey: K.defaults.amountNotificationSent) {
                let notificationConent: UNMutableNotificationContent = UNMutableNotificationContent()
                notificationConent.title = "Caffeine Up"
                notificationConent.body = "You have consumed more caffeine than your daily limit today!"
                
                // Notification trigger
                let fiveMinutesLater = Calendar.current.date(byAdding: .minute, value: 15, to: .now)
                let dateComponent = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: fiveMinutesLater!)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
            UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: K.ID.notification, content: notificationConent, trigger: trigger))
                UserDefaults.standard.set(true, forKey: K.defaults.amountNotificationSent)
        }
    }
}

// MARK: - EditViewControllerDelegate methods
extension DashboardViewController: EditViewControllerDelegate {
    func recordChanged() {
        self.updateInfo()
        updateProgressView()
        loadConsumedDrinks()
        tableView.reloadData()
        updateConstraints()
    }
}

// MARK: - CaffeineViewControlelrDelegate methods
extension DashboardViewController: CaffeineViewControllerDelegate {
    func drinkChanged() {
        updateInfo()
        updateProgressView()
        loadConsumedDrinks()
        tableView.reloadData()
        updateConstraints()
    }
}
