//
//  BatchHistoryViewController.swift
//  Cornerstone Humidity Data Logger
//
//  Created by Kunal Thacker on 12/18/16.
//  Copyright © 2016 Cornerstone Humidity. All rights reserved.
//

import UIKit

class BatchHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var selectedTab: SelecedTab = .Devices
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2            // 1 for external logger, 1 for internal
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceDetailsTableViewCell", for: indexPath) as? DeviceDetailsTableViewCell {
                cell.humidityImageWidthConstraint.constant = 0
                cell.humidityImageLeadingConstraint.constant = 0
                cell.backgroundColor = UIColor(colorLiteralRed: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)
                return cell
            }
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "InternalDeviceDetailsTableViewCell", for: indexPath)
        return cell
    }
    
    // MARK: Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "History", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "IndividualDeviceDataViewController") as! IndividualDeviceDataViewController
        vc.selectedTab = self.selectedTab
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: Others
    
    func setup() {
        // Register Nibs
        let nib1 = UINib(nibName: "InternalDeviceDetailsTableViewCell", bundle: nil)
        self.tableView.register(nib1, forCellReuseIdentifier: "InternalDeviceDetailsTableViewCell")
        let nib2 = UINib(nibName: "DeviceDetailsTableViewCell", bundle: nil)
        self.tableView.register(nib2, forCellReuseIdentifier: "DeviceDetailsTableViewCell")
        
        // Table view height setup
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 150.0
        
        // Navigation Bar setup
        self.navigationItem.title = "Device List"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .done, target: nil, action: nil)
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
