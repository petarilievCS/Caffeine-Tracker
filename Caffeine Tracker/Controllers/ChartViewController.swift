//
//  ChartViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 31.1.23.
//

import UIKit
import SwiftUI
import Charts

class ChartViewController: UIViewController {
    
    @IBOutlet weak var reportView: UIView!
    
    var child = UIHostingController(rootView: BarChart())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reportView.layer.cornerRadius = K.defaultCornerRadius
        child.view.translatesAutoresizingMaskIntoConstraints = false
        child.view.frame = reportView.bounds
        reportView.addSubview(child.view)
        // reportView.addChild(child)

    }
    
}

// Entry in chart
struct ChartEntry: Identifiable {
    var day: Date
    var caffeineAmount: Int
    var id = UUID()
}

// Chart view
struct BarChart: View {
    
    // Data source for chart
    var chartData: [ChartEntry] = [
        .init(day: Date.now, caffeineAmount: 140),
        .init(day: Calendar.current.date(byAdding: .day, value: -1, to: .now)! , caffeineAmount: 250),
        .init(day: Calendar.current.date(byAdding: .day, value: -2, to: .now)!, caffeineAmount: 130),
        .init(day: Calendar.current.date(byAdding: .day, value: -3, to: .now)!, caffeineAmount: 300),
        .init(day: Calendar.current.date(byAdding: .day, value: -4, to: .now)!, caffeineAmount: 450),
        .init(day: Calendar.current.date(byAdding: .day, value: -5, to: .now)!, caffeineAmount: 50),
        .init(day: Calendar.current.date(byAdding: .day, value: -6, to: .now)!, caffeineAmount: 89)]
    
    var body: some View {
        Chart {
            BarMark(
                x: .value("Day", Calendar.current.component(.weekday, from: chartData[0].day)),
                y: .value("Amount", chartData[0].caffeineAmount)
            )
            BarMark(
                x: .value("Day", Calendar.current.component(.weekday, from: chartData[1].day)),
                y: .value("Amount", chartData[1].caffeineAmount)
            )
            BarMark(
                x: .value("Day", Calendar.current.component(.weekday, from: chartData[2].day)),
                y: .value("Amount", chartData[2].caffeineAmount)
            )
            BarMark(
                x: .value("Day", Calendar.current.component(.weekday, from: chartData[3].day)),
                y: .value("Amount", chartData[3].caffeineAmount)
            )
            BarMark(
                x: .value("Day", Calendar.current.component(.weekday, from: chartData[4].day)),
                y: .value("Amount", chartData[4].caffeineAmount)
            )
            BarMark(
                x: .value("Day", Calendar.current.component(.weekday, from: chartData[5].day)),
                y: .value("Amount", chartData[5].caffeineAmount)
            )
            BarMark(
                x: .value("Day", Calendar.current.component(.weekday, from: chartData[6].day)),
                y: .value("Amount", chartData[6].caffeineAmount)
            )
        }
    }
}

