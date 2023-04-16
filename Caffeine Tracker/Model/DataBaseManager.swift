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
    private let secondsPerHour: Int = 3600
    private let declinePerHour: Double = 0.87
    private var consumedDrinksArray: [ConsumedDrink] = []
    private var drinksArray: [Drink] = []
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
}

// MARK: - Drink methods
extension DataBaseManager {
    // Returns Drinks from CoreData
    mutating func getDrinks(with request: NSFetchRequest<Drink> = Drink.fetchRequest(), and predicate: NSPredicate? = nil) -> [Drink] {
        loadDrinks(with: request, and: predicate)
        return drinksArray
    }
    
    // Returns the Drink objects for the 5 most frequently consumed drinks in the past month
    mutating func getFrequentlyConsumedDrinks() -> [Drink] {
        let topDrinks: [(ConsumedDrink, Int)] = getTopDrinks(5, for: .month, false)
        var result: [Drink] = []
        for drink in topDrinks {
            if let parent = drink.0.parent {
                result.append(parent)
            }
        }
        return result.sorted(by: { first, second in
            return first.name!.capitalized < second.name!.capitalized
        })
    }
    
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
    
    // Adds Drink with given data to CoreData
    mutating func addDrink(name: String, icon: String, caffeine: Int64, serving: Int64, caffeineOz: Double) {
        loadDrinks()
        let newDrink = Drink(context: self.context)
        newDrink.name = name
        newDrink.icon = icon
        newDrink.caffeine = caffeine
        newDrink.serving = serving
        newDrink.caffeineOz = caffeineOz
        drinksArray.append(newDrink)
        saveDrinks()
    }
    
    // Edits given Drink with given data
    mutating func editDrink(_ drink: Drink, name: String? = nil, icon: String? = nil, caffeine: Int64? = nil, serving: Int64? = nil, caffeineOz: Double? = nil) {
        drink.name = name
        drink.icon = icon
        drink.caffeine = caffeine ?? 0
        drink.serving = serving ?? 0
        drink.caffeineOz = caffeineOz ?? 0.0
        saveDrinks()
    }
    
    // Removes given Drink from CoreData
    mutating func removeDrinnk(_ drink: Drink) {
        loadDrinks()
        context.delete(drink)
        drinksArray.remove(at: drinksArray.firstIndex(of: drink)!)
        saveDrinks()
    }
}

