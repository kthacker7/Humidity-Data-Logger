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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup() {
        // Setup Reset button
        self.resetButton.layer.cornerRadius = 10.0
        self.resetButton.layer.borderColor = UIColor(colorLiteralRed: 197.0/255.0, green: 10.0/255.0, blue: 39.0/255.0, alpha: 1.0).cgColor
        self.resetButton.layer.borderWidth = 1.0
        
        // Navigation bar
        self.navigationItem.title = "Reset Devices"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: nil, action: nil)
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a, EEE dd MMM yyyy "
        self.dateLabel.text = formatter.string(from: self.datePicker.date)
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a, EEE dd MMM yyyy "
        self.dateLabel.text = formatter.string(from: sender.date)
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        let selectedDate = datePicker.date
        let formatter = DateFormatter()
        
        formatter.dateFormat = "YYMMddHHmm"
        var dateToWrite = "*d\(formatter.string(from: selectedDate))"
        let helper = TempoHelperMethods()
        //        helper.connectAndWrite("*rst")
        let _ = self.navigationController?.popViewController(animated: true)
        if self.deviceGroup != nil {
            //            if let downloader = TDUARTDownloader.shared() {
            if let externalDevice = self.deviceGroup!.externalDevice {
                TDDefaultDevice.shared().selectedDevice = externalDevice
                helper.connectAndWrite("*clr")
                helper.connectAndWrite(dateToWrite)
                externalDevice.peripheral?.disconnect(completion: { (error) in
                    if  (error == nil) {
                        for internalDevice in self.deviceGroup!.internalDevices {
                            //                            downloader.refreshDownloader()
                            
                            TDDefaultDevice.shared().selectedDevice = internalDevice
                            helper.connectAndWrite("*clr")
                            helper.connectAndWrite(dateToWrite)
                            
                        }
                    } else {
                        let alert = UIAlertController(title: "Oops!", message: "Failed to reset devices, please try again!", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
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
