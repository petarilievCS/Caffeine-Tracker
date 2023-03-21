//
//  MapViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 13.3.23.
//

import UIKit
import MapKit
import CoreLocation
import AVFoundation

protocol HandleMapSearch {
    func dropPinZoomIn(placemark: MKPlacemark)
    func dropPin(placemark: MKPlacemark)
}

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var coffeeButton: UIButton!
    
    private let locationManager = CLLocationManager()
    var resultSearchController: UISearchController? = nil
    var selectedPin: MKPlacemark? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        customizeButton(locationButton)
        customizeButton(coffeeButton)
        mapView.showsCompass = false
        mapView.delegate = self
        
        // Configure location search table
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        // Configure search bar
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for coffee shops"
        navigationItem.titleView = resultSearchController?.searchBar
        navigationItem.titleView?.backgroundColor = .systemBackground
        resultSearchController?.navigationController?.navigationBar.backgroundColor = .systemBackground
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.searchBar.backgroundColor = .systemBackground
        resultSearchController?.navigationItem.titleView?.backgroundColor = .systemBackground
        definesPresentationContext = true
        
        mapView.layer.cornerRadius = 15.0
    }
    
    func customizeButton(_ button: UIButton) {
        button.layer.cornerRadius = 10
        button.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15.0)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 5.0
    }
    
    // MARK: - IBActions
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        self.locationButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        if let location = locationManager.location {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.locationButton.setImage(UIImage(systemName: "location"), for: .normal)
        }
    }
    
    
    @IBAction func coffeeButtonPressed(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        coffeeButton.setImage(UIImage(systemName: "cup.and.saucer.fill"), for: .normal)
        
        let request = MKLocalSearch.Request()
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        request.region = MKCoordinateRegion(center: mapView.centerCoordinate, span: span)
        request.naturalLanguageQuery = "coffee shop"
        
        mapView.removeAnnotations(mapView.annotations)
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else {
                fatalError("Error: \(String(describing: error))")
            }
            
            for item in response.mapItems {
                if let name = item.name,
                   let location = item.placemark.location {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location.coordinate
                    annotation.title = name
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.coffeeButton.setImage(UIImage(systemName: "cup.and.saucer"), for: .normal)
        }
    }
}


// MARK: - LocationManager Delegate methods
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {}
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

// MARK: - Map Pin methods

extension MapViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func dropPin(placemark: MKPlacemark) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        mapView.addAnnotation(annotation)
    }
}

// MARK: - MapView delegate methods
extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.markerTintColor = .orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 40, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPointZero, size: smallSquare))
        button.setBackgroundImage(UIImage(systemName: "car.fill"), for: [])
        button.addTarget(self, action: #selector(self.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
    @objc func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
}
