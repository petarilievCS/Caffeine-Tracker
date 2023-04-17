//
//  metabolismCalculator.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 9.1.23.
//

import UIKit

struct MetabolismCalculator {
    private var consumedDrinksArray = [ConsumedDrink]()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let dateFormatter = DateFormatter()
    private var db = DataBaseManager()
    
    // Amount of caffeine left after 1 hour of consumption (5 hour half-life)
    private let oneHourDecline = 0.87
    private let secondsInHour = 3600
    
    // Returns the amount of caffeine in the metabolism right now
    mutating func calculateMetabolismAmount() -> Int {
        db.updateMetabolismAmounts()
        consumedDrinksArray = db.getTodayDrinks()
        var metabolismAmount = 0
        for consumeDrink in consumedDrinksArray {
            metabolismAmount += Int(consumeDrink.caffeine)
        }
        return metabolismAmount
    }
    
    // Returns total amount consumed in a day
    mutating func calculateTotalAmount() -> Int {
        consumedDrinksArray = db.getTodayDrinks()
        var totalAmount = 0
        for consumedDrink in consumedDrinksArray {
            totalAmount += Int(consumedDrink.initialAmount)
        }
        return totalAmount
    }
    
    // Returns total amount of drinks consumed today
    mutating func getNumberOfDrinks() -> Int {
        return db.getTodayDrinks().count
    }
}
