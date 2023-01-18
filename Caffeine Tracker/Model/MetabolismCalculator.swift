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
    let dateFormatter = DateFormatter()

    
    // Amount of caffeine left after 1 hour of consumption (5 hour half-life)
    let oneHourDecline = 0.87
    let secondsInHour = 3600
    
    // Returns the amount of caffeine in the metabolism right now
    mutating func calculateMetabolismAmount() -> Int {
        loadConsumedDrinks()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        var metabolismAmount = 0
        
        for i in 0..<consumedDrinksArray.count {
            let consumedDrink = consumedDrinksArray[i]
            var amountFromDrink = Double(consumedDrink.caffeine)
            let now = Date.now
            let consumptionTime = consumedDrink.timeConsumed!
            let differenceInSeconds = now.timeIntervalSince1970 - consumptionTime.timeIntervalSince1970
            let differneceInHours = Int(differenceInSeconds) / secondsInHour
            
            // Remove drinks consumed on previous days and drinks with very little caffeine content
            if amountFromDrink < 10.0 && (dateFormatter.string(from: now) != dateFormatter.string(from: consumptionTime)) {
                self.context.delete(consumedDrink)
                self.consumedDrinksArray.remove(at: i)
                self.saveConsumedDrinks()
            }
            
            // Decrease amount each hour
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
        dateFormatter.dateFormat = "MM-dd-yyyy"
        var totalAmount = 0
        
        for consumedDrink in consumedDrinksArray {
            let today = Date.now
            let dateConsumed = consumedDrink.timeConsumed!
            
            if dateFormatter.string(from: today) == dateFormatter.string(from: dateConsumed) {
                let amountFromDrink = Double(consumedDrink.caffeine)
                totalAmount += Int(amountFromDrink)
            }
        }
        return totalAmount
    }
    
    // Returns total amount of drinks consumed today
    mutating func getNumberOfDrinks() -> Int {
        loadConsumedDrinks()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        var totalDrinks = 0
        
        for consumedDrink in consumedDrinksArray {
            let today = Date.now
            let dateConsumed = consumedDrink.timeConsumed!
            
            if dateFormatter.string(from: today) == dateFormatter.string(from: dateConsumed) {
                totalDrinks += 1
            }
        }
        
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
