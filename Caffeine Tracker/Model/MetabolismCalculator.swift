//
//  metabolismCalculator.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 9.1.23.
//

import UIKit

struct MetabolismCalculator {
    
    let defaults = UserDefaults.standard
    var consumedDrinksArray = [ConsumedDrink]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Amount of caffeine left after 1 hour of consumption (5 hour half-life)
    let oneHourDecline = 0.87
    let secondsInHour = 3600
    
    // Returns the amount of caffeine in the metabolism right now
    mutating func calculateMetabolismAmount() -> Int {
        loadConsumedDrinks()
        var metabolismAmount = 0
        
        for consumedDrink in consumedDrinksArray {
            var amountFromDrink = Double(consumedDrink.caffeine)
            let now = Date.now
            let consumptionTime = consumedDrink.timeConsumed!
            let differenceInSeconds = now.timeIntervalSince1970 - consumptionTime.timeIntervalSince1970
            let differneceInHours = Int(differenceInSeconds) / secondsInHour
            
            // decrease amount each hour
            for _ in 0..<differneceInHours {
                amountFromDrink *= oneHourDecline
            }
            metabolismAmount += Int(amountFromDrink)
        }
        
        return metabolismAmount
    }
    
    // Returns total amount consumed in a day
    mutating func calculateTotalAmount() -> Int {
        loadConsumedDrinks()
        var totalAmount = 0
        
        for consumedDrink in consumedDrinksArray {
            var amountFromDrink = Double(consumedDrink.caffeine)
            totalAmount += Int(amountFromDrink)
        }
        return totalAmount
    }
    
    // Returns total amount of drinks consumed today
    mutating func getNumberOfDrinks() -> Int {
        loadConsumedDrinks()
        return consumedDrinksArray.count
    }
    
    // MARK: - Core Data methods
    
    func saveConsumedDrinks() {
        do {
            try self.context.save()
        } catch {
            print("Error while saving context")
        }
    }
    
    mutating func loadConsumedDrinks() {
        do {
            consumedDrinksArray = try context.fetch(ConsumedDrink.fetchRequest())
        } catch {
            print("Error while loading data")
        }
    }
    
}
