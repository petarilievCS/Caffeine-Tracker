//
//  MapViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 13.3.23.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        mapView.layer.cornerRadius = 15.0
    }
}

// MARK: - LocationManager Delegate methods
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            mapView.showsUserLocation = true
            mapView.setCameraZoomRange(MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 20000), animated: true)
            mapView.setCenter(location.coordinate, animated: true)
            mapView.region.center = location.coordinate
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = "coffee"
            request.region = mapView.region
            
            print("Region center: \(mapView.region.center.latitude), \(mapView.region.center.longitude)")
            
            let search = MKLocalSearch(request: request)
            search.start { (response, error) in
                guard let response = response else {
                    fatalError("Error: \(String(describing: error))")
                }
                
                for item in response.mapItems {
                    if let name = item.name,
                        let location = item.placemark.location {
                        print("\(name): \(location.coordinate.latitude),\(location.coordinate.longitude)")
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = location.coordinate
                        self.mapView.addAnnotation(annotation)
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
