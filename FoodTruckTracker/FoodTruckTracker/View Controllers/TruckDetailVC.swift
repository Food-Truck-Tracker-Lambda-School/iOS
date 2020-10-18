//
//  TruckDetailVC.swift
//  FoodTruckTracker
//
//  Created by Norlan Tibanear on 10/16/20.
//

import UIKit
import MapKit
import CoreLocation

class TruckDetailVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // Outlets
    @IBOutlet private weak var truckImageView: UIImageView!
    @IBOutlet private weak var truckNameLabel: UILabel!
    @IBOutlet private weak var cuisineTypeLabel: UILabel!
    @IBOutlet private weak var avgRatingLabel: UILabel!
    
    @IBOutlet private weak var mapView: MKMapView!
    
    
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        self.mapView.showsUserLocation = true
    }
    

    @IBAction func rateThisTruckButton(_ sender: UIButton) {
    }
    
    @IBAction func addToFavoritesButton(_ sender: UIButton) {
    }
    
    
    @IBAction func goToLocationGPS(_ sender: UIButton) {
        
        let addressL = "3801 E 10th ave Hialeah Fl, 33010"
        print("New Address \(addressL)")
        
        self.reverseGeocode(address: addressL, completion: { (placemark) in
            
            let destinationPlacemark = MKPlacemark(coordinate: (placemark.location?.coordinate)!)
            
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
            
            MKMapItem.openMaps(with: [destinationMapItem], launchOptions: nil)
        })
        
    }
    
    private func reverseGeocode(address: String, completion: @escaping(CLPlacemark) -> ()) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let placemarks = placemarks,
                let placemark = placemarks.first else {
                    return
            }
            
            completion(placemark)
        }
    }
    
    // Coordinates
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
        
        mapView.setRegion(region, animated: true)
    }
    
    
    
} // truckDetailVC
