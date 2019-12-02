//
//  FirstViewController.swift
//  SafetyBuddy
//
//  Created by Nikash Taskar on 11/8/19.
//  Copyright © 2019 Nikash Taskar. All rights reserved.
//

import Firebase
import UIKit
import MapKit

protocol HandleMapSearch: class {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class FirstViewController: UIViewController {

    @IBOutlet weak var crimeMap: MKMapView!
    var locationManager = CLLocationManager()
    var currentLocationButton: UIButton!
    var currentLocation: CLLocation!
    var currentCoordinate: CLLocationCoordinate2D!
    @IBOutlet weak var centerLocationButton: UIBarButtonItem!
    @IBOutlet weak var switchButton: UIBarButtonItem!
    var selectedPin: MKPlacemark?
    var resultSearchController: UISearchController!
    let radius: Double = 1000
    var overlays = [MKOverlay]()
    
    var crimes: [Crime] = []
    
    var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
                observeQuery()
            }
        }
    }
    
    func initQuery(coordinates: CLLocationCoordinate2D) -> Query {
        return Firestore.firestore().collection("stl_crimes").order(by: "DateOccur", descending: true).limit(to: 800)
    }
    
    var listener: ListenerRegistration?
    
    func observeQuery() {
        guard let query = query else { return }
        stopObserving()
        
        self.listener = query.addSnapshotListener { [unowned self] (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error: \(error!)")
                return
            }
            let models = snapshot.documents.map { (document) -> Crime in
                if let model = Crime(dictionary: document.data()) {
                    return model
                } else {
                    fatalError("Error: Null model")
                }
            }
            
            self.crimes = models
            
            for crime in self.crimes {
                self.crimeMap.addAnnotation(crime)
            }
        }
    }
    
    func stopObserving() {
        listener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        subscribeToCrimes()
        
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        crimeMap.delegate = self
        crimeMap.showsUserLocation = true
        crimeMap.showsCompass = true
        crimeMap.setUserTrackingMode(.follow, animated: true)
        crimeMap.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        crimeMap.register(CrimeMarkerView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    
        self.currentCoordinate = CLLocationCoordinate2D(latitude: crimeMap.userLocation.coordinate.latitude, longitude: crimeMap.userLocation.coordinate.longitude)
        let startRegion = MKCoordinateRegion(center: self.currentCoordinate, latitudinalMeters: self.radius, longitudinalMeters: self.radius)
        
        query = initQuery(coordinates: self.currentCoordinate)
        
        crimeMap.setRegion(startRegion, animated: true)
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        locationSearchTable.mapView = crimeMap
        locationSearchTable.handleMapSearchDelegate = self
        
//        carTransport.layer.zPosition = 4
//        walkTransport.layer.zPosition = 4
//        transitTransport.layer.zPosition = 4
        
        crimeMap.layer.zPosition = 1
    }
    
    @objc func getDirections(){
        guard let selectedPin = selectedPin else { return }
        let mapItem = MKMapItem(placemark: selectedPin)
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: launchOptions)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        observeQuery()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        stopObserving()
    }
 
    @IBAction func centerUser(_ sender: Any) {
        crimeMap.setCenter(self.currentCoordinate, animated: true)
        crimeMap.isRotateEnabled = true
        let startRegion = MKCoordinateRegion(center: self.currentCoordinate, latitudinalMeters: self.radius, longitudinalMeters: self.radius)
        crimeMap.setRegion(startRegion, animated: true)
    }
    
    @IBAction func mapStyleToggle(_ sender: Any) {
        if crimeMap.mapType == MKMapType.standard {
            crimeMap.mapType = MKMapType.hybrid
        } else {
            crimeMap.mapType = MKMapType.standard
        }
    }
    
    @objc func tap(_ sender: Any){
        
    }
    
}

extension FirstViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentCoordinate = locations.first?.coordinate else { return }
        
        self.currentCoordinate = currentCoordinate
    }
}

extension FirstViewController: MKMapViewDelegate{
    
}

extension FirstViewController: HandleMapSearch {
    
    func dropPinZoomIn(placemark: MKPlacemark){
        // cache the pin
//        selectedPin = placemark
        // clear existing pins
//        crimeMap.removeAnnotations(crimeMap.annotations)
        let destAnnotation = MKPointAnnotation()
        destAnnotation.coordinate = placemark.coordinate
        destAnnotation.title = placemark.name
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
                destAnnotation.subtitle = "\(city) \(state)"
        }
        
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.coordinate = self.currentCoordinate
        sourceAnnotation.title = "Current Location"
        
        self.crimeMap.showAnnotations([sourceAnnotation, destAnnotation], animated: true)
        
        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate, addressDictionary: nil)
        let destPlacemark = MKPlacemark(coordinate: placemark.coordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destMapItem = MKMapItem(placemark: destPlacemark)
        
        let request = MKDirections.Request()
        
        request.source = sourceMapItem
        request.destination = destMapItem
        
        request.transportType = .init(arrayLiteral: [.walking])
        
        if self.overlays.count > 0 {
            crimeMap.removeOverlays(self.overlays)
        }
        
        let directions = MKDirections(request: request)
        directions.calculate(completionHandler: { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            for route in unwrappedResponse.routes {
                self.crimeMap.addOverlay(route.polyline)
                self.overlays.append(route.polyline)
                self.crimeMap.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
            
        })
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
                var polylineRenderer = MKPolylineRenderer(overlay: overlay)
                polylineRenderer.strokeColor = UIColor.blue
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        return MKOverlayRenderer()
    }
    
}
