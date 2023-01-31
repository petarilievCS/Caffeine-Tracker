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
    
    var child = UIHostingController(rootView: BarChart())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Customization
        reportView.layer.cornerRadius = K.defaultCornerRadius
        
        // Add SwiftUI Chart
        let hostingController = UIHostingController(rootView: BarChart())
        // hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(hostingController)
        chartView.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        hostingController.view.backgroundColor = .systemGray6
        // hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.frame = chartView.bounds
//        NSLayoutConstraint.activate([hostingController.view.leadingAnchor.constraint(equalTo: chartView.leadingAnchor),
//                                     hostingController.view.trailingAnchor.constraint(equalTo: chartView.trailingAnchor),
//                                     hostingController.view.topAnchor.constraint(equalTo: chartView.topAnchor),
//                                     hostingController.view.bottomAnchor.constraint(equalTo: chartView.bottomAnchor)])
        
    }
    
    // Chart view
    struct BarChart: View {
        
        // Data source for chart
        var chartData: [ChartEntry] = [
            .init(day: "Tue", caffeineAmount: 200),
            .init(day: "Mon", caffeineAmount: 250),
            .init(day: "Sun", caffeineAmount: 130),
            .init(day: "Sat", caffeineAmount: 300),
            .init(day: "Fru", caffeineAmount: 450),
            .init(day: "Thu", caffeineAmount: 50),
            .init(day: "Wed", caffeineAmount: 89)
        ]
        
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


