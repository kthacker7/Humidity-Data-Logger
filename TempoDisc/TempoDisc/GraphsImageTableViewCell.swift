//
//  GraphsImageTableViewCell.swift
//  Cornerstone Humidity Data Logger
//
//  Created by Kunal Thacker on 12/18/16.
//  Copyright © 2016 Cornerstone Humidity. All rights reserved.
//

import UIKit


enum GraphType {
    case temperature
    case dewpoint
    case humidity
}

class GraphsImageTableViewCell: UITableViewCell {

    @IBOutlet weak var temperatureGraphView: UIView!
    @IBOutlet weak var humidityGraphView: UIView!
    @IBOutlet weak var dewpointGraphView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
//        _hostViewTemperature = [self configureHost:_viewGraphTemperature forGraph:_hostViewTemperature];
//        _graphTemperature = [self configureGraph:_graphTemperature hostView:_hostViewTemperature graphView:_viewGraphTemperature title:nil];
//        _plotTemperature = [self configurePlot:_plotTemperature forGraph:_graphTemperature identifier:@"Temperature"];
//        [self configureAxesForGraph:_graphTemperature plot:_plotTemperature];
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func switchTo(type: GraphType) {
        
    }
}
