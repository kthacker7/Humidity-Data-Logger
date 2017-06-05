//
//  MainTabBarViewController.swift
//  Cornerstone Humidity Data Logger
//
//  Created by Kunal Thacker on 12/17/16.
//  Copyright © 2016 Cornerstone Humidity. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let selectedImages = [#imageLiteral(resourceName: "DevicesActive"), #imageLiteral(resourceName: "HistoryActive"), #imageLiteral(resourceName: "GlossaryActive"), #imageLiteral(resourceName: "AboutActive")]
        let images = [#imageLiteral(resourceName: "DevicesInactive"), #imageLiteral(resourceName: "HistoryInactive"), #imageLiteral(resourceName: "GlossaryInactive"), #imageLiteral(resourceName: "AboutInactive")]
        var i = 0
        if let items = self.tabBar.items {
            for item in items {
                item.setTitleTextAttributes([NSForegroundColorAttributeName: #colorLiteral(red: 0.7568627451, green: 0.03921568627, blue: 0.1529411765, alpha: 1)], for: .selected)
                item.setTitleTextAttributes([NSForegroundColorAttributeName: #colorLiteral(red: 0.3803921569, green: 0.6431372549, blue: 0.8431372549, alpha: 1)], for: .normal)
                item.image = images[i].withRenderingMode(.alwaysOriginal)
                item.selectedImage = selectedImages[i].withRenderingMode(.alwaysOriginal)
                i += 1
            }
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
