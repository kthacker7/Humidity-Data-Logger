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
    
    var selectedSegment = 0
    var selectedTab: SelecedTab = .Devices
    var selectedDevice: TempoDevice?
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentedControlHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var exportAsCSVButton: UIButton!
    let leftLabelValues = ["UUID", "VERSION", "RSSI", "BATTERY", "LOGGING INTERVAL", "NUMBER OF RECORDS", "MODE", "CURRENT", "TEMPERATURE", "HUMIDITY", "DEW POINT", "HIGHEST AND LOWEST RECORDED", "HIGHEST TEMEPERATURE", "HIGHEST HUMIDITY", "LOWEST TEMEPERATURE", "LOWEST HUMIDITY", "LAST 24 HOURS", "HIGHEST TEMEPERATURE", "LOWEST TEMEPERATURE"]
    
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
        
        for readingType in (self.selectedDevice?.readingTypes)! {
            if readingType.type == "Temperature" {
                for reading in (readingType.readings)! {
                    tempList.append(reading)
                }
            } else if readingType.type == "Humidity" {
                for reading in (readingType.readings)! {
                    humidityList.append(reading)
                }
            } else if readingType.type == "DewPoint" {
                for reading in (readingType.readings)! {
                    dewList.append(reading)
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
        if dewList.count == humidityList.count && dewList.count == tempList.count {
            while i < dewList.count {
                if let dew = dewList[i].avgValue {
                    if let humidity = humidityList[i].avgValue {
                        if let temp = tempList[i].avgValue {
                            readingList.append(CombinedReading(dewReading: dew, tempReading: temp, dateReading: tempList[i].timestamp as NSDate?, logNumber: i, humidityReading: humidity))
                        }
                    }
                }
                i += 1
            }
        }
        
        self.selectTypeView.isHidden = true
        self.selectTypeView.layer.cornerRadius = 5.0
        self.selectTypeView.layer.borderWidth = 1.0
        self.selectTypeView.layer.borderColor = UIColor(colorLiteralRed: 197.0/255.0, green: 10.0/255.0, blue: 39.0/255.0, alpha: 1.0).cgColor
        
        // Export as csv setup
        self.exportAsCSVButton.layer.cornerRadius = 5.0
        self.exportAsCSVButton.layer.borderWidth = 1.0
        self.exportAsCSVButton.layer.borderColor = UIColor(colorLiteralRed: 197.0/255.0, green: 10.0/255.0, blue: 39.0/255.0, alpha: 1.0).cgColor
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
        let tempoDiscDevice = self.selectedDevice as? TempoDiscDevice
        switch indexPath.row {
        case 0:
            return ""
        case 1:
            return self.selectedDevice?.uuid
        case 2:
            return self.selectedDevice?.version
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
            if let numberOfRecords = tempoDiscDevice?.intervalCounter {
                return "\(numberOfRecords)"
            } else {
                return "-"
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
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "GraphsImageTableViewCell", for: indexPath)
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
    }
    
    // MARK: Graph Selection Delegate
    
    func allData() {
        
    }
    
    func selectRange() {
        self.selectTypeView.isHidden = false
    }
    @IBAction func temperatureButtonTapped(_ sender: Any) {
        self.selectTypeView.isHidden = true
    }
    
    @IBAction func humidityButtonTapped(_ sender: Any) {
        self.selectTypeView.isHidden = true
    }
    
    @IBAction func dewpointButtonTapped(_ sender: Any) {
        self.selectTypeView.isHidden = true
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
