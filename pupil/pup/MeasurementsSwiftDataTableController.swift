//
//  MeasurementsSwiftDataTableController.swift
//  pup
//
//  Created by Miguel Tamayo on 3/19/21.
//

import UIKit
import RealmSwift
import SwiftDataTables
import PureLayout
import Charts


class MeasurementsSwiftDataTableController: UIViewController {
    
    lazy var dataTable = makeDataTable()
    var dataSource: DataTableContent = []
    let dataChart: LineChartView = LineChartView(forAutoLayout: ())
    let headerTitles = ["Date", "Prediction"]
    let segmentedControl: UISegmentedControl = UISegmentedControl(items: ["Table", "Chart"])
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addDataSource()
        updateGraph()
    }
    
    func setupViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(segmentedControl)
        segmentedControl.autoPinEdgesToSuperviewSafeArea(with: .init(top: 0, left: 8, bottom: 0, right: 8), excludingEdge: .bottom)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlIndexChanged(sender:)), for: .valueChanged)
        
        view.addSubview(dataTable)
        dataTable.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .top)
        dataTable.autoPinEdge(.top, to: .bottom, of: segmentedControl)
        dataTable.reload()
        
        view.addSubview(dataChart)
        dataChart.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .top)
        dataChart.autoPinEdge(.top, to: .bottom, of: segmentedControl)
        dataChart.isHidden = true
        updateGraph()
    }
    
    public func addDataSource() {
        self.dataSource = realmDB.objects(Prediction.self).compactMap { (prediction) in
            return [
                DataTableValueType.string(prediction.date),
                DataTableValueType.string(prediction.prediction)
            ]
        }
        dataTable.reload()
    }
    
    func updateGraph(){
        let data = Array(realmDB.objects(Prediction.self))
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        
        var referenceTimeInterval: TimeInterval = 0
        if let minTimeInterval = (data.map {  dateFormatter.date(from: $0.date)!.timeIntervalSince1970 }).min() {
            referenceTimeInterval = minTimeInterval
        }


        // Define chart xValues formatter
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale.current

        let xValuesNumberFormatter = ChartXAxisFormatter(referenceTimeInterval: referenceTimeInterval, dateFormatter: formatter)



        // Define chart entries
        var entries = [ChartDataEntry]()
        for object in data {
            print(object.date)
            let timeInterval = dateFormatter.date(from: object.date)!.timeIntervalSince1970
            let xValue = (timeInterval - referenceTimeInterval) / (3600 * 24)

            let yValue = Double(object.prediction)!
            let entry = ChartDataEntry(x: xValue, y: yValue)
            entries.append(entry)
        }

        

        let line1 = LineChartDataSet(entries: entries, label: "Measurment") //Here we convert lineChartEntry to a LineChartDataSet
        line1.colors = [NSUIColor.blue] //Sets the colour to blue

        let dat = LineChartData() //This is the object that will be added to the chart
        dat.addDataSet(line1) //Adds the line to the dataSet
        
        dataChart.xAxis.valueFormatter = xValuesNumberFormatter
        dataChart.data = dat //finally - it adds the chart data to the chart and causes an update
//        dataChart.chartDescription?.text = "My awesome chart" // Here we set the description for the graph
    }
}

extension MeasurementsSwiftDataTableController {
    
    @objc func segmentedControlIndexChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            dataTable.isHidden = false
            dataChart.isHidden = true
        } else if sender.selectedSegmentIndex == 1 {
            dataTable.isHidden = true
            dataChart.isHidden = false
        }
    }
    
    func makeOptions() -> DataTableConfiguration {
        var options = DataTableConfiguration()
        options.shouldContentWidthScaleToFillFrame = true
        options.defaultOrdering = DataTableColumnOrder(index: 1, order: .ascending)
        options.shouldShowFooter = false
        return options
    }
    
    func makeDataTable() -> SwiftDataTable {
        let dataTable = SwiftDataTable(dataSource: self, options: makeOptions(), frame: .infinite)
        dataTable.delegate = self
        dataTable.translatesAutoresizingMaskIntoConstraints = false
        return dataTable
    }
    
}
extension MeasurementsSwiftDataTableController: SwiftDataTableDataSource {
    public func dataTable(_ dataTable: SwiftDataTable, headerTitleForColumnAt columnIndex: NSInteger) -> String {
        return self.headerTitles[columnIndex]
    }
    
    public func numberOfColumns(in: SwiftDataTable) -> Int {
        return 2
    }
    
    func numberOfRows(in: SwiftDataTable) -> Int {
        return self.dataSource.count
    }
    
    public func dataTable(_ dataTable: SwiftDataTable, dataForRowAt index: NSInteger) -> [DataTableValueType] {
        return self.dataSource[index]
    }
}

extension MeasurementsSwiftDataTableController: SwiftDataTableDelegate {
    
    func dataTable(_ dataTable: SwiftDataTable, widthForColumnAt index: Int) -> CGFloat {
        return CGFloat(UIScreen.main.bounds.width / 2)
    }
    
    func didSelectItem(_ dataTable: SwiftDataTable, indexPath: IndexPath) {
        debugPrint("did select item at indexPath: \(indexPath) dataValue: \(dataTable.data(for: indexPath))")
        try! realmDB.write {
            realmDB.delete(realmDB.objects(Prediction.self).filter("date == %@", dataTable.data(for: indexPath).stringRepresentation))
            addDataSource()
        }
    }
}


class ChartXAxisFormatter: NSObject {
    fileprivate var dateFormatter: DateFormatter?
    fileprivate var referenceTimeInterval: TimeInterval?

    convenience init(referenceTimeInterval: TimeInterval, dateFormatter: DateFormatter) {
        self.init()
        self.referenceTimeInterval = referenceTimeInterval
        self.dateFormatter = dateFormatter
    }
}


extension ChartXAxisFormatter: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let dateFormatter = dateFormatter,
        let referenceTimeInterval = referenceTimeInterval
        else {
            return ""
        }

        let date = Date(timeIntervalSince1970: value * 3600 * 24 + referenceTimeInterval)
        return dateFormatter.string(from: date)
    }

}
