//
//  K.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 29.12.22.
//

import Foundation

struct K {
    struct UI {
        static let settingCellHeight: CGFloat = 55.0
        static let consumedDrinkCellHeight: CGFloat = 44.0
        static let drinkCellHeight: CGFloat = 70.0
        static let cornerRadius = 15.0
    }
    
    struct ID {
        struct segues {
            static let dashboardToDrinks = "dashboardToDrinks"
            static let dashboardToRecord = "dashboardToDrink"
            static let drinksToAdd = "drinksToAdd"
            static let drinksToAdjust = "drinksToAmount"
        }
        static let nameCell = "DrinkNameCell"
        static let iconCell =  "IconCell"
        static let numberCell = "NumberCell"
        static let dateCell = "DateCell"
        
        static let consumedDrinkCell = "ConsumedDrinkCell"
        static let caffeineCell = "CaffeineCell"
        static let switchCell = "SettingsCell"
        static let settingCell = "RegularSettingsCell"
        static let detailSettingCell = "VersionSettingsCell"
        
        static let notification = "aboveLimitNotification"
    }
    
    struct defaults {
        static let order: String = "orderByCaffeine"
        static let dailyAmount = "dailyAmount"
        static let metablosimAmount = "metabolismAmount"
        static let numberOfDrinks = "numberOfDrinks"
        static let lastRefreshed = "lastRefreshed"
        static let amountNotificationSent = "amountNotificationSent"
        static let notificationPermission = "notificationPermission"
        static let dailyLimit = "dailyLimit"
        static let firstRun = "firstRun"
    }
    
    struct constants {
        static let numberOfFrequentlyConsumedDrinks: Int = 3
    }
    
    struct icons {
        static let hotCoffe = "hot-coffee.png"
        static let espresso = "espresso.png"
        static let coldCoffe = "cold-coffee.png"
        static let cannedCoffe = "canned-coffee.png"
        static let energyDrink = "energy-drink.png"
        static let energyShot = "energy-shot.png"
        static let softDrink = "soft-drink.png"
        static let tea = "tea.png"
        static let icedTea = "iced-tea.png"
        static let supplement = "supplement.png"
        static let water = "water.png"
    }
    
    struct data {
        static let drinkTypes: [String] = ["Espresso", "Hot Coffee", "Cold Coffee", "Canned Coffee", "Soft Drink", "Energy Drink", "Energy Shot", "Chocolate", "Supplement", "Tea", "Iced Tea", "Water"]
    }
}
