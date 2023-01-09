//
//  metabolismCalculator.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 9.1.23.
//

import Foundation

struct MetabolismCalculator {
    
    
    let defaults = UserDefaults.standard
    var consumedDrinksArray = [ConsumedDrink]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
}
