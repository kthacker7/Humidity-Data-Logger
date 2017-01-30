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
        let _ = self.navigationController?.popViewController(animated: true)
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
