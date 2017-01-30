//
//  GlossaryViewController.swift
//  Cornerstone Humidity Data Logger
//
//  Created by Kunal Thacker on 12/18/16.
//  Copyright © 2016 Cornerstone Humidity. All rights reserved.
//

import UIKit

class GlossaryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let leftTitles = ["RH%", "T=", "T=", "T=", "T="]
    let rightTitles = ["Relative Humidity", "Air Temp °C", "Air Temp °C", "Air Temp °C", "Air Temp °C"]
    
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
        return leftTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GlossaryTableViewCell", for: indexPath) as! GlossaryTableViewCell
        if indexPath.row < leftTitles.count && indexPath.row < rightTitles.count {
            cell.leftLabel.text = leftTitles[indexPath.row]
            cell.rightLabel.text = rightTitles[indexPath.row]
        }
        return cell
    }
    
    // MARK: Table View Delegate
    
    
    // MARK: Others
    
    func setup() {
        
        // Register Nibs
        let nib = UINib(nibName: "GlossaryTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "GlossaryTableViewCell")
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
