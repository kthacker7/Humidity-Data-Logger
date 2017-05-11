//
//  DeviceDetailsViewController.swift
//  Cornerstone Humidity Data Logger
//
//  Created by Kunal Thacker on 12/18/16.
//  Copyright © 2016 Cornerstone Humidity. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth

class DeviceDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let flatTexts = ["Flat No. 1 (3)", "Flat No. 12 (2)", "Flat No. 15 (4)", "Flat No. 34 (4)"]
    
    @IBOutlet weak var greyView: UIView!
    var devices: [TDTempoDisc] = []
    var deviceGroups : [TempoDeviceGroup] = []
    var firstAttempt = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setup()
        //        UIApplication.shared.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Devices count setup
        self.firstAttempt = true
        
        self.greyView.isHidden = true
        //        if #available(iOS 10.0, *) {
        //        let bluetoothManager: CBCentralManager = CBCentralManager()
        //            switch bluetoothManager.state {
        //            case CBManagerState.poweredOff:
        //                let alert = UIAlertController(title: "Oops!", message: "Please turn on bluetooth to be able to use Cornerstone Data Logger app!", preferredStyle: UIAlertControllerStyle.alert)
        //                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        //                break
        //            case CBManagerState.poweredOn:
        //                self.scanButtonTapped()
        //                break
        //            default :
        //                break
        //            }
        //        } else {
        //            // Fallback on earlier versions
        //        }
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
        return self.deviceGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupedSummaryTableViewCell", for: indexPath) as! GroupedSummaryTableViewCell
        
        if indexPath.row < self.deviceGroups.count {
            let green = UIColor(colorLiteralRed: 110.0/255.0, green: 206.0/255.0, blue: 26.0/255.0, alpha: 1.0)
            let orange = UIColor(colorLiteralRed: 238.0/255.0, green: 169.0/255.0, blue: 28.0/255.0, alpha: 1.0)
            let red = UIColor(colorLiteralRed: 201.0/255.0, green: 0.0/255.0, blue: 25.0/255.0, alpha: 1.0)
            
            let group = self.deviceGroups[indexPath.row]
            let bsVal = self.calculateValueForGroup(group: group)
            cell.groupNameLabel.text = "Group name - " + group.groupName + "(\(group.internalDevices.count + 1))"
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
        }
        return cell
    }
    
    // MARK: Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "History", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "DeviceHistoryDetailsViewController") as? DeviceHistoryDetailsViewController  {
            if indexPath.row < self.deviceGroups.count {
                let group = self.deviceGroups[indexPath.row]
                vc.navTitle = group.groupName + " (\(group.internalDevices.count + 1))"
                vc.selectedTab = .Devices
                vc.deviceGroup = group
                self.navigationController?.pushViewController(vc, animated: true)
            }
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
        self.navigationItem.title = "Device Group List"
        let scanButton = UIBarButtonItem(title: "Scan", style: .plain, target: self, action: #selector(DeviceDetailsViewController.scanButtonTapped))
        scanButton.tintColor = UIColor.white
        scanButton.setTitleTextAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)], for: .normal)
        self.navigationItem.rightBarButtonItem = scanButton
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: nil, action: nil)
        self.navigationController?.navigationBar.backIndicatorImage = UIImage()
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        
    }
    
    func scanButtonTapped() {
        self.greyView.isHidden = false
        self.deviceGroups = []
        self.tableView.reloadData()
        LGCentralManager.sharedInstance().scanForPeripherals(byInterval: 5, services: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true], completion: { peripherals in
            DispatchQueue.main.async {
                if (peripherals == nil || peripherals!.count == 0)  {
                    if (self.firstAttempt) {
                        self.firstAttempt = false
                        self.scanButtonTapped()
                    } else {
                        let alert = UIAlertController(title: "Oops", message: "Oops, no nearby devices found. Please try to scan again, or check if the data loggers are out of battery!", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.greyView.isHidden = true
                    }
                } else {
                    for peripheral in peripherals as! [LGPeripheral] {
                        //                    let context = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
                        //                    [(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext];
                        
                        // [TempoDiscDevice deviceWithName:peripheral.name data:peripheral.advertisingData uuid:peripheral.cbPeripheral.identifier.UUIDString context:context];
                        var toAdd = true
                        var i = 0
                        if let newDevice = TDHelper.findOrCreateDevice(for: peripheral) {
                            newDevice.peripheral = peripheral
                            for device in self.devices {
                                if device.uuid != nil && device.uuid == newDevice.uuid {
                                    toAdd = false
                                    break
                                }
                                i += 1
                            }
                            if toAdd {
                                
                                self.devices.append(newDevice)
                            } else {
                                self.devices.remove(at: i)
                                self.devices.append(newDevice)
                            }
                        }
                    }
                    self.groupDevices()
                    self.tableView.reloadData()
                    self.greyView.isHidden = true
                }
            }
        })
    }
    
    func groupDevices() {
        var externals : [TempoDiscDevice] = []
        
        for device in self.devices {
            if device.name != nil && (device.name!.hasSuffix("-E") || device.name!.hasSuffix("-e")) {
                if let toAdd = TempoHelperMethods.td(toTempo: device) {
                    toAdd.peripheral = device.peripheral
                    externals.append(toAdd)
                }
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
                
                for device in self.devices {
                    if device.name != nil && ((device.name! as NSString).range(of: groupName).location != NSNotFound) && device.name != external.name {
                        if let toAdd = TempoHelperMethods.td(toTempo: device) {
                            toAdd.peripheral = device.peripheral
                            internals.append(toAdd)
                        }
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
        self.deviceGroups = deviceGroups
    }
    
    func calculateValueForGroup(group: TempoDeviceGroup) -> Double{
        if group.internalDevices.count == 0 || group.externalDevice == nil {
            return 0.0
        }
        var internalGPKgAverage = 0.0
        var internalVPAverage = 0.0
        for intern in group.internalDevices {
            
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
