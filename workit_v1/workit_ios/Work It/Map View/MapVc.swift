

import UIKit
import MapKit
 
class MapVC: UIView,MKMapViewDelegate {
    //MARK: IBOUtlets
   
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var contentview: UIView!
    
    var location = [MKPointAnnotation]()
    var latitude: Double = 0
    var address = "address"
    var longitude: Double = 0 {
        didSet {
            if(self.latitude != 0){
             self.showSitterLocation()
            }
        }
    }

    override init(frame: CGRect) {
         super.init(frame: frame)
         commonInit()
     }
     
     required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
         commonInit()
     }
     
     func commonInit() {
        Bundle.main.loadNibNamed("MapView", owner: self, options: nil)
        contentview.fixInView(self)
        self.mapView.delegate = self
        self.showSitterLocation()
     }
    
    func showSitterLocation() {
        
        let location = MKPointAnnotation()
        location.title = "\(self.address)"
       // let lat = Int(Int((((latitude as Double).doubleValue)*100).rounded()))/100
        //let long = Int(Int((((longitude as Double).doubleValue)*100).rounded()))/100
        
        location.coordinate = CLLocationCoordinate2D(latitude: self.latitude    ,longitude:self.longitude)
        self.location.append(location)
        let span = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.showAnnotations(self.location, animated: true)
        mapView.setRegion(MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500), animated: true)
        if(CLLocationCoordinate2DIsValid(location.coordinate)){
          mapView.setCenter(location.coordinate, animated: true)
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        if annotation is MKUserLocation {
            return nil
        }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
             annotationView?.canShowCallout = true
            let pinImage = #imageLiteral(resourceName: "placeholder(7)")
            let size = CGSize(width: 35, height: 40)
            UIGraphicsBeginImageContext(size)
            pinImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            annotationView?.image = resizedImage
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
}


extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
