//
//  ResetDevicesViewController.swift
//  Cornerstone Humidity Data Logger
//
//  Created by Kunal Thacker on 12/19/16.
//  Copyright © 2016 Cornerstone Humidity. All rights reserved.
//

import UIKit

class ResetDevicesViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    var deviceGroup: TempoDeviceGroup?
    var internalIndex = 0
    var toWriteData : String?
    let helper = TempoHelperMethods()
    var appearanceDate : Date?
    
    @IBOutlet weak var greyView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(ResetDevicesViewController.resetInternalDevices), name: Notification.Name.init("ResetComplete"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.appearanceDate = Date()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup() {
        // Setup Reset button
        self.resetButton.layer.cornerRadius = 5.0
        self.resetButton.layer.borderColor = UIColor(colorLiteralRed: 197.0/255.0, green: 10.0/255.0, blue: 39.0/255.0, alpha: 1.0).cgColor
        self.resetButton.layer.borderWidth = 1.0
        
        // Navigation bar
        self.navigationItem.title = "Reset Devices"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: nil, action: nil)
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a, EEE dd MMM yyyy "
        self.dateLabel.text = formatter.string(from: self.datePicker.date)
        
        self.greyView.isHidden = true
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a, EEE dd MMM yyyy "
        self.dateLabel.text = formatter.string(from: sender.date)
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        self.greyView.isHidden = false
        while (Date().timeIntervalSince(self.appearanceDate!) < 3) {
            
        }
        let selectedDate = datePicker.date
        let formatter = DateFormatter()
        
        formatter.dateFormat = "YYMMddHHmm"
        let dateToWrite = "*d\(formatter.string(from: selectedDate))"
        self.helper.didDisconnect = true
        //        helper.connectAndWrite("*rst")
        if self.deviceGroup != nil {
            //            if let downloader = TDUARTDownloader.shared() {
            if let externalDevice = self.deviceGroup!.externalDevice {
                TDDefaultDevice.shared().selectedDevice = externalDevice
                helper.connectAndWrite("*clr", withCompletion: {success in
                    if (success) {
                        self.helper.didDisconnect = true
                        NSLog("KT: Connected to external: clr")
                        externalDevice.peripheral?.disconnect(completion: { (error) in
                            NSLog("KT: Disonnected to external: clr")
                            self.internalIndex = 0
                            self.toWriteData = dateToWrite
                            self.helper.connectAndWrite(dateToWrite, withCompletion: { success in
                                if (success) {
                                    NSLog("KT: Connected to external: date")
                                    externalDevice.peripheral?.disconnect(completion: { (error) in
                                        NSLog("KT: Disconnected to external: date")
                                        self.helper.didDisconnect = true
                                        NotificationCenter.default.post(name: Notification.Name.init("ResetComplete"), object: self)
                                    })
                                } else {
                                    let alert = UIAlertController(title: "Oops!", message: "Failed to reset devices, please try again!", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                    self.greyView.isHidden = true
                                }
                            })
                        })
                    } else {
                        let alert = UIAlertController(title: "Oops!", message: "Failed to reset devices, please try again!", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.greyView.isHidden = true
                    }
                })
            }
        }
    }
    
    func resetInternalDevices(notification: Notification) {
        
        if self.internalIndex < self.deviceGroup!.internalDevices.count {
            self.internalIndex += 1
            self.resetDataFor(device: self.deviceGroup!.internalDevices[self.internalIndex - 1], helper: self.helper)
        } else if self.internalIndex == self.deviceGroup!.internalDevices.count {
            let alert = UIAlertController(title: "Success!", message: "Resetting data was successful!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {_ in
                let _ = self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
            self.greyView.isHidden = true
        }
        
    }
    
    func resetDataFor(device: TempoDiscDevice, helper: TempoHelperMethods) {
        TDDefaultDevice.shared().selectedDevice = device
        helper.connectAndWrite("*clr", withCompletion: { success in
            if (success) {
                NSLog("KT: Connected to internal: clr")
                device.peripheral?.disconnect(completion: { (error) in
                    NSLog("KT: Disconnected to internal: clr")
                    self.helper.didDisconnect = true
                    self.helper.connectAndWrite(self.toWriteData, withCompletion: { success in
                        if (success) {
                            NSLog("KT: Connected to internal: date")
                            self.helper.didDisconnect = true
                            device.peripheral?.disconnect(completion: { (error) in
                                NSLog("KT: Connected to internal: date")
                                NotificationCenter.default.post(name: Notification.Name.init("ResetComplete"), object: self)
                            })
                        } else {
                            let alert = UIAlertController(title: "Oops!", message: "Failed to download data, please try again!", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            self.greyView.isHidden = true
                        }
                    })
                })
            } else {
                let alert = UIAlertController(title: "Oops!", message: "Failed to download data, please try again!", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.greyView.isHidden = true
            }
        })
        
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
