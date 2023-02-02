//
//  metabolismCalculator.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 9.1.23.
//

import UIKit

struct MetabolismCalculator {
    
    var consumedDrinksArray = [ConsumedDrink]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let dateFormatter = DateFormatter()
    var databaseManager = DataBaseManager()
    
    // Amount of caffeine left after 1 hour of consumption (5 hour half-life)
    let oneHourDecline = 0.87
    let secondsInHour = 3600
    
    // Returns the amount of caffeine in the metabolism right now
    mutating func calculateMetabolismAmount() -> Int {
        print("calculateMetabolismAmount() called")
        consumedDrinksArray = databaseManager.getTodayDrinks()
        print(consumedDrinksArray)
        databaseManager.updateMetabolismAmounts()
        var metabolismAmount = 0
        
        for consumeDrink in consumedDrinksArray {
            print("Adding: \(consumeDrink.caffeine)")
            metabolismAmount += Int(consumeDrink.caffeine)
        }
        
        print("Returing: \(metabolismAmount)")
        return metabolismAmount
    }
    
    // Returns total amount consumed in a day
    mutating func calculateTotalAmount() -> Int {
        consumedDrinksArray = databaseManager.getTodayDrinks()
        var totalAmount = 0
        
        for consumedDrink in consumedDrinksArray {
            totalAmount += Int(consumedDrink.initialAmount)
        }
        return totalAmount
    }
    
    // Returns total amount of drinks consumed today
    mutating func getNumberOfDrinks() -> Int {
        return databaseManager.getTodayDrinks().count
    }
}
