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

    

}

