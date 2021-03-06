//
//  HistoryListViewController.swift
//  Cornerstone Humidity Data Logger
//
//  Created by Kunal Thacker on 12/18/16.
//  Copyright © 2016 Cornerstone Humidity. All rights reserved.
//

import UIKit
import CoreData

class HistoryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var deviceList : [TempoDiscDevice] = []
    var deviceGroupsList : [TempoDeviceGroup] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.loadDataSource()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadDataSource()
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
        return self.deviceGroupsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupedSummaryTableViewCell", for: indexPath) as! GroupedSummaryTableViewCell
        cell.dateLabel.isHidden = false
        cell.lastDownloadedAtLabel.isHidden = false
        if indexPath.row < self.deviceGroupsList.count {
            let green = UIColor(colorLiteralRed: 110.0/255.0, green: 206.0/255.0, blue: 26.0/255.0, alpha: 1.0)
            let orange = UIColor(colorLiteralRed: 238.0/255.0, green: 169.0/255.0, blue: 28.0/255.0, alpha: 1.0)
            let red = UIColor(colorLiteralRed: 201.0/255.0, green: 0.0/255.0, blue: 25.0/255.0, alpha: 1.0)
            
            let group = self.deviceGroupsList[indexPath.row]
            let bsVal = self.calculateValueForGroup(group: group)
            cell.groupNameLabel.text =  group.groupName + " (\(group.internalDevices.count + 1))"
            if bsVal < 0.3 {
                cell.bsValueLabel.textColor = green
                cell.waterDropImageView.image = #imageLiteral(resourceName: "WaterDropDry")
            } else if bsVal >= 0.3 && bsVal < 0.6 {
                cell.bsValueLabel.textColor = orange
                cell.waterDropImageView.image = #imageLiteral(resourceName: "WaterDropMoist")
            } else {
                cell.bsValueLabel.textColor = red
                cell.waterDropImageView.image = #imageLiteral(resourceName: "WaterDropWet")
            }
            cell.bsValueLabel.text = String(round(bsVal * 100)/100)
           
            if group.externalDevice != nil && group.externalDevice!.lastDownload != nil {
                let dateFormat = group.externalDevice!.lastDownload!
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yy' at 'h:mm a."
                let selectedDate = dateFormatter.string(from: dateFormat)
                cell.dateLabel.text = selectedDate
                
            } else {
                cell.dateLabel.text = "-"
            }
        }
        return cell
    }
    
    
    // MARK: Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "History", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "DeviceHistoryDetailsViewController") as? DeviceHistoryDetailsViewController  {
            vc.selectedTab = .History
            if indexPath.row < self.deviceGroupsList.count {
                vc.deviceGroup = self.deviceGroupsList[indexPath.row]
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: Others
    
    func setup() {
        // Register Nibs
        let nib = UINib(nibName: "DeviceDetailsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "DeviceDetailsTableViewCell")
        let nib2 = UINib(nibName: "GroupedSummaryTableViewCell", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "GroupedSummaryTableViewCell")
        
        // Height setup
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        // Navigation bar setup
        self.navigationItem.title = "History List"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: nil, action: nil)
        self.navigationController?.navigationBar.backIndicatorImage = UIImage()
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage()
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    
    func loadDataSource() {
        let request = NSFetchRequest<TempoDiscDevice>(entityName: NSStringFromClass(TempoDiscDevice.classForCoder()))
        request.predicate = NSPredicate(format: "readingTypes.@count > 0")
        do {
            if let delegate =  (UIApplication.shared.delegate) as? AppDelegate {
                let result = try delegate.managedObjectContext.fetch(request)
                self.deviceList = result
                self.groupDevices()
                self.tableView.reloadData()
                
//                if let result = (resultt as? [TDTempoDisc]) {
//                    self.deviceList = result
//                    self.groupDevices()
//                    self.tableView.reloadData()
//                }
            }
        }
        catch {
            
        }
        
    }
    
    func groupDevices() {
        var externals : [TempoDiscDevice] = []
        for device in self.deviceList {
            if device.name != nil && (device.name!.hasSuffix("-E") || device.name!.hasSuffix("-e")){
                externals.append(device)
            }
        }
        var deviceGroups : [TempoDeviceGroup] = []
        for external in externals {
            if external.name != nil {
                var internals : [TempoDiscDevice] = []
                var groupName = ""
                let range = (external.name! as NSString).range(of: "-", options: .backwards)
                if range.location != NSNotFound {
                    groupName = String(external.name!.characters.dropLast(external.name!.characters.count - range.location))
                }
                for device in self.deviceList {
                    if device.name != nil && ((device.name! as NSString).range(of: groupName).location != NSNotFound) && device != external {
                        internals.append(device)
                    }
                }
                internals.sort(by: { (device1, device2) -> Bool in
                    let name1 = device1.name?.replacingOccurrences(of: " ", with: "")
                    let name2 = device2.name?.replacingOccurrences(of: " ", with: "")
                    return device1.name == nil || device2.name == nil || (name1!.compare(name2!) == .orderedAscending)
                })
                let newTempGroup = TempoDeviceGroup()
                newTempGroup.externalDevice = external
                newTempGroup.internalDevices = internals
                newTempGroup.groupName = groupName
                if (newTempGroup.externalDevice != nil || newTempGroup.externalDiscDevice != nil) && (newTempGroup.internalDiscDevices.count > 0 || newTempGroup.internalDevices.count > 0) {
                    deviceGroups.append(newTempGroup)
                }
            }
        }
        self.deviceGroupsList = deviceGroups
    }
    
    func calculateValueForGroup(group: TempoDeviceGroup) -> Double{
        if group.internalDevices.count == 0 || group.externalDevice == nil {
            return 0.0
        }
        var internalGPKgAverage = 0.0
        var internalVPAverage = 0.0
        for internalDevice in group.internalDevices {
            let intern = internalDevice
            let svp = 610.78 * exp((Double(intern.averageDayTemperature!) * 17.2694) / (Double(intern.averageDayTemperature!) + 238.3))
            let vp = (svp / 1000.0) * (Double(intern.averageDayHumidity!) / 100.0)
            let gpm3 = ((vp * 1000.0) / ((273.0 + Double(intern.averageDayTemperature!)) * 461.5)) * 1000.0
            let gpkg = gpm3 * 0.83174
            internalGPKgAverage += gpkg
            internalVPAverage += vp
            
        }
        if group.internalDevices.count != 0 {
            internalVPAverage /= Double(group.internalDevices.count)
            internalGPKgAverage /= Double(group.internalDevices.count)
        }
        if let externalDevice = group.externalDevice {
            let svp = 610.78 * exp((Double(externalDevice.averageDayTemperature!) * 17.2694) / (Double(externalDevice.averageDayTemperature!) + 238.3))
            let vp = (svp / 1000.0) * (Double(externalDevice.averageDayHumidity!) / 100.0)
            
            let bsReading = internalVPAverage - vp
            return bsReading
        }
        return 0.0
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
