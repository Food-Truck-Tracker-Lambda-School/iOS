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
    var truck: TruckListing?
    var location: CLLocationCoordinate2D?
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        
        self.mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        self.mapView.showsUserLocation = true
        createAnnotation()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMenuSegue" {
            if let menuVC = segue.destination as? MenuTableVC,
               let truck = truck {
                menuVC.truck = truck
            }
        }
    }
    
    // MARK: - Actions

    @IBAction func rateThisTruckButton(_ sender: UIButton) {
        guard APIController.shared.userRole == .diner else {
            self.presentFTAlertOnMainThread(title: "Error", message: "Only diners can post ratings.", buttonTitle: "Ok")
            return
        }
        setUpRating()
    }
    
    @IBAction func addToFavoritesButton(_ sender: UIButton) {
        guard APIController.shared.userRole == .diner else {
            self.presentFTAlertOnMainThread(title: "Error", message: "Only diners can add a truck to favorites.", buttonTitle: "Ok")
            return
        }
        guard let truck = truck,
              let identifer = truck.identifier else {
            self.presentFTAlertOnMainThread(title: "Sorry!", message: "Unable to add to favorites.", buttonTitle: "Ok")
            return
        }
        APIController.shared.addTruckToFavorites(truckId: identifer)
    }
    
    
    @IBAction func goToLocationGPS(_ sender: UIButton) {
        guard let location = location else { return }
        let destination = MKPlacemark(coordinate: location)
        let destinationItem = MKMapItem(placemark: destination)
        destinationItem.name = truck?.name
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        destinationItem.openInMaps(launchOptions: [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center),
                                                   MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: region.span),
                                                   MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    // MARK: - Private Functions
    
    private func reverseGeocode(address: String, completion: @escaping(CLPlacemark) -> Void) {
        
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(address) { placemarks, error in
            
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
    
    private func updateViews() {
        truckNameLabel.text = truck?.name
        cuisineTypeLabel.text = truck?.cuisine
    }
    
    private func createAnnotation() {
        if let truck = truck {
            let coordinateArray = truck.location.components(separatedBy: " ")
            if let latitude = Double(coordinateArray[0]),
               let longitude = Double(coordinateArray[1]),
               let cuisine = truck.cuisine {
                location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                guard let location = location else { return }
                let annotation = MKPointAnnotation()
                annotation.coordinate = location
                annotation.title = truck.name
                annotation.subtitle = cuisine
                mapView.addAnnotation(annotation)
                let region = MKCoordinateRegion(center: location, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                mapView.setRegion(region, animated: true)
            }
        }
    }
    
    private func setUpRating() {
        let alert = UIAlertController(title: "Truck Rating", message: "Please choose a rating.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "⭐️", style: .default, handler: { _ in
            let rating = 1
            self.sendRating(rating)
        }))
        alert.addAction(UIAlertAction(title: "⭐️⭐️", style: .default, handler: { _ in
            let rating = 2
            self.sendRating(rating)
        }))
        alert.addAction(UIAlertAction(title: "⭐️⭐️⭐️", style: .default, handler: { _ in
            let rating = 3
            self.sendRating(rating)
        }))
        alert.addAction(UIAlertAction(title: "⭐️⭐️⭐️⭐️", style: .default, handler: { _ in
            let rating = 4
            self.sendRating(rating)
        }))
        alert.addAction(UIAlertAction(title: "⭐️⭐️⭐️⭐️⭐️", style: .default, handler: { _ in
            let rating = 5
            self.sendRating(rating)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func sendRating(_ rating: Int) {
        guard let truck = self.truck,
              let identifer = truck.identifier else {
            self.presentFTAlertOnMainThread(title: "Sorry!", message: "Unable to rate this truck.", buttonTitle: "Ok")
            return
        }
        APIController.shared.postRating(rating: rating, truckId: identifer, itemId: nil) { result in
            switch result {
            case .success(true):
                DispatchQueue.main.async {
                    self.presentFTAlertOnMainThread(title: "Thank you!", message: "We appreciate you taking the time to rate this truck.", buttonTitle: "Ok")
                }
            default:
                DispatchQueue.main.async {
                    self.presentFTAlertOnMainThread(title: "Sorry!", message: "Unable to rate this truck.", buttonTitle: "Ok")
                }
            }
        }
    }
    
    // MARK: - Coordinates
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008))
        
        mapView.setRegion(region, animated: true)
        
    }
    
} // truckDetailVC
