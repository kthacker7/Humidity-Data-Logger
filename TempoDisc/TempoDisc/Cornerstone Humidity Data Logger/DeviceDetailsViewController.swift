//
//  DeviceDetailsViewController.swift
//  Cornerstone Humidity Data Logger
//
//  Created by Kunal Thacker on 12/18/16.
//  Copyright © 2016 Cornerstone Humidity. All rights reserved.
//

import UIKit

class DeviceDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    let flatTexts = ["Flat No. 1 (3)", "Flat No. 12 (2)", "Flat No. 15 (4)", "Flat No. 34 (4)"]
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceDetailsTableViewCell", for: indexPath) as! DeviceDetailsTableViewCell
        cell.flatNumberLabel.text = flatTexts[indexPath.row]
        return cell
    }
    
    // MARK: Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "History", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "DeviceHistoryDetailsViewController") as? DeviceHistoryDetailsViewController  {
            vc.navTitle = self.flatTexts[indexPath.row]
            vc.selectedTab = .Devices
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: Others
    
    func setup() {
        // Register Nibs
        let nib = UINib(nibName: "DeviceDetailsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "DeviceDetailsTableViewCell")
        
        // Height setup
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        // Navigation bar setup
        self.navigationItem.title = "Batch List"
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
