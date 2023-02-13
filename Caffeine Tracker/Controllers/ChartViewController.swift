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
        for i in (0...6).reversed() {
            chartData.append(.init(day: databaseManager.dayOfTheWeek(for: i), caffeineAmount: databaseManager.getAmountDaysAgo(i)))
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
        for i in (0...6).reversed() {
            chartData.append(.init(day: databaseManager.dayOfTheWeek(for: i), caffeineAmount: databaseManager.getAmountDaysAgo(i)))
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
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle().fill(.clear).contentShape(Rectangle())
//                        .gesture(
//                            DragGesture()
//                                .onChanged { value in
//                                    // Convert the gesture location to the coordiante space of the plot area.
//                                    let origin = geometry[proxy.plotAreaFrame].origin
//                                    let location = CGPoint(
//                                        x: value.location.x - origin.x,
//                                        y: value.location.y - origin.y
//                                    )
//                                    // Get the x (date) and y (price) value from the location.
//                                    let (day, caffeine) = proxy.value(at: location, as: (String, Int).self)!
//                                    print("Location: \(day), \(caffeine)")
//                                }
//                        )
                        .onTapGesture { value in
                            let origin = geometry[proxy.plotAreaFrame].origin
//                            let location = CGPoint(
//                                x: value.location.x - origin.x,
//                                y: value.location.y - origin.y
//                            )
                            // Get the x (date) and y (price) value from the location.
                            let (day, caffeine) = proxy.value(at: value, as: (String, Int).self)!
                            let caffeineAmount = findChartAmount(for: day)
                            print(caffeineAmount)
                        }
                }
            }
        }
        
        func findChartAmount(for day: String) -> Int {
            for i in 0..<chartData.count {
                if chartData[i].day == day {
                    return chartData[i].caffeineAmount
                }
            }
            return 0
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


