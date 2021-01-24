//
//  FilterViewController.swift
//  Work It
//
//  Created by qw on 14/01/20.
//  Copyright © 2020 qw. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation

protocol ApplyFilter{
    func reloadTable(approach: String, price: Float, distance: Float, address: String, lat: CLLocationDegrees, long: CLLocationDegrees)
}

class FilterViewController: UIViewController, SelectFromPicker{
    func selectedItem(name: String, id: Int) {
        currentApproach = name
        self.type.text = name
    }

    @IBOutlet weak var priceSlider: UISlider!
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var type: UITextField!
    @IBOutlet weak var distanceSliderValue: UILabel!
    @IBOutlet weak var priceSliderValue: UILabel!
    @IBOutlet weak var height : NSLayoutConstraint!
    
    var filterData : [String] = []
    var filterDelegate: ApplyFilter? = nil

    var latitude = CLLocationDegrees()
    var longitude = CLLocationDegrees()
    var locManager =  CLLocationManager()
    var currentLocation: CLLocation!
    private var currentApproach = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.type.text = filterData.first
        currentApproach = filterData.first!
       
         if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                   CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
                   guard let currentLocation = locManager.location else {
                       return
            }
            self.longitude = currentLocation.coordinate.longitude
            self.latitude = currentLocation.coordinate.latitude

            let geoCoder = CLGeocoder()

            geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: { (placemarks, error) -> Void in

                if(placemarks!.count > 0){
                    let placeMark = placemarks?.first!
                    self.address.text = placeMark?.name
                }
               
              
            })
            
        }
        
        if(self.view.frame.size.height == 667.0 || self.view.frame.size.height == 736.0){
            self.height.constant = 50.0
        }
    }
    
    // MARK: IBActions
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectAproach(_ sender: Any){

        let storyboard  = UIStoryboard(name: "Main", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "PickerViewController") as! PickerViewController
        myVC.modalPresentationStyle = .overFullScreen
        myVC.pickerDelegate = self
        myVC.pickerData = self.filterData
        self.present(myVC, animated: true, completion: nil)
    }
    
    @IBAction func addressAction(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue:UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) |
            UInt(GMSPlaceField.coordinate.rawValue) |
            GMSPlaceField.addressComponents.rawValue |
            GMSPlaceField.formattedAddress.rawValue)!
        autocompleteController.placeFields = fields
        
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        autocompleteController.autocompleteFilter = filter
        
        autocompleteController.modalPresentationStyle = .overFullScreen
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func continueAction(_ sender: Any) {
        self.filterDelegate?.reloadTable(approach: currentApproach, price: 5000 * floor(self.priceSlider.value * 20), distance: floor(self.distanceSlider.value * 100) , address: self.address.text ?? "", lat: self.latitude, long: self.longitude)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func priceChangeAction(_ sender: UISlider) {
        if(sender.tag == 0){
            let value = floor(sender.value * 100)
            self.distanceSliderValue.text = "\(value) KM"
        } else {
            let value = 5000 * floor(sender.value * 20)
            self.priceSliderValue.text = "$\(value.formattedWithSeparator)"
        }
      
    }
}

extension FilterViewController: GMSAutocompleteViewControllerDelegate {
   
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.address.text = place.formattedAddress
        self.latitude = place.coordinate.latitude
        self.longitude = place.coordinate.longitude
      
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
      
        
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.dismiss(animated: true, completion: nil)
       
    }
    
  
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

