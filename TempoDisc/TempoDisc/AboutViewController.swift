//
//  AboutViewController.swift
//  Tempo Utility
//
//  Created by Kunal Thacker on 5/30/17.
//  Copyright © 2017 BlueMaestro. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var aboutDescriptionLabel: UILabel!
    @IBOutlet weak var versionNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.versionNumberLabel.text = version
        } else if let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            self.versionNumberLabel.text = version
        } else {
            self.versionNumberLabel.text = "-"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
