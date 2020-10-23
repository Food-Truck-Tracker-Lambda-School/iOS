//
//  SearchVC.swift
//  FoodTruckTracker
//
//  Created by Norlan Tibanear on 10/16/20.
//

import UIKit
import MapKit

class SearchVC: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var mapKit: MKMapView!
    
    // MARK: - Properties
    
    fileprivate let locationManager = CLLocationManager()
    var span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    var userLocation: CLLocationCoordinate2D?
    var trucks: [TruckListing] = []
    var filteredTrucks: [TruckListing] = [] {
        didSet {
            createArrayForMap()
        }
    }
    var filters = Filters()
    var truckPins: [MKPointAnnotation] = []

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APIController.shared.fetchAllTrucks { result in
            switch result {
            case .success(let truckArray):
                DispatchQueue.main.async {
                    self.trucks = truckArray
                    self.createArrayForMap()
                }
            case .failure(let error):
                NSLog("Error fetching trucks: \(error)")
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modalFilterVC" {
            if let filterVC = segue.destination as? FilterViewController {
                filterVC.delegate = self
                filterVC.trucks = trucks
                filterVC.filters = filters
                if !filteredTrucks.isEmpty {
                    filterVC.filteredTrucks = filteredTrucks
                } else {
                    filterVC.filteredTrucks = trucks
                }
                filterVC.location = userLocation
            }
        } else if segue.identifier == "showTrucksTableVC" {
            if let tableVC = segue.destination as? TrucksTableViewController {
                if !filteredTrucks.isEmpty {
                    tableVC.filteredTrucks = filteredTrucks
                } else {
                    tableVC.filteredTrucks = trucks
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func setUpMap() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        mapKit.showsUserLocation = true
    }
    
    private func createArrayForMap() {
        var truckArray: [TruckListing]
        mapKit.removeAnnotations(truckPins)
        truckPins = []
        if !filteredTrucks.isEmpty {
            truckArray = filteredTrucks
        } else {
            truckArray = trucks
        }
        for truck in truckArray where truck.location.count > 12 {
            let coordinateArray = truck.location.components(separatedBy: " ")
            if let latitude = Double(coordinateArray[0]),
               let longitude = Double(coordinateArray[1]),
               let cuisine = truck.cuisine {
                let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let annotation = MKPointAnnotation()
                annotation.coordinate = location
                annotation.title = truck.name
                annotation.subtitle = cuisine
                truckPins.append(annotation)
            }
        }
        mapKit.showAnnotations(truckPins, animated: false)
        if let mapCenter = userLocation {
            let coordinateRegion = MKCoordinateRegion(center: mapCenter, span: span)
            mapKit.setRegion(coordinateRegion, animated: true)
        }
    }

} // SearchVC

extension SearchVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last! as CLLocation
        let currentLocation = location.coordinate
        userLocation = currentLocation
        let coordinateRegion = MKCoordinateRegion(center: currentLocation, span: span)
        mapKit.setRegion(coordinateRegion, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension SearchVC: FilterVCDelegate {
    func filterTrucks(filteredTrucks: [TruckListing]) {
        self.filteredTrucks = filteredTrucks
    }
    
    func setFilters(filters: Filters) {
        self.filters = filters
    }
}
