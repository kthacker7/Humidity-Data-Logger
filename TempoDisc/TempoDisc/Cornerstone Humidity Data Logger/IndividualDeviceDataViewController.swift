//
//  IndividualDeviceDataViewController.swift
//  Cornerstone Humidity Data Logger
//
//  Created by Kunal Thacker on 12/18/16.
//  Copyright © 2016 Cornerstone Humidity. All rights reserved.
//

import UIKit

class IndividualDeviceDataViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GraphSelectionDelegate, ExportDataDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var selectedSegment = 0
    var selectedTab: SelecedTab = .Devices
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentedControlHeightConstraint: NSLayoutConstraint!
    
    let leftLabelValues = ["UUID", "VERSION", "RSSI", "BATTERY", "LOGGING INTERVAL", "NUMBER OF RECORDS", "MODE", "CURRENT", "TEMPERATURE", "HUMIDITY", "DEW POINT", "HIGHEST AND LOWEST RECORDED", "HIGHEST TEMEPERATURE", "HIGHEST HUMIDITY", "LOWEST TEMEPERATURE", "LOWEST HUMIDITY", "LAST 24 HOURS", "HIGHEST TEMEPERATURE", "LOWEST TEMEPERATURE"]
    let rightLabelValues = ["BA248102-22CD-4056-972C-C4B88F99786C", "22", "30 dBm", "100%", "3600 seconds", "661", "1", "", "21.1 °Celsius", "59% RH", "13 °Celsius", "", "25.9 °Celsius", "73% RH", "11.1 °Celsius", "43% RH", "", "21.6 °Celsius", "15.2 °Celsius"]
    
    let navigationTitles = ["History Device Details", "Device Graphs", "Table"]
    
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
        return 10
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
    }
    
    func getDetailsCell(indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "IndividualDeviceNameTableViewCell", for: indexPath)
            return cell
        }
        if let cell = self.tableView.dequeueReusableCell(withIdentifier: "IndividualDeviceDataTableViewCell", for: indexPath) as? IndividualDeviceDataTableViewCell {
            if indexPath.row - 1 < leftLabelValues.count && indexPath.row - 1 < rightLabelValues.count {
                let leftLabelText = leftLabelValues[indexPath.row - 1] + ":"
                let rightLabelText = rightLabelValues[indexPath.row - 1]
                if rightLabelText == "" {
                    cell.leftLabel.font = UIFont.boldSystemFont(ofSize: 17)
                }
                cell.leftLabel.text = leftLabelText
                cell.rightLabel.text = rightLabelText
            }
            return cell
        }
        return UITableViewCell()
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
        if indexPath.row != 9 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "SingleReadingTableViewCell", for: indexPath)
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
    }
    
    // MARK: Graph Selection Delegate
    
    func allData() {
        
    }
    
    func selectRange() {
        
    }
    
    // MARK: Export Data Delegate
    
    func exportAsPDF() {
        
    }
    
    func exportAsCSV() {
        
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
