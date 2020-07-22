//
//  MapViewController.swift
//  Work It
//
//  Created by qw on 07/05/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import CoreLocation

class MapViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var mapView: MapVC!
    
    
    var latitude = CLLocationDegrees()
    var longitude = CLLocationDegrees()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.latitude = self.latitude
        self.mapView.longitude = self.longitude
    }
  
    //MARK: IBActions
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
