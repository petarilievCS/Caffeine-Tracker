//
//  DataBaseManager.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 1.2.23.
//

import CoreData
import UIKit
import Foundation

struct DataBaseManager {
    
    let secondsPerHour: Int = 3600
    let declinePerHour: Double = 0.87
    
    var consumedDrinksArray: [ConsumedDrink] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Returns the amount "days" ago
    mutating func getAmountDaysAgo(_ days: Int) -> Int {
        loadConsumedDrinks()
        let current: Date = .now
        let calendar: Calendar = Calendar.current
        let daysAgo: Date = calendar.date(byAdding: .day, value: -days, to: current)!
        var result: Int = 0
        
        for consumedDrink in consumedDrinksArray {
            if calendar.isDate(consumedDrink.timeConsumed!, inSameDayAs: daysAgo) {
                result += Int(consumedDrink.initialAmount)
            }
        }
        return result
    }
    
    //  Returns average caffeine intake in the past 7 days
    mutating func getWeekAverage() -> Double {
        return Double(getTotalAmount()) / 7.0
    }
    
    // Returns total amount of caffeine taken in the past 7 days
    mutating func getWeeklyTotal() -> Double {
        clearDrinks()
        loadConsumedDrinks()
        var totalAmount: Double = 0.0
        for consumedDrink in consumedDrinksArray {
            totalAmount += Double(consumedDrink.initialAmount)
        }
        return totalAmount / 1000.0
    }
    
    // Returns total number of drinks consumed today
    mutating func getNumberOfDrinks() -> Int {
        return getTodayDrinks().count
    }
    
    // Returns total amount of caffeine consumed today
    mutating func getTotalAmount() -> Int {
        var totalAmount: Int = 0
        for consumeDrink in getTodayDrinks() {
            totalAmount += Int(consumeDrink.initialAmount)
        }
        return totalAmount
    }
    
    // Returns total amount in metabolism right now
    mutating func getMetabolismAmount() -> Int {
        var metabolismAmount: Int = 0
        updateMetabolismAmounts()
        for consumedDrink in consumedDrinksArray {
            metabolismAmount += Int(consumedDrink.caffeine)
        }
        return metabolismAmount
    }
    
    // Update amount of caffeine in metabolism
    mutating func updateMetabolismAmounts() {
        loadConsumedDrinks()
        
        for i in 0..<consumedDrinksArray.count {
            let consumedDrink: ConsumedDrink = consumedDrinksArray[i]
            let amount: Double = Double(consumedDrink.caffeine)
            let now: Date = .now
            let consumptionTime: Date = consumedDrink.timeConsumed!
            
            let differenceInSeconds: Double = now.timeIntervalSince1970 - consumptionTime.timeIntervalSince1970
            let differenceInHours: Int = Int(differenceInSeconds) / secondsPerHour
            print("difference in hours: \(differenceInHours)")
            // Update amount for each hour of difference
            if differenceInHours > 0 {
                let newAmount: Double = amount * (declinePerHour * Double(differenceInHours))
                print(newAmount)
                if newAmount < Double(Int64.max) {
                    consumedDrink.caffeine = Int64(newAmount)
                }
                
            }
        }
        saveConsumedDrinks()
    }
    
    // Gets all drinks from today and drinks that have more than 10 mg of caffeine left in metabolism
    mutating func getEffectiveDrinks() -> [ConsumedDrink] {
        var result: [ConsumedDrink] = []
        result = getTodayDrinks()
        
        for consumedDrink in result {
            if consumedDrink.caffeine < 10 {
                let idx = result.firstIndex(of: consumedDrink)!
                result.remove(at: idx)
            }
        }
        
        return result
    }
    
    // Returns all drinks consumed within today
    mutating func getTodayDrinks() -> [ConsumedDrink] {
        var result: [ConsumedDrink] = []
        let calendar = Calendar.current
        loadConsumedDrinks()
        for consumedDrink in consumedDrinksArray {
            if calendar.isDateInToday(consumedDrink.timeConsumed!) {
                result.append(consumedDrink)
            }
        }
        return result
    }
    
    // Removes all drinks in the array that have been added more than a week ago
    mutating func clearDrinks() {
        loadConsumedDrinks()
        
        for consumedDrink in consumedDrinksArray {
            if !isDateInPastWeek(consumedDrink.timeConsumed!) {
                context.delete(consumedDrink)
                let idx = consumedDrinksArray.firstIndex(of: consumedDrink)!
                consumedDrinksArray.remove(at: idx)
            }
        }
    }
    
    // Returns true if date is within past 7 days, false otherwise
    func isDateInPastWeek(_ date: Date) -> Bool {
        let current: Date = .now
        let calendar: Calendar = Calendar.current
        
        if calendar.isDateInToday(date) || calendar.isDateInYesterday(date) {
            return true
        }
        
        for i in 2...6 {
            let iDaysAgo: Date = calendar.date(byAdding: .day, value: -i, to: current)!
            if calendar.isDate(date, inSameDayAs: iDaysAgo) {
                return true
            }
        }
        return false
    }
    
    // MARK: - CoreData methods
    
    // Load all consumed drinks
    mutating func loadConsumedDrinks() {
        do {
            consumedDrinksArray = try context.fetch(ConsumedDrink.fetchRequest())
        } catch {
            print("Error while loading data")
        }
    }
    
    // Save current context
    mutating func saveConsumedDrinks() {
        do {
            try self.context.save()
        } catch {
            print("Error while saving context")
        }
    }
    
}
