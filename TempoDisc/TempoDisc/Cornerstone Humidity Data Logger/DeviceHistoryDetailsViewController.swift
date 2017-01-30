//
//  DeviceHistoryDetailsViewController.swift
//  Cornerstone Humidity Data Logger
//
//  Created by Kunal Thacker on 12/18/16.
//  Copyright © 2016 Cornerstone Humidity. All rights reserved.
//

import UIKit

enum SelecedTab {
    case Devices
    case History
}

class DeviceHistoryDetailsViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.hideButtonsIfNeeded()
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
        self.hideOverlay()
    }
    
    func hideButtonsIfNeeded() {
        // Hide buttons if selected tab is history
        if self.selectedTab == .History {
            self.downloadLogButton.isHidden = true
            self.resetDevicesHeightConstraint.constant = 0
            self.topSeparator.isHidden = true
            self.bottomSeparator.isHidden = true
        } else {
            self.downloadLogButton.isHidden = false
            self.resetDevicesHeightConstraint.constant = 28
            self.topSeparator.isHidden = false
            self.bottomSeparator.isHidden = false
            
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
        vc.selectedTab = self.selectedTab
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func resetButtonTapped() {
        let storyboard = UIStoryboard(name: "Devices", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ResetDevicesViewController")
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func downloadLogPressed(_ sender: Any) {
        self.showOverlay()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.hideOverlay()
    }
    
    @IBAction func downloadAllTapped(_ sender: Any) {
        self.hideOverlay()
    }
    
    @IBAction func downloadNewTapped(_ sender: Any) {
        self.hideOverlay()
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
