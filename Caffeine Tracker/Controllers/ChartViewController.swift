//
//  ChartViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 31.1.23.
//

import UIKit
import SwiftUI
import Charts
import SwiftPieChart


class ChartViewController: UIViewController {
    
    // MARK: - @IBOutlets
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var commonDrinksView: UIView!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var averageIntakeLabel: UILabel!
    @IBOutlet weak var pieChartView: UIView!
    @IBOutlet weak var totalntakeLabel: UILabel!
    @IBOutlet weak var mostCommonDrinkLabel: UILabel!
    @IBOutlet weak var totalDrinksLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timePeriodControl: UISegmentedControl!
    @IBOutlet weak var drinkOrderButton: UIButton!
    
    private let names: [String] = ["Coffee", "Energy Drinks", "Soft Drinks", "Tea", "Supplements", "Other"]
    private let colors: [Color] = [Color(.systemBlue), Color(.systemRed), Color(.systemGreen), Color(.systemOrange), Color(.systemYellow), Color(.systemPurple)]
    private var pieChartHostingController: UIHostingController<ChartViewController.PieChartView>? = nil
    private var topDrinks: [(ConsumedDrink, Int)] = []
    private var db: DataBaseManager = DataBaseManager()
    private var hostingController = UIHostingController(rootView: BarChart(chartData: []))
    private var defaults = UserDefaults.standard
    
    private var currentPeriod: Period {
        switch timePeriodControl.selectedSegmentIndex {
        case 0:
            return .week
        default:
            return .month
        }
    }
    
    // MARK: - Drink Order Menu Variables
    private var orderByAmount: Bool {
        return defaults.bool(forKey: K.defaults.order)
    }
    private var menu: UIMenu {
        return UIMenu(title: "Order By", children: [firstElement, secondElement])
    }
    private var firstElement: UIAction {
        return UIAction(title: "Frequency", attributes: [], state: orderByAmount ? .off : .on) { action in
            self.defaults.set(false, forKey: K.defaults.order)
            self.refreshMenu()
        }
    }
    private var secondElement: UIAction {
        return UIAction(title: "Caffeine Amount", attributes: [], state: orderByAmount ? .on : .off) { action in
            self.defaults.set(true, forKey: K.defaults.order)
            self.refreshMenu()
        }
    }
    
    // MARK: - View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: K.ID.consumedDrinkCell, bundle: nil), forCellReuseIdentifier:  K.ID.consumedDrinkCell)
        tableView.delegate = self
        tableView.dataSource = self
        timePeriodControl.addTarget(self, action: #selector(self.changePeriod), for: .valueChanged)
        
        // UI Customization
        reportView.layer.cornerRadius = K.UI.cornerRadius
        commonDrinksView.layer.cornerRadius = K.UI.cornerRadius
        
        // Data source for chart
        var chartData: [ChartEntry] = []
        for i in (0...6).reversed() {
            chartData.append(.init(day: db.dayOfTheWeek(for: i), caffeineAmount: db.getAmountDaysAgo(i)))
        }
        
        // Add SwiftUI Chart
        hostingController = UIHostingController(rootView: BarChart(chartData: chartData))
        addChild(hostingController)
        chartView.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        hostingController.view.backgroundColor = .systemGray6
        hostingController.view.frame = chartView.bounds
        
        // Customize segmented control
        let font = UIFont.systemFont(ofSize: 17)
        timePeriodControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        
        // Add SwiftUI Chart (pie chart)
        initializePieChart()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        changePeriod()
    }
    
    // MARK: - @IBActions
    @IBAction func orderButtonPressed(_ sender: UIButton) {
        drinkOrderButton.menu = menu
    }
    
