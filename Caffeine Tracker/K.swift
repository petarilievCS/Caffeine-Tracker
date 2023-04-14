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
    }
    
    struct ID {
        struct segues {
            static let dashboardToDrinks = "dashboardToDrinks"
            static let dashboardToRecord = "dashboardToDrink"
            static let drinksToAdd = "drinksToAdd"
        }
        static let caffeineCell = "CaffeineCell"
        static let switchCell = "SettingsCell"
        static let settingCell = "RegularSettingsCell"
        static let detailSettingCell = "VersionSettingsCell"
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
    
    struct segues {
        
    }
    
    // Identifiers
    
    static let addDrinkCellIdentifier = "AddDrinkCell"
    static let drinkNameCellIdentifier = "DrinkNameCell"
    static let iconCellIdentifier = "IconCell"
    static let numberCellIdentifier = "NumberCell"
    static let drinksToAmountSegue = "drinksToAmount"
    static let consumedDrinkCellIdentifier = "ConsumedDrinkCell"
    static let aboveLimitNotifiicationIdentifier = "aboveLimitNotification"
    static let drinkTypePopoverSegueIdentifier = "drinkTypePopoverSegue"
    static let drinkTypePopoverIdentifier = "DrinkTypePopover"
    static let dateCellIdentifier = "DateCell"
    static let locationCellIdentifier = "LocationCell"
    
    // UI constants
    static let defaultCornerRadius = 15.0
}
