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
    
    // MARK: - Outlets
    
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
        if truck == nil {
            navigationController?.popViewController(animated: true)
        }
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
        self.presentFTAlertOnMainThread(title: "Success!", message: "This truck has been added to your favorites.", buttonTitle: "Ok")
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
    
    private func updateViews() {
        guard let truck = truck else { return }
        title = truck.name
        truckNameLabel.text = truck.name
        cuisineTypeLabel.text = truck.cuisine
        let average = RatingController.shared.averageRating(ratings: truck.ratings)
        avgRatingLabel.text = String(average)
        updateImageView()
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
        APIController.shared.postRating(ratingInt: rating, truckId: identifer, itemId: nil) { result in
            switch result {
            case .success(true):
                self.presentFTAlertOnMainThread(title: "Thank you!", message: "We appreciate you taking the time to rate this truck.", buttonTitle: "Ok")
                DispatchQueue.main.async {
                    self.updateAverageRating()
                }
            default:
                self.presentFTAlertOnMainThread(title: "Sorry!", message: "Unable to rate this truck.", buttonTitle: "Ok")
            }
        }
    }
    
    private func updateAverageRating() {
        guard let truck = truck,
              let identifier = truck.identifier else { return }
        APIController.shared.fetchRatings(truckId: identifier, itemId: nil) { result in
            switch result {
            case .success(let ratings):
                DispatchQueue.main.async {
                    let average = RatingController.shared.averageRating(ratings: ratings)
                    switch average {
                    case 0:
                        self.avgRatingLabel.text = ""
                    default:
                        self.avgRatingLabel.text = String(average)
                    }
                }
            default:
                return
            }
        }
    }
    
    private func updateImageView() {
        if let imageArray = ImageController.shared.getUIImage(nil, truck, nil) {
            truckImageView.image = imageArray[0]
        } else {
            guard let truck = truck,
                  let imageString = truck.imageString,
                  !imageString.isEmpty else { return }
            APIController.shared.fetchImage(at: imageString) { result in
                switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self.truckImageView.image = image
                    }
                default:
                    return
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
