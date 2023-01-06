//
//  ViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 29.12.22.
//

import UIKit
import MKRingProgressView

class DashboardViewController: UIViewController {

    @IBOutlet weak var dailyIntakeView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var currentAmluntView: UIView!
    @IBOutlet weak var drinkButton: UIButton!
    @IBOutlet weak var dailyAmountLabel: UILabel!
    @IBOutlet weak var drinkNumberLabel: UILabel!
    @IBOutlet weak var metabolismAmountLabel: UILabel!
    @IBOutlet weak var ringView: UIView!
    let ringProgressView = RingProgressView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize scroll view
        scrollView.showsVerticalScrollIndicator = false
        
        
        // Customize navigation bar
        tabBarController?.navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.navigationController?.navigationBar.isTranslucent = true
        
        // Customize views
        dailyIntakeView.layer.cornerRadius = 15.0
        currentAmluntView.layer.cornerRadius = 15.0
        drinkButton.layer.cornerRadius = 15.0
        
        setupRingProgressView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateInfo()
        updateProgressView()
    }

    @IBAction func drinkButtonPressed(_ sender: UIButton) {
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
        let consumedCaffeine = defaults.integer(forKey: K.dailyAmount)
        return Double(consumedCaffeine) / 400.0
    }
    
    // Updates the ring progress view
    func updateProgressView() {
        UIView.animate(withDuration: 0.5) {
            self.ringProgressView.progress = self.getProgress()
        }
    }
    
    func updateInfo() {
        let dailyAmount = defaults.integer(forKey: K.dailyAmount)
        
        dailyAmountLabel.text = "\(dailyAmount)/400 MG"
        drinkNumberLabel.text = String(defaults.integer(forKey: K.numberOfDrinks))
        metabolismAmountLabel.text = "\(defaults.integer(forKey: K.metablosimAmount)) MG"
        
        // Change color if caffeine consumpton too high
        if dailyAmount > 400 {
            dailyAmountLabel.textColor = UIColor(named: "Red")
            // TODO: Change color
        }
    }
}