    // MARK: - SwiftUI Views
    struct BarChart: View {
        let db: DataBaseManager = DataBaseManager()
        var chartData: [ChartEntry]
        var body: some View {
            Chart {
                RuleMark(y: .value("Limit", UserDefaults.standard.integer(forKey: K.defaults.dailyLimit)))
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
                switch chartData.count {
                case 7:
                    AxisMarks(values: chartData.map { $0.day }) { day in
                        AxisValueLabel()
                    }
                default:
                    AxisMarks(values: chartData.map { $0.day }) { day in
                        day.index % 7 == 2 ? AxisValueLabel(db.getDayLabel(daysAgo: day.index)) : nil
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
        public var values: [Double]
        public var colors: [Color]
        public let names: [String]
        public var totalAmount: Double
        
        public var backgroundColor: Color
        public var widthFraction: Double
        public var innerRadiusFraction: CGFloat
        
        @State private var activeIndex: Int = -1
        
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
        
        
        public init(values: [Double], colors: [Color], names: [String], totalAmount: Double, backgroundColor: Color, widthFraction: Double, innerRadiusFraction: Double) {
            self.values = values
            self.names = names
            self.colors = colors
            self.totalAmount = totalAmount
            self.backgroundColor = backgroundColor
            self.widthFraction = widthFraction
            self.innerRadiusFraction = innerRadiusFraction
        }
        
        var body: some View {
            GeometryReader { geometry in
                VStack{
                    ZStack{
                        ForEach(0..<self.values.count, id: \.self) { i in
                            PieSliceView(pieSliceData: self.slices[i])
                                .scaleEffect(self.activeIndex == i ? 1.05 : 1)
                                .animation(Animation.spring(), value: self.activeIndex == i ? 1.05 : 1)
                            
                        }
                        .frame(width: geometry.size.width, height: geometry.size.width)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let radius = 0.5 * geometry.size.width
                                    let diff = CGPoint(x: value.location.x - radius, y: radius - value.location.y)
                                    let dist = pow(pow(diff.x, 2.0) + pow(diff.y, 2.0), 0.5)
                                    if (dist > radius || dist < radius * innerRadiusFraction) {
                                        self.activeIndex = -1
                                        return
                                    }
                                    var radians = Double(atan2(diff.x, diff.y))
                                    if (radians < 0) {
                                        radians = 2 * Double.pi + radians
                                    }
                                    
                                    for (i, slice) in slices.enumerated() {
                                        if (radians < slice.endAngle.radians) {
                                            if self.activeIndex != i {
                                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            }
                                            self.activeIndex = i
                                            break
                                        }
                                    }
                                }
                                .onEnded { value in
                                    self.activeIndex = -1
                                }
                        )
                        Circle()
                            .fill(self.backgroundColor)
                            .frame(width: geometry.size.width * innerRadiusFraction, height: geometry.size.width * innerRadiusFraction)
                        
                        VStack {
                            Text(self.activeIndex == -1 ? "Total" : names[self.activeIndex])
                                .font(.system(size: 17.0, weight: .medium))
                                .foregroundColor(Color(UIColor.secondaryLabel))
                            Text(self.activeIndex == -1 ? String(Int(totalAmount * 1000)) + " mg" : String(Int(self.values[activeIndex])) + " mg")
                                .font(.system(size: 28.0, weight: .semibold))
                                .foregroundColor(Color(UIColor.label))
                        }
                    }
                }
                .background(self.backgroundColor)
                .foregroundColor(Color.white)
            }
        }
    }
}

// MARK: - UITableView methods
extension ChartViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topDrinks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.ID.consumedDrinkCell, for: indexPath) as! ConsumedDrinkCell
        let consumedDrink = topDrinks[indexPath.row]
        cell.title.text = consumedDrink.0.name
        cell.icon.image = UIImage(named: consumedDrink.0.icon!)
        cell.detail.text = String(consumedDrink.1) + (orderByAmount ? " mg" : "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return K.UI.consumedDrinkCellHeight
    }
    
}

// MARK: - UISegmentedControl Methods
extension ChartViewController {
    @objc func changePeriod() {
        reloadAmounts(for: currentPeriod)
        reloadChartView(for: currentPeriod)
        reloadPieChart(for: currentPeriod)
    }
    
}

// MARK: - UI Helper methods
extension ChartViewController {
    // Reloads the chart view
    func reloadChartView(for period: Period) {
        var chartData: [ChartEntry] = []
        if period == .week {
            for i in (0...6).reversed() {
                chartData.append(.init(day: db.dayOfTheWeek(for: i), caffeineAmount: db.getAmountDaysAgo(i)))
            }
        } else {
            let amounts: Array<Int> = db.getAmountsInLast(.month)
            for i in 0..<amounts.count {
                let date: Date = Calendar.current.date(byAdding: .day, value: -(29 - i), to: .now)!
                let formatter = DateFormatter()
                formatter.dateFormat = "d"
                let day = formatter.string(from: date)
                chartData.insert(.init(day: String(day), caffeineAmount: amounts[i]), at: 0)
            }
        }
        hostingController.rootView.chartData = chartData
    }
    
    // Reloads the average and total amounts in the chart view
    func reloadAmounts(for period: Period) {
        averageIntakeLabel.text = String(format: "%d mg", Int(db.getAverage(for: period)))
        totalntakeLabel.text = String(format: "%.2f g", db.getTotal(for: period))
    }
    
    // Reloads the pie chart {
    func reloadPieChart(for period: Period) {
        let values = db.getDrinkTypeAmounts(in: period)
        let maxIdx = values.firstIndex(of: values.max()!)
        let totalAmount = db.getTotal(for: period)
        pieChartHostingController!.rootView.values = values
        pieChartHostingController!.rootView.totalAmount = totalAmount
        mostCommonDrinkLabel.text = names[maxIdx!]
        totalDrinksLabel.text = String(db.getDrinksInLast(period).count)
        reloadTopDrinks(for: period)
    }
    
    // Realoads top drink table
    func reloadTopDrinks(for period: Period) {
        topDrinks = db.getTopDrinks(3, for: period, orderByAmount)
        tableView.reloadData()
    }
    
    // Initializes PieChartView
    func initializePieChart()  {
        let values = db.getDrinkTypeAmounts(in: .week)
        pieChartHostingController = UIHostingController(rootView:  PieChartView(values: values, colors: colors, names: names, totalAmount: db.getTotal(for: .week), backgroundColor: Color(.systemGray6), widthFraction: 0.75, innerRadiusFraction: 0.65))
        addChild(pieChartHostingController!)
        pieChartView.addSubview(pieChartHostingController!.view)
        pieChartHostingController!.didMove(toParent: self)
        pieChartHostingController!.view.backgroundColor = .systemGray6
        pieChartHostingController!.view.frame = pieChartView.bounds
    }
    
    // Refreshed order selection menu
    func refreshMenu() {
        firstElement.state = orderByAmount ? .off : .on
        secondElement.state = orderByAmount ? .on : .off
        drinkOrderButton.menu = menu
        reloadTopDrinks(for: currentPeriod)
    }
}
