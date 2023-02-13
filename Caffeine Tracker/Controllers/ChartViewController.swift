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
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var averageIntakeLabel: UILabel!
    @IBOutlet weak var totalntakeLabel: UILabel!
    
    var databaseManager: DataBaseManager = DataBaseManager()
    var hostingController = UIHostingController(rootView: BarChart(chartData: []))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Customization
        reportView.layer.cornerRadius = K.defaultCornerRadius
        
        // Data source for chart
        var chartData: [ChartEntry] = []
        for i in 0...6 {
            chartData.append(.init(day: String(i), caffeineAmount: databaseManager.getAmountDaysAgo(i)))
        }
        
        // Add SwiftUI Chart
        hostingController = UIHostingController(rootView: BarChart(chartData: chartData))
        addChild(hostingController)
        chartView.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        hostingController.view.backgroundColor = .systemGray6
        hostingController.view.frame = chartView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        averageIntakeLabel.text = String(format: "%d mg", Int(databaseManager.getWeekAverage()))
        totalntakeLabel.text = String(format: "%.2f g", databaseManager.getWeeklyTotal())
        
        var chartData: [ChartEntry] = []
        for i in 0...6 {
            chartData.append(.init(day: String(i), caffeineAmount: databaseManager.getAmountDaysAgo(i)))
        }
        hostingController.rootView.chartData = chartData
    }
    
    // Chart view
    struct BarChart: View {
        
        let databaseManager: DataBaseManager = DataBaseManager()
        var chartData: [ChartEntry]
        
        var body: some View {
            Chart {
                RuleMark(y: .value("Limit", 400))
                    .foregroundStyle(Color.red)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                
                ForEach(chartData) { datum in
                    BarMark(
                        x: .value("Day", datum.day),
                        y: .value("Caffeine", datum.caffeineAmount)
                    )
                }
            }
            .chartXAxis {
                AxisMarks(values: chartData.map { $0.day }) { day in
                    AxisValueLabel()
                }
            }
        }
    }
}

// Entry in chart
struct ChartEntry: Identifiable {
    var day: String
    var caffeineAmount: Int
    var id = UUID()
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    var startOfWeek: Date {
        Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
    
    var endOfWeek: Date {
        var components = DateComponents()
        components.weekOfYear = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfWeek)!
    }
    
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.current.date(from: components)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }
}


