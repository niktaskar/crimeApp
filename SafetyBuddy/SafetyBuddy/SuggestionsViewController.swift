//
//  SuggestionsViewController.swift
//  SafetyBuddy
//
//  Created by Shane Blair on 12/1/19.
//  Copyright © 2019 Nikash Taskar. All rights reserved.
//

import UIKit
import MapKit

class SuggestionsViewController: UIViewController, MKLocalSearchCompleterDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let locationManager = CLLocationManager()
    
    lazy var completion: MKLocalSearchCompleter = {
        let completer = MKLocalSearchCompleter()
        completer.delegate = self
        completer.region = MKCoordinateRegion(center: locationManager.location!.coordinate, latitudinalMeters: 1609, longitudinalMeters: 1609)
        if #available(iOS 13.0, *) {
            completer.resultTypes = [.address, .pointOfInterest]
        }
        
        return completer
    }()
    
    var results = [MKLocalSearchCompletion]()
    var coordinate: CLLocationCoordinate2D? = CLLocationCoordinate2D()
    var streetName: String? = ""
    var streetNumber: String? = ""
    
    @IBOutlet weak var suggestionsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            completion.queryFragment = ""
        }
        else {
            completion.queryFragment = searchText
        }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
        suggestionsTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "suggestionCell")
        let result = results[indexPath.row]
        cell.textLabel?.text = result.title
        cell.detailTextLabel?.text = result.subtitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSuggestion = results[indexPath.row]
        
        let search = MKLocalSearch(request: MKLocalSearch.Request(completion: selectedSuggestion))
        search.start{
            (response, error) in
            if error == nil {
                let mapPlacemark = response?.mapItems[0].placemark
                
                self.coordinate = mapPlacemark?.coordinate
                self.streetName = mapPlacemark?.thoroughfare
                self.streetNumber = mapPlacemark?.subThoroughfare
                
                let currentLocation = self.locationManager.location
                let distance = currentLocation?.distance(from: CLLocation(latitude: self.coordinate!.latitude, longitude: self.coordinate!.longitude))
                
                if distance! > 1609 {
                    let alert = UIAlertController(title: "Too far from location.", message: "You are too far from that location to report it. Please select another location", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {action in
                    }))
                    
                    self.present(alert, animated: true)
                }
                else {
                    self.performSegue(withIdentifier: "suggestionDetailsSegue", sender: self)
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        suggestionsTableView.dataSource = self
        suggestionsTableView.delegate = self
        
        searchBar.delegate = self
        searchBar.placeholder = "Search for location to report"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailsViewController  = segue.destination as? ThirdViewController else { return }

        detailsViewController.coordinates = self.coordinate
        detailsViewController.streetNameData = self.streetName
        detailsViewController.streetNumberData = self.streetNumber
    }

}
