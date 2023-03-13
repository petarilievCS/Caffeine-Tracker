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
    var drinksArray: [Drink] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Adds default drinks to CoreData
    mutating func addDefaultDrinks() {
        var drinks: [DefaultDrink] = []
        loadDrinks()
        if let url = Bundle.main.url(forResource: "caffeine", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                drinks = try decoder.decode([DefaultDrink].self, from: data)
                for drink in drinks {
                    let defaultDrink = Drink(context: self.context)
                    defaultDrink.name = drink.drink
                    defaultDrink.icon = getIcon(for: drink.type)
                    defaultDrink.caffeine = Int64(drink.caffeine)
                    defaultDrink.serving = Int64(drink.volume * 0.033814)
                    defaultDrink.caffeineOz = Double(defaultDrink.caffeine) / Double(defaultDrink.serving)
                    drinksArray.append(defaultDrink)
                }
                
                saveDrinks()
            } catch {
                print("error:\(error)")
            }
        }
    }
    
    // Returns icon name for given drink type
    func getIcon(for drink: String) -> String {
        switch drink {
        case "Coffee":
            return "hot-coffee.png"
        case "Bottle":
            return "canned-coffee.png"
        case "Coffee Can":
            return "canned-coffee.png"
        case "Esspresso":
            return "espresso.png"
        case "Ice":
            return "cold-coffee.png"
        case "Energy Drinks":
            return "energy-drink.png"
        case "Energy Shots":
            return "energy-shot.png"
        case "Tea":
            return "tea.png"
        case "Ice Tea":
            return "iced-tea.png"
        case "Soft Drinks":
            return "soft-drink.png"
        case "Water":
            return "water.png"
        default:
            return ""
        }
    }
    
    // Loads caffeine drinks from CoreData
    mutating func loadDrinks(with request: NSFetchRequest<Drink> = Drink.fetchRequest(), and predicate: NSPredicate? = nil) {
        request.predicate = predicate
        do {
            drinksArray = try context.fetch(request)
        } catch {
            print("Error while loading data")
        }
    }
    
    // Saves given drinks to CoreData
    func saveDrinks() {
        do {
            try context.save()
        } catch {
            print("Error saving: \(error)")
        }
    }
    
    // Returns amounts of caffeine for each drink type in the past week
    mutating func getDrinkTypeAmounts() -> [Double] {
        clearDrinks()
        loadConsumedDrinks()
        var values: [Double] = Array(repeating: 0.0, count: 6)
        for consumedDrink in consumedDrinksArray {
            switch consumedDrink.icon {
            case "hot-coffee.png":
                values[0] += Double(consumedDrink.initialAmount)
            case "espresso.png":
                values[0] += Double(consumedDrink.initialAmount)
            case "cold-coffee.png":
                values[0] += Double(consumedDrink.initialAmount)
            case "canned-coffee.png":
                values[0] += Double(consumedDrink.initialAmount)
            case "energy-drink.png":
                values[1] += Double(consumedDrink.initialAmount)
            case "energy-shot.png":
                values[1] += Double(consumedDrink.initialAmount)
            case "soft-drink.png":
                values[2] += Double(consumedDrink.initialAmount)
            case "tea.png":
                values[3] += Double(consumedDrink.initialAmount)
            case "iced-tea.png":
                values[3] += Double(consumedDrink.initialAmount)
            case "supplement.png":
                values[4] += Double(consumedDrink.initialAmount)
            default:
                values[5] += Double(consumedDrink.initialAmount)
            }
        }
        return values
    }
    
    // Updates given record with given properties
    mutating func updateRecord(_ record: ConsumedDrink, name: String, type: String, amount: Int64, time: Date) {
        loadConsumedDrinks()
        for i in 0..<consumedDrinksArray.count {
            if consumedDrinksArray[i].id == record.id {
                consumedDrinksArray[i].name = name
                consumedDrinksArray[i].icon = type
                consumedDrinksArray[i].initialAmount = amount
                consumedDrinksArray[i].timeConsumed = time
                updateMetabolismAmounts()
                break
            }
        }
    }
    
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
        return Double(getWeeklyTotal() * 1000.0) / 7.0
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
            let amount: Int64 = consumedDrink.initialAmount
            let now: Date = .now
            let consumptionTime: Date = consumedDrink.timeConsumed!
            
            let differenceInSeconds: Double = now.timeIntervalSince1970 - consumptionTime.timeIntervalSince1970
            let differenceInHours: Int = Int(differenceInSeconds) / secondsPerHour
            
            // Update amount for each hour of difference
            if differenceInHours > 0 {
                let newAmount: Int64 = Int64(Double(amount) * pow(declinePerHour, Double(differenceInHours)))
                if newAmount < Int64.max {
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
    
    // Returns the day of the week for x days ago
    func dayOfTheWeek(for x: Int) -> String {
        let today: Date = .now
        let calendar: Calendar = Calendar.current
        let dateToReturn: Date = calendar.date(byAdding: .day, value: -x, to: today)!
        let formatter = DateFormatter()
        let weekdayName = formatter.weekdaySymbols[calendar.component(.weekday, from: dateToReturn) - 1]
        let symbol = weekdayName.dropLast(weekdayName.count - 3)
        return String(symbol)
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
    
    // Removes given drink
    mutating func removeDrink(_ drink: ConsumedDrink) {
        loadConsumedDrinks()
        self.context.delete(drink)
    }
    
    // Returns top 3 drinks over the past week
    mutating func getTopDrinks() -> [(String, Int)] {
        loadConsumedDrinks()
        var counter: [String : Int] = [String : Int]()
        
        for consumedDrink in consumedDrinksArray {
            if !(counter.keys.contains(consumedDrink.name!)) {
                counter[consumedDrink.name!] = 9
            }
            counter[consumedDrink.name!]! += 1
        }
        
        var drinks: [(String, Int)] = [(String, Int)]()
        for drink in counter {
            drinks.append(drink)
        }
        
        // Sort drinks by number of records
        drinks = drinks.sorted(by: { drink1, drink2 in
            return drink1.1 < drink2.1
            
        })
        
        if drinks.count < 3 {
            return drinks
        }
        drinks = drinks.dropLast(drinks.count - 3)
        return drinks
    }
    
}

// Entry in chart
struct ChartEntry: Identifiable {
    var day: String
    var caffeineAmount: Int
    var id = UUID()
}
