//
//  ViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 29.12.22.
//

import UIKit

class DashboardViewController: UIViewController {

    @IBOutlet weak var dailyIntakeView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var currentAmluntView: UIView!
    @IBOutlet weak var drinkButton: UIButton!
    @IBOutlet weak var dailyAmountLabel: UILabel!
    @IBOutlet weak var drinkNumberLabel: UILabel!
    @IBOutlet weak var metabolismAmountLabel: UILabel!
    @IBOutlet weak var circleView: UIImageView!
    
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateInfo()
    }

    @IBAction func drinkButtonPressed(_ sender: UIButton) {
    
    }
    
    func updateInfo() {
        let dailyAmount = defaults.integer(forKey: K.dailyAmount)
        
        dailyAmountLabel.text = "\(dailyAmount)/400 MG"
        drinkNumberLabel.text = String(defaults.integer(forKey: K.numberOfDrinks))
        metabolismAmountLabel.text = "\(defaults.integer(forKey: K.metablosimAmount)) MG"
        
        // Change color if caffeine consumpton too high
        if dailyAmount > 400 {
            dailyAmountLabel.textColor = UIColor(named: "Red")
            circleView.tintColor = UIColor(named: "Red")
        }
    }
}

