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
    
    let flatTexts = ["Flat No. 1", "Flat No. 12", "Flat No. 15"]
    let batchQuantities = ["(3)", "(2)", "(4)"]
    
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceDetailsTableViewCell", for: indexPath) as! DeviceDetailsTableViewCell
        cell.flatNumberLabel.text =  "\(self.flatTexts[indexPath.row]) \(batchQuantities[indexPath.row])"
        return cell
    }

    // MARK: Table View Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "History", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "DeviceHistoryDetailsViewController") as? DeviceHistoryDetailsViewController  {
            vc.navTitle = "\(self.flatTexts[indexPath.row]) History"
            vc.selectedTab = .History
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
    
    func loadDataSource() {
        let request = NSFetchRequest<TempoDiscDevice>(entityName: NSStringFromClass(TempoDiscDevice.classForCoder()))
        request.predicate = NSPredicate(format: "readingTypes.@count > 0")
        do {
            
            if let delegate =  (UIApplication.shared.delegate) as? AppDelegate {
                let result = try delegate.managedObjectContext.fetch(request)
                NSLog(result.description)
            }
        }
        catch {
            
        }
        
//        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([TempoDiscDevice class])];
//        request.predicate = [NSPredicate predicateWithFormat:@"readingTypes.@count > 0"];
//        NSArray *result = [[(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext] executeFetchRequest:request error:nil];
//        [self.controllerDeviceList loadDevices:result];
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