// MARK: - ConsumedDrink methods
extension DataBaseManager {
    // Returns drinks for the past month/week
    mutating func loadDrinksInLast(_ period: Period) {
        var periodComponent: Calendar.Component
        var periodValue = 0
        switch period {
        case .month:
            periodComponent = .month
            periodValue = -1
        case .week:
            periodComponent = .day
            periodValue = -7
        }
        
        let fromDate = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: periodComponent, value: periodValue, to: .now)!)
        let toPredicate = NSPredicate(format: "%@ >= %K", Date.now as NSDate, #keyPath(ConsumedDrink.timeConsumed))
        let fromPredicate = NSPredicate(format: "%@ <= %K", fromDate as NSDate, #keyPath(ConsumedDrink.timeConsumed))
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [toPredicate, fromPredicate])
        loadConsumedDrinks(with: compoundPredicate)
    }
    
    // Returns drinks for the past month/week
    mutating func getDrinksInLast(_ period: Period) -> [ConsumedDrink] {
        loadDrinksInLast(period)
        return consumedDrinksArray
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
                saveConsumedDrinks()
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
    mutating func getAverage(for period: Period) -> Double {
        return Double(getTotal(for: period) * 1000.0) / 7.0
    }
    
    // Returns total amount of caffeine taken in the past 7 days
    mutating func getTotal(for period: Period) -> Double {
        loadDrinksInLast(period)
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
            } else {
                consumedDrink.caffeine = Int64(amount)
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
    
    // Returns top 3 drinks over the past week
    mutating func getTopDrinks(_ number: Int, for period: Period, _ orderByAmount: Bool) -> [(ConsumedDrink, Int)] {
        loadDrinksInLast(period)
        var counter: [String : Int] = [String : Int]()
        
        for consumedDrink in consumedDrinksArray {
            if !(counter.keys.contains(consumedDrink.name!)) {
                counter[consumedDrink.name!] = 0
            }
            counter[consumedDrink.name!]! += orderByAmount ? Int(consumedDrink.initialAmount) : 1
        }
        
        var drinks: [(String, Int)] = [(String, Int)]()
        for drink in counter {
            drinks.append(drink)
        }
        
        // Sort drinks by number of records
        drinks = drinks.sorted(by: { drink1, drink2 in
            if drink1.1 > drink2.1 {
                return true
            }
            if drink2.1 > drink1.1 {
                return false
            }
            return drink1.0.capitalized < drink2.0.capitalized
        })
        
        if drinks.count < number {
            return drinks.map { (name, count) in
                return (getDrinkByName(name), count)
            }
        }
        drinks = drinks.dropLast(drinks.count - number)
        return drinks.map { (name, count) in
            return (getDrinkByName(name), count)
        }
    }
    
    // Adds ConsumedDrink to CoreData
    mutating func addConsumedDrink(with caffeineAmount: Int, and parent: Drink) {
        loadConsumedDrinks()
        var consumedDrink = ConsumedDrink(context: self.context)
        consumedDrink.parent = parent
        consumedDrink.name = parent.name
        consumedDrink.icon = parent.icon
        consumedDrink.caffeine = Int64(caffeineAmount)
        consumedDrink.initialAmount = Int64(caffeineAmount)
        consumedDrink.timeConsumed = Date.now
        consumedDrinksArray.append(consumedDrink)
        saveConsumedDrinks()
    }
    
}

// MARK: - CoreData methods
extension DataBaseManager {
    // Loads caffeine drinks from CoreData
    mutating func loadDrinks(with request: NSFetchRequest<Drink> = Drink.fetchRequest(), and predicate: NSPredicate? = nil) {
        request.predicate = predicate
        do {
            drinksArray = try context.fetch(request)
        } catch {
            print("Error while loading data")
        }
        drinksArray = drinksArray.sorted { first, second in
            return first.name!.capitalized < second.name!.capitalized
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
    
    // Load all consumed drinks
    mutating func loadConsumedDrinks(with predicate: NSCompoundPredicate = NSCompoundPredicate()) {
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
    mutating func removeRecord(_ consumedDrink: ConsumedDrink) {
        self.context.delete(consumedDrink)
        saveConsumedDrinks()
    }
    
    // Returns consumed drink object for given name
    mutating func getDrinkByName(_ name: String) -> ConsumedDrink {
        loadConsumedDrinks()
        for consumedDrink in consumedDrinksArray {
            if consumedDrink.name == name {
                return consumedDrink
            }
        }
        return consumedDrinksArray[0]
    }
    
    // Returns an array of size 30, where each entry is the caffeine amount consumed i days ago
    mutating func getAmountsInLast(_ period: Period) -> Array<Int> {
        loadDrinksInLast(period)
        var periodLength = 0
        
        switch period {
        case .week:
            periodLength = 6
        case .month:
            periodLength = 29
        }
        
        var amounts: Array<Int> = Array(repeating: 0, count: periodLength + 1)
        var days: [Date] = []
        for i in 0...periodLength {
            let iDaysAgo = Calendar.current.date(byAdding: .day, value: -i, to: .now)
            days.append(iDaysAgo!)
        }
        for consumedDrink in consumedDrinksArray {
            for i in 0..<days.count {
                if Calendar.current.isDate(consumedDrink.timeConsumed!, inSameDayAs: days[i]) {
                    amounts[i] += Int(consumedDrink.initialAmount)
                }
            }
        }
        return amounts
    }
}

// MARK: - Helper methods
extension DataBaseManager {
    // Returns icon name for given drink type
    func getIcon(for drink: String) -> String {
        switch drink {
        case "Coffee":
            return K.icons.hotCoffe
        case "Bottle":
            return K.icons.cannedCoffe
        case "Coffee Can":
            return K.icons.cannedCoffe
        case "Esspresso":
            return K.icons.espresso
        case "Ice":
            return K.icons.coldCoffe
        case "Energy Drinks":
            return K.icons.energyDrink
        case "Energy Shots":
            return K.icons.energyShot
        case "Tea":
            return K.icons.tea
        case "Ice Tea":
            return K.icons.icedTea
        case "Soft Drinks":
            return K.icons.softDrink
        case "Water":
            return K.icons.water
        default:
            return ""
        }
    }
    
    // Returns amounts of caffeine for each drink type in the past week
    mutating func getDrinkTypeAmounts(in period: Period) -> [Double] {
        loadDrinksInLast(period)
        var values: [Double] = Array(repeating: 0.0, count: 6)
        for consumedDrink in consumedDrinksArray {
            switch consumedDrink.icon {
            case K.icons.hotCoffe:
                values[0] += Double(consumedDrink.initialAmount)
            case K.icons.espresso:
                values[0] += Double(consumedDrink.initialAmount)
            case K.icons.coldCoffe:
                values[0] += Double(consumedDrink.initialAmount)
            case K.icons.cannedCoffe:
                values[0] += Double(consumedDrink.initialAmount)
            case K.icons.energyDrink:
                values[1] += Double(consumedDrink.initialAmount)
            case K.icons.energyShot:
                values[1] += Double(consumedDrink.initialAmount)
            case K.icons.softDrink:
                values[2] += Double(consumedDrink.initialAmount)
            case K.icons.tea:
                values[3] += Double(consumedDrink.initialAmount)
            case K.icons.icedTea:
                values[3] += Double(consumedDrink.initialAmount)
            case K.icons.supplement:
                values[4] += Double(consumedDrink.initialAmount)
            default:
                values[5] += Double(consumedDrink.initialAmount)
            }
        }
        return values
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
    
    // Returns the day of the month x days ago
    func getDayLabel(daysAgo: Int) -> String {
        let date = Calendar.current.date(byAdding: .day, value: -(29 - daysAgo), to: .now)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let day = formatter.string(from: date!)
        return day
    }
}

// Entry in chart
struct ChartEntry: Identifiable {
    var day: String
    var caffeineAmount: Int
    var id = UUID()
}
