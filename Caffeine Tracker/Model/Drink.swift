//
//  Drink.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 7.3.23.
//

import Foundation

struct DefaultDrink: Codable {
    let drink: String
    let volume: Double
    let calories: Int
    let caffeine: Int
    let type: String
}
