//
//  Utilities.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 15.4.23.
//

import Foundation

class Utilities {
    // Formats the given input string as an image name
    static func formatImageName(_ imageName: String) -> String {
        var lowerCaseName = imageName.lowercased()
        lowerCaseName.replace(" ", with: "-")
        return lowerCaseName + ".png"
    }
    
    // Returns drink type from icon name
    static func formatIconName(_ iconName: String) -> String {
        var formattedName = iconName
        for _ in 0...3 {
            formattedName.removeLast()
        }
        formattedName.replace("-", with: " ")
        return formattedName.capitalized
    }
}
