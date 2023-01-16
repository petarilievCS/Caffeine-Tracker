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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dailyIntakeView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var currentAmluntView: UIView!
    @IBOutlet weak var drinkButton: UIButton!
    @IBOutlet weak var dailyAmountLabel: UILabel!
    @IBOutlet weak var drinkNumberLabel: UILabel!
    @IBOutlet weak var metabolismAmountLabel: UILabel!
    @IBOutlet weak var ringView: UIView!
    @IBOutlet weak var drinksLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    let ringProgressView = RingProgressView(frame: CGRect(x: 0, y: 0, width: 110, height: 110))
    
    let defaults = UserDefaults.standard
    var consumedDrinksArray = [ConsumedDrink]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var metabolismCalculator = MetabolismCalculator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadConsumedDrinks()
        tableView.register(UINib(nibName: K.consumedDrinkCellIdentifier, bundle: nil), forCellReuseIdentifier: K.consumedDrinkCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        
        // Customize scroll view
        scrollView.showsVerticalScrollIndicator = false
        
        // Customize navigation bar
        tabBarController?.navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.navigationController?.navigationBar.isTranslucent = true
        
        // Customize views
        dailyIntakeView.layer.cornerRadius = 15.0
        currentAmluntView.layer.cornerRadius = 15.0
        drinkButton.layer.cornerRadius = 15.0
        tableView.layer.cornerRadius = 15.0
        
        setupRingProgressView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateInfo()
        updateProgressView()
        loadConsumedDrinks()
        updateConstraints()
    }
    
    // Setup table view height
    func updateConstraints() {
        drinksLabel.isHidden = consumedDrinksArray.isEmpty
        for constraint in tableView.constraints {
            if constraint.identifier == "tableViewHeight" {
                constraint.constant = CGFloat(consumedDrinksArray.count) * 44.0
            }
        }
        
        // Expand scroll view
        let extraCells = consumedDrinksArray.count - 3
        for constraint in contentView.constraints {
            if constraint.identifier == "contentViewHeight" {
                if extraCells > 0 {
                    constraint.constant = 675.0 + (CGFloat(extraCells) * 44.0)
                } else {
                    constraint.constant = 675.0
                }
            }
        }
    }
    
    @IBAction func drinkButtonPressed(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        performSegue(withIdentifier: K.dashboardToDrinksSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationNC = segue.destination as! UINavigationController
        let destinationVC = destinationNC.topViewController as! DrinkViewController
        destinationVC.dashboardVC = self
    }
    
    // Creates ring progress view
    func setupRingProgressView() {
        ringProgressView.startColor = UIColor(named: "Green")!
        ringProgressView.endColor = UIColor(named: "Red")!
        ringProgressView.ringWidth = 25
        ringProgressView.progress = getProgress()
        ringView.addSubview(ringProgressView)
    }
    
    // Gets the current percentage of the allowed daily caffeine amount that the user has logged in
    func getProgress() -> Double {
        let consumedCaffeine = metabolismCalculator.calculateTotalAmount()
        return Double(consumedCaffeine) / 400.0
    }
    
    // Updates the ring progress view
    func updateProgressView() {
        UIView.animate(withDuration: 0.5) {
            self.ringProgressView.progress = self.getProgress()
        }
    }
    
    func updateInfo() {
        let dailyAmount = metabolismCalculator.calculateTotalAmount()
        
        dailyAmountLabel.text = "\(dailyAmount)/400 mg"
        drinkNumberLabel.text = String(metabolismCalculator.getNumberOfDrinks())
        metabolismAmountLabel.text = "\(metabolismCalculator.calculateMetabolismAmount()) mg"
        
        // Change color if caffeine consumpton too high
        if dailyAmount > 400 {
            dailyAmountLabel.textColor = UIColor(named: "Red")
            // TODO: Change color
        }
    }
    
    // MARK: - Core Data methods
    
    func saveConsumedDrinks() {
        do {
            try self.context.save()
        } catch {
            print("Error while saving context")
        }
    }
    
    func loadConsumedDrinks() {
        do {
            consumedDrinksArray = try context.fetch(ConsumedDrink.fetchRequest())
        } catch {
            print("Error while loading data")
        }
        tableView.reloadData()
    }
    
    func getDailyTotal() -> Int {
        return metabolismCalculator.calculateTotalAmount()
    }
    
    func getDailyDrinks() -> Int {
        return metabolismCalculator.getNumberOfDrinks()
    }
}

// MARK: - Table View methods

extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return consumedDrinksArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.consumedDrinkCellIdentifier, for: indexPath) as! ConsumedDrinkCell
        cell.delegate = self
        let consumedDrink = consumedDrinksArray[indexPath.row]
        cell.title.text = consumedDrink.name
        cell.icon.image = UIImage(named: consumedDrink.icon!)
        cell.detail.text = "\(consumedDrink.caffeine) mg"
        return cell
    }
    
    func imageWithImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(x: 0 ,y: 0 ,width: newSize.width ,height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!.withRenderingMode(.alwaysOriginal)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}

// MARK: - Swipe Table View methods

extension DashboardViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeCellKit.SwipeActionsOrientation) -> [SwipeCellKit.SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.loadConsumedDrinks()
            self.context.delete(self.consumedDrinksArray[indexPath.row])
            self.consumedDrinksArray.remove(at: indexPath.row)
            self.saveConsumedDrinks()
            self.updateInfo()
            self.updateProgressView()
            self.updateConstraints()
            tableView.reloadData()
            self.updateConstraints()
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
}
