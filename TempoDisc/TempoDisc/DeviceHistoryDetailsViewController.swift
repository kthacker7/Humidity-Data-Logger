//
//  DeviceHistoryDetailsViewController.swift
//  Cornerstone Humidity Data Logger
//
//  Created by Kunal Thacker on 12/18/16.
//  Copyright © 2016 Cornerstone Humidity. All rights reserved.
//

import UIKit
import MessageUI

enum SelecedTab {
    case Devices
    case History
}

class DeviceHistoryDetailsViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var devicesButtonView: UIView!
    
    var navTitle: String?
    
    @IBOutlet weak var resetDevicesHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var resetDevicesButtonView: UIView!
    @IBOutlet weak var downloadLogButton: UIButton!
    
    // Separators
    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var bottomSeparator: UIView!
    
    var selectedTab: SelecedTab = .Devices
    
    @IBOutlet weak var greyView: UIView!
    @IBOutlet weak var downloadButtonsView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    
    var deviceGroup : TempoDeviceGroup?
    var internalIndex = 0
    var downloader = (TDUARTDownloader.shared())!
    
    // UI Variable Elements
    @IBOutlet weak var externalAHLabel: UILabel!
    @IBOutlet weak var externalPressureLabel: UILabel!
    
    @IBOutlet weak var internalAHLabel: UILabel!
    @IBOutlet weak var internalPressureLabel: UILabel!
    
    @IBOutlet weak var bsOutcomeLabel: UILabel!
    @IBOutlet weak var bsDescriptionLabel: UILabel!
    
    @IBOutlet weak var outcomeImageView: UIImageView!
    
    @IBOutlet weak var devicesCountLabel: UILabel!
    @IBOutlet weak var exportGroupDataAsCsvButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setup()
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideButtonsIfNeeded()
        NotificationCenter.default.addObserver(self, selector: #selector(DeviceHistoryDetailsViewController.downloadLogForInternalDevices), name: Notification.Name.init("DownloadComplete"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Others
    
    func setup() {
        // Add gesture recognizers
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DeviceHistoryDetailsViewController.devicesButtonTapped))
        self.devicesButtonView.addGestureRecognizer(gestureRecognizer)
        let gestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(DeviceHistoryDetailsViewController.resetButtonTapped))
        self.resetDevicesButtonView.addGestureRecognizer(gestureRecognizer2)
        let gestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(DeviceHistoryDetailsViewController.hideOverlay))
        self.greyView.addGestureRecognizer(gestureRecognizer3)
        
        // Setup navigation bar
        self.navigationItem.title = self.navTitle
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: nil, action: nil)
        
        // Download Log Button Setup
        self.downloadLogButton.layer.cornerRadius = 5.0
        self.downloadLogButton.layer.borderWidth = 1.0
        self.downloadLogButton.layer.borderColor = UIColor(colorLiteralRed: 197.0/255.0, green: 10.0/255.0, blue: 39.0/255.0, alpha: 1.0).cgColor
        
        // Setup overlay
        self.cancelButton.layer.cornerRadius = 15.0
        self.downloadButtonsView.layer.cornerRadius = 15.0
        self.exportGroupDataAsCsvButton.layer.cornerRadius = 5.0
        self.exportGroupDataAsCsvButton.layer.borderWidth = 1.0
        self.exportGroupDataAsCsvButton.layer.borderColor = UIColor(colorLiteralRed: 197.0/255.0, green: 10.0/255.0, blue: 39.0/255.0, alpha: 1.0).cgColor
        self.hideOverlay()
    }
    
    func setupUI() {
        if let group = self.deviceGroup {
            if group.internalDevices.count == 0 || group.externalDevice == nil {
                return
            }
            self.devicesCountLabel.text = "(\(group.internalDevices.count + 1))"
            var internalGPKgAverage = 0.0
            var internalVPAverage = 0.0
            for intern in group.internalDevices {
                //                if let intern = internalDevice as? TempoDiscDevice {
                let svp = 610.78 * exp((Double(intern.averageDayTemperature!) * 17.2694) / (Double(intern.averageDayTemperature!) + 238.3))
                let vp = (svp / 1000.0) * (Double(intern.averageDayHumidity!) / 100.0)
                let gpm3 = ((vp * 1000.0) / ((273.0 + Double(intern.averageDayTemperature!)) * 461.5)) * 1000.0
                let gpkg = gpm3 * 0.83174
                internalGPKgAverage += gpkg
                internalVPAverage += vp
                //                }
            }
            if group.internalDevices.count != 0 {
                internalVPAverage /= Double(group.internalDevices.count)
                internalGPKgAverage /= Double(group.internalDevices.count)
            }
            if let externalDevice = group.externalDevice {
                let svp = 610.78 * exp((Double(externalDevice.averageDayTemperature!) * 17.2694) / (Double(externalDevice.averageDayTemperature!) + 238.3))
                let vp = (svp / 1000.0) * (Double(externalDevice.averageDayHumidity!) / 100.0)
                let gpm3 = ((vp * 1000.0) / ((273.0 + Double(externalDevice.averageDayTemperature!)) * 461.5)) * 1000.0
                let gpkg = gpm3 * 0.83174
                
                let bsVal = internalVPAverage - vp
                //            green 110 206 26
                //            orange 238 169 28
                //            red 201 0 25
                let green = UIColor(colorLiteralRed: 110.0/255.0, green: 206.0/255.0, blue: 26.0/255.0, alpha: 1.0)
                let orange = UIColor(colorLiteralRed: 238.0/255.0, green: 169.0/255.0, blue: 28.0/255.0, alpha: 1.0)
                let red = UIColor(colorLiteralRed: 201.0/255.0, green: 0.0/255.0, blue: 25.0/255.0, alpha: 1.0)
                if bsVal < 0.3 {
                    self.bsDescriptionLabel.text = "Dry Occupancy"
                    self.bsDescriptionLabel.textColor = green
                    self.bsOutcomeLabel.textColor = green
                    self.outcomeImageView.image = #imageLiteral(resourceName: "WaterDropDry")
                } else if bsVal >= 0.3 && bsVal < 0.6 {
                    self.bsDescriptionLabel.textColor = orange
                    self.bsOutcomeLabel.textColor = orange
                    self.bsDescriptionLabel.text = "Moist Occupancy"
                    self.outcomeImageView.image = #imageLiteral(resourceName: "WaterDropMoist")
                } else {
                    self.bsDescriptionLabel.textColor = red
                    self.bsOutcomeLabel.textColor = red
                    self.bsDescriptionLabel.text = "Wet Occupancy"
                    self.outcomeImageView.image = #imageLiteral(resourceName: "WaterDropWet")
                }
                self.bsOutcomeLabel.text = String(round(bsVal * 100.0)/100.0)
                
                self.internalAHLabel.text = String(round(internalGPKgAverage * 100.0) / 100.0)
                self.internalPressureLabel.text = String(round(internalVPAverage * 100.0) / 100.0)
                
                self.externalAHLabel.text = String(round(gpkg * 100.0) / 100.0)
                self.externalPressureLabel.text = String(round(vp * 100.0) / 100.0)
            }
        }
        
    }
    
    
    
    func hideButtonsIfNeeded() {
        // Hide buttons if selected tab is history
        if self.selectedTab == .History {
            self.downloadLogButton.isHidden = true
            self.resetDevicesHeightConstraint.constant = 0
            self.topSeparator.isHidden = true
            self.bottomSeparator.isHidden = true
            self.exportGroupDataAsCsvButton.isHidden = false
        } else {
            self.downloadLogButton.isHidden = false
            self.resetDevicesHeightConstraint.constant = 28
            self.topSeparator.isHidden = false
            self.bottomSeparator.isHidden = false
            self.exportGroupDataAsCsvButton.isHidden = true
        }
    }
    
    func hideOverlay() {
        self.greyView.isHidden = true
        self.cancelButton.isHidden = true
        self.downloadButtonsView.isHidden = true
    }
    
    func showOverlay() {
        self.greyView.isHidden = false
        self.cancelButton.isHidden = false
        self.downloadButtonsView.isHidden = false
    }
    
    func devicesButtonTapped() {
        let storyboard = UIStoryboard(name: "History", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BatchHistoryViewController") as! BatchHistoryViewController
        vc.deviceGroup = self.deviceGroup
        vc.selectedTab = self.selectedTab
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func resetButtonTapped() {
        let storyboard = UIStoryboard(name: "Devices", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ResetDevicesViewController") as! ResetDevicesViewController
        vc.deviceGroup = self.deviceGroup
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func exportButtonTapped(_ sender: Any) {
        if self.deviceGroup != nil {
            let filePath = TempoHelperMethodsSwift.createCSVFileForGroup(deviceGroup: self.deviceGroup!)
            let mailComposeVC = MFMailComposeViewController()
            mailComposeVC.mailComposeDelegate = self
            mailComposeVC.modalPresentationStyle = .pageSheet
            mailComposeVC.setSubject("Group Device Data Export for \(self.deviceGroup!.groupName)")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            let data = NSData.dataWithContentsOfMappedFile(filePath)
            if self.deviceGroup?.groupName != nil {
                let date = dateFormatter.string(from: Date())
                mailComposeVC.addAttachmentData(data as! Data, mimeType: "text/csv", fileName: (self.deviceGroup?.groupName)! + " " + date)
            }
            self.present(mailComposeVC, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func downloadLogPressed(_ sender: Any) {
        self.showOverlay()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.hideOverlay()
    }
    
    
    @IBAction func downloadAllTapped(_ sender: Any) {
        if self.deviceGroup != nil {
            
            let externalTDDevice = self.deviceGroup!.externalDevice
            if let externalDevice = externalTDDevice {
                TDDefaultDevice.shared().selectedDevice = externalDevice
                downloader.downloadData(for: externalDevice, withCompletion: { success in
                    if success {
                        externalDevice.peripheral?.disconnect(completion: { (error) in
                            if  (error == nil) {
                                self.internalIndex = 0
                                NotificationCenter.default.post(name: Notification.Name.init("DownloadComplete"), object: self)
                            } else {
                                let alert = UIAlertController(title: "Oops!", message: "Failed to download data, please try again!", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                self.setupUI()
                            }
                        })
                    } else {
                        let alert = UIAlertController(title: "Oops!", message: "Failed to download data, please try again!", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
        self.hideOverlay()
    }
    
    func downloadLogForInternalDevices(notification: Notification) {
        if (self.internalIndex > 0) {
            let prevDevice = self.deviceGroup!.internalDevices[self.internalIndex-1]
            prevDevice.peripheral?.disconnect(completion: { (error) in
                if error == nil {
                    if self.internalIndex < self.deviceGroup!.internalDevices.count {
                        self.downloadDataFor(device: self.deviceGroup!.internalDevices[self.internalIndex], downloader: self.downloader)
                        self.internalIndex += 1
                    } else {
                        let alert = UIAlertController(title: "Success", message: "Download of logs were successful! You can now see the logs in the History tab.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    self.setupUI()
                } else {
                    let alert = UIAlertController(title: "Oops!", message: "Failed to download data, please try again!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        } else {
            if self.internalIndex < self.deviceGroup!.internalDevices.count {
                self.downloadDataFor(device: self.deviceGroup!.internalDevices[self.internalIndex], downloader: downloader)
                self.internalIndex += 1
            }
            self.setupUI()
        }
    }
    
    func downloadDataFor(device: TempoDiscDevice, downloader: TDUARTDownloader){
        downloader.refreshDownloader()
        let internalDevice = device
        TDDefaultDevice.shared().selectedDevice = internalDevice
        downloader.downloadData(for: internalDevice, withCompletion: { (success) in
            if (!success) {
                let alert = UIAlertController(title: "Oops!", message: "Failed to download data, please try again!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                NotificationCenter.default.post(name: Notification.Name.init("DownloadComplete"), object: self)
            }
            
        })
    }
    
    @IBAction func downloadNewTapped(_ sender: Any) {
        self.hideOverlay()
        if let downloader = TDUARTAllDataDownloader.shared() {
            for device in self.deviceGroup!.internalDevices {
                if let internalDevice = device as? TempoDiscDevice {
                    TDDefaultDevice.shared().selectedDevice = internalDevice
                    downloader.downloadData(for: internalDevice, withCompletion: { (success) in
                        if (!success) {
                            let alert = UIAlertController(title: "Oops!", message: "Failed to download data, please try again!", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            let alert = UIAlertController(title: "Success", message: "Download of logs were successful! You can now see the logs in the History tab.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    })
                    
                }
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
