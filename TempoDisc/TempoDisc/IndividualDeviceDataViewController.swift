//
//  IndividualDeviceDataViewController.swift
//  Cornerstone Humidity Data Logger
//
//  Created by Kunal Thacker on 12/18/16.
//  Copyright © 2016 Cornerstone Humidity. All rights reserved.
//

import UIKit
import MessageUI

struct CombinedReading {
    var dewReading : NSDecimalNumber?
    var tempReading : NSDecimalNumber?
    var dateReading : NSDate?
    var logNumber : Int?
    var humidityReading : NSDecimalNumber?
}

class IndividualDeviceDataViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GraphSelectionDelegate, ExportDataDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var selectTypeView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomExportView: UIView!
    
    // Graph Views
    @IBOutlet weak var temperatureGraphView: UIView!
    @IBOutlet weak var humidityGraphView: UIView!
    @IBOutlet weak var dewpointGraphView: UIView!
    
    // Graph Button buttons and Views
    @IBOutlet weak var graphsBottomView: UIView!
    @IBOutlet weak var allDataButton: UIButton!
    @IBOutlet weak var selectTypeButton: UIButton!
    
    @IBOutlet weak var greyView: UIView!
    
    var selectedSegment = 0
    var selectedTab: SelecedTab = .Devices
    var selectedDevice: TempoDiscDevice?
    let helper : TempoHelperMethods = TempoHelperMethods()
    var allDataSelected = false
    var currentType : GraphType = .temperature
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentedControlHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var exportAsCSVButton: UIButton!
    var leftLabelValues = ["UUID", "VERSION", "RSSI", "BATTERY", "LOGGING INTERVAL", "NUMBER OF RECORDS", "MODE", "CURRENT", "TEMPERATURE", "HUMIDITY", "DEW POINT", "HIGHEST AND LOWEST RECORDED", "HIGHEST TEMEPERATURE", "HIGHEST HUMIDITY", "LOWEST TEMEPERATURE", "LOWEST HUMIDITY", "LAST 24 HOURS", "HIGHEST TEMEPERATURE", "LOWEST TEMEPERATURE"]
    
    let navigationTitles = ["History Device Details", "Device Graphs", "Table"]
    
    var readingList : [CombinedReading] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.selectedTab == .Devices {
            self.segmentedControlHeightConstraint.constant = 0
            self.segmentedControl.isHidden = true
            
        } else {
            self.segmentedControlHeightConstraint.constant = 28
            self.segmentedControl.isHidden = false
            if self.selectedSegment == 2 {
                self.bottomExportView.isHidden = false
            } else {
                self.bottomExportView.isHidden = true
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectedSegment == 0 {
            return 20
        } else if self.selectedSegment == 1 {
            return 2
        }
        if self.selectedDevice == nil {
            return 0
        }
       
        return readingList.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.selectedSegment == 0 {
            // Details table view
            return self.getDetailsCell(indexPath: indexPath)
        } else if self.selectedSegment == 1 {
            return self.getGraphsCell(indexPath: indexPath)
        } else {
            return self.getReadingCell(indexPath: indexPath)
        }
    }
    
    
    // MARK: Others
    
    func setup() {
        // Register Nibs
        let nib1 = UINib(nibName: "IndividualDeviceNameTableViewCell", bundle: nil)
        self.tableView.register(nib1, forCellReuseIdentifier: "IndividualDeviceNameTableViewCell")
        let nib2 = UINib(nibName: "IndividualDeviceDataTableViewCell", bundle: nil)
        self.tableView.register(nib2, forCellReuseIdentifier: "IndividualDeviceDataTableViewCell")
        let nib3 = UINib(nibName: "GraphsImageTableViewCell", bundle: nil)
        self.tableView.register(nib3, forCellReuseIdentifier: "GraphsImageTableViewCell")
        let nib4 = UINib(nibName: "GraphsSelectionTableViewCell", bundle: nil)
        self.tableView.register(nib4, forCellReuseIdentifier: "GraphsSelectionTableViewCell")
        let nib5 = UINib(nibName: "SingleReadingTableViewCell", bundle: nil)
        self.tableView.register(nib5, forCellReuseIdentifier: "SingleReadingTableViewCell")
        let nib6 = UINib(nibName: "ExportDataTableViewCell", bundle: nil)
        self.tableView.register(nib6, forCellReuseIdentifier: "ExportDataTableViewCell")
        
        // Table view height setup
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50.0
        
        // Navigation bar setup
        if self.selectedTab == .History {
            self.navigationItem.title = self.navigationTitles[self.selectedSegment]
        } else {
            self.navigationItem.title = "Device Details"
        }
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: nil, action: nil)
        // Get logs
        
        var tempList : [Reading] = []
        var humidityList : [Reading] = []
        var dewList : [Reading] = []
        let readingTypes = ["Temperature", "Humidity", "DewPoint"]
        if let device = self.selectedDevice {
            for readingType in readingTypes {
                if readingType == "Temperature" {
                    for reading in device.readings(forType: readingType) {
                        tempList.append(reading as! Reading)
                    }
                } else if readingType == "Humidity" {
                    for reading in device.readings(forType: readingType) {
                        humidityList.append(reading as! Reading)
                    }
                } else if readingType == "DewPoint" {
                    for reading in device.readings(forType: readingType) {
                        dewList.append(reading as! Reading)
                    }
                }
            }
        }
        tempList.sort { (reading1, reading2) -> Bool in
            return reading1.timestamp!.compare(reading2.timestamp!) == ComparisonResult.orderedAscending
        }
        humidityList.sort { (reading1, reading2) -> Bool in
            return reading1.timestamp!.compare(reading2.timestamp!) == ComparisonResult.orderedAscending
        }
        dewList.sort { (reading1, reading2) -> Bool in
            return reading1.timestamp!.compare(reading2.timestamp!) == ComparisonResult.orderedAscending
        }
        var i = 0
        let minCount = min(a: min(a: humidityList.count, b: dewList.count), b: tempList.count)
        
        while i < minCount {
            if let dew = dewList[i].avgValue {
                if let humidity = humidityList[i].avgValue {
                    if let temp = tempList[i].avgValue {
                        readingList.append(CombinedReading(dewReading: dew, tempReading: temp, dateReading: tempList[i].timestamp as NSDate?, logNumber: i, humidityReading: humidity))
                    }
                }
            }
            i += 1
        }
        // Setup graph views
        self.dewpointGraphView.isHidden = true
        self.temperatureGraphView.isHidden = true
        self.humidityGraphView.isHidden = true
        self.dewpointGraphView.isUserInteractionEnabled = true
        self.temperatureGraphView.isUserInteractionEnabled = true
        self.humidityGraphView.isUserInteractionEnabled = true
        
        self.selectTypeView.isHidden = true
        self.greyView.isHidden = true
        self.selectTypeView.layer.cornerRadius = 5.0
        self.selectTypeView.layer.borderWidth = 1.0
        self.selectTypeView.layer.borderColor = UIColor(colorLiteralRed: 197.0/255.0, green: 10.0/255.0, blue: 39.0/255.0, alpha: 1.0).cgColor
        
        self.graphsBottomView.isHidden = true
        self.allDataButton.layer.cornerRadius = 5.0
        self.allDataButton.layer.borderWidth = 1.0
        self.allDataButton.layer.borderColor = UIColor(colorLiteralRed: 197.0/255.0, green: 10.0/255.0, blue: 39.0/255.0, alpha: 1.0).cgColor
        
        self.selectTypeButton.layer.cornerRadius = 5.0
        self.selectTypeButton.layer.borderWidth = 1.0
        self.selectTypeButton.layer.borderColor = UIColor(colorLiteralRed: 197.0/255.0, green: 10.0/255.0, blue: 39.0/255.0, alpha: 1.0).cgColor
        
        // Export as csv setup
        self.exportAsCSVButton.layer.cornerRadius = 5.0
        self.exportAsCSVButton.layer.borderWidth = 1.0
        self.exportAsCSVButton.layer.borderColor = UIColor(colorLiteralRed: 197.0/255.0, green: 10.0/255.0, blue: 39.0/255.0, alpha: 1.0).cgColor
        
        if self.selectedTab == .Devices {
            self.leftLabelValues[5] = "LAST DOWNLOADED DATE"
        }
    }
    
    func min(a:Int, b: Int) -> Int{
        if (a<b) {
            return a
        }
        return b
    }
    
    func getDetailsCell(indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "IndividualDeviceNameTableViewCell", for: indexPath) as! IndividualDeviceNameTableViewCell
            cell.nameLabel.text = self.selectedDevice?.name
            return cell
        }
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "IndividualDeviceDataTableViewCell", for: indexPath) as? IndividualDeviceDataTableViewCell {
            if indexPath.row - 1 < leftLabelValues.count {
                let leftLabelText = leftLabelValues[indexPath.row - 1] + ":"
                let rightLabelText = self.getRightLabelText(indexPath: indexPath)
                if rightLabelText == ""  {
                    cell.leftLabel.font = UIFont.boldSystemFont(ofSize: 17)
                }
                cell.leftLabel.text = leftLabelText
                cell.rightLabel.text = rightLabelText
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func getRightLabelText(indexPath: IndexPath) -> String? {
        let tempoDiscDevice = self.selectedDevice
        switch indexPath.row {
        case 0:
            return ""
        case 1:
            return self.selectedDevice?.uuid
        case 2:
            return self.selectedDevice?.version?.description
        case 3:
            if let rssi = self.selectedDevice?.peripheral?.rssi {
                return "\(rssi) dBm"
            } else {
                return "-"
            }
        case 4:
            if let battery = self.selectedDevice?.battery {
                return "\(battery)%"
            } else {
                return "-"
            }
        case 5:
            if let loggingInterval = tempoDiscDevice?.timerInterval {
                return "\(loggingInterval)"
            } else {
                return "-"
            }
        case 6:
            if self.selectedTab == .History {
                if let numberOfRecords = tempoDiscDevice?.readings(forType: "Temperature").count {
                    return "\(numberOfRecords)"
                } else {
                    return "-"
                }
            } else {
                if let lastDownload = tempoDiscDevice?.lastDownload {
                    return lastDownload.description
                } else {
                    return "-"
                }
            }
        case 7:
            if let mode = tempoDiscDevice?.mode {
                return "\(mode)"
            }
            return "-"
        case 9:
            if let currTemp = self.selectedDevice?.currentTemperature {
                return "\(currTemp)°C"
            }
            return "-"
        case 10:
            if let currHumidity = self.selectedDevice?.currentHumidity {
                return "\(currHumidity)"
            }
            return "-"
        case 11:
            if let currDewPoint = tempoDiscDevice?.dewPoint {
                return "\(currDewPoint)°C"
            }
            return "-"
        case 13:
            if let highestTemp = tempoDiscDevice?.highestTemperature {
                return "\(highestTemp)°C"
            }
            return "-"
        case 14:
            if let highestHumidity = tempoDiscDevice?.highestHumidity {
                return "\(highestHumidity)% RH"
            }
            return "-"
        case 15:
            if let lowestTemp = tempoDiscDevice?.lowestTemperature {
                return "\(lowestTemp)°C"
            }
            return "-"
        case 16:
            if let lowestHumidity = tempoDiscDevice?.lowestHumidity {
                return "\(lowestHumidity)% RH"
            }
            return "-"
        case 18:
            if let highestDayTemp = tempoDiscDevice?.highestDayTemperature {
                return "\(highestDayTemp)°C"
            }
            return "-"
        case 19:
            if let lowestDayTemp = tempoDiscDevice?.lowestDayTemperature {
                return "\(lowestDayTemp)°C"
            }
            return "-"
        default:
            return ""
        }
    }
    
    func getGraphsCell(indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "GraphsImageTableViewCell", for: indexPath) as! GraphsImageTableViewCell
            if self.selectedDevice != nil {
                cell.switchTo(type: .temperature, device: self.selectedDevice!)
            }
            return cell
        }
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "GraphsSelectionTableViewCell", for: indexPath) as! GraphsSelectionTableViewCell
        cell.delegate = self
        return cell
    
    }
    
    func getReadingCell(indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row != self.readingList.count {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "SingleReadingTableViewCell", for: indexPath) as! SingleReadingTableViewCell
            if indexPath.row < self.readingList.count {
                let reading = self.readingList[indexPath.row]
                cell.dateLabel.text = "\(reading.dateReading!.description)"
                cell.dewLabel.text = "\(reading.dewReading!) °C"
                cell.tempLabel.text = "\(reading.tempReading!) °C"
                cell.humidityLabel.text = "\(reading.humidityReading!) RH"
                cell.logNumberLabel.text = (indexPath.row + 1).description
            }
            return cell
        }
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ExportDataTableViewCell", for: indexPath) as! ExportDataTableViewCell
        cell.delegate = self
        return cell
    }
    
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        self.selectedSegment = sender.selectedSegmentIndex
        self.navigationItem.title = self.navigationTitles[self.selectedSegment]
        self.tableView.reloadData()
        if self.selectedSegment == 2 {
            self.bottomExportView.isHidden = false
        } else {
            self.bottomExportView.isHidden = true
        }
        if self.selectedSegment == 1 {
            self.dewpointGraphView.isHidden = true
            self.temperatureGraphView.isHidden = false
            self.humidityGraphView.isHidden = true
            self.tableView.isHidden = true
            self.graphsBottomView.isHidden = false
            self.switchTo(type: .temperature)
        } else {
            self.graphsBottomView.isHidden = true
            self.tableView.isHidden = false
            self.temperatureGraphView.isHidden = true
            self.dewpointGraphView.isHidden = true
            self.humidityGraphView.isHidden = true
        }
    }
    
    func switchTo(type: GraphType) {
        self.currentType = type
        if self.selectedDevice != nil {
            var stringType : String?
            var chosenView : UIView?
            if type == .temperature {
                self.temperatureGraphView.isHidden = false
                self.humidityGraphView.isHidden = true
                self.dewpointGraphView.isHidden = true
                chosenView = self.temperatureGraphView
                stringType = "Temperature"
            } else if type == .humidity {
                self.temperatureGraphView.isHidden = true
                self.humidityGraphView.isHidden = false
                self.dewpointGraphView.isHidden = true
                chosenView = self.humidityGraphView
                stringType = "Humidity"
            } else {
                self.temperatureGraphView.isHidden = false
                self.humidityGraphView.isHidden = true
                self.dewpointGraphView.isHidden = false
                chosenView = self.dewpointGraphView
                stringType = "DewPoint"
            }
            self.helper.allDataSelected = self.allDataSelected
            self.helper.selectedDevice = self.selectedDevice
            var hostViewTemperature : CPTGraphHostingView = CPTGraphHostingView()
            hostViewTemperature = helper.configureHost(chosenView!, forGraph: hostViewTemperature)
            var graphTemperature: CPTGraph = CPTXYGraph(frame: hostViewTemperature.bounds.insetBy(dx: 10, dy: 10))
            //        graph = [[CPTXYGraph alloc] initWithFrame:CGRectInset(viewGraph.bounds, 10, 10)];
            graphTemperature = helper.configureGraph(graphTemperature, hostView: hostViewTemperature, graphView: temperatureGraphView, title: nil)
            var plotTemperature: CPTScatterPlot = CPTScatterPlot()
            plotTemperature = helper.configurePlot(plotTemperature, for: graphTemperature, identifier: stringType!)
            helper.configureAxes(for: graphTemperature, plot: plotTemperature)
            helper.adjustPlotsRange(graphTemperature.defaultPlotSpace!, forType: stringType!)
        }
    }
    
    // MARK: Graphs Bottom view Methods
    
    @IBAction func allDataButtonTapped(_ sender: Any) {
        if (!self.allDataSelected) {
            self.allDataButton.backgroundColor = UIColor(colorLiteralRed: 197.0/255.0, green: 10.0/255.0, blue: 39.0/255.0, alpha: 1.0)
            self.allDataButton.setTitleColor(UIColor.white, for: .normal)
            self.allDataButton.titleLabel?.textColor = UIColor.white
        } else {
            self.allDataButton.backgroundColor = UIColor.white
            self.allDataButton.setTitleColor(UIColor(colorLiteralRed: 197.0/255.0, green: 10.0/255.0, blue: 39.0/255.0, alpha: 1.0), for: .normal)
        }
        allDataSelected = !allDataSelected
        self.switchTo(type: self.currentType)
    }
    
    
    @IBAction func selectTypeTapped(_ sender: Any) {
        self.selectRange()
    }
    
    
    // MARK: Graph Selection Delegate
    
    func allData() {
        
    }
    
    func selectRange() {
        self.selectTypeView.isHidden = false
        self.greyView.isHidden = false
    }
    @IBAction func temperatureButtonTapped(_ sender: Any) {
        self.selectTypeView.isHidden = true
        self.greyView.isHidden = true
        self.switchTo(type: .temperature)
    }
    
    @IBAction func humidityButtonTapped(_ sender: Any) {
        self.selectTypeView.isHidden = true
        self.greyView.isHidden = true
        self.switchTo(type: .humidity)
    }
    
    @IBAction func dewpointButtonTapped(_ sender: Any) {
        self.selectTypeView.isHidden = true
        self.greyView.isHidden = true
        self.switchTo(type: .dewpoint)
    }
    
    // MARK: Export Data Delegate
    
    
    @IBAction func exportAsCSVTapped(_ sender: Any) {
        self.exportAsCSV()
    }
    
    
    func exportAsPDF() {
        
    }
    
    func exportAsCSV() {
        if let device = self.selectedDevice {
            if let filePath = TempoHelperMethods.createCSVFileFordevice(device) {
                let mailComposeVC = MFMailComposeViewController()
                mailComposeVC.mailComposeDelegate = self
                mailComposeVC.modalPresentationStyle = .pageSheet
                mailComposeVC.setSubject("Device Data Export")
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                let data = NSData.dataWithContentsOfMappedFile(filePath)
                if device.name != nil {
                    let date = dateFormatter.string(from: Date())
                    mailComposeVC.addAttachmentData(data as! Data, mimeType: "text/csv", fileName: device.name! + " " + date)
                }
                self.present(mailComposeVC, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: Mail Compose Delegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
