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
    func reloadTable(approach: String, price: Float, address: String, lat: CLLocationDegrees, long: CLLocationDegrees)
}

class FilterViewController: UIViewController, GMSAutocompleteViewControllerDelegate{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var priceSlider: UISlider!
    @IBOutlet weak var address: DesignableUITextField!
    @IBOutlet weak var priceSliderValue: UILabel!
    
    var filterData = ["All", "In Person", "Come and get it", "Take it to workplace" ]
    var filterDelegate: ApplyFilter? = nil
    var selectedApproach: Int? = 0
    var latitude = CLLocationDegrees()
    var longitude = CLLocationDegrees()
    var locManager =  CLLocationManager()
    var currentLocation: CLLocation!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
         if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                   CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
                   guard let currentLocation = locManager.location else {
                       return
            }
            self.longitude = currentLocation.coordinate.longitude
            self.latitude = currentLocation.coordinate.latitude
            var locName = String()
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: latitude, longitude: longitude)
            geoCoder.reverseGeocodeLocation(currentLocation, completionHandler: { (placemarks, error) -> Void in

                print("Response GeoLocation : \(placemarks)")
                var placeMark: CLPlacemark!
                placeMark = placemarks?[0]

                // Country
                if let country = placeMark.addressDictionary?["Country"] as? String {
                    if let city = placeMark.addressDictionary?["City"] as? String {
                        
                        // State
                        if let state = placeMark.addressDictionary?["State"] as? String{
                            
                            self.address.text = city + ", " + state + ", " + country
                            if let street = placeMark.addressDictionary?["Street"] as? String{
                                print("Street :- \(street)")
                                let str = street
                                let streetNumber = str.components(
                                    separatedBy: NSCharacterSet.decimalDigits.inverted).joined(separator: "")
                                print("streetNumber :- \(streetNumber)" as Any)

                                // ZIP
                                if let zip = placeMark.addressDictionary?["ZIP"] as? String{
                                    
                                    // Location name
                                    if let locationName = placeMark?.addressDictionary?["Name"] as? String {
                                        self.address.text = locationName + ", " + city + ", " + state + ", " + country
                                        // Street address
                                        if let thoroughfare = placeMark?.addressDictionary!["Thoroughfare"] as? NSString {
                                            self.address.text = "\(thoroughfare)"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            })
            
        }
    }
    
    // MARK: IBActions
    @IBAction func dismissAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
        
        // Display the autocomplete view controller.
        autocompleteController.modalPresentationStyle = .overFullScreen
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func continueAction(_ sender: Any) {
        self.filterDelegate?.reloadTable(approach: self.filterData[selectedApproach ?? 0], price: self.priceSlider.value, address: self.address.text ?? "", lat: self.latitude, long: self.longitude)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func priceChangeAction(_ sender: UISlider) {
       sender.value = roundf(sender.value)
        self.priceSliderValue.text = "\(sender.value)"
    }
}

extension FilterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell
        if(self.selectedApproach == indexPath.row){
            cell.backView.backgroundColor = darkBlue
            self.selectedApproach = indexPath.row
            cell.nameLabel.textColor = .white
        }else {
            cell.backView.backgroundColor = .white
            cell.nameLabel.textColor = .black
        }
        cell.nameLabel.text = self.filterData[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect.zero)
        label.text = self.filterData[indexPath.row]
        label.sizeToFit()
        let width = label.frame.width + 80
        return CGSize(width: width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FilterCell
        if(self.selectedApproach == indexPath.row){
            if(cell.backView.backgroundColor == .white){
                cell.backView.backgroundColor = darkBlue
                self.selectedApproach = indexPath.row
                cell.nameLabel.textColor = .white
            }else {
                cell.backView.backgroundColor = .white
                self.selectedApproach = nil
                cell.nameLabel.textColor = .black
            }
        }else {
            cell.backView.backgroundColor = darkBlue
            self.selectedApproach = indexPath.row
            cell.nameLabel.textColor = lightBlue
        }
        self.collectionView.reloadData()
    }
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.address.text = place.formattedAddress
        self.latitude = place.coordinate.latitude
        self.longitude = place.coordinate.longitude
        print("Place name: \(place.name)")
        print("Place ID: \(place.placeID)")
        print("Place attributions: \(place.attributions)")
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

class FilterCell: UICollectionViewCell {
    //MARK: IBOutlets
    @IBOutlet weak var filterName: CustomButton!
    @IBOutlet weak var nameLabel: DesignableUILabel!
    @IBOutlet weak var backView: View!
}
