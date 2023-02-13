//
//  K.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 29.12.22.
//

import Foundation

struct K {
    
    // Identifiers
    static let caffeineCellIdentifier = "CaffeineCell"
    static let addDrinkCellIdentifier = "AddDrinkCell"
    static let drinkNameCellIdentifier = "DrinkNameCell"
    static let iconCellIdentifier = "IconCell"
    static let numberCellIdentifier = "NumberCell"
    static let drinksToAddSegue = "drinksToAdd"
    static let drinksToAmountSegue = "drinksToAmount"
    static let dashboardToDrinksSegue = "dashboardToDrinks"
    static let consumedDrinkCellIdentifier = "ConsumedDrinkCell"
    static let aboveLimitNotifiicationIdentifier = "aboveLimitNotification"
    static let settingsCellIdentifier = "SettingsCell"
    static let regularSettingsCellIdentifier = "RegularSettingsCell"
    
    // UserDefaults names
    static let dailyAmount = "dailyAmount"
    static let metablosimAmount = "metabolismAmount"
    static let numberOfDrinks = "numberOfDrinks"
    static let lastRefreshed = "lastRefreshed"
    static let amountNotificationSent = "amountNotificationSent"
    static let notificationPermission = "notificationPermission"
    static let dailyLimit = "dailyLimit"
    
    // UI constants
    static let defaultCornerRadius = 15.0
}
