//
//  LocationSearchTableTableViewController.swift
//  Caffeine Tracker
//
//  Created by Petar Iliev on 13.3.23.
//

import UIKit
import MapKit

class LocationSearchTable: UITableViewController {

    var matchingItems:[MKMapItem] = []
    var mapView: MKMapView? = nil
    var handleMapSearchDelegate: HandleMapSearch? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.translatesAutoresizingMaskIntoConstraints = true
        tableView.insetsContentViewsToSafeArea = true
        tableView.contentInsetAdjustmentBehavior = .automatic
    }
    
    func parseAddress(selectedItem:MKPlacemark) -> String {

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

// MARK: - Location Search methods

extension LocationSearchTable : UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
            let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
}

// MARK: - TableView methods
extension LocationSearchTable {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        // cell.detailTextLabel?.text = selectedItem. ?? ""
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
    }
}

