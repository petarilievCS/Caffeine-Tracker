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
    @IBOutlet weak var commonDrinksView: UIView!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var averageIntakeLabel: UILabel!
    @IBOutlet weak var pieChartView: UIView!
    @IBOutlet weak var totalntakeLabel: UILabel!
    
    var databaseManager: DataBaseManager = DataBaseManager()
    var hostingController = UIHostingController(rootView: BarChart(chartData: []))
    var pieChartHostingController = UIHostingController(rootView:  PieChartView(values: [1300, 500, 300], colors: [Color(UIColor(named: "Light Blue")!), Color(UIColor(named: "Green")!), Color(UIColor(named: "Red")!)], names: ["Coffee", "Energy Drink", "Soda"], totalAmount: 0.0, backgroundColor: Color(.systemGray6), innerRadiusFraction: 0.6))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Customization
        reportView.layer.cornerRadius = K.defaultCornerRadius
        commonDrinksView.layer.cornerRadius = K.defaultCornerRadius
        
        // Data source for chart
        var chartData: [ChartEntry] = []
        for i in (0...6).reversed() {
            chartData.append(.init(day: databaseManager.dayOfTheWeek(for: i), caffeineAmount: databaseManager.getAmountDaysAgo(i)))
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        averageIntakeLabel.text = String(format: "%d mg", Int(databaseManager.getWeekAverage()))
        totalntakeLabel.text = String(format: "%.2f g", databaseManager.getWeeklyTotal())
        
        var chartData: [ChartEntry] = []
        for i in (0...6).reversed() {
            chartData.append(.init(day: databaseManager.dayOfTheWeek(for: i), caffeineAmount: databaseManager.getAmountDaysAgo(i)))
        }
        hostingController.rootView.chartData = chartData
        
        // Add SwiftUI Chart
        hostingController = UIHostingController(rootView: BarChart(chartData: chartData))
        addChild(hostingController)
        chartView.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        hostingController.view.backgroundColor = .systemGray6
        hostingController.view.frame = chartView.bounds
        
        // Add SwiftUI Chart (pie chart)
        initializePieChart()
    }
    
    // Initializes PieChartView
    func initializePieChart()  {
        
        let values = databaseManager.getDrinkTypeAmounts()
        pieChartHostingController = UIHostingController(rootView:  PieChartView(values: values, colors: [Color(.systemBlue), Color(.systemRed), Color(.systemGreen), Color(.systemOrange), Color(.systemYellow), Color(.systemPurple), Color(.systemIndigo), Color(.systemCyan)], names: ["Coffee", "Esspresso", "Energy Drinks", "Sodas", "Supplements", "Chocolate", "Tea", "Other"], totalAmount: databaseManager.getWeeklyTotal(), backgroundColor: Color(.systemGray6), innerRadiusFraction: 0.65))
        addChild(pieChartHostingController)
        pieChartView.addSubview(pieChartHostingController.view)
        pieChartHostingController.didMove(toParent: self)
        pieChartHostingController.view.backgroundColor = .systemGray6
        pieChartHostingController.view.frame = pieChartView.bounds
    }
    
    // Chart view
    struct BarChart: View {
        
        let databaseManager: DataBaseManager = DataBaseManager()
        var chartData: [ChartEntry]
        
        var body: some View {
            Chart {
                RuleMark(y: .value("Limit", UserDefaults.standard.integer(forKey: K.dailyLimit)))
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
        
        func findChartAmount(for day: String) -> Int {
            for i in 0..<chartData.count {
                if chartData[i].day == day {
                    return chartData[i].caffeineAmount
                }
            }
            return 0
        }
    }
    
    // Pie chart view
    struct PieSliceView: View {
        var pieSliceData: PieSliceData
        
        var midRadians: Double {
            return Double.pi / 2.0 - (pieSliceData.startAngle + pieSliceData.endAngle).radians / 2.0
        }
        
        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    Path { path in
                        let width: CGFloat = min(geometry.size.width, geometry.size.height)
                        let height = width
                        
                        let center = CGPoint(x: width * 0.5, y: height * 0.5)
                        
                        path.move(to: center)
                        
                        path.addArc(
                            center: center,
                            radius: width * 0.5,
                            startAngle: Angle(degrees: -90.0) + pieSliceData.startAngle,
                            endAngle: Angle(degrees: -90.0) + pieSliceData.endAngle,
                            clockwise: false)
                        
                    }
                    .fill(pieSliceData.color)
                    
                    Text(pieSliceData.text)
                        .position(
                            x: geometry.size.width * 0.5 * CGFloat(1.0 + 0.78 * cos(self.midRadians)),
                            y: geometry.size.height * 0.5 * CGFloat(1.0 - 0.78 * sin(self.midRadians))
                        )
                        .foregroundColor(Color.white)
                        .font(.system(size: 17.0, weight: .medium))
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
    }

    struct PieSliceData {
        var startAngle: Angle
        var endAngle: Angle
        var text: String
        var color: Color
    }
    
    struct PieChartView: View {
        public let values: [Double]
        public var colors: [Color]
        public let names: [String]
        public let totalAmount: Double
        
        public var backgroundColor: Color
        public var innerRadiusFraction: CGFloat
        
        var slices: [PieSliceData] {
            let sum = values.reduce(0, +)
            var endDeg: Double = 0
            var tempSlices: [PieSliceData] = []
            
            for (i, value) in values.enumerated() {
                let degrees: Double = value * 360 / sum
                
                if value == 0.0 {
                    tempSlices.append(PieSliceData(startAngle: Angle(degrees: endDeg), endAngle: Angle(degrees: endDeg + degrees), text: "", color: self.colors[i]))
                } else {
                    tempSlices.append(PieSliceData(startAngle: Angle(degrees: endDeg), endAngle: Angle(degrees: endDeg + degrees), text: "", color: self.colors[i]))
                }
                // String(format: "%.0f%%", value * 100 / sum)
                endDeg += degrees
            }
            return tempSlices
        }
        
        var body: some View {
            GeometryReader { geometry in
                VStack{
                    ZStack{
                        ForEach(0..<self.values.count){ i in
                            PieSliceView(pieSliceData: self.slices[i])
                        }
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        
                        Circle()
                            .fill(self.backgroundColor)
                            .frame(width: geometry.size.width * innerRadiusFraction, height: geometry.size.width * innerRadiusFraction)
                        
                        VStack {
                            Text("Total")
                                .font(.system(size: 17.0, weight: .medium))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                            Text(String(Int(totalAmount * 1000)) + " mg")
                                .font(.system(size: 28.0, weight: .semibold))
                                .foregroundColor(Color(UIColor.label))
                        }
                    }
                    PieChartRows(colors: self.colors, names: self.names, values: self.values.map { String($0) }, percents: self.values.map { String(format: "%.0f%%", $0 * 100 / self.values.reduce(0, +)) })
                }
                .background(self.backgroundColor)
                .foregroundColor(Color.white)
            }
        }
    }
    
    struct PieChartRows: View {
        var colors: [Color]
        var names: [String]
        var values: [String]
        var percents: [String]
        
        var body: some View {
            Spacer()
            HStack {
                VStack{
                    ForEach(0..<(self.values.count / 2)) { i in
                        HStack {
                            RoundedRectangle(cornerRadius: 5.0)
                                .fill(self.colors[i])
                                .frame(width: 20, height: 20)
                            Text(self.names[i])
                                .font(.system(size: 17.0))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                            Spacer()

                        }
                    }
                }
                VStack{
                    ForEach((self.values.count / 2)..<self.values.count) { i in
                        HStack {
                            RoundedRectangle(cornerRadius: 5.0)
                                .fill(self.colors[i])
                                .frame(width: 20, height: 20)
                            Text(self.names[i])
                                .font(.system(size: 17.0))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                            Spacer()

                        }
                    }
                }
            }
            
        }
    }

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


