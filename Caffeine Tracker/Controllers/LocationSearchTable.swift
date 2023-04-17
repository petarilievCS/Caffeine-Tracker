//
//  LocationSearchTableTableViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 13.3.23.
//

import UIKit
import MapKit

class LocationSearchTable: UITableViewController {
    private var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    var delegate: HandleMapSearch? = nil
    private var searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()
    
    // MARK: - View Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCompleter.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = true
        tableView.insetsContentViewsToSafeArea = true
        tableView.contentInsetAdjustmentBehavior = .automatic
    }
}

// MARK: - Location Search methods

extension LocationSearchTable : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
              let searchBarText = searchController.searchBar.text else { return }
        searchCompleter.region = mapView.region
        searchCompleter.queryFragment = searchBarText
        
    }
    
    // Parses MKPlacemark address into more readable format
    func parseAddress(selectedItem: MKPlacemark) -> String {
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) ? ", " : ""
        let secondSpace = selectedItem.locality != nil ? " " : ""
        // Regular location
        var addressLine = String(
            format:"%@%@%@%@%@%@%@",
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            selectedItem.thoroughfare ?? "",
            comma,
            selectedItem.locality ?? "",
            secondSpace,
            selectedItem.administrativeArea == selectedItem.locality ? "" : (selectedItem.administrativeArea ?? "")
        )
        // City
        if selectedItem.locality == selectedItem.name {
            if selectedItem.country == "United States" || selectedItem.country == "Canada" {
                addressLine = String(format: "%@, %@", selectedItem.administrativeArea ?? "", selectedItem.country ?? "")
            } else {
                addressLine = String(format: "%@", selectedItem.country ?? "")
            }
        }
        
        return addressLine
    }
}

// MARK: - TableView methods
extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell")!
        let selectedItem = searchResults[indexPath.row]
        cell.textLabel?.text = selectedItem.title
        cell.detailTextLabel?.text = selectedItem.subtitle
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let completion = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            if error == nil {
                self.delegate?.dropPinZoomIn(placemark: (response?.mapItems[0].placemark)!)
                if let safeResponse = response {
                    for item in safeResponse.mapItems {
                        print("Response")
                        self.delegate?.dropPin(placemark: item.placemark)
                    }
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Search Completer methods
extension LocationSearchTable: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        for result in searchResults {
            print("\(result.title) | \(result.subtitle)")
        }
        tableView.reloadData()
    }
    
    private func completer(completer: MKLocalSearchCompleter, didFailWithError error: NSError) {}
}
